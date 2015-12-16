//
//  GameViewController.m
//  SampleTCPClient
//
//  Created by Nozomu MIURA on 2015/12/14.
//  Copyright © 2015年 TECHLIFE SG Pte.Ltd. All rights reserved.
//

#import "TCPClientAppDelegate.h"
#import "GameViewController.h"
#import "TL_INetSyphonSDK/TL_INetSyphonSDK.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))


@interface GameViewController () {
    TL_INetTCPSyphonSDK*            m_TCPSyphonSDK;
    
    GLuint _program;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    GLint   _textureUniform;
    
    CGSize  _GotTextureSize;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end


@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSNotificationCenter*	center = [NSNotificationCenter defaultCenter];

    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    [center addObserver:self selector:@selector(OnNotify_EnterBackground:) name:Notification_EnterBackground object:nil];
    [center addObserver:self selector:@selector(OnNotify_BecomeActive:) name:Notification_BecomeActive object:nil];
    [center addObserver:self selector:@selector(OnNotify_ChangeTCPSyphonServerList:) name:TL_INetSyphonSDK_ChangeTCPSyphonServerListNotification object:nil];

    m_TCPSyphonSDK = [[TL_INetTCPSyphonSDK alloc] init];
        
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormatNone;
    
    [self setupGL];
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [super dealloc];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders];
    
    glDisable(GL_CULL_FACE);
    glDisable(GL_DEPTH_TEST);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    if ( _vertexBuffer )
    {
        glDeleteBuffers(1, &_vertexBuffer);
        glDeleteVertexArrays(1, &_vertexArray);
    }
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    GLuint  texture;
    CGSize  texturesize;

    [m_TCPSyphonSDK ClientIdle];
 
    glClearColor( 0.0f, 0.0f, 0.3f, 0.0f );
    glClear( GL_COLOR_BUFFER_BIT );

    if ( ![m_TCPSyphonSDK GetReceiveTextureFromTCPSyphonServer:&texture Resolution:&texturesize] )
    {
        if ( (_GotTextureSize.width!=texturesize.width) && (_GotTextureSize.height!=texturesize.height) )
        {
            float x, y, sw, sh;
            CGSize rendersize;

            _GotTextureSize = texturesize;

            CGSize canvassize = self.view.bounds.size;

            //sorry for messy code due to adjust aspect and centering.
            sw = 1;
            rendersize.width = canvassize.width;
            rendersize.height = canvassize.width * ( texturesize.height / texturesize.width );
            if ( rendersize.height > canvassize.height )
            {
                sh = 1;
                rendersize.height = canvassize.height;
                rendersize.width = canvassize.height * ( texturesize.width / texturesize.height );
                sw = rendersize.width / canvassize.width;
            }
            else
                sh = rendersize.height / canvassize.height;
            
            sw *= 2;
            sh *= 2;
            x = -1 + ( 2.0f - sw ) / 2.0f;
            y = -1 + ( 2.0f - sh ) / 2.0f;
            GLfloat surfaceVertexData[5*6] =
            {
                x, y, 0,      0, 0,
                x+sw, y, 0,      1, 0,
                x+sw, y+sh, 0,      1, 1,
                
                x+sw, y+sh, 0,      1, 1,
                x, y+sh, 0,      0, 1,
                x, y, 0,      0, 0,
            };
            
            if ( _vertexBuffer )
            {
                glDeleteBuffers(1, &_vertexBuffer);
                glDeleteVertexArrays(1, &_vertexArray);
            }
            glGenVertexArrays(1, &_vertexArray);
            glBindVertexArray(_vertexArray);
            
            glGenBuffers(1, &_vertexBuffer);
            glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
            glBufferData(GL_ARRAY_BUFFER, sizeof(surfaceVertexData), surfaceVertexData, GL_STATIC_DRAW);
            
            glEnableVertexAttribArray(GLKVertexAttribPosition);
            glVertexAttribPointer( GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 5*4, BUFFER_OFFSET(0));
            glEnableVertexAttribArray( GLKVertexAttribTexCoord0 );
            glVertexAttribPointer( GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 5*4, BUFFER_OFFSET(3*4));
        }

        glUseProgram(_program);
        
        glBindVertexArray(_vertexArray);
        
        glActiveTexture( GL_TEXTURE0 );
        glBindTexture( GL_TEXTURE_2D, texture );
        
        glDrawArrays( GL_TRIANGLES, 0, 2*3 );

        glBindTexture( GL_TEXTURE_2D, 0 );
        
        glUseProgram( 0 );
    }
}


#pragma mark -  OpenGL ES shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord0, "TexCoordIn");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    _textureUniform = glGetUniformLocation( _program, "Texture" );
    glUniform1i( _textureUniform, 0 );

    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}


- (void)OnNotify_ChangeTCPSyphonServerList:(NSNotification *)aNotification
{
    NSArray*    servers = [m_TCPSyphonSDK GetTCPSyphonServerInformation];
    NSLog( @"Changed TCPSyphonServers--------------" );
    for (NSDictionary* info in servers)
    {
        NSLog( @"%@", info );
    }
    NSLog( @"---" );
    
    //If no connection, then try connecting first one.
    if ( [[m_TCPSyphonSDK GetConnectedTCPSyphonServerName] length] <= 0 )
    {
        if ( [servers count] > 0 )
        {
            [m_TCPSyphonSDK ConnectToTCPSyphonServerAtIndex:0];
        }
    }
}


-(void)OnNotify_EnterBackground:(NSNotification *)notification
{
    [m_TCPSyphonSDK StopClient];
}


-(void)OnNotify_BecomeActive:(NSNotification *)notification
{
    [m_TCPSyphonSDK StartClient];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //Request to make vertextbuffer again.
    _GotTextureSize = CGSizeZero;
}

@end

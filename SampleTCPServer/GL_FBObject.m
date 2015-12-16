//
//  GL_FBObject.m
//  INetSyphon_iOS_SDK
//
//  Created by Nozomu MIURA on 2015/12/16.
//  Copyright © 2015 TECHLIFE SG Pte.Ltd. All rights reserved.
//

#import "GL_FBObject.h"

@implementation GL_FBObject


- (id)initWithWidth:(int)w Height:(int)h
{
    self = [super init];
    if (self)
    {
        m_Width = w;
        m_Height = h;
    }
    return self;
}


- (void)dealloc
{
    [self FreeFrameBuffer];

    [super dealloc];
}


-(void)FreeFrameBuffer
{
    glBindFramebuffer( GL_FRAMEBUFFER, 0 );

    if ( m_FrameBuffer )
    {
        if ( m_RenderTexture )
        {
            glDeleteTextures( 1, &m_RenderTexture );
            m_RenderTexture = 0;
        }
        
        if ( m_DepthRenderBuffer )
        {
            glDeleteRenderbuffers( 1, &m_DepthRenderBuffer );
            m_DepthRenderBuffer = 0;
        }
        
        glDeleteFramebuffers( 1, &m_FrameBuffer );
        m_FrameBuffer = 0;
    }
}


-(void)CreateFrameBuffer
{
    GLuint	textureBuffer;
    GLenum	status;

    glGetIntegerv( GL_FRAMEBUFFER_BINDING, &m_OldFBO );

    glGenRenderbuffers(1, &m_DepthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, m_DepthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, m_Width, m_Height );
    
    
    glGenFramebuffers( 1, &m_FrameBuffer );
    glBindFramebuffer( GL_FRAMEBUFFER, m_FrameBuffer );
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, m_DepthRenderBuffer);

    glGenTextures( 1, &textureBuffer );
    glBindTexture( GL_TEXTURE_2D, textureBuffer );
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );//GL_LINEAR
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    
    glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA8, m_Width, m_Height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0 );
    glFramebufferTexture2D( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0+0, GL_TEXTURE_2D, textureBuffer, 0 );
    
    status = glCheckFramebufferStatus( GL_FRAMEBUFFER );
    glBindFramebuffer( GL_FRAMEBUFFER, m_OldFBO );
    
    if ( status != GL_FRAMEBUFFER_COMPLETE )
    {
        NSLog( @"glCheckFramebufferStatus error" );
        
        glDeleteTextures( 1, &textureBuffer );
        textureBuffer = 0;
    }
    m_RenderTexture = textureBuffer;
}


-(void)Bind
{
    glGetIntegerv( GL_FRAMEBUFFER_BINDING, &m_OldFBO );
    
    glBindFramebuffer( GL_FRAMEBUFFER, m_FrameBuffer );
    
    GLenum DrawBuffers[1] = { GL_COLOR_ATTACHMENT0 };
    glDrawBuffers( 1, DrawBuffers );

    glGetIntegerv( GL_VIEWPORT, m_Viewport );

    glViewport( 0, 0, m_Width, m_Height );
}


-(void)Unbind
{
    glBindFramebuffer( GL_FRAMEBUFFER, m_OldFBO );
    
    glViewport( m_Viewport[0], m_Viewport[1], m_Viewport[2], m_Viewport[3] );
}

@end

//
//  GL_FBObject.h
//  INetSyphon_iOS_SDK
//
//  Created by Nozomu MIURA on 2015/12/16.
//  Copyright © 2015 TECHLIFE SG Pte.Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

@interface GL_FBObject : NSObject
{
    GLuint      m_FrameBuffer;
    
    GLuint      m_DepthRenderBuffer;
    GLuint      m_RenderTexture;
    
    GLint       m_OldFBO;
    GLint       m_Viewport[4];
    
    int         m_Width;
    int         m_Height;
}

- (id)initWithWidth:(int)w Height:(int)h;

-(void)CreateFrameBuffer;

-(void)Bind;
-(void)Unbind;

@end

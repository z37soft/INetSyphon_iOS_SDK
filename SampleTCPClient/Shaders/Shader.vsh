//
//  Shader.vsh
//  SampleTCPClient
//
//  Created by Nozomu MIURA on 2015/12/14.
//  Copyright © 2015 TECHLIFE SG Pte.Ltd. All rights reserved.
//

attribute vec4 position;
attribute vec2 TexCoordIn;

varying vec2 TexCoordOut;

void main()
{
    TexCoordOut = TexCoordIn;
    
    gl_Position = position;
}

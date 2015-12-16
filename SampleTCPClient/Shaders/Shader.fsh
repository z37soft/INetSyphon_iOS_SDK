//
//  Shader.fsh
//  SampleTCPClient
//
//  Created by Nozomu MIURA on 2015/12/14.
//  Copyright © 2015 TECHLIFE SG Pte.Ltd. All rights reserved.
//

varying lowp vec2 TexCoordOut;
uniform sampler2D Texture;

void main()
{
    gl_FragColor = texture2D(Texture, TexCoordOut);
}

//
//  Shader.fsh
//  SampleTCPServer
//
//  Created by Nozomu MIURA on 2015/12/13.
//  Copyright © 2015年 TECHLIFE SG Pte.Ltd. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}

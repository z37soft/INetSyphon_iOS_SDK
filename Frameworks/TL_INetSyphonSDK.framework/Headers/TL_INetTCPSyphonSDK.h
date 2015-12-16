//
//  TL_INetTCPSyphonSDK.h
//  TL_INetSyphonSDK
//
//  Created by Nozomu MIURA on 2015/11/12.
//  Copyright © 2015年 TECHLIFE SG Pte.Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TL_INetSyphonSDK.h"
#import <GLKit/GLKit.h>

#define TL_INetSyphonSDK_ChangeTCPSyphonServerListNotification   @"TL_INetSyphonSDK_ChangeTCPSyphonServerListNotification"

@interface TL_INetTCPSyphonSDK : NSObject

//-=-= SERVER SECTION -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//Control server
-(void)StartServer:(NSString*)appname;
-(void)StopServer;

-(void)SetSendData:(NSData*)buffer Width:(int)w Height:(int)h;
-(void)SetSendImage:(CVImageBufferRef)buffer FlipHorizontal:(BOOL)fh FlipVertical:(BOOL)fv;

//set parameters
//Default encode type: TCPUDPSyphon::EncodeType_TURBOJPEG
-(void)SetEncodeType:(TCPUDPSyphonEncodeType)encodetype;
//Default encode quality: 0.5 ( bad:0.0, good:1.0 )
-(void)SetEncodeQuality:(float)quality;

//get information
-(NSDictionary*)GetSyphonServerInformation;
-(NSArray*)GetTCPSyphonClientInformation;
-(unsigned int)GetSendingDataSize;
//-=-= SERVER SECTION -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

//-=-= CLIENT SECTION -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//Control client
-(void)StartClient;
-(void)StopClient;

//Connect,Disconnect
-(void)ConnectToTCPSyphonServerAtIndex:(int)index;
-(int)ConnectToTCPSyphonServerByName:(NSString*)name;
-(void)DisconnectToTCPSyphonServer;
-(NSString*)GetConnectedTCPSyphonServerName;

-(NSString*)GetAverageFPS;

-(void)ClientIdle;
-(int)GetReceiveTextureFromTCPSyphonServer:(GLuint*)texture Resolution:(CGSize*)texturesize;

-(NSArray*)GetTCPSyphonServerInformation;
//-=-= CLIENT SECTION -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

@end

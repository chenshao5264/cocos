//
//  WXApiManager.m
//  SDKSample
//
//  Created by Jeason on 16/07/2015.
//
//

#import "WXApiManager.h"

#import "cocos2d.h"

@implementation WXApiManager

#pragma mark - LifeCycle
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static WXApiManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXApiManager alloc] init];
    });
    return instance;
}

- (void)dealloc {
    self.delegate = nil;
    [super dealloc];
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp
{
    //tmp.errCode = 0 成功
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        SendMessageToWXResp* tmp = (SendMessageToWXResp*)resp;
        int ret = tmp.errCode;
        NSLog(@"res = %d", ret);
        
        [self.delegate managerDidRecvMessageResponse:[[NSString alloc] initWithFormat:@"%d", ret]];
       
    }
    else if([resp isKindOfClass:[SendAuthResp class]])
    {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        int ret = authResp.errCode;
        NSLog(@"res = %d", ret);
        
        [_delegate managerDidRecvAuthResponse:authResp];
    }
    else if ([resp isKindOfClass:[PayResp class]])
    {
        PayResp* payResp = (PayResp*) resp;
        
        [_delegate managerDidRecvPayResponse:payResp];
    }
}

- (void)onReq:(BaseReq *)req
{

}

@end

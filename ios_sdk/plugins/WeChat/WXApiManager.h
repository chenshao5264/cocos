//
//  WXApiManager.h
//  SDKSample
//
//  Created by Jeason on 16/07/2015.
//
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

@protocol WXApiManagerDelegate <NSObject>

@optional

// 微信分享 结果delegate
- (void) managerDidRecvMessageResponse: (NSString *)response;

//
//- (void)managerDidRecvGetMessageReq:(GetMessageFromWXReq *)request;
//
//- (void)managerDidRecvShowMessageReq:(ShowMessageFromWXReq *)request;
//
//- (void)managerDidRecvLaunchFromWXReq:(LaunchFromWXReq *)request;
//
//- (void)managerDidRecvMessageResponse:(SendMessageToWXResp *)response;
//

// 微信登陆 结果delegate
- (void)managerDidRecvAuthResponse:(SendAuthResp *)response;

// 微信 支付
- (void)managerDidRecvPayResponse:(PayResp *)response;

//
//- (void)managerDidRecvAddCardResponse:(AddCardToWXCardPackageResp *)response;
//
@end

@interface WXApiManager : NSObject<WXApiDelegate>

@property (nonatomic, assign) id<WXApiManagerDelegate> delegate;

+ (instancetype)sharedManager;

@end

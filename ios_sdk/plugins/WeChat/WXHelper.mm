//
//  WXHelper.m
//  zebra
//
//  Created by 辰少 on 16/8/23.
//
//

#import "WXHelper.h"
#import "WXApi.h"
#import "QSHelper.h"
#import "WXApiManager.h"

@interface WXHelper() <WXApiManagerDelegate> {
    int mShareResultCallBack; //分享结果回调
    int mLoginResultCallBack;
    int mLuaPayResultFunctionID; //支付结果 lua回调id
}
@end

@implementation WXHelper

+ (instancetype)getInstance {
    static dispatch_once_t onceToken;
    static WXHelper *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXHelper alloc] init];
        [WXApiManager sharedManager].delegate = instance;
    });
    return instance;
}

- (BOOL)isWXAppInstalled
{
    return [WXApi isWXAppInstalled];
}

- (void)startLogin
{
    SendAuthReq* req = [[[SendAuthReq alloc] init] autorelease];
    req.openID = WX_AUTH_OPENID;
    req.scope = WX_AUTH_SCOPE;
    req.state = WX_AUTH_STATE;
    
    [WXApi sendReq:req];
    
    [QSHelper setCurrentPlugin:Plugin_WeChat];
}

- (void) startSharePhoto: (NSString *) strImagePath
             Description: (NSString *) strDescription
                 TagName: (NSString *) strImageTagName
                   Title: (NSString *) strImageTitle
              MessageExt: (NSString *) strMessageExt
                  Action: (NSString *) strAction
              ThumbImage: (NSString *) strThumbImage
              ShareScene: (int) shareScene
{
    
    NSString *filePath = strImagePath;
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];

    WXImageObject *ext = [WXImageObject object];
    ext.imageData = imageData;
    
    
    WXMediaMessage* message = [WXMediaMessage message];
    message.title = strImageTitle;
    message.description = strDescription;
    message.mediaObject = ext;
    message.messageExt = strMessageExt;
    message.messageAction = strAction;
    message.mediaTagName = strImageTagName;
    
    UIImage *thumbImage = [UIImage imageNamed: strThumbImage];
    [message setThumbImage: thumbImage];

    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.scene = shareScene;
    req.message = message;
    
    [WXApi sendReq:req];
    [QSHelper setCurrentPlugin:Plugin_WeChat];
}

/**
 *  beief 只适合分享webrul
 *
 *  @param strTitle       标题
 *  @param strDescruption 描述
 *  @param strThumnImage  缩略图
 *  @param strURL         url
 */
-(void) startShare: (NSString *)strTitle
 DescriptionString: (NSString *)strDescruption
        ThumbImage: (NSString *)strThumnImage
         URLString: (NSString *)strURL
         shareScene: (int)iShareScene
{
    WXMediaMessage* message = [WXMediaMessage message];
    message.title = strTitle;
    message.description = strDescruption;
    
    [message setThumbImage:[UIImage imageNamed:strThumnImage]];
    
    WXWebpageObject *webpageObject = [WXWebpageObject object];
    webpageObject.webpageUrl = strURL;
    message.mediaObject = webpageObject;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = false;
    req.message = message;
    req.scene = iShareScene;
    
    [WXApi sendReq:req];
    
    [QSHelper setCurrentPlugin:Plugin_WeChat];
}

- (void)managerDidRecvAuthResponse:(SendAuthResp *)response
{
    NSString* errCode = [[NSString alloc] initWithFormat:@"%d", response.errCode];
    NSString* code = response.code;
    
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:errCode, @"errCode", code, @"code", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [QSHelper callBackCocos2dFunction:mLoginResultCallBack JsongString:jsonString];
}

- (void) managerDidRecvMessageResponse: (NSString *)resultCode
{
    //构造jsonstring
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:resultCode, @"resultCode", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [QSHelper callBackCocos2dFunction:mShareResultCallBack JsongString:jsonString];
}

- (void)managerDidRecvPayResponse:(PayResp *)resp
{
    switch (resp.errCode) {
        case WXSuccess:
            NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
            break;
        default:
            NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode, resp.errStr);
            break;
    }
    
    NSString *resultCode = [NSString stringWithFormat:@"%d", resp.errCode];
    

    NSDictionary *signValueDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   resultCode, @"resultCode",
                                   resp.returnKey, @"returnKey",
                                   resp.errStr, @"errStr",
                                   [NSString stringWithFormat:@"%d", resp.type], @"type",
                                   nil];
    
    NSString* jsonValue = [QSHelper dictionary2JsonString: signValueDict];
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:resultCode, @"resultCode", jsonValue, @"signvalue", nil];
    
    [QSHelper callBackCocos2dFunction:mLuaPayResultFunctionID Dic:dict];
}

// 开始支付
- (void)startPay: (NSDictionary*)dictTrandInfo
{
    PayReq* req             = [[[PayReq alloc] init]autorelease];
    req.partnerId           = [dictTrandInfo objectForKey:@"partnerid"];
    req.prepayId            = [dictTrandInfo objectForKey:@"prepayid"];
    req.nonceStr            = [dictTrandInfo objectForKey:@"noncestr"];
    NSMutableString *stamp  = [dictTrandInfo objectForKey:@"timestamp"];
    req.timeStamp           = stamp.intValue;
    req.package             = [dictTrandInfo objectForKey:@"package"];
    req.sign                = [dictTrandInfo objectForKey:@"sign"];
    [WXApi sendReq:req];
    [QSHelper setCurrentPlugin:Plugin_WeChat];
    
    NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@", WX_APP_ID, req.partnerId, req.prepayId, req.nonceStr,(long)req.timeStamp,req.package,req.sign );
}

- (NSString *) getWXAppID
{
    return WX_APP_ID;
}

- (void)setPayResultFunctionID: (int)cbid
{
    mLuaPayResultFunctionID = cbid;
}

- (void) setLoginResultCallBack:(int) callBackID
{
    mLoginResultCallBack = callBackID;
}

- (void)setShareResultCallBack:(int) callBackID
{
       mShareResultCallBack = callBackID;
}

@end

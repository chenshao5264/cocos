#import "CallOC.h"
//#import <AudioToolbox/AudioToolbox.h>
#import "platform/ios/CCLuaObjcBridge.h"

//#import "Iappay/IappayHelper.h"

#import "QQ/QQHelper.h"

#import "WXHelper.h"

#import "UserAvatarController.h"

#import "InAppPurchaseManager.h"

#import "Alipay/AlipayHelper.h"


#import "QSHelper.h"

@implementation CallOC


+(NSDictionary*) getAppInfo
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
   
    NSString *app_version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    
    NSDictionary* ret = [NSDictionary dictionaryWithObjectsAndKeys:app_version, @"app_version", app_build, @"app_build", nil];
    return ret;
}

+(void) Iappay:(NSDictionary *) dict
{
//    int handlerID = (int) [[dict objectForKey:@"payCallBack"] integerValue]; //支付回调函数
//    NSString* trandInfo = [dict valueForKey:@"strTrandInfo"]; //订单信息
//    
//    if (handlerID && trandInfo)
//    {
//        [[IappayHelper getInstance] setPayResultFunctionID:handlerID];
//        [[IappayHelper getInstance] startPay: trandInfo];
//    }
}

+(void) Ali_startPay:(NSDictionary *) dict
{
    int handlerID = (int) [[dict objectForKey:@"payCallBack"] integerValue]; //支付回调函数
    NSString* trandInfo = [dict valueForKey:@"strTrandInfo"]; //订单信息
    
    if (handlerID && trandInfo)
    {
        [[AlipayHelper getInstance] setPayResultFunctionID:handlerID];
        [[AlipayHelper getInstance] startPay: trandInfo];
    }
}

+(void) jumpToAppStore:(NSDictionary *) dict
{
    if ([dict valueForKey:@"appid"])
    {
        NSString* appid = [dict valueForKey:@"appid"];
        NSString* urlStr = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=";
        NSString* urlStr1 = [urlStr stringByAppendingString:appid];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr1]];
    }
}

+(void) QQLogin:(NSDictionary *) dict
{
    int loginResultCallBackID = (int) [[dict objectForKey:@"loginResultCallBack"] integerValue];
    //int useriInfoCallBackID = (int) [[dict objectForKey:@"userInfoCallBack"] integerValue];
    
    if (loginResultCallBackID)
    {
        [[QQHelper getInstance] setLoginResultCallBack:loginResultCallBackID];
        //[[QQHelper getInstance] setUserInfoCallBack:useriInfoCallBackID];
        [[QQHelper getInstance] startLogin];
    }
}

+(NSDictionary* ) WXIsInstalled
{
    NSString* boolString;
    
    if ([[WXHelper getInstance] isWXAppInstalled]) {
        boolString = @"true";
    } else {
        boolString = @"false";
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:boolString, @"isInstalled", nil];
}

+(void) WXSharePhoto:(NSDictionary *) dict
{
    NSString* strImagePath       = [dict valueForKey:@"strImagePath"];
    NSString* strDescription     = [dict valueForKey:@"strDescription"];
    NSString* strImageTagName    = [dict valueForKey:@"strImageTagName"];
    NSString* strImageTitle      = [dict valueForKey:@"strImageTitle"];
    NSString* strMessageExt      = [dict valueForKey:@"strMessageExt"];
    NSString* strAction          = [dict valueForKey:@"strAction"];
    NSString* strThumbImage      = [dict valueForKey:@"strThumbImage"];
    int shareScene               = (int)[[dict valueForKey:@"strDescription"] integerValue];
    int shareResultCallBack      = (int)[[dict valueForKey:@"shareResultCallBack"] integerValue];
    
    
    [[WXHelper getInstance] setShareResultCallBack: shareResultCallBack];
    [[WXHelper getInstance] startSharePhoto:strImagePath Description:strDescription TagName:strImageTagName Title:strImageTitle MessageExt:strMessageExt Action:strAction ThumbImage:strThumbImage ShareScene:shareScene];
}

+(void) WXShare:(NSDictionary *) dict
{
    NSString* strTitle       = [dict valueForKey:@"title"];
    NSString* strDescription = [dict valueForKey:@"description"];
    NSString* strThumnImage  = [dict valueForKey:@"imagePathName"];
    NSString* strURL         = [dict valueForKey:@"url"];
    int iShareScene          = (int)[[dict valueForKey:@"shareType"] integerValue];
    
    int shareResultCallBack  = (int)[[dict valueForKey:@"shareResultCallBack"] integerValue];
    
    if (strTitle && strDescription && strThumnImage && strURL && shareResultCallBack)
    {
        [[WXHelper getInstance] setShareResultCallBack: shareResultCallBack];
        [[WXHelper getInstance] startShare:strTitle DescriptionString:strDescription ThumbImage:strThumnImage URLString:strURL shareScene:iShareScene];
    }
}

+(void) WXLogin:(NSDictionary *) dict
{
    int loginResultCallBackID = (int) [[dict objectForKey:@"loginResultCallBack"] integerValue];

    
    if(loginResultCallBackID)
    {
        [[WXHelper getInstance] setLoginResultCallBack:loginResultCallBackID];
        [[WXHelper getInstance] startLogin];

    }
}

+(void) WX_startPay:(NSDictionary *) dict
{
    int handlerID = (int) [[dict objectForKey:@"payCallBack"] integerValue]; //支付回调函数
    NSString* trandInfo = [dict valueForKey:@"strTrandInfo"]; //订单信息
    
    NSDictionary *dictInfo = [QSHelper jsonStrin2Dictionary: trandInfo];
    
    if (handlerID && dictInfo)
    {
        [[WXHelper getInstance] setPayResultFunctionID:handlerID];
        [[WXHelper getInstance] startPay: dictInfo];
    }
}

+(void) AvatarDiy:(NSDictionary *) dict
{
    NSString* strDescription = [dict valueForKey:@"fileName"];
    int callBackId = (int)[[dict valueForKey:@"callBack"] integerValue];
    SettingAvaterFormiOS(callBackId, [strDescription UTF8String]);
}

+(void) callPhone:(NSDictionary *)dict
{
    if ([dict valueForKey:@"number"])
    {
        for (id obj in [[[UIApplication sharedApplication] keyWindow] subviews])
        {
            NSString* strPhone = [dict valueForKey:@"number"];
            NSString* tel = @"tel:";
            
            strPhone = [tel stringByAppendingString:strPhone];
            
            UIWebView* webVIew = [[UIWebView alloc] init];
            NSURL* telURL = [NSURL URLWithString:strPhone];
            [webVIew loadRequest:[NSURLRequest requestWithURL:telURL]];
            [obj addSubview:webVIew];
        }
    }
}

// apple pay
+(void) IOS_LoadStore:(NSDictionary *) dict
{
    NSString* strProductID = [dict valueForKey:@"strProductID"];
    
    _loadStore(strProductID);
}
+(void) IOS_BuyProduct:(NSDictionary *) dict
{
    NSString* strProductID = [dict valueForKey:@"strProductID"];
    
    int payResultCallBack = (int)[[dict valueForKey:@"payResultCallBack"] integerValue];
    
    [[InAppPurchaseManager instance] setPlayResultCallBack:payResultCallBack];
    
    _buyProduct(strProductID);
    
}
//+(void) IOS_RestorePurchases:(NSDictionary *) dict
//{
//}
//+(void) IOS_VerifyLastPurchase:(NSDictionary *) dict
//{
//}
//+(void) IOS_CreateProductView:(NSDictionary *) dict
//{
//}
//+(void) IOS_ShowProductView:(NSDictionary *) dict
//{
//}
//+(void) IOS_ISN_RequestInAppSettingState:(NSDictionary *) dict
//{
//}
//

@end

#import <Foundation/Foundation.h>
@interface CallOC : NSObject

+(NSDictionary*) getAppInfo;

+(void) jumpToAppStore:(NSDictionary *) dict;
+(void) callPhone:(NSDictionary *)dict;

//Iappay
+(void) Iappay:(NSDictionary *) dict;
//end

//QQ
+(void) QQLogin:(NSDictionary *) dict;
//end

//WeChat
+(NSDictionary* ) WXIsInstalled;
+(void) WXSharePhoto:(NSDictionary *) dict;
+(void) WXShare:(NSDictionary *) dict;
+(void) WXLogin:(NSDictionary *) dict;
+(void) WX_startPay:(NSDictionary *) dict;
//end

//
+(void) AvatarDiy:(NSDictionary *) dict;

//


// apple pay
+(void) IOS_LoadStore:(NSDictionary *) dict;
+(void) IOS_BuyProduct:(NSDictionary *) dict;
//+(void) IOS_RestorePurchases:(NSDictionary *) dict;
//+(void) IOS_VerifyLastPurchase:(NSDictionary *) dict;
//+(void) IOS_CreateProductView:(NSDictionary *) dict;
//+(void) IOS_ShowProductView:(NSDictionary *) dict;
//+(void) IOS_ISN_RequestInAppSettingState:(NSDictionary *) dict;
//

// alipay
+(void) Ali_startPay:(NSDictionary *) dict;
// end

@end
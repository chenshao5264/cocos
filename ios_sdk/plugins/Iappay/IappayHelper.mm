//
//  IappayHelper.m
//  zebra
//
//  Created by 辰少 on 16/8/10.
//
//

#import "IappayHelper.h"

#import "QSHelper.h"

@interface IappayHelper() <IapppayKitPayRetDelegate> {
    NSString *mAppId;
    NSString *mChannel;
    int mLuaPayResultFunctionID; //支付结果 lua回调id
}

@property (nonatomic, strong) NSString *mCheckResultKey;    //验签密钥

@end

@implementation IappayHelper

- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

//单列
+ (IappayHelper *)getInstance
{
    static IappayHelper *pIappayHelper = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        pIappayHelper = [[self alloc] init];
        [pIappayHelper initPay];
    });
    return pIappayHelper;
}

- (void)initPay
{
    mLuaPayResultFunctionID = 0;
    
    //初始化SDK信息
    mAppId = mOrderUtilsAppId;
    
    mChannel = mOrderUtilsChannel;
    
    self.mCheckResultKey = mOrderUtilsCheckResultKey;
    
    [[IapppayKit sharedInstance] setAppId:mAppId mACID:mChannel];
    
    //初始化屏幕方向
    UIInterfaceOrientationMask directionMask = UIInterfaceOrientationMaskPortrait;
    [[IapppayKit sharedInstance] setIapppayPayWindowOrientationMask:directionMask];
}

- (void)setPayResultFunctionID:(int)functionID
{
    mLuaPayResultFunctionID = functionID;
}

- (void)startPay: (NSString* )trandInfo
{
    [[IapppayKit sharedInstance] makePayForTrandInfo:trandInfo
                                    openIDTokenValue:nil
                                   payResultDelegate:self];
}

/**
 * 此处方法是支付结果处理
 **/
#pragma mark - IapppayKitPayRetDelegate
- (void)iapppayKitRetPayStatusCode:(IapppayKitPayRetCodeType)statusCode
                        resultInfo:(NSDictionary *)resultInfo
{
    NSString *resultCode = [NSString stringWithFormat:@"%d", (int)statusCode];
    NSString *signvalue = resultInfo[@"Signature"];
    
    NSString *errMsg = resultInfo[@"ErrorMsg"];
    NSString* retCode = resultInfo[@"RetCode"];
    //构造jsonstring
    NSDictionary* dic;
    
    if ((int)statusCode == 0) {
        dic = [NSDictionary dictionaryWithObjectsAndKeys:
               resultCode, @"resultCode",
               signvalue, @"signvalue",
               nil];
    } else {
        dic = [NSDictionary dictionaryWithObjectsAndKeys:
               resultCode, @"resultCode",
               errMsg, @"errMsg",
               retCode, @"retCode",
               nil];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [QSHelper callBackCocos2dFunction:mLuaPayResultFunctionID JsongString:jsonString];
}

@end

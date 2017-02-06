//
//  AlipayHelper.cpp
//  zebra
//
//  Created by 辰少 on 16/11/14.
//
//

#import "AlipayHelper.h"
#import <AlipaySDK/AlipaySDK.h>

#import "QSHelper.h"

@interface AlipayHelper() {
    int mLuaPayResultFunctionID; //支付结果 lua回调id
}
@end


@implementation AlipayHelper

+ (instancetype)getInstance {
    static dispatch_once_t onceToken;
    static AlipayHelper *instance;
    dispatch_once(&onceToken, ^{
        instance = [[AlipayHelper alloc] init];
    });
    return instance;
}

- (void)startPay: (NSString*)trandInfo
{
    NSLog(@"trandInfo = %@", trandInfo);
    if (trandInfo) {
        [[AlipaySDK defaultService] payOrder:trandInfo fromScheme:ALIPAY_APP_SCHEME callback:^(NSDictionary *resultDic) {
            [self onPayResult:resultDic];
        }];
    } else {
        NSLog(@"订单字符串为空!");
    }
}

- (void) onPayResult:(NSDictionary *) resultDict
{
    if (!resultDict) {
        NSLog(@"支付结果错误!");
        return;
    }
    
    NSLog(@"支付完成");
    NSLog(@"reslut = %@", resultDict);
    int retCode = [resultDict[@"resultStatus"] intValue];
    
    //< start 配合 lua
    if (retCode == 9000) {
        retCode = 0;
    }
    
    NSString* resultCode = [NSString stringWithFormat:@"%d", retCode];
    NSDictionary *myNewDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               resultCode, @"resultCode",
                               resultDict, @"signvalue", nil];

    //< end
    
    if (mLuaPayResultFunctionID) {
        [QSHelper callBackCocos2dFunction:mLuaPayResultFunctionID Dic:myNewDict];
    }
}

- (void)setPayResultFunctionID: (int)cbid
{
    mLuaPayResultFunctionID = cbid;
}



@end

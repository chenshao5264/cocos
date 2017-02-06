//
//  AlipayHelper.hpp
//  zebra
//
//  Created by 辰少 on 16/11/14.
//
//



#import <Foundation/Foundation.h>

@interface AlipayHelper : NSObject
+ (instancetype)getInstance;

- (void)startPay: (NSString*)trandInfo;
- (void)setPayResultFunctionID: (int)cbid;

// 支付结果回调
- (void) onPayResult:(NSDictionary *) resultDict;
@end

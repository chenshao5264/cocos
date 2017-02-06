//
//  QQHelper.h
//  zebra
//
//  Created by 辰少 on 16/8/23.
//
//

#import <Foundation/Foundation.h>


@interface QQHelper : NSObject
+ (QQHelper *)getInstance;
- (void)startLogin;
- (void)setLoginResultCallBack:(int) callBackID;
- (void)setUserInfoCallBack:(int) callBackID;
@end
//
//  WXHelper.h
//  zebra
//
//  Created by 辰少 on 16/8/23.
//
//

#import <Foundation/Foundation.h>




@interface WXHelper : NSObject
+ (instancetype)getInstance;
- (BOOL) isWXAppInstalled;
- (void) startShare: (NSString *)strTitle
  DescriptionString: (NSString *)strDescription
         ThumbImage: (NSString *)strThumnImage
          URLString: (NSString *)strURL
         shareScene: (int) iShareScene;

- (void) startSharePhoto: (NSString *) strImagePath
             Description: (NSString *) strDescription
                 TagName: (NSString *) strImageTagName
                   Title: (NSString *) strImageTitle
              MessageExt: (NSString *) strMessageExt
                  Action: (NSString *) strAction
              ThumbImage: (NSString *) strThumbImage
              ShareScene: (int) shareScene;

- (void) setShareResultCallBack:(int) callBackID;

- (void) setLoginResultCallBack:(int) callBackID;
- (void) startLogin;

// pay
- (void) startPay: (NSDictionary*)dictTrandInfo;
- (void) setPayResultFunctionID: (int)cbid;

//
- (NSString *) getWXAppID;

@end

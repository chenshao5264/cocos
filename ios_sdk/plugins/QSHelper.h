//
//  QSHelper.h
//  zebra
//
//  Created by 辰少 on 16/8/23.
//
//

#import <Foundation/Foundation.h>

// QQ
#define QQ_APP_ID            @"101376829"

// WX
#define WX_AUTH_OPENID       @"ok3WXv_cOHae850PAPerzYAvEVEg"
#define WX_AUTH_SCOPE        @"snsapi_userinfo"
#define WX_AUTH_STATE        @"xxx"
#define WX_APP_ID            @"wx63c4aa0d04d4b6f4"

//Ali
#define ALIPAY_APP_SCHEME    @"alipay_uno"

enum  CurrentPlugin {
    Plugin_Null = -1,
    Plugin_QQ = 0,
    Plugin_WeChat = 1,
    Plugin_Iappay = 2,
    Plugin_Alipay = 3,
    
    Plugin_AvatarDiy = 10
};

@interface QSHelper : NSObject
+ (void) setCurrentPlugin:(enum CurrentPlugin) curPlugin;
+ (enum CurrentPlugin) getCurrentPlugin;

//
+ (void) setRootViewController: (UIViewController*) vc;
+ (UIViewController*) getRootViewController;
//

/**
 *  brief 回调coco2dx 的回调函数
 *
 *  @param functionID 方法ID
 *  @param jsonString 携带的jsong字符串数据
 */
+ (void) callBackCocos2dFunction: (int) functionID
         JsongString: (NSString *)jsonString;

+ (void) callBackCocos2dFunction: (int) functionID
                     Dic: (NSDictionary *)dic;

+ (void) notifiEvent2Lua: (const char*) evtName;

+ (NSDictionary *) jsonStrin2Dictionary: (NSString*) jsonString;
+ (NSString *) dictionary2JsonString: (NSDictionary*) dict;

@end

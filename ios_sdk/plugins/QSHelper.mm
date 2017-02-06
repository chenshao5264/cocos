//
//  QSHelper.m
//  zebra
//
//  Created by 辰少 on 16/8/23.
//
//

#import "QSHelper.h"
#import "CCLuaEngine.h"
#import "CCLuaBridge.h"

#import "cocos2d.h"

@implementation QSHelper

static enum CurrentPlugin s_currentPlugin = Plugin_Null;

static UIViewController* s_rootViewController;

+ (void) setCurrentPlugin:(enum CurrentPlugin) curPlugin
{
    s_currentPlugin = curPlugin;
}

+ (enum CurrentPlugin) getCurrentPlugin
{
    return s_currentPlugin;
}

+ (void) callBackCocos2dFunction: (int) functionID
                     JsongString: (NSString *)jsonString
{
    if (functionID)
    {
        cocos2d::LuaBridge::pushLuaFunctionById(functionID);
        cocos2d::LuaStack* L = cocos2d::LuaBridge::getStack();
        L->pushString([jsonString UTF8String]);
        L->executeFunction(1); //括号里面的1 是告诉lua传递的形参是1个
        cocos2d::LuaBridge::releaseLuaFunctionById(functionID); //释放
    }
}

+ (void) callBackCocos2dFunction: (int) functionID
                             Dic: (NSDictionary *)dic
{
    if (functionID)
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        
   
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

        cocos2d::LuaBridge::pushLuaFunctionById(functionID);
        cocos2d::LuaStack* L = cocos2d::LuaBridge::getStack();
        L->pushString([jsonString UTF8String]);
        L->executeFunction(1); //括号里面的1 是告诉lua传递的形参是1个
        cocos2d::LuaBridge::releaseLuaFunctionById(functionID); //释放
    }
}

+ (void) notifiEvent2Lua: (const char*) evtName
{
    auto event = cocos2d::EventCustom(evtName);
    
    cocos2d::Director::getInstance()->getEventDispatcher()->dispatchEvent(&event);
}

+ (void) setRootViewController: (UIViewController*) vc
{
    s_rootViewController = vc;
}

+ (UIViewController*) getRootViewController
{
    return s_rootViewController;
}

+ (NSDictionary *) jsonStrin2Dictionary: (NSString*) jsonString
{
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData: jsonData
                                                             options: NSJSONReadingMutableContainers
                                                               error: &err];
    if(!err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    
    return dict;
}

+ (NSString *) dictionary2JsonString: (NSDictionary*) jsonString
{
    return @"";
}

@end

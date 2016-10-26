//
//  WeShare.m
//  HelloWorld_c2d
//
//  Created by 辰少 on 16/4/21.
//
//


#include "WeShare-ios.h"
#include "WXApi.h"


WeShareIOS::WeShareIOS()
{
    
}

WeShareIOS::~WeShareIOS()
{
    
}

bool WeShareIOS::isWXAppInstalled()
{
    return [WXApi isWXAppInstalled];
}

void WeShareIOS::jumpToWXDownloadPage()
{
    NSString* url = [WXApi getWXAppInstallUrl];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

void WeShareIOS::registerApp(const std::string& strAppID)
{
    [WXApi registerApp:[NSString stringWithUTF8String:strAppID.c_str()]];
}

void WeShareIOS::shareText(const std::string& strText)
{
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.text = [NSString stringWithUTF8String:strText.c_str()];
    req.bText = true;
    req.scene = WXSceneSession;
    [WXApi sendReq:req];
}

void WeShareIOS::shareWeb(const std::string& strTitle, const std::string& strDescription, const std::string& strThumbImage,
                          const std::string& strURL)
{
    WXMediaMessage* message = [WXMediaMessage message];
    message.title = [NSString stringWithUTF8String:strTitle.c_str()];
    message.description = [NSString stringWithUTF8String:strDescription.c_str()];
    
    [message setThumbImage:[UIImage imageNamed:[NSString stringWithUTF8String:strThumbImage.c_str()]]];
    
    WXWebpageObject *webpageObject = [WXWebpageObject object];
    webpageObject.webpageUrl = [NSString stringWithUTF8String:strURL.c_str()];
    message.mediaObject = webpageObject;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = false;
    req.message = message;
    req.scene = WXSceneSession;
    
    [WXApi sendReq:req];
}

void WeShareIOS::sharePhoto()
{
    WXMediaMessage* msg = [WXMediaMessage message];
    [msg setThumbImage:[UIImage imageNamed:@"chat.png"]];
    
    WXImageObject* imageObject = [WXImageObject object];
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"circle" ofType:@"png"];
    imageObject.imageData = [NSData dataWithContentsOfFile:filePath];
    msg.mediaObject = imageObject;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = false;
    req.message = msg;
    req.scene = WXSceneTimeline;
    [WXApi sendReq:req];
    
}

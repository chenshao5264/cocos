//
//  WeShareInterface.h
//  HelloWorld_c2d
//
//  Created by 辰少 on 16/4/21.
//
//

#ifndef WeShareInterface_h
#define WeShareInterface_h

#include <string>

class WeShareInterface
{
public:
    virtual bool isWXAppInstalled() = 0;
    virtual void jumpToWXDownloadPage() = 0;
    virtual void registerApp(const std::string& strAppID) = 0;
    virtual void shareText(const std::string& strText) = 0;
    virtual void sharePhoto() = 0;
    virtual void shareWeb(const std::string& strTitle, const std::string& strDescription, const std::string& strThumbImage,
                          const std::string& strURL) = 0;
};

#endif /* WeShareInterface_h */

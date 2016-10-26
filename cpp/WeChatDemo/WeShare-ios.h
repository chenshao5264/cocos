//
//  WeShare.h
//  HelloWorld_c2d
//
//  Created by 辰少 on 16/4/21.
//
//

#ifndef WeShare_IOS_h
#define WeShare_IOS_h


#include "WeShareInterface.h"


class WeShareIOS : public WeShareInterface
{
public:
    WeShareIOS();
    ~WeShareIOS();
    
    virtual bool isWXAppInstalled();
    virtual void jumpToWXDownloadPage();
    virtual void registerApp(const std::string& strAppID);
    virtual void shareText(const std::string& strText);
    virtual void sharePhoto();
    virtual void shareWeb(const std::string& strTitle, const std::string& strDescription, const std::string& strThumbImage,
                          const std::string& strURL);
};



#endif /* WeShare_h */

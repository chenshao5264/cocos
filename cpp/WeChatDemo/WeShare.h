//
//  WeShare.hpp
//  HelloWorld_c2d
//
//  Created by 辰少 on 16/4/21.
//
//

#ifndef WeShare_h
#define WeShare_h

class WeShareInterface;

class WeShare
{
private:
    WeShare();
    
public:
    ~WeShare();
    static WeShare* getInstance();
    
    bool isWXAppInstalled();
    void jumpToWXDownloadPage();
    void registerApp();
    void shareText(const std::string& strText);
    void sharePhoto();
    void shareWeb(const std::string& strTitle, const std::string& strDescription, const std::string& strThumbImage,
                  const std::string& strURL);
    
private:
    static WeShare* s_pWeShare;
    
     WeShareInterface* m_pWeShareInterface;
    
    
};

#endif /* WeShare_h */

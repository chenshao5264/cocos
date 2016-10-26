//
//  WeShare.cpp
//  HelloWorld_c2d
//
//  Created by 辰少 on 16/4/21.
//
//
#include <string>
#include "WeShare.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "WeShare-ios.h"
#endif


const std::string strAppID = "wx020cfdda50c09e2e";

WeShare* WeShare::s_pWeShare = nullptr;

WeShare::WeShare()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    m_pWeShareInterface = new WeShareIOS();
#endif
}

WeShare::~WeShare()
{
    
}

WeShare* WeShare::getInstance()
{
    if (s_pWeShare == nullptr)
    {
        s_pWeShare = new WeShare();
    }
    
    return s_pWeShare;
}

bool WeShare::isWXAppInstalled()
{
    if (m_pWeShareInterface != nullptr)
    {
        return m_pWeShareInterface->isWXAppInstalled();
    }
    
    return false;
}

void WeShare::jumpToWXDownloadPage()
{
    if (m_pWeShareInterface != nullptr)
    {
        m_pWeShareInterface->jumpToWXDownloadPage();
    }
}

void WeShare::registerApp()
{
    if (m_pWeShareInterface != nullptr)
    {
        m_pWeShareInterface->registerApp(strAppID);
    }
}

void WeShare::sharePhoto()
{
    if (m_pWeShareInterface != nullptr)
    {
        m_pWeShareInterface->sharePhoto();
    }
}

void WeShare::shareWeb(const std::string& strTitle, const std::string& strDescription, const std::string& strThumbImage,
                       const std::string& strURL)
{
    if (m_pWeShareInterface != nullptr)
    {
        m_pWeShareInterface->shareWeb(strTitle, strDescription, strThumbImage, strURL);
    }
}

void WeShare::shareText(const std::string& strText)
{
    if (m_pWeShareInterface != nullptr)
    {
        m_pWeShareInterface->shareText(strText);
    }
}
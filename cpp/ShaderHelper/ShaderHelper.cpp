//
//  ShaderHelper.cpp
//  HelloWorld_3_12
//
//  Created by 辰少 on 16/10/18.
//
//

#include "ShaderHelper.h"
using namespace cocos2d;
using namespace uu;

#define BLUR_FSH "res/Shaders/example_Blur.fsh"

void CShaderHelper::setEffect(Sprite* target, CEffect* effect)
{
    if (target && effect)
    {
        CEffect* defaultEffect = static_cast<CEffect*>(target->getUserData());
        if (defaultEffect != effect)
        {
            effect->setTarget(target);
            
            CC_SAFE_RELEASE(defaultEffect);
            defaultEffect = effect;
            target->setUserData(static_cast<void*>(defaultEffect));
            CC_SAFE_RETAIN(defaultEffect);
            
            target->setGLProgramState(effect->getGLProgramState());
        }
       
    }
}

void CShaderHelper::clearEffect(Sprite* target)
{
    CEffect* defaultEffect = static_cast<CEffect*>(target->getUserData());
    if (defaultEffect)
    {
        CC_SAFE_RELEASE_NULL(defaultEffect);
        target->setUserData(static_cast<void*>(defaultEffect));
        target->setGLProgram(GLProgramCache::getInstance()->getGLProgram(GLProgram::SHADER_NAME_POSITION_TEXTURE_COLOR_NO_MVP));
    }
}   

//
// CEffect
//
bool CEffect::initGLProgramState(const std::string &fragmentFilename)
{
    auto fileUtiles = FileUtils::getInstance();
    auto fragmentFullPath = fileUtiles->fullPathForFilename(fragmentFilename);
    auto fragSource = fileUtiles->getStringFromFile(fragmentFullPath);
    auto glprogram = GLProgram::createWithByteArrays(ccPositionTextureColor_noMVP_vert, fragSource.c_str());
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_WP8 || CC_TARGET_PLATFORM == CC_PLATFORM_WINRT)
    _fragSource = fragSource;
#endif
    
    _glprogramstate = GLProgramState::getOrCreateWithGLProgram(glprogram);
    _glprogramstate->retain();
    
    return _glprogramstate != nullptr;
}

CEffect::CEffect()
: _glprogramstate(nullptr)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_WP8 || CC_TARGET_PLATFORM == CC_PLATFORM_WINRT)
    _backgroundListener = EventListenerCustom::create(EVENT_RENDERER_RECREATED,
                                                      [this](EventCustom*)
                                                      {
                                                          auto glProgram = _glprogramstate->getGLProgram();
                                                          glProgram->reset();
                                                          glProgram->initWithByteArrays(ccPositionTextureColor_noMVP_vert, _fragSource.c_str());
                                                          glProgram->link();
                                                          glProgram->updateUniforms();
                                                      }
                                                      );
    Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(_backgroundListener, -1);
#endif
}

CEffect::~CEffect()
{
    CC_SAFE_RELEASE_NULL(_glprogramstate);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_WP8 || CC_TARGET_PLATFORM == CC_PLATFORM_WINRT)
    Director::getInstance()->getEventDispatcher()->removeEventListener(_backgroundListener);
#endif
}

// CustomEffect
CCustomEffect* CCustomEffect::create(const std::string& fragmentFilename)
{
    auto pRet = new(std::nothrow) CCustomEffect();
    if (pRet && pRet->init(fragmentFilename))
    {
        pRet->autorelease();
        return pRet;
    }
    else
    {
        delete pRet;
        pRet = nullptr;
        return nullptr;
    }
}

bool CCustomEffect::init(const std::string& fragmentFilename)
{
    initGLProgramState(fragmentFilename);
    
    return true;
}

// Blur
void CBlurEffect::setTarget(Sprite *sprite)
{
    Size size = sprite->getTexture()->getContentSizeInPixels();
    _glprogramstate->setUniformVec2("resolution", size);
    _glprogramstate->setUniformFloat("blurRadius", _blurRadius);
    _glprogramstate->setUniformFloat("sampleNum", _blurSampleNum);
}

bool CBlurEffect::init(float blurRadius, float sampleNum)
{
    initGLProgramState(BLUR_FSH);
    _blurRadius = blurRadius;
    _blurSampleNum = sampleNum;
    
    return true;
}

void CBlurEffect::setBlurRadius(float radius, bool isRefresh)
{
    _blurRadius = radius;
    if (isRefresh)
    {
        _glprogramstate->setUniformFloat("blurRadius", _blurRadius);
    }
}

void CBlurEffect::setBlurSampleNum(float num, bool isRefresh)
{
    _blurSampleNum = num;
    if (isRefresh)
    {
        _glprogramstate->setUniformFloat("sampleNum", _blurSampleNum);
    }
}

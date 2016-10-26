//
//  ShaderHelper.h
//  HelloWorld_3_12
//
//  Created by 辰少 on 16/10/18.
//
//

#ifndef ShaderHelper_h
#define ShaderHelper_h

#include "cocos2d.h"

namespace uu {
//
// CShaderHelper
// 原有精灵shader
class CEffect;
class CShaderHelper
{
public:    
    static void setEffect(cocos2d::Sprite* target, CEffect* effect);
    static void clearEffect(cocos2d::Sprite* target);
};

//
// EffectSprite
// 创建ShaderSprite
class EffectSprite : public cocos2d::Sprite
{
    
};


//
// CEffect
//
class CEffect : public cocos2d::Ref
{
public:
    cocos2d::GLProgramState* getGLProgramState() const { return _glprogramstate; }
    virtual void setTarget(cocos2d::Sprite *sprite){}

protected:
    bool initGLProgramState(const std::string &fragmentFilename);
    CEffect();
    virtual ~CEffect();
    cocos2d::GLProgramState *_glprogramstate;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_WP8 || CC_TARGET_PLATFORM == CC_PLATFORM_WINRT)
    std::string _fragSource;
    EventListenerCustom* _backgroundListener;
#endif
};
    
// CustomEffect
class CCustomEffect : public CEffect
{
public:
    static CCustomEffect* create(const std::string& fragmentFilename);
    
private:
    bool init(const std::string& fragmentFilename);
};

// CBlurEffect
class CBlurEffect : public CEffect
{
public:
    CREATE_FUNC(CBlurEffect);
    virtual void setTarget(cocos2d::Sprite *sprite) override;
    void setBlurRadius(float radius, bool isRefresh = false);
    void setBlurSampleNum(float num, bool isRefresh = false);
    
protected:
    bool init(float blurRadius = 10.0f, float sampleNum = 5.0f);
    
    float _blurRadius;
    float _blurSampleNum;
};
}
#endif /* ShaderHelper_h */

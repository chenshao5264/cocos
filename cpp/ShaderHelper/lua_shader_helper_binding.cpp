//
//  lua_shader_helper_binding.cpp
//  zebra
//
//  Created by 辰少 on 16/10/19.
//
//

#include "lua_shader_helper_binding.h"
#include <string>

#include  "tolua_fix.h"
#include "LuaBasicConversions.h"

#include "ShaderHelper.h"

using namespace cocos2d;
using namespace uu;


//
// CShaderHelper
//
int lua_uu_shader_ShaderHelper_setEffect(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;
    
    argc = lua_gettop(tolua_S) - 1;
    if (argc == 2)
    {
        Sprite* arg0;
        CEffect* arg1;
        ok &= luaval_to_object<cocos2d::Sprite>(tolua_S, 2, "cc.Sprite", &arg0);
        ok &= luaval_to_object<CEffect>(tolua_S, 3, "uu.Effect", &arg1);
        
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_uu_shader_ShaderHelper_setEffect'", nullptr);
            return 0;
        }
        
        CShaderHelper::setEffect(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    
    return 0;
}

int lua_uu_shader_ShaderHelper_clearEffect(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;
    
    argc = lua_gettop(tolua_S) - 1;
    if (argc == 1)
    {
        Sprite* arg0;
        ok &= luaval_to_object<cocos2d::Sprite>(tolua_S, 2, "cc.Sprite", &arg0);
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_uu_shader_ShaderHelper_setEffect'", nullptr);
            return 0;
        }
        CShaderHelper::clearEffect(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    return 0;
}

int lua_register_shader_helper(lua_State* tolua_S)
{
    tolua_usertype(tolua_S, "uu.ShaderHelper");
    tolua_cclass(tolua_S, "ShaderHelper", "uu.ShaderHelper", "", nullptr);
    
    tolua_beginmodule(tolua_S, "ShaderHelper");
        tolua_function(tolua_S, "setEffect", lua_uu_shader_ShaderHelper_setEffect);
        tolua_function(tolua_S, "clearEffect", lua_uu_shader_ShaderHelper_clearEffect);
    
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(CShaderHelper).name();
    g_luaType[typeName] = "uu.ShaderHelper";
    g_typeCast["ShaderHelper"] = "uu.ShaderHelper";
    
    return 1;
}

//
// CCustomEffect
//
int lua_uu_shader_CustomEffect_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok = true;
    
    argc = lua_gettop(tolua_S) - 1;
    if(argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "uu.CustomEffect:create");
        
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_uu_shader_CustomEffect_create'", nullptr);
            return 0;
        }
        
        CCustomEffect* ret = CCustomEffect::create(arg0);
        object_to_luaval<CCustomEffect>(tolua_S, "uu.CustomEffect", (CCustomEffect*)ret);
        return 1;
    }
    
    return 0;
}


int lua_register_shader_custom_effect(lua_State* tolua_S)
{
    tolua_usertype(tolua_S, "uu.CustomEffect");
    tolua_cclass(tolua_S, "CustomEffect", "uu.CustomEffect", "uu.Effect", nullptr);
    
    tolua_beginmodule(tolua_S, "CustomEffect");
        tolua_function(tolua_S, "create", lua_uu_shader_CustomEffect_create);
    
    
    tolua_endmodule(tolua_S);
    
    std::string typeName = typeid(CShaderHelper).name();
    g_luaType[typeName] = "uu.CustomEffect";
    g_typeCast["CustomEffect"] = "uu.CustomEffect";
    
    return 1;

}

//
// CBlurEffect
//
int lua_uu_shader_BlurEffect_create(lua_State* tolua_S)
{
    int argc = 0;
    
    argc = lua_gettop(tolua_S) - 1;
    
    if (argc == 0)
    {
        CBlurEffect* ret = CBlurEffect::create();
        object_to_luaval<CBlurEffect>(tolua_S, "uu.BlurEffect", (CBlurEffect*)ret);
        return 1;
    }

    return 0;
}

int lua_uu_shader_BlurEffect_setTarget(lua_State* tolua_S)
{
    int argc = 0;
    CBlurEffect* cobj = nullptr;
    bool ok  = true;
    
    cobj = (CBlurEffect*)tolua_tousertype(tolua_S, 1, 0);
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_uu_shader_CBlurEffect_setTarget'", nullptr);
        return 0;
    }
    
    argc = lua_gettop(tolua_S) - 1;
    if(argc == 1)
    {
        cocos2d::Sprite* arg0;
        ok &= luaval_to_object<cocos2d::Sprite>(tolua_S, 2, "cc.Sprite", &arg0);
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_uu_shader_CBlurEffect_setTarget'", nullptr);
            return 0;
        }
        
        cobj->setTarget(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uu.BlurEffect:setTarget",argc, 1);
    return 0;
}

int lua_uu_shader_BlurEffect_setBlurRadius(lua_State* tolua_S)
{
    int argc = 0;
    CBlurEffect* cobj = nullptr;
    bool ok  = true;
    
    cobj = (CBlurEffect*)tolua_tousertype(tolua_S, 1, 0);
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_uu_shader_BlurEffect_setBlurRadius'", nullptr);
        return 0;
    }
    
    argc = lua_gettop(tolua_S) - 1;
    
    if (argc == 1)
    {
        double arg0;
        ok &= luaval_to_number(tolua_S, 2, &arg0, "uu.BlurEffect:setBlurRadius");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_uu_shader_BlurEffect_setBlurRadius'", nullptr);
            return 0;
        }
        
        cobj->setBlurRadius(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    else if (argc == 2)
    {
        double arg0;
        bool arg1;
        ok &= luaval_to_number(tolua_S, 2, &arg0, "uu.BlurEffect:setBlurRadius");
        ok &= luaval_to_boolean(tolua_S, 3, &arg1, "uu.BlurEffect:setBlurRadius");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_uu_shader_BlurEffect_setBlurRadius'", nullptr);
            return 0;
        }
        cobj->setBlurRadius(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uu.BlurEffect:setBlurRadius",argc, 1);
    return 0;
}

int lua_uu_shader_BlurEffect_setBlurSampleNum(lua_State* tolua_S)
{
    int argc = 0;
    CBlurEffect* cobj = nullptr;
    bool ok  = true;
    
    cobj = (CBlurEffect*)tolua_tousertype(tolua_S, 1, 0);
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_uu_shader_BlurEffect_setBlurSampleNum'", nullptr);
        return 0;
    }
    
    argc = lua_gettop(tolua_S) - 1;
    
    if (argc == 1)
    {
        double arg0;
        ok &= luaval_to_number(tolua_S, 2, &arg0, "uu.BlurEffect:setBlurSampleNum");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_uu_shader_BlurEffect_setBlurSampleNum'", nullptr);
            return 0;
        }
        
        cobj->setBlurSampleNum(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    else if (argc == 2)
    {
        double arg0;
        bool arg1;
        ok &= luaval_to_number(tolua_S, 2, &arg0, "uu.BlurEffect:setBlurRadius");
        ok &= luaval_to_boolean(tolua_S, 3, &arg1, "uu.BlurEffect:setBlurRadius");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_uu_shader_BlurEffect_setBlurSampleNum'", nullptr);
            return 0;
        }
        cobj->setBlurSampleNum(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uu.BlurEffect:setBlurSampleNum",argc, 1);
    return 0;
}

int lua_register_shader_blur_effect(lua_State* tolua_S)
{
    tolua_usertype(tolua_S, "uu.BlurEffect");
    tolua_cclass(tolua_S, "BlurEffect", "uu.BlurEffect","uu.Effect", nullptr);
    
    tolua_beginmodule(tolua_S, "BlurEffect");
        tolua_function(tolua_S, "create", lua_uu_shader_BlurEffect_create);
        tolua_function(tolua_S, "setTarget", lua_uu_shader_BlurEffect_setTarget);
        tolua_function(tolua_S, "setBlurRadius", lua_uu_shader_BlurEffect_setBlurRadius);
        tolua_function(tolua_S, "setBlurSampleNum", lua_uu_shader_BlurEffect_setBlurSampleNum);
    
    tolua_endmodule(tolua_S);
    
    std::string typeName = typeid(CBlurEffect).name();
    g_luaType[typeName] = "uu.BlurEffect";
    g_typeCast["BlurEffect"] = "uu.BlurEffect";
    
    return 1;
}

//
// Effect
//
int lua_uu_shader_effect_getGLProgramState(lua_State* tolua_S)
{
    int argc = 0;
    CEffect* cobj = nullptr;
    bool ok  = true;
    
    
    cobj = (CEffect*)tolua_tousertype(tolua_S, 1, 0);
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_uu_shader_effect_getGLProgramState'", nullptr);
        return 0;
    }
    
    argc = lua_gettop(tolua_S) - 1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_uu_shader_effect_getGLProgramState'", nullptr);
            return 0;
        }
        GLProgramState* ret= cobj->getGLProgramState();
        object_to_luaval<cocos2d::GLProgramState>(tolua_S, "cc.GLProgramState", (cocos2d::GLProgramState*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uu.Effect:getGLProgramState",argc, 0);
    return 0;
}

int lua_uu_shader_effect_setTarget(lua_State* tolua_S)
{
    int argc = 0;
    CEffect* cobj = nullptr;
    bool ok  = true;

    cobj = (CEffect*)tolua_tousertype(tolua_S, 1, 0);
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_uu_shader_effect_setTarget'", nullptr);
        return 0;
    }
    
    argc = lua_gettop(tolua_S) - 1;
    if(argc == 1)
    {
        cocos2d::Sprite* arg0;
        ok &= luaval_to_object<cocos2d::Sprite>(tolua_S, 2, "cc.Sprite", &arg0);
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_uu_shader_effect_setTarget'", nullptr);
            return 0;
        }
        
        cobj->setTarget(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uu.Effect:setTarget",argc, 1);
    return 0;
}

int lua_register_shader_effect(lua_State* tolua_S)
{
    tolua_usertype(tolua_S, "uu.Effect");
    tolua_cclass(tolua_S, "Effect", "uu.Effect", "cc.Ref", nullptr);
    
    tolua_beginmodule(tolua_S, "Effect");
        tolua_function(tolua_S, "getGLProgramState", lua_uu_shader_effect_getGLProgramState);
        tolua_function(tolua_S, "setTarget", lua_uu_shader_effect_setTarget);
    
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(CEffect).name();
    g_luaType[typeName] = "uu.Effect";
    g_typeCast["Effect"] = "uu.Effect";
    return 1;
}

//
// Reigster
//
int register_all_shader_helper(lua_State* tolua_S)
{
    tolua_open(tolua_S);
    
    tolua_module(tolua_S, "uu", 0);
    tolua_beginmodule(tolua_S, "uu");
    
    lua_register_shader_effect(tolua_S);
    lua_register_shader_custom_effect(tolua_S);
    lua_register_shader_blur_effect(tolua_S);
    lua_register_shader_helper(tolua_S);
    
    tolua_endmodule(tolua_S);
    return 1;
}

int lua_register_shader_helper_module(lua_State* L)
{
    lua_getglobal(L, "_G");
    if (lua_istable(L, -1))//stack:...,_G,
    {
        register_all_shader_helper(L);
    }
    lua_pop(L, 1);

    return 1;
}

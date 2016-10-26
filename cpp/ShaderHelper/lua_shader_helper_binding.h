//
//  lua_shader_helper_binding.hpp
//  zebra
//
//  Created by 辰少 on 16/10/19.
//
//

#ifndef lua_shader_helper_binding_h
#define lua_shader_helper_binding_h

#ifdef __cplusplus
extern "C" {
#endif
#include "tolua++.h"
#ifdef __cplusplus
}
#endif


TOLUA_API int lua_register_shader_helper_module(lua_State* L);

#endif /* lua_shader_helper_binding_hpp */

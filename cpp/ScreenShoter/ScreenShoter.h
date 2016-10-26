#ifndef _SCREEN_SHOTER_
#define _SCREEN_SHOTER_

#include "cocos2d.h"

namespace cocos2d_ex
{
	class ScreenShoter
	{
	public:
		ScreenShoter();
		~ScreenShoter();


		/** 
			w: width , h: hegith 建议用设计分辨率
			fileName： 图片保存名，默认取截图时间
		*/
		static void shot(int w, int h, const std::string& fileName = "");
	};
}

#endif
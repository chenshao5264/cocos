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
			w: width , h: hegith ��������Ʒֱ���
			fileName�� ͼƬ��������Ĭ��ȡ��ͼʱ��
		*/
		static void shot(int w, int h, const std::string& fileName = "");
	};
}

#endif
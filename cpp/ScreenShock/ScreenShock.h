#ifndef _SCREEN_SHOCK_
#define _SCREEN_SHOCK_

#include "cocos2d.h"

namespace cocos2d_ex
{
	class ScreenShock
	{
	private:
		ScreenShock();
	public:
		static ScreenShock* getInstance();
		static void pruge();
		~ScreenShock();

		/**
			开始震动调用
		*/
		void startShock();
		/**
			每帧调用 
		*/
		void onShakePreen(cocos2d::Node* curNode, float dt);
		
	private:
		void updateShakeScreen(float dt);
		void onShakePreen(cocos2d::Node* curNode, cocos2d::Vec2 offset);

	private:
		static ScreenShock* s_pScreenShock;

		float m_fElapse;
		bool m_bShakeScreen;
		int	m_nCurShakeFrame;
		cocos2d::Vec2 m_ptOffest;
	};
}

#endif
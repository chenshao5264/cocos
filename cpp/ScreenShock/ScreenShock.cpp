#include "ScreenShock.h"

#define	SHAKE_FPS					30
#define SHAKE_FRAMES				20

namespace cocos2d_ex
{
	ScreenShock* ScreenShock::s_pScreenShock = nullptr;

	ScreenShock::ScreenShock()
	{

	}

	ScreenShock::~ScreenShock()
	{

	}

	void ScreenShock::pruge()
	{
		if (s_pScreenShock)
		{
			delete s_pScreenShock;
			s_pScreenShock = nullptr;
		}
	}

	ScreenShock* ScreenShock::getInstance()
	{
		if (s_pScreenShock == nullptr)
		{
			s_pScreenShock = new ScreenShock();
		}
		return s_pScreenShock;
	}

	void ScreenShock::onShakePreen(cocos2d::Node* curNode, float dt)
	{
		assert(curNode != nullptr);
		this->onShakePreen(curNode, m_ptOffest);
		this->updateShakeScreen(dt);
	}

	void ScreenShock::onShakePreen(cocos2d::Node* curNode, cocos2d::Vec2 offset)
	{
		curNode->setPosition(offset);
	}

	void ScreenShock::startShock()
	{
		m_fElapse = -1.f;
		m_nCurShakeFrame = 0;
		m_bShakeScreen = true;
	}

	void ScreenShock::updateShakeScreen(float dt)
	{
		if (!m_bShakeScreen) return;

		if (m_fElapse == -1.0f) m_fElapse = 0.0f;
		else m_fElapse += dt;

		static const float kSpeed = 1.0f / SHAKE_FPS;
		while (m_fElapse >= kSpeed)
		{
			m_fElapse -= kSpeed;
			if (m_nCurShakeFrame + 1 == SHAKE_FRAMES) 
			{
				m_bShakeScreen = false;
				m_ptOffest.x = 0.f;
				m_ptOffest.y = 0.f;
				break;
			}
			else
			{
				++m_nCurShakeFrame;
				m_ptOffest.x = rand() % 2 == 0 ? (10.f + rand()%5) : (-10.f - rand()%5);
				m_ptOffest.y = rand() % 2 == 1 ? (10.f + rand()%5) : (-10.f - rand()%5);

			}
		}
	}
}


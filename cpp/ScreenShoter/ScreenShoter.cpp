#include "ScreenShoter.h"
USING_NS_CC;

namespace cocos2d_ex{
	
	ScreenShoter::ScreenShoter()
	{

	}
	ScreenShoter::~ScreenShoter()
	{

	}

	void ScreenShoter::shot(int w, int h, const std::string& fileName)
	{
		Scene* scene = Director::getInstance()->getRunningScene();

		RenderTexture* renderTexture = RenderTexture::create(w, h,
			Texture2D::PixelFormat::RGBA8888,
			GL_DEPTH24_STENCIL8);
		renderTexture->begin();
		scene->visit();
		renderTexture->end();

		if (fileName.empty())
		{
			time_t nowTime = time(0);
			char timeStr[64];
			sprintf(timeStr, "%ld.png", nowTime);
			renderTexture->saveToFile(timeStr, Image::Format::PNG, true);
		}
		else
		{
			renderTexture->saveToFile(fileName + ".png", Image::Format::PNG, true);
		}
	}
}

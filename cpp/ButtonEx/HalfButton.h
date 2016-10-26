#ifndef _HalfButton_H_
#define _HalfButton_H_

#include "cocos2d.h"
#include "ui/CocosGUI.h"
NS_CC_BEGIN

	namespace ui{

		class HalfButton : public cocos2d::Sprite
		{
		public:
			typedef std::function<void(Ref*, Widget::TouchEventType)> ccWidgetEventCallback;

		public:
			HalfButton();
			virtual ~HalfButton();

			static HalfButton* create(const std::string& normalImage,
				const std::string& selectedImage = ""); 

			/*
				添加按钮事件回调
			*/
			void addTouchEventListener(const ccWidgetEventCallback& touch);

			/*
				添加按钮上的图片文字
			*/
			void addTitleImage(const std::string& normalImage, const std::string& selectedImage = "");

		private:
			bool init(const std::string& normalImage, const std::string& selectedImage);
			void updateButtonTexture(bool bSelected);

			/*
				以下3个函数
				模仿按钮点击事件
			*/
			virtual bool onTouchBegan(cocos2d::Touch *touch, cocos2d::Event *unused_event);
			virtual void onTouchMoved(cocos2d::Touch *touch, cocos2d::Event *unused_event);
			virtual void onTouchEnded(cocos2d::Touch *touch, cocos2d::Event *unused_event);

		private:
			ccWidgetEventCallback m_callBack;
			cocos2d::Sprite* m_btnLeft;
			cocos2d::Sprite* m_btnRight;

			cocos2d::Texture2D* m_btnTextureNormal;
			cocos2d::Texture2D* m_btnTextureSelect;

			cocos2d::Sprite* m_titleImage;

			std::string m_strNormalImage;
			std::string m_strSelectedImage;

			std::string m_strNormalTitleImage;
			std::string m_strSelectedTitleImage;

			cocos2d::Texture2D* m_btnTitleTextureNormal;
			cocos2d::Texture2D* m_btnTitleTextureSelect;
		};

}
NS_CC_END

#endif
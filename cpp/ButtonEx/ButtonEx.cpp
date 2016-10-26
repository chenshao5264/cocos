#include "ButtonEx.h"
USING_NS_CC;
using namespace ui;

const std::string strImgPoint = "hong.png";

ButtonEx::ButtonEx()
	: m_imgPoint(nullptr)
{

}

ButtonEx::~ButtonEx()
{

}

ButtonEx* ButtonEx::create(const std::string& normalImage,
					  const std::string& selectedImage,
					  size_t msgNum,
					  const std::string& disableImage,
					  TextureResType texType)
{
	ButtonEx* btn = new ButtonEx();
	if (btn && btn->init(normalImage, selectedImage, disableImage, texType))
	{
		btn->createPoint(msgNum);
		btn->autorelease();
		return btn;
	}
	CC_SAFE_DELETE(btn);
	return nullptr;
	
}

void ButtonEx::createPoint(size_t msgNum)
{
	m_imgPoint = ImageView::create(strImgPoint);
	if (m_imgPoint != nullptr)
	{
		m_imgPoint->setPosition(Vec2(this->getContentSize().width, this->getContentSize().height));
		this->addChild(m_imgPoint, 1);

		this->setPointVisible(msgNum);
	}
}

void ButtonEx::setPointVisible(size_t msgNum)
{
	if (msgNum > 0)
	{
		if (m_imgPoint != nullptr)
		{
			m_imgPoint->setVisible(true);
		}	
	}
	else
	{
		if (m_imgPoint != nullptr)
		{
			m_imgPoint->setVisible(false);
		}	
	}
}

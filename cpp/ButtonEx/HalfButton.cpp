#include "HalfButton.h"

USING_NS_CC;
using namespace ui;

HalfButton::HalfButton()
	: m_callBack(nullptr)
	, m_btnLeft(nullptr)
	, m_btnRight(nullptr)
	, m_titleImage(nullptr)
	, m_btnTextureNormal(nullptr)
	, m_btnTextureSelect(nullptr)
	, m_btnTitleTextureNormal(nullptr)
	, m_btnTitleTextureSelect(nullptr)
{

}

HalfButton::~HalfButton()
{

}

HalfButton* HalfButton::create(const std::string& normalImage, const std::string& selectedImage)
{
	auto halfBtn = new HalfButton();
	if (halfBtn && halfBtn->init(normalImage, selectedImage))
	{
		halfBtn->autorelease();
		return halfBtn;
	}
	CC_SAFE_DELETE(halfBtn);
	return nullptr;
}

bool HalfButton::init(const std::string& normalImage, const std::string& selectedImage)
{
	
	m_btnTextureNormal = Director::getInstance()->getTextureCache()->addImage(normalImage);
	CCASSERT(m_btnTextureNormal != nullptr, "m_btnTextureNormal == nullptr");
	m_strNormalImage = normalImage;

	m_strSelectedImage = selectedImage == "" ? normalImage : selectedImage;
	m_btnTextureSelect = Director::getInstance()->getTextureCache()->addImage(m_strSelectedImage);
	CCASSERT(m_btnTextureSelect != nullptr, "m_btnTextureSelect == nullptr");

	if (Sprite::init())
	{
		
		auto spL = Sprite::create(normalImage);
		auto spR = Sprite::create(normalImage);
		spR->setFlippedX(true);

		//this->setTextureRect(Rect(0, 0, spL->getContentSize().width * 2, spL->getContentSize().height));
		this->setContentSize(Size(spL->getContentSize().width * 2, spL->getContentSize().height));
		this->setOpacity(0);

		spL->setPosition(Vec2(spL->getContentSize().width / 2, spL->getContentSize().height / 2));
		spR->setPosition(Vec2(spR->getContentSize().width / 2 * 3, spR->getContentSize().height / 2));

		this->addChild(spL);
		this->addChild(spR);

		m_btnLeft = spL;
		m_btnRight = spR;

		EventListenerTouchOneByOne* listener = EventListenerTouchOneByOne::create();
		listener->setSwallowTouches(true);
		listener->onTouchBegan = CC_CALLBACK_2(HalfButton::onTouchBegan, this);
		listener->onTouchMoved = CC_CALLBACK_2(HalfButton::onTouchMoved, this);
		listener->onTouchEnded = CC_CALLBACK_2(HalfButton::onTouchEnded, this);
		 _eventDispatcher->addEventListenerWithSceneGraphPriority(listener,this);

		return true;
	}
	
	return false;
}

void HalfButton::addTitleImage(const std::string& normalImage, const std::string& selectedImage)
{
	m_strNormalTitleImage = normalImage;
	m_btnTitleTextureNormal = Director::getInstance()->getTextureCache()->addImage(normalImage);
	CCASSERT(m_btnTitleTextureNormal != nullptr, "m_btnTitleTextureNormal == nullptr");

	m_strSelectedTitleImage = selectedImage == "" ? normalImage : selectedImage;
	m_btnTitleTextureSelect = Director::getInstance()->getTextureCache()->addImage(m_strSelectedTitleImage);
	CCASSERT(m_btnTitleTextureSelect != nullptr, "m_btnTitleTextureSelect == nullptr");

	m_titleImage = Sprite::create(m_strNormalTitleImage);
	m_titleImage->setPosition(Vec2(this->getContentSize().width / 2, this->getContentSize().height / 2));
	this->addChild(m_titleImage, 1);

}

void HalfButton::addTouchEventListener(const ccWidgetEventCallback& touch)
{
	m_callBack = touch;
}

cocos2d::Rect rect(Sprite* sp)
{
	return Rect(0, 0, sp->getContentSize().width, sp->getContentSize().height);
}

bool isContainsPoint(Sprite* sp, Vec2 point)
{
	return rect(sp).containsPoint(sp->convertToNodeSpace(point));
}

bool HalfButton::onTouchBegan(cocos2d::Touch *touch, cocos2d::Event *unused_event)
{

	if (isContainsPoint(this, touch->getLocation()))
	{
		if (m_callBack)
		{
			updateButtonTexture(true);
			m_callBack(this, Widget::TouchEventType::BEGAN);
		}

		return true;
	}
	return false;
}

void HalfButton::onTouchMoved(cocos2d::Touch *touch, cocos2d::Event *unused_event)
{
	if (m_callBack)
	{
		updateButtonTexture(isContainsPoint(this, touch->getLocation()));
		m_callBack(this, Widget::TouchEventType::MOVED);
	}
}

void HalfButton::updateButtonTexture(bool bSelected)
{
	if (bSelected)
	{
		m_btnLeft->setTexture(m_btnTextureSelect);
		m_btnRight->setTexture(m_btnTextureSelect);

		if (m_titleImage)
		{
			m_titleImage->setTexture(m_btnTitleTextureSelect);
		}
	}
	else
	{
		m_btnLeft->setTexture(m_btnTextureNormal);
		m_btnRight->setTexture(m_btnTextureNormal);
		if (m_titleImage)
		{
			m_titleImage->setTexture(m_btnTitleTextureNormal);
		}
	}
}

void HalfButton::onTouchEnded(cocos2d::Touch *touch, cocos2d::Event *unused_event)
{
	if (m_callBack)
	{
		updateButtonTexture(false);
		if (isContainsPoint(this, touch->getLocation()))
		{
			m_callBack(this, Widget::TouchEventType::ENDED);
		}
		else
		{
			m_callBack(this, Widget::TouchEventType::CANCELED);
		}
	}
}
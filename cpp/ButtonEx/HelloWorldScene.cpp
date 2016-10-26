#include "HelloWorldScene.h"
#include "VisibleRect.h"

#include "ButtonEx/ButtonEx.h"
#include "ButtonEx/HalfButton.h"

USING_NS_CC;
using namespace ui;


Scene* HelloWorld::createScene()
{
    // 'scene' is an autorelease object
    auto scene = Scene::create();
    
    // 'layer' is an autorelease object
    auto layer = HelloWorld::create();

    // add layer as a child to scene
    scene->addChild(layer);

    // return the scene
    return scene;
}

// on "init" you need to initialize your instance
bool HelloWorld::init()
{
    //////////////////////////////
    // 1. super init first
    if ( !Layer::init() )
    {
        return false;
    }

    auto lab = Label::create("Send Text", "fonts/Marker Felt.ttf", 100);
    auto txtItem = MenuItemLabel::create(lab, [](Ref* pSender)
    		{

    		});

    auto menu = Menu::create(txtItem, NULL);
    menu->setPosition(VisibleRect::center());
    this->addChild(menu, 1);


	auto btn = ButtonEx::create("btn.png", "btn.png", 0);
	btn->setPosition(VisibleRect::center());
	this->addChild(btn, 2);

	btn->addTouchEventListener([=](Ref* ref, ui::Widget::TouchEventType type)->void
	{
		if (type == Widget::TouchEventType::ENDED)
		{
			CCLOG("click btn");
			btn->setPointVisible(1);
		}
	
	});
	
	auto halfBtn = HalfButton::create("btn.png", "btn.png");
	halfBtn->setPosition(VisibleRect::center() + Vec2(0, 100));
	this->addChild(halfBtn);
	halfBtn->addTouchEventListener([](Ref* ref, Widget::TouchEventType type)
	{
		if(type == Widget::TouchEventType::ENDED)
		{
			CCLOG("ENDED ENDED");
		}
	});

	
    return true;
}

void HelloWorld::menuCloseCallback(Ref* pSender)
{

}

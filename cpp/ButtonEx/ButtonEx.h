#ifndef _Button_Ex_H_
#define _Button_Ex_H_

#include "cocos2d.h"
#include "ui/CocosGUI.h"

NS_CC_BEGIN

namespace ui{
	class ButtonEx : public Button
	{
	public:
		ButtonEx();

		virtual ~ButtonEx();

		static ButtonEx* create(const std::string& normalImage,
			const std::string& selectedImage = "",
			size_t msgNum = 0,
			const std::string& disableImage = "",
			TextureResType texType = TextureResType::LOCAL);


		void setPointVisible(size_t msgNum = 0);

	private:
		void createPoint(size_t msgNum);

	private:
		ImageView* m_imgPoint;
	};
}

NS_CC_END


#endif
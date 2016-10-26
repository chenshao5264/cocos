--
-- Author: ChenShao
-- Date: 2016-06-05 16:57:13
--
local GameOverLayer = class("GameOverLayer", function ()
	return display.newLayer()
end)

function GameOverLayer:ctor()
	self._lableGameOver = cc.LabelTTF:create("GAME OVER", "font/lcd.ttf", 50)
	:addTo(self, 10)
	:pos(0, 100)


	local btnReset = ccui.Button:create("menu_reset.png", "menu_reset.png", "")
	:addTo(self, 10)
	:pos(0, 0)
	btnReset:setPressedActionEnabled(true)
	btnReset:addTouchEventListener(function(sender, type)
		if type == 2 then
			app.runningScene:reStart()
			self:setVisible(false)
		end
	end) 

	self:setVisible(false)
end

function GameOverLayer:showLayer()
	self:setVisible(true)
	local actBlink = cc.Blink:create(1, 3)
	self._lableGameOver:runAction(actBlink)
end

function GameOverLayer:onEnter()
end

function GameOverLayer:onExit()
end

return GameOverLayer
--
-- Author: ChenShao
-- Date: 2016-06-04 14:04:32
--
local CtrlLayer = class("CtrlLayer", function()
	return display.newLayer()
end)

function CtrlLayer:ctor()
	self._canTouch = true
	self:initCtrlBtns()
	--self:initSetBtns()
end

function CtrlLayer:initSetBtns()
	local btnEat = ccui.Button:create("menu_reset.png", "menu_reset.png", "")
	:addTo(self)
	:pos(display.cx + 180, display.bottom + 250)
	btnEat:setPressedActionEnabled(true)
	btnEat:addTouchEventListener(function(sender, type)
		if type == 2 then
			--app.isEated = true
			app.isCollision = true
			--app.runningScene:createGameOverLayer()
		end
	end)
end

function CtrlLayer:initCtrlBtns()
	local btnUp = ccui.Button:create("btn_up.png", "btn_up.png", "")
	:addTo(self)
	:pos(display.cx, display.bottom + 190)
	btnUp:setPressedActionEnabled(true)
	btnUp.dir = app.Model.WALK_DIR.UP
	btnUp:addTouchEventListener(handler(self, CtrlLayer.onTouchEvent))

	local btnRight = ccui.Button:create("btn_right.png", "btn_right.png", "")
	:addTo(self)
	:pos(display.cx + 120, display.bottom + 130)
	btnRight:setPressedActionEnabled(true)
	btnRight.dir =app.Model.WALK_DIR.RIGHT
	btnRight:addTouchEventListener(handler(self, CtrlLayer.onTouchEvent))

	local btnDown = ccui.Button:create("btn_down.png", "btn_down.png", "")
	:addTo(self)
	:pos(display.cx, display.bottom + 60)
	btnDown:setPressedActionEnabled(true)
	btnDown.dir = app.Model.WALK_DIR.DOWN
	btnDown:addTouchEventListener(handler(self, CtrlLayer.onTouchEvent))

	local btnLeft = ccui.Button:create("btn_left.png", "btn_left.png", "")
	:addTo(self)
	:pos(display.cx - 120, display.bottom + 130)
	btnLeft:setPressedActionEnabled(true)
	btnLeft.dir = app.Model.WALK_DIR.LEFT
	btnLeft:addTouchEventListener(handler(self, CtrlLayer.onTouchEvent))
end

function CtrlLayer:onTouchEvent(sender, type)
	if type == ccui.TouchEventType.ended then
		if self._canTouch == false then
			return
		end
		self._canTouch = false
		local opDir = sender.dir
		local walkDir = app.spSnakeHeader._dir


		if math.abs(opDir - walkDir) == 2 or  (opDir == walkDir) then
			print("err: 相同方向和相反方向无效")
		else
			app.spSnakeHeader:setWalkDir(opDir)
		end
	end
end


return CtrlLayer

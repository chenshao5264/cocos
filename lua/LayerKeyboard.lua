local LayerKeyboard = class("LayerKeyboard", function()
	return display.newLayer()
end)

function LayerKeyboard:ctor()
	local function onKeyReleased(keyCode)
        if keyCode == cc.KeyCode.KEY_F1 then
        	print("<=== F1")
        end
	end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

return LayerKeyboard
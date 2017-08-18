--
-- Author: Your Name
-- Date: 2017-08-18 10:20:46
--

local DebugLayer = class("ccDebugLayer", function()
    return cc.Layer:create()
end)

local math_floor = math.floor

function DebugLayer:ctor()
    self:setContentSize(cc.size(display.width, display.height))

    local filename = cc.FileUtils:getInstance():getWritablePath() .."point.pt"

    local f = io.open(filename, "a+")
    

    self:onNodeEvent("exit", function()
        if f then
            f:close()
        end
    end)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)

    listener:registerScriptHandler(function(touch, event)
    

        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN )

    listener:registerScriptHandler(function(touch, event)

    end, cc.Handler.EVENT_TOUCH_MOVED )

    listener:registerScriptHandler(function(touch, event)
        local location = touch:getLocation()

        if f then
            location.x = math_floor(location.x)
            location.y = math_floor(location.y)
            local p = json.encode(location)
            f:write(p .."\n")
        end
    end, cc.Handler.EVENT_TOUCH_ENDED )


    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

return DebugLayer
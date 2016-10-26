--
-- Author: ChenShao
-- Date: 2016-09-04 18:34:23
--
local GameView = class("GameView", function()
	return display.newNode()
end)

function GameView:ctor(gamefsm)
	
	-- 通过代理注册事件的好处：可以方便的在视图删除时，清理所以通过该代理注册的事件，
    -- 同时不影响目标对象上注册的其他事件
    --
    -- EventProxy.new() 第一个参数是要注册事件的对象，第二个参数是绑定的视图
    -- 如果指定了第二个参数，那么在视图删除时，会自动清理注册的事件
    local cls = gamefsm.class
    cc.EventProxy.new(gamefsm, self)
        :addEventListener(cls.BET_EVENT, handler(self, self.onBet))
        :addEventListener(cls.DEAL_EVENT, handler(self, self.onDeal))
        :addEventListener(cls.SETTLE_EVENT, handler(self, self.onSettle))
end

function GameView:onBet(event)
	print("<=== GameView:onBet")
end

function GameView:onDeal(event)
	print("<=== GameView:onDeal")
end

function GameView:onSettle(event)
	print("<=== GameView:onSettle")
end

return GameView
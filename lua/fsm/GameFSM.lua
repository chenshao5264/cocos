--
-- Author: ChenShao
-- Date: 2016-09-04 14:42:12
--
local GameFSM = class("GameFSM")

--函数后缀
local FuncSuffixKey = 
{
    "Deal",
    "Bet",
    "Open",
    "Award",
    "GoldFlow",
    "Settle",
    "Wait",
}

-- /**
--  *  	brief: register static eventkey
--  * 	example: GameFSM.DEAL
--  */
local function registerEventKey()
	for i = 1, #FuncSuffixKey do
		local eventKey = string.format("%s_EVENT", string.upper(FuncSuffixKey[i]))
		GameFSM[eventKey] = eventKey
	end
end
registerEventKey()

function GameFSM:ctor()
	cc(self):addComponent("components.behavior.StateMachine")
	self.fsm = self:getComponent("components.behavior.StateMachine")

	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

	local function funcKey(i)
		return string.format("to%s", string.lower(FuncSuffixKey[i]))
	end

	--设定状态机的默认事件
    local defaultEvents = {
    	{name = "resetwait", from = "none", 	to = "wait"},
    	{name = "resetbet",  from = "none", 	to = "bet"},
    	
		{name = funcKey(1),  from = "wait",  	to = "deal"},
		{name = funcKey(2),  from = "deal",   	to = "bet" },
		{name = funcKey(3),  from = "bet",   	to = "open" },
		{name = funcKey(4),  from = "open",  	to = "award"},
		{name = funcKey(5),  from = "award",  	to = "goldflow"},
		{name = funcKey(6),  from = "goldflow", to = "settle"},
		{name = funcKey(7),  from = "settle",  	to = "wait"},
	}

    -- 如果继承类提供了其他事件，则合并
    --table.insertto(defaultEvents, checktable(events))

    --//register callback functions
    self:registerChangeStatusCallBackFunctions()

    -- 设定状态机的默认回调
	local defaultCallbacks = {
		onwait     = handler(self, self.onWait),
		ondeal     = handler(self, self.onDeal),
		onbet      = handler(self, self.onBet),
		onopen     = handler(self, self.onOpen),
		onaward    = handler(self, self.onAward),
		ongoldflow = handler(self, self.onGoldFlow),
		onsettle   = handler(self, self.onSettle),
	}
    -- 如果继承类提供了其他回调，则合并
    --table.merge(defaultCallbacks, checktable(callbacks))

    self.fsm:setupState({
		events    = defaultEvents,
		callbacks = defaultCallbacks
    })

    --//register 给外部调用的函数
    self:registerChangeStatusDoEventFunctions() 
end

function GameFSM:init()
	self.fsm:doEvent("init")
end

function GameFSM:resetWait()
	self.fsm:doEvent("resetwait")
end

function GameFSM:resetBet()
	self.fsm:doEvent("resetbet")
end

-- /**
--  *  简化函数定义
-- 	*  转换状态机 GameFSM:XXX()  函数名为 table to中得valule值
--  *  example: GameFSM:toDeal()  状态改为发牌状态
--  */
function GameFSM:registerChangeStatusDoEventFunctions()
	for i = 1, #FuncSuffixKey do
    	local funcKey = string.format("to%s", FuncSuffixKey[i]) 
    	GameFSM[funcKey] = function()
    		self.fsm:doEvent(string.lower(funcKey))
    	end
    end
end

-- /**
--  *  简化函数定义
-- 	*  state machine call back
--  *  
--  */
function GameFSM:registerChangeStatusCallBackFunctions()
	for i = 1, #FuncSuffixKey do
    	local funcKey = string.format("on%s", FuncSuffixKey[i])
    	GameFSM[funcKey] = function(self, event)
    		local eventKey = string.format("%s_EVENT", string.upper(FuncSuffixKey[i]))
    		self:dispatchEvent({name = eventKey})
    	end
    end
end

function GameFSM:getCurrentState()
	return self:getState()
end

return GameFSM

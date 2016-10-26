-- /**
--  * 	基于cocos的自定义事件分发器
--  * 	注册监听带target时, 移除监听同时需要带有target的API
-- 	*	
--  */

local EventDispatcher = class("EventDispatcher")

local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

function EventDispatcher:ctor()
	self.eventListeners = {} --key 为evtName value 为listener

	self.targetEventListeners = {}--二维数组 target 一维下标 

end

-- /**
--  *	事件分发
--  * 	evtName: string, 事件唯一key
-- 	*	userdata: table, 事件携带数据
--  */
function EventDispatcher:dispatchEvent(evtName, userdata)

	--// temp
	local name
	if type(evtName) == "table" then
		name = evtName.name
		userdata = evtName.data
	else
		name = evtName
	end
	--//

	userdata = checktable(userdata)

	local event = cc.EventCustom:new(name)
	event.data = userdata
	--event.userdata = userdata
	eventDispatcher:dispatchEvent(event)
end

-- -- /**
-- --  *	删除所有监听事件
-- --  */
-- function EventDispatcher:removeAllEventListeners()
-- 	--eventDispatcher:removeAllEventListeners()
-- end

-- /**
--	*	根据evtName删除事件监听
--  *	evtName: string 事件唯一key
--  */
function EventDispatcher:removeEventListenerByName(evtName)
	local listener = self.eventListeners[evtName]
	if listener then
		eventDispatcher:removeEventListener(listener)
		self.eventListeners[evtName] = nil
	end
end

-- /**
--  *	添加事件监听
--  * 	evtName: string, 事件唯一key
-- 	*	evtCallBack: function, 回调事件
--  */
function EventDispatcher:addEventListener(evtName, evtCallBack)
	self:removeEventListenerByName(evtName)

    local listener = cc.EventListenerCustom:create(evtName, evtCallBack)
    eventDispatcher:addEventListenerWithFixedPriority(listener, 1)

    self.eventListeners[evtName] = listener
end

-- /**
--  *	删除target中某个 evtName 的事件监听
-- 	* 	target: node	
--  * 	evtName: string, 事件唯一key
--  */
function EventDispatcher:removeEventListenerByNameForTarget(target, evtName)
	local targetID = tostring(target)
	local listeners = self.targetEventListeners[targetID]

	if listeners then
		local listener = listeners[evtName]
		if listener then
			eventDispatcher:removeEventListener(listener)
			self.targetEventListeners[targetID][evtName] = nil
		end
	end
end

-- /**
--  *	删除target中所有的事件监听
-- 	* 	target: node
--  */
function EventDispatcher:removeEventListenersForTarget(target)
	assert(target ~= nil, "target == nil")
	if target == nil then
		return
	end

	local targetID = tostring(target)
	local listeners = self.targetEventListeners[targetID]

	if listeners then
		for _, listener in pairs(listeners) do
			eventDispatcher:removeEventListener(listener)
		end
	end

	self.targetEventListeners[targetID] = {}
end

-- /**
--  *	添加事件监听, 所有监听的事件,存放到target中
--  * 	target: node, 事件监听容器
--  * 	evtName: string, 事件唯一key
-- 	*	evtCallBack: function, 回调事件
--  */
function EventDispatcher:addEventListenerForTarget(target, evtName, evtCallBack)
	assert(target ~= nil, "target == nil")
	assert(evtCallBack ~= nil, "evtCallBack == nil")

	if target == nil or evtCallBack == nil then
		return
	end

	self:removeEventListenerByNameForTarget(target, evtName)

	local listener = cc.EventListenerCustom:create(evtName, evtCallBack)
	eventDispatcher:addEventListenerWithFixedPriority(listener, 1)

	local targetID = tostring(target)

	self.targetEventListeners[targetID] = self.targetEventListeners[targetID] or {}
	self.targetEventListeners[targetID][evtName] = listener
end

return EventDispatcher
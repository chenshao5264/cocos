--
-- Author: Your Name
-- Date: 2017-06-22 10:22:08
--

local scheduler = {}

local sharedScheduler = cc.Director:getInstance():getScheduler()

--// 下一帧执行
function scheduler.nextFrame(listener)
 local handle
 sharedScheduler:scheduleScriptFunc(function()
        scheduler.unscheduleGlobal(handle)
        listener()
    end, 0, false)
end

function scheduler.unscheduleGlobal(handle)
    sharedScheduler:unscheduleScriptEntry(handle)
end

--- view 移除的时候自动删除view绑定的定时器，无需手动删除定时器
function sharedScheduler.performWithDelayGlobal(view, listener, time)
    local handle
    handle = sharedScheduler:scheduleScriptFunc(function()
        scheduler.unscheduleGlobal(handle)
        listener()
    end, time, false)

    if handle and view then
        view:onNodeEvent("exit", function()
            scheduler.unscheduleGlobal(handle)
        end)
    end

    return handle
end


return sharedScheduler
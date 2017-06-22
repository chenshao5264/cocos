-- @Author     : wangyao
-- @DateTime   : 2017-05-10 12:00:15
-- @Description: 测试接口

local WSAgent       = import(".wsagent")
local UpLoader      = import(".uploadlog")
local GMLayer       = import(".gmlayer")
local GMIcon        = import(".gmicon")
local FlyMsg        = import(".flymsg")
local scheduler     = cc.Director:getInstance():getScheduler()

cc.exports.DbgInterface = {}

function DbgInterface:run()
    self.nScheduleId = scheduler:scheduleScriptFunc(function()
        myxpcall(function()
            self:onSchedule()
        end)
    end, 1, false)
end

function DbgInterface:onSchedule()
    self:showGMIcon()
    UpLoader:flushPrintLog()
end

function DbgInterface:connectTestServer()
    if not gDbgConfig.gmenable then
        return
    end
    if self:getPlayerId() <= 0 then
        return
    end
    if not self._wsAgent then
        self._wsAgent = WSAgent:create(self)
    end
    if self._wsAgent:isConnect() then
        return
    end
    --self._wsAgent:startReconnet()
    self._wsAgent:connect()
end

function DbgInterface:disConnectTestServer()
    if self._wsAgent then
        self._wsAgent:close()
    end
end

function DbgInterface:onWSOpen()
    self._wsAgent:send({
        cmd = "login",
        nUserID = self:getPlayerId(),
        szPassword = "woshishabi",
    })
end

function DbgInterface:isWSConnect()
    if self._wsAgent then
        return self._wsAgent:isConnect()
    end
    return false
end

function DbgInterface:uploadPrintLog(szLog)
    if not gDbgConfig.synclog then
        return
    end
    if self:getPlayerId() <= 0 then
        return
    end    
    UpLoader:uploadPrintLog(szLog)
end

function DbgInterface:uploadFile(szPath, uploadEventHandler)
    UpLoader:uploadFile(szPath, uploadEventHandler)
end

function DbgInterface:showMsg(szMsg, color)
    package.loaded["debugtool.flymsg"] = nil           -- reload for test
    local FlyMsg = import("debugtool.flymsg")          -- reload for test    

    FlyMsg:create(szMsg, color)
end

function DbgInterface:showGMLayer()
    package.loaded["debugtool.gmlayer"] = nil           -- reload for test
    local GMLayer = import("debugtool.gmlayer")         -- reload for test

    self:connectTestServer()
    GMLayer:create()
end

function DbgInterface:closeGMLayer()
    local curScene = display.getRunningScene()
    if curScene and curScene._gmLayer then
        myxpcall(function()
            curScene._gmLayer:remove()
        end)        
        curScene._gmLayer = nil
    end
end

function DbgInterface:setLogFileStartLine(nLineIdx)
    self._logFileStartLine = nLineIdx
end

function DbgInterface:getLogFileStartLine()
    return self._logFileStartLine or 0
end

function DbgInterface:showGMIcon()
    local curScene = display.getRunningScene()
    if curScene and not curScene._disableGMIcon and not curScene._gmIcon then
        curScene._gmIcon = GMIcon:create()
    end
end

function DbgInterface:closeGMIcon()
    local curScene = display.getRunningScene()
    if curScene and curScene._gmIcon then
        myxpcall(function()
            curScene._gmIcon:remove()
        end)        
        curScene._gmIcon = nil
    end
end

function DbgInterface:disableGMIconInCurrentScene()
    local curScene = display.getRunningScene()
    if curScene then
        curScene._disableGMIcon = true
    end
    self:closeGMIcon()
end

function DbgInterface:getPlayerId()
    if mymodel then
        local user = mymodel("UserModel"):getInstance()
        if user and user.nUserID then
            return user.nUserID
        end
    end
    return 0
end

function DbgInterface:getGameAbbr()
    if my and my.getAbbrName then
        return my.getAbbrName()
    end
    return "xxxx"
end

return DbgInterface

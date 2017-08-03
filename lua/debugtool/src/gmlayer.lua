local SearchLayer   = import(".searchlayer")
local HistoryLayer   = import(".historylayer")
local GMLayer       = class("GMLayer")

GMLayer.RES_PATH                = "res/gmtool/gmlayer.csb"
GMLayer.RES_PATH_SP             = "res/gmtool/gmlayersp.csb"

GMLayer.GAP_SCHEDULE            = 0.2   -- 刷新间隔
GMLayer.MAX_HISTORY_FILE_SHOW   = 5     -- 显示几个历史日志文件

GMLayer.MODE_CURRENT            = 1     -- 当前日志文件
GMLayer.MODE_HISTORY            = 2     -- 历史日志文件

GMLayer.TABLEVIEW_WIDTH         = display.width - 110
GMLayer.TABLEVIEW_HEIGIT        = display.height - 130
GMLayer.TABLEVIEW_POSX          = 30
GMLayer.TABLEVIEW_POSY          = 50

local function isShuPing()
    return display.height > display.width
end

if isShuPing() then
    GMLayer.TABLEVIEW_WIDTH         = display.width - 130
    GMLayer.TABLEVIEW_HEIGIT        = display.height - 110
    GMLayer.TABLEVIEW_POSX          = 80
    GMLayer.TABLEVIEW_POSY          = 30
end

function GMLayer:ctor()
    self:createResNode()
    self:initChildName()

    self:registEvent()

    self.cacheFile      = {}
    self.tbTextLines    = {}
    self.tbTextColor    = {}

    self:setMode(self.MODE_CURRENT)
    self:setAutoScroll(true)

    self._resNode:scheduleUpdate(handler(self, self.onSchedule))

    self:loadLogFile()
end

function GMLayer:createResNode()
    local resPath = isShuPing() and self.RES_PATH_SP or self.RES_PATH
    local node = cc.CSLoader:createNode(resPath)
    node:setAnchorPoint(0.5, 0.5)
    node:setPosition(display.center)
    node:setLocalZOrder(1000)
    local curScene = display.getRunningScene()
    curScene:addChild(node)
    self._resNode = node
end

function GMLayer:remove()
    if self._resNode then
        self._resNode:removeFromParent()
        --DbgInterface:disConnectTestServer()
    end
end

function GMLayer:initChildName()
    local panel         = self._resNode:getChildByName("Panel")
    local toolBar       = panel:getChildByName("Node_ToolBar")
    local stateBar      = panel:getChildByName("Node_StateBar")
    local toolBarPanel  = toolBar:getChildByName("Panel")
    local stateBarPanel = stateBar:getChildByName("Panel")
    self.nodes = {
        panel           = panel,
        toolBar         = toolBar,
        stateBar        = stateBar,
        btnQuit         = toolBarPanel:getChildByName("Btn_Quit"),
        btnShowLog      = toolBarPanel:getChildByName("Btn_ShowLog"),
        btnClearLog     = toolBarPanel:getChildByName("Btn_Clear"),
        btnLoadFile     = toolBarPanel:getChildByName("Btn_LoadFile"),
        btnSearch       = toolBarPanel:getChildByName("Btn_Search"),
        btnHelp         = toolBarPanel:getChildByName("Btn_Help"),
        cboxScroll      = toolBarPanel:getChildByName("CheckBox_Scroll"),
        txtConnectState = stateBarPanel:getChildByName("Text_ConnectState"),
        txtMsg          = stateBarPanel:getChildByName("Text_Msg"),
        txtPlayerId     = stateBarPanel:getChildByName("Text_PlayerId"),
        txtFileName     = stateBarPanel:getChildByName("Text_FileName"),
        slider          = panel:getChildByName("Slider"),
        nodeSearch      = panel:getChildByName("Node_Search"),
        nodeHistory     = panel:getChildByName("Node_History"),
    }

    self.nodes.btnHelp:hide()
    self.nodes.slider:hide()
    self.nodes.nodeSearch:hide()
    self.nodes.nodeHistory:hide()
    self.nodes.txtMsg:hide()
    self.nodes.txtPlayerId:setString("UserID:" .. DbgInterface:getPlayerId())

    -- 适配
    panel:setContentSize(cc.size(display.width, display.height))
    if isShuPing() then        
        self.nodes.toolBar:setPosition(cc.p(0, display.height/2))
        self.nodes.stateBar:setPosition(cc.p(display.width, display.height/2))
        self.nodes.slider:setContentSize(cc.size(self.TABLEVIEW_WIDTH, 30))
        self.nodes.slider:setPosition(cc.p(self.TABLEVIEW_POSX, self.TABLEVIEW_HEIGIT + self.TABLEVIEW_POSY + 20))
    else
        self.nodes.toolBar:setPosition(display.width/2, display.height)
        self.nodes.stateBar:setPosition(cc.p(display.width/2, 0))
        self.nodes.slider:setContentSize(cc.size(self.TABLEVIEW_HEIGIT, 30))
        self.nodes.slider:setPosition(cc.p(self.TABLEVIEW_WIDTH + self.TABLEVIEW_POSX + 20, self.TABLEVIEW_POSY))
    end
end

function GMLayer:registEvent()
    self.nodes.btnQuit:addClickEventListener(function()
        self:remove()
    end)

    self.nodes.btnShowLog:addClickEventListener(function()
        self:setMode(self.MODE_CURRENT)
        self:loadLogFile()
    end)

    self.nodes.btnClearLog:addClickEventListener(function()
        self:clearLogFile()
    end)

    -- 移动端无接口遍历文件夹获取文件，而且登陆后才知道userID，所以以递增ID区分文件，windows端以userId为文件名区分
    -- if device.platform == "windows" then
    --     self.nodes.btnLoadFile:hide()
    -- end
    self.nodes.btnLoadFile:addClickEventListener(function()
        self:openHistory()
    end)

    self.nodes.btnSearch:addClickEventListener(function()
        self:openSearch()
    end)    

    self.nodes.cboxScroll:addEventListener(function(sender, eventType)
        if eventType == 0 then
            self:setAutoScroll(true)
        elseif eventType == 1 then
            self:setAutoScroll(false)
        end
    end)

    self.nodes.slider:addEventListener(function(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            self:setTBViewOffsetByPercent(sender:getPercent())
        end
    end)

    -- self._listener = cc.EventListenerKeyboard:create()
    -- self._listener:registerScriptHandler(handler(self, self.onKeyboardReleased), cc.Handler.EVENT_KEYBOARD_RELEASED)
    -- self._resNode:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._listener, self._resNode)
end

-- function GMLayer:onKeyboardReleased(keyCode, event)
--     if keyCode == cc.KeyCode.KEY_BACK then
--         self._listener:setEnabled(false)
--         self:remove()
--         return false
--     end
-- end

function GMLayer:tipMsg(szMsg, color)
    DbgInterface:showMsg(szMsg, color)
    -- szMsg = szMsg or ""
    -- color = color or display.COLOR_WHITE
    -- self.nodes.txtMsg:setString(szMsg)    
    -- self.nodes.txtMsg:setColor(color)
    -- self.nodes.txtMsg:show()
    -- self:regDelayFunc(function()
    --     self.nodes.txtMsg:hide()
    -- end, 2)
end

function GMLayer:onSchedule()
    self:processDelayFunc()

    self:setBtnEnabled(self.nodes.btnClearLog, self._mode == self.MODE_CURRENT)

    if DbgInterface:isWSConnect() then
        self.nodes.txtConnectState:setString("指令服已连接 139.224.117.95")
        self.nodes.txtConnectState:setColor(display.COLOR_GREEN)
    else
        self.nodes.txtConnectState:setString("指令服未连接 139.224.117.95")
        self.nodes.txtConnectState:setColor(display.COLOR_RED)
    end

    if self._autoScroll and self._mode == self.MODE_CURRENT then
        local nowTime = os.clock()
        self._lastTime = self._lastTime or 0
        if nowTime - self._lastTime > self.GAP_SCHEDULE then
            self._lastTime = nowTime
            self:loadLogFile()
        end
    end
end

function GMLayer:regDelayFunc(func, nDelay)
    self._delayFuncList = self._delayFuncList or {}
    local nEndLine = os.clock() + nDelay
    table.insert(self._delayFuncList, {func, nEndLine})
end

function GMLayer:processDelayFunc()
    local nNowClock = os.clock()
    local tbLeft = {}
    for _, tb in pairs(self._delayFuncList or {}) do
        if nNowClock >= tb[2] then
            tb[1]()
        else
            table.insert(tbLeft, tb)
        end
    end
    self._delayFuncList = tbLeft
end

function GMLayer:setBtnEnabled(btn, bEnable)
    btn:setEnabled(bEnable)
end

function GMLayer:setMode(szMode)
    self._mode = szMode
    local bCur = szMode == self.MODE_CURRENT
    self.nodes.btnShowLog:setTitleColor(bCur and display.COLOR_GREEN or display.COLOR_BLACK)
    self.nodes.btnLoadFile:setTitleColor(bCur and display.COLOR_BLACK or display.COLOR_GREEN)
end

function GMLayer:setAutoScroll(bAtuto)
    self._autoScroll = bAtuto
    if self.nodes.cboxScroll:isSelected() ~= bAtuto then
        self.nodes.cboxScroll:setSelected(bAtuto)
    end
end

function GMLayer:getTextHeight(szStr)
    local text = ccui.Text:create()
    text:setFontSize(20)
    text:setString(szStr)
    local sz = text:getContentSize()
    return sz.height
end

function GMLayer:clearLogFile()
    if self._mode == self.MODE_CURRENT then
        if self._totalLines then
            DbgInterface:setLogFileStartLine(self._totalLines)
            self.tbTextLines = {}
            self:showLogView()
        end
    end
end

function GMLayer:setStateFileName(filePath)
    local path = string.gsub(filePath, "\\", "/")
    local name = string.match(path, "/([^/]+/[^/]+.txt)")
    self.nodes.txtFileName:setString(name)
end

function GMLayer:autoSplitLine(szStr, getWidth)
    local maxWidth = isShuPing() and self.TABLEVIEW_HEIGIT - 50 or self.TABLEVIEW_WIDTH - 50
    cc.exports._fixLineLen = cc.exports._fixLineLen or 100
    if string.len(szStr) < cc.exports._fixLineLen then
        return {szStr}
    end
    if getWidth(szStr) <= maxWidth then
        return {szStr}
    end

    local lines = {}
    local pos = 1
    local len = string.len(szStr)
    while true do
        szStr = string.sub(szStr, pos, -1)
        local newPos = self:binSearch(szStr, maxWidth, getWidth)
        lines[#lines+1] = string.sub(szStr, 1, newPos)
        pos = newPos + 1
        if pos > string.len(szStr) then
            break
        end

        cc.exports._fixLineLen = math.min(cc.exports._fixLineLen, newPos)
    end
    return lines
end

function GMLayer:binSearch(s, maxWidth, getWidth)
    local r = string.len(s)
    local l = math.min(cc.exports._fixLineLen, r)
    local best = l
    while l < r do
        local mid = math.floor((l+r) / 2)
        local subStr = string.sub(s, 1, mid)
        if getWidth(subStr) <= maxWidth then
            best = mid
            l = mid + 1
        else
            r = mid - 1
        end
    end
    return best
end

function GMLayer:loadLogFile(filePath)
    filePath = filePath or gCurLogPath
    local sz = io.filesize(filePath)
    if self.cacheFile[filePath] == sz then
        return
    end
    self.cacheFile = {[filePath] = sz}

    self:setStateFileName(filePath)

    local f = io.open(filePath, "r")
    local tbLines = {}
    self.tbTextLines = {}
    local nLineIdx = 0
    local nLineIdx2 = 0
    local nStartIdx = DbgInterface:getLogFileStartLine()
    if self._mode == self.MODE_HISTORY then
        nStartIdx = 0
    end

    local tmpText = ccui.Text:create()
    tmpText:setFontSize(20)
    local function getWidth(str)
        tmpText:setString(str)
        local sz = tmpText:getContentSize()
        return sz.width
    end

    while true do
        local line = f:read("*line")
        if not line then break end
        nLineIdx = nLineIdx + 1
        if nLineIdx > nStartIdx then
            nLineIdx2 = nLineIdx2 + 1

            line = string.gsub(line, "\t", "    ")
            local autoLines = self:autoSplitLine(line, getWidth)
            for i, subline in ipairs(autoLines) do
                self.tbTextLines[#self.tbTextLines + 1] = string.format("%4d:", nLineIdx2) .. subline
            end
        end
    end
    f:close()
    self._totalLines = nLineIdx

    if self.tbTextLines[1] then
        self._lineHeight = self:getTextHeight(self.tbTextLines[1])
    end
    
    self:showLogView()
end     

function GMLayer:numberOfCellsInTableView(view)
    return #self.tbTextLines
end

function GMLayer:cellSizeForTable(table, idx)
    -- [NOTICE] cocos2dx 版本不一样这里 返回width,height的顺序可能不一样的！！
    if isShuPing() then
        return self.TABLEVIEW_HEIGIT, self._lineHeight
    end
    return self._lineHeight, self.TABLEVIEW_WIDTH
end

function GMLayer:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local str = self.tbTextLines[idx+1] or ""
    local color = self.tbTextColor[idx+1] or display.COLOR_WHITE
    if nil == cell then
        cell = cc.TableViewCell:new()
        local text = ccui.Text:create()
        text:setFontSize(20)
        if isShuPing() then
            text:setRotation(270)
            text:setAnchorPoint(cc.p(0, 1))
        else
            text:setAnchorPoint(cc.p(0, 0))
        end
        text:setString(str)
        text:setColor(color)
        cell:addChild(text)
        cell._text = text
    else
        cell._text:setString(str)
        cell._text:setColor(color)
    end
    return cell
end

function GMLayer:_getTotalOffset()
    if isShuPing() then
       return self.TABLEVIEW_WIDTH - (#self.tbTextLines * self._lineHeight) 
    end
    return  self.TABLEVIEW_HEIGIT - (#self.tbTextLines * self._lineHeight)
end

function GMLayer:isSliderNeedShow()
    local nTextHeight = #self.tbTextLines * self._lineHeight
    if isShuPing() and self.TABLEVIEW_WIDTH >= nTextHeight then
        return false
    end
    if not isShuPing() and self.TABLEVIEW_HEIGIT >= nTextHeight then
        return false
    end
    return true
end

function GMLayer:scrollViewDidScroll(view)
    if not self:isSliderNeedShow() then
        return
    end

    local offsetFront, offsetBack = self:getOffsetInterval()
    local nNowOffset
    if isShuPing() then
        nNowOffset = self.tableView:getContentOffset().x
    else
        nNowOffset = self.tableView:getContentOffset().y
    end

    local per = (nNowOffset - offsetFront) / (offsetBack - offsetFront) * 100
    local per = math.min(math.max(per, 0), 100)

    self.nodes.slider:setPercent(per)
    self:setAutoScroll(per >= 100)
end

function GMLayer:setTBViewOffsetByPercent(percent)
    if not self:isSliderNeedShow() then
        return
    end
    local offsetFront, offsetBack = self:getOffsetInterval()
    local nNowOffset = (offsetBack - offsetFront) * percent / 100 + offsetFront
    if isShuPing() then
        self.tableView:setContentOffset(cc.p(nNowOffset, 0))
    else
        self.tableView:setContentOffset(cc.p(0, nNowOffset))
    end
end

function GMLayer:getOffsetInterval(percent)
    local offsetFront, offsetBack
    if not isShuPing() then
        offsetFront = self.TABLEVIEW_HEIGIT - (#self.tbTextLines * self._lineHeight)
        offsetBack = 0
    else
        offsetFront = 0
        offsetBack = self.TABLEVIEW_WIDTH - (#self.tbTextLines * self._lineHeight)
    end
    return offsetFront, offsetBack
end

function GMLayer:showLogView()
    if self.tableView then
        self.tableView:removeFromParent()
        self.tableView = nil
    end

    self.nodes.slider:hide()
    if #self.tbTextLines <= 0 then
        return
    end
    
    local tableView = cc.TableView:create(cc.size(self.TABLEVIEW_WIDTH, self.TABLEVIEW_HEIGIT))
    if isShuPing() then
        tableView:setDirection(2)
        tableView:setVerticalFillOrder(0)
    else
        tableView:setDirection(1)
        tableView:setVerticalFillOrder(0)
    end
    tableView:setPosition(cc.p(self.TABLEVIEW_POSX, self.TABLEVIEW_POSY))
    tableView:setDelegate()
    self.nodes.panel:addChild(tableView)
    self.tableView = tableView

    tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), 8)
    tableView:registerScriptHandler(handler(self, self.scrollViewDidScroll), 0)
    tableView:registerScriptHandler(handler(self, self.cellSizeForTable), 6)
    tableView:registerScriptHandler(handler(self, self.tableCellAtIndex), 7)
    tableView:reloadData()

    self:setTBViewOffsetByPercent(100)

    self.nodes.slider:setVisible(self:isSliderNeedShow())
    self.nodes.slider:setPercent(100)
end

function GMLayer:openHistory()    
    self.nodes.nodeHistory:show()
    HistoryLayer:create(self.nodes.nodeHistory, self)
end

function GMLayer:closeHisory()
   self.nodes.nodeHistory:hide()
end

function GMLayer:showHistoryFile(szFilePath)
    self:setMode(self.MODE_HISTORY)
    self:loadLogFile(szFilePath)
end

function GMLayer:openSearch()
    self.tbTextColor = {}
    self.nodes.nodeSearch:show()
    SearchLayer:create(self.nodes.nodeSearch, self)
end

function GMLayer:closeSearch()
    self.nodes.nodeSearch:hide()
end

function GMLayer:locateToLineForSearch(nLineIdx)
    self.tbTextColor[nLineIdx] = display.COLOR_GREEN

    if not self:isSliderNeedShow() then
        return
    end

    local per = math.floor(((nLineIdx+1) / #self.tbTextLines) * 100)
    self:setTBViewOffsetByPercent(per)
    self.tableView:updateCellAtIndex(nLineIdx-1)
end

return GMLayer

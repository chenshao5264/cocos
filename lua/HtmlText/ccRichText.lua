--
-- Author: ChenShao
-- Date: 2017-05-11 14:45:45
--


-- local xmlText = "<font color='ffffff' size='30' opacity='255'><font color='ff0000' face='happyfont.ttf'>你好</font><font color='00ff00'>jikexueyuan</font><br/>新<br/><font color='0000ff'>的</font>行<br/>又是新的一行</font>"

-- local htmlText = require("app.share.HtmlText").new()
-- htmlText:renderHtml(xmlText)

-- htmlText:setPosition(display.cx - 200, display.cy)
-- display.getRunningScene():addChild(htmlText, 2)

--// 新版本增加点击事件 需要更改 底层代码
--// 目前只支持 lable的点击事件
-- local function cb1(obj)
--     print "1111"
-- end

-- local function cb2(obj)
--     print "222"
-- end
-- local xmlText = "<font color='ffffff' size='30' opacity='255' tag='2'>123123123<font color='ff0000' face='happyfont.ttf' tag='1'>你好</font></font>"
-- local richText = cc.RichTextEx:create(xmlText)
-- richText:setPosition(display.cx, display.cy)
-- richText:setCallBack("1", cb1)
-- richText:setCallBack("2", cb2)
-- self:addChild(richText)
-- "ps 注意tag"



local HtmlText = class("HtmlText", function()
	return ccui.Widget:create()
end)

function HtmlText:ctor()
	self._font = {
		face = "",
		size = "",
		color    = "",
		opacity  = ""
	}
	self._fontList = {}

	local defaultFont = {}
	defaultFont.face = ""
	defaultFont.size = 24
	defaultFont.color    = "ffffff"
	defaultFont.opacity  = 255

	self.defaultFont = defaultFont

	
	self._fontList[#self._fontList + 1] = defaultFont

	self._lineList = {}
	self._line = {}
	self._key_node = {}

	self._startIndex = 1

	self:addNewLine()
end

function HtmlText:create(htmlString)
	local ptr = HtmlText.new()

	if htmlString then
		ptr:renderHtml(htmlString)
	end

	return ptr
end

function HtmlText:FromXmlString(value)
    value = string.gsub(value, "&#x([%x]+)%;",
        function(h)
            return string.char(tonumber(h, 16))
        end);
    value = string.gsub(value, "&#([0-9]+)%;",
        function(h)
            return string.char(tonumber(h, 10))
        end);
    value = string.gsub(value, "&quot;", "\"");
    value = string.gsub(value, "&apos;", "'");
    value = string.gsub(value, "&gt;", ">");
    value = string.gsub(value, "&lt;", "<");
    value = string.gsub(value, "&amp;", "&");
    value = string.gsub(value, "&nbsp;", " ");
    return value
end

function HtmlText:renderFile(path)
	local xmlText = cc.FileUtils:getInstance():getStringFromFile(path)
	self:renderHtml(xmlText)
end

function HtmlText:renderHtml(htmlString)
	self:renderNode(htmlString, 1)

	self:updateLine()
end

local function hex2Rgb(strHex)
	strHex = string.gsub(strHex, "#", "")
	local r = tonumber("0x" ..string.sub(strHex, 1, 2))
	local g = tonumber("0x" ..string.sub(strHex, 3, 4))
	local b = tonumber("0x" ..string.sub(strHex, 5, 6))
	return cc.c3b(r, g, b)
end

function HtmlText:ParseArgs(node, xarg)
	string.gsub(xarg, "(%w+)=([\"'])(.-)%2", function(w, _, a)
		node[w] = a
	end)
end

function HtmlText:setCallBack(tag, cb)
	local node = self._key_node[tag] 

	local function press(obj)
		local act = cc.ScaleTo:create(0.1, 0.9)
		obj:stopAllActions()
		obj:runAction(act)
	end

	local function release(obj)
		local act = cc.ScaleTo:create(0.1, 1)
		obj:stopAllActions()
		obj:runAction(act)
	end

	local function onTouchBegan(touch, event)

		local curObj = event:getCurrentTarget()
		local location = touch:getLocation()

		local curObjRect = cc.rect(0, 0, curObj:getContentSize().width, curObj:getContentSize().height)

		if cc.rectContainsPoint(curObjRect,  curObj:convertToNodeSpace(location)) then
			press(curObj)
			if cb then
				cb(curObj)
			end
			return true
		end
	end

	local function onTouchEnded(touch, event)
		release(event:getCurrentTarget())
	end

	local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end

function HtmlText:renderNode(xmlText, startIndex)

	local ni, c, label, xarg, empty
	local i, j = startIndex, 1 

	if true then
		ni, j, c, label, xarg, empty = string.find(xmlText, "<(%/?)([%w_:]+)(.-)(%/?)>", i)
		if not ni then
			return
		end
		-- print("<==== i = " ..i)
		-- print("<==== ni = " ..ni)
		-- print("<==== c = " ..c)
		-- print("<==== label = " ..label)
		-- print("<==== xarg = " ..xarg)
		-- print("<==== empty = " ..empty)

		local text = string.sub(xmlText, i, ni - 1);
        if not string.find(text, "^%s*$") then
            local value = self:FromXmlString(text)

            value = string.gsub(value, "[\n\r]", "")

            local font = self._fontList[#self._fontList]
            local textElement = ccui.RichElementText:create(font.tag or 0, hex2Rgb(font.color), font.opacity, value, font.face, font.size)
            self._line:pushBackElement(textElement)
		end	

    	label = string.upper(label)

    	if label == "FONT" then
    		if c == "" then -- start tag
				local newFont = clone(self._fontList[#self._fontList])
				self:ParseArgs(newFont, xarg)

				table.insert(self._fontList, newFont)
				self:renderNode(xmlText, j + 1)
				table.remove(self._fontList)
			elseif c == "/" then -- end tag
				table.remove(self._fontList)
				self:renderNode(xmlText, j + 1)
			end
		elseif label == "IMG" then

			if c == "" then -- start tag
				local imgArgs = {}
				imgArgs.color   = 'ffffff'
				imgArgs.opacity = 255
				imgArgs.src     = ""
				self:ParseArgs(imgArgs, xarg)

				local imgElement = ccui.RichElementImage:create(1, hex2Rgb(imgArgs.color), imgArgs.opacity, imgArgs.src)
				self._line:pushBackElement(imgElement)
			else

			end
			self:renderNode(xmlText, j + 1)
		elseif label == "BR" then
			self:addNewLine()
			self:renderNode(xmlText, j + 1)
		end	
	end
end

function HtmlText:addNewLine()
	self._line = ccui.RichText:create()
	self._lineList[#self._lineList + 1] = self._line

	self:addChild(self._line)
end

function HtmlText:updateLine()
	local commHeight = 0
	local maxWidth = 0 
	local maxHeight = 0
	for i = #self._lineList, 1, -1 do
		local line = self._lineList[i]
		line:formatText()
		local size = line:getContentSize()
		if size.height ~= 0 and commHeight == 0 then
			commHeight = size.height
		end
		line:setPosition(size.width / 2, maxHeight)
		if size.width > maxWidth then
			maxWidth = size.width
		end
		maxHeight = maxHeight + commHeight

		local key_node = line:getCanClickNodes()
		for key, node in pairs(key_node) do
			self._key_node[key] = node
		end
	end
	self:setContentSize(cc.size(maxWidth, maxHeight))
end

return HtmlText
--
-- Author: ChenShao
-- Date: 2016-06-04 15:12:35
--
local TailPart = class("TailPart", function()
	return display.newSprite("snake_tail.png")
end)

function TailPart:ctor(cellX, cellY)
	self._cellX = cellX
	self._cellY = cellY

	local p = app.Model:getPos(self._cellX, self._cellY)
	self:setPosition(p.x, p.y)


end

function TailPart:remove()
	self:removeSelf()
end

function TailPart:onEnter()
end

function TailPart:onExit()
end


return TailPart
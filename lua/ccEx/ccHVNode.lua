--
-- Author: Your Name
-- Date: 2017-07-03 10:15:25
--


-- local hvNode = cc.HVNode:create({img1, img2, img3, img4}, 0, 10)
-- hvNode:setPosition(display.cx, display.cy)
-- self:addChild(hvNode, 1)

-- hvNode:pushBackCustomBack(img1:clone())

local HVNode = class("HVNode", function()
    return cc.Node:create()
end)

function HVNode:ctor(direction, itemsMargin)

    self._items       = {}
    self._direction   = direction or 0
    self._itemsMargin = itemsMargin or 10
end

function HVNode:setDirection(direction)
    self._direction = direction or 0
end

function HVNode:setItemsMargin(margin)
    self._itemsMargin = margin or 10
end

function HVNode:pushBackCustomBack(item)
    self._items[#self._items + 1] = item
    self:addChild(item)
    item:setPosition(0, 0)

    self:adjust()
end

function HVNode:adjust()
    local items       = self._items
    local itemCount   = #self._items    

    if itemCount <= 0 then
        return
    end

    local itemX
    local itemSize = items[1]:getContentSize()
    if self._direction == 0 then --// 水平
        itemX = itemSize.width
    else
        itemX = itemSize.height
    end

    local firstPos  = -(itemX + self._itemsMargin) * (itemCount - 1) / 2
    if self._direction == 0 then --// 水平
        for i = 1, itemCount do
            local item = items[i]
            item:setPositionX(firstPos + (itemX + self._itemsMargin) * (i - 1))
            item:setTag(i)
        end
    else
        for i  = 1, itemCount do
            local item = items[i]
            item:setPositionY(firstPos + (itemX + self._itemsMargin) * (i - 1))
            item:setTag(i)
        end
    end
end

function HVNode:getItemByIndex(idx)
    return self:getChildByTag(idx)
end

function HVNode:removeItemByIndex(idx)
    if self:getChildByTag(idx) then
        table.remove(self._items, idx)
        self:removeChildByTag(idx)
    else
        print("no item: " ..idx)
    end

    self:adjust()
end

return HVNode


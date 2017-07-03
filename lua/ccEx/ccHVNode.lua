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

function HVNode:ctor(items, direction, itemsMargin)

    self._items       = items or {}
    self._direction   = direction or 0
    self._itemsMargin = itemsMargin or 10

    local itemX
    local itemSize = items[1]:getContentSize()
    if direction == 0 then --// 水平
        itemX = itemSize.width
    else
        itemX = itemSize.height
    end

    self._itemX = itemX

    local itemCount = #items
    local firstPos  = -(itemX + itemsMargin) * (itemCount - 1) / 2
    if direction == 0 then --// 水平
        for i  = 1, itemCount do
            local item = items[i]
            item:setPositionX(firstPos + (itemX + itemsMargin) * (i - 1))
            item:setTag(i)
            self:addChild(item)
        end
    else
        for i  = 1, itemCount do
            local item = items[i]
            item:setPositionY(firstPos + (itemX + itemsMargin) * (i - 1))
            item:setTag(i)
            self:addChild(item)
        end
    end
end

function HVNode:pushBackCustomBack(item)
    self._items[#self._items + 1] = item
    self:addChild(item)

    self:adjust()
end

function HVNode:adjust()
    local items       = self._items
    local itemCount   = #self._items    
    local itemX       = self._itemX
    local itemsMargin = self._itemsMargin

    local firstPos  = -(itemX + itemsMargin) * (itemCount - 1) / 2
    if self._direction == 0 then --// 水平
        for i = 1, itemCount do
            local item = items[i]
            item:setPositionX(firstPos + (itemX + itemsMargin) * (i - 1))
            item:setTag(i)
        end
    else
        for i  = 1, itemCount do
            local item = items[i]
            item:setPositionY(firstPos + (itemX + itemsMargin) * (i - 1))
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


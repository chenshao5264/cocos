--
-- Author: Your Name
-- Date: 2017-06-27 18:28:22
--
local Node = cc.Node or {}

function Node:performWithDelay(callback, delay)
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    self:runAction(sequence)
    return self
end
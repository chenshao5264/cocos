--
-- Author: ChenShao
-- Date: 2016-06-04 19:40:04
--
local SnakeTail = class("SnakeTail", function()
	return display.newSprite("snake_tail.png")
end)

--[[
local GRAVITY         = 0
local COIN_MASS       = 100
local COIN_RADIUS     = 46
local COIN_FRICTION   = 0.8
local COIN_ELASTICITY = 0.8
local WALL_THICKNESS  = 64
local WALL_FRICTION   = 1.0
local WALL_ELASTICITY = 0.5
]]

function SnakeTail:ctor()
	self._cellX = 0
	self._cellY = 0
	self._dir = app.Model.WALK_DIR.UP
	self._tag = 0

	--self:initPhysicsBody()
end

function SnakeTail:initPhysicsBody()
	local snakeBody = cc.PhysicsBody:createBox(self:getContentSize(),
        cc.PhysicsMaterial(COIN_RADIUS, COIN_FRICTION, COIN_ELASTICITY))
    snakeBody:setMass(COIN_MASS)
    self:setPhysicsBody(snakeBody)

	snakeBody:setCategoryBitmask(1)
	snakeBody:setContactTestBitmask(1)
	snakeBody:setCollisionBitmask(1)
end

function SnakeTail:updatePos()
	local p = self:getPos()
	self:setPosition(p.x, p.y)
end

function SnakeTail:getPos()
	local  p = app.Model:getPos(self._cellX, self._cellY)
	return cc.p(p.x, p.y)
end

function SnakeTail:walk()
	local p = self:getPos()
	self:setPosition(p.x, p.y)
end


function SnakeTail:onEnter()
end

function SnakeTail:onExit()
end

return SnakeTail
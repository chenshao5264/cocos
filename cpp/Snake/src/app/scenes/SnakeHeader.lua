--
-- Author: ChenShao
-- Date: 2016-06-04 18:54:22
--
local SnakeHeader = class("SnakeHeader", function()
	return display.newSprite("snake_header.png")
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

function SnakeHeader:ctor()
	self._cellX = 7
	self._cellY = 7
	self._dir = app.Model.WALK_DIR.UP
	self._tag = 1

	local p = self:getPos()
	self:setPosition(p.x, p.y)


	--self:initPhysicsBody()
end

function SnakeHeader:initPhysicsBody()
	local snakeBody = cc.PhysicsBody:createBox(self:getContentSize(),
        cc.PhysicsMaterial(COIN_RADIUS, COIN_FRICTION, COIN_ELASTICITY))
    snakeBody:setMass(COIN_MASS)
    self:setPhysicsBody(snakeBody)

   	snakeBody:setCategoryBitmask(1)
	snakeBody:setContactTestBitmask(1)
	snakeBody:setCollisionBitmask(1)
end

function SnakeHeader:setWalkDir(dir)
	self._dir = dir
end

function SnakeHeader:walk(dir)
	self._cellX, self._cellY = self:nextCell()
	local p = self:getPos()
	self:setPosition(p.x, p.y)
end

function SnakeHeader:getPos()
	local  p = app.Model:getPos(self._cellX, self._cellY)
	return cc.p(p.x, p.y)
end

function SnakeHeader:nextCell()
	curCellX = self._cellX
	curCellY = self._cellY
	dir = self._dir
	local nextCellX, nextCellY
	if dir == app.Model.WALK_DIR.UP then
		nextCellX = curCellX
		nextCellY = curCellY + 1
		if nextCellY > app.Model.maxCellY then
			nextCellY = app.Model.minCellY
		end
	elseif dir == app.Model.WALK_DIR.RIGHT then
		nextCellX = curCellX + 1
		nextCellY = curCellY
		if nextCellX > app.Model.maxCellX then
			nextCellX = app.Model.minCellX
		end
	elseif dir == app.Model.WALK_DIR.DOWN then
		nextCellX = curCellX
		nextCellY = curCellY - 1
		if nextCellY < app.Model.minCellY then
			nextCellY = app.Model.maxCellY
		end
	elseif dir == app.Model.WALK_DIR.LEFT then
		nextCellX = curCellX - 1
		nextCellY = curCellY
		if nextCellX < app.Model.minCellX then
			nextCellX = app.Model.maxCellX
		end
	end

	--print("nextCellX = " ..nextCellX .." nextCellY = " ..nextCellY)
	return nextCellX, nextCellY
end

function SnakeHeader:checkIsCollision()
	local tails = app.Model._snakeTail
	for i = 1, #tails do
		local tail = tails[i]
		local cellX = tail._cellX
		local cellY = tail._cellY

		if self._cellX == cellX and self._cellY == cellY then 
			app.isCollision = true
			return 
		end
	end
end

function SnakeHeader:checkIsEat()
	if self._cellX == app.spFood._cellX and self._cellY == app.spFood._cellY then
		app.isEated = true
		app.spFood:remove()
	end
end

function SnakeHeader:onEnter()

end

function SnakeHeader:onExit()

end



return SnakeHeader
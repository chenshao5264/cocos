--
-- Author: ChenShao
-- Date: 2016-06-04 15:59:07
--
local Model = class("Model")

Model.minCellX = 0
Model.minCellY = 0
Model.maxCellX = 14
Model.maxCellY = 14


Model.WALK_DIR = {
	UP = 0,
	RIGHT = 1,
	DOWN = 2,
	LEFT = 3
}



function Model:ctor()
	self._snake = {}

	self._snakeTail = {}
end

function Model:addSnakeHeader(newSnakeNode)
	self:clear()

	self._snake[#self._snake + 1] = newSnakeNode
end

function Model:addSnakeTail(newSnakeNode)
	local tail = self._snake[#self._snake]

	local tailCellX = tail._cellX
	local tailCellY = tail._cellY
	local tailDir = tail._dir
	local tailTag = tail._tag

	local newTailCellX, newTailCellY
	local newTailDir = tailDir
	local newTailTag = tailTag + 1

	if tailDir == Model.WALK_DIR.UP then
		newTailCellX = tailCellX
		newTailCellY = tailCellY - 1
	elseif tailDir == Model.WALK_DIR.RIGHT then
		newTailCellX = tailCellX - 1
		newTailCellY = tailCellY
	elseif tailDir == Model.WALK_DIR.DOWN then
		newTailCellX = tailCellX
		newTailCellY = tailCellY + 1
	elseif tailDir == Model.WALK_DIR.LEFT then
		newTailCellX = tailCellX + 1
		newTailCellY = tailCellY
	end

	newSnakeNode._cellX = newTailCellX
	newSnakeNode._cellY = newTailCellY
	newSnakeNode._dir = newTailDir
	newSnakeNode._tag = tailTag + 1

	--print("newSnakeNode._cellX = " ..newSnakeNode._cellX)
	--print("newSnakeNode._cellY = " ..newSnakeNode._cellY)
	--print("newSnakeNode._dir = " ..newSnakeNode._dir)
	--print("newSnakeNode._tag = " ..newSnakeNode._tag)

	self._snake[#self._snake + 1] = newSnakeNode
	self._snakeTail[#self._snakeTail + 1] = newSnakeNode
	--self:getFoodBornPos()
end

function Model:getFoodBornPos()
	math.randomseed(os.time())
	
	
	local cellX, cellY
	local flagX = true
	local flagY = true


	local cellXs = {}
	local cellYs = {}
	for i = 1, #self._snake do
		cellXs[#cellXs + 1] = self._snake[i]._cellX
		cellYs[#cellYs + 1] = self._snake[i]._cellY
	end

	math.random(15)
	while flagX do
		cellX = math.random(15) - 1 
		if cellXs[cellX] == nil then
			flagX = false
		end
	end

	math.random(15)
	while flagY do
		cellY = math.random(15) - 1 
		if cellYs[cellY] == nil then
			flagY = false
		end
	end
	
	print("cellX = " ..cellX .." cellY = " ..cellY)

	return cellX, cellY
end

function Model:clear()
	self._snake = {}
	self._snakeTail = {}
end

function Model:getPos(cellX, cellY)
	return cc.p(16 + 32 * cellX, 16 + 32 * cellY)
end

return Model
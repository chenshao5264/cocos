
app = {}
app.Model = require("app.model.Model").new()
app.runningScene = nil
scheduler  = require("framework.scheduler")

app.isCollision = false
app.isEated = false
app.spFood = nil

local snakeHeader = require("app.scenes.SnakeHeader")
local snakeTail = require("app.scenes.SnakeTail")
local food = require("app.scenes.TailPart")
local gameOverLayer = require("app.scenes.GameOverLayer")


local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
  -- return display.newPhysicsScene("MainScene")
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

function MainScene:ctor()
	app.runningScene = self
	self._isStart = false

  	self:addBgLayer()
  	self:initCtrlLayer()

  	self:createGameOverLayer()
  	--self:initPhysicsWorld()

 
  	
end



function MainScene:removeSnake()
	for _, node in pairs(app.Model._snake) do
		node:removeSelf()
	end 
end

function MainScene:removeFood()
	if app.spFood then
		app.spFood:removeSelf()
		app.spFood = nil
	end
end

function MainScene:clear()
	self:removeSnake()
	self:removeFood()
	app.Model:clear()

	app.isCollision = false
	app.isEated = false
	app.spFood = nil
end

function MainScene:reStart()
	self:clear()
	self:start()
end

function MainScene:start()
	

	self:createHeader()
	self:createFood()

	self._isStart = true
end

function MainScene:initPhysicsWorld()
	self.world = self:getPhysicsWorld()
    self.world:setGravity(cc.p(0, GRAVITY))

    local wallBox = display.newNode()
    wallBox:setAnchorPoint(cc.p(0.5, 0.5))

    local dp = cc.PhysicsBody:createEdgeBox(cc.size(display.width, display.width))
    wallBox:setPhysicsBody(dp)
    wallBox:setPosition(display.cx, display.cy +  140)
    self:addChild(wallBox)

    -- add debug node
     self:getPhysicsWorld():setDebugDrawMask(
         true and cc.PhysicsWorld.DEBUGDRAW_ALL or cc.PhysicsWorld.DEBUGDRAW_NONE)


    local contactListener =  cc.EventListenerPhysicsContact:create()
    contactListener:registerScriptHandler(function(contact)
    	print("123123")
    end, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(contactListener, self)
end

function MainScene:createFood()

	local cellX, cellY = app.Model:getFoodBornPos()

	local spFood = food.new(cellX, cellY)
	:addTo(self.spBgMain, 10)


	app.spFood = spFood
end



function MainScene:walk()
	self.scheduleWalk = scheduler.scheduleGlobal(function()
		if self._isStart == false then
			return
		end

		self._ctrlLayer._canTouch = true

		for i = #app.Model._snake, 1, -1 do
			local tail = app.Model._snake[i]
			local lastTail = app.Model._snake[i - 1]
			if lastTail then
				tail._cellX = lastTail._cellX
				tail._cellY = lastTail._cellY
				tail._dir = lastTail._dir
			end
			tail:walk()
		end
		

		

		app.spSnakeHeader:checkIsEat()
		if app.isEated then
			app.isEated = false
			local spSnakeTail = snakeTail.new()
			:addTo(self.spBgMain, 10)
			app.Model:addSnakeTail(spSnakeTail)
			spSnakeTail:updatePos()

			self:createFood()
		end

		app.spSnakeHeader:checkIsCollision()
		if app.isCollision then
			--scheduler.unscheduleGlobal(self.scheduleWalk)
			self._isStart = false
			self._layGameOver:showLayer()

		end
		
	end, 0.5)
end

function MainScene:createHeader()
 	local spSnakeHeader = snakeHeader.new()
   	:addTo(self.spBgMain, 10)
   	app.Model:addSnakeHeader(spSnakeHeader)
   	app.spSnakeHeader = spSnakeHeader

   	---[[
   	local spSnakeTail = snakeTail.new()
	:addTo(self.spBgMain, 10)
	app.Model:addSnakeTail(spSnakeTail)
	spSnakeTail:updatePos()
	--]]
end

function MainScene:createTail()
	local spSnakeNode = SnakeNode.new()
   	:addTo(self.spBgMain, 10)

   	app.Model:addSnakeNode(spSnakeNode)
   	spSnakeNode:updatePos()
end

function MainScene:createGameOverLayer()
	local layGameOver = gameOverLayer.new()
	layGameOver:addTo(self, 50)
	:pos(display.cx, display.cy + 50)

	self:clear()
	self._layGameOver = layGameOver
end

function MainScene:initCtrlLayer()
	local ctrlLayer = require("app.scenes.CtrlLayer").new()
	ctrlLayer:addTo(self)
	self._ctrlLayer = ctrlLayer
end

function MainScene:addBgLayer()
	self.spBgMain = display.newSprite("snake_bg.png")
	:addTo(self)
	:pos(display.cx, display.cy +  140)

	local spBgDown = display.newSprite("snake_bg_down.png")
	:addTo(self)
	:pos(display.cx, display.bottom + 100) 
end

function MainScene:onEnter()
	self:start()
	self:walk()
end

function MainScene:onExit()
end

return MainScene

local bump = require 'bump'
local pprint = require 'pprint'

-- Initialize Bump
local world = bump.newWorld()

X_SCALE = 0.5
Y_SCALE = 0.5

HIGH_FIVE_THRUST = 2000
GRAVITY = 4750

emitters = {}

JedMonster = {}
function JedMonster:new (o, x, y, speed, img)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.x = x or 600
  self.y = y or 100
  self.speed = speed or 150
  self.img = love.graphics.newImage("assets/jed.jpeg")
  return o
end

function JedMonster:move(dx, dy)
  self.x, self.y, cols, len = world:move(self, self.x + dx, self.y + dy)
end

JedHand = {}
function JedHand:new(o, x, y, speed)
  local o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.x = x or 500
  self.y = y or 100
  self.speed = speed or 150
  self.img = love.graphics.newImage("assets/highfive_right.png")
  self.x_velocity = 0
  self.active_collisions = false
  return o
end

function JedHand:move(dx, dy)
  self.x, self.y, cols, len = world:move(self, self.x + dx, self.y + dy)
  if len > 0 then
    slap:play()
    for _, col in ipairs(cols) do
      if self.active_collisions then
        print("have collided with " .. tostring(col.other))
      else
        print("have not collided with " .. tostring(col.other))
        local emitter = JedEmitter:new(nil, col["touch"].x, col["touch"].y)
        self.active_collisions = true
        table.insert(emitters, emitter)
      end
    end
  else
    self.active_collisions = false
  end
end

function JedHand:addCollision(item)
  self.active_collisions[item] = true
end

function JedHand:removeCollision(item)
  self.active_collisions[item] = false
end

function JedHand:isCollided(item)
  return self.active_collisions[item] ~= nil
end


Player = {}
function Player:new(o, x, y, score)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.x = x or 25
  self.y = y or 200
  self.speed = speed or 250
  self.score = score or 100
  self.img = love.graphics.newImage("assets/jed.jpeg")
  return o
end

function Player:move(dx, dy)
  self.x, self.y, cols, len = world:move(self, self.x + dx, self.y + dy)
end

PlayerHand = {}
function PlayerHand:new(o, x, y, speed)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.x = x or 200
  self.y = y or 230
  self.speed = speed or 250
  self.img = love.graphics.newImage("assets/highfive_left.png")
  self.x_velocity = 0
  return o
end

function PlayerHand:move(dx, dy)
  self.x, self.y, cols, len = world:move(self, self.x + dx, self.y + dy)
end


JedEmitter = { x = 0, y = 0 }
function JedEmitter:new (o,x,y)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.x = x or math.random(800)
  self.y = y or math.random(600)
  local img = love.graphics.newImage('assets/jed.jpeg')
  self.emitter = love.graphics.newParticleSystem(img, 32)
  self.emitter:setAreaSpread("none",0,0)
  self.emitter:setColors(255, 255, 255, 255, 255, 255, 255, 0)
  self.emitter:setDirection(-1.6)
  self.emitter:setEmissionRate(300)
  self.emitter:setEmitterLifetime(1.1)
  self.emitter:setLinearAcceleration(-500, 5000, 500, 0)
  self.emitter:setOffset(16, 16)
  self.emitter:setParticleLifetime(1, 3)
  self.emitter:setSizeVariation(0)
  self.emitter:setSizes(1)
  self.emitter:setSpeed(1500, 0)
  self.emitter:setSpread(4)
  return o
end


function love.load(dt)
  -- Set Initial Background Color
  love.graphics.setBackgroundColor(106, 239, 242)

  -- Instantiate Player
  player = Player:new()
  world:add(player, player.x, player.y, player.img:getWidth(), player.img:getHeight())

  -- Instantiate Player Hand
  player_hand = PlayerHand:new()
  world:add(player_hand, player_hand.x, player_hand.y, player_hand.img:getWidth(), player_hand.img:getHeight())

  -- Instantiate the Jeds and the Jed Hands
  jeds = {}
  hands = {}
  starting = 100
  for i=1, 5 do
    local jed = JedMonster:new()
    jed.y = starting
    jeds[i] = jed
    local hand = JedHand:new()
    hand.y = starting
    hands[i] = hand
    starting = starting - 200
    world:add(jeds[i], jeds[i].x, jeds[i].y, jeds[i].img:getWidth(), jeds[i].img:getHeight())
    world:add(hands[i], hands[i].x, hands[i].y, hands[i].img:getWidth(), hands[i].img:getHeight())
  end

  -- Get Window Height
  windowHeight = love.graphics.getHeight()

  -- Jed Particle System

  -- Load Sound Effects
  slap = love.audio.newSource("assets/slap.mp3", "static")
end

function love.draw(dt)
  -- Draw the Player
  love.graphics.draw(player.img, player.x, player.y)

  -- Draw the Jeds
  for _, jed in ipairs(jeds) do
    love.graphics.draw(jed.img, jed.x, jed.y)
  end

  -- Draw the Jed Hands
  for _, hand in ipairs(hands) do
    love.graphics.draw(hand.img, hand.x, hand.y)
  end

  -- Draw Player Hand
  love.graphics.draw(player_hand.img, player_hand.x, player_hand.y)

  -- Draw Jed Particles
  for i, emitter in ipairs(emitters) do
    love.graphics.draw(emitter.emitter, emitter.x, emitter.y, 0, 0.1, 0.1)
    print(i, emitter)
    if not emitter.emitter:isActive() then
      table.remove(emitters, i)
    end
  end
end

function love.update(dt)
  -- Update the Player Position
  if love.keyboard.isDown('w', 'up') then
    player:move(0, -(player.speed * dt))
    player_hand:move(0, -(player_hand.speed * dt))
  elseif love.keyboard.isDown('s', 'down') then
    player:move(0, player.speed * dt)
    player_hand:move(0, player_hand.speed * dt)
  end

  -- Start High Five
  if love.keyboard.isDown('space') then
    if player_hand.x_velocity == 0 then
      player_hand.x_velocity = HIGH_FIVE_THRUST
    end
  end

  -- Update High Five
  if player_hand.x_velocity ~= 0 then
    player_hand:move(player_hand.x_velocity * dt, 0)
    player_hand.x_velocity = player_hand.x_velocity - (GRAVITY * dt)
  end

  -- Reset Player Hand after High Five
  if player_hand.x < 200 then
    player_hand.x_velocity = 0
  end

  -- Update the position of the Jeds
  for _, jed in ipairs(jeds) do
    jed:move(0, jed.speed * dt)

    if jed.y > 600 then
      jed.y = -400
      world:update(jed, jed.x, jed.y)
    end
  end


  -- Update the position of the Jed Hands
  for _, hand in ipairs(hands) do
    hand:move(0, hand.speed * dt)

    -- Make them high five maybe
    if hand.x_velocity == 0 then
      if math.random(10) % 2 == 0 then
        hand.x_velocity = -HIGH_FIVE_THRUST
      end
    end

    -- Update High Five
    if hand.x_velocity ~= 0 then
      hand:move(hand.x_velocity * dt, 0)
      hand.x_velocity = hand.x_velocity + (GRAVITY * dt)
    end

    -- Reset Jed Hand after High Five
    if hand.x > 500 then
      hand.x_velocity = 0
    end

    if hand.y > 600 then
      hand.y = -400
      world:update(hand, hand.x, hand.y)
    end
  end

  -- Update Jed Particles
  for _, emitter in ipairs(emitters) do
    emitter.emitter:update(dt)
  end
end

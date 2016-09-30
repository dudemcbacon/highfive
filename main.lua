local bump = require 'bump'
local pprint = require 'pprint'

-- Initialize Bump
local world = bump.newWorld()

X_SCALE = 0.5
Y_SCALE = 0.5

HIGH_FIVE_THRUST = 2000
GRAVITY = 4750

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

function JedMonster:move_x(dx)
  self.x, self.y, cols, len = world:move(self, self.x + dx, self.y)
end

function JedMonster:move_y(dy)
  self.x, self.y, cols, len = world:move(self, self.x, self.y + dy)
end

JedHand = {}
function JedHand:new(o, x, y, speed)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.x = x or 500
  self.y = y or 100
  self.speed = speed or 150
  self.img = love.graphics.newImage("assets/highfive_right.png")
  self.x_velocity = 0
  return o
end

function JedHand:move(dx, dy)
  self.x, self.y, cols, len = world:move(self, self.x + dx, self.y + dy)
end

function JedHand:move_x(dx)
  self.x, self.y, cols, len = world:move(self, self.x + dx, self.y)
end

function JedHand:move_y(dy)
  self.x, self.y, cols, len = world:move(self, self.x, self.y + dy)
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

function Player:move_x(dx)
  self.x, self.y, cols, len = world:move(self, self.x + dx, self.y)
end

function Player:move_y(dy)
  self.x, self.y, cols, len = world:move(self, self.x, self.y + dy)
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

function PlayerHand:move_x(dx)
  self.x, self.y, cols, len = world:move(self, self.x + dx, self.y)
end

function PlayerHand:move_y(dy)
  self.x, self.y, cols, len = world:move(self, self.x, self.y + dy)
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
    jeds[i] = JedMonster:new()
    jeds[i].y = starting
    hands[i] = JedHand:new()
    hands[i].y = starting
    starting = starting - 200
    world:add(jeds[i], jeds[i].x, jeds[i].y, jeds[i].img:getWidth(), jeds[i].img:getHeight())
    world:add(hands[i], hands[i].x, hands[i].y, hands[i].img:getWidth(), hands[i].img:getHeight())
  end

  -- Get Window Height
  windowHeight = love.graphics.getHeight()

  -- Jed Particle System
  local img = love.graphics.newImage('assets/jed.jpeg')

  emitter = love.graphics.newParticleSystem(img, 32)
  emitter:setDirection(-1.6)
  emitter:setAreaSpread("none",0,0)
  emitter:setEmissionRate(10)
  emitter:setLinearAcceleration(-500, 10000, 500, 0)
  emitter:setParticleLifetime(3, 3)
  emitter:setSpeed(3000, 0)
  emitter:setSpread(2)
  emitter:setOffset(16, 16)
  emitter:setSizes(1)
  emitter:setSizeVariation(0)
  emitter:setColors(255, 255, 255, 255, 255, 255, 255, 0)
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
  love.graphics.draw(emitter, love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5, 0, 0.1, 0.1)
end

function love.update(dt)
  x, y, cols, len = world:move(player_hand, player_hand.x, player_hand.y)
  if len > 0 then
    --print(("player_hand collision: %d"):format(len))
  end

  -- Update the Player Position
  if love.keyboard.isDown('w', 'up') then
    player:move_y(-(player.speed * dt))
    player_hand:move_y(-(player_hand.speed * dt))
  elseif love.keyboard.isDown('s', 'down') then
    player:move_y(player.speed * dt)
    player_hand:move_y(player_hand.speed * dt)
  end

  -- Start High Five
  if love.keyboard.isDown('space') then
    if player_hand.x_velocity == 0 then
      print('jump')
      player_hand.x_velocity = HIGH_FIVE_THRUST
    end
  end

  -- Update High Five
  if player_hand.x_velocity ~= 0 then
    player_hand:move_x(player_hand.x_velocity * dt)
    player_hand.x_velocity = player_hand.x_velocity - (GRAVITY * dt)
  end

  -- Reset Player Hand after High Five
  if player_hand.x < 200 then
    player_hand.x_velocity = 0
  end

  -- Update the position of the Jeds
  for _, jed in ipairs(jeds) do
    jed:move_y(jed.speed * dt)

    if jed.y > 600 then
      jed.y = -400
      world:update(jed, jed.x, jed.y)
    end
  end


  -- Update the position of the Jed Hands
  for _, hand in ipairs(hands) do
    hand:move_y(hand.speed * dt)

    -- Make them high five maybe
    if hand.x_velocity == 0 then
      if math.random(10) % 2 == 0 then
        hand.x_velocity = -HIGH_FIVE_THRUST
        print(hand.x_velocity)
      end
    end

    -- Update High Five
    if hand.x_velocity ~= 0 then
      hand:move_x(hand.x_velocity * dt)
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
  emitter:update(dt)
end

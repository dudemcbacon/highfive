-- Initialize Bump
local bump = require 'bump'
local world = bump.newWorld()

X_SCALE = 0.5
Y_SCALE = 0.5

HIGH_FIVE_THRUST = 2000
GRAVITY = 4750

JedMonster = { x = 600, y = 100, speed = 150 }

function JedMonster:new (o, x, y, speed, img)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.x = x or 600
  self.y = y or 100
  self.speed = speed or 150
  self.img = love.graphics.newImage("jed.jpeg")
  return o
end

JedHand = { x = 100, y = 200, speed = 250 }

function JedHand:new(o, x, y, speed)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.x = x or 250
  self.y = y or 230
  self.speed = speed or 250
  self.img = love.graphics.newImage("highfive_right.png")
  self.x_velocity = 0
  return o
end


Player = { x = 100, y = 200, score = 100, speed = 250 }

function Player:new(o, x, y, score)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.x = x or 100
  self.y = y or 200
  self.speed = speed or 250
  self.score = score or 100
  self.img = love.graphics.newImage("jed.jpeg")
  return o
end

PlayerHand = { x = 100, y = 200, speed = 250 }

function PlayerHand:new(o, x, y, speed)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.x = x or 250
  self.y = y or 230
  self.speed = speed or 250
  self.img = love.graphics.newImage("highfive_left.png")
  self.x_velocity = 0
  return o
end

function love.load(dt)
  -- Set Initial Background Color
  love.graphics.setBackgroundColor(106, 239, 242)

  -- Instantiate Player
  player = Player:new()

  -- Instantiate Player Hand
  player_hand = PlayerHand:new()
  world:add(player_hand, player.x, player.y, player.img:getWidth(), player.img:getHeight())

  -- Instantiate the Jeds and the Jed Hands
  jeds = {}
  hands = {}
  starting = 100
  for i=1, 5 do
    print('load jed ' .. i .. ' at y ' .. starting )
    jeds[i] = JedMonster:new()
    jeds[i].y = starting
    starting = starting - 200
    print('jed ' .. jeds[i].y)
    hands[i] = JedHand:new()
    hands[i].x = jeds[i].x - 150
    world:add(hands[i], hands[i].x, hands[i].y, hands[i].img:getWidth(), hands[i].img:getHeight())
  end

  -- Get Window Height
  windowHeight = love.graphics.getHeight()
end

function love.draw(dt)
  -- Draw the Player
  love.graphics.draw(player.img, player.x, player.y, 0, X_SCALE, Y_SCALE)

  -- Draw the Jeds
  for i=1, 5 do
    love.graphics.draw(jeds[i].img, jeds[i].x, jeds[i].y, 0, X_SCALE, Y_SCALE)
    love.graphics.draw(hands[i].img, hands[i].x, (jeds[i].y - 25))
    world:move(hands[i], hands[i].x, hands[i].y)
  end

  -- Draw Player Hand
  love.graphics.draw(player_hand.img, player_hand.x, player_hand.y)
end

function love.update(dt)
  actualX, actualY, cols, len = world:move(player_hand, player_hand.x, player_hand.y)
  if len > 0 then
    print(("player_hand collision: %d"):format(len))
  else
    print("no player_hand collisions")
  end

  -- Update the Player Position
  if love.keyboard.isDown('w', 'up') then
    player.y = player.y - (player.speed * dt)
    player_hand.y = player_hand.y - (player_hand.speed * dt)
  elseif love.keyboard.isDown('s', 'down') then
    player.y = player.y + (player.speed * dt)
    player_hand.y = player_hand.y + (player_hand.speed * dt)
  end

  -- Start High Five
  if love.keyboard.isDown('space') then
    if player_hand.x_velocity == 0 then
      player_hand.x_velocity = HIGH_FIVE_THRUST
    end
  end

  -- Update High Five
  if player_hand.x_velocity ~= 0 then
    player_hand.x = player_hand.x + (player_hand.x_velocity * dt)
    player_hand.x_velocity = player_hand.x_velocity - (GRAVITY * dt)
  end

  -- Reset Player Hand after High Five
  if player_hand.x < 230 then
    player_hand.x_velocity = 0
    player_hand.x = 230
  end

  -- Update the position of the Jeds
  for i=1, 5 do
    jeds[i].y = jeds[i].y + (jeds[i].speed * dt)

    -- Jed is below the bottom of the screen
    if jeds[i].y > windowHeight then
      -- print('jed ' .. i .. ' is at the bottom, jed 5 is at ' .. jeds[5].y)
      jeds[i].y = -400
    end
  end
end

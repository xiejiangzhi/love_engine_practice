
world = nil
ball = {}
text = ""
persisting = 0
can_jump = true

ball2 = {}

function love.load()
  world = love.physics.newWorld(0, 0, true)
  world:setCallbacks(beginContact, endContact)

  ball.b = love.physics.newBody(world, 400, 300, 'dynamic')
  -- ball.b:setMass(0)
  ball.s = love.physics.newCircleShape(20)
  ball.f = love.physics.newFixture(ball.b, ball.s)
  ball.f:setRestitution(0.4)
  ball.f:setUserData('ball')

  ball2.b = love.physics.newBody(world, 500, 300, 'dynamic')
  -- ball.b:setMass(0)
  ball2.s = love.physics.newCircleShape(20)
  ball2.f = love.physics.newFixture(ball2.b, ball2.s)
  -- ball.f:setRestitution(0)
  ball2.f:setUserData('ball2')


  edge = {
    {'top', 400, -5, 850, 10}, 
    {'right', 805, 300, 10, 650}, 
    {'bottom', 400, 605, 850, 10}, 
    {'left', -5, 300, 10, 650}, 
  }
  for i, data in pairs(edge) do
    name, x, y, w, h = data[1], data[2], data[3], data[4], data[5]
    local item = {}
    item.b = love.physics.newBody(world, x, y, 'static')
    item.s = love.physics.newRectangleShape(w, h)
    item.f = love.physics.newFixture(item.b, item.s)
    item.f:setUserData(name)
  end
end

function love.update(dt)
  world:update(dt)

  if string.len(text) > 768 then text = "" end

  if can_jump then
    if love.keyboard.isDown('right') then
      ball.b:applyForce(1000, 0)
    end
    if love.keyboard.isDown('left') then
      ball.b:applyForce(-1000, 0)
    end

    if love.keyboard.isDown('up', 'space') then
      print("jump")
      can_jump = false
      ball.b:applyForce(0, -50000)
    end
  end
end

function love.draw()
  love.graphics.circle('line', ball.b:getX(), ball.b:getY(), ball.s:getRadius(), 20)
  love.graphics.circle('line', ball2.b:getX(), ball2.b:getY(), ball2.s:getRadius(), 20)
  love.graphics.print(text, 10, 10)
  love.graphics.print(love.timer.getFPS(), 600, 10)
end

function beginContact(a, b, coll)
  local player = nil
  local block = nil
  if a:getUserData() == 'ball' then player = a; block = b end
  if b:getUserData() == 'ball' then player = b; block = a end

  if player and block:getUserData() == 'bottom' then
    print("player contact bottom")
    print(player:getBody():getPosition())
    print(a:getUserData() .. " contact " .. b:getUserData())
    can_jump = true
  else
    print(a:getUserData() .. " contact " .. b:getUserData())
  end
end

function endContact(a, b, coll)
  persisting = 0

  local player = nil
  local block = nil
  if a:getUserData() == 'ball' then player = a; block = b end
  if b:getUserData() == 'ball' then player = b; block = a end

  if player and block:getUserData() == 'bottom' then
    print("player uncontact bottom")
    print(a:getUserData() .. " contact " .. b:getUserData())
    can_jump = false
  else
    print(a:getUserData() .. " contact " .. b:getUserData())
  end
end

function preSlove(a, b, coll)
  if can_jump == false then
    local player = nil
    local block = nil
    if a:getUserData() == 'ball' then player = a; block = b end
    if b:getUserData() == 'ball' then player = b; block = a end

    if player and block:getUserData() == 'bottom' then
      can_jump = true
    end
  end
end


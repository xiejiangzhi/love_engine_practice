local lightWorld = require 'lib'

local light_world, light_mouse

items = {}


function love.load()
  light_world = lightWorld({ambient = {15, 15, 31}})
  light_world.post_shader:addEffect('phosphor')

  light_mouse = light_world:newLight(0, 0, 200, 200, 200, 300)
  light_mouse:setSmooth(1.5)

  local l1 = light_world:newLight(200, 200, 256, 0, 0, 300)
  l1:setSmooth(1.5)
  local l2 = light_world:newLight(500, 600, 0, 256, 0, 300)
  l2:setSmooth(1.5)
  local l3 = light_world:newLight(650, 100, 0, 0, 256, 300)
  l3:setSmooth(1.5)

  local circle = {x = 256, y = 256, radius = 32}
  function circle:draw()
    love.graphics.setColor(256, 40, 40)
    love.graphics.circle('fill', self.x, self.y, self.radius)
  end
  circle.body = light_world:newCircle(circle.x, circle.y, circle.radius)
  table.insert(items, circle)

  local rect = {x = 512, y = 512, w = 64, h = 64}
  function rect:draw()
    love.graphics.setColor(40, 256, 40)
    love.graphics.rectangle('fill', self.x - rect.w / 2, self.y - rect.h / 2, self.w, self.h)
  end
  rect.body = light_world:newRectangle(rect.x, rect.y, rect.w, rect.h)
  table.insert(items, rect)

  local polygon = {x1 = 580, y1 = 200, x2 = 500, y2 = 270, x3 = 630, y3 = 270}
  function polygon:draw()
    love.graphics.setColor(40, 40, 256)
    love.graphics.polygon('fill', self.x1, self.y1, self.x2, self.y2, self.x3, self.y3)
  end
  polygon.body = light_world:newPolygon(
    polygon.x1, polygon.y1, polygon.x2, polygon.y2, polygon.x3, polygon.y3
  )
  table.insert(items, polygon)
end

function love.update(dt)
  light_world:update(dt)

  love.window.setTitle('Light and Shadow (FPS:' .. love.timer.getFPS() .. ')')
  light_mouse:setPosition(love.mouse.getX(), love.mouse.getY())
end

function love.draw()
  light_world:draw(function()
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    for i, item in pairs(items) do
      item:draw()
    end
  end)
end


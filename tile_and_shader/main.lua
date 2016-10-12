local Bump = require 'lib.bump'
local TileMap = require 'lib.tile_map'
local MapManager = require 'lib.map_manager'

local map = TileMap.newMap{cols = 1000, rows = 300, tile_w = 64, tile_h = 64}
local world = Bump.newWorld(map.tile_w)

local map_manager = MapManager.new(map, world, {})

local player = {
  name = 'player',
  speed = 700,
  x = 100, y = 100,
  w = map.tile_w, h = map.tile_h * 2
}


function love.load()
  map_manager:init()
  world:add(player, player.x, player.y, player.w, player.h)
  move_player(map.tile_w * 3, map.tile_h * 10)
end

function love.update(dt)
  update_player(dt)
  map_manager:update(dt)
  map:moveCamera(player.x, player.y)

  love.window.setTitle("TileMap FPS: " .. love.timer.getFPS())
end

function love.draw()
  love.graphics.setBackgroundColor(200, 200, 200)
  map_manager:draw()
  love.graphics.setShader()

  love.graphics.setColor(16, 8, 32)
  love.graphics.print(
    "move with Left, Right, Up and Down, destroy block with Space", 50, 30
  )
  love.graphics.print(
    math.floor(player.x / map.tile_w) .. ', ' .. math.floor(player.y / map.tile_h),
    50, 60
  )
  love.graphics.print("World body count: " .. world:countItems(), 50, 90)

  draw_player()
end

function draw_player()
  love.graphics.setColor(255, 200, 255)
  love.graphics.translate(player.x + map.x, player.y + map.y)

  love.graphics.rectangle('fill', 0, 0, player.w, player.h)
  love.graphics.setShader()
end

function update_player(dt)
  if love.keyboard.isDown('left') then
    move_player(player.x - player.speed * dt, player.y)
  elseif love.keyboard.isDown('right') then
    move_player(player.x + player.speed * dt, player.y)
  end

  if love.keyboard.isDown('up') then
    move_player(player.x, player.y - player.speed * dt)
  elseif love.keyboard.isDown('down') then
    move_player(player.x, player.y + player.speed * dt)
  end

  if love.keyboard.isDown('space') then
    local items, len = world:queryRect(player.x - 1, player.y - 1, player.w + 2, player.h + 2)
    if len > 0 then
      for i, item in pairs(items) do
        if item.name ~= 'edge' and item.name ~= 'player' then
          map_manager:remove_tile(item)
        end
      end
    end
  end
end

function move_player(x, y)
  local ax, ay, cols, len = world:move(player, x, y)
  player.x, player.y = ax, ay
end


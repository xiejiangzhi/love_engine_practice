local Bump = require 'bump'


local game_info = {
  w = 0, h = 0,
  cw = 0, ch = 0 -- center xxx
}

local tiles = {
  [-1] = {100, 100, 100},
  {256, 0, 0},
  {256, 256, 0},
  {256, 0, 256}, 
  {0, 256, 256},
  {0, 0, 256}
}

-- map[x][y]
--  type: 
--    nil: empty
--    -1: edge
--    >=1: tile
local map = {}
local map_info = {
  x = 0,
  y = 0,
  max_x = 0,
  max_y = 0,
  w = nil,
  h = nil,

  cols = 9000,
  rows = 300,
  tile_w = 50,
  tile_h = 50,

  draw_sx = 0, -- draw start point
  draw_sy = 0,
  draw_ex = 0, -- draw end point
  draw_ey = 0
}

local world = nil

local player = {
  name = 'player',
  speed = 700,
  x = 100, y = 100,
  w = 0, h = 0
}


function love.load()
  init_game()
  
  init_world()
  init_map()

  init_player()
end

function love.update(dt)
  update_player(dt)
  update_world(dt)
  love.window.setTitle("TileMap FPS: " .. love.timer.getFPS())
end

function love.draw()
  draw_map()
  love.graphics.setColor(16, 8, 32)
  love.graphics.print(
    "move with Left, Right, Up and Down, destroy block with Space", 50, 30
  )
  love.graphics.print(
    math.floor(player.x / map_info.tile_w) .. ', ' .. math.floor(player.y / map_info.tile_h),
    50, 60
  )
  love.graphics.print("World body count: " .. world:countItems(), 50, 90)

  draw_player()
end


function init_game()
  game_info.w = love.graphics.getWidth()
  game_info.h = love.graphics.getHeight()
  game_info.cw = game_info.w / 2
  game_info.ch = game_info.h / 2
end

function init_world()
  world = Bump.newWorld(map.tile_w)
end

function init_map()
  map_info.max_x = map_info.tile_w * map_info.cols - game_info.w
  map_info.max_y = map_info.tile_h * map_info.rows - game_info.h
  map_info.w = map_info.tile_w * map_info.cols
  map_info.h = map_info.tile_h * map_info.rows

  for y = 0, map_info.rows - 1 do
    for x = 0, map_info.cols - 1 do
      if not map[x] then map[x] = {} end

      local is_edge = x == 0 or y == 0 or x == (map_info.cols - 1) or y == (map_info.rows - 1)
      if (y > map_info.rows / 7) or is_edge then
        local tile = {map_x = x, map_y = y} 
        if is_edge then
          tile.texture_index = -1
          tile.name = 'edge'
        else
          tile.texture_index = math.random(#tiles)
          tile.name = 'tile' 
        end
        
        map[x][y] = tile
      end
    end
  end
end

function init_player()
  player.w = map_info.tile_w
  player.h = map_info.tile_h

  world:add(player, player.x, player.y, player.w, player.h)
end

function draw_map()
  love.graphics.translate(map_info.x, map_info.y)
  love.graphics.setBackgroundColor(200, 200, 200)

  each_visible_tiles(function(map_x, map_y, tile)
    if tile then
      local game_x = map_x * map_info.tile_w
      local game_y = map_y * map_info.tile_h

      love.graphics.setColor(unpack(tiles[tile.texture_index]))
      love.graphics.rectangle('fill', game_x, game_y, map_info.tile_w, map_info.tile_h)
    end
  end)

  love.graphics.origin()
end

function draw_player()
  love.graphics.setColor(256, 200, 256)
  love.graphics.translate(player.x + map_info.x, player.y + map_info.y)

  love.graphics.rectangle('fill', 0, 0, player.w, player.h)
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
          destroy_item_from_world(item)
          map[item.map_x][item.map_y] = nil
        end
      end
    end
  end
end

function update_map()
  map_info.x = math.min(math.max(game_info.w / 2 - player.x, -map_info.max_x), 0)
  map_info.y = math.min(math.max(game_info.h / 2 - player.y, -map_info.max_y), 0)
end

function update_world(dt)
  map_info.draw_sx = math.max(math.floor((player.x - game_info.w) / map_info.tile_w), 0)
  map_info.draw_sy = math.max(math.floor((player.y - game_info.h) / map_info.tile_h), 0)
  map_info.draw_ex = math.min(
    math.ceil((player.x + game_info.w) / map_info.tile_w), map_info.cols - 1
  )
  map_info.draw_ey = math.min(
    math.ceil((player.y + game_info.h) / map_info.tile_h), map_info.rows -1
  )

  update_world_items()
  update_map()
end

function each_visible_tiles(fn)
  for y = map_info.draw_sy, map_info.draw_ey do
    for x = map_info.draw_sx, map_info.draw_ex do
      local tile = map[x][y]
      fn(x, y, tile)
    end
  end
end

function update_world_items()
  each_visible_tiles(function(map_x, map_y, tile)
    if tile then
      local game_x = map_x * map_info.tile_w
      local game_y = map_y * map_info.tile_h
      tile.save_item = true

      -- create new items
      if not tile.visible then
        tile.visible = true
        world:add(tile, game_x, game_y, map_info.tile_w, map_info.tile_h)
      end
    end
  end)

  for i, item in pairs(world:getItems()) do
    if item.name ~= 'player' then
      if item.save_item then
        item.save_item = nil
      else
        -- destroy old item
        destroy_item_from_world(item)
      end
    end
  end
end

function destroy_item_from_world(item)
  world:remove(item)
  item.visible = nil
end

function move_player(x, y)
  local ax, ay, cols, len = world:move(player, x, y)
  player.x, player.y = ax, ay
end


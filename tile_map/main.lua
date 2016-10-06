tile_names = { 'Coal_01', 'Diamond_01', 'Gold_01', 'Iron_01', 'Sand_01', 'Stone_01' }
tiles_total = 0
tiles = {}

game_info = {w = 0, h = 0}

map = {}
map_info = {
  x = 0,
  y = 0,
  max_x = 0,
  max_y = 0,
  w = nil,
  h = nil,

  cols = 100,
  rows = 20,
  tile_w = 50,
  tile_h = 50,
  tile_scale_x = 1,
  tile_scale_y = 1,
  world = nil
}

player = {speed = 400, x = 100, y = 100, can_jump = true, w = 0, h = 0}


function love.load()
  init_game()
  
  init_tiles()
  init_world()
  init_map()

  init_player()
end

function love.update(dt)
  check_move(dt)
  update_world(dt)
  love.window.setTitle("TileMap FPS: " .. love.timer.getFPS())
end

function love.draw()
  draw_map()
  love.graphics.setColor(16, 8, 32)
  love.graphics.print(
    "move with Left and Right, jump with Space, destroy tile with Down", 50, 50
  )
  draw_player()
end


function init_game()
  game_info.w = love.graphics.getWidth()
  game_info.h = love.graphics.getHeight()
end

function init_tiles()
  for i, name in pairs(tile_names) do
    tiles_total = tiles_total + 1
    tiles[i] = love.graphics.newImage('assets/tiles/' .. name .. '.png')
  end
end

function init_world()
  love.physics.setMeter(map_info.tile_h / 2)
  map_info.world = love.physics.newWorld(0, 9.81 * map_info.tile_h, true)
  map_info.world:setCallbacks(beginContact, endContact)
end

function init_map()
  map_info.tile_scale_x = map_info.tile_w / tiles[1]:getWidth()
  map_info.tile_scale_y = map_info.tile_h / tiles[1]:getHeight()
  map_info.max_x = map_info.tile_w * map_info.cols - game_info.w
  map_info.max_y = map_info.tile_h * map_info.rows - game_info.h
  map_info.w = map_info.tile_w * map_info.cols
  map_info.h = map_info.tile_h * map_info.rows

  local halt_tile_w = map_info.tile_w / 2
  local halt_tile_h = map_info.tile_h / 2

  for y = 0, map_info.rows - 1 do
    for x = 0, map_info.cols - 1 do
      if not map[x] then map[x] = {} end
      local is_edge = x == 0 or y == 0 or x == (map_info.cols - 1) or y == (map_info.rows - 1)
      if (y > map_info.rows / 2) or is_edge then
        local game_x = x * map_info.tile_w
        local game_y = y * map_info.tile_h
        local tile = {} 
        if not is_edge then
          tile.type = math.random(tiles_total)
        end
        tile.body = love.physics.newBody(
          map_info.world, game_x + halt_tile_w, game_y + halt_tile_h
        )
        tile.shape = love.physics.newRectangleShape(map_info.tile_w, map_info.tile_h)
        tile.fixture = love.physics.newFixture(tile.body, tile.shape)
        if is_edge then
          tile.fixture:setUserData('edge')
          tile.body:setUserData({x = x, y = y, type = 'edge'})
        else
          tile.fixture:setUserData('tile')
          tile.body:setUserData({x = x, y = y, type = 'tile'})
        end
        map[x][y] = tile
      end
    end
  end
end

function init_player()
  player.w = map_info.tile_w
  player.h = map_info.tile_h * 2

  player.body = love.physics.newBody(map_info.world, player.x, player.y, 'dynamic')
  player.shape = love.physics.newRectangleShape(player.w, player.h)
  player.fixture = love.physics.newFixture(player.body, player.shape)
  player.fixture:setUserData('player')
end

function draw_map()
  love.graphics.translate(map_info.x, map_info.y)
  love.graphics.setBackgroundColor(150, 150, 250)

  for map_y = 0, map_info.rows - 1 do
    for map_x = 0, map_info.cols - 1 do
      local tile = map[map_x][map_y]

      if tile then
        local game_x = map_x * map_info.tile_w
        local game_y = map_y * map_info.tile_h
        if tile.type then
          love.graphics.draw(
            tiles[tile.type], game_x, game_y, 0, map_info.tile_scale_x, map_info.tile_scale_x
          )
        else
          love.graphics.setColor(100, 100, 100)
          love.graphics.rectangle('fill', game_x, game_y, map_info.tile_w, map_info.tile_h)
        end
      end
    end
  end 

  love.graphics.origin()
end

function draw_player()
  love.graphics.setColor(256, 200, 256)
  love.graphics.translate(player.x + map_info.x, player.y + map_info.y)
  love.graphics.rotate(player.body:getAngle())

  love.graphics.rectangle('fill', -player.w / 2, -player.h / 2, player.w, player.h)
  love.graphics.circle('line', 0, 0, 10)
  
  love.graphics.origin()
end

function check_move(dt)
  if player.can_jump then
    if love.keyboard.isDown('left') then
      player.body:applyLinearImpulse(-player.speed * dt * 9.18, 0)
    elseif love.keyboard.isDown('right') then
      player.body:applyLinearImpulse(player.speed * dt * 9.18, 0)
    end

    if love.keyboard.isDown('space') then
      player.can_jump = false
      player.body:applyForce(0, -130000)
    end

    if love.keyboard.isDown('down') then
      for _, contact in pairs(player.body:getContactList()) do
        for _, fixture in pairs({contact:getFixtures()}) do
          if fixture:getUserData() == 'tile' then
            local data = fixture:getBody():getUserData()
            local tile = map[data.x][data.y]
            if tile then
              tile.body:destroy()
              map[data.x][data.y] = nil
            end
          end
        end
      end
    end
  else
    if love.keyboard.isDown('left') then
      player.body:applyLinearImpulse(-player.speed * dt, 0)
    elseif love.keyboard.isDown('right') then
      player.body:applyLinearImpulse(player.speed * dt, 0)
    end
  end
end

function move_map()
  map_info.x = math.min(math.max(game_info.w / 2 - player.x, -map_info.max_x), 0)
  map_info.y = math.min(math.max(game_info.h / 2 - player.y, -map_info.max_y), 0)
end

function update_world(dt)
  map_info.world:update(dt)
  player.x = player.body:getX()
  player.y = player.body:getY()

  move_map()
end

function beginContact(a, b, coll)
  local pf = nil
  local bf = nil
  if b:getUserData() == 'player' then pf = b; bf = a end
  if a:getUserData() == 'player' then pf = a; bf = b end

  if pf and bf:getUserData() == 'tile' then
    player.can_jump = true
  end
end

function engContact(a, b, coll)
end


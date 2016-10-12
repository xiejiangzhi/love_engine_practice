local MapManager = {}
MapManager.__index = MapManager

local tiles_color = {
  [-1] = {100, 100, 100},
  {150, 150, 150},
  {0, 230, 0}, -- green
  {230, 230, 0}, -- yellow
  {0, 0, 230}, -- blue
  {255, 0, 255}, -- red
  {255, 0, 255} -- purple
}

local default_opts = {
  tiles_weight = {
    [-1] = 0,
    20000,
    2000,
    500,
    200,
    20,
    5
  }
}

local tile_shader_names = {
  [-1] = 'tile1',
  [1] = 'tile1',
  [2] = 'tile1',
  [3] = 'tile2',
  [4] = 'tile3',
  [5] = 'tile4',
  [6] = 'tile5'
}

function MapManager.new(tile_map, bump_world, opts)
  local manager = setmetatable({}, MapManager)
  manager.map = tile_map
  manager.world = bump_world

  for k, v in pairs(default_opts) do
    manager[k] = opts[k] or default_opts[k]
  end

  return manager
end

function MapManager:init()
  self:init_tiles()
  self:init_map()
  self:init_shaders()
end

function MapManager:init_tiles()
  self.tiles_mesh = {}
  self.tiles_weight_area = {}
  local tiles_weight_total = 0

  for i, val in pairs(tiles_color) do
    tiles_weight_total = tiles_weight_total + self.tiles_weight[i]
    self.tiles_weight_area[i] = tiles_weight_total
    local vertices = {
      {0, 0, 0, 0, unpack(val)},
      {self.map.tile_w, 0, 1, 0, unpack(val)},
      {self.map.tile_w, self.map.tile_h, 1, 1, unpack(val)},
      {0, self.map.tile_h, 0, 1, unpack(val)}
    }
    self.tiles_mesh[i] = love.graphics.newMesh(vertices, 'fan', 'static')
  end
end

function MapManager:init_map()
  for my = 1, self.map.rows do
    for mx = 1, self.map.cols do
      local is_edge = mx == 1 or my == 1 or mx == self.map.cols or my == self.map.rows

      if (my > self.map.rows / 7) or is_edge then
        local tile = {map_x = mx, map_y = my} 
        if is_edge then
          tile.texture_index = -1
          tile.name = 'edge'
        else
          tile.texture_index = self:random_tile_index(mx, my)
          tile.name = 'tile' 
        end
        
        self.map.data[mx][my] = tile
      end
    end
  end
end

function MapManager:init_shaders()
  self.shaders_time = 0
  self.tile_shaders = {}

  for index, name in pairs(tile_shader_names) do
    local effect = love.filesystem.read('shaders/' .. name .. '.glsl')
    print(name .. '.glsl')
    self.tile_shaders[index] = love.graphics.newShader(effect)
  end
end

function MapManager:update(dt)
  self:update_world_items()
  self:update_shaders(dt)
end

function MapManager:draw()
  love.graphics.push()
  love.graphics.translate(self.map.x, self.map.y)

  self.map:eachVisibleTiles(function(map_x, map_y, tile)
    if tile then
      local game_x = (map_x - 1) * self.map.tile_w
      local game_y = (map_y - 1) * self.map.tile_h

      love.graphics.setShader(self.tile_shaders[tile.texture_index])
      love.graphics.draw(self.tiles_mesh[tile.texture_index], game_x, game_y)
    end
  end)

  love.graphics.pop()
end


function MapManager:update_world_items()
  self.map:eachVisibleTiles(function(map_x, map_y, tile)
    if tile then
      local game_x = (map_x - 1) * self.map.tile_w
      local game_y = (map_y - 1) * self.map.tile_h
      tile.save_item = true

      -- create new items
      if not tile.visible then
        tile.visible = true
        self.world:add(tile, game_x, game_y, self.map.tile_w, self.map.tile_h)
      end
    end
  end)

  for i, item in pairs(self.world:getItems()) do
    if item.name ~= 'player' then
      if item.save_item then
        item.save_item = nil
      else
        -- destroy old item
        self.world:remove(item)
        item.visible = nil
      end
    end
  end
end

function MapManager:update_shaders(dt)
  self.shaders_time = self.shaders_time + dt
  for _, shader in pairs(self.tile_shaders) do
    shader:send('time', self.shaders_time)
  end
end

function MapManager:remove_tile(tile)
  self.world:remove(tile)
  self.map:remove(tile.map_x, tile.map_y)
end

function MapManager:random_tile_index(mx, my)
  local rand = math.random(1, self.tiles_weight_area[#self.tiles_weight_area])
  for i = 1, #self.tiles_weight_area do
    if rand <= self.tiles_weight_area[i] then
      return i
    end
  end
end

return MapManager


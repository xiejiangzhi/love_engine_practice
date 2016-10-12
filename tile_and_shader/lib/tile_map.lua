local TileMap = {}

local map_default_opts = {
  cols = 100,
  rows = 100,
  tile_w = 50,
  tile_h = 50,
}

MapMt = {}
MapMt.__index = MapMt

function TileMap.newMap(opts)
  local map = setmetatable({
    data = nil,
    x = 0, y = 0, -- pixel coord
    w = 0, h = 0, -- pixel size
    max_x = 0, max_y = 0, -- map coord
    visible_stx = 0, visible_sty = 0, -- start map coord of visible tile
    visible_etx = 0, visible_ety = 0, -- end map coord of visible tile
    camera_x = 0, camera_y = 0 -- camera coord of pixel coord
  }, MapMt)

  for i, key in pairs{'cols', 'rows', 'tile_w', 'tile_h'} do
    map[key] = opts[key] or map_default_opts[key]
  end

  map.w = map.tile_w * map.cols
  map.h = map.tile_h * map.rows

  map:reset()
  map:resize()
  map:moveCamera(map.camera_x, map.camera_y)

  return map
end

function MapMt:resize()
  self.screen_w = love.graphics.getWidth()
  self.screen_h = love.graphics.getHeight()

  self.max_x = self.tile_w * self.cols - self.screen_w
  self.max_y = self.tile_h * self.rows - self.screen_h
end

function MapMt:moveCamera(cx, cy)
  self.camera_x, self.camera_y = cx, cy
  self.x = math.min(math.max(self.screen_w / 2 - cx, -self.max_x), 0)
  self.y = math.min(math.max(self.screen_h / 2 - cy, -self.max_y), 0)

  self.visible_stx = math.max(math.floor(-self.x / self.tile_w - 1), 1)
  self.visible_sty = math.max(math.floor(-self.y / self.tile_h - 1), 1)
  self.visible_etx = math.min(math.ceil((self.screen_w - self.x) / self.tile_w + 1), self.cols)
  self.visible_ety = math.min(math.ceil((self.screen_h - self.y) / self.tile_h + 1), self.rows)
end

function MapMt:eachVisibleTiles(fn)
  for my = self.visible_sty, self.visible_ety do
    for mx = self.visible_stx, self.visible_etx do
      fn(mx, my, self.data[mx][my])
    end
  end
end

function MapMt:remove(map_x, map_y)
  self.data[map_x][map_y] = nil
end

function MapMt:reset()
  self.data = {}

  for i = 1, self.cols do
    self.data[i] = {}
  end
end

-- function MapMt:dump()
-- end

-- function MapMt:load()
-- end

return TileMap


img = {}
game = {}
shader = nil

function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

function love.load()
  game.w = love.graphics.getWidth()
  game.h = love.graphics.getHeight()

  img.picture = love.graphics.newImage('test.jpg')
  img.w = img.picture:getWidth()
  img.h = img.picture:getHeight()
  img.x = (game.w - img.w) / 2
  img.y = (game.h - img.h) / 2
  img.cx = img.x + img.w / 2
  img.cy = img.y + img.h / 2

  local pixelcode = [[
    extern vec3 dist_factor;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
      vec4 pixel = Texel(texture, texture_coords);
      number avg = (pixel.r + pixel.b + pixel.g) / 3.0;
      pixel.r = pixel.r + (avg - pixel.r) * dist_factor[0];
      pixel.g = pixel.g + (avg - pixel.g) * dist_factor[1];
      pixel.b = pixel.b + (avg - pixel.b) * dist_factor[2];
      return pixel;
    }
  ]]

  shader = love.graphics.newShader(pixelcode)
end

function love.update(dt)
  local x, y = love.mouse.getPosition()
  local base = game.w / 2
  img.r, img.g, img.b = math.max(math.min(math.dist(0, 0, x, y) / base, 1), 0),
    math.max(math.min(math.dist(game.w, 0, x, y) / base, 1), 0),
    math.max(math.min(math.dist(game.w, game.h, x, y) / base, 1), 0)

  shader:send("dist_factor", {img.r, img.g, img.b})
end

function love.draw()
  love.graphics.print("Picture R Factor: " .. (1 - img.r), 30, 30)
  love.graphics.print("Picture G Factor: " .. (1 - img.g), 30, 60)
  love.graphics.print("Picture B Factor: " .. (1 - img.b), 30, 90)

  love.graphics.setShader(shader)
  love.graphics.draw(img.picture, img.x, img.y)
end


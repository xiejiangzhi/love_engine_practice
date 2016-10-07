img = {}
game = {}

function love.load()
  img.picture = love.graphics.newImage('ball.png')
  img.w = img.picture:getWidth()
  img.h = img.picture:getHeight()
  game.w = love.graphics.getWidth()
  game.h = love.graphics.getHeight()

  local pixelcode = [[
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
      vec4 pixel = Texel(texture, texture_coords);
      number avg = (pixel.r + pixel.b + pixel.g) / 3.0;
      number factor = texture_coords.x;
      pixel.r = pixel.r + (avg - pixel.r) * factor;
      pixel.g = pixel.g + (avg - pixel.g) * factor;
      pixel.b = pixel.b + (avg - pixel.b) * factor;
      return pixel;
    }
  ]]

  shader = love.graphics.newShader(pixelcode)
end

function love.draw()
  love.graphics.setShader(shader)
  love.graphics.draw(img.picture, 10 + (img.w + 10) * 0, (game.h - img.h) / 2)

  love.graphics.setShader()
  love.graphics.draw(img.picture, 10 + (img.w + 10) * 1, (game.h - img.h) / 2)
end



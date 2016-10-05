time = 0

function love.load()
  local pixelcode = [[
    extern number time;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
      return vec4((1.0 + sin(time)) / 2.0, abs(cos(time)), abs(sin(time)), 1.0);
    }
  ]]

  local vertexcode = [[
    varying vec4 vpos;

    vec4 position(mat4 transform_projection, vec4 vertex_position) {
      vpos = vertex_position;
      return transform_projection * vertex_position;
    }
  ]]

  shader = love.graphics.newShader(pixelcode)
end

function love.update(dt)
  time = time + dt
  shader:send("time", time)
end

function love.draw()
  love.graphics.setColor(123, 255, 123)

  love.graphics.setShader(shader)
  love.graphics.rectangle("fill", 200, 300, 100, 100)

  love.graphics.setShader()
  love.graphics.rectangle("fill", 400, 300, 100, 100)
end



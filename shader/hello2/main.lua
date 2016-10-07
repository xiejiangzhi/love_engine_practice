local shader = nil
local time = 0
local game = {}


function love.load()
  game.w = love.graphics.getWidth()
  game.h = love.graphics.getHeight()

  shader = love.graphics.newShader([[
    extern number time;

    float speed = 0.3;
    float spread_dist = 0.7;
    float range = 0.4;

    float eff_dist(float st, vec2 coords) {
      return distance(vec2(abs(st), abs(st)), vec2(abs(coords.x), abs(coords.y)));
    }

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
      float st = sin(time * speed);
      vec2 coords = screen_coords.xy / love_ScreenSize.xy * 2.0 - vec2(1.0, 1.0);
      float dist = eff_dist(min(st, range), coords);
      float spread_rate = (spread_dist - dist) / spread_dist;

      float col = sin(time * 5 - dist * 20) * spread_rate;
      return vec4(0, 0, col, 1.0) * spread_rate;
    }
  ]])
end

function love.update(dt)
  time = time + dt
  shader:send('time', time)
end

function love.draw()
  love.graphics.setShader(shader)
  love.graphics.rectangle('fill', 0, 0, game.w, game.h)
  love.graphics.setShader()
end
 

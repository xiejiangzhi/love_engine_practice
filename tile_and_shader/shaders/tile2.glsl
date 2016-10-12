extern number time;

float speed = 1;

float life_edge = 0.1;
float top_edge = 0.13;
float right_edge = 0.1;
float bottom_edge = 0.1;

float spread_factory = 1.5;
float base_color = 0.8;
float max_light_dist = 0.4 / 2;

float rand_light_color(vec2 coords, vec4 pixel_color) {
  float st = sin(time * speed);
  float dist = distance(vec2((1 + st) / 2, 0.5 + st / 2), coords);

  if (dist > max_light_dist) {
    return base_color;
  } else {
    return base_color + (max_light_dist - dist);
  }
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec4 pixel_color = Texel(texture, texture_coords) * color;
  float color_factor = -1.0;
  bool is_block_color = false;

  float life_cf = texture_coords.x / life_edge;
  float right_cf = (1 - texture_coords.x) / right_edge;
  float top_cf = texture_coords.y / top_edge;
  float bottom_cf = (1 - texture_coords.y) / bottom_edge;

  if (texture_coords.x < life_edge) {
    color_factor = min(life_cf, min(top_cf, bottom_cf));
  } else if (texture_coords.x > 1 - right_edge) {
    color_factor = min(right_cf, min(top_cf, bottom_cf));
  } else if (texture_coords.y < top_edge) {
    color_factor = min(top_cf, min(life_cf, right_cf));
  } else if (texture_coords.y > 1 - bottom_edge) {
    color_factor = min(bottom_cf, min(life_cf, right_cf));
  } else {
    is_block_color = true;
    color_factor = rand_light_color(texture_coords, pixel_color);
  }

  if (color_factor < 0) {
    color_factor = base_color;
  } else {
    if (is_block_color) {
    } else {
      color_factor = max(0, color_factor / spread_factory) * base_color;
    }
  }

  return pixel_color * color_factor;
}

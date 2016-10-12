extern number time;

float speed = 0.7;
float min_size = 0.3;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  float st = sin(time * speed);
  float abs_st = abs(st);
  float dist = distance(vec2(0.5, 0.5), texture_coords) * 2;
  vec4 pixel_color = Texel(texture, texture_coords) * color;
  float color_factor;

  if (abs_st < min_size) {
    color_factor = 1 - (dist + abs_st);
  } else {
    color_factor = 1 - (dist + min_size);
  }

  return pixel_color * color_factor;
}


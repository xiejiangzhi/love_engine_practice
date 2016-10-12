extern number time;

float speed = 0.7;
float min_size = 0.3;
float edge = 0.07;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  float st = sin(time * speed);
  float abs_st = abs(st);
  float dist = distance(vec2(0.5, 0.5), texture_coords) * 2;
  vec4 pixel_color = Texel(texture, texture_coords) * color;
  float color_factor;

  if (
    texture_coords.x < edge || texture_coords.x > 1 - edge ||
    texture_coords.y < edge || texture_coords.y > 1 - edge
  ) {
    if (texture_coords.x < edge / 2 || texture_coords.y < edge / 2) {
      color_factor = 0.1;
    } else {
      color_factor = 0.5;
    }
  } else {
    if (abs_st < min_size) {
      color_factor = 1 - (dist + abs_st);
    } else {
      color_factor = 1 - (dist + min_size);
    }
  }

  return pixel_color * color_factor;
}

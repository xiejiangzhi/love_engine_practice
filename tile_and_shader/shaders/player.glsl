extern number time;

float speed = 0.3;

float eff_dist(float st, vec2 coords) {
  return distance(vec2(abs(st), abs(st)), vec2(abs(coords.x), abs(coords.y)));
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  float st = sin(time * speed);
  vec4 pixel_color = Texel(texture, texture_coords) * color;

  return pixel_color * st;
}

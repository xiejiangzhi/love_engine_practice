-- json = require('json')
debug = true

game_info = {width = nil, height = nil}

images = nil
images_quad = {player = nil, bullet = nil}

audios = {shoot = nil, explode = nil}
sound_data = nil

player = {x = 200, y = 710, speed = 200, width = nil, height = nil, img = nil, alive = true}
player_quad = nil
player_quad_viewport = nil

bullets = {}
bullet_info = {width = nil, height = nil, speed = 400}
shoot_interval = 0.5
last_shoot_time = shoot_interval

enemies = {}
enemy_info = {width = nil, height = nil, speed = 150}
enemy_interval = 0.5
last_enemy_time = enemy_interval

score = 0

function love.load(arg)
  game_info.width = love.graphics.getWidth()
  game_info.height = love.graphics.getHeight()

  images = love.graphics.newImage('assets/aircrafts.png')
  image_w = images:getWidth()
  image_h = images:getHeight()

  player.img = 'player'
  player.width = 110
  player.height = 92
  images_quad.player = love.graphics.newQuad(
    114, 193, player.width, player.height, image_w, image_h
  )

  bullet_info.width = 12
  bullet_info.height = 12
  images_quad.bullet = love.graphics.newQuad(
    492, 150, bullet_info.width, bullet_info.height, image_w, image_h
  )

  enemy_info.width = 94
  enemy_info.height = 76
  images_quad.enemy = love.graphics.newQuad(
    322, 618, enemy_info.width, enemy_info.height, image_w, image_h
  )

  audios.shoot = 'assets/shoot.mp3'
  audios.explode = 'assets/explode.mp3'
end

function love.update(dt)
  if love.keyboard.isDown('escape') then love.event.push('quit') end
  if love.keyboard.isDown('r') then
    score = 0
    player.alive = true
  end

  if player.alive then
    move_process(dt)
    bullet_process(dt) 
    enemy_process(dt)
  end
end

function love.draw()
  love.graphics.print(string.format("Score: %i", score), game_info.width / 2, 10)

  if player.alive then
    draw_player()
    draw_bullets()
    draw_enemies()
  else
    love.graphics.print("Press 'R' to restart", game_info.width / 2, game_info.height / 2)
  end

end

function draw_player()
  draw_image(player.img, player.x, player.y)
end

function draw_bullets()
  for i, bullet in ipairs(bullets) do
    draw_image(bullet.img, bullet.x, bullet.y)
  end 
end

function draw_enemies()
  for i, enemy in ipairs(enemies) do
    draw_image(enemy.img, enemy.x, enemy.y, 0)
  end 
end

-- Params:
--  name: required
--  x: required
--  y: required
--  orientation: options
--
function draw_image(name, x, y, ...)
  orientation = ... or 0
  love.graphics.draw(images, images_quad[name], x, y, orientation)
end


function move_process(dt)
  if love.keyboard.isDown('left', 'a') and player.x > 0 then
    player.x = player.x - (player.speed * dt)
  elseif love.keyboard.isDown('right', 'd') then
    if player.x < (game_info.width - player.width) then
      player.x = player.x + (player.speed * dt)
    end
  end
end

function bullet_process(dt)
  if last_shoot_time < shoot_interval then
    last_shoot_time = last_shoot_time + dt
  end

  if love.keyboard.isDown('space') and last_shoot_time >= shoot_interval then
    last_shoot_time = 0
    new_bullet = {x = player.x + player.width / 2, y = player.y, img = 'bullet'}
    play_audio(audios.shoot)
    table.insert(bullets, new_bullet)
  end

  for i, bullet in ipairs(bullets) do
    bullet.y = bullet.y - (bullet_info.speed * dt)

    for j, enemy in ipairs(enemies) do
      if check_collision(bullet.x, bullet.y, bullet_info.width, bullet_info.height, enemy.x, enemy.y, enemy_info.width, enemy_info.height) then
        table.remove(bullets, i)
        table.remove(enemies, j)
        score = score + 1
        play_audio(audios.explode)
      end
    end

    if bullet.y < 0 then
      table.remove(bullets, i)
    end
  end
end

function enemy_process(dt)
  if last_enemy_time < enemy_interval then
    last_enemy_time = last_enemy_time + dt
  end

  if last_enemy_time >= enemy_interval then
    last_enemy_time = 0
    rand_x = math.random(10, game_info.width - enemy_info.width - 10)
    new_enemy = {x = rand_x, y = -enemy_info.height, img = 'enemy'}
    table.insert(enemies, new_enemy)
  end

  for i, enemy in ipairs(enemies) do
    enemy.y = enemy.y + ((enemy_info.speed + score) * dt)

    if enemy.y > love.graphics.getHeight() + enemy_info.height + 10 then
      table.remove(enemies, i)
    end

    if check_collision(enemy.x, enemy.y, enemy_info.width, enemy_info.height, player.x, player.y, player.width, player.height) then
      play_audio(audios.explode)
      player.alive = false
      bullets = {}
      enemies = {}
    end
  end
end

function play_audio(audio_path)
  love.audio.newSource(audio_path):play()
end


function check_collision(x1, y1, w1, h1, x2, y2, w2, h2)
  return (
    x1 < x2 + w2 and
    x2 < x1 + w1 and
    y1 < y2 + h2 and
    y2 < y1 + h1
  )
end


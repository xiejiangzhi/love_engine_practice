
sound_info = {len = 2, rate = 44100, bits = 16, channel = 1}
sound_data = nil

game_info = {width = nil, height = nil}

audios = {a = nil, b = nil}


function love.load()
  game_info.width = love.graphics.getWidth()
  game_info.height = love.graphics.getHeight()

  audios.a = love.audio.newSource('assets/a.mp3')
  audios.b = love.audio.newSource('assets/b.mp3')

  sound_data = love.sound.newSoundData( 
    sound_info.len * sound_info.rate, sound_info.rate, sound_info.bits, sound_info.channel
  )

  osc = Oscillator(440)
  amplitude = 0.2

  for i = 0, (sound_info.len * sound_info.rate - 1) do
    sample = osc() * amplitude
    print(i, sample)
    sound_data:setSample(i, sample)
  end

  audios.a:play()
  audios.b:play()
  love.audio.newSource(sound_data):play()
end

function love.update()
  if love.keyboard.isDown('escape') then love.event.push('quit') end
end

function love.draw()
  last_point = {x = 0, y = game_info.height / 2}
  for i = 0, game_info.width do
    amplitude = sound_data:getSample(i)
    new_point = {x = i, y = game_info.height / 2 + amplitude * 100}
    love.graphics.line(last_point.x, last_point.y, new_point.x, new_point.y)
    last_point = new_point
  end
end


function Oscillator(freq)
  local phase = 0
  return function()
    phase = phase + 2 * math.pi / sound_info.rate
    if phase >= 2 * math.pi then phase = phase - 2 * math.pi end
    return math.sin(freq * phase)
  end
end



function love.load()
  width, height = love.graphics.getDimensions()
  local vertices = {
    {
      0, 0,
      0, 0,
      255, 0, 0
    },
    {
      width, 0,
      1, 0,
      0, 255, 0
    },
    {
      width, height,
      1, 1,
      0, 0, 255
    },
    {
      0, height,
      0, 1,
      255, 255, 0
    }
  }

  mesh = love.graphics.newMesh(vertices, 'fan')
end

function love.draw()
  love.graphics.draw(mesh, 0, 0)
end


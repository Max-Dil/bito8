_G.love = love
local bito8 = require("bito8")

local player = {
    x = 100,
    y = 100,
    image = nil,
    angle = 0
}
function love.load()
    player.image = bito8.imageConvertor("player.png")
end

function love.update(dt)
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        player.x = player.x - 60 * dt
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        player.x = player.x + 60 * dt
    end
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        player.y = player.y - 60 * dt
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        player.y = player.y + 60 * dt
    end

    player.angle = player.angle + 2 * dt
end

function love.draw()
    bito8.graphics.clear(0, 0, 0)
    
    bito8.graphics.setColor(255, 255, 255)
    bito8.graphics.scale(1)
    bito8.graphics.text(10, 10, "FPS: "..love.timer.getFPS())
    
    bito8.graphics.push()
    bito8.graphics.setColor(255, 255, 0)
    bito8.graphics.scale(2)
    bito8.graphics.rotate(player.angle)
    bito8.graphics.image(player.x, player.y, player.image)
    bito8.graphics.pop()
    
    bito8.graphics.push()
    bito8.graphics.setColor(255, 0, 0)
    bito8.graphics.rectangle(200, 150, 50, 50, false)
    bito8.graphics.pop()

    bito8.graphics.fill(210, 160, {0, 255, 0})

    bito8.graphics.setColor(0, 255, 0)
    bito8.graphics.line(0, 0, 400, 300)

    bito8.graphics.push()
    bito8.graphics.setColor(255, 255, 255)
    bito8.graphics.circle(100, 100, 50, true)
    bito8.graphics.pop()

    bito8.draw()
end
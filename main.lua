_G.love = love
local bito8 = require("bito8")

local player = {
    x = 100,
    y = 100,
    image = nil
}
function love.load()
    -- Load an image
    player.image = bito8.imageConvertor("player.png")
end

function love.update(dt)
    -- Game logic goes here
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
end

function love.draw()
    -- Clear screen with black
    bito8.graphics.clear(0, 0, 0)
    
    -- Draw FPS counter
    bito8.graphics.drawText(10, 10, "FPS: "..love.timer.getFPS(), {255, 255, 255}, 1)
    
    -- Draw player
    bito8.graphics.drawImage(player.x, player.y, player.image, 2)
    
    -- Draw a rectangle
    bito8.graphics.drawRectangle(200, 150, 50, 50, {255, 0, 0})
    bito8.graphics.fill(210, 160, {0, 255, 0})
    
    -- Draw a line
    bito8.graphics.drawLine(0, 0, 400, 300, {0, 255, 0})

    bito8.graphics.drawCircle(100, 100, 50, {255, 255, 255}, true)
    
    -- Render everything
    bito8.draw()
end
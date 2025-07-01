love.graphics.setDefaultFilter( 'nearest', 'nearest', 1 )

local DRAW
DRAW = setmetatable({
    width = 400,
    height = 300,
    PIXELS = {},
}, {__call = function ()
    DRAW.draw()
end})
DRAW.IMAGE = love.image.newImageData(DRAW.width, DRAW.height)
DRAW.scale = math.min(love.graphics.getWidth() / DRAW.width, love.graphics.getHeight() / DRAW.height)

for y = 1, DRAW.height, 1 do
    DRAW.PIXELS[y] = {}
    for x = 1, DRAW.width, 1 do
        DRAW.PIXELS[y][x] = {0,0,0}
    end
end

DRAW.__setResolution = function (width, height)
    DRAW.width, DRAW.height = width, height
    DRAW.PIXELS = {}
    for y = 1, DRAW.height, 1 do
        DRAW.PIXELS[y] = {}
        for x = 1, DRAW.width, 1 do
            DRAW.PIXELS[y][x] = {0,0,0}
        end
    end
    DRAW.IMAGE = love.image.newImageData(DRAW.width, DRAW.height)
    DRAW.scale = math.min(love.graphics.getWidth() / DRAW.width, love.graphics.getHeight() / DRAW.height)
end

DRAW.drawPixel = function(x, y, color)
    if x >= 1 and x <= DRAW.width and
       y >= 1 and y <= DRAW.height then
        DRAW.PIXELS[y][x] = color
    else
        -- print(string.format("Invalid pixel coordinates (%d, %d)", x, y))
    end
end

DRAW.getPixel = function(x, y)
    if x >= 1 and x <= DRAW.width and
       y >= 1 and y <= DRAW.height then
        return DRAW.PIXELS[y][x]
    end
    return {0, 0, 0}
end

DRAW.draw = function ()
    for y = 1, DRAW.height do
        for x = 1, DRAW.width do
            local color = DRAW.PIXELS[y][x] or {0, 0, 0}
            DRAW.IMAGE:setPixel(x-1, y-1, color[1]/255, color[2]/255, color[3]/255, 1)
        end
    end

    local image = love.graphics.newImage(DRAW.IMAGE)
    love.graphics.draw(image, 0, 0, 0, DRAW.scale, DRAW.scale)
    image:release()
end

return DRAW
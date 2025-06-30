local path = ...

local bito = {
    draw = require(... .. ".draw"),
    graphics = require(... .. ".graphics"),
    imageConvertor = require(... .. ".imageConvertor"),
}
bito.graphics.DRAW = bito.draw

bito.setSize = function (width, height)
    bito.draw.__setResolution(width, height)
end

return bito
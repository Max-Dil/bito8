local function imageToPixelArray(path)
    local output = {}
    local imageData = love.image.newImageData(path)
    local f = math.floor
    imageData:mapPixel(function(x, y, r, g, b, a)
      x, y = x + 1, y + 1
      output[x] = output[x] or {}
      output[x][y] = {
        f(r * 255 + 0.5), 
        f(g * 255 + 0.5), 
        f(b * 255 + 0.5), 
      }
      return r, g, b, a
    end)
    imageData:release()

    return output
end

return imageToPixelArray
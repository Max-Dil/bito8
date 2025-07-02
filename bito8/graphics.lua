local graphics = {}
local math_floor = math.floor

graphics.drawState = {
    color = {255, 255, 255},
    scale = 1,
    angle = 0,
    stack = {},
    translation = {0, 0}
}

graphics.push = function()
    table.insert(graphics.drawState.stack, {
        color = {graphics.drawState.color[1], graphics.drawState.color[2], graphics.drawState.color[3]},
        scale = graphics.drawState.scale,
        angle = graphics.drawState.angle,
    })
end

graphics.pop = function()
    local state = table.remove(graphics.drawState.stack)
    if state then
        graphics.drawState.color = state.color
        graphics.drawState.scale = state.scale
        graphics.drawState.angle = state.angle
    else
        print("Warning: Attempted to pop from an empty drawing state stack.")
    end
end

graphics.setColor = function(r, g, b)
    graphics.drawState.color = {r, g, b}
end

graphics.translation = function (x, y)
    graphics.drawState.translation[1] = math_floor(x)
    graphics.drawState.translation[2] = math_floor(y)
end

graphics.scale = function(scale_factor)
    graphics.drawState.scale = math_floor(scale_factor)
end

graphics.rotate = function(angle)
    graphics.drawState.angle = math_floor(angle)
end

graphics.pixel = function(x, y)
    x, y = math_floor(x), math_floor(y)
    graphics.DRAW.drawPixel(x, y, graphics.drawState.color)
end

graphics.line = function(x1, y1, x2, y2)
    x1, y1 = math_floor(x1) + graphics.drawState.translation[1], math_floor(y1) + graphics.drawState.translation[2]
    x2, y2 = math_floor(x2) + graphics.drawState.translation[1], math_floor(y2) + graphics.drawState.translation[2]
    
    local dx = math.abs(x2 - x1)
    local dy = math.abs(y2 - y1)
    local sx = x1 < x2 and 1 or -1
    local sy = y1 < y2 and 1 or -1
    local err = dx - dy
    
    local rotation_angle = graphics.drawState.angle
    local cos_angle = math.cos(rotation_angle)
    local sin_angle = math.sin(rotation_angle)
    
    local center_x, center_y = (x1 + x2) / 2, (y1 + y2) / 2

    while true do
        local translated_x = x1 - center_x
        local translated_y = y1 - center_y
        local rotated_x = translated_x * cos_angle - translated_y * sin_angle
        local rotated_y = translated_x * sin_angle + translated_y * cos_angle
        
        local final_x = math_floor(rotated_x + center_x)
        local final_y = math_floor(rotated_y + center_y)

        if final_x >= 1 and final_x <= graphics.DRAW.width and
           final_y >= 1 and final_y <= graphics.DRAW.height then
            graphics.DRAW.drawPixel(final_x, final_y, graphics.drawState.color)
        end

        if x1 == x2 and y1 == y2 then break end
    
        local e2 = 2 * err
        if e2 > -dy then
            err = err - dy
            x1 = x1 + sx
        end
        if e2 < dx then
            err = err + dx
            y1 = y1 + sy
        end
    end
end

graphics.clear = function (r, g, b)
    r,g, b = r or 0, g or 0, b or 0
    for y = 1, graphics.DRAW.height do
        for x = 1, graphics.DRAW.width do
            graphics.DRAW.PIXELS[y][x] = {r, g, b}
        end
    end
end

graphics.circle = function(x, y, radius, filled)
    x, y = math_floor(x) + graphics.drawState.translation[1], math_floor(y) + graphics.drawState.translation[2]
    radius = math_floor(radius) * graphics.drawState.scale
    filled = filled or false

    local function plotPoints(cx, cy, x_offset, y_offset)
        if filled then
            graphics.line(cx - x_offset, cy + y_offset, cx + x_offset, cy + y_offset)
            graphics.line(cx - x_offset, cy - y_offset, cx + x_offset, cy - y_offset)
            graphics.line(cx - y_offset, cy + x_offset, cx + y_offset, cy + x_offset)
            graphics.line(cx - y_offset, cy - x_offset, cx + y_offset, cy - x_offset)
        else
            graphics.drawPixel(cx + x_offset, cy + y_offset)
            graphics.drawPixel(cx - x_offset, cy + y_offset)
            graphics.drawPixel(cx + x_offset, cy - y_offset)
            graphics.drawPixel(cx - x_offset, cy - y_offset)
            graphics.drawPixel(cx + y_offset, cy + x_offset)
            graphics.drawPixel(cx - y_offset, cy + x_offset)
            graphics.drawPixel(cx + y_offset, cy - x_offset)
            graphics.drawPixel(cx - y_offset, cy - x_offset)
        end
    end

    local x_offset = 0
    local y_offset = radius
    local d = 3 - 2 * radius

    plotPoints(x, y, x_offset, y_offset)
    while y_offset >= x_offset do
        x_offset = x_offset + 1
        if d > 0 then
            y_offset = y_offset - 1
            d = d + 4 * (x_offset - y_offset) + 10
        else
            d = d + 4 * x_offset + 6
        end
        plotPoints(x, y, x_offset, y_offset)
    end
end

graphics.image = function(x, y, data)
    x, y = math_floor(x) + graphics.drawState.translation[1], math_floor(y) + graphics.drawState.translation[2]
    local scale = graphics.drawState.scale

    local scaled_width = #data * scale
    local scaled_height = #data[1] * scale

    for dx = 0, scaled_width - 1 do
        for dy = 0, scaled_height - 1 do
            local src_x = math.floor(dx / scale) + 1
            local src_y = math.floor(dy / scale) + 1

            if src_x >= 1 and src_x <= #data and
               src_y >= 1 and src_y <= #data[1] then

                local px = x + dx
                local py = y + dy

                local center_x = x + scaled_width / 2
                local center_y = y + scaled_height / 2
                local translated_x = px - center_x
                local translated_y = py - center_y
                local cos_angle = math.cos(graphics.drawState.angle)
                local sin_angle = math.sin(graphics.drawState.angle)
                local rotated_x = translated_x * cos_angle - translated_y * sin_angle
                local rotated_y = translated_x * sin_angle + translated_y * cos_angle
                
                local final_x = math_floor(rotated_x + center_x)
                local final_y = math_floor(rotated_y + center_y)

                if final_x >= 1 and final_x <= graphics.DRAW.width and
                   final_y >= 1 and final_y <= graphics.DRAW.height then
                    graphics.DRAW.drawPixel(final_x, final_y, data[src_x][src_y])
                end
            end
        end
    end
end

graphics.rectangle = function(x, y, width, height, isFilled)
    x, y = math_floor(x) + graphics.drawState.translation[1], math_floor(y) + graphics.drawState.translation[2]
    width, height = math_floor(width * graphics.drawState.scale), math_floor(height * graphics.drawState.scale)
    
    if not isFilled then
        for dy = 0, height - 1 do
            for dx = 0, width - 1 do
                local px = x + dx
                local py = y + dy
                local center_x = x + width / 2
                local center_y = y + height / 2
                local translated_x = px - center_x
                local translated_y = py - center_y
                local cos_angle = math.cos(graphics.drawState.angle)
                local sin_angle = math.sin(graphics.drawState.angle)
                local rotated_x = translated_x * cos_angle - translated_y * sin_angle
                local rotated_y = translated_x * sin_angle + translated_y * cos_angle
                
                local final_x = math_floor(rotated_x + center_x)
                local final_y = math_floor(rotated_y + center_y)

                if final_x >= 1 and final_x <= graphics.DRAW.width and
                   final_y >= 1 and final_y <= graphics.DRAW.height then
                    graphics.DRAW.drawPixel(final_x, final_y, graphics.drawState.color)
                end
            end
        end
    else
        for dx = 0, width - 1 do
            local px = x + dx
            local py_top = y
            local py_bottom = y + height - 1

            local center_x = x + width / 2
            local center_y = y + height / 2

            local translated_x_top = px - center_x
            local translated_y_top = py_top - center_y
            local rotated_x_top = translated_x_top * math.cos(graphics.drawState.angle) - translated_y_top * math.sin(graphics.drawState.angle)
            local rotated_y_top = translated_x_top * math.sin(graphics.drawState.angle) + translated_y_top * math.cos(graphics.drawState.angle)
            local final_x_top = math_floor(rotated_x_top + center_x)
            local final_y_top = math_floor(rotated_y_top + center_y)
            if final_x_top >= 1 and final_x_top <= graphics.DRAW.width and
               final_y_top >= 1 and final_y_top <= graphics.DRAW.height then
                graphics.DRAW.drawPixel(final_x_top, final_y_top, graphics.drawState.color)
            end

            local translated_x_bottom = px - center_x
            local translated_y_bottom = py_bottom - center_y
            local rotated_x_bottom = translated_x_bottom * math.cos(graphics.drawState.angle) - translated_y_bottom * math.sin(graphics.drawState.angle)
            local rotated_y_bottom = translated_x_bottom * math.sin(graphics.drawState.angle) + translated_y_bottom * math.cos(graphics.drawState.angle)
            local final_x_bottom = math_floor(rotated_x_bottom + center_x)
            local final_y_bottom = math_floor(rotated_y_bottom + center_y)
            if final_x_bottom >= 1 and final_x_bottom <= graphics.DRAW.width and
               final_y_bottom >= 1 and final_y_bottom <= graphics.DRAW.height then
                graphics.DRAW.drawPixel(final_x_bottom, final_y_bottom, graphics.drawState.color)
            end
        end

        for dy = 1, height - 2 do
            local px_left = x
            local px_right = x + width - 1
            local py = y + dy

            local center_x = x + width / 2
            local center_y = y + height / 2

            local translated_x_left = px_left - center_x
            local translated_y_left = py - center_y
            local rotated_x_left = translated_x_left * math.cos(graphics.drawState.angle) - translated_y_left * math.sin(graphics.drawState.angle)
            local rotated_y_left = translated_x_left * math.sin(graphics.drawState.angle) + translated_y_left * math.cos(graphics.drawState.angle)
            local final_x_left = math_floor(rotated_x_left + center_x)
            local final_y_left = math_floor(rotated_y_left + center_y)
            if final_x_left >= 1 and final_x_left <= graphics.DRAW.width and
               final_y_left >= 1 and final_y_left <= graphics.DRAW.height then
                graphics.DRAW.drawPixel(final_x_left, final_y_left, graphics.drawState.color)
            end

            local translated_x_right = px_right - center_x
            local translated_y_right = py - center_y
            local rotated_x_right = translated_x_right * math.cos(graphics.drawState.angle) - translated_y_right * math.sin(graphics.drawState.angle)
            local rotated_y_right = translated_x_right * math.sin(graphics.drawState.angle) + translated_y_right * math.cos(graphics.drawState.angle)
            local final_x_right = math_floor(rotated_x_right + center_x)
            local final_y_right = math_floor(rotated_y_right + center_y)
            if final_x_right >= 1 and final_x_right <= graphics.DRAW.width and
               final_y_right >= 1 and final_y_right <= graphics.DRAW.height then
                graphics.DRAW.drawPixel(final_x_right, final_y_right, graphics.drawState.color)
            end
        end
    end
end

graphics.fill = function(x, y, color)
    x, y = math_floor(x) + graphics.drawState.translation[1], math_floor(y) + graphics.drawState.translation[2]

    if x < 1 or x > graphics.DRAW.width or y < 1 or y > graphics.DRAW.height then
        return
    end

    local target_color = graphics.DRAW.getPixel(x, y)
    
    if target_color[1] == color[1] and 
       target_color[2] == color[2] and 
       target_color[3] == color[3] then
        return
    end

    local queue = {{x, y}}
    local visited = {}
    
    local function isVisited(px, py)
        return visited[px] and visited[px][py]
    end
    
    local function setVisited(px, py)
        visited[px] = visited[px] or {}
        visited[px][py] = true
    end

    while #queue > 0 do
        local current = table.remove(queue, 1)
        local cx, cy = current[1], current[2]
        
        if not isVisited(cx, cy) then
            local pixel_color = graphics.DRAW.getPixel(cx, cy)
            if pixel_color[1] == target_color[1] and 
               pixel_color[2] == target_color[2] and 
               pixel_color[3] == target_color[3] then
                
                graphics.DRAW.drawPixel(cx, cy, color)
                setVisited(cx, cy)

                if cx > 1 then table.insert(queue, {cx - 1, cy}) end
                if cx < graphics.DRAW.width then table.insert(queue, {cx + 1, cy}) end
                if cy > 1 then table.insert(queue, {cx, cy - 1}) end
                if cy < graphics.DRAW.height then table.insert(queue, {cx, cy + 1}) end
            end
        end
    end
end

local font = {
    -- Цифры
    ['0'] = {0x0E, 0x11, 0x13, 0x15, 0x19, 0x11, 0x0E},
    ['1'] = {0x04, 0x0C, 0x04, 0x04, 0x04, 0x04, 0x0E},
    ['2'] = {0x0E, 0x11, 0x01, 0x02, 0x04, 0x08, 0x1F},
    ['3'] = {0x0E, 0x11, 0x01, 0x06, 0x01, 0x11, 0x0E},
    ['4'] = {0x02, 0x06, 0x0A, 0x12, 0x1F, 0x02, 0x02},
    ['5'] = {0x1F, 0x10, 0x1E, 0x01, 0x01, 0x11, 0x0E},
    ['6'] = {0x06, 0x08, 0x10, 0x1E, 0x11, 0x11, 0x0E},
    ['7'] = {0x1F, 0x01, 0x02, 0x04, 0x08, 0x08, 0x08},
    ['8'] = {0x0E, 0x11, 0x11, 0x0E, 0x11, 0x11, 0x0E},
    ['9'] = {0x0E, 0x11, 0x11, 0x0F, 0x01, 0x02, 0x0C},
    
    -- Заглавные буквы
    ['A'] = {0x04, 0x0A, 0x11, 0x11, 0x1F, 0x11, 0x11},
    ['B'] = {0x1E, 0x11, 0x11, 0x1E, 0x11, 0x11, 0x1E},
    ['C'] = {0x0E, 0x11, 0x10, 0x10, 0x10, 0x11, 0x0E},
    ['D'] = {0x1E, 0x11, 0x11, 0x11, 0x11, 0x11, 0x1E},
    ['E'] = {0x1F, 0x10, 0x10, 0x1E, 0x10, 0x10, 0x1F},
    ['F'] = {0x1F, 0x10, 0x10, 0x1E, 0x10, 0x10, 0x10},
    ['G'] = {0x0E, 0x11, 0x10, 0x17, 0x11, 0x11, 0x0F},
    ['H'] = {0x11, 0x11, 0x11, 0x1F, 0x11, 0x11, 0x11},
    ['I'] = {0x0E, 0x04, 0x04, 0x04, 0x04, 0x04, 0x0E},
    ['J'] = {0x07, 0x02, 0x02, 0x02, 0x02, 0x12, 0x0C},
    ['K'] = {0x11, 0x12, 0x14, 0x18, 0x14, 0x12, 0x11},
    ['L'] = {0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x1F},
    ['M'] = {0x11, 0x1B, 0x15, 0x15, 0x11, 0x11, 0x11},
    ['N'] = {0x11, 0x19, 0x15, 0x13, 0x11, 0x11, 0x11},
    ['O'] = {0x0E, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0E},
    ['P'] = {0x1E, 0x11, 0x11, 0x1E, 0x10, 0x10, 0x10},
    ['Q'] = {0x0E, 0x11, 0x11, 0x11, 0x15, 0x12, 0x0D},
    ['R'] = {0x1E, 0x11, 0x11, 0x1E, 0x14, 0x12, 0x11},
    ['S'] = {0x0F, 0x10, 0x10, 0x0E, 0x01, 0x01, 0x1E},
    ['T'] = {0x1F, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04},
    ['U'] = {0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0E},
    ['V'] = {0x11, 0x11, 0x11, 0x11, 0x0A, 0x0A, 0x04},
    ['W'] = {0x11, 0x11, 0x11, 0x15, 0x15, 0x1B, 0x11},
    ['X'] = {0x11, 0x11, 0x0A, 0x04, 0x0A, 0x11, 0x11},
    ['Y'] = {0x11, 0x11, 0x0A, 0x04, 0x04, 0x04, 0x04},
    ['Z'] = {0x1F, 0x01, 0x02, 0x04, 0x08, 0x10, 0x1F},
    
    -- Строчные буквы (немного уменьшенные)
    ['a'] = {0x00, 0x00, 0x0E, 0x01, 0x0F, 0x11, 0x0F},
    ['b'] = {0x10, 0x10, 0x16, 0x19, 0x11, 0x11, 0x1E},
    ['c'] = {0x00, 0x00, 0x0E, 0x11, 0x10, 0x11, 0x0E},
    ['d'] = {0x01, 0x01, 0x0D, 0x13, 0x11, 0x11, 0x0F},
    ['e'] = {0x00, 0x00, 0x0E, 0x11, 0x1F, 0x10, 0x0E},
    ['f'] = {0x06, 0x09, 0x08, 0x1C, 0x08, 0x08, 0x08},
    ['g'] = {0x00, 0x0F, 0x11, 0x11, 0x0F, 0x01, 0x0E},
    ['h'] = {0x10, 0x10, 0x16, 0x19, 0x11, 0x11, 0x11},
    ['i'] = {0x04, 0x00, 0x0C, 0x04, 0x04, 0x04, 0x0E},
    ['j'] = {0x02, 0x00, 0x06, 0x02, 0x02, 0x12, 0x0C},
    ['k'] = {0x10, 0x10, 0x12, 0x14, 0x18, 0x14, 0x12},
    ['l'] = {0x0C, 0x04, 0x04, 0x04, 0x04, 0x04, 0x0E},
    ['m'] = {0x00, 0x00, 0x1A, 0x15, 0x15, 0x11, 0x11},
    ['n'] = {0x00, 0x00, 0x16, 0x19, 0x11, 0x11, 0x11},
    ['o'] = {0x00, 0x00, 0x0E, 0x11, 0x11, 0x11, 0x0E},
    ['p'] = {0x00, 0x00, 0x1E, 0x11, 0x1E, 0x10, 0x10},
    ['q'] = {0x00, 0x0D, 0x13, 0x11, 0x0F, 0x01, 0x01},
    ['r'] = {0x00, 0x00, 0x16, 0x19, 0x10, 0x10, 0x10},
    ['s'] = {0x00, 0x00, 0x0F, 0x10, 0x0E, 0x01, 0x1E},
    ['t'] = {0x08, 0x08, 0x1C, 0x08, 0x08, 0x09, 0x06},
    ['u'] = {0x00, 0x00, 0x11, 0x11, 0x11, 0x13, 0x0D},
    ['v'] = {0x00, 0x00, 0x11, 0x11, 0x11, 0x0A, 0x04},
    ['w'] = {0x00, 0x00, 0x11, 0x11, 0x15, 0x15, 0x0A},
    ['x'] = {0x00, 0x00, 0x11, 0x0A, 0x04, 0x0A, 0x11},
    ['y'] = {0x00, 0x11, 0x11, 0x0F, 0x01, 0x11, 0x0E},
    ['z'] = {0x00, 0x00, 0x1F, 0x02, 0x04, 0x08, 0x1F},
    
    -- Символы
    [' '] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00},
    ['.'] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04},
    [','] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x04},
    [':'] = {0x00, 0x00, 0x04, 0x00, 0x04, 0x00, 0x00},
    ['!'] = {0x04, 0x04, 0x04, 0x04, 0x04, 0x00, 0x04},
    ['?'] = {0x0E, 0x11, 0x01, 0x02, 0x04, 0x00, 0x04},
    ['-'] = {0x00, 0x00, 0x00, 0x1F, 0x00, 0x00, 0x00},
    ['_'] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1F},
    ['+'] = {0x00, 0x04, 0x04, 0x1F, 0x04, 0x04, 0x00},
    ['/'] = {0x00, 0x01, 0x02, 0x04, 0x08, 0x10, 0x00},
    ['\\']= {0x00, 0x10, 0x08, 0x04, 0x02, 0x01, 0x00},
    ['('] = {0x02, 0x04, 0x08, 0x08, 0x08, 0x04, 0x02},
    [')'] = {0x08, 0x04, 0x02, 0x02, 0x02, 0x04, 0x08},
    ['['] = {0x0E, 0x08, 0x08, 0x08, 0x08, 0x08, 0x0E},
    [']'] = {0x0E, 0x02, 0x02, 0x02, 0x02, 0x02, 0x0E},
    ['{'] = {0x06, 0x08, 0x08, 0x10, 0x08, 0x08, 0x06},
    ['}'] = {0x0C, 0x02, 0x02, 0x01, 0x02, 0x02, 0x0C},
    ['<'] = {0x02, 0x04, 0x08, 0x10, 0x08, 0x04, 0x02},
    ['>'] = {0x08, 0x04, 0x02, 0x01, 0x02, 0x04, 0x08},
    ['='] = {0x00, 0x00, 0x1F, 0x00, 0x1F, 0x00, 0x00},
    ['@'] = {0x0E, 0x11, 0x17, 0x15, 0x17, 0x10, 0x0E},
    ['#'] = {0x0A, 0x0A, 0x1F, 0x0A, 0x1F, 0x0A, 0x0A},
    ['$'] = {0x04, 0x0F, 0x14, 0x0E, 0x05, 0x1E, 0x04},
    ['%'] = {0x18, 0x19, 0x02, 0x04, 0x08, 0x13, 0x03},
    ['^'] = {0x04, 0x0A, 0x11, 0x00, 0x00, 0x00, 0x00},
    ['&'] = {0x0C, 0x12, 0x14, 0x08, 0x15, 0x12, 0x0D},
    ['*'] = {0x00, 0x04, 0x15, 0x0E, 0x15, 0x04, 0x00},
    ['"'] = {0x0A, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00},
    ['\'']= {0x04, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00},
    ['~'] = {0x00, 0x00, 0x0A, 0x15, 0x00, 0x00, 0x00},
    ['`'] = {0x08, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00},
    ['|'] = {0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04},
    ['°'] = {0x0E, 0x0A, 0x0E, 0x00, 0x00, 0x00, 0x00},
    ['↑'] = {0x04, 0x0E, 0x1F, 0x04, 0x04, 0x04, 0x04},
    ['↓'] = {0x04, 0x04, 0x04, 0x04, 0x1F, 0x0E, 0x04},
    ['←'] = {0x00, 0x04, 0x08, 0x1F, 0x08, 0x04, 0x00},
    ['→'] = {0x00, 0x04, 0x02, 0x1F, 0x02, 0x04, 0x00},

    -- Русские заглавные буквы
    ['А'] = {0x04, 0x0A, 0x11, 0x11, 0x1F, 0x11, 0x11},
    ['Б'] = {0x1F, 0x10, 0x10, 0x1E, 0x11, 0x11, 0x1E},
    ['В'] = {0x1E, 0x11, 0x11, 0x1E, 0x11, 0x11, 0x1E},
    ['Г'] = {0x1F, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10},
    ['Д'] = {0x06, 0x0A, 0x0A, 0x0A, 0x12, 0x1F, 0x11},
    ['Е'] = {0x1F, 0x10, 0x10, 0x1E, 0x10, 0x10, 0x1F},
    ['Ж'] = {0x15, 0x15, 0x15, 0x0E, 0x15, 0x15, 0x15},
    ['З'] = {0x0E, 0x11, 0x01, 0x06, 0x01, 0x11, 0x0E},
    ['И'] = {0x11, 0x11, 0x13, 0x15, 0x19, 0x11, 0x11},
    ['Й'] = {0x15, 0x11, 0x13, 0x15, 0x19, 0x11, 0x11},
    ['К'] = {0x11, 0x12, 0x14, 0x18, 0x14, 0x12, 0x11},
    ['Л'] = {0x07, 0x09, 0x09, 0x09, 0x09, 0x11, 0x11},
    ['М'] = {0x11, 0x1B, 0x15, 0x15, 0x11, 0x11, 0x11},
    ['Н'] = {0x11, 0x11, 0x11, 0x1F, 0x11, 0x11, 0x11},
    ['О'] = {0x0E, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0E},
    ['П'] = {0x1F, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11},
    ['Р'] = {0x1E, 0x11, 0x11, 0x1E, 0x10, 0x10, 0x10},
    ['С'] = {0x0E, 0x11, 0x10, 0x10, 0x10, 0x11, 0x0E},
    ['Т'] = {0x1F, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04},
    ['У'] = {0x11, 0x11, 0x11, 0x0F, 0x01, 0x11, 0x0E},
    ['Ф'] = {0x0E, 0x15, 0x15, 0x15, 0x0E, 0x04, 0x04},
    ['Х'] = {0x11, 0x11, 0x0A, 0x04, 0x0A, 0x11, 0x11},
    ['Ц'] = {0x11, 0x11, 0x11, 0x11, 0x11, 0x1F, 0x01},
    ['Ч'] = {0x11, 0x11, 0x11, 0x0F, 0x01, 0x01, 0x01},
    ['Ш'] = {0x11, 0x11, 0x11, 0x15, 0x15, 0x15, 0x1F},
    ['Щ'] = {0x11, 0x11, 0x11, 0x15, 0x15, 0x1F, 0x01},
    ['Ъ'] = {0x18, 0x08, 0x08, 0x0E, 0x09, 0x09, 0x0E},
    ['Ы'] = {0x11, 0x11, 0x11, 0x1D, 0x13, 0x13, 0x1D},
    ['Ь'] = {0x10, 0x10, 0x10, 0x1E, 0x11, 0x11, 0x1E},
    ['Э'] = {0x0E, 0x11, 0x01, 0x07, 0x01, 0x11, 0x0E},
    ['Ю'] = {0x17, 0x19, 0x19, 0x1D, 0x19, 0x19, 0x17},
    ['Я'] = {0x0F, 0x11, 0x11, 0x0F, 0x05, 0x09, 0x11},

    -- Русские строчные буквы
    ['а'] = {0x00, 0x00, 0x0E, 0x01, 0x0F, 0x11, 0x0F},
    ['б'] = {0x00, 0x0F, 0x10, 0x1E, 0x11, 0x11, 0x0E},
    ['в'] = {0x00, 0x1E, 0x11, 0x1E, 0x11, 0x11, 0x1E},
    ['г'] = {0x00, 0x1E, 0x10, 0x10, 0x10, 0x10, 0x10},
    ['д'] = {0x00, 0x06, 0x0A, 0x0A, 0x12, 0x1F, 0x11},
    ['е'] = {0x00, 0x00, 0x0E, 0x11, 0x1F, 0x10, 0x0E},
    ['ж'] = {0x00, 0x15, 0x15, 0x0E, 0x15, 0x15, 0x15},
    ['з'] = {0x00, 0x0E, 0x11, 0x02, 0x04, 0x11, 0x0E},
    ['и'] = {0x00, 0x11, 0x13, 0x15, 0x19, 0x11, 0x11},
    ['й'] = {0x0A, 0x11, 0x13, 0x15, 0x19, 0x11, 0x11},
    ['к'] = {0x00, 0x11, 0x12, 0x14, 0x18, 0x14, 0x12},
    ['л'] = {0x00, 0x07, 0x09, 0x09, 0x09, 0x11, 0x11},
    ['м'] = {0x00, 0x11, 0x1B, 0x15, 0x11, 0x11, 0x11},
    ['н'] = {0x00, 0x11, 0x11, 0x1F, 0x11, 0x11, 0x11},
    ['о'] = {0x00, 0x00, 0x0E, 0x11, 0x11, 0x11, 0x0E},
    ['п'] = {0x00, 0x1F, 0x11, 0x11, 0x11, 0x11, 0x11},
    ['р'] = {0x00, 0x1E, 0x11, 0x11, 0x1E, 0x10, 0x10},
    ['с'] = {0x00, 0x00, 0x0E, 0x10, 0x10, 0x11, 0x0E},
    ['т'] = {0x00, 0x1F, 0x04, 0x04, 0x04, 0x04, 0x04},
    ['у'] = {0x00, 0x11, 0x11, 0x0F, 0x01, 0x11, 0x0E},
    ['ф'] = {0x00, 0x04, 0x0E, 0x15, 0x15, 0x0E, 0x04},
    ['х'] = {0x00, 0x11, 0x0A, 0x04, 0x0A, 0x11, 0x11},
    ['ц'] = {0x00, 0x11, 0x11, 0x11, 0x11, 0x1F, 0x01},
    ['ч'] = {0x00, 0x11, 0x11, 0x0F, 0x01, 0x01, 0x01},
    ['ш'] = {0x00, 0x11, 0x11, 0x15, 0x15, 0x15, 0x1F},
    ['щ'] = {0x00, 0x11, 0x11, 0x15, 0x15, 0x1F, 0x01},
    ['ъ'] = {0x00, 0x18, 0x08, 0x0E, 0x09, 0x09, 0x0E},
    ['ы'] = {0x00, 0x11, 0x11, 0x1D, 0x13, 0x13, 0x1D},
    ['ь'] = {0x00, 0x10, 0x10, 0x1E, 0x11, 0x11, 0x1E},
    ['э'] = {0x00, 0x0E, 0x11, 0x03, 0x01, 0x11, 0x0E},
    ['ю'] = {0x00, 0x12, 0x15, 0x15, 0x1D, 0x15, 0x12},
    ['я'] = {0x00, 0x0F, 0x11, 0x0F, 0x05, 0x09, 0x11},
}

local utf8 = require("utf8")
graphics.font = font

graphics.setFont = function(custom_font)
    if type(custom_font) == "table" then
        graphics.font = custom_font
    else
        print("Warning: setFont expects a font table")
    end
end

graphics.text = function(x, y, text)
    x, y = math_floor(x) + graphics.drawState.translation[1], math_floor(y) + graphics.drawState.translation[2]
    local scale = graphics.drawState.scale
    local color = graphics.drawState.color

    if graphics.drawState.translation then
        x = x + graphics.drawState.translation[1]
        y = y + graphics.drawState.translation[2]
    end

    local char_width = 5 * scale
    local char_spacing = 1 * scale
    local line_height = 8 * scale

    local lines = {}
    for line in text:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    
    for line_num, line in ipairs(lines) do
        local current_y = y + (line_num - 1) * line_height

        if current_y + 7*scale <= graphics.DRAW.height then
            local chars = {}
            for p, c in utf8.codes(line) do
                table.insert(chars, utf8.char(c))
            end

            for i, char in ipairs(chars) do
                local glyph = graphics.font[char] or graphics.font['?']
                local current_x = x + (i - 1) * (char_width + char_spacing)

                if current_x + char_width > 0 and current_x <= graphics.DRAW.width then
                    for row = 1, 7 do
                        local row_data = glyph[row] or 0

                        for col = 0, 4 do
                            if bit.band(row_data, bit.lshift(1, 4 - col)) ~= 0 then
                                for sy = 0, scale - 1 do
                                    for sx = 0, scale - 1 do
                                        local px = current_x + col * scale + sx
                                        local py = current_y + (row - 1) * scale + sy
                                        
                                        local center_x = x + (i - 1) * (char_width + char_spacing) + char_width/2
                                        local center_y = y + (line_num - 1) * line_height + line_height/2
                                        local translated_x = px - center_x
                                        local translated_y = py - center_y
                                        local cos_angle = math.cos(graphics.drawState.angle)
                                        local sin_angle = math.sin(graphics.drawState.angle)
                                        local rotated_x = translated_x * cos_angle - translated_y * sin_angle
                                        local rotated_y = translated_x * sin_angle + translated_y * cos_angle
                                        
                                        local final_x = math_floor(rotated_x + center_x)
                                        local final_y = math_floor(rotated_y + center_y)

                                        if final_x >= 1 and final_x <= graphics.DRAW.width and
                                           final_y >= 1 and final_y <= graphics.DRAW.height then
                                            graphics.DRAW.drawPixel(final_x, final_y, color)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                if current_x + char_width > graphics.DRAW.width then
                    break
                end
            end
        end
    end
end

return graphics
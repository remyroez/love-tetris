
local class = require 'middleclass'
local lume = require 'lume'

-- 基底クラス
local Tetrimino = require 'Tetrimino'

-- ステージ クラス
local Stage = class('Stage', Tetrimino)

-- 初期化
function Stage:initialize(t)
    Tetrimino.initialize(self, t)
end

-- 破棄
function Stage:destroy()
    Tetrimino.destroy(self)
end

-- 更新
function Stage:update(dt)
    Tetrimino.update(self, dt)
end

-- 描画
function Stage:draw()
    Tetrimino.draw(self)
end

-- ブロックのマージ
function Stage:merge(x, y, colorArray)
    x = x or 0
    y = y or 0
    if colorArray == nil then return false end
    if x < 0 then return false end
    if y < 0 then return false end

    local w, h = Tetrimino.getArrayDimensions(colorArray, true)

    -- 高さ拡張
    local height = y + h
    if height > #self.colorArray then
        while height >= #self.colorArray do
            table.insert(self.colorArray, {})
        end
    end

    -- 幅拡張
    local width = x + w
    if width > #self.colorArray[1] then
        for v, line in ipairs(self.colorArray) do
            while width >= #line do
                table.insert(line, false)
            end
        end
    end

    -- マージ
    for v, line in ipairs(self.colorArray) do
        for h, color in ipairs(line) do
            local tx, ty = h - 1, v - 1
            if (tx >= x) and (ty >= y) and (tx < width) and (ty < height) then
                local i, j = tx - x + 1, ty - y + 1
                if colorArray[j][i] then
                    line[h] = colorArray[j][i]
                end
            end
        end
    end

    return true
end

-- スコア計算
function Stage:score()
    local lines = {}

    print(self.width, self.height)

    for v, line in ipairs(self.colorArray) do
        local valid = 0
        for h, color in ipairs(line) do
            if color then
                valid = valid + 1
            end
        end
        if valid > 0 and valid == #line then
            table.insert(lines, v)
        end
    end

    for i = 1, #lines do
        table.remove(self.colorArray, lines[#lines - i + 1])
    end

    for i = 1, #lines do
        table.insert(self.colorArray, 1, Tetrimino.makeLine(self.width))
    end

    return #lines
end

return Stage


local class = require 'middleclass'
local lume = require 'lume'

-- 基底クラス
local Entity = require 'Entity'

-- テトリミノ クラス
local Tetrimino = class('Tetrimino', Entity)
Tetrimino:include(require 'SpriteRenderer')

-- スプライト名
Tetrimino.static.spriteNames = {
    black = "tileBlack_15.png",
    blue = "tileBlue_15.png",
    green = "tileGreen_15.png",
    grey = "tileGrey_15.png",
    orange = "tileOrange_14.png",
    pink = "tilePink_15.png",
    red = "tileRed_15.png",
    yellow = "tileYellow_15.png",
}

-- 色
Tetrimino.static.colors = lume.keys(Tetrimino.spriteNames)

-- 配列
Tetrimino.static.arrays = {
    I = {
        { true, true, true, true, },
    },
    O = {
        { true, true, },
        { true, true, },
    },
    S = {
        { false, true, true },
        { true, true, false },
    },
    Z = {
        { true, true, false },
        { false, true, true },
    },
    J = {
        { true, false, false },
        { true, true, true },
    },
    L = {
        { false, false, true },
        { true, true, true },
    },
    T = {
        { false, true, false },
        { true, true, true },
    },
}

-- 配列名
Tetrimino.static.arrayNames = lume.keys(Tetrimino.arrays)

-- カラー配列の作成
function Tetrimino.static.makeColorArray(array, color)
    array = array or Tetrimino.arrays.I
    color = color or 'red'

    local t = {}
    for v, line in ipairs(array) do
        local l = {}
        for h, block in ipairs(line) do
            table.insert(l, block and color or false)
        end
        table.insert(t, l)
    end
    return t
end

-- 配列の作成
function Tetrimino.static.makeArray(width, height, color)
    width = width or 0
    height = height or 1
    if color == nil then
        color = false
    end

    local t = {}
    for i = 1, height do
        local l = {}
        for j = 1, width do
            table.insert(l, color)
        end
        table.insert(t, l)
    end
    return t
end

-- 初期化
function Tetrimino:initialize(t)
    Entity.initialize(self)

    -- SpriteRenderer 初期化
    self:initializeSpriteRenderer(t.spriteSheet)

    self.x = t.x or 0
    self.y = t.y or 0
    self.rotation = t.rotation or 0
    self.scale = t.scale or 1
    self.blockWidth, self.blockHeight = self:getSpriteSize(Tetrimino.spriteNames[t.color or 'red'])
    self.colorArray = t.colorArray or Tetrimino.makeColorArray(t.array, t.color)
end

-- 破棄
function Tetrimino:destroy()
end

-- 更新
function Tetrimino:update(dt)
end

-- 描画
function Tetrimino:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.scale(self.scale)
    love.graphics.rotate(self.rotation)
    local x, y = 0, 0
    for v, line in ipairs(self.colorArray) do
        for h, color in ipairs(line) do
            if color then
                self:drawBlock(x, y, color)
            end
            x = x + self.blockWidth
        end
        x = 0
        y = y + self.blockHeight
    end
    love.graphics.pop()
end

-- ブロックの描画
function Tetrimino:drawBlock(x, y, color)
    x = x or self.x or 0
    y = y or self.y or 0
    color = color or 'red'
    self:drawSprite(Tetrimino.spriteNames[color], x, y)
end

-- ブロックのマージ
function Tetrimino:merge(x, y, colorArray)
    x = x or 0
    y = y or 0
    if colorArray == nil then return false end
    if x < 0 then return false end
    if y < 0 then return false end

    -- 高さ拡張
    local height = y + #colorArray
    if height > #self.colorArray then
        while height >= #self.colorArray do
            table.insert(self.colorArray, {})
        end
    end

    -- 幅拡張
    local width = x + #colorArray[1]
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

return Tetrimino

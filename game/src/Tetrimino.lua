
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
        { false, false, false, false, },
        { true, true, true, true, },
        { false, false, false, false, },
        { false, false, false, false, },
    },
    O = {
        { false, false, false, false, },
        { false, true, true, false, },
        { false, true, true, false, },
        { false, false, false, false, },
    },
    S = {
        { false, true, true },
        { true, true, false },
        { false, false, false },
    },
    Z = {
        { true, true, false },
        { false, true, true },
        { false, false, false },
    },
    J = {
        { true, false, false },
        { true, true, true },
        { false, false, false },
    },
    L = {
        { false, false, true },
        { true, true, true },
        { false, false, false },
    },
    T = {
        { false, true, false },
        { true, true, true },
        { false, false, false },
    },
}

-- 配列に対応する色
Tetrimino.static.arrayColors = {
    I = 'grey',
    O = 'yellow',
    S = 'green',
    Z = 'red',
    J = 'blue',
    L = 'orange',
    T = 'pink',
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

-- 列の作成
function Tetrimino.static.makeLine(width, color)
    width = width or 0
    if color == nil then
        color = false
    end

    local l = {}
    for j = 1, width do
        table.insert(l, color)
    end

    return l
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
        table.insert(t, Tetrimino.makeLine(width, color))
    end
    return t
end

-- 配列の作成
function Tetrimino.static.rotateArray(array, newcolor)
    array = array or {}
    if newcolor == nil then
        newcolor = false
    end
    local width = #array
    local height = array[1] == nil and 0 or #array[1]
    local newArray = Tetrimino.makeArray(width, height, newcolor)
    for v, line in ipairs(array) do
        for h, color in ipairs(line) do
            if color then
                newArray[h][height - v + 1] = color
            end
        end
    end
    return newArray
end

-- 配列の次元の取得
function Tetrimino.static.getArrayDimensions(array, fullcheck)
    array = array or {}
    if not fullcheck then
        return (array[1] == nil and 0 or #array[1]), (array == nil and 0 or #array)
    end

    local width, height = 0, 0

    for v, line in ipairs(array) do
        local count = 0
        for h, color in ipairs(line) do
            if color then
                if h > width then
                    width = h
                end
                count = count + 1
            end
        end
        if count > 0 then
            height = v
        end
    end

    return width, height
end

-- 配列の矩形の取得
function Tetrimino.static.getArrayRect(array)
    local right, bottom = Tetrimino.getArrayDimensions(array, true)
    local left, top = Tetrimino.getArrayDimensions(array)

    for v, line in ipairs(array) do
        for h, color in ipairs(line) do
            if color then
                if h < left then
                    left = h
                end
                if v < top then
                    top = v
                end
                break
            end
        end
    end

    return left, top, right, bottom
end

-- 配列の上書き
function Tetrimino.static.fillArray(array, newcolor)
    if newcolor == nil then
        newcolor = false
    end
    for v, line in ipairs(array) do
        for h, color in ipairs(line) do
            line[h] = newcolor
        end
    end
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
    local array = t.array or 'Z'
    local color = t.color or Tetrimino.arrayColors[array] or 'red'
    self.blockWidth, self.blockHeight = self:getSpriteSize(Tetrimino.spriteNames[color])
    self.colorArray = t.colorArray or Tetrimino.makeColorArray(Tetrimino.arrays[array], color)
    self:refresh()
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

-- ブロックの回転
function Tetrimino:rotate(n, newcolor)
    n = n or 1
    if n < 0 then
        n = 4 + n
    end
    for i = 1, n do
        self.colorArray = Tetrimino.rotateArray(self.colorArray, newcolor)
    end
    self:refresh()
end

-- ブロックの上書き
function Tetrimino:fill(newcolor)
    Tetrimino.fillArray(self.colorArray, newcolor)
end

-- ブロックの更新
function Tetrimino:refresh()
    self.width, self.height = Tetrimino.getArrayDimensions(self.colorArray)
    self.left, self.top, self.right, self.bottom = Tetrimino.getArrayRect(self.colorArray)
    self.swidth, self.sheight = self.right - self.left + 1, self.bottom - self.top + 1
end

-- サイズ
function Tetrimino:getDimensions()
    return self.blockWidth * self.width * self.scale, self.blockHeight * self.height * self.scale
end

-- 厳密なサイズ
function Tetrimino:getStrictDimensions()
    return self.blockWidth * self.swidth * self.scale, self.blockHeight * self.sheight * self.scale
end

-- ブロックのサイズ
function Tetrimino:getBlockDimensions()
    return self.blockWidth * self.scale, self.blockHeight * self.scale
end

-- サイズ
function Tetrimino:getRect()
    return self.blockWidth * (self.left - 1) * self.scale, self.blockHeight * (self.top - 1) * self.scale, self.blockWidth * self.right * self.scale, self.blockHeight * self.bottom * self.scale
end

-- ブロック座標に変換
function Tetrimino:toBlockDimensions(x, y)
    return math.ceil((x or self.x) / (self.blockWidth * self.scale)), math.ceil((y or self.y) / (self.blockHeight * self.scale))
end

-- ピクセル座標に変換
function Tetrimino:toPixelDimensions(x, y)
    return x * self.blockWidth * self.scale, y * self.blockHeight * self.scale
end

-- ブロック座標に移動
function Tetrimino:resetToBlockDimensions()
    self.x, self.y = self:toPixelDimensions(self:toBlockDimensions())
end

-- ブロック単位で移動
function Tetrimino:move(x, y)
    x = x or 0
    y = y or 0
    x, y = self:toPixelDimensions(x, y)
    self.x = self.x + x
    self.y = self.y + y
end

return Tetrimino

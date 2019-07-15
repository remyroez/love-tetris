
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
Tetrimino.static.colors = {
    'black',
    'blue',
    'green',
    'grey',
    'orange',
    'pink',
    'red',
    'yellow',
}

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

-- 初期化
function Tetrimino:initialize(t)
    Entity.initialize(self)

    -- SpriteRenderer 初期化
    self:initializeSpriteRenderer(t.spriteSheet)

    self.x = t.x or 0
    self.y = t.y or 0
    self.scale = t.scale or 1
    self.color = t.color or 'red'
    self.blockWidth, self.blockHeight = self:getSpriteSize(self:getBlockSpriteName())
    self.array = t.array or Tetrimino.arrays.I
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
    local x, y = 0, 0
    for v, line in ipairs(self.array) do
        for h, block in ipairs(line) do
            if block then
                self:drawBlock(x, y)
            end
            x = x + self.blockWidth
        end
        x = 0
        y = y + self.blockHeight
    end
    love.graphics.pop()
end

-- ブロックのスプライト名を返す
function Tetrimino:getBlockSpriteName()
    return Tetrimino.spriteNames[self.color]
end

-- ブロックの描画
function Tetrimino:drawBlock(x, y)
    x = x or self.x or 0
    y = y or self.y or 0
    self:drawSprite(self:getBlockSpriteName(), x, y)
end

return Tetrimino

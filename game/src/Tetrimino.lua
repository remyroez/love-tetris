
local class = require 'middleclass'
local lume = require 'lume'

-- 基底クラス
local Entity = require 'Entity'

-- テトリミノ クラス
local Tetrimino = class('Tetrimino', Entity)

-- 初期化
function Tetrimino:initialize(t)
    Entity.initialize(self)

    self.x = t.x or 0
    self.y = t.y or 0
end

-- 破棄
function Tetrimino:destroy()
end

-- 更新
function Tetrimino:update(dt)
end

-- 描画
function Tetrimino:draw()
    love.graphics.print('Tetrimino', self.x, self.y)
end

return Tetrimino


local class = require 'middleclass'
local lume = require 'lume'

-- 基底クラス
local Entity = require 'Entity'

-- インゲーム クラス
local InGame = class('InGame', Entity)

-- 初期化
function InGame:initialize()
    Entity.initialize(self)
end

-- 破棄
function InGame:destroy()
end

-- 更新
function InGame:update(dt)
end

-- 描画
function InGame:draw()
    love.graphics.print('Hello, InGame!')
end

-- キー入力
function InGame:keypressed(key, scancode, isrepeat)
    print('InGame', 'keypressed', key, scancode, isrepeat)
end

return InGame

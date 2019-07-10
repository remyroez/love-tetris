
local class = require 'middleclass'
local lume = require 'lume'

-- 基底クラス
local Entity = require 'Entity'

-- インゲーム クラス
local InGame = class('InGame', Entity)

-- クラス
local EntityManager = require 'EntityManager'
local Tetrimino = require 'Tetrimino'

-- 初期化
function InGame:initialize()
    Entity.initialize(self)
    self.width, self.height = love.graphics.getDimensions()
    self.manager = EntityManager()
    for i = 1, 10 do
        self.manager:add(Tetrimino{ x = love.math.random(self.width), y = love.math.random(self.height) })
    end
end

-- 破棄
function InGame:destroy()
    self.manager:destroy()
    self.manager = nil
end

-- 更新
function InGame:update(dt)
    self.manager:update(dt)
end

-- 描画
function InGame:draw()
    self.manager:draw()
end

-- キー入力
function InGame:keypressed(key, scancode, isrepeat)
end

return InGame

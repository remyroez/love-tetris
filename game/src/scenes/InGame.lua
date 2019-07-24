
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
function InGame:initialize(t)
    Entity.initialize(self)

    self.width = t.width or 800
    self.height = t.height or 600
    self.spriteSheetTiles = t.spriteSheetTiles
    self.spriteSheetParticles = t.spriteSheetParticles

    self.manager = EntityManager()

    self.stage = self.manager:add(Tetrimino{
        spriteSheet = self.spriteSheetTiles,
        x = 0, y = 0,
        rotation = 0,
        scale = 0.25,
        colorArray = Tetrimino.makeArray(10, 20, 'black')
    })
    do
        local t = Tetrimino{
            spriteSheet = self.spriteSheetTiles,
            x = 0, y = 0,
            rotation = 0,
            scale = 0.25,
            color = 'red',
            array = Tetrimino.arrays.S
        }
        self.stage:merge(1, 1, t.colorArray)
    end
    do
        local t = Tetrimino{
            spriteSheet = self.spriteSheetTiles,
            x = 0, y = 0,
            rotation = 0,
            scale = 0.25,
            color = 'blue',
            array = Tetrimino.arrays.T
        }
        self.stage:merge(2, 2, t.colorArray)
    end
    for i = 1, 0 do
        self.manager:add(Tetrimino{
            spriteSheet = self.spriteSheetTiles,
            x = love.math.random(self.width), y = love.math.random(self.height),
            rotation = love.math.random() * math.pi * 2,
            scale = 0.25,
            color = Tetrimino.colors[love.math.random(#Tetrimino.colors)],
            array = Tetrimino.arrays[Tetrimino.arrayNames[love.math.random(#Tetrimino.arrayNames)]]
        })
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

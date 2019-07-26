
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
        colorArray = Tetrimino.makeArray(10, 20)
    })
    do
        local t = { Tetrimino.makeLine(self.stage.width, 'grey') }
        self.stage:merge(0, 14, t)
    end
    do
        local t = Tetrimino.makeColorArray(Tetrimino.arrays.I, 'grey')
        self.stage:merge(0, 17, t)
    end
    do
        local t = Tetrimino.makeColorArray(Tetrimino.arrays.O, 'yellow')
        self.stage:merge(8, 18, t)
    end
    do
        local t = Tetrimino.makeColorArray(Tetrimino.arrays.S, 'green')
        self.stage:merge(1, 18, t)
        self.stage:merge(5, 15, t)
    end
    do
        local t = Tetrimino.makeColorArray(Tetrimino.arrays.Z, 'red')
        self.stage:merge(7, 16, t)
    end
    do
        local t = Tetrimino.makeColorArray(Tetrimino.arrays.J, 'blue')
        self.stage:merge(0, 15, t)
    end
    do
        local t = Tetrimino.makeColorArray(Tetrimino.arrays.L, 'orange')
        self.stage:merge(7, 12, t)
    end
    do
        local t = Tetrimino.makeColorArray(Tetrimino.arrays.T, 'pink')
        self.stage:merge(6, 11, t)
    end
    do
        local spriteSheet = self.spriteSheetTiles
        local x, y = self.width / 3, self.height / 2
        local scale = 0.25
        local color = 'pink'
        local array = Tetrimino.arrays.T
        self.manager:add(Tetrimino{
            spriteSheet = spriteSheet, x = x, y = y, scale = scale, color = color, array = array
        })
        for i = 1, 3 do
            local t = self.manager:add(Tetrimino{
                spriteSheet = spriteSheet,
                x = x + 100 * i, y = y,
                scale = scale, color = color, array = array
            })
            t:rotate(i)
        end
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
    love.graphics.rectangle('line', 0, 0, self.stage:getDimensions())
    self.manager:draw()
end

-- キー入力
function InGame:keypressed(key, scancode, isrepeat)
    if key == 'space' then
        print(self.stage:score())
    end
end

return InGame


local class = require 'middleclass'
local lume = require 'lume'

-- 基底クラス
local Entity = require 'Entity'

-- インゲーム クラス
local InGame = class('InGame', Entity)

-- クラス
local EntityManager = require 'EntityManager'
local Tetrimino = require 'Tetrimino'
local Stage = require 'Stage'

local function randomSelect(array)
    return array[love.math.random(#array)]
end

local baseScale = 0.25

-- 初期化
function InGame:initialize(t)
    Entity.initialize(self)

    self.width = t.width or 800
    self.height = t.height or 600
    self.spriteSheetTiles = t.spriteSheetTiles
    self.spriteSheetParticles = t.spriteSheetParticles

    self.manager = EntityManager()

    self.stage = self.manager:add(
        Stage {
            spriteSheet = self.spriteSheetTiles,
            x = 0, y = 0,
            scale = baseScale,
            colorArray = Tetrimino.makeArray(10, 20)
        }
    )

    self.currentTetrimino = self.manager:add(
        Tetrimino {
            spriteSheet = self.spriteSheetTiles,
            x = 0, y = 0,
            scale = baseScale,
            array = randomSelect(Tetrimino.arrayNames)
        }
    )

    self.speed = 100
end

-- 破棄
function InGame:destroy()
    self.manager:destroy()
    self.manager = nil
end

-- 更新
function InGame:update(dt)
    self.manager:update(dt)
    self:hitcheckCurrentTetrimino()
    if self.currentTetrimino then
        self.currentTetrimino.y = self.currentTetrimino.y + dt * self.speed
    end
end

-- 現在のテトリミノの当たり判定
function InGame:hitcheckCurrentTetrimino()
    local t = self.currentTetrimino
    if self.stage:hit(t) then
        t.y = t.y - t.blockHeight * t.scale
        self.stage:merge(t)
        self.stage:score()
        self.manager:remove(t)
        self.currentTetrimino = self.manager:add(
            Tetrimino {
                spriteSheet = self.spriteSheetTiles,
                x = 0, y = 0,
                scale = baseScale,
                array = randomSelect(Tetrimino.arrayNames)
            }
        )
    end
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

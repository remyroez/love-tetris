
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

    self.speed = 1 / 10
    self.timer = self.speed
end

-- 破棄
function InGame:destroy()
    self.manager:destroy()
    self.manager = nil
end

-- 更新
function InGame:update(dt)
    self.manager:update(dt)
    self:updateTetrimino(dt)
end

-- 描画
function InGame:draw()
    love.graphics.rectangle('line', 0, 0, self.stage:getDimensions())
    self.manager:draw()
end

-- キー入力
function InGame:keypressed(key, scancode, isrepeat)
    if key == 'space' then
        self.currentTetrimino:rotate()
    elseif key == 'left' then
        self:moveTetrimino(-1)
    elseif key == 'right' then
        self:moveTetrimino(1)
    end
end

-- 現在のテトリミノの更新
function InGame:updateTetrimino(dt)
    -- タイマーのカウントダウン
    self.timer = self.timer - dt
    if self.timer < 0 then
        -- タイマーのリセット
        self.timer = self.timer + self.speed

        -- 下に移動
        if self:moveTetrimino(0, 1) then
            -- 接触したのでステージに積む
            local t = self.currentTetrimino
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
end

-- テトリミノの移動
function InGame:moveTetrimino(x, y)
    local hit = false
    local t = self.currentTetrimino
    local tx, ty = t.x, t.y
    t:move(x, y)
    if self.stage:hit(t) then
        t.x, t.y = tx, ty
        hit = true
    end
    return hit
end

return InGame

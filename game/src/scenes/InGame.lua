
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

-- 初期化
function InGame:initialize(t)
    Entity.initialize(self)

    self.width = t.width or 800
    self.height = t.height or 600
    self.spriteSheetTiles = t.spriteSheetTiles
    self.spriteSheetParticles = t.spriteSheetParticles

    self.manager = EntityManager()

    local scale = 0.25
    self.stage = self.manager:add(
        Stage {
            spriteSheet = self.spriteSheetTiles,
            x = 0, y = 0,
            scale = scale,
            colorArray = Tetrimino.makeArray(10, 20)
        }
    )
    for _, array in ipairs(Tetrimino.arrayNames) do
        local t = self.manager:add(
            Tetrimino {
                spriteSheet = self.spriteSheetTiles,
                x = 0, y = 0,
                scale = scale,
                array = array
            }
        )
        for i = 1, self.stage.height do
            if self.stage:hit(t) then
                print('hit', i)
                t.y = t.y - t.blockHeight
                self.stage:merge(t)
                self.manager:remove(t)
                break
            end
            t.y = t.y + t.blockHeight
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

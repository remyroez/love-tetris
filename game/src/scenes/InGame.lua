
local class = require 'middleclass'
local lume = require 'lume'
local Timer = require 'Timer'

-- エイリアス
local lg = love.graphics

-- 基底クラス
local Entity = require 'Entity'

-- インゲーム クラス
local InGame = class('InGame', Entity)
InGame:include(require 'stateful')

-- クラス
local EntityManager = require 'EntityManager'
local Tetrimino = require 'Tetrimino'
local Stage = require 'Stage'

local function randomSelect(array)
    return array[love.math.random(#array)]
end

local baseScale = 0.25
local nextScale = 0.15

-- 初期化
function InGame:initialize(t)
    Entity.initialize(self)

    self.app = t.app or {}
    self.width = self.app.width or 800
    self.height = self.app.height or 600
    self.spriteSheetTiles = self.app.spriteSheetTiles
    self.spriteSheetParticles = self.app.spriteSheetParticles
    self.font64 = self.app.font64
    self.font32 = self.app.font32
    self.font16 = self.app.font16

    -- タイマー
    self.timer = Timer()

    -- エンティティマネージャ
    self.manager = EntityManager()

    -- ステージ
    self.stage = self.manager:add(
        Stage {
            spriteSheet = self.spriteSheetTiles,
            x = 0, y = 0,
            scale = baseScale,
            colorArray = Tetrimino.makeArray(10, 20)
        }
    )

    -- ステージの位置
    local w, h = self.stage:getDimensions()
    self.stage.x = (self.width - w) * 0.5
    self.stage.y = (self.height - h) * 0.5

    -- 初期状態
    self.speed = 1 / 2
    self.counter = self.speed
    self.level = 1
    self.score = 0
    self.lines = 0
    self.next = {}
    self.busy = true

    -- スタート
    self:gotoState 'Start'
end

-- 破棄
function InGame:added(parent)
end

-- 破棄
function InGame:destroy()
    self.manager:destroy()
    self.manager = nil
end

-- 更新
function InGame:update(dt)
end

-- 描画
function InGame:draw()
end

-- キー入力
function InGame:keypressed(key, scancode, isrepeat)
end

-- ステージの描画
function InGame:drawStage()
    -- ステージのライン
    love.graphics.rectangle('line', self.stage.x, self.stage.y, self.stage:getDimensions())

    lg.printf(
        'LEVEL\n' .. self.level .. '\n\nSCORE\n' .. self.score .. '\n\nLINES\n' .. self.lines,
        self.font16,
        0,
        self.stage.y,
        self.stage.x - 16,
        'right'
    )

    local w, h = self.stage:getDimensions()
    lg.printf('NEXT', self.font16, self.stage.x + w + 16, self.stage.y, self.width, 'left')

    -- エンティティの描画
    self.manager:draw()
end

-- 現在のテトリミノの更新
function InGame:updateTetrimino(dt)
    local hit = false

    -- タイマーのカウントダウン
    self.counter = self.counter - (dt or self.speed)
    if self.counter < 0 then
        -- タイマーのリセット
        self.counter = self.counter + self.speed

        -- 下に移動
        if self:moveTetrimino(0, 1) then
            -- 接触したのでステージに積む
            self:mergeTetrimino()
            hit = true
        end
    end

    return hit
end

-- テトリミノのマージ
function InGame:mergeTetrimino()
    self.stage:merge(self.currentTetrimino)
    self.stage:score()
    self.manager:remove(self.currentTetrimino)
    self:newTetrimino()
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

-- テトリミノの移動
function InGame:fallTetrimino()
    while not self:updateTetrimino() do
    end
    self.counter = self.speed
end

-- テトリミノの生成
function InGame:newTetrimino()
    self:nextTetrimino()
end

-- テトリミノの生成
function InGame:generateNextTetriminos(n)
    local w, h = self.stage:getDimensions()
    local count = (n or 6) - #self.next
    for i = 1, count do
        table.insert(
            self.next,
            self.manager:add(
                Tetrimino {
                    spriteSheet = self.spriteSheetTiles,
                    x = self.stage.x + w + 16, y = 0,
                    scale = nextScale,
                    array = randomSelect(Tetrimino.arrayNames)
                }
            )
        )
    end
    local fh = self.font16:getHeight() * 2
    for i, t in ipairs(self.next) do
        local x, y = t:toPixelDimensions(0, 4)
        t.y = self.stage.y + (i - 1) * y + fh
    end
end

-- テトリミノの生成
function InGame:nextTetrimino()
    if #self.next == 0 then
        self:generateNextTetriminos()
    end
    local x, y = self.stage:toPixelDimensions(3, 0)
    x = x + self.stage.x
    y = y + self.stage.y
    self.currentTetrimino = lume.first(self.next)
    self.currentTetrimino.x, self.currentTetrimino.y = x, y
    self.currentTetrimino.scale = baseScale
    self.next = lume.slice(self.next, 2)
    self:generateNextTetriminos()
end

local fitcheck = {
    { 0, 1 },
    { 1, 1 },
    { -1, 1 },
    --{ 0, -1 },
    --{ 1, -1 },
    --{ -1, -1 },
}

-- テトリミノの生成
function InGame:fitTetrimino()
    local valid = true
    local t = self.currentTetrimino
    local hitresult = self.stage:hit(t)
    while hitresult do
        if lume.find(hitresult, 'left') then
            t:move(1)
        elseif lume.find(hitresult, 'right') then
            t:move(-1)
        elseif lume.find(hitresult, 'bottom') then
            t:move(0, -1)
        elseif lume.find(hitresult, 'hit') then
            local ok = false
            for _, pos in ipairs(fitcheck) do
                if not self:moveTetrimino(unpack(pos)) then
                    ok = true
                    break
                end
            end
            if not ok then
                valid = false
                break
            end
        else
            break
        end
        hitresult = self.stage:hit(t)
    end
    return valid
end

-- スタート ステート
local Start = InGame:addState 'Start'

-- ステート開始
function Start:enteredState()
    self.busy = true

    self.fade = { .42, .75, .89, 1 }

    -- 開始演出
    self.timer:tween(
        1,
        self,
        { fade = { [4] = 0 } },
        'in-out-cubic',
        function ()
            -- 操作可能
            self:gotoState 'Play'
        end
    )
end

-- 更新
function Start:update(dt)
    self.timer:update(dt)
    self.manager:update(dt)
end

-- 描画
function Start:draw()
    -- クリア
    love.graphics.clear(.42, .75, .89)

    -- ステージ描画
    self:drawStage()

    -- タイトル
    --lg.setColor(1, 1, 1)
    --lg.printf('CHOOSE LEVEL', self.font64, 0, self.height * 0.3 - self.font64:getHeight() * 0.5, self.width, 'center')

    -- フェード
    if self.fade[4] > 0 then
        lg.setColor(unpack(self.fade))
        lg.rectangle('fill', 0, 0, self.width, self.height)
    end
end

-- キー入力
function Start:keypressed(key, scancode, isrepeat)
    if not self.busy then
        self:gotoState 'Play'
    end
end

-- プレイ ステート
local Play = InGame:addState 'Play'

-- ステート開始
function Play:enteredState()
    -- 新規テトリミノ
    self:nextTetrimino()
end

-- 更新
function Play:update(dt)
    self.manager:update(dt)
    if self:updateTetrimino(dt) and self.stage:hit(self.currentTetrimino) then
        self:gotoState 'Gameover'
    end
end

-- 描画
function Play:draw()
    -- クリア
    love.graphics.clear(.42, .75, .89)

    -- ステージ描画
    self:drawStage()
end

-- キー入力
function Play:keypressed(key, scancode, isrepeat)
    if key == 'space' or key == 'a' then
        self.currentTetrimino:rotate()
        if not self:fitTetrimino() then
            self.currentTetrimino:rotate(-1)
        end
    elseif key == 'd' then
        self.currentTetrimino:rotate(-1)
        if not self:fitTetrimino() then
            self.currentTetrimino:rotate()
        end
    elseif key == 'left' then
        self:moveTetrimino(-1)
    elseif key == 'right' then
        self:moveTetrimino(1)
    elseif key == 'down' then
        self:fallTetrimino()
    end
end

-- ゲームオーバー ステート
local Gameover = InGame:addState 'Gameover'

-- ステート開始
function Gameover:enteredState()
end

-- 更新
function Gameover:update(dt)
    self.manager:update(dt)
end

-- 描画
function Gameover:draw()
    -- クリア
    lg.clear(.42, .75, .89)

    -- ステージ描画
    self:drawStage()

    -- タイトル
    lg.setColor(1, 1, 1)
    lg.printf('GAMEOVER', self.font64, 0, self.height * 0.3 - self.font64:getHeight() * 0.5, self.width, 'center')
end

-- キー入力
function Gameover:keypressed(key, scancode, isrepeat)
    self:gotoState 'Start'
    self.stage:fill()
end

return InGame

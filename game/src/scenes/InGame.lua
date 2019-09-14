
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

local function shuffle(t)
    local rtn = {}
    for i = 1, #t do
      local r = love.math.random(i)
      if r ~= i then
        rtn[i] = rtn[r]
      end
      rtn[r] = t[i]
    end
    return rtn
  end

local baseSpeed = 1
local baseScale = 0.25
local nextScale = 0.15
local scoreTable = {
    40,
    100,
    300,
    1200,
}

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

    -- オーディオ
    self.audio = self.app.audio or {}

    -- タイマー
    self.timer = Timer()

    -- エンティティマネージャ
    self.manager = EntityManager()

    -- 初期状態
    self.speed = baseSpeed
    self.counter = self.speed
    self.level = 0
    self.score = 0
    self.lines = 0
    self.next = {}
    self.stock = {}
    self.busy = true

    -- スタート
    self:gotoState 'Start'
end

-- 破棄
function InGame:added(parent)
end

-- 破棄
function InGame:destroy()
    self.timer:destroy()
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
function InGame:setupStage()
    -- ステージ
    self.backstage = self.manager:add(
        Stage {
            spriteSheet = self.spriteSheetTiles,
            x = 0, y = 0,
            scale = baseScale,
            colorArray = Tetrimino.makeArray(10, 20, 'black'),
            alpha = 0.25
        }
    )
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
    self.backstage.x = self.stage.x
    self.backstage.y = self.stage.y
end

-- ステージの描画
function InGame:drawStage()
    -- ステージ
    if self.stage == nil then
        return
    end

    -- ステージのライン
    lg.setColor(0, 0, 0, 0.75)
    lg.rectangle('fill', self.stage.x, self.stage.y, self.stage:getDimensions())
    lg.setColor(1, 1, 1)
    lg.rectangle('line', self.stage.x, self.stage.y, self.stage:getDimensions())

    -- スコア類
    lg.printf(
        'LEVEL\n' .. self.level .. '\n\nSCORE\n' .. self.score .. '\n\nLINES\n' .. self.lines,
        self.font16,
        0,
        self.stage.y,
        self.stage.x - 16,
        'right'
    )

    -- 次のテトリミノ
    local w, h = self.stage:getDimensions()
    lg.printf('NEXT', self.font16, self.stage.x + w + 16, self.stage.y, self.width, 'left')
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
    local lines = self.stage:score()
    if lines > 0 then
        self.lines = self.lines + lines
        self.score = self.score + scoreTable[lines] * (self.level + 1)
        self.level = math.floor(self.lines / 10)
        self.audio:playSound('score')
    else
        self.audio:playSound('fall')
    end
    self.manager:remove(self.currentTetrimino)
    self:nextTetrimino()
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
    self:resetCounter()
end

-- 次の配列名を返す
function InGame:nextArrayName()
    if #self.stock == 0 then
        self.stock = shuffle(lume.clone(Tetrimino.arrayNames))
    end
    return table.remove(self.stock)
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
                    array = self:nextArrayName()
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

function InGame:resetSpeed(level)
    level = level or self.level
    self.speed = baseSpeed / (level + 1)
    self:resetCounter()
end

function InGame:resetCounter(counter)
    self.counter = counter or self.speed
end

-- スタート ステート
local Start = InGame:addState 'Start'

-- ステート開始
function Start:enteredState()
    -- 初期化
    self.timer:destroy()
    self.manager:clear()
    self:setupStage()

    -- リセット
    self.level = 0
    self.score = 0
    self.lines = 0
    self.next = {}
    self.stock = {}
    self.busy = true
    self:resetSpeed()

    self.fade = { .42, .75, .89, 1 }

    -- ＢＧＭ
    self.audio:playMusic('ingame')

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

-- ステート終了
function Start:exitedState()
    self.timer:destroy()
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

    -- エンティティの描画
    self.manager:draw()

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

-- ステート終了
function Play:exitedState()
    self.audio:stopMusic()
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

    -- エンティティの描画
    self.manager:draw()
end

-- キー入力
function Play:keypressed(key, scancode, isrepeat)
    if key == 'space' or key == 'a' then
        self.currentTetrimino:rotate(-1)
        if not self:fitTetrimino() then
            self.currentTetrimino:rotate()
        else
            self.audio:playSound('move')
        end
    elseif key == 'd' then
        self.audio:playSound('move')
        self.currentTetrimino:rotate()
        if not self:fitTetrimino() then
            self.currentTetrimino:rotate(-1)
        else
            self.audio:playSound('move')
        end
    elseif key == 'left' then
        if not self:moveTetrimino(-1) then
            self.audio:playSound('move')
        end
    elseif key == 'right' then
        if not self:moveTetrimino(1) then
            self.audio:playSound('move')
        end
    elseif key == 'down' then
        self.audio:playSound('move')
        if not self:moveTetrimino(0, 1) then
            self.audio:playSound('move')
            self:resetCounter()
        end
    elseif key == 'up' then
        self:fallTetrimino()
        if self.stage:hit(self.currentTetrimino) then
            self:gotoState 'Gameover'
        end
    elseif key == 'z' then
        self.lines = self.lines + 10
        self.level = self.level + 1
        self:resetSpeed()
    elseif key == 'x' then
        self.lines = 0
        self.level = 0
        self:resetSpeed()
    end
end

-- ゲームオーバー ステート
local Gameover = InGame:addState 'Gameover'

-- ステート開始
function Gameover:enteredState()
    -- 初期化
    self.timer:destroy()
    self.fade = { .42, .75, .89, 0 }
    self.alpha = 0
    self.busy = true
    self.offset = self.height
    self.visiblePressAnyKey = true

    -- ＳＥ
    self.audio:playSound('gameover')

    -- 開始演出
    self.timer:tween(
        1,
        self,
        { alpha = .5, offset = 0 },
        'in-out-cubic',
        function ()
            -- キー入力表示の点滅
            self.timer:every(
                0.5,
                function ()
                    self.visiblePressAnyKey = not self.visiblePressAnyKey
                end
            )

            -- 操作可能
            self.busy = false
        end
    )
end

-- ステート終了
function Gameover:exitedState()
    self.timer:destroy()
    self.audio:stopSound('gameover')
    self.audio:seekMusic('ingame')
end

-- 更新
function Gameover:update(dt)
    self.timer:update(dt)
    self.manager:update(dt)
end

-- 描画
function Gameover:draw()
    -- クリア
    lg.clear(.42, .75, .89)

    -- ステージ描画
    self:drawStage()

    -- エンティティの描画
    self.manager:draw()

    -- フェード
    if self.alpha > 0 then
        lg.setColor(.42, .75, .89, self.alpha)
        lg.rectangle('fill', 0, 0, self.width, self.height)
    end

    -- タイトル
    lg.setColor(1, 1, 1)
    lg.printf('GAMEOVER', self.font64, 0, self.height * 0.3 - self.font64:getHeight() * 0.5 - self.offset, self.width, 'center')

    -- キー入力表示
    if not self.busy and self.visiblePressAnyKey then
        lg.printf('PRESS ANY KEY TO CONTINUE', self.font32, 0, self.height * 0.7 - self.font32:getHeight() * 0.5, self.width, 'center')
    end

    -- フェード
    if self.fade[4] > 0 then
        lg.setColor(self.fade)
        lg.rectangle('fill', 0, 0, self.width, self.height)
    end
end

-- キー入力
function Gameover:keypressed(key, scancode, isrepeat)
    if not self.busy then
        self.audio:playSound('ok')
        self.busy = true
        self.timer:tween(
            1,
            self,
            { fade = { [4] = 1 }, offset = 0 },
            'in-out-cubic',
            function ()
                self:gotoState 'Start'
            end
        )
    end
end

return InGame

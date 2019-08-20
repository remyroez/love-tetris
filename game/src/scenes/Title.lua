
local class = require 'middleclass'
local lume = require 'lume'
local Timer = require 'Timer'

-- 基底クラス
local Entity = require 'Entity'

-- エイリアス
local lg = love.graphics

-- タイトル クラス
local Title = class('Title', Entity)

-- 次のステートへ
function Title:nextScene(...)
    self.parent:swap(
        require 'scenes.InGame' {
            app = self.app,
        }
    )
end

-- 初期化
function Title:initialize(t)
    Entity.initialize(self)

    self.app = t.app or {}
    self.width = self.app.width or 800
    self.height = self.app.height or 600
    self.font64 = self.app.font64
    self.font32 = self.app.font32

    -- タイマー
    self.timer = Timer()

    -- 演出
    self.busy = true
    self.visiblePressAnyKey = true
    self.fade = { .42, .75, .89, 1 }
    self.alpha = 0

    -- 開始演出
    self.timer:tween(
        1,
        self,
        { fade = { [4] = 0 }, alpha = 1 },
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

-- 破棄
function Title:destroy()
    self.timer:destroy()
    self.timer = nil
end

-- 更新
function Title:update(dt)
    -- タイマー
    self.timer:update(dt)
end

-- 描画
function Title:draw()
    -- クリア
    lg.clear(.42, .75, .89)

    -- タイトル
    lg.setColor(1, 1, 1, self.alpha)
    lg.printf('TETRIS', self.font64, 0, self.height * 0.3 - self.font64:getHeight() * 0.5, self.width, 'center')

    -- キー入力表示
    if not self.busy and self.visiblePressAnyKey then
        lg.printf('PRESS ANY KEY', self.font32, 0, self.height * 0.7 - self.font32:getHeight() * 0.5, self.width, 'center')
    end

    -- フェード
    if self.fade[4] > 0 then
        lg.setColor(unpack(self.fade))
        lg.rectangle('fill', 0, 0, self.width, self.height)
    end
end

-- キー入力
function Title:keypressed(key, scancode, isrepeat)
    if not self.busy then
        -- 操作不可
        self.busy = true

        -- 終了演出
        self.timer:tween(
            0.5,
            self,
            { alpha = 0 },
            'in-out-cubic',
            function ()
                -- 演出が終わったら次へ
                self:nextScene()
            end
        )
    end
end

-- マウス入力
function Title:mousepressed(x, y, button, istouch, presses)
    if not self.busy then
        self:keypressed('mouse' .. button)
    end
end

return Title

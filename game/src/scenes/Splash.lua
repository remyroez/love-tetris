
local class = require 'middleclass'
local lume = require 'lume'
local o_ten_one = require 'o-ten-one'

-- 基底クラス
local Entity = require 'Entity'

-- スプラッシュ クラス
local Splash = class('Splash', Entity)

-- 次のステートへ
function Splash:nextScene(...)
    self.parent:swap(
        require 'scenes.Title' {
            app = self.app,
        }
    )
end

-- 初期化
function Splash:initialize(t)
    Entity.initialize(self)

    self.app = t.app or {}

    -- スプラッシュスクリーンの設定
    local config = t.config or {}
    config.base_folder = config.base_folder or 'lib'

    -- スプラッシュスクリーン
    self.splash = o_ten_one(config)
    self.splash.onDone = function ()
        self:nextScene()
    end
end

-- 破棄
function Splash:destroy()
end

-- 更新
function Splash:update(dt)
    self.splash:update(dt)
end

-- 描画
function Splash:draw()
    self.splash:draw()
end

-- キー入力
function Splash:keypressed(key, scancode, isrepeat)
    self.splash:skip()
end

-- マウス入力
function Splash:mousepressed(x, y, button, istouch, presses)
    self.splash:skip()
end

return Splash

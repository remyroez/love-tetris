
local class = require 'middleclass'
local lume = require 'lume'

-- 基底クラス
local Entity = require 'Entity'

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
end

-- 破棄
function Title:destroy()
end

-- 更新
function Title:update(dt)
end

-- 描画
function Title:draw()
    love.graphics.print('Tetris')
end

-- キー入力
function Title:keypressed(key, scancode, isrepeat)
    self:nextScene()
end

-- マウス入力
function Title:mousepressed(x, y, button, istouch, presses)
    self:nextScene()
end

return Title

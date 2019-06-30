
local class = require 'middleclass'

-- アプリケーション
local Application = class 'Application'

-- 初期化
function Application:initialize(...)
    self.debugMode = false

    self:load(...)
end

-- デバッグモードの設定
function Application:setDebugMode(mode)
    self.debugMode = mode or false
end

-- 読み込み
function Application:load(...)
end

-- 更新
function Application:update(dt, ...)
end

-- 描画
function Application:draw(...)
end

-- キー入力
function Application:keypressed(key, scancode, isrepeat)
end

-- キー離した
function Application:keyreleased(key, scancode)
end

-- マウス入力
function Application:mousepressed(x, y, button, istouch, presses)
end

-- マウス離した
function Application:mousereleased(x, y, button, istouch, presses)
end

-- マウス移動
function Application:mousemoved(x, y, dx, dy, istouch)
end

-- マウスホイール
function Application:wheelmoved(x, y)
end

-- ゲームパッド入力
function Application:gamepadpressed(joystick, button)
end

-- テキスト入力
function Application:textinput(text)
end

-- リサイズ
function Application:resize(width, height)
end

return Application

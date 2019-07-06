
-- シーン モジュール
local Scene = {}

-- キー入力
function Scene:keypressed(key, scancode, isrepeat)
    self:call('keypressed', key, scancode, isrepeat)
end

-- キー離した
function Scene:keyreleased(key, scancode)
    self:call('keyreleased', key, scancode)
end

-- マウス入力
function Scene:mousepressed(x, y, button, istouch, presses)
    self:call('mousepressed', x, y, button, istouch, presses)
end

-- マウス離した
function Scene:mousereleased(x, y, button, istouch, presses)
    self:call('mousereleased', x, y, button, istouch, presses)
end

-- マウス移動
function Scene:mousemoved(x, y, dx, dy, istouch)
    self:call('mousemoved', x, y, dx, dy, istouch)
end

-- マウスホイール
function Scene:wheelmoved(x, y)
    self:call('wheelmoved', x, y)
end

-- ゲームパッド入力
function Scene:gamepadpressed(joystick, button)
    self:call('gamepadpressed', joystick, button)
end

-- テキスト入力
function Scene:textinput(text)
    self:call('textinput', text)
end

-- リサイズ
function Scene:resize(width, height)
    self:call('resize', width, height)
end

return Scene


local folderOfThisFile = (...):match("(.-)[^%/%.]+$")

-- ゲームクラス
local Game = require(folderOfThisFile .. 'class')

-- クラス
local Application = require 'Application'
local EntityStack = require 'EntityStack'
local InGame = require 'scenes.InGame'

-- 初期化
function Game:initialize(...)
    Application.initialize(self, ...)
end

-- 読み込み
function Game:load(...)
    self.scene = EntityStack()
    self.scene:add(InGame())
end

-- 更新
function Game:update(dt, ...)
    self.scene:update()
end

-- 描画
function Game:draw(...)
    self.scene:draw()
end

-- キー入力
function Game:keypressed(key, scancode, isrepeat)
    self.scene:call('keypressed', key, scancode, isrepeat)
end

-- キー離した
function Game:keyreleased(key, scancode)
    self.scene:call('keyreleased', key, scancode)
end

-- テキスト入力
function Game:textinput(text)
end

-- マウス入力
function Game:mousepressed(x, y, button, istouch, presses)
    self.scene:call('mousepressed', x, y, button, istouch, presses)
end

-- マウス離した
function Game:mousereleased(x, y, button, istouch, presses)
    self.scene:call('mousereleased', x, y, button, istouch, presses)
end

-- マウス移動
function Game:mousemoved(x, y, dx, dy, istouch)
end

-- マウスホイール
function Game:wheelmoved(x, y)
end

-- リサイズ
function Game:resize(width, height)
end


local folderOfThisFile = (...):match("(.-)[^%/%.]+$")

-- ゲームクラス
local Game = require(folderOfThisFile .. 'class')

-- クラス
local Application = require 'Application'
local EntityStack = require 'EntityStack'
local Splash = require 'scenes.Splash'
local AudioManager = require 'AudioManager'

-- エイリアス
local lg = love.graphics
local la = love.audio

-- 初期化
function Game:initialize(...)
    Application.initialize(self, ...)
end

-- 読み込み
function Game:load(...)
    -- 画面のサイズ
    local width, height = lg.getDimensions()
    self.width = width
    self.height = height

    -- スプライトシートの読み込み
    self.spriteSheetParticles = sbss:new('assets/spritesheet_particles.xml')
    self.spriteSheetTiles = sbss:new('assets/spritesheet_tiles.xml')

    -- フォントの読み込み
    local fontPath = 'assets/KenPixel Blocks.ttf'
    self.font64 = lg.newFont(fontPath, 64)
    self.font32 = lg.newFont(fontPath, 32)
    self.font16 = lg.newFont(fontPath, 16)
    self.font8 = lg.newFont(fontPath, 8)

    -- オーディオマネージャ
    self.audio = AudioManager()

    -- 音楽
    self.audio:loadMusic(
        {
            ingame = 'Mishief Stroll.ogg',
        },
        {
            basepath = 'assets',
            volume = 0.5,
        }
    )

    -- ＳＥ
    self.audio:loadSound(
        {
            gameover = 'Serious ident.ogg',
            ok = 'upgrade1.ogg',
            move = 'coin5.ogg',
            fall = 'hurt2.ogg',
            score = 'hit2.ogg',
        },
        {
            basepath = 'assets',
        }
    )

    -- シーン
    self.scene = EntityStack()
    self.scene:add(Splash{
        app = self,
    })
end

-- 更新
function Game:update(dt, ...)
    self.scene:update(dt)
end

-- 描画
function Game:draw(...)
    self.scene:draw()

    -- デバッグモード表示
    if self.debugMode then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print('debug mode')
    end
end

-- キー入力
function Game:keypressed(key, scancode, isrepeat)
    self.scene:call('keypressed', key, scancode, isrepeat)
end

-- キー離した
function Game:keyreleased(key, scancode)
    self.scene:call('keyreleased', key, scancode)
end

-- マウス入力
function Game:mousepressed(x, y, button, istouch, presses)
    self.scene:call('mousepressed', x, y, button, istouch, presses)
end

-- マウス離した
function Game:mousereleased(x, y, button, istouch, presses)
    self.scene:call('mousereleased', x, y, button, istouch, presses)
end

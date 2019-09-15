
local class = require 'middleclass'

-- オーディオマネージャ
local AudioManager = class 'AudioManager'

-- 初期化
function AudioManager:initialize(t)
    t = t or {}
    self.sounds = t.sounds or {}
    self.musics = t.musics or {}
    self.currentMusic = nil
end

-- 破棄
function AudioManager:destroy()
    self:stopMusic()
    self:stopAllSound()
end

-- 音楽の読み込み
function AudioManager:loadMusic(paths, opt)
    opt = opt or {}
    local basepath = opt.basepath or ''
    local stype = opt.type or 'static'
    local volume = opt.volume
    for name, path in pairs(paths) do
        self.musics[name] = love.audio.newSource(basepath .. '/' .. path, stype)
        self.musics[name]:setLooping(true)
        if volume then self.musics[name]:setVolume(volume) end
    end
end

-- 音楽の取得
function AudioManager:getMusic(name)
    return self.musics ~= nil and self.musics[name] or nil
end

-- 音楽の再生
function AudioManager:playMusic(name, reset)
    reset = reset ~= nil and reset or false

    if name ~= self.currentMusic or reset then
        -- 前の音楽を停止
        self:stopMusic()
    end

    local music = self:getMusic(name)
    if music then
        if reset then
            music:seek(0)
        end
        music:play()
    end

    self.currentMusic = name
end

-- 音楽の停止
function AudioManager:stopMusic()
    local music = self:getMusic(self.currentMusic)
    if music then
        music:stop()
    end
    self.currentMusic = nil
end

-- 音楽の再生位置の設定
function AudioManager:seekMusic(name, offset, unit)
    offset = offset or 0
    local music = self:getMusic(name)
    if music then
        music:seek(offset, unit)
    end
end

-- サウンドの読み込み
function AudioManager:loadSound(paths, opt)
    opt = opt or {}
    local basepath = opt.basepath or ''
    local stype = opt.type or 'static'
    for name, path in pairs(paths) do
        self.sounds[name] = love.audio.newSource(basepath .. '/' .. path, stype)
    end
end

-- サウンドの取得
function AudioManager:getSound(name)
    return self.sounds ~= nil and self.sounds[name] or nil
end

-- サウンドの再生
function AudioManager:playSound(name, reset)
    reset = reset == nil and true or reset
    local sound = self:getSound(name)
    if sound then
        if sound then
            sound:seek(0)
        end
        sound:play()
    end
end

-- サウンドの停止
function AudioManager:stopSound(name)
    local sound = self:getSound(name)
    if sound then
        sound:stop()
    end
end

-- すべてのサウンドの停止
function AudioManager:stopAllSound()
    for _, sound in ipairs(self.sounds) do
        sound:stop()
    end
end

return AudioManager

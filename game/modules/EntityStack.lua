
local class = require 'middleclass'
local lume = require 'lume'

-- 基底クラス
local EntityManager = require 'EntityManager'

-- エンティティスタック クラス
local EntityStack = class('EntityStack', EntityManager)

-- 初期化
function EntityStack:initialize()
    EntityManager.initialize(self)
end

-- 現在のエンティティ
function EntityStack:current()
    return lume.last(self.entities)
end

-- 更新
function EntityStack:update(dt)
    local entity = self:current()
    if entity then
        entity:update(dt)
    end
end

-- 描画
function EntityStack:draw()
    local entity = self:current()
    if entity then
        entity:draw()
    end
end

-- 呼び出し
function EntityStack:call(event, ...)
    local entity = self:current()
    if entity then
        lume.call(entity[event], entity, ...)
    end
end

return EntityStack

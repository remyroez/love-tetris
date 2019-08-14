
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

-- 先頭のエンティティ
function EntityStack:top()
    return lume.last(self.entities)
end

-- 呼び出し
function EntityStack:call(event, ...)
    local entity = self:top()
    if entity then
        lume.call(entity[event], entity, ...)
    end
end

-- 先頭のエンティティを入れ替える
function EntityStack:swap(entity)
    self:remove(self:top())
    return self:add(entity)
end

return EntityStack

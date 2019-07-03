
local class = require 'middleclass'
local lume = require 'lume'

-- 基底クラス
local Entity = require 'Entity'

-- エンティティマネージャ クラス
local EntityManager = class('EntityManager', Entity)

-- 初期化
function EntityManager:initialize()
    Entity.initialize(self)

    self.entities = {}
end

-- 破棄
function EntityManager:destroy()
    self:clear()
end

-- 更新
function EntityManager:update(dt)
    for _, entity in ipairs(self.entities) do
        entity:update(dt)
    end
end

-- 描画
function EntityManager:draw()
    for _, entity in ipairs(self.entities) do
        entity:draw()
    end
end

-- クリア
function EntityManager:clear()
    for _, entity in ipairs(self.entities) do
        entity:destroy()
        entity.parent = nil
    end
    lume.clear(self.entities)
end

-- 追加
function EntityManager:add(entity)
    table.insert(self.entities, entity)
    entity.parent = self
    return entity
end

-- 除外
function EntityManager:remove(entity)
    lume.remove(self.entities, entity)
    entity:destroy()
    entity.parent = nil
    return entity
end

return EntityManager

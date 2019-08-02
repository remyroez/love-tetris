
local class = require 'middleclass'
local lume = require 'lume'

-- 基底クラス
local Tetrimino = require 'Tetrimino'

-- ステージ クラス
local Stage = class('Stage', Tetrimino)

-- 初期化
function Stage:initialize(t)
    Tetrimino.initialize(self, t)
end

-- 破棄
function Stage:destroy()
    Tetrimino.destroy(self)
end

-- 更新
function Stage:update(dt)
    Tetrimino.update(self, dt)
end

-- 描画
function Stage:draw()
    Tetrimino.draw(self)
end

-- ブロックの当たり判定
function Stage:hit(xOrTetrimino, y, colorArray)
    local x, y = 0, 0

    -- 最初の引数がテーブルなら Tetrimino クラスとして見做す
    if type(xOrTetrimino) == 'table' then
        x, y = xOrTetrimino:toBlockDimensions()
        colorArray = xOrTetrimino.colorArray
    else
        x = xOrTetrimino or 0
        y = y or 0
        if colorArray == nil then return false end
    end

    -- マイナス方向にはみ出したので当たり扱い
    if x < 0 then return true end
    if y < 0 then return true end

    -- 当たりフラグ
    local isHit = false

    -- 配列のサイズ
    local width, height = Tetrimino.getArrayDimensions(colorArray, true)
    local right, bottom = width + x, height + y

    -- 外にはみ出していたら当たり扱い
    if right > self.width or bottom > self.height then
        return true
    end

    for v, line in ipairs(self.colorArray) do
        for h, color in ipairs(line) do
            local tx, ty = h - 1, v - 1
            if (tx >= x) and (ty >= y) and (tx < right) and (ty < bottom) then
                local i, j = tx - x + 1, ty - y + 1
                if colorArray[j][i] and line[h] then
                    isHit = true
                    break
                end
            end
        end
        if isHit then
            break
        end
    end

    return isHit
end

-- ブロックのマージ
function Stage:merge(xOrTetrimino, y, colorArray)
    local x, y = 0, 0

    -- 最初の引数がテーブルなら Tetrimino クラスとして見做す
    if type(xOrTetrimino) == 'table' then
        x, y = xOrTetrimino:toBlockDimensions()
        colorArray = xOrTetrimino.colorArray
    else
        x = xOrTetrimino or 0
        y = y or 0
        if colorArray == nil then return false end
    end

    -- マイナス方向にはみ出していたら失敗
    -- TODO: マージできるようにする
    if x < 0 then return false end
    if y < 0 then return false end

    local w, h = Tetrimino.getArrayDimensions(colorArray, true)

    -- 高さ拡張
    local height = y + h
    if height > #self.colorArray then
        while height >= #self.colorArray do
            table.insert(self.colorArray, {})
        end
    end

    -- 幅拡張
    local width = x + w
    if width > #self.colorArray[1] then
        for v, line in ipairs(self.colorArray) do
            while width >= #line do
                table.insert(line, false)
            end
        end
    end

    -- マージ
    for v, line in ipairs(self.colorArray) do
        for h, color in ipairs(line) do
            local tx, ty = h - 1, v - 1
            if (tx >= x) and (ty >= y) and (tx < width) and (ty < height) then
                local i, j = tx - x + 1, ty - y + 1
                if colorArray[j][i] then
                    line[h] = colorArray[j][i]
                end
            end
        end
    end

    return true
end

-- スコア計算
function Stage:score()
    local lines = {}

    for v, line in ipairs(self.colorArray) do
        local valid = 0
        for h, color in ipairs(line) do
            if color then
                valid = valid + 1
            end
        end
        if valid > 0 and valid == #line then
            table.insert(lines, v)
        end
    end

    for i = 1, #lines do
        table.remove(self.colorArray, lines[#lines - i + 1])
    end

    for i = 1, #lines do
        table.insert(self.colorArray, 1, Tetrimino.makeLine(self.width))
    end

    return #lines
end

return Stage

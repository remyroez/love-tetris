
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

-- クリア
function Stage:clear()
    self.colorArray = Tetrimino.makeArray(self.width, self.height)
end

-- ブロックの当たり判定
function Stage:hit(xOrTetrimino, y, colorArray)
    local x = 0
    local result = {}

    -- 最初の引数がテーブルなら Tetrimino クラスとして見做す
    if type(xOrTetrimino) == 'table' then
        x, y = xOrTetrimino:toBlockDimensions()
        colorArray = xOrTetrimino.colorArray
    else
        x = xOrTetrimino or 0
        y = y or 0
        if colorArray == nil then return false end
    end

    -- 配列のサイズ
    local left, top, right, bottom = Tetrimino.getArrayRect(colorArray)
    local bleft, btop = left, top
    left, top = left + x, top + y
    right, bottom = right + x, bottom + y

    -- はみ出していたら当たり扱い
    if left < 1 then table.insert(result, 'left') end
    if top < 1 then table.insert(result, 'top') end
    if right > self.width then table.insert(result, 'right') end
    if bottom > self.height then table.insert(result, 'bottom') end

    if #result > 0 then
        return result
    end

    -- 当たりフラグ
    local isHit = false

    for v, line in ipairs(self.colorArray) do
        for h, color in ipairs(line) do
            local tx, ty = h, v
            if (tx >= left) and (ty >= top) and (tx <= right) and (ty <= bottom) then
                local i, j = tx - left + bleft, ty - top + btop
                if colorArray[j][i] and line[h] then
                    table.insert(result, 'hit')
                    isHit = true
                    break
                end
            end
        end
        if isHit then
            break
        end
    end

    return #result > 0 and result or nil
end

-- ブロックのマージ
function Stage:merge(xOrTetrimino, y, colorArray)
    local x = 0

    -- 最初の引数がテーブルなら Tetrimino クラスとして見做す
    if type(xOrTetrimino) == 'table' then
        x, y = xOrTetrimino:toBlockDimensions()
        colorArray = xOrTetrimino.colorArray
    else
        x = xOrTetrimino or 0
        y = y or 0
        if colorArray == nil then return false end
    end

    -- 配列のサイズ
    local left, top, right, bottom = Tetrimino.getArrayRect(colorArray)
    local bleft, btop = left, top
    left, top = left + x, top + y
    right, bottom = right + x, bottom + y

    -- マイナス方向にはみ出していたら失敗
    if left < 1 then return false end
    if top < 1 then return false end

    -- 高さ拡張
    local height = right
    if height > #self.colorArray then
        while height >= #self.colorArray do
            table.insert(self.colorArray, {})
        end
    end

    -- 幅拡張
    local width = bottom
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
            if (h >= left) and (v >= top) and (h <= right) and (v <= bottom) then
                local i, j = h - left + bleft, v - top + btop
                if colorArray[j] == nil then
                    print('j', j)
                elseif colorArray[j][i] == nil then
                    print('j', j, 'i', i)
                elseif colorArray[j][i] then
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

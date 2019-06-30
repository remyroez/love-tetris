
local folderOfThisFile = (...):gsub("%.init$", "") .. "."

-- ゲーム
local Game = require(folderOfThisFile .. 'class')

require(folderOfThisFile .. 'main')

return Game

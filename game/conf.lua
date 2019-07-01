-- on love
if love.filesystem then
	-- loverocks
	--require 'rocks' ()

	-- src
	love.filesystem.setRequirePath("src/?.lua;src/?/init.lua;" .. love.filesystem.getRequirePath())

	-- modules
	love.filesystem.setRequirePath("modules/?.lua;modules/?/init.lua;" .. love.filesystem.getRequirePath())

	-- lib
	love.filesystem.setRequirePath("lib/?;lib/?.lua;lib/?/init.lua;" .. love.filesystem.getRequirePath())
end

-- https://love2d.org/wiki/Config_Files
function love.conf(t)
	t.identity = 'love-tetris'
	t.version = '11.2'

	t.window.title = "TETRIS"
end

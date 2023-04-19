import 'luaunit/playdate_luaunit_fix'
import 'luaunit/luaunit'
import 'tests'

local gfx = playdate.graphics
local cnt = kTextAlignment.center

-- turns off updating
playdate.stop()
gfx.drawTextAligned("*TESTING…*", 200, 110, cnt)
gfx.drawTextAligned("open console", 200, 132, cnt)

-- when outputting a table, include a table address
luaunit.PRINT_TABLE_REF_IN_ERROR_MSG = true

-- process the command line args (if any)
local testOutputFilename = "test_output"
local outputType = "text"
local luaunit_args = {'--output', 'text', '--verbose', '-r'}

-- run the tests
local returnValue = luaunit.LuaUnit.run(table.unpack(luaunit_args))

gfx.fillRect(0, 106, 400, 24)
gfx.setImageDrawMode(playdate.graphics.kDrawModeInverted)
gfx.drawTextAligned(returnValue == 0 and "*SUCCESS*" or "*FAIL*", 200, 110, cnt)

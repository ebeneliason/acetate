import "../acetate.lua"
import "CoreLibs/object"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics
local lu <const> = luaunit

-- a stub of a sprite class
class('S').extends(gfx.sprite)
function S:init() S.super.init(self) end

class('S2').extends(gfx.sprite)
function S2:init() S2.super.init(self) end

class('S3').extends(gfx.sprite)
function S3:init() S3.super.init(self) end

-- to hold the sprites we'll test with (populated in setUp)
local sprites = {}

-- a mock function which detects when it's been called
local flags = {}

function setFlag(key, verbose)
    key = key or "default"
    flags[key] = false
    return function()
        flags[key] = true
        if verbose then print("FLAGGED: " .. key) end
    end
end

function getFlag(key)
    return flags[key or "default"]
end

-- random number conveniences
function rnd(n) return n and math.random(n) or math.random() end
function rndN(n) return math.random(1, n) end
function rnd100() return rndN(100) end
function rnd1K() return rndN(1000) end
function rndBool() return rnd() > 0.5 and true or false end

-- a list of random numbers
local rnds = {}
for i = 1, 9 do
    rnds[i] = rnd1K()
end

-- We have to initialize it before we can run tests
acetate.init()


TestContext = {}

function TestContext:setUp()
end

function TestContext:tearDown()
    playdate.keyPressed = nil
    playdate.debugDraw = nil
    acetate._keyPressed = nil
    acetate._debugDraw = nil
end

function TestContext:testOnlyInitializedInSimulator()
    acetate.init()

    if playdate.isSimulator then
        lu.assertTrue(acetate.initialized)
        lu.assertEquals(acetate.keyPressed, playdate.keyPressed)
        lu.assertEquals(acetate.debugDraw, playdate.debugDraw)
        lu.assertNotNil(acetate.debugFont)
        lu.assertNotNil(acetate.drawCenters)
    else
        lu.assertNil(acetate.initialized)
        lu.assertNotEquals(acetate.keyPressed, playdate.keyPressed)
        lu.assertNotEquals(acetate.debugDraw, playdate.debugDraw)
        lu.assertIsNil(acetate.debugFont)
        lu.assertIsNil(acetate.drawCenters)
    end
end

TestSettings = {}

function TestSettings:setUp()
    if not playdate.isSimulator then lu.skip("Test invalid on device hardware") end
end

function TestSettings:tearDown()
    playdate.keyPressed = nil
    playdate.debugDraw = nil
    acetate._keyPressed = nil
    acetate._debugDraw = nil
end

function TestSettings:testDefaults()
    acetate.init()

    lu.assertEquals(acetate.drawCenters, true)
    lu.assertEquals(acetate.drawBounds, true)
    lu.assertEquals(acetate.drawOrientations, true)
    lu.assertEquals(acetate.drawCollideRects, false)

    lu.assertEquals(acetate.color, {0, 255, 255, 0.75})
    lu.assertEquals(acetate.lineWidth, 1)

    lu.assertEquals(acetate.centerRadius, 2)
    lu.assertEquals(acetate.minOrientationOrbRadius, 10)
    lu.assertEquals(acetate.orientationOrbScale, 0.5)
    lu.assertEquals(acetate.onlyDrawRotatedOrbs, true)
    lu.assertEquals(acetate.customDebugDrawing, true)
    lu.assertEquals(acetate.customOverridesDefaults, false)

    lu.assertEquals(acetate.showFPS, false)
    lu.assertEquals(acetate.FPSPersists, true)

    lu.assertEquals(acetate.showSpriteCount, false)
    lu.assertEquals(acetate.spriteCountPersists, true)
    lu.assertEquals(acetate.alwaysShowSpriteNames, true)

    lu.assertEquals(acetate.showDebugString, true)
    lu.assertEquals(acetate.defaultDebugStringFormat, "$n   \nX: $x\nY: $y\nW: $w\nH: $h\n")
    lu.assertEquals(acetate.debugStringPosition, { x=2, y=2 })
    lu.assertEquals(acetate.debugFontPath, "fonts/Acetate-Mono-Bold-Condensed")
    lu.assertEquals(acetate.showShortcuts, false)

    lu.assertEquals(acetate.toggleDebugModeKey    , "d")
    lu.assertEquals(acetate.toggleCentersKey      , "c")
    lu.assertEquals(acetate.toggleBoundsKey       , "b")
    lu.assertEquals(acetate.toggleOrientationsKey , "v")
    lu.assertEquals(acetate.toggleCollideRectsKey , "x")
    lu.assertEquals(acetate.toggleInvisiblesKey   , "z")
    lu.assertEquals(acetate.toggleCustomDrawKey   , "m")
    lu.assertEquals(acetate.toggleFPSKey          , "f")
    lu.assertEquals(acetate.toggleSpriteCountKey  , "n")
    lu.assertEquals(acetate.toggleDebugStringKey  , "?")
    lu.assertEquals(acetate.cycleForwardKey       , ".")
    lu.assertEquals(acetate.cycleBackwardKey      , ",")
    lu.assertEquals(acetate.cycleForwardInClassKey, ">")
    lu.assertEquals(acetate.cycleBackwardInClassKey,"<")
    lu.assertEquals(acetate.togglePauseKey        , "p")
    lu.assertEquals(acetate.captureScreenshotKey  , "q")

    lu.assertEquals(acetate.spriteScreenshotsEnabled, true)
    lu.assertEquals(acetate.defaultScreenshotPath, "~/Desktop")

    lu.assertEquals(acetate.retainFocusOnDisable, true)
    lu.assertEquals(acetate.focusInvisibleSprites, false)
    lu.assertEquals(acetate.animateBoundsForFocus, true)

    lu.assertEquals(acetate.enabled, false)
    lu.assertEquals(acetate.paused, false)
    lu.assertEquals(acetate.autoPause, false)

    acetate.debugStringPosition.x = 123
    lu.assertNotEquals(acetate.debugStringPosition.x, acetate.defaults.debugStringPosition.x)
end

function TestSettings:testCanOverrideDefaults()
    -- initialize with custom settings
    acetate.init({
        drawCenters = false,
        lineWidth = 2,
        captureScreenshotKey = "0"
    })

    -- confirm the overridden values are set properly
    lu.assertIsFalse(acetate.drawCenters)
    lu.assertEquals(acetate.lineWidth, 2)
    lu.assertEquals(acetate.captureScreenshotKey, "0")

    -- confirm all other defaults are set properly
    for k, v in pairs(acetate.defaults) do
        if k ~= "drawCenters" and k ~= "lineWidth" and k ~= "captureScreenshotKey" then
            lu.assertEquals(acetate[k], v)
        end
    end
end

function TestSettings:testRestoreDefaults()
    -- initialize with custom settings
    acetate.init({
        drawCenters = false,
        lineWidth = 2,
        captureScreenshotKey = "0"
    })

    -- confirm the overridden values are set properly
    lu.assertIsFalse(acetate.drawCenters)
    lu.assertEquals(acetate.lineWidth, 2)
    lu.assertEquals(acetate.captureScreenshotKey, "0")

    -- restore defaults
    acetate.restoreDefaults()

    -- confirm all defaults are set properly
    for k, v in pairs(acetate.defaults) do
        lu.assertEquals(acetate[k], v)
    end
end

function TestSettings:testDebugDrawFunctionWrapping()
    playdate.debugDraw = setFlag()
    local orig = playdate.debugDraw
    acetate.init()
    -- validate that a new debugDraw function was installed
    lu.assertNotEquals(playdate.debugDraw, orig)
    -- call the new function
    playdate.debugDraw()
    -- validate that the origionl debugDraw function got called
    lu.assertIsTrue(getFlag())
end

function TestSettings:testKeyPressedFunctionWrapping()
    playdate.keyPressed = setFlag()
    local orig = playdate.keyPressed
    acetate.init()
    -- validate that a new keyPressed function was installed
    lu.assertNotEquals(playdate.keyPressed, orig)
    -- call the new function
    playdate.keyPressed("-")
    -- validate that the origionl keyPressed function got called
    lu.assertIsTrue(getFlag())
end


TestDrawing = {}

function TestDrawing:setUp()
    if not playdate.isSimulator then lu.skip("Test invalid on device hardware") end

    gfx.sprite.removeAll()
    acetate.enable()
    acetate.customOverridesDefaults = false
end

function TestDrawing:tearDown()
    gfx.sprite.removeAll()
end

function TestDrawing:TestDrawCenters()
    local s = S()
    s:add()

    -- draws when enabled
    s.drawCenter = setFlag("drawCenter")
    acetate.drawCenters = true
    acetate.debugDraw()
    lu.assertIsTrue(getFlag("drawCenter"))

    -- doesn't draw when disabled
    s.drawCenter = setFlag("drawCenter")
    acetate.drawCenters = false
    acetate.debugDraw()
    lu.assertIsFalse(getFlag("drawCenter"))

    -- doesn't draw when overridden
    s.drawCenter = setFlag("drawCenter")
    s.debugDraw = setFlag("debugDraw")
    acetate.drawCenters = true
    acetate.customOverridesDefaults = true
    acetate.debugDraw()
    lu.assertIsFalse(getFlag("drawCenter"))
    lu.assertIsTrue(getFlag("debugDraw"))
end

function TestDrawing:TestDrawBounds()
    gfx.sprite.removeAll()
    local s = S()
    s:add()

    -- draws when enabled
    s.drawBounds = setFlag("drawBounds")
    acetate.drawBounds = true
    acetate.debugDraw()
    lu.assertIsTrue(getFlag("drawBounds"))

    -- doesn't draw when disabled
    s.drawBounds = setFlag("drawBounds")
    acetate.drawBounds = false
    acetate.debugDraw()
    lu.assertIsFalse(getFlag("drawBounds"))

    -- doesn't draw when overridden
    s.drawBounds = setFlag("drawBounds")
    s.debugDraw = setFlag("debugDraw")
    acetate.drawBounds = true
    acetate.customOverridesDefaults = true
    acetate.debugDraw()
    lu.assertIsFalse(getFlag("drawBounds"))
    lu.assertIsTrue(getFlag("debugDraw"))
end

TestDebugStrings = {}

function TestDebugStrings:setUp()
    if not playdate.isSimulator then lu.skip("Test invalid on device hardware") end
    playdate.graphics.sprite.removeAll()
end

function TestDebugStrings:tearDown()
    playdate.graphics.sprite.removeAll()
end

function TestDebugStrings:testDefaultDebugString()
    acetate.init()

    local s = S()
    s:moveTo(rnds[1], rnds[2])
    s:setSize(rnds[3], rnds[4])

    local x, y = s:getPosition()
    local w, h = s:getSize()

    -- default debug strings work for basic sprites
    local str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, "S   \n"   ..
        "X: " .. x .. "\n"     ..
        "Y: " .. y .. "\n"     ..
        "W: " .. w .. "\n"     ..
        "H: " .. h .. "\n"
    )
end

function TestDebugStrings:testDebugName()
    acetate.init()

    local s = S()
    s:moveTo(rnds[1], rnds[2])
    s:setSize(rnds[3], rnds[4])

    local x, y = s:getPosition()
    local w, h = s:getSize()

    -- custom debug name is used in formatted debug string
    s.debugName = "Foo"
    local str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, "Foo   \n"   ..
        "X: " .. x .. "\n"     ..
        "Y: " .. y .. "\n"     ..
        "W: " .. w .. "\n"     ..
        "H: " .. h .. "\n"
    )
end

function TestDebugStrings:testLegacyDebugString()
    acetate.init()

    local s = S()
    s:moveTo(rnds[1], rnds[2])
    s:setSize(rnds[3], rnds[4])

    -- test that custom debugString is used
    s.debugString = "Custom String"
    local str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, "Custom String")
end

function TestDebugStrings:testLegacyDebugStringFormat()
    acetate.init()

    local s = S()
    s:moveTo(rnds[1], rnds[2])
    s:setSize(rnds[3], rnds[4])

    -- test that custom debugStringFormat is used
    s.debugStringFormat = "($x, $y), $w x $h"

    local x, y = s:getPosition()
    local w, h = s:getSize()
    local str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, "(" .. x .. ", " .. y .. "), " .. w .. " x " .. h .. "")
end

function TestDebugStrings:testDebugStringFunction()
    acetate.init()

    local s = S()
    s:moveTo(rnds[1], rnds[2])
    s:setSize(rnds[3], rnds[4])

    -- test that custom debugString is used and substituted
    s.debugString = function()
        return "($x, $y) should not be substituted"
    end
    local str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, "($x, $y) should not be substituted")
end

function TestDebugStrings:testDebugStringFunctionSubstitution()
    acetate.init()

    local s = S()
    s:moveTo(rnds[1], rnds[2])
    s:setSize(rnds[3], rnds[4])

    local x, y = s:getPosition()
    local w, h = s:getSize()

    -- test that custom debugString is used
    s.debugString = function()
        return "($x, $y) should be substituted", true
    end
    local str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, "(" .. x .. ", " .. y .. ") should be substituted")
end

function TestDebugStrings:testAllSubstitutions()
    acetate.init()

    local s = S()
    s:moveTo(rnd100(), rnd100())
    s:setSize(rnd100(), rnd100())
    s:setCenter(rnd(), rnd())
    s:setRotation(rnd100())
    s:setScale(rnd100())
    s:setTag(rnd100())
    s:setZIndex(rnd100())
    s.debugName = "foo"
    s:add()

    local x,  y  = s.x, s.y
    local w,  h  = s:getSize()
    local cx, cy = s:getLocalCenter()
    local Cx, Cy = s:getWorldCenter()
    local rx, ry = s:getCenter()
    local ox, oy = s:getLocalOrigin()
    local Ox, Oy = s:getWorldOrigin()
    local r      = s:getRotation()
    local sc     = s:getScale()
    local t      = s:getTag()
    local z      = s:getZIndex()
    local fps    = playdate.getFPS() -- luacheck: ignore
    local num    = #playdate.graphics.sprite.getAllSprites()
    local n      = s.debugName or s.className

    local str

    -- test x, y
    s.debugString = function() return "$x, $y", true end
    str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, x .. ", " .. y)

    -- test width and height
    s.debugString = function() return "$w, $h", true end
    str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, w .. ", " .. h)

    -- test local center
    s.debugString = function() return "[$cx, $cy], $c", true end
    str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, "[" .. cx .. ", " .. cy .. "], (" .. cx .. ", " .. cy .. ")")

    -- test world center
    s.debugString = function() return "[$Cx, $Cy], $C", true end
    str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, "[" .. Cx .. ", " .. Cy .. "], (" .. Cx .. ", " .. Cy .. ")")

    -- test relative center
    s.debugString = function() return "[$rx, $ry], $rc", true end
    str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, "[" .. rx .. ", " .. ry .. "], (" .. rx .. ", " .. ry .. ")")

    -- test local origin
    s.debugString = function() return "[$ox, $oy], $o", true end
    str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, "[" .. ox .. ", " .. oy .. "], (" .. ox .. ", " .. oy .. ")")

    -- test world center
    s.debugString = function() return "[$Ox, $Oy], $O", true end
    str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, "[" .. Ox .. ", " .. Oy .. "], (" .. Ox .. ", " .. Oy .. ")")

    -- test rotation in both radians and degrees
    s.debugString = function() return "$d, $r", true end
    str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, r .. ", " .. math.rad(r))

    -- test scale
    s.debugString = function() return "$s", true end
    str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, tostring(sc))

    -- test tag
    s.debugString = function() return "$t", true end
    str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, tostring(t))

    -- test z-index
    s.debugString = function() return "$z", true end
    str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, tostring(z))

    -- test FPS
    s.debugString = function() return "$f", true end
    str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, tostring(fps))

    -- test number of sprites
    s.debugString = function() return "$#", true end
    str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, "1")

    -- test name
    s.debugString = function() return "$n", true end
    str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, "foo")

    -- test visibility
    s.debugString = function() return "$v", true end
    s:setVisible(false)
    str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, "INVISIBLE")
    s:setVisible(true)
    str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, "VISIBLE")

    -- test opacity
    s.debugString = function() return "$q", true end
    s:setOpaque(false)
    str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, "TRANSPARENT")
    s:setOpaque(true)
    str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, "OPAQUE")

    -- test updating
    s.debugString = function() return "$u", true end
    s:setUpdatesEnabled(true)
    str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, "UPDATING")
    s:setUpdatesEnabled(false)
    str = acetate.formatDebugStringForSprite(s)
    lu.assertEquals(str, "DISABLED")

end


TestKeyHandlers = {}

local mockedFns = {}
function TestKeyHandlers:setUp()
    if not playdate.isSimulator then lu.skip("Test invalid on device hardware") end

    acetate.init(acetate.defaults)

    mockedFns.cycleFocusForward = acetate.cycleFocusForward
    mockedFns.cycleFocusBackward = acetate.cycleFocusBackward
    mockedFns.captureScreenshot = acetate.captureScreenshot
end

function TestKeyHandlers:tearDown()
    acetate.cycleFocusForward = mockedFns.cycleFocusForward
    acetate.cycleFocusBackward = mockedFns.cycleFocusBackward
    acetate.captureScreenshot = mockedFns.captureScreenshot
    acetate.focusedSprite = nil
end

function TestKeyHandlers:testDebugToggle()
    acetate.disable()
    acetate.keyPressed(acetate.toggleDebugModeKey)
    lu.assertEquals(acetate.enabled, true)
end

function TestKeyHandlers:testPauseToggle()
    acetate.unpause()
    acetate.keyPressed(acetate.togglePauseKey)
    lu.assertEquals(acetate.paused, true)
end

function TestKeyHandlers:testFPSToggle()
    acetate.showFPS = false
    acetate.keyPressed(acetate.toggleFPSKey)
    lu.assertEquals(acetate.showFPS, true)
end

function TestKeyHandlers:testSpriteCountToggle()
    acetate.showSpriteCount = false
    acetate.keyPressed(acetate.toggleSpriteCountKey)
    lu.assertEquals(acetate.showSpriteCount, true)
end

function TestKeyHandlers:testScreenshotKey()
    acetate.captureScreenshot = setFlag()
    acetate.keyPressed(acetate.captureScreenshotKey)
    lu.assertIsTrue(getFlag())
end

function TestKeyHandlers:testKeysInactiveWhileDisabled()
    acetate.disable()
    lu.assertEquals(acetate.enabled, false)

    local before

    before = acetate.drawCenters
    acetate.keyPressed(acetate.toggleCentersKey)
    lu.assertEquals(acetate.drawCenters, before)

    before = acetate.drawBounds
    acetate.keyPressed(acetate.toggleBoundsKey)
    lu.assertEquals(acetate.drawBounds, before)

    before = acetate.drawOrientations
    acetate.keyPressed(acetate.toggleOrientationsKey)
    lu.assertEquals(acetate.drawOrientations, before)

    before = acetate.drawCollideRects
    acetate.keyPressed(acetate.toggleCollideRectsKey)
    lu.assertEquals(acetate.drawCollideRects, before)

    before = acetate.focusInvisibleSprites
    acetate.keyPressed(acetate.toggleInvisiblesKey)
    lu.assertEquals(acetate.focusInvisibleSprites, before)

    before = acetate.customDebugDrawing
    acetate.keyPressed(acetate.toggleCustomDrawKey)
    lu.assertEquals(acetate.customDebugDrawing, before)

    before = acetate.drawCollideRects
    acetate.keyPressed(acetate.toggleCollideRectsKey)
    lu.assertEquals(acetate.drawCollideRects, before)

    before = acetate.showDebugString
    acetate.keyPressed(acetate.toggleDebugStringKey)
    lu.assertEquals(acetate.showDebugString, before)

    before = acetate.showShortcuts
    acetate.keyPressed("?")
    lu.assertEquals(acetate.showShortcuts, before)

    acetate.cycleFocusForward = setFlag()
    acetate.keyPressed(acetate.cycleForwardKey)
    lu.assertIsFalse(getFlag())

    acetate.cycleFocusBackward = setFlag()
    acetate.keyPressed(acetate.cycleBackwardKey)
    lu.assertIsFalse(getFlag())

    acetate.cycleFocusForwardInClass = setFlag()
    acetate.keyPressed(acetate.cycleForwardInClassKey)
    lu.assertIsFalse(getFlag())

    acetate.cycleFocusBackwardInClass = setFlag()
    acetate.keyPressed(acetate.cycleBackwardInClassKey)
    lu.assertIsFalse(getFlag())

    acetate.toggleClassFocusLock = setFlag()
    acetate.keyPressed(acetate.toggleClassFocusLockKey)
    lu.assertIsFalse(getFlag())
end

function TestKeyHandlers:testKeysActiveWhileEnabled()
    acetate.enable()
    lu.assertIsTrue(acetate.enabled)

    local before

    before = acetate.drawCenters
    acetate.keyPressed(acetate.toggleCentersKey)
    lu.assertNotEquals(acetate.drawCenters, before)

    before = acetate.drawBounds
    acetate.keyPressed(acetate.toggleBoundsKey)
    lu.assertNotEquals(acetate.drawBounds, before)

    before = acetate.drawOrientations
    acetate.keyPressed(acetate.toggleOrientationsKey)
    lu.assertNotEquals(acetate.drawOrientations, before)

    before = acetate.drawCollideRects
    acetate.keyPressed(acetate.toggleCollideRectsKey)
    lu.assertNotEquals(acetate.drawCollideRects, before)

    before = acetate.focusInvisibleSprites
    acetate.keyPressed(acetate.toggleInvisiblesKey)
    lu.assertNotEquals(acetate.focusInvisibleSprites, before)

    before = acetate.customDebugDrawing
    acetate.keyPressed(acetate.toggleCustomDrawKey)
    lu.assertNotEquals(acetate.customDebugDrawing, before)

    before = acetate.drawCollideRects
    acetate.keyPressed(acetate.toggleCollideRectsKey)
    lu.assertNotEquals(acetate.drawCollideRects, before)

    acetate.focusedSprite = nil

    -- this shouldn't change unless there's a focused sprite
    before = acetate.showDebugString
    acetate.keyPressed(acetate.toggleDebugStringKey)
    lu.assertEquals(acetate.showDebugString, before)

    -- this should only change when there's a focused sprite
    before = acetate.showShortcuts
    acetate.keyPressed("?")
    lu.assertNotEquals(acetate.showShortcuts, before)

    -- give ourselves a focus (any truthy value works)
    acetate.focusedSprite = true

    -- this should only change when there's a focused sprite
    before = acetate.showDebugString
    acetate.keyPressed(acetate.toggleDebugStringKey)
    lu.assertNotEquals(acetate.showDebugString, before)

    -- this shouldn't change if there's a focused sprite
    before = acetate.showShortcuts
    acetate.keyPressed("?")
    lu.assertEquals(acetate.showShortcuts, before)

    acetate.cycleFocusForward = setFlag()
    acetate.keyPressed(acetate.cycleForwardKey)
    lu.assertIsTrue(getFlag())

    acetate.cycleFocusBackward = setFlag()
    acetate.keyPressed(acetate.cycleBackwardKey)
    lu.assertIsTrue(getFlag())

    acetate.cycleFocusForwardInClass = setFlag()
    acetate.keyPressed(acetate.cycleForwardInClassKey)
    lu.assertIsTrue(getFlag())

    acetate.cycleFocusBackwardInClass = setFlag()
    acetate.keyPressed(acetate.cycleBackwardInClassKey)
    lu.assertIsTrue(getFlag())

    acetate.toggleFocusLock = setFlag()
    acetate.keyPressed(acetate.toggleFocusLockKey)
    lu.assertIsTrue(getFlag())
end

function TestKeyHandlers:testAltSymbolForKey()
    lu.assertEquals(acetate.altSymbolForKey(","), "<")
    lu.assertEquals(acetate.altSymbolForKey("<"), ",")

    lu.assertEquals(acetate.altSymbolForKey("."), ">")
    lu.assertEquals(acetate.altSymbolForKey(">"), ".")

    lu.assertEquals(acetate.altSymbolForKey("/"), "?")
    lu.assertEquals(acetate.altSymbolForKey("?"), "/")
end

function TestKeyHandlers:testKeyMatch()
    lu.assertIsTrue(acetate.keyMatch(",", "<"))
    lu.assertIsTrue(acetate.keyMatch("<", ","))

    lu.assertIsTrue(acetate.keyMatch(".", ">"))
    lu.assertIsTrue(acetate.keyMatch(">", "."))

    lu.assertIsTrue(acetate.keyMatch("/", "?"))
    lu.assertIsTrue(acetate.keyMatch("?", "/"))
end

function TestKeyHandlers:testShortcutStringAdaptsToSettings()
    local shortcutString = acetate.shortcutString()

    lu.assertNotNil(shortcutString:match("%[c%] centers"))
    lu.assertNotNil(shortcutString:match("%[b%] bounds"))
    lu.assertNotNil(shortcutString:match("%[v%] orientations"))
    lu.assertNotNil(shortcutString:match("%[x%] collide rects"))
    lu.assertNotNil(shortcutString:match("%[z%] invisible"))
    lu.assertNotNil(shortcutString:match("%[m%] custom"))
    lu.assertNotNil(shortcutString:match("%[?%] sprite info"))
    lu.assertNotNil(shortcutString:match("%[f%] FPS"))
    lu.assertNotNil(shortcutString:match("%[n%] sprite count"))
    lu.assertNotNil(shortcutString:match("%[p%] Pause"))
    lu.assertNotNil(shortcutString:match("%[.%] Next"))
    lu.assertNotNil(shortcutString:match("%[,%] Back"))
    lu.assertNotNil(shortcutString:match("%[q%] Screenshot"))

    acetate.toggleCentersKey      = "1"
    acetate.toggleBoundsKey       = "2"
    acetate.toggleOrientationsKey = "3"
    acetate.toggleCollideRectsKey = "4"
    acetate.toggleInvisiblesKey   = "5"
    acetate.toggleCustomDrawKey   = "6"
    acetate.toggleDebugStringKey  = "7"
    acetate.toggleFPSKey          = "8"
    acetate.toggleSpriteCountKey  = "9"
    acetate.togglePauseKey        = "0"
    acetate.cycleForwardKey       = "]"
    acetate.cycleBackwardKey      = "["
    acetate.captureScreenshotKey  = "~"

    shortcutString = acetate.shortcutString()

    lu.assertNotNil(shortcutString:match("%[1%] centers"))
    lu.assertNotNil(shortcutString:match("%[2%] bounds"))
    lu.assertNotNil(shortcutString:match("%[3%] orientations"))
    lu.assertNotNil(shortcutString:match("%[4%] collide rects"))
    lu.assertNotNil(shortcutString:match("%[5%] invisible"))
    lu.assertNotNil(shortcutString:match("%[6%] custom"))
    lu.assertNotNil(shortcutString:match("%[7%] sprite info"))
    lu.assertNotNil(shortcutString:match("%[8%] FPS"))
    lu.assertNotNil(shortcutString:match("%[9%] sprite count"))
    lu.assertNotNil(shortcutString:match("%[0%] Pause"))
    lu.assertNotNil(shortcutString:match("%[%]%] Next"))
    lu.assertNotNil(shortcutString:match("%[%[%] Back"))
    lu.assertNotNil(shortcutString:match("%[~%] Screenshot"))
end


TestFocusHandling = {}

function TestFocusHandling:setUp()
    if not playdate.isSimulator then lu.skip("Test invalid on device hardware") end

    gfx.sprite.removeAll()
    for i = 1, 3 do
        local s = S()
        s:add()
        sprites[i] = s
    end
end

function TestFocusHandling:tearDown()
    sprites = {}
end

function TestFocusHandling:testFocusSprite()
    acetate.focusedSprite = nil
    acetate.setFocus(sprites[1])
    lu.assertEquals(acetate.focusedSprite, sprites[1])
    acetate.setFocus(sprites[2])
    lu.assertEquals(acetate.focusedSprite, sprites[2])
    acetate.setFocus(sprites[3])
    lu.assertEquals(acetate.focusedSprite, sprites[3])
end

function TestFocusHandling:testFocusForInvisibleSprites()
    acetate.focusedSprite = nil
    sprites[1]:setVisible(false)

    acetate.focusInvisibleSprites = false
    acetate.setFocus(sprites[1])
    lu.assertIsNil(acetate.focusedSprite)

    acetate.focusInvisibleSprites = true
    acetate.setFocus(sprites[1])
    lu.assertEquals(acetate.focusedSprite, sprites[1])
end

function TestFocusHandling:testFocusForUnaddedSprites()
    local s = gfx.sprite.new()
    acetate.focusedSprite = nil
    acetate.setFocus(s)
    lu.assertIsNil(acetate.focusedSprite)
end

function TestFocusHandling:releaseFocus()
    acetate.setFocus(sprites[3])
    assertEquals(acetate.focusedSprite, sprites[3])
    acetate.releaseFocus()
    lu.assertIsNil(acetate.focusedSprite)
end

function TestFocusHandling:testCycleFocusForward()
    acetate.focusedSprite = nil

    -- cycles through all sprites
    lu.assertEquals(acetate.focusedSprite, nil)
    acetate.cycleFocusForward()
    lu.assertEquals(acetate.focusedSprite, sprites[1])
    acetate.cycleFocusForward()
    lu.assertEquals(acetate.focusedSprite, sprites[2])
    acetate.cycleFocusForward()
    lu.assertEquals(acetate.focusedSprite, sprites[3])
    acetate.cycleFocusForward()
    lu.assertEquals(acetate.focusedSprite, nil)

    -- skips invisible sprites when appropriate
    sprites[2]:setVisible(false)
    acetate.focusInvisibleSprites = false

    lu.assertEquals(acetate.focusedSprite, nil)
    acetate.cycleFocusForward()
    lu.assertEquals(acetate.focusedSprite, sprites[1])
    acetate.cycleFocusForward()
    lu.assertEquals(acetate.focusedSprite, sprites[3])
    acetate.cycleFocusForward()
    lu.assertEquals(acetate.focusedSprite, nil)

    -- focuses invisible sprites when appropriate
    acetate.focusInvisibleSprites = true

    lu.assertEquals(acetate.focusedSprite, nil)
    acetate.cycleFocusForward()
    lu.assertEquals(acetate.focusedSprite, sprites[1])
    acetate.cycleFocusForward()
    lu.assertEquals(acetate.focusedSprite, sprites[2])
    acetate.cycleFocusForward()
    lu.assertEquals(acetate.focusedSprite, sprites[3])
    acetate.cycleFocusForward()
    lu.assertEquals(acetate.focusedSprite, nil)
end

function TestFocusHandling:testCycleFocusBackward()
    acetate.focusedSprite = nil

    -- cycles through all sprites
    lu.assertEquals(acetate.focusedSprite, nil)
    acetate.cycleFocusBackward()
    lu.assertEquals(acetate.focusedSprite, sprites[3])
    acetate.cycleFocusBackward()
    lu.assertEquals(acetate.focusedSprite, sprites[2])
    acetate.cycleFocusBackward()
    lu.assertEquals(acetate.focusedSprite, sprites[1])
    acetate.cycleFocusBackward()
    lu.assertEquals(acetate.focusedSprite, nil)

    -- skips invisible sprites when appropriate
    sprites[2]:setVisible(false)
    acetate.focusInvisibleSprites = false

    lu.assertEquals(acetate.focusedSprite, nil)
    acetate.cycleFocusBackward()
    lu.assertEquals(acetate.focusedSprite, sprites[3])
    acetate.cycleFocusBackward()
    lu.assertEquals(acetate.focusedSprite, sprites[1])
    acetate.cycleFocusBackward()
    lu.assertEquals(acetate.focusedSprite, nil)

    -- focuses invisible sprites when appropriate
    acetate.focusInvisibleSprites = true

    lu.assertEquals(acetate.focusedSprite, nil)
    acetate.cycleFocusBackward()
    lu.assertEquals(acetate.focusedSprite, sprites[3])
    acetate.cycleFocusBackward()
    lu.assertEquals(acetate.focusedSprite, sprites[2])
    acetate.cycleFocusBackward()
    lu.assertEquals(acetate.focusedSprite, sprites[1])
    acetate.cycleFocusBackward()
    lu.assertEquals(acetate.focusedSprite, nil)
end

function TestFocusHandling:updateFocus()

    -- focus updates when made invisible
    acetate.focusedSprite = sprites[2]
    lu.assertEquals(acetate.focusedSprite, sprites[2])
    sprites[2]:setVisible(false)
    acetate.updateFocus()
    lu.assertIsNil(acetate.focusedSprite)

    -- focus updates when removed
    acetate.focusedSprite = sprites[3]
    lu.assertEquals(acetate.focusedSprite, sprites[3])
    sprites[3]:remove()
    acetate.updateFocus()
    lu.assertIsNil(acetate.focusedSprite)
end


TestClassFocus = {}

function TestClassFocus:setUp()
    if not playdate.isSimulator then lu.skip("Test invalid on device hardware") end

    gfx.sprite.removeAll()
    for i = 1, 3 do
        local s = S()
        s:add()
        sprites[#sprites+1] = s

        s = S2()
        s:add()
        sprites[#sprites+1] = s

        s = S3()
        s:add()
        sprites[#sprites+1] = s
    end

    -- resulting ordering: S, S2, S3, S, S2, S3, S, S2, S3
    -- matching sprites are found at (index % 3) + 1
end

function TestClassFocus:tearDown()
    sprites = {}
    acetate.releaseFocus()
    acetate.releaseClassFocusLock()
end

function TestClassFocus:testClassFocusLock()
    -- test setting the focus lock
    acetate.focusedSprite = nil
    acetate.setClassFocusLock(S3)
    lu.assertEquals(acetate.focusedClass, S3)
    acetate.setClassFocusLock(S)
    lu.assertEquals(acetate.focusedClass, S)

    -- test cycling forward
    acetate.cycleFocusForward()
    lu.assertEquals(acetate.focusedSprite, sprites[1])
    acetate.cycleFocusForward()
    lu.assertEquals(acetate.focusedSprite, sprites[4])
    acetate.cycleFocusForward()
    lu.assertEquals(acetate.focusedSprite, sprites[7])
    acetate.cycleFocusForward() -- all
    lu.assertEquals(acetate.focusedSprite, nil)
    acetate.cycleFocusForward() -- loop
    lu.assertEquals(acetate.focusedSprite, sprites[1])

    -- test cycling backward
    acetate.cycleFocusBackward() -- all
    lu.assertEquals(acetate.focusedSprite, nil)
    acetate.cycleFocusBackward() -- loop
    lu.assertEquals(acetate.focusedSprite, sprites[7])
    acetate.cycleFocusBackward()
    lu.assertEquals(acetate.focusedSprite, sprites[4])
    acetate.cycleFocusBackward()
    lu.assertEquals(acetate.focusedSprite, sprites[1])

    -- test releasing the focus lock
    acetate.releaseClassFocusLock()
    lu.assertEquals(acetate.focusedClass, nil)
end

function TestClassFocus:testImplicitReleaseOfFocusLockDueToSetFocus()
    -- set the focus lock
    acetate.setClassFocusLock(S)
    lu.assertEquals(acetate.focusedClass, S)
    lu.assertEquals(acetate.focusedSprite, nil)

    -- set a sprite matching current focus lock
    acetate.setFocus(sprites[1])
    lu.assertEquals(acetate.focusedClass, S)
    lu.assertEquals(acetate.focusedSprite, sprites[1])

    -- implicitly release
    acetate.setFocus(sprites[2]) -- will override the current focus
    lu.assertEquals(acetate.focusedClass, nil)
    lu.assertEquals(acetate.focusedSprite, sprites[2])

end

function TestClassFocus:testImplicitReleaseOfFocusLockDueToSpriteRemoval()
    -- test setting the focus lock
    acetate.setClassFocusLock(S)
    acetate.setFocus(sprites[1])
    lu.assertEquals(acetate.focusedClass, S)
    lu.assertEquals(acetate.focusedSprite, sprites[1])

    -- remove the sprites of the focused class
    sprites[1]:remove()
    sprites[4]:remove()
    sprites[7]:remove()

    -- iterate one draw loop to give state a chance to update
    acetate.debugDraw()
    lu.assertEquals(acetate.focusedSprite, nil)
    lu.assertEquals(acetate.focusedClass, nil)
end

function TestClassFocus:testImplicitReleaseOfFocusDueToSpriteVisibility()
    acetate.setFocus(sprites[1])
    acetate.toggleFocusLock()
    acetate.focusInvisibleSprites = false
    lu.assertEquals(acetate.focusedClass, S)
    lu.assertEquals(acetate.focusedSprite, sprites[1])

    -- hide the focused sprite
    sprites[1]:setVisible(false)

    -- update focus
    acetate.updateFocus()
    lu.assertEquals(acetate.focusedSprite, nil)
    lu.assertEquals(acetate.focusedClass, S)
end

function TestClassFocus:testCyclingForwardInClass()
    acetate.setFocus(sprites[1])
    lu.assertEquals(acetate.focusedSprite, sprites[1])
    acetate.cycleFocusForward(false)
    lu.assertEquals(acetate.focusedSprite, sprites[2])
    acetate.cycleFocusForward(true)
    lu.assertEquals(acetate.focusedSprite, sprites[5])
    acetate.cycleFocusForward(true)
    lu.assertEquals(acetate.focusedSprite, sprites[8])
    acetate.cycleFocusForward(true) -- loop
    lu.assertEquals(acetate.focusedSprite, sprites[2])
    acetate.cycleFocusForward(false)
    lu.assertEquals(acetate.focusedSprite, sprites[3])
end

function TestClassFocus:testCyclingBackwardInClass()
    acetate.setFocus(sprites[8])
    lu.assertEquals(acetate.focusedSprite, sprites[8])
    acetate.cycleFocusBackward(false)
    lu.assertEquals(acetate.focusedSprite, sprites[7])
    acetate.cycleFocusBackward(true)
    lu.assertEquals(acetate.focusedSprite, sprites[4])
    acetate.cycleFocusBackward(true)
    lu.assertEquals(acetate.focusedSprite, sprites[1])
    acetate.cycleFocusBackward(true) -- loop
    lu.assertEquals(acetate.focusedSprite, sprites[7])
    acetate.cycleFocusBackward(false)
    lu.assertEquals(acetate.focusedSprite, sprites[6])
end

function TestClassFocus:testToggleFocusLock()
    -- class focus does nothing when there's no focused sprite
    acetate.focusedSprite = nil
    acetate.toggleFocusLock()
    lu.assertEquals(acetate.focusedClass, nil)

    -- toggle focus on for the focused sprite
    acetate.focusedSprite = sprites[1]
    acetate.toggleFocusLock()
    lu.assertEquals(acetate.focusedClass, sprites[1].class)

    -- toggle focus off again
    acetate.toggleFocusLock()
    lu.assertEquals(acetate.focusedClass, nil)
end


TestSpriteExtensions = {}

local s

function TestSpriteExtensions:setUp()
    if not playdate.isSimulator then lu.skip("Test invalid on device hardware") end

    s = S()
    s:setSize(100, 100)
    s:setCenter(0.5, 0.5)
    s:moveTo(50, 50)
end

function TestSpriteExtensions:testGetLocalCenter()
    s:setSize(100, 100)
    s:setCenter(0.5, 0.5)
    s:moveTo(50, 50)

    local x, y = s:getLocalCenter()
    lu.assertEquals(x, 50)
    lu.assertEquals(y, 50)
end

function TestSpriteExtensions:testGetWorldCenter()
    s:setSize(100, 100)
    s:setCenter(0.5, 0.5)
    s:moveTo(50, 50)

    local x, y = s:getWorldCenter()
    lu.assertEquals(x, 50)
    lu.assertEquals(y, 50)
end

function TestSpriteExtensions:testGetLocalOrigin()
    s:setSize(100, 100)
    s:setCenter(0.5, 0.5)
    s:moveTo(50, 50)

    local x, y = s:getLocalOrigin()
    lu.assertEquals(x, -50)
    lu.assertEquals(y, -50)
end

function TestSpriteExtensions:testGetWorldOrigin()
    s:setSize(100, 100)
    s:setCenter(0.5, 0.5)
    s:moveTo(50, 50)

    local x, y = s:getWorldOrigin()
    lu.assertEquals(x, 0)
    lu.assertEquals(y, 0)
end


-- NOTE: can't fully test screenshot functionality without access to host filesystem
TestScreenshots = {}

function TestScreenshots:setUp()
    if not playdate.isSimulator then lu.skip("Test invalid on device hardware") end
    acetate.defaultScreenshotPath = "/tmp"
end

function TestScreenshots:testScreenshot()
    -- fullscreen screenshots should always work
    acetate.focusedSprite = nil
    local ret = acetate.captureScreenshot()
    lu.assertIsTrue(ret)

    local s = S()
    s:add()
    s:setSize(5,5)
    s.draw = nil

    -- no draw function
    acetate.setFocus(s)
    ret = acetate.captureScreenshot()
    lu.assertIsFalse(ret)

    s.draw = setFlag()
    s:setSize(0,0)

    -- invalid bitmap size
    acetate.setFocus(s)
    ret = acetate.captureScreenshot()
    lu.assertIsFalse(ret)

    s:setSize(5,5)

    -- success case
    acetate.setFocus(s)
    ret = acetate.captureSpriteScreenshot(s)
    lu.assertIsTrue(ret)
end

import "../acetate.lua"
import "CoreLibs/object"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics
local lu <const> = luaunit

-- a stub of a sprite class
class('S').extends(gfx.sprite)
function S:init() S.super.init(self) end

-- to hold the sprites we'll test with (populated in setUp)
local sprites = {}

-- a mock function which detects when it's been called
local flags = {}

function setFlag(key)
    key = key or "default"
    flags[key] = false
    return function() flags[key] = true end
end

function getFlag(key)
    return flags[key or "default"]
end

-- a list of random numbers
local rnd = {}
for i = 1, 9 do
    rnd[i] = math.random()
end

-- We have to initialize it before we can run tests
acetate.init()


TestContext = {}

function TestContext:testOnlyInitializedInSimulator()
    if playdate.isSimulator then
        lu.assertEquals(acetate.keyPressed, playdate.keyPressed)
        lu.assertEquals(acetate.debugDraw, playdate.debugDraw)
        lu.assertNotNil(acetate.debugFont)
        lu.assertNotNil(acetate.drawCenters)
    else
        lu.assertNotEquals(acetate.keyPressed, playdate.keyPressed)
        lu.assertNotEquals(acetate.debugDraw, playdate.debugDraw)
        lu.assertIsNil(acetate.debugFont)
        lu.assertIsNil(acetate.drawCenters)
    end
end

TestSettings = {}

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
    lu.assertEquals(acetate.cycleForwardKey       , ">")
    lu.assertEquals(acetate.cycleBackwardKey      , "<")
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


TestKeyHandlers = {}

local mockedFns = {}
function TestKeyHandlers:setUp()
    mockedFns.cycleFocusForward = acetate.cycleFocusForward
    mockedFns.cycleFocusBackward = acetate.cycleFocusBackward
    mockedFns.captureScreenshot = acetate.captureScreenshot
end

function TestKeyHandlers:tearDown()
    acetate.cycleFocusForward = mockedFns.cycleFocusForward
    acetate.cycleFocusBackward = mockedFns.cycleFocusBackward
    acetate.captureScreenshot = mockedFns.captureScreenshot
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
    lu.assertNotNil(shortcutString:match("%[>%] Next"))
    lu.assertNotNil(shortcutString:match("%[<%] Back"))
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


TestSpriteExtensions = {}

local s

function TestSpriteExtensions:setUp()
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

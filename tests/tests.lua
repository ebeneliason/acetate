import "../Acetate.lua"
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
Acetate.init()


TestContext = {}

function TestContext:testOnlyInitializedInSimulator()
    if playdate.isSimulator then
        lu.assertEquals(Acetate.keyPressed, playdate.keyPressed)
        lu.assertEquals(Acetate.debugDraw, playdate.debugDraw)
        lu.assertNotNil(Acetate.debugFont)
        lu.assertNotNil(Acetate.drawCenters)
    else
        lu.assertNotEquals(Acetate.keyPressed, playdate.keyPressed)
        lu.assertNotEquals(Acetate.debugDraw, playdate.debugDraw)
        lu.assertIsNil(Acetate.debugFont)
        lu.assertIsNil(Acetate.drawCenters)
    end
end

TestSettings = {}

function TestSettings:testDefaults()
    -- TODO: need a way to restore defaults before this test

    lu.assertEquals(Acetate.drawCenters, true)
    lu.assertEquals(Acetate.drawBounds, true)
    lu.assertEquals(Acetate.drawOrientations, true)
    lu.assertEquals(Acetate.drawCollideRects, false)

    lu.assertEquals(Acetate.color, {0, 255, 255, 0.75})
    lu.assertEquals(Acetate.lineWidth, 1)

    lu.assertEquals(Acetate.centerRadius, 2)
    lu.assertEquals(Acetate.minOrientationOrbRadius, 10)
    lu.assertEquals(Acetate.orientationOrbScale, 0.5)
    lu.assertEquals(Acetate.onlyDrawRotatedOrbs, true)
    lu.assertEquals(Acetate.customDebugDrawing, true)

    lu.assertEquals(Acetate.showFPS, false)
    lu.assertEquals(Acetate.FPSPersists, true)

    lu.assertEquals(Acetate.showSpriteCount, false)
    lu.assertEquals(Acetate.spriteCountPersists, true)
    lu.assertEquals(Acetate.alwaysShowSpriteNames, true)

    lu.assertEquals(Acetate.showDebugString, true)
    lu.assertEquals(Acetate.defaultDebugStringFormat, "$n   \nX: $x\nY: $y\nW: $w\nH: $h\n")
    lu.assertEquals(Acetate.debugStringPosition, { x=2, y=2 })
    lu.assertEquals(Acetate.debugFontPath, "fonts/Acetate-Mono-Bold-Condensed")
    lu.assertEquals(Acetate.showShortcuts, false)

    lu.assertEquals(Acetate.toggleDebugModeKey    , "d")
    lu.assertEquals(Acetate.toggleCentersKey      , "c")
    lu.assertEquals(Acetate.toggleBoundsKey       , "b")
    lu.assertEquals(Acetate.toggleOrientationsKey , "v")
    lu.assertEquals(Acetate.toggleCollideRectsKey , "x")
    lu.assertEquals(Acetate.toggleInvisiblesKey   , "z")
    lu.assertEquals(Acetate.toggleCustomDrawKey   , "m")
    lu.assertEquals(Acetate.toggleFPSKey          , "f")
    lu.assertEquals(Acetate.toggleSpriteCountKey  , "n")
    lu.assertEquals(Acetate.toggleDebugStringKey  , "?")
    lu.assertEquals(Acetate.cycleForwardKey       , ">")
    lu.assertEquals(Acetate.cycleBackwardKey      , "<")
    lu.assertEquals(Acetate.togglePauseKey        , "p")
    lu.assertEquals(Acetate.captureScreenshotKey  , "q")

    lu.assertEquals(Acetate.spriteScreenshotsEnabled, true)
    lu.assertEquals(Acetate.defaultScreenshotPath, "~/Desktop")

    lu.assertEquals(Acetate.focusedSprite, nil)
    lu.assertEquals(Acetate.retainFocusOnDisable, true)
    lu.assertEquals(Acetate.focusInvisibleSprites, false)
    lu.assertEquals(Acetate.animateBoundsForFocus, true)

    lu.assertEquals(Acetate.enabled, false)
    lu.assertEquals(Acetate.paused, false)
    lu.assertEquals(Acetate.autoPause, false)

    Acetate.debugStringPosition.x = 123
    lu.assertNotEquals(Acetate.debugStringPosition.x, Acetate.defaults.debugStringPosition.x)
end


TestKeyHandlers = {}

local mockedFns = {}
function TestKeyHandlers:setUp()
    mockedFns.cycleFocusForward = Acetate.cycleFocusForward
    mockedFns.cycleFocusBackward = Acetate.cycleFocusBackward
    mockedFns.captureScreenshot = Acetate.captureScreenshot
end

function TestKeyHandlers:tearDown()
    Acetate.cycleFocusForward = mockedFns.cycleFocusForward
    Acetate.cycleFocusBackward = mockedFns.cycleFocusBackward
    Acetate.captureScreenshot = mockedFns.captureScreenshot
end

function TestKeyHandlers:testDebugToggle()
    Acetate.disable()
    Acetate.keyPressed(Acetate.toggleDebugModeKey)
    lu.assertEquals(Acetate.enabled, true)
end

function TestKeyHandlers:testPauseToggle()
    Acetate.unpause()
    Acetate.keyPressed(Acetate.togglePauseKey)
    lu.assertEquals(Acetate.paused, true)
end

function TestKeyHandlers:testFPSToggle()
    Acetate.showFPS = false
    Acetate.keyPressed(Acetate.toggleFPSKey)
    lu.assertEquals(Acetate.showFPS, true)
end

function TestKeyHandlers:testSpriteCountToggle()
    Acetate.showSpriteCount = false
    Acetate.keyPressed(Acetate.toggleSpriteCountKey)
    lu.assertEquals(Acetate.showSpriteCount, true)
end

function TestKeyHandlers:testScreenshotKey()
    Acetate.captureScreenshot = setFlag()
    Acetate.keyPressed(Acetate.captureScreenshotKey)
    lu.assertIsTrue(getFlag())
end

function TestKeyHandlers:testKeysInactiveWhileDisabled()
    lu.assertEquals(Acetate.enabled, false)

    local before

    before = Acetate.drawCenters
    Acetate.keyPressed(Acetate.toggleCentersKey)
    lu.assertEquals(Acetate.drawCenters, before)

    before = Acetate.drawBounds
    Acetate.keyPressed(Acetate.toggleBoundsKey)
    lu.assertEquals(Acetate.drawBounds, before)

    before = Acetate.drawOrientations
    Acetate.keyPressed(Acetate.toggleOrientationsKey)
    lu.assertEquals(Acetate.drawOrientations, before)

    before = Acetate.drawCollideRects
    Acetate.keyPressed(Acetate.toggleCollideRectsKey)
    lu.assertEquals(Acetate.drawCollideRects, before)

    before = Acetate.focusInvisibleSprites
    Acetate.keyPressed(Acetate.toggleInvisiblesKey)
    lu.assertEquals(Acetate.focusInvisibleSprites, before)

    before = Acetate.customDebugDrawing
    Acetate.keyPressed(Acetate.toggleCustomDrawKey)
    lu.assertEquals(Acetate.customDebugDrawing, before)

    before = Acetate.drawCollideRects
    Acetate.keyPressed(Acetate.toggleCollideRectsKey)
    lu.assertEquals(Acetate.drawCollideRects, before)

    before = Acetate.showDebugString
    Acetate.keyPressed(Acetate.toggleDebugStringKey)
    lu.assertEquals(Acetate.showDebugString, before)

    before = Acetate.showShortcuts
    Acetate.keyPressed("?")
    lu.assertEquals(Acetate.showShortcuts, before)

    Acetate.cycleFocusForward = setFlag()
    Acetate.keyPressed(Acetate.cycleForwardKey)
    lu.assertIsFalse(getFlag())

    Acetate.cycleFocusBackward = setFlag()
    Acetate.keyPressed(Acetate.cycleBackwardKey)
    lu.assertIsFalse(getFlag())
end

function TestKeyHandlers:testKeysActiveWhileEnabled()
    Acetate.enable()
    lu.assertIsTrue(Acetate.enabled)

    local before

    before = Acetate.drawCenters
    Acetate.keyPressed(Acetate.toggleCentersKey)
    lu.assertNotEquals(Acetate.drawCenters, before)

    before = Acetate.drawBounds
    Acetate.keyPressed(Acetate.toggleBoundsKey)
    lu.assertNotEquals(Acetate.drawBounds, before)

    before = Acetate.drawOrientations
    Acetate.keyPressed(Acetate.toggleOrientationsKey)
    lu.assertNotEquals(Acetate.drawOrientations, before)

    before = Acetate.drawCollideRects
    Acetate.keyPressed(Acetate.toggleCollideRectsKey)
    lu.assertNotEquals(Acetate.drawCollideRects, before)

    before = Acetate.focusInvisibleSprites
    Acetate.keyPressed(Acetate.toggleInvisiblesKey)
    lu.assertNotEquals(Acetate.focusInvisibleSprites, before)

    before = Acetate.customDebugDrawing
    Acetate.keyPressed(Acetate.toggleCustomDrawKey)
    lu.assertNotEquals(Acetate.customDebugDrawing, before)

    before = Acetate.drawCollideRects
    Acetate.keyPressed(Acetate.toggleCollideRectsKey)
    lu.assertNotEquals(Acetate.drawCollideRects, before)

    Acetate.focusedSprite = nil

    -- this shouldn't change unless there's a focused sprite
    before = Acetate.showDebugString
    Acetate.keyPressed(Acetate.toggleDebugStringKey)
    lu.assertEquals(Acetate.showDebugString, before)

    -- this should only change when there's a focused sprite
    before = Acetate.showShortcuts
    Acetate.keyPressed("?")
    lu.assertNotEquals(Acetate.showShortcuts, before)

    -- give ourselves a focus (any truthy value works)
    Acetate.focusedSprite = true

    -- this should only change when there's a focused sprite
    before = Acetate.showDebugString
    Acetate.keyPressed(Acetate.toggleDebugStringKey)
    lu.assertNotEquals(Acetate.showDebugString, before)

    -- this shouldn't change if there's a focused sprite
    before = Acetate.showShortcuts
    Acetate.keyPressed("?")
    lu.assertEquals(Acetate.showShortcuts, before)

    Acetate.cycleFocusForward = setFlag()
    Acetate.keyPressed(Acetate.cycleForwardKey)
    lu.assertIsTrue(getFlag())

    Acetate.cycleFocusBackward = setFlag()
    Acetate.keyPressed(Acetate.cycleBackwardKey)
    lu.assertIsTrue(getFlag())
end

function TestKeyHandlers:testAltSymbolForKey()
    lu.assertEquals(Acetate.altSymbolForKey(","), "<")
    lu.assertEquals(Acetate.altSymbolForKey("<"), ",")

    lu.assertEquals(Acetate.altSymbolForKey("."), ">")
    lu.assertEquals(Acetate.altSymbolForKey(">"), ".")

    lu.assertEquals(Acetate.altSymbolForKey("/"), "?")
    lu.assertEquals(Acetate.altSymbolForKey("?"), "/")
end

function TestKeyHandlers:testKeyMatch()
    lu.assertIsTrue(Acetate.keyMatch(",", "<"))
    lu.assertIsTrue(Acetate.keyMatch("<", ","))

    lu.assertIsTrue(Acetate.keyMatch(".", ">"))
    lu.assertIsTrue(Acetate.keyMatch(">", "."))

    lu.assertIsTrue(Acetate.keyMatch("/", "?"))
    lu.assertIsTrue(Acetate.keyMatch("?", "/"))
end

function TestKeyHandlers:testShortcutStringAdaptsToSettings()
    local shortcutString = Acetate.shortcutString()

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

    Acetate.toggleCentersKey      = "1"
    Acetate.toggleBoundsKey       = "2"
    Acetate.toggleOrientationsKey = "3"
    Acetate.toggleCollideRectsKey = "4"
    Acetate.toggleInvisiblesKey   = "5"
    Acetate.toggleCustomDrawKey   = "6"
    Acetate.toggleDebugStringKey  = "7"
    Acetate.toggleFPSKey          = "8"
    Acetate.toggleSpriteCountKey  = "9"
    Acetate.togglePauseKey        = "0"
    Acetate.cycleForwardKey       = "]"
    Acetate.cycleBackwardKey      = "["
    Acetate.captureScreenshotKey  = "~"

    shortcutString = Acetate.shortcutString()

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
    Acetate.focusedSprite = nil
    Acetate.setFocus(sprites[1])
    lu.assertEquals(Acetate.focusedSprite, sprites[1])
    Acetate.setFocus(sprites[2])
    lu.assertEquals(Acetate.focusedSprite, sprites[2])
    Acetate.setFocus(sprites[3])
    lu.assertEquals(Acetate.focusedSprite, sprites[3])
end

function TestFocusHandling:testFocusForInvisibleSprites()
    Acetate.focusedSprite = nil
    sprites[1]:setVisible(false)

    Acetate.focusInvisibleSprites = false
    Acetate.setFocus(sprites[1])
    lu.assertIsNil(Acetate.focusedSprite)

    Acetate.focusInvisibleSprites = true
    Acetate.setFocus(sprites[1])
    lu.assertEquals(Acetate.focusedSprite, sprites[1])
end

function TestFocusHandling:testFocusForUnaddedSprites()
    local s = gfx.sprite.new()
    Acetate.focusedSprite = nil
    Acetate.setFocus(s)
    lu.assertIsNil(Acetate.focusedSprite)
end

function TestFocusHandling:releaseFocus()
    Acetate.setFocus(sprites[3])
    assertEquals(Acetate.focusedSprite, sprites[3])
    Acetate.releaseFocus()
    lu.assertIsNil(Acetate.focusedSprite)
end

function TestFocusHandling:testCycleFocusForward()
    Acetate.focusedSprite = nil

    -- cycles through all sprites
    lu.assertEquals(Acetate.focusedSprite, nil)
    Acetate.cycleFocusForward()
    lu.assertEquals(Acetate.focusedSprite, sprites[1])
    Acetate.cycleFocusForward()
    lu.assertEquals(Acetate.focusedSprite, sprites[2])
    Acetate.cycleFocusForward()
    lu.assertEquals(Acetate.focusedSprite, sprites[3])
    Acetate.cycleFocusForward()
    lu.assertEquals(Acetate.focusedSprite, nil)

    -- skips invisible sprites when appropriate
    sprites[2]:setVisible(false)
    Acetate.focusInvisibleSprites = false

    lu.assertEquals(Acetate.focusedSprite, nil)
    Acetate.cycleFocusForward()
    lu.assertEquals(Acetate.focusedSprite, sprites[1])
    Acetate.cycleFocusForward()
    lu.assertEquals(Acetate.focusedSprite, sprites[3])
    Acetate.cycleFocusForward()
    lu.assertEquals(Acetate.focusedSprite, nil)

    -- focuses invisible sprites when appropriate
    Acetate.focusInvisibleSprites = true

    lu.assertEquals(Acetate.focusedSprite, nil)
    Acetate.cycleFocusForward()
    lu.assertEquals(Acetate.focusedSprite, sprites[1])
    Acetate.cycleFocusForward()
    lu.assertEquals(Acetate.focusedSprite, sprites[2])
    Acetate.cycleFocusForward()
    lu.assertEquals(Acetate.focusedSprite, sprites[3])
    Acetate.cycleFocusForward()
    lu.assertEquals(Acetate.focusedSprite, nil)
end

function TestFocusHandling:testCycleFocusBackward()
    Acetate.focusedSprite = nil
    
    -- cycles through all sprites
    lu.assertEquals(Acetate.focusedSprite, nil)
    Acetate.cycleFocusBackward()
    lu.assertEquals(Acetate.focusedSprite, sprites[3])
    Acetate.cycleFocusBackward()
    lu.assertEquals(Acetate.focusedSprite, sprites[2])
    Acetate.cycleFocusBackward()
    lu.assertEquals(Acetate.focusedSprite, sprites[1])
    Acetate.cycleFocusBackward()
    lu.assertEquals(Acetate.focusedSprite, nil)

    -- skips invisible sprites when appropriate
    sprites[2]:setVisible(false)
    Acetate.focusInvisibleSprites = false

    lu.assertEquals(Acetate.focusedSprite, nil)
    Acetate.cycleFocusBackward()
    lu.assertEquals(Acetate.focusedSprite, sprites[3])
    Acetate.cycleFocusBackward()
    lu.assertEquals(Acetate.focusedSprite, sprites[1])
    Acetate.cycleFocusBackward()
    lu.assertEquals(Acetate.focusedSprite, nil)

    -- focuses invisible sprites when appropriate
    Acetate.focusInvisibleSprites = true

    lu.assertEquals(Acetate.focusedSprite, nil)
    Acetate.cycleFocusBackward()
    lu.assertEquals(Acetate.focusedSprite, sprites[3])
    Acetate.cycleFocusBackward()
    lu.assertEquals(Acetate.focusedSprite, sprites[2])
    Acetate.cycleFocusBackward()
    lu.assertEquals(Acetate.focusedSprite, sprites[1])
    Acetate.cycleFocusBackward()
    lu.assertEquals(Acetate.focusedSprite, nil)
end

function TestFocusHandling:updateFocus()

    -- focus updates when made invisible
    Acetate.focusedSprite = sprites[2]
    lu.assertEquals(Acetate.focusedSprite, sprites[2])
    sprites[2]:setVisible(false)
    Acetate.updateFocus()
    lu.assertIsNil(Acetate.focusedSprite)

    -- focus updates when removed
    Acetate.focusedSprite = sprites[3]
    lu.assertEquals(Acetate.focusedSprite, sprites[3])
    sprites[3]:remove()
    Acetate.updateFocus()
    lu.assertIsNil(Acetate.focusedSprite)
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
    Acetate.defaultScreenshotPath = "/tmp"
end

function TestScreenshots:testScreenshot()
    -- fullscreen screenshots should always work
    Acetate.focusedSprite = nil
    local ret = Acetate.captureScreenshot()
    lu.assertIsTrue(ret)

    local s = S()
    s:add()
    s:setSize(5,5)
    s.draw = nil

    -- no draw function
    Acetate.setFocus(s)
    ret = Acetate.captureScreenshot()
    lu.assertIsFalse(ret)

    s.draw = setFlag()
    s:setSize(0,0)

    -- invalid bitmap size
    Acetate.setFocus(s)
    ret = Acetate.captureScreenshot()
    lu.assertIsFalse(ret)

    s:setSize(5,5)

    -- success case
    Acetate.setFocus(s)
    ret = Acetate.captureSpriteScreenshot(s)
    lu.assertIsTrue(ret)
end

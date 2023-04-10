
-- This file specifies Acetate's default settings. You can change these here directly, or modify
-- them from anywhere in your project, e.g. Acetate.color = {0, 255, 0, 0.5}. Take particular
-- note of the `defaultDebugStringFormat`, which you can adjust to provide the info most relevant
-- to your use case. You can also define a custom `debugString` or `debugStringFormat` property
-- on your individual sprite classes for additional flexibility.

Acetate = {

    -- BUILT-IN DEBUG VISUALIZATIONS

    drawCenters = true,                -- draw sprite centers
    drawBounds = true,                 -- draw sprite bounds
    drawOrientations = true,           -- draw sprite orientation orbs
    drawCollideRects = false,          -- draw sprite collide rects

    -- DRAWING OPTIONS

    color = {0, 255, 255, 0.75},       -- the color used for debug drawing (r, g, b, a)
    lineWidth = 1,                     -- line width used for debug drawing

    centerRadius = 2,                  -- determines size of sprite center indicators
    minOrientationOrbRadius = 10,      -- always draw orientation orbs at least this large, for clarity
    orientationOrbScale = 0.5,         -- diameter of orientation orb relative to sprite's shortest dimension
    onlyDrawRotatedOrbs = true,        -- only draw orientation orbs for sprites with non-zero rotation
    customDebugDrawing = true,         -- whether to call `debugDraw` on any sprites which define it
    
    -- DEBUG TEXT

    showFPS = false,                   -- whether to display the current FPS
    FPSPersists = true,                -- whether to display the current FPS when not in debug mode

    showSpriteCount = false,           -- whether to display the total number of sprites (when not focused on a particular one)
    spriteCountPersists = true,        -- whether to display the total number of sprites when not in debug mode
    alwaysShowSpriteNames = true,      -- whether to display the highlighted sprite's name even while the debug string is hidden

    showDebugString = true,            -- whether to show informative text when a single sprite is focused sprite
    defaultDebugStringFormat =         -- comment and/or reorder lines below to adjust the format; see
                                       -- `formatDebugStringForSprite` for additional substitution options
        "$n   \n"     ..               --    class name or `debugName` if provided
        "X: $x\n"     ..               --    X position
        "Y: $y\n"     ..               --    Y position
        "W: $w\n"     ..               --    width
        "H: $h\n"     ..               --    height
        -- "P: $p\n"     ..            --    full position coord
        -- "R: $dº\n"    ..            --    rotation (degrees)
        -- "R: $r rad\n" ..            --    rotation (radians)
        -- "S: $sx\n"    ..            --    scale
        -- "C: $C\n"     ..            --    world center coord
        -- "C: $c\n"     ..            --    local center coord
        -- "O: $co\n"    ..            --    local center relative offset e.g. (0.5, 0.5)
        -- "T: $t\n"     ..            --    tag
        -- "Z: $z\n"     ..            --    z-index
        -- "$v\n"        ..            --    visibility
        -- "$u"          ..            --    updates enabled
        -- "$f FPS\n"    ..            --    current FPS
        -- "$# SPRITES\n"..            --    number of sprites
        "",                            -- terminate our format string concatenation
    debugStringPosition = {            -- the position of the debug string
        x = 2,
        y = 2
    },
    debugFontPath =                    -- the font used to display debug strings
        "fonts/Acetate-Mono-Bold-Condensed",

    showShortcuts = false,             -- show the shortcut cheat sheet (when not focused on an individual sprite)

    -- KEYBOARD SHORTCUTS

    toggleDebugModeKey    = "d",       -- key to toggle [D]ebug drawing mode on/off
    toggleCentersKey      = "c",       -- key to toggle drawing [C]enters while in debug mode
    toggleBoundsKey       = "b",       -- key to toggle drawing [B]ounds while in debug mode
    toggleOrientationsKey = "v",       -- key to toggle drawing orientation [V]ectors while in debug mode
    toggleCollideRectsKey = "x",       -- key to toggle drawing colli[X]ion rects while in debug mode
    toggleInvisiblesKey   = "z",       -- key to toggle debug drawing of invi[Z]ible sprites while in debug mode
    toggleCustomDrawKey   = "m",       -- key to toggle use of custo[M] sprite `debugDraw` functions
    toggleFPSKey          = "f",       -- key to toggle [F]PS display on/off
    toggleSpriteCountKey  = "n",       -- key to toggle display of the total sprite count
    toggleDebugStringKey  = "?",       -- key to toggle debug string display while focused a single sprite
    cycleForwardKey       = ">",       -- key to cycle forward through sprites, one by one
    cycleBackwardKey      = "<",       -- key to cycle backward through sprites, one by one
    togglePauseKey        = "p",       -- key to [P]ause/unpause the game while in debug mode
    captureScreenshotKey  = "q",       -- key to [Q]uick-capture a screenshot

    -- SCREENSHOTS

    spriteScreenshotsEnabled = true,   -- whether screenshots are taken of just the focused sprite, while one is focused
    defaultScreenshotPath =            -- the default location any screenshots are saved to
        "~/Desktop",

    -- SPRITE FOCUS

    focusedSprite = nil,               -- the sprite focused via `makeDebugFocus()`, or nil when debugging all sprites
    retainFocusOnDisable = true,       -- whether the focused sprite will remain focused the next time debug mode is entered
    focusInvisibleSprites = false,     -- whether invisible sprites can be focused (and debug visualizations drawn)

    -- GENERAL STATE
    enabled = false,                   -- whether debug drawing is on/off
    paused = false,                    -- whether Playdate is paused
    autoPause = false,                 -- automatically pause when entering debug mode
}


-- Acetate is controlled via keyboard shortcuts. If you or another utility you use in your project
-- already implement `playdate.keyPressed`, be sure to call `Acetate.keyPressed` yourself. You may
-- also remap the keys for any shortcuts to avoid conflict or suit your needs, by editing them in
-- settings.lua or setting them from within your project, e.g. `Acetate.toggleDebugModeKey = "1"`.

function Acetate.keyPressed(key)
    -- toggle debug mode
    if key == Acetate.toggleDebugModeKey then
        Acetate.toggleEnabled()

    -- allow pausing to enter debug mode
    elseif key == Acetate.togglePauseKey then
        Acetate.enable()
        Acetate.togglePause()

    -- FPS may be toggled outside debug mode
    elseif key == Acetate.toggleFPSKey then
        Acetate.showFPS = not Acetate.showFPS

    -- sprite count may be toggled outside debug mode
    elseif key == Acetate.toggleSpriteCountKey then
        Acetate.showSpriteCount = not Acetate.showSpriteCount

    -- screenshots are allowed outside debug mode
    elseif key == Acetate.captureScreenshotKey then
        Acetate.captureScreenshot()
    end

    -- the rest of these only apply in debug mode
    if Acetate.enabled then

        -- toggle debug mode settings
        if key == Acetate.toggleCentersKey then
            Acetate.drawCenters = not Acetate.drawCenters

        elseif key == Acetate.toggleBoundsKey then
            Acetate.drawBounds = not Acetate.drawBounds

        elseif key == Acetate.toggleOrientationsKey then
            Acetate.drawOrientations = not Acetate.drawOrientations

        elseif key == Acetate.toggleCollideRectsKey then
            Acetate.drawCollideRects = not Acetate.drawCollideRects

        elseif key == Acetate.toggleInvisiblesKey then
            Acetate.focusInvisibleSprites = not Acetate.focusInvisibleSprites

        elseif key == Acetate.toggleCustomDrawKey then
            Acetate.customDebugDrawing = not Acetate.customDebugDrawing

        elseif Acetate.keyMatch(key, Acetate.cycleForwardKey) then
            Acetate.cycleFocusForward()

        elseif Acetate.keyMatch(key, Acetate.cycleBackwardKey) then
            Acetate.cycleFocusBackward()

        elseif Acetate.keyMatch(key, "?") and not Acetate.focusedSprite then
            Acetate.showShortcuts = not Acetate.showShortcuts

        elseif Acetate.keyMatch(key, Acetate.toggleDebugStringKey) then
            if Acetate.focusedSprite then
                Acetate.showDebugString = not Acetate.showDebugString
            end
        end

    end

    -- hide the shortcuts if needed
    if Acetate.focusedSprite then
        Acetate.showShortcuts = false
    end
end

-- acknowledge alternate symbols that match our intended mnemonics for a few keys
function Acetate.altSymbolForKey(key)
    symbolPairs = {
        {",",  "<"},
        {".",  ">"},
        {"/",  "?"},
    }

    for i, symbolPair in ipairs(symbolPairs) do
        local a, b = table.unpack(symbolPair)
        if a == key then return b end
        if b == key then return a end
    end
end

function Acetate.keyMatch(a, b)
    return a == b or a == Acetate.altSymbolForKey(b)
end

-- return a multi-line string listing all available shortcuts
function Acetate.shortcutString()
    -- special cases for a few shortcuts with mnemonics pertaining to the shift-keyed symbol
    local cycleBackwardKey =         Acetate.cycleBackwardKey:gsub(",",  "<")
    local cycleForwardKey =           Acetate.cycleForwardKey:gsub("%.", ">")
    local toggleDebugStringKey = Acetate.toggleDebugStringKey:gsub("/",  "?")

    local shortcutString =
        "[" .. Acetate.toggleCentersKey      .. "] centers\n" ..
        "[" .. Acetate.toggleBoundsKey       .. "] bounds\n" ..
        "[" .. Acetate.toggleOrientationsKey .. "] orientations\n" ..
        "[" .. Acetate.toggleCollideRectsKey .. "] collide rects\n" ..
        "[" .. Acetate.toggleInvisiblesKey   .. "] invisible sprites\n" ..
        "[" .. Acetate.toggleCustomDrawKey   .. "] custom debug draws\n" ..
        "[" .. toggleDebugStringKey          .. "] sprite info\n" ..
        "[" .. Acetate.toggleFPSKey   .. "] FPS\n" ..
        "[" .. Acetate.toggleSpriteCountKey  .. "] sprite count\n" ..
        "\n"..
        "[" .. cycleForwardKey               .. "] Next\n" ..
        "[" .. cycleBackwardKey              .. "] Back\n" ..
        "\n"..
        "[" .. Acetate.togglePauseKey        .. "] Pause\n" ..
        "[" .. Acetate.captureScreenshotKey  .. "] Screenshot\n" ..
        "[?] Help\n"

    return shortcutString
end

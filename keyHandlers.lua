
-- Acetate is controlled via keyboard shortcuts. If you or another utility you use in your project
-- already implement `playdate.keyPressed`, be sure to call `acetate.keyPressed` yourself. You may
-- also remap the keys for any shortcuts to avoid conflict or suit your needs, by editing them in
-- settings.lua or setting them from within your project, e.g. `acetate.toggleDebugModeKey = "1"`.

function acetate.keyPressed(key)
    -- call the wrapped keyPressed handler, if present
    if acetate._keyPressed then acetate._keyPressed() end

    -- toggle debug mode
    if key == acetate.toggleDebugModeKey then
        acetate.toggleEnabled()

    -- allow pausing to enter debug mode
    elseif key == acetate.togglePauseKey then
        acetate.enable()
        acetate.togglePause()

    -- FPS may be toggled outside debug mode
    elseif key == acetate.toggleFPSKey then
        acetate.showFPS = not acetate.showFPS

    -- sprite count may be toggled outside debug mode
    elseif key == acetate.toggleSpriteCountKey then
        acetate.showSpriteCount = not acetate.showSpriteCount

    -- screenshots are allowed outside debug mode
    elseif key == acetate.captureScreenshotKey then
        acetate.captureScreenshot()
    end

    -- the rest of these only apply in debug mode
    if acetate.enabled then

        -- toggle debug mode settings
        if key == acetate.toggleCentersKey then
            acetate.drawCenters = not acetate.drawCenters

        elseif key == acetate.toggleBoundsKey then
            acetate.drawBounds = not acetate.drawBounds

        elseif key == acetate.toggleOrientationsKey then
            acetate.drawOrientations = not acetate.drawOrientations

        elseif key == acetate.toggleCollideRectsKey then
            acetate.drawCollideRects = not acetate.drawCollideRects

        elseif key == acetate.toggleInvisiblesKey then
            acetate.focusInvisibleSprites = not acetate.focusInvisibleSprites

        elseif key == acetate.toggleCustomDrawKey then
            acetate.customDebugDrawing = not acetate.customDebugDrawing

        elseif key == acetate.cycleForwardKey then
            acetate.cycleFocusForward()

        elseif key == acetate.cycleForwardInClassKey then
            acetate.cycleFocusForward(true)

        elseif key == acetate.cycleBackwardKey then
            acetate.cycleFocusBackward()

        elseif key == acetate.cycleBackwardInClassKey then
            acetate.cycleFocusBackward(true)

        elseif key == acetate.toggleFocusLockKey then
            acetate.toggleFocusLock()

        elseif acetate.keyMatch(key, "?") and not acetate.focusedSprite then
            acetate.showShortcuts = not acetate.showShortcuts

        elseif acetate.keyMatch(key, acetate.toggleDebugStringKey) then
            if acetate.focusedSprite then
                acetate.showDebugString = not acetate.showDebugString
            end
        end

    end

    -- hide the shortcuts if needed
    if acetate.focusedSprite then
        acetate.showShortcuts = false
    end
end

-- acknowledge alternate symbols that match our intended mnemonics for a few keys
local symbolPairs = {
    {",",  "<"},
    {".",  ">"},
    {"/",  "?"},
}

function acetate.altSymbolForKey(key)
    for _, symbolPair in ipairs(symbolPairs) do
        local a, b = table.unpack(symbolPair)
        if a == key then return b end
        if b == key then return a end
    end
end

function acetate.keyMatch(a, b)
    return a == b or a == acetate.altSymbolForKey(b)
end

-- return a multi-line string listing all available shortcuts
function acetate.shortcutString()
    local shortcutString =
        "[" .. acetate.toggleCentersKey      .. "] centers\n" ..
        "[" .. acetate.toggleBoundsKey       .. "] bounds\n" ..
        "[" .. acetate.toggleOrientationsKey .. "] orientations\n" ..
        "[" .. acetate.toggleCollideRectsKey .. "] collide rects\n" ..
        "[" .. acetate.toggleInvisiblesKey   .. "] invisible sprites\n" ..
        "[" .. acetate.toggleCustomDrawKey   .. "] custom debug draws\n" ..
        "[" .. acetate.toggleDebugStringKey  .. "] sprite info\n" ..
        "[" .. acetate.toggleFPSKey          .. "] FPS\n" ..
        "[" .. acetate.toggleSpriteCountKey  .. "] sprite count\n" ..
        "\n"..
        "[" .. acetate.cycleForwardKey       .. "] Next\n" ..
        "[" .. acetate.cycleBackwardKey      .. "] Back\n" ..
        "[" .. acetate.toggleFocusLockKey    .. "] Toggle class focus lock\n" ..
        "\n"..
        "[" .. acetate.togglePauseKey        .. "] Pause\n" ..
        "[" .. acetate.captureScreenshotKey  .. "] Screenshot\n" ..
        "[?] Help\n"

    return shortcutString
end

import "CoreLibs/graphics"
import "./EasyPattern"

-- define the Acetate namespace before importing our settings and function definitions
acetate = {}

import "settings"
import "keyHandlers"
import "focusHandling"
import "spriteExtensions"
import "screenshots"

local gfx <const> = playdate.graphics

-- animated dotted line effect used for selection bounds
local marchingAnts = AcetateEasyPattern {
    ditherType = gfx.image.kDitherTypeDiagonalLine,
    xDuration = 0.25,
    bgColor = gfx.kColorWhite, -- debug color
}

-- animated dot field used for nudge selection
local marchingDots = AcetateEasyPattern {
    alpha = 0.99,
    duration = 0.5,
    color = gfx.kColorWhite -- debug color
}

-- USAGE:
--
-- You can use the built-in utilities as-is, or create custom debug drawing for your sprite
-- classes just by implementing the `debugDraw` method on those you choose to, e.g.
--
-- function MySprite:debugDraw()
--     gfx.pushContext()
--         -- custom debug drawing here
--     gfx.popContext()
-- end

-- The line width will be set to 1 and the color set to kColorWhite (the color used for
-- all debug drawing) so you needn't set these yourself unless you want to change them.
-- Sprites can also define a custom debug string to be shown when they are focused, e.g.
--
-- function MySprite:debugString()
--     return "My custom debug string"
-- end
--
-- NOTE: while you must import Acetate somewhere, e.g. main.lua, you needn't import it in
-- your individual sprite classes.


-- initialization logic

function acetate.init(config)
    if not playdate.isSimulator then
        print("NOTE: Skipping initialization of Acetate outside simulator.")
        return
    end

    -- load defaults first, then optionally override via an optional custom config
    acetate.restoreDefaults()
    if config then
        acetate.loadConfig(config)
    end

    -- load the font used for displaying debug strings
    acetate.loadDebugFont()

    -- install our `debugDraw` function, storing a reference to any previously defined
    -- function which we'll still call to preserve its behavior
    if playdate.debugDraw and playdate.debugDraw ~= acetate.debugDraw then
        print("NOTE: Acetate is wrapping an existing `playdate.debugDraw` function.")
        print("That function will still be called to preserve its functionality.")
        acetate._debugDraw = playdate.debugDraw
    end
    playdate.debugDraw = acetate.debugDraw

    -- install our `keyPressed` function, storing a reference to any previously defined
    -- function which we'll still call to preserve its behavior
    if playdate.keyPressed  and playdate.keyPressed ~= acetate.keyPressed then
        print("NOTE: Acetate is wrapping an existing `playdate.keyPressed` function.")
        print("That function will still be called to preserve its functionality.")
        acetate._keyPressed = playdate.keyPressed
    end
    playdate.keyPressed = acetate.keyPressed
    print("NOTE: Press [" .. acetate.toggleDebugModeKey .. "] to activate Acetate debug mode.")

    -- set a bool which can be checked to determine whether acetate is initialized
    -- before attempting to access its members
    acetate.initialized = true
end

function acetate.loadConfig(config)
    for k, v in pairs(config) do
        acetate[k] = type(v) == "table" and table.deepcopy(v) or v
    end
end

function acetate.restoreDefaults()
    acetate.loadConfig(acetate.defaults)
end

-- state management functions

function acetate.enable()
    if acetate.enabled then return end
    acetate.enabled = true
    if acetate.autoPause then acetate.pause() end
end

function acetate.disable()
    if not acetate.enabled then return end
    acetate.enabled = false
    if not acetate.retainFocusOnDisable then
        acetate.focusedSprite = nil
    end
    if acetate.paused then acetate.unpause() end
end

function acetate.toggleEnabled()
    if acetate.enabled then
        acetate.disable()
    else
        acetate.enable()
    end
end

function acetate.pause()
    if acetate.paused then return end
    acetate.paused = true
    if playdate.gameWillPause then
        playdate.gameWillPause() -- let the game prepare
    end
    playdate.inputHandlers.push({}, true) -- block all inputs
    acetate.updateHandlerRef = playdate.update -- cease calls to update fn
    playdate.update = function() end -- no-op
end

function acetate.unpause()
    if not acetate.paused then return end
    acetate.paused = false
    if playdate.gameWillResume then
        playdate.gameWillResume() -- let the game prepare
    end
    playdate.inputHandlers.pop() -- unblock inputs
    playdate.update = acetate.updateHandlerRef -- restore update fn
end

function acetate.togglePause()
    if acetate.paused then
        acetate.unpause()
    else
        acetate.pause()
    end
end

-- implement our debug drawing method, deferring to other sprites as appropriate

function table.filter(t, func)
    local i = 1
    while (i <= #t) do
        if func(t[i]) then
            -- value passes test
            i = i + 1
        else
            table.remove(t, i)
        end
    end
end

function acetate.debugDraw()
    -- call the wrapped debugDraw version, if present
    if acetate._debugDraw then acetate._debugDraw() end

    -- this is slightly inefficient, but it avoids needing a setter
    playdate.setDebugDrawColor(table.unpack(acetate.color))

    local sprites = playdate.graphics.sprite.getAllSprites()
    local s = ""

    if acetate.focusedClass then
        table.filter(sprites, function(s) return s:isa(acetate.focusedClass) end)
        if #sprites == 0 then
            acetate.releaseClassFocusLock() -- no sprites of the current focus remaining
        end
    end

    -- show FPS as appropriate
    if acetate.showFPS and (acetate.FPSPersists or acetate.enabled) then
        local fps = playdate.getFPS() -- luacheck: ignore
        s = s .. (acetate.enabled and (fps .. " FPS\n") or (fps .. "\n"))
    end

    -- show sprite count as appropriate
    if acetate.showSpriteCount and (acetate.spriteCountPersists or acetate.enabled) then
        if not acetate.focusedSprite or not acetate.enabled then
            s = s .. tostring(#sprites)

            if acetate.enabled then
                s = s .. ((acetate.focusedClass ~= nil) and (" " .. acetate.focusedClass.className .. "s") or " SPRITES")
            end

            if acetate.focusedClass ~= nil then
                s = s .. " 🔒"
            end

            s = s .. "\n"

        end
    elseif acetate.enabled and acetate.focusedClass ~= nil and acetate.focusedSprite == nil then
        s = s .. acetate.focusedClass.className .. " 🔒\n"
    end

    -- grab the current draw offset so we can adjust relative to it accordingly
    local xo, yo = gfx.getDrawOffset()

    -- do debug drawing only if enabled
    if acetate.enabled then

        -- refocus or release if current focus is invisible or no longer displayed
        acetate.updateFocus()

        -- show shortcuts or shortcut hint if there are no focused sprites
        if sprites and not acetate.focusedSprite then
            if acetate.showShortcuts then
                s = s .. acetate.shortcutString()
            else
                s = s .. "? for help"
            end
        end

        -- loop over all the sprites
        for _, sprite in ipairs(sprites) do
            -- only debug draw for visible sprites depending on our setting
            if acetate.focusInvisibleSprites or sprite:isVisible() then
                -- debug draw all sprites, or only the sprite at the matching index
                if acetate.focusedSprite == nil or acetate.focusedSprite == sprite then

                    -- time to draw
                    gfx.pushContext()
                        -- determine the draw offset for the sprite and set useful defaults
                        local x, y = sprite:getBounds()
                        if sprite.__ignoresDrawOffset then
                            gfx.setDrawOffset(x, y)
                        else
                            gfx.setDrawOffset((sprite.__xo or (x + xo)), (sprite.__yo or (y + yo)))
                        end
                        gfx.setLineWidth(acetate.lineWidth)
                        gfx.setColor(gfx.kColorWhite) -- white is the debug color

                        -- draw built-in debug visualizations, if enabled and there's no custom override
                        if not (acetate.customDebugDrawing and sprite.debugDraw and acetate.customOverridesDefaults)
                        then
                            if acetate.drawBounds then
                                if acetate.animateBoundsForFocus and acetate.focusedSprite == sprite then
                                    gfx.setPattern(marchingAnts:apply())
                                end
                                sprite:drawBounds()
                                gfx.setColor(gfx.kColorWhite)
                            end
                            if acetate.drawCenters then sprite:drawCenter() end
                            if acetate.drawCollideRects then sprite:drawCollideRect() end
                            if acetate.drawOrientations then
                                if not acetate.onlyDrawRotatedOrbs or sprite:getRotation() ~= 0 then
                                    sprite:drawOrientation()
                                end
                            end
                        end

                        -- handle any sprites with custom `debugDraw` functions defined
                        if acetate.customDebugDrawing and sprite.debugDraw then
                            sprite:debugDraw()
                        end

                        -- show the info string if a single sprite is focused
                        if acetate.focusedSprite then
                            if acetate.showDebugString then
                                s = s .. acetate.formatDebugStringForSprite(sprite)
                            elseif acetate.alwaysShowSpriteNames then
                                s = s .. (sprite.debugName or sprite.className)
                            end
                        end
                    gfx.popContext()
                end
            end
        end
    end

    -- lastly, show the debug string we've built up
    gfx.pushContext()
        gfx.setDrawOffset(0, 0)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        acetate.debugFont:drawText(s, acetate.debugStringPosition.x, acetate.debugStringPosition.y)
    gfx.popContext()
end


-- load the debug font
function acetate.loadDebugFont()

    if acetate.debugFontPath then
        -- check the canonical fonts directory first
        acetate.debugFont = gfx.font.new(acetate.debugFontPath)
        if acetate.debugFont then return end

        -- check the toybox assets directory next
        local toyboxAssetsDir = "toybox_assets/github-dot-com/ebeneliason/acetate/"
        acetate.debugFont = gfx.font.new(toyboxAssetsDir .. acetate.debugFontPath)
        if acetate.debugFont then return end
    end

    -- use the system font as a fallback
    print("WARNING: Acetate fonts could not be found. Falling back to system font.")
    print("Please double-check your `debugFontPath` setting and font file installations.")
    acetate.debugFont = gfx.getSystemFont(gfx.font.kVariantBold)
end

-- perform debug string substitutions using the format string specified by the sprite,
-- if provided, and our default format string otherwise. By necessity, this needs to
-- happen every frame, even though it's somewhat inefficient.

function acetate.formatDebugStringForSprite(sprite, options)
    local s, performSubstitutions
    local options = options or {}

    -- a format string passed as an argument takes precedence
    if options.formatString then
        s = options.formatString
        performSubstitutions = true
    -- check to see if the sprite provides a custom debug string
    elseif sprite.debugString and not s then
        if type(sprite.debugString) == "function" then
            s, performSubstitutions = sprite:debugString()
        else
            -- legacy support
            return sprite.debugString
        end
    -- fall back to a custom tostring() implementation, if defined
    elseif sprite.__tostring then
        s = (sprite.debugName or sprite.className) .. "\n" .. tostring(sprite)
    else
    -- the default format string otherwise
        s = s or sprite.debugStringFormat or acetate.defaultDebugStringFormat
        performSubstitutions = true
    end

    -- if no substitutions are needed, we're done
    if not performSubstitutions then return s end

    local x,  y  = sprite.x, sprite.y
    local w,  h  = sprite:getSize()
    local cx, cy = sprite:getLocalCenter()
    local Cx, Cy = sprite:getWorldCenter()
    local rx, ry = sprite:getCenter()
    local ox, oy = sprite:getLocalOrigin()
    local Ox, Oy = sprite:getWorldOrigin()
    local r      = sprite:getRotation()
    local v      = sprite:isVisible()
    local q      = sprite:isOpaque()
    local sc     = sprite:getScale()
    local u      = sprite:updatesEnabled()
    local t      = sprite:getTag()
    local z      = sprite:getZIndex()
    local fps    = playdate.getFPS() -- luacheck: ignore
    local num    = #playdate.graphics.sprite.getAllSprites()
    local n      = sprite.debugName or sprite.className
    local cn     = sprite.className

    if acetate.focusedClass ~= nil then
        n = n .. " 🔒"
        cn = cn .. " 🔒"
    end

    -- truncate to desired precision
    local precision = options.precision or acetate.displayPrecision or 3
    local mult = 10^precision
    local p = function(num)
        if precision < 0 then return num end
        return num*mult//1/mult
    end

    s = s:gsub("%$[a-zA-Z#]+", function(str)                                  -- SUBSTITUTION KEY
        if     str == "$n"   then return n                                    -- $n  | sprite `debugName` (or classname)
        elseif str == "$cn"  then return cn                                   -- $cn | sprite classname
        elseif str == "$str" then return tostring(sprite)                     -- $str| `tostring()` output
        elseif str == "$a"   then return string.format("%p", sprite)          -- $a  | memory address
        elseif str == "$x"   then return p(x)                                 -- $x  | x position
        elseif str == "$y"   then return p(y)                                 -- $y  | y position
        elseif str == "$p"   then return "(" .. p(x) .. ", " .. p(y) .. ")"   -- $p  | position coordinate (x, y)
        elseif str == "$pos" then return "(" .. p(x) .. ", " .. p(y) .. ")"   -- $pos| position coordinate (x, y)
        elseif str == "$w"   then return p(w)                                 -- $w  | width
        elseif str == "$h"   then return p(h)                                 -- $h  | height
        elseif str == "$sz"  then return "" .. p(w) .. " x " .. p(h)          -- $sz | size (w x h)
        elseif str == "$rx"  then return p(rx)                                -- $rx | local relative horizontal center
        elseif str == "$ry"  then return p(ry)                                -- $ry | local relative vertical center
        elseif str == "$rc"  then return "(" .. p(rx) .. ", " .. p(ry) .. ")" -- $rc | local relative center coordinate
        elseif str == "$ox"  then return p(ox)                                -- $ox | local origin x
        elseif str == "$oy"  then return p(oy)                                -- $oy | local origin y
        elseif str == "$o"   then return "(" .. p(ox) .. ", " .. p(oy) .. ")" -- $o  | local origin coordinate
        elseif str == "$Ox"  then return p(Ox)                                -- $Ox | world origin x
        elseif str == "$Oy"  then return p(Oy)                                -- $Oy | world origin y
        elseif str == "$O"   then return "(" .. p(Ox) .. ", " .. p(Oy) .. ")" -- $O  | world origin coordinate
        elseif str == "$cx"  then return p(cx)                                -- $cx | local center x
        elseif str == "$cy"  then return p(cy)                                -- $cy | local center y
        elseif str == "$c"   then return "(" .. p(cx) .. ", " .. p(cy) .. ")" -- $c  | local center coordinate
        elseif str == "$Cx"  then return p(Cx)                                -- $Cx | world center x
        elseif str == "$Cy"  then return p(Cy)                                -- $Cy | world center y
        elseif str == "$C"   then return "(" .. p(Cx) .. ", " .. p(Cy) .. ")" -- $C  | world center coordinate
        elseif str == "$d"   then return p(r)                                 -- $d  | rotation (degrees)
        elseif str == "$deg" then return p(r)                                 -- $deg| rotation (degrees)
        elseif str == "$r"   then return p(math.rad(r))                       -- $r  | rotation (radians)
        elseif str == "$rad" then return p(math.rad(r))                       -- $rad| rotation (radians)
        elseif str == "$s"   then return p(sc)                                -- $s  | scale
        elseif str == "$t"   then return t                                    -- $t  | tag number
        elseif str == "$u"   then return u and "UPDATING" or "DISABLED"       -- $u  | updates enabled
        elseif str == "$v"   then return v and "VISIBLE" or "INVISIBLE"       -- $v  | visibility
        elseif str == "$q"   then return q and "OPAQUE" or "TRANSPARENT"      -- $q  | opaqueness
        elseif str == "$z"   then return z                                    -- $z  | z-index
        elseif str == "$fps" then return fps                                  -- $fps| FPS
        elseif str == "$#"   then return num                                  -- $num| number of sprites
        end
    end)

    return s
end

function acetate.printDebugInfo()
    for _, sprite in ipairs(acetate.getFocusedSprites() or playdate.graphics.sprite.getAllSprites()) do
        acetate.printDebugInfoForSprite(sprite)
    end
end

function acetate.printDebugInfoForSprite(s, formatString)
    print(acetate.formatDebugStringForSprite(s, { formatString = formatString, precision = -1 }))
end

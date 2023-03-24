import "CoreLibs/graphics"

import "settings"
import "keyHandlers"
import "focusHandling"
import "spriteExtensions"
import "screenshots"

local gfx <const> = playdate.graphics
local geom <const> = playdate.geometry

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
-- Sprites can also define a custom debug string, or a debug string format, to be shown when
-- they are focused in debug mode, e.g.
--
-- self.debugString = "My custom debug string"
-- 
-- NOTE: while you must import Acetate somewhere, e.g. main.lua, you needn't import it in
-- your individual sprite classes.


-- state management functions

function Acetate.enable()
    if Acetate.enabled then return end
    Acetate.enabled = true
    if Acetate.autoPause then Acetate.pause() end
end

function Acetate.disable()
    if not Acetate.enabled then return end
    Acetate.enabled = false
    if not Acetate.retainFocusOnDisable then
        Acetate.focusedSprite = nil
    end
    if Acetate.paused then Acetate.unpause() end
end

function Acetate.toggleEnabled()
    if Acetate.enabled then
        Acetate.disable()
    else
        Acetate.enable()
    end
end

function Acetate.pause()
    Acetate.paused = true
    playdate.gameWillPause()
    playdate.stop()
    playdate.inputHandlers.push({}, true) -- block inputs
end

function Acetate.unpause()
    Acetate.paused = false
    playdate.gameWillResume()
    playdate.start()
    playdate.inputHandlers.pop() -- unblock inputs
end

function Acetate.togglePause()
    if Acetate.paused then
        Acetate.unpause()
    else
        Acetate.pause()
    end
end

-- implement our debug drawing method, deferring to other sprites as appropriate

function Acetate.debugDraw()
    -- call the wrapped debugDraw version, if present
    if Acetate._debugDraw then Acetate._debugDraw() end

    -- this is slightly inefficient, but it avoids needing a setter
    playdate.setDebugDrawColor(table.unpack(Acetate.color))

    local sprites = playdate.graphics.sprite.getAllSprites()
    local s = ""

    -- show FPS as appropriate
    if Acetate.showFPS and (Acetate.FPSPersists or Acetate.enabled) then
        local fps = playdate.getFPS()
        s = s .. (Acetate.enabled and (fps .. " FPS\n") or (fps .. "\n"))
    end

    -- show sprite count as appropriate
    if Acetate.showSpriteCount and (Acetate.spriteCountPersists or Acetate.enabled) then
        if not Acetate.focusedSprite or not Acetate.enabled then
            s = s .. (Acetate.enabled and (#sprites .. " SPRITES\n") or (#sprites .. "\n"))
        end
    end

    -- abort if debug drawing isn't enabled
    if Acetate.enabled then

        -- refocus or release if current focus is invisible or no longer displayed
        Acetate.updateFocus()

        -- show shortcuts or shortcut hint if there are no focused sprites
        if sprites and not Acetate.focusedSprite then
            gfx.pushContext()
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            if Acetate.showShortcuts then
                s = s .. Acetate.shortcutString()
            else
                s = s .. "? for help"
            end
            gfx.popContext()
        end

        -- loop over all the sprites
        for i, sprite in ipairs(sprites) do
            -- only debug draw for visible sprites depending on our setting
            if Acetate.focusInvisibleSprites or sprite:isVisible() then
                -- debug draw all sprites, or only the sprite at the matching index
                if Acetate.focusedSprite == nil or Acetate.focusedSprite == sprite then

                    -- time to draw
                    gfx.pushContext()
                        -- determine the draw offset for the sprite and set useful defaults
                        local x, y = sprite:getBounds()
                        gfx.setDrawOffset(x, y)
                        gfx.setLineWidth(Acetate.lineWidth)
                        gfx.setColor(gfx.kColorWhite) -- white is the debug color

                        -- draw built-in debug visualizations, if enabled
                        if Acetate.drawBounds then sprite:drawBounds() end
                        if Acetate.drawCenters then sprite:drawCenter() end
                        if Acetate.drawCollideRects then sprite:drawCollideRect() end
                        if Acetate.drawOrientations then
                            if not Acetate.onlyDrawRotatedOrbs or sprite:getRotation() ~= 0 then
                                sprite:drawOrientation()
                            end
                        end

                        -- handle any sprites with custom `debugDraw` functions defined
                        if Acetate.customDebugDrawing and sprite.debugDraw then
                            sprite:debugDraw()
                        end

                        -- show the info string if a single sprite is focused
                        if Acetate.focusedSprite then
                            if Acetate.showDebugString then
                                s = s .. Acetate.formatDebugStringForSprite(sprite)
                            elseif Acetate.alwaysShowSpriteNames then
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
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        Acetate.debugFont:drawText(s, Acetate.debugStringPosition.x, Acetate.debugStringPosition.y)
    gfx.popContext()


    -- our trick to update the debug drawing requires re-pausing
    if Acetate.paused then
        playdate.update = Acetate.updateHandlerRef
        playdate.stop()
    end
end

-- install our `debugDraw` function if not already defined, storing a reference to
-- any previously defined function which we'll call to preserve its behavior
if playdate.debugDraw then
    print("NOTE: Acetate is wrapping an existing `playdate.debugDraw` function.")
    print("That function will still be called to preserve its functionality.")
    Acetate._debugDraw = playdate.debugDraw
end
playdate.debugDraw = Acetate.debugDraw

-- load the debug font
function Acetate.loadDebugFont()

    if Acetate.debugFontPath then
        -- check the canonical fonts directory first
        Acetate.debugFont = gfx.font.new(Acetate.debugFontPath)
        if Acetate.debugFont then return end

        -- check the toybox assets directory next
        local toyboxAssetsDir = "toybox_assets/github-dot-com/ebeneliason/acetate/"
        Acetate.debugFont = gfx.font.new(toyboxAssetsDir .. Acetate.debugFontPath)
        if Acetate.debugFont then return end
    end

    -- use the system font as a fallback
    print("WARNING: Acetate fonts could not be found. Falling back to system font.")
    print("Please double-check your `debugFontPath` setting and font file installations.")
    Acetate.debugFont = gfx.getSystemFont(gfx.font.kVariantBold)
end
Acetate.loadDebugFont()

-- perform debug string substitutions using the format string specified by the sprite,
-- if provided, and our default format string otherwise. By necessity, this needs to
-- happen every frame, even though it's somewhat inefficient.

function Acetate.formatDebugStringForSprite(sprite)
    -- if the sprite provides a pre-formatted string, just return it
    if sprite.debugString then return sprite.debugString end

    -- use the format string specified by the sprite, if provided, falling back to
    -- the default format string otherwise
    local s = sprite.debugStringFormat or Acetate.defaultDebugStringFormat

    local x,  y  = sprite.x, sprite.y
    local w,  h  = sprite:getSize()
    local cx, cy = sprite:getLocalCenter()
    local Cx, Cy = sprite:getWorldCenter()
    local ox, oy = sprite:getCenter()
    local r      = sprite:getRotation()
    local v      = sprite:isVisible()
    local sc     = sprite:getScale()
    local u      = sprite:updatesEnabled()
    local t      = sprite:getTag()
    local z      = sprite:getZIndex()
    local f      = playdate.getFPS()
    local num    = #playdate.graphics.sprite.getAllSprites()
    local n      = sprite.debugName or sprite.className

                                                       -- SUBSTITUTION KEY
    s = s:gsub("$n",  ""  .. n)                        -- $n  | sprite class name
    s = s:gsub("$p",  "(" .. x .. "," .. y .. ")")     -- $p  | position coord
    s = s:gsub("$x",  ""  .. x)                        -- $x  | x position
    s = s:gsub("$y",  ""  .. y)                        -- $y  | y position
    s = s:gsub("$w",  ""  .. w)                        -- $w  | width
    s = s:gsub("$h",  ""  .. h)                        -- $h  | height
    s = s:gsub("$co", "(" .. ox .. "," .. oy .. ")")   -- $o  | relative offset center
    s = s:gsub("$cx", ""  .. cx)                       -- $cx | local center x position
    s = s:gsub("$cy", "(" .. cy)                       -- $cy | local center y position
    s = s:gsub("$c",  "(" .. cx .. "," .. cy .. ")")   -- $c  | local center coord
    s = s:gsub("$Cx", ""  .. Cx)                       -- $Cx | world center x position
    s = s:gsub("$Cy", "(" .. Cy)                       -- $Cy | world center y position
    s = s:gsub("$C",  "(" .. Cx .. "," .. Cy .. ")")   -- $C  | world center coord
    s = s:gsub("$d",  ""  .. r)                        -- $d  | rotation (deg)
    s = s:gsub("$r",  ""  .. math.rad(r))              -- $r  | rotation (rad)
    s = s:gsub("$s",  ""  .. sc)                       -- $s  | scale
    s = s:gsub("$t",  ""  .. t)                        -- $t  | tag number
    s = s:gsub("$u",  u and "UPDATING" or "DISABLED")  -- $u  | updates enabled
    s = s:gsub("$v",  v and "VISIBLE" or "INVISIBLE")  -- $v  | visibility
    s = s:gsub("$z",  ""  .. z)                        -- $z  | z index
    s = s:gsub("$f",  ""  .. f)                        -- $f  | FPS
    s = s:gsub("$#",  ""  .. num)                      -- $#  | number of sprites

    return s
end


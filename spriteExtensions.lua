import "CoreLibs/graphics"

local gfx <const> = playdate.graphics

-- Define a handful of extensions to the `playdate.graphics.sprite` class to facilitate easier
-- debug drawing, coordinate conversions, and debug focus handling.

-- sprite extensions for drawing debug visualizations
-- luacheck: ignore 142 (indirectly setting undefined field of global)

function gfx.sprite:drawBounds()
    gfx.drawRect(0, 0, self.width, self.height)
end

function gfx.sprite:drawCollideRect()
    gfx.drawRect(self:getCollideRect())
end

function gfx.sprite:drawCenter()
    local x, y = self:getLocalCenter()
    gfx.fillCircleAtPoint(x, y, acetate.centerRadius)
end

function gfx.sprite:drawOrientation()
    local x, y = self:getLocalCenter()
    local degrees = self:getRotation()
    local radius = math.max(acetate.minOrientationOrbRadius, math.min(
        self.width * acetate.orientationOrbScale / 2,
        self.height * acetate.orientationOrbScale / 2))
    gfx.drawCircleAtPoint(x, y, radius)
    gfx.drawLine(x, y,
        x + radius * math.cos(math.rad(degrees)),
        y + radius * math.sin(math.rad(degrees)))
end

-- sprite extensions for determining local and world origins and centers

function gfx.sprite:getWorldCenter()
    local cx, cy = self:getLocalCenter()
    local bx, by = self:getBounds()
    local x = bx + cx
    local y = by + cy
    return x, y
end

function gfx.sprite:getLocalCenter()
    local cx, cy = self:getCenter()
    local x = cx * self.width
    local y = cy * self.height
    return x, y
end

function gfx.sprite:getWorldOrigin()
    -- this is just a proxy for the first two bounds values
    local x, y = self:getBounds()
    return x, y
end

function gfx.sprite:getLocalOrigin()
    local cx, cy = self:getCenter()
    return -cx * self.width, -cy * self.height
end

function gfx.sprite:cacheDrawOffset()
    local xo, yo = gfx.getDrawOffset()
    self.__xo = xo
    self.__yo = yo
end

-- work around a limitation of the SDK which makes it impossible to check
-- whether a sprite is currently set to ignore the draw offset
local _setIgnoresDrawOffset = gfx.sprite.setIgnoresDrawOffset
function gfx.sprite:setIgnoresDrawOffset(flag)
    self.__ignoresDrawOffset = flag
    _setIgnoresDrawOffset(self, flag)
end

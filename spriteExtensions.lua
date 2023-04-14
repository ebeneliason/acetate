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
    gfx.fillCircleAtPoint(x, y, Acetate.centerRadius)
end

function gfx.sprite:drawOrientation()
    local x, y = self:getLocalCenter()
    local degrees = self:getRotation()
    local radius = math.max(Acetate.minOrientationOrbRadius, math.min(
        self.width * Acetate.orientationOrbScale / 2,
        self.height * Acetate.orientationOrbScale / 2))
    gfx.drawCircleAtPoint(x, y, radius)
    gfx.drawLine(x, y,
        x + radius * math.cos(math.rad(degrees)),
        y + radius * math.sin(math.rad(degrees)))
end

-- sprite extensions for determining local and world centers

function gfx.sprite:getWorldCenter()
    local cx, cy = self:getCenter()
    local x = self.x - self.width * cx
    local y = self.y - self.height * cy
    return x, y
end

function gfx.sprite:getLocalCenter()
    local cx, cy = self:getCenter()
    local x = cx * self.width
    local y = cy * self.height
    return x, y
end

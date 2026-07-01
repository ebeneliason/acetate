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

-- quick access to debug info
function gfx.sprite:printDebugInfo(prefix, format)
    if prefix then print(prefix) end
    acetate.printDebugInfoForSprite(self, format)
end

-- print a debug trace
function gfx.sprite:printDebugTrace(prefix, format)
    if prefix then self:printDebugInfo(prefix, format) end
    print(debug.traceback())
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
    return math.floor(x), math.floor(y) -- floored values keep this more stable
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

function gfx.sprite:getWorldCoordFromRelative(x, y)
    local bx, by = self:getBounds()
    x = bx + x * self.width
    y = by + y * self.height
    return x, y
end

function gfx.sprite:getRelativeCoordFromWorld(x, y)
    local bx, by = self:getBounds()
    x = (bx - x) / self.width
    y = (by - y) / self.height
    return x, y
end

function gfx.sprite:getWorldCoordFromLocal(x, y)
    local bx, by = self:getBounds()
    return bx + x, by + y
end

function gfx.sprite:getLocalCoordFromWorld(x, y)
    local bx, by = self:getBounds()
    return x - bx, y - by
end

function gfx.sprite:getRelativeCoord(x, y)
    return x * self.width, y * self.height
end

function gfx.sprite:cacheDrawOffset()
    local xo, yo = gfx.getDrawOffset()
    self.__xo = xo
    self.__yo = yo
end

-- work around a limitation of the SDK which makes it impossible to check
-- whether a sprite is currently set to ignore the draw offset
-- luacheck: ignore
local _setIgnoresDrawOffset = gfx.sprite.setIgnoresDrawOffset
function gfx.sprite:setIgnoresDrawOffset(flag)
    self.__ignoresDrawOffset = flag
    _setIgnoresDrawOffset(self, flag)
end

-- enable animated updates to position for nudge reset
function gfx.sprite:slideTo(x, y, --[[optional:]] duration, --[[optional]] ease)
    if self._interpX then self._interpX:remove() end
    if self._interpY then self._interpY:remove() end
    ease = ease or self.interpEase or playdate.easingFunctions.inOutCubic
    duration = duration or self.interpDuration or 300
    if x ~= self.x then
        self._interpX = playdate.timer.new(duration, self.x, x, ease)
        self._interpX.updateCallback = function(t) self:moveTo(t.value, self.y) end
        self._interpX.timerEndedCallback = self._interpX.updateCallback
    end
    if y ~= self.y then
        self._interpY = playdate.timer.new(duration, self.y, y, ease)
        self._interpY.updateCallback = function(t) self:moveTo(self.x, t.value) end
        self._interpY.timerEndedCallback = self._interpY.updateCallback
    end
end

-- enable animated updates to size for nudge reset
function gfx.sprite:resizeTo(w, h, --[[optional]] duration, --[[optional]] ease)
    if self._interpW then self._interpW:remove() end
    if self._interpH then self._interpH:remove() end
    ease = ease or self.interpEase or playdate.easingFunctions.inOutCubic
    duration = duration or self.interpDuration or 300
    if w ~= self.width then
        self._interpW = playdate.timer.new(duration, self.width, w, ease)
        self._interpW.updateCallback = function(t) self:setSize(t.value, self.height) end
        self._interpW.timerEndedCallback = self._interpW.updateCallback
    end
    if h ~= self.height then
        self._interpH = playdate.timer.new(duration, self.height, h, ease)
        self._interpH.updateCallback = function(t) self:setSize(self.width, t.value) end
        self._interpH.timerEndedCallback = self._interpH.updateCallback
    end
end

-- enable animated updates to scale for nudge reset
function gfx.sprite:scaleTo(sx, sy, --[[optional]] duration, --[[optional]] ease)
    sy = sy or sx
    local _sx, _sy = self:getScale()
    if self._interpSX then self._interpSX:remove() end
    if self._interpSY then self._interpSY:remove() end
    ease = ease or self.interpEase or playdate.easingFunctions.inOutCubic
    duration = duration or self.interpDuration or 300
    if sx ~= _sx then
        self._interpSX = playdate.timer.new(duration, _sx, sx, ease)
        self._interpSX.updateCallback = function(t) self:setScale(t.value, select(2, self:getScale())) end
        self._interpSX.timerEndedCallback = self._interpSX.updateCallback
    end
    if sy ~= _sy then
        self._interpSY = playdate.timer.new(duration, _sy, sy, ease)
        self._interpSY.updateCallback = function(t) self:setScale(select(1, self:getScale()), t.value) end
        self._interpSY.timerEndedCallback = self._interpSY.updateCallback
    end
end

-- enable animated updates to rotation for nudge reset
function gfx.sprite:rotateTo(degrees, --[[optional]] duration, --[[optional]] ease)
    if self._interpR then self._interpR:remove() end
    local _degrees = self:getRotation()
    if _degrees - degrees > 180 then degrees += 360 end
    ease = ease or self.interpEase or playdate.easingFunctions.inOutCubic
    duration = duration or self.interpDuration or 300
    if degrees ~= _degrees then
        self._interpR = playdate.timer.new(duration, _degrees, degrees, ease)
        self._interpR.updateCallback = function(t) self:setRotation(t.value) end
        self._interpR.timerEndedCallback = self._interpR.updateCallback
    end
end

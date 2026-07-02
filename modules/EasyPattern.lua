import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/easing"

-- NOTE:
-- EasyPattern is available from https://github.com/ebeneliason/easy-pattern.
-- This unmodified version is included here under a different name exclusively to allow
-- installation of Acetate without additional dependencies, and without the potential
-- for namespace collisions in projects which also depend on EasyPattern.

local gfx <const> = playdate.graphics

local PTTRN_SIZE <const> = 8
local CACHE_EXP <const> = 1 / 60 -- max FPS

-- luacheck: ignore 214 (ignore use of variables beginning with underscore)

-- Animated patterns with easing, made easy.
--
-- SAMPLE USAGE:
--
--     local checkerboard <const> = { 0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F }
--     local easyCheckerboard = AcetateEasyPattern {
--         pattern  = checkerboard,
--         duration = 1.0,
--         ease     = playdate.easingFunctions.inOutCubic,
--         -- <list any additional animation params here>
--     }
--
--     playdate.graphics.setPattern(easyCheckerboard:apply()) -- in `draw`
--     -- <perform drawing using pattern here>

class('AcetateEasyPattern').extends(Object)

-- Create a new animated AcetateEasyPattern.
-- @param params            A table containing one or more of the elements listed below.
--
--                          With the exception of `pattern`, `ditherType`, `alpha`, and `color`
--                          any of these properties may also be set directly on the object at any
--                          time, e.g. `myAcetateEasyPattern.xPhaseDuration = 0.5`. (Use `:setPattern()` or
--                          `:setDitherPattern()` to change the pattern itself.)
--
--                          Additionally, when initializing an `AcetateEasyPattern`, any of the axis-specific
--                          values may be set for both axes at once by dropping the `x` or `y` prefix,
--                          from the parameter name, e.g. `..., scale = 2, reverses = true, ...`
--
--
--
--        pattern           The pattern to animate, specified as an array of 8 numbers describing the
--                          bitmap for each row, with an optional additional 8 for a bitmap alpha
--                          channel, as would be supplied to `playdate.graphics.setPattern()`.
--
--        ditherType        A dither type as would be passed to `playdate.graphics.setDitherPattern()`,
--                          e.g. `playdate.graphics.image.kDitherTypeVerticalLine`. This setting only
--                          applies when the `pattern` parameter is omitted or `nil`.
--                          Default: nil.
--
--        alpha             An alpha value for a dither pattern, which can either be the default
--                          Playdate dither effect, or one specified by `ditherType`. This setting only
--                          applies when the `pattern` parameter is omitted or `nil`.
--                          Default 0.5.
--
--        color             The color to use when rendering the dither pattern. This setting only
--                          applies when the `pattern` parameter is omitted or `nil`.
--                          Default: `playdate.graphics.kColorBlack`
--
--        bgColor           The color to use as a background when rendering a dither pattern or a
--                          pattern with an alpha channel.
--                          Default: `playdate.graphics.kColorClear`
--
--
--
--        xEase             An easing function that defines the animation pattern in the X axis,
--                          following the signature of the `playdate.easingFunctions`.
--                          Default: `playdate.easingFunctions.linear`
--
--        yEase             An easing function that defines the animation pattern in the Y axis,
--                          following the signature of the `playdate.easingFunctions`.
--                          Default: `playdate.easingFunctions.linear`
--
--        xEaseArgs         A list containing any additional args to the X axis easing function, e.g.
--                          to parameterize amplitude, period, overshoot, etc.
--                          Default: {}
--
--        yEaseArgs         A list containing any additional args to the Y axis easing function, e.g.
--                          to parameterize amplitude, period, overshoot, etc.
--                          Default: {}
--
--        xDuration         The duration of the animation in the X axis, in seconds. Omit this param
--                          or set it to 0 to prevent animation in this axis.
--                          Default: 0.
--
--        yDuration         The duration of the animation in the Y axis, in seconds. Omit this param
--                          or set it to 0 to prevent animation in this axis.
--                          Default: 0.
--
--        xOffset           An absolute time offset for the X axis animation, in seconds.
--                          Default: 0.
--
--        xOffset           An absolute time offset for the Y axis animation, in seconds.
--                          Default: 0.
--
--        xReverses         A boolean indicating whether the X axis animation reverses at each end.
--                          Default: false.
--
--        yReverses         A boolean indicating whether the Y axis animation reverses at each end.
--                          Default: false.
--
--        xReversed         A boolean indicating whether the X axis animation is playing in reverse.
--                          May be set manually, and also updates automatically when `xReverses` is `true`.
--                          Default: false.
--
--        yReversed         A boolean indicating whether the Y axis animation is playing in reverse.
--                          May be set manually, and also updates automatically when `yReverses` is `true`.
--                          Default: false.
--
--        xSpeed            A multiplier for the overall speed of the animation in the X axis, relative
--                          to the timings specified for its duration and offset.
--                          Default: 1.
--
--        ySpeed            A multiplier for the overall speed of the animation in the Y axis, relative
--                          to the timings specified for its duration and offset.
--                          Default: 1.
--
--        xScale            A multiplier describing the number of 8px repetitions the pattern moves by
--                          per cycle in the X axis. Non-integer values result in discontinuity when looping.
--                          Default: 1.
--
--        yScale            A multiplier describing the number of 8px repetitions the pattern moves by
--                          per cycle in the Y axis. Non-integer values result in discontinuity when looping.
--                          Default: 1.
--


function AcetateEasyPattern:init(params)
    AcetateEasyPattern.super.init(self)

    -- the pattern to be animated
    self.pattern = params.pattern or nil

    -- the alpha value to use when animating a dither pattern (and `pattern` itself is `nil`)
    self.alpha = params.alpha or 0.5

    -- the dither type to use when `pattern` is `nil`
    self.ditherType = params.ditherType or nil

    -- the color to use for the dither pattern when `pattern` is `nil`
    self.color = params.color or gfx.kColorBlack

    -- the color to use for a background for a dither pattern or a pattern with an alpha channel
    self.bgColor = params.bgColor or gfx.kColorClear


    -- OBJECT PROPERTY  | SINGLE AXIS SET        | DUAL AXIS FALLBACK    | DEFAULT VALUE

    -- governs animation duration in both x and y axes in seconds (1 second yields 8FPS, negative numbers reverse)
    self.xDuration      = params.xDuration      or params.duration      or 0
    self.yDuration      = params.yDuration      or params.duration      or 0

    -- legacy duration params
    self.xDuration      = params.xPhaseDuration or params.phaseDuration or self.xDuration
    self.yDuration      = params.yPhaseDuration or params.phaseDuration or self.yDuration

    -- offsets that adjust the relative x and y phases, in seconds; when omitted, both run in the same phase
    self.xOffset        = params.xOffset        or params.offset        or 0
    self.yOffset        = params.yOffset        or params.offset        or 0

    -- legacy offset params
    self.xOffset        = params.xPhaseOffset   or params.phaseOffset   or self.xOffset
    self.yOffset        = params.yPhaseOffset   or params.phaseOffset   or self.yOffset

    -- by default, a linear animation is used; any playdate easing (or API-compatible) function is supported
    self.xEase          = params.xEase          or params.ease          or playdate.easingFunctions.linear
    self.yEase          = params.yEase          or params.ease          or playdate.easingFunctions.linear

    self.xEaseArgs      = params.xEaseArgs      or params.easeArgs      or {}
    self.yEaseArgs      = params.yEaseArgs      or params.easeArgs      or {}

    -- legacy function params
    self.xEase          = params.xPhaseFunction or params.phaseFunction or self.xEase
    self.yEase          = params.yPhaseFunction or params.phaseFunction or self.yEase

    self.xEaseArgs      = params.xPhaseArgs     or params.phaseArgs     or self.xEaseArgs
    self.yEaseArgs      = params.yPhaseArgs     or params.phaseArgs     or self.yEaseArgs

    -- indicates whether the animation reverses when reaching either end
    self.xReverses      = params.xReverses      or params.reverses      or false
    self.yReverses      = params.yReverses      or params.reverses      or false

    -- indicates whether the animation is actively playing in reverse
    self.xReversed      = params.xReversed      or params.reversed      or false
    self.yReversed      = params.yReversed      or params.reversed      or false

    -- a speed multiplier which affects overall speed relative to the specified phase durations
    self.xSpeed         = params.xSpeed         or params.speed         or 1
    self.ySpeed         = params.ySpeed         or params.speed         or 1

    -- a scale multiplier which affects how many 8px texture repetitions are moved by per animation cycle
    self.xScale         = params.xScale         or params.scale         or 1
    self.yScale         = params.yScale         or params.scale         or 1


    -- the previously computed time values for each axis, used to determine when to reverse animations
    self._ptx = 0
    self._pty = 0

    -- the previous phase calculation timestamp, used for caching computed phase offsets
    self._pt = 0

    -- cached phase offset values for each axis
    self._xPhase = 0
    self._yPhase = 0


    -- the pattern image to use for drawing, at twice the pattern size to support looping animation
    self.patternImage = gfx.image.new(PTTRN_SIZE * 2, PTTRN_SIZE * 2)

    -- pre-render the pattern image
    self:_updatePatternImage()
end

function AcetateEasyPattern:setColor(color)
    self.color = color
    self:_updatePatternImage()
end

function AcetateEasyPattern:setBackgroundColor(color)
    self.bgColor = color
    self:_updatePatternImage()
end

function AcetateEasyPattern:setPattern(pattern)
    self.pattern = pattern
    self:_updatePatternImage()
end

function AcetateEasyPattern:setDitherPattern(alpha, ditherType)
    self.alpha = alpha
    self.ditherType = ditherType
    self.pattern = nil
    self:_updatePatternImage()
end

function AcetateEasyPattern:_updatePatternImage()
    self.patternImage:clear(self.bgColor)
    gfx.pushContext(self.patternImage)
        gfx.setColor(self.color)
        if self.pattern then
            gfx.setPattern(self.pattern)
        elseif self.ditherType then
            gfx.setDitherPattern(self.alpha, self.ditherType)
        else
            gfx.setDitherPattern(self.alpha)
        end
        gfx.fillRect(0, 0, PTTRN_SIZE * 2, PTTRN_SIZE * 2)
    gfx.popContext()
end

-- this exists primarily to enable mocking in tests
function AcetateEasyPattern:_getTime() -- luacheck: ignore
    return playdate.getCurrentTimeMilliseconds() / 1000
end

function AcetateEasyPattern:getPhases()
    -- all patterns animate with respect to absolute time
    local t = self:_getTime()

    -- use the cached values if they were computed recently enough
    if t - self._pt < CACHE_EXP then
        return self._xPhase, self._yPhase, false
    end

    -- calculate the effective time param for each axis accounting for offsets, speed scaling, and looping
    local tx = (t * self.xSpeed + self.xOffset) % self.xDuration
    local ty = (t * self.ySpeed + self.yOffset) % self.yDuration

    -- handle animation reversal when crossing the animation duration bounds
    if self.xReverses and self._ptx > tx then
        self.xReversed = not self.xReversed
    end
    self._ptx = tx

    if self.yReverses and self._pty > ty then
        self.yReversed = not self.yReversed
    end
    self._pty = ty

    -- compute the resulting phase offsets, mod 8 to fit within our pattern texture
    local xPhase = (self.xDuration > 0 and self.xEase)
        and self.xEase(tx, 0, PTTRN_SIZE, self.xDuration, table.unpack(self.xEaseArgs))
                * self.xScale % PTTRN_SIZE // 1
        or 0

    local yPhase = (self.yDuration > 0 and self.yEase)
        and self.yEase(ty, 0, PTTRN_SIZE, self.yDuration, table.unpack(self.yEaseArgs))
                * self.yScale % PTTRN_SIZE // 1
        or 0

    -- flip the output values when in reverse animation mode
    if self.xReversed then xPhase = PTTRN_SIZE - xPhase - 1 end
    if self.yReversed then yPhase = PTTRN_SIZE - yPhase - 1 end

    -- determine if we're dirty and cache the computed phase values along with a timestamp
    local dirty = xPhase ~= self._xPhase or yPhase ~= self._yPhase
    self._xPhase = xPhase
    self._yPhase = yPhase
    self._pt = t

    -- return the newly computed phase offsets and indicate whether they have changed
    return xPhase, yPhase, dirty
end

function AcetateEasyPattern:isDirty()
    local _, _, dirty = self:getPhases()
    return dirty
end

function AcetateEasyPattern:apply()
    local xPhase, yPhase = self:getPhases()
    -- return a 3-tuple to be used as arguments to `playdate.graphics.setPattern()`
    return self.patternImage, xPhase, yPhase
end

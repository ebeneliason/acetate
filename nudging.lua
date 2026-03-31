
-- sprite nudge functions

function acetate.toggleNudgeMode()
    acetate.nudgeMode = not acetate.nudgeMode
    if acetate.nudgeMode then
        playdate.inputHandlers.push({
            rightButtonDown =  function() acetate.nudge(1, 0) end,
            rightButtonUp = function() acetate.stopNudging(1, 0) end,
            leftButtonDown = function() acetate.nudge(-1, 0) end,
            leftButtonUp = function() acetate.stopNudging(-1, 0) end,
            downButtonDown = function() acetate.nudge(0, -1) end,
            downButtonUp = function() acetate.stopNudging(0, -1) end,
            upButtonDown = function() acetate.nudge(0, 1) end,
            upButtonUp = function() acetate.stopNudging(0, 1) end,
            AButtonDown = acetate.nudgeReset,
            BButtonDown = acetate.nudgeReset,
            AButtonHeld = function() acetate.nudgeReset(acetate.focusedSprite, true) end,
            cranked = acetate.scaleOrRotate,
        }, true)
    else
        playdate.inputHandlers.pop()
    end
end

function acetate.nudge(x, y, delta, sprite)
    if not acetate.nudgeMode then return end

    local fastNudgeAmount = 3 -- when holding arrow keys
    delta = delta or 1-fastNudgeAmount -- how much? (negative value offsets first key repeat call)
    local adjust = (x == 1 or y == 1) and delta or -delta -- which way?

    local sprite = sprite or acetate.focusedSprite
    -- nudge all focused sprites if there's no singular focus
    if not sprite then
        local sprites = acetate.getFocusedSprites()
        for _, sprite in ipairs(sprites) do
            acetate.nudge(x, y, delta, sprite)
        end
        return
    end

    -- nothing to do
    if not sprite then return end

    -- key repeat timers enable faster adjustment
    local timerID = "nudgeTimer" .. x .. y
    if not acetate[timerID] then
        acetate[timerID] = true
        acetate[timerID] = playdate.timer.keyRepeatTimerWithDelay(300, 1, acetate.nudge, x, y, fastNudgeAmount)
    end

    -- capture original values for potential reset
    if not sprite.acetateData then
        sprite.acetateData = {
            width = sprite.width,
            height = sprite.height,
            scale = sprite:getScale(),
            x = sprite.x,
            y = sprite.y,
            rotation = sprite:getRotation(),
        }
    end

    -- rotation/custom
    if playdate.buttonIsPressed(playdate.kButtonB) then
        if sprite.debugNudge then
            sprite:debugNudge(x*delta, y*delta)
        else
            sprite:setRotation(sprite:getRotation() + adjust)
        end

    -- size/scale
    elseif playdate.buttonIsPressed(playdate.kButtonA) then
        if sprite:getImage() ~= nil then
            local xs, ys = sprite:getScale()
            sprite:setScale(xs + adjust/100, (xs + adjust/100)/xs * ys)
        else
            local w, h = sprite:getSize()
            local aspectRatio = sprite.acetateData.width / sprite.acetateData.height
            sprite:setSize(w + adjust, (w + adjust) / aspectRatio)
        end

    -- position
    else
        sprite:moveBy(x * delta, -y * delta)
    end
end

function acetate.stopNudging(x, y)
    if x == nil or y == nil then
        acetate.stopNudging(1, 0)
        acetate.stopNudging(-1, 0)
        acetate.stopNudging(0, 1)
        acetate.stopNudging(0, -1)
        return
    end
    local timerID = "nudgeTimer" .. x .. y
    if acetate[timerID] then
        acetate[timerID]:remove()
        acetate[timerID] = nil
    end
end

function acetate.nudgeReset(sprite, center)
    if not acetate.nudgeMode then return end
    if not (playdate.buttonIsPressed(playdate.kButtonA) and playdate.buttonIsPressed(playdate.kButtonB)) then return end

    local sprite = sprite or acetate.focusedSprite
    if not sprite then
        local sprites = acetate.getFocusedSprites()
        for _, sprite in ipairs(sprites) do
            acetate.nudgeReset(sprite)
        end
        return
    end

    if not sprite.acetateData then
        sprite.acetateData = {
            width = sprite.width,
            height = sprite.height,
            scale = sprite:getScale(),
            x = sprite.x,
            y = sprite.y,
            rotation = sprite:getRotation(),
        }
    end

    if sprite.debugNudgeReset then
        sprite:debugNudgeReset()
    end
    sprite:slideTo(sprite.acetateData.x, sprite.acetateData.y)
    sprite:rotateTo(sprite.acetateData.rotation)
    sprite:resizeTo(sprite.acetateData.width, sprite.acetateData.height)
    sprite:scaleTo(sprite.acetateData.scale)

    if center then
        sprite:slideTo(200, 120)
    end
end

function acetate.scaleOrRotate(c, _, sprite)
    c /= 10
    local sprite = sprite or acetate.focusedSprite
    -- nudge all focused sprites if there's no singular focus
    if not sprite then
        local sprites = acetate.getFocusedSprites()
        for _, sprite in ipairs(sprites) do
            acetate.scaleOrRotate(c, nil, sprite)
        end
        return
    end

    -- nothing to do
    if not sprite then return end

    -- capture original values for potential reset
    if not sprite.acetateData then
        sprite.acetateData = {
            width = sprite.width,
            height = sprite.height,
            scale = sprite:getScale(),
            x = sprite.x,
            y = sprite.y,
            rotation = sprite:getRotation(),
        }
    end

    if playdate.buttonIsPressed(playdate.kButtonB) then
        sprite:setRotation(sprite:getRotation() + c)
    else
        if sprite:getImage() ~= nil then
            local xs, ys = sprite:getScale()
            sprite:setScale(xs + c/100, (xs + c/100)/xs * ys)
        else
            local w, h = sprite:getSize()
            local aspectRatio = sprite.acetateData.width / sprite.acetateData.height
            sprite:setSize(w + c, (w + c) / aspectRatio)
        end
    end
end

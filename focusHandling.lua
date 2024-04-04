
-- sprite focus functions

-- pick the sprite to show debug visualizations for exclusively
function acetate.setFocus(sprite)
    if not sprite:isVisible() and not acetate.focusInvisibleSprites then
        print("Unable to focus " .. sprite.className .. " sprite as it's currently invisible. "
            .."Set acetate.focusInvisibleSprites to true to focus invisible sprites.")
        return
    end

    if acetate.focusedClass and not sprite:isa(acetate.focusedClass) then
        print("Releasing class focus lock in order to focus " .. sprite.className .. ".")
        acetate.releaseClassFocusLock()
    end

    local sprites = playdate.graphics.sprite.getAllSprites()
    for _, s in ipairs(sprites) do
        if s == sprite then
            acetate.focusedSprite = sprite
            acetate.enable() -- ensure debug drawing is on
            return
        end
    end
    print("Unable to focus " .. sprite.className .. " sprite. Have you called add()?")
end

-- release focus, returning to drawing debug visualizations for all sprites
function acetate.releaseFocus()
    acetate.focusedSprite = nil
end

-- constrain focus cycling to sprites of the specified class
function acetate.setClassFocusLock(class)
    acetate.focusedClass = class
end

-- release class focus lock, enabling cycling through all sprites
function acetate.releaseClassFocusLock()
    acetate.focusedClass = nil
end

-- toggle class focus lock for the class of the currently focused sprite
function acetate.toggleFocusLock()
    if acetate.focusedSprite and not acetate.focusedClass then
        acetate.setClassFocusLock(acetate.focusedSprite.class)
    else
        acetate.releaseClassFocusLock()
    end
end

-- determine whether the sprite meets all criteria for becoming focused
function acetate.spriteIsFocusable(s, sameClass)
    local sameClassCheck = not sameClass or acetate.focusedSprite == nil or s:isa(acetate.focusedSprite.class)
    local visibilityCheck = s:isVisible() or acetate.focusInvisibleSprites
    local classFocusCheck = acetate.focusedClass == nil or s:isa(acetate.focusedClass)
    return visibilityCheck and classFocusCheck and sameClassCheck
end

-- move forward through the sprite display list, focusing the next one for debug visualization
function acetate.cycleFocusForward(sameClass, _looping)
    local sprites = playdate.graphics.sprite.getAllSprites()

    -- release focus if there are no sprites
    if not sprites or #sprites == 0 then
        acetate.releaseFocus()
        acetate.releaseClassFocusLock()
        return
    end

    -- keep track of whether we've iterated past the current focus, starting at the
    -- beginning if we're looping around or beginning without a focused sprite
    local focusFound = _looping or acetate.focusedSprite == nil

    for i, sprite in ipairs(sprites) do
        if focusFound then
            -- consider the next focus candidate
            if acetate.spriteIsFocusable(sprite, sameClass) then
                acetate.focusedSprite = sprite
                return
            end
        elseif sprite == acetate.focusedSprite then
            -- found the index of the focused sprite; begin considering new focus candidates
            focusFound = true
        end
        -- reached the end
        if i == #sprites then
            if sameClass and not _looping then
                -- loop around once when cycling through sprites of the same class
                acetate.cycleFocusForward(true, true)
            else
                -- release focus to show debug info for all sprites
                acetate.releaseFocus()
            end
        end
    end
end

-- move backward through the sprite display list, focusing the previous one for debug visualization
function acetate.cycleFocusBackward(sameClass, _looping)
    local sprites = playdate.graphics.sprite.getAllSprites()

    -- release focus if there are no sprites
    if not sprites or #sprites == 0 then
        acetate.releaseFocus()
        acetate.releaseClassFocusLock()
        return
    end

    -- keep track of whether we've iterated past the current focus, starting at the
    -- end if we're looping around or beginning without a focused sprite
    local focusFound = _looping or acetate.focusedSprite == nil

    for i = #sprites, 1, -1 do
        local sprite = sprites[i]
        if focusFound then
            -- consider the next focus candidate
            if acetate.spriteIsFocusable(sprite, sameClass) then
                acetate.focusedSprite = sprite
                return
            end
        elseif sprite == acetate.focusedSprite then
            -- found the index of the focused sprite; begin considering new focus candidates
            focusFound = true
        end
        -- reached the end
        if i == 1 then
            if sameClass and not _looping then
                -- loop around once when cycling through sprites of the same class
                acetate.cycleFocusBackward(true, true)
            else
                -- release focus to show debug info for all sprites
                acetate.releaseFocus()
            end
        end
    end
end

-- update the current focus in response to changes in visibility or removal from the display list
function acetate.updateFocus()
    -- nothing to do if there's no current focus
    if not acetate.focusedSprite then return end

    -- if the focused sprite becomes invisible, release focus as appropriate
    if not (acetate.focusedSprite:isVisible() or acetate.focusInvisibleSprites) then
        acetate.focusedSprite = nil
        return
    end

    -- if the focused sprite is no longer displayed, release focus
    local sprites = playdate.graphics.sprite.getAllSprites()
    for _, sprite in ipairs(sprites) do
        if acetate.focusedSprite == sprite then return end
    end
    acetate.releaseFocus()
end

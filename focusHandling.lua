
-- sprite focus functions

-- pick the sprite to show debug visualizations for exclusively
function acetate.setFocus(sprite)
    if not sprite:isVisible() and not acetate.focusInvisibleSprites then
        print("Unable to focus " .. sprite.className .. " sprite as it's currently invisible. "
            .."Set acetate.focusInvisibleSprites to true to focus invisible sprites.")
        return
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

-- release focus, returning to drawing debug vizualizations for all sprites
function acetate.releaseFocus()
    acetate.focusedSprite = nil
end

-- move forward through the sprite display list, focusing the next one for debug visualization
function acetate.cycleFocusForward()
    local sprites = playdate.graphics.sprite.getAllSprites()
    local focusFound = false -- keep track of whether we've iterated past the current focus

    -- release focus if there are no sprites
    if not sprites or #sprites == 0 then
        acetate.releaseFocus()
        return
    end

    -- start at the beginning if we're looping forwards from the end
    if not acetate.focusedSprite then
        acetate.focusedSprite = sprites[1]
        focusFound = true
    end

    for i, sprite in ipairs(sprites) do
        if focusFound then
            -- consider the next focus candidate
            acetate.focusedSprite = sprite
            -- validate our new focus and return if it qualifies
            if acetate.focusedSprite:isVisible() or acetate.focusInvisibleSprites then return end
        elseif sprite == acetate.focusedSprite then
            -- found the index of the focused sprite; begin considering new focus candidates
            focusFound = true
        end
        -- reached the end; release focus to show debug info for all sprites
        if i == #sprites then acetate.releaseFocus() end
    end
end

-- move backward through the sprite display list, focusing the previous one for debug visualization
function acetate.cycleFocusBackward()
    local sprites = playdate.graphics.sprite.getAllSprites()
    local focusFound = false -- keep track of whether we've iterated past the current focus

    -- release focus if there are no sprites
    if not sprites or #sprites == 0 then
        acetate.focusedSprite = nil
        return
    end

    -- start at the end if we're looping backwards from the beginning
    if not acetate.focusedSprite then
        acetate.focusedSprite = sprites[#sprites]
        focusFound = true
    end

    for i = #sprites, 1, -1 do
        local sprite = sprites[i]
        if focusFound then
            -- consider the next focus candidate
            acetate.focusedSprite = sprite
            -- validate our new focus and return if it qualifies
            if acetate.focusedSprite:isVisible() or acetate.focusInvisibleSprites then return end
        elseif sprite == acetate.focusedSprite then
            -- found the index of the focused sprite; begin considering new focus candidates
            focusFound = true
        end
        -- reached the end; release focus to show debug info for all sprites
        if i == 1 then acetate.focusedSprite = nil end
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
    acetate.focusedSprite = nil
end

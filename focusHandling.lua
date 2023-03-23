
-- sprite focus functions

-- pick the sprite to show debug visualizations for exclusively
function Acetate.setFocus(sprite)
    local sprites = playdate.graphics.sprite.getAllSprites()
    for _, s in ipairs(sprites) do
        if s == sprite then
            Acetate.focusedSprite = sprite
            Acetate.enable() -- ensure debug drawing is on
            return
        end
    end
    print("Unable to focus " .. self.className .. " sprite. Have you called add()?")
end

-- release focus, returning to drawing debug vizualizations for all sprites
function Acetate.releaseFocus()
    Acetate.focusedSprite = nil
end

-- move forward through the sprite display list, focusing the next one for debug visualization
function Acetate.cycleFocusForward()
    local sprites = playdate.graphics.sprite.getAllSprites()
    local focusFound = false -- keep track of whether we've iterated past the current focus

    -- release focus if there are no sprites
    if not sprites or #sprites == 0 then
        Acetate.releaseFocus()
        return
    end

    -- start at the beginning if we're looping forwards from the end
    if not Acetate.focusedSprite then
        Acetate.focusedSprite = sprites[1]
        focusFound = true
    end

    for i, sprite in ipairs(sprites) do
        if focusFound then
            -- consider the next focus candidate
            Acetate.focusedSprite = sprite
            -- validate our new focus and return if it qualifies
            if Acetate.focusedSprite:isVisible() or Acetate.focusInvisibleSprites then return end
        elseif sprite == Acetate.focusedSprite then
            -- found the index of the focused sprite; begin considering new focus candidates
            focusFound = true
        end
        -- reached the end; release focus to show debug info for all sprites
        if i == #sprites then Acetate.releaseFocus() end
    end
end

-- move backward through the sprite display list, focusing the previous one for debug visualization
function Acetate.cycleFocusBackward()
    local sprites = playdate.graphics.sprite.getAllSprites()
    local focusFound = false -- keep track of whether we've iterated past the current focus

    -- release focus if there are no sprites
    if not sprites or #sprites == 0 then
        Acetate.focusedSprite = nil
        return
    end

    -- start at the end if we're looping backwards from the beginning
    if not Acetate.focusedSprite then
        Acetate.focusedSprite = sprites[#sprites]
        focusFound = true
    end

    for i = #sprites, 1, -1 do
        local sprite = sprites[i]
        if focusFound then
            -- consider the next focus candidate
            Acetate.focusedSprite = sprite
            -- validate our new focus and return if it qualifies
            if Acetate.focusedSprite:isVisible() or Acetate.focusInvisibleSprites then return end
        elseif sprite == Acetate.focusedSprite then
            -- found the index of the focused sprite; begin considering new focus candidates
            focusFound = true
        end
        -- reached the end; release focus to show debug info for all sprites
        if i == 1 then Acetate.focusedSprite = nil end
    end
end

-- update the current focus in response to changes in visibility or removal from the display list
function Acetate.updateFocus()
    -- nothing to do if there's no current focus
    if not Acetate.focusedSprite then return end

    -- if the focused sprite becomes invisible, release focus as appropriate
    if not (Acetate.focusedSprite:isVisible() or Acetate.focusInvisibleSprites) then
        Acetate.focusedSprite = nil
        return
    end

    -- if the focused sprite is no longer displayed, release focus
    local sprites = playdate.graphics.sprite.getAllSprites()
    for i, sprite in ipairs(sprites) do
        if Acetate.focusedSprite == sprite then return end
    end
    Acetate.focusedSprite = nil
end
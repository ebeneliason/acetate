
-- sprite focus functions

-- pick the sprite to show debug visualizations for exclusively
function acetate.focusSprite(sprite)
    if not sprite:isVisible() and not acetate.focusInvisibleSprites then
        if not acetate.quietMode then
            print("Unable to focus " .. sprite.className .. " sprite as it's currently invisible. "
                .."Set acetate.focusInvisibleSprites to true to focus invisible sprites.")
        end
        return
    end

    if acetate.focusedClass and not sprite:isa(acetate.focusedClass) then
        if not acetate.quietMode then
            print("Releasing class focus lock in order to focus " .. sprite.className .. ".")
        end
        acetate.releaseClassFocus()
    end

    local sprites = playdate.graphics.sprite.getAllSprites()
    for _, s in ipairs(sprites) do
        if s == sprite then
            acetate.focusedSprite = sprite
            acetate.enable() -- ensure debug drawing is on
            return
        end
    end
    if not acetate.quietMode then
        print("Unable to focus " .. sprite.className .. " sprite. Have you called add()?")
    end
end

-- release focus, returning to drawing debug visualizations for all sprites
function acetate.releaseSpriteFocus()
    acetate.focusedSprite = nil
end

-- constrain focus cycling to sprites of the specified class
function acetate.focusClass(class)
    acetate.focusedClass = class
    acetate.releaseSpriteFocus() -- TODO: yay or nay?
    acetate.releaseGroupFocus()
end

-- release class focus, enabling cycling through all sprites
function acetate.releaseClassFocus()
    acetate.focusedClass = nil
end

-- toggle class focus lock for the class of the currently focused sprite
function acetate.toggleClassFocus()
    if acetate.focusedSprite and not acetate.focusedClass then
        acetate.focusClass(acetate.focusedSprite.class)
    else
        acetate.releaseClassFocus()
    end
end

function acetate.focusGroup(numberOrName)
    local num = 0
    if type(numberOrName) == "number" then
        num = numberOrName
    elseif acetate.groupNames[numberOrName] then
        num = acetate.groupNames[numberOrName]
    end
    if num == 0 then
        acetate.focusedGroup = nil
    elseif num > 0 and num <= 9 then
        if num == acetate.focusedGroup and acetate.focusedSprite == nil then
            acetate.focusedGroup = nil
        else
            acetate.focusedGroup = num//1
        end
    end
    acetate.releaseSpriteFocus()
    acetate.releaseClassFocus()
end

function acetate.setGroupName(num, name)
    if num == 0 then return end
    acetate.groupNames[num] = name
    acetate.groupNames[name] = num
end

function acetate.setGroupNames(...)
    for i, name in ipairs({...}) do
        acetate.setGroupName(i, name)
    end
end

-- unfocus the debug group
function acetate.releaseGroupFocus()
    acetate.focusedGroup = nil
end

function acetate.cycleGroups()
    acetate.focusedGroup = acetate.focusedGroup and acetate.focusedGroup+1 or 1
end

-- determine whether the sprite meets all criteria for becoming focused
function acetate.spriteIsFocusable(s, sameClass)
    local sameClassCheck = not sameClass or acetate.focusedSprite == nil or s:isa(acetate.focusedSprite.class)
    local visibilityCheck = s:isVisible() or acetate.focusInvisibleSprites
    local classFocusCheck = acetate.focusedClass == nil or s:isa(acetate.focusedClass)
    local sameGroupCheck = acetate.focusedGroup == nil or acetate.focusedGroup == s.debugGroup
    return visibilityCheck and classFocusCheck and sameClassCheck and sameGroupCheck
end

-- move forward through the sprite display list, focusing the next one for debug visualization
function acetate.cycleFocusForward(sameClass, --[[optional]] looping)
    local sprites = playdate.graphics.sprite.getAllSprites()

    -- release focus if there are no sprites
    if not sprites or #sprites == 0 then
        acetate.releaseSpriteFocus()
        acetate.releaseClassFocus()
        return
    end

    -- keep track of whether we've iterated past the current focus, starting at the
    -- beginning if we're looping around or beginning without a focused sprite
    local focusFound = looping or acetate.focusedSprite == nil

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
            if sameClass and not looping then
                -- loop around once when cycling through sprites of the same class
                acetate.cycleFocusForward(true, true)
            else
                -- release focus to show debug info for all sprites
                acetate.releaseSpriteFocus()
            end
        end
    end
end

-- move backward through the sprite display list, focusing the previous one for debug visualization
function acetate.cycleFocusBackward(sameClass, --[[optional]] looping)
    local sprites = playdate.graphics.sprite.getAllSprites()

    -- release focus if there are no sprites
    if not sprites or #sprites == 0 then
        acetate.releaseSpriteFocus()
        acetate.releaseClassFocus()
        return
    end

    -- keep track of whether we've iterated past the current focus, starting at the
    -- end if we're looping around or beginning without a focused sprite
    local focusFound = looping or acetate.focusedSprite == nil

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
            if sameClass and not looping then
                -- loop around once when cycling through sprites of the same class
                acetate.cycleFocusBackward(true, true)
            else
                -- release focus to show debug info for all sprites
                acetate.releaseSpriteFocus()
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
    acetate.releaseSpriteFocus()
end

function acetate.releaseFocus()
    acetate.releaseSpriteFocus()
    acetate.releaseClassFocus()
    acetate.releaseGroupFocus()
end

function acetate.getFocusableSprites()
    local sprites = playdate.graphics.sprite.getAllSprites()

    if acetate.focusedClass then
        table.filter(sprites, function(s) return s:isa(acetate.focusedClass) end)
    end

    if acetate.focusedGroup then
        table.filter(sprites, function(s) return s.debugGroup == acetate.focusedGroup end)
    end

    if not acetate.focusInvisibleSprites then
        table.filter(sprites, function(s) return s:isVisible() end)
    end

    return sprites
end

function acetate.getFocusedSprites()
    if acetate.focusedSprite then return { acetate.focusedSprite } end
    return acetate.getFocusableSprites()
end

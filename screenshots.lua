import "CoreLibs/graphics"

local gfx <const> = playdate.graphics

-- Basic screenshot capabilities

-- conditionally capture either a sprite or a full-screen screenshot
function acetate.captureScreenshot()
    -- only capture sprite screenshots while a sprite is focused in debug mode
    if acetate.enabled and acetate.focusedSprite and acetate.spriteScreenshotsEnabled then
        return acetate.captureSpriteScreenshot(acetate.focusedSprite)
    -- the default
    else
        return acetate.captureFullScreenshot()
    end
end

-- capture a full screenshot
function acetate.captureFullScreenshot(path, filename)
    -- set up the output path
    path = path or acetate.defaultScreenshotPath
    path = path:gsub("/?$", "/") -- ensure trailing slash
    filename = filename or "Playdate-Screenshot-" .. playdate.getSecondsSinceEpoch() ..  ".png"
    local fullPath = path .. filename

    -- capture the image
    local screenshot = playdate.graphics.getDisplayImage()

    -- save the image to disk
    playdate.simulator.writeToFile(screenshot, fullPath)
    print("Saved screenshot to " .. fullPath)
    return true
end

-- capture a screenshot of the specified sprite
function acetate.captureSpriteScreenshot(sprite, path, filename)
    -- abort if there's no sprite to capture
    if not sprite then
        print("Failed to capture sprite screenshot. No sprite provided.")
        return false
    end

    if sprite.width <= 0 or sprite.height <= 0 then
        print("Can't capture a screenshot of a sprite with 0 area. Set a valid width and height.")
        return false
    end

    -- set up the output path
    path = path or acetate.defaultScreenshotPath
    path = path:gsub("/?$", "/") -- ensure trailing slash
    filename = filename
        or "Playdate-" .. sprite.className .. "-Screenshot-" .. playdate.getSecondsSinceEpoch() .. ".png"
    local fullPath = path .. filename

    -- produce the image of the sprite
    local screenshot = sprite:getImage() -- images supersede draw()
    if not screenshot then
        if sprite.draw then
            screenshot = gfx.image.new(sprite.width, sprite.height)
            gfx.lockFocus(screenshot)
                sprite:draw()
            gfx.unlockFocus()
        else
            print("Failed to capture sprite screenshot. No image set or draw() function provided.")
            return false
        end
    end

    -- save the image to disk
    playdate.simulator.writeToFile(screenshot, fullPath)
    print("Saved sprite screenshot to " .. fullPath)
    return true
end

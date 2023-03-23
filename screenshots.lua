import "CoreLibs/graphics"

local gfx <const> = playdate.graphics

-- Basic screenshot capabilities

-- conditionally capture either a sprite or a full-screen screenshot
function Acetate.captureScreenshot()
	-- only capture sprite screenshots while a sprite is focused in debug mode
    if Acetate.enabled and Acetate.focusedSprite and Acetate.spriteScreenshotsEnabled then
        Acetate.captureSpriteScreenshot(Acetate.focusedSprite)
    -- the default
    else
        Acetate.captureFullScreenshot()
    end
end

-- capture a full screenshot
function Acetate.captureFullScreenshot(path, filename)
	-- set up the output path
    local path = path or Acetate.defaultScreenshotPath
    path = path:gsub("/?$", "/") -- ensure trailing slash
    local filename = filename or "Playdate-Screenshot-" .. playdate.getSecondsSinceEpoch() ..  ".png"
    local fullPath = path .. filename

    -- capture the image
    local screenshot = playdate.graphics.getDisplayImage()

    -- save the image to disk
    playdate.simulator.writeToFile(screenshot, fullPath)
    print("Saved screenshot to " .. fullPath)
end

-- capture a screenshot of the specified sprite
function Acetate.captureSpriteScreenshot(sprite, path, filename)
	-- abort if there's no sprite to capture
    if not sprite then
        print("Failed to capture sprite screenshot. No sprite provided.")
        return
    end

    -- set up the output path
    local path = path or Acetate.defaultScreenshotPath
    path = path:gsub("/?$", "/") -- ensure trailing slash
    local filename = filename or "Playdate-" .. sprite.className .. "-Screenshot-" .. playdate.getSecondsSinceEpoch() ..  ".png"
    local fullPath = path .. filename

    -- produce the image of the sprite
    local screenshot = sprite:getImage() -- images supercede draw()
    if not screenshot then
    	if sprite.draw then
	    	screenshot = gfx.image.new(sprite.width, sprite.height)
	    	gfx.lockFocus(screenshot)
	        	sprite:draw()
	    	gfx.unlockFocus()
	    else
	    	print("Failed to capture sprite screenshot. No image set or draw() function provided.")
	    end
    end

    -- save the image to disk
    playdate.simulator.writeToFile(screenshot, fullPath)
    print("Saved sprite screenshot to " .. fullPath)
end

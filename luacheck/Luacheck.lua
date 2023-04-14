-- Acetate globals
--
-- This file can also be used with toyboxpy (https://toyboxpy.io):
--
-- 1. Add this to your project's .luacheckrc:
--    require "toyboxes/luacheck" (stds, files)
--
-- 2. Add 'toyboxes' to your std:
--    std = "lua54+playdate+toyboxes"

return {
    globals = {
        Acetate = {
            fields = {
                super = {
                    fields = {
                        className = {},
                        init = {}
                    },
                },
                className = {},
                init = {},
                loadDebugFont = {},
                debugFontPath = {},
                debugFont = {
                    fields = {
                        drawText = {},
                    }
                },
                _debugDraw = {},
                debugDraw = {},
                _keyPressed = {},
                keyPressed = {},
                enable = {},
                disable = {},
                toggleEnabled = {},
                enabled = {},
                autoPause = {},
                pause = {},
                unpause = {},
                togglePause = {},
                paused = {},
                retainFocusOnDisable = {},
                updateHandlerRef = {},
                color = {},
                showFPS = {},
                showSpriteCount = {},
                showShortcuts = {},
                showDebugString = {},
                spriteCountPersists = {},
                FPSPersists = {},
                focusedSprite = {
                    fields = {
                        isVisible = {},
                    }
                },
                setFocus = {},
                releaseFocus = {},
                cycleFocusForward = {},
                cycleFocusBackward = {},
                updateFocus = {},
                focusInvisibleSprites = {},
                animateBoundsForFocus = {},
                drawBounds = {},
                drawCenters = {},
                drawOrientations = {},
                drawCollideRects = {},
                customDebugDrawing = {},
                onlyDrawRotatedOrbs = {},
                lineWidth = {},
                orientationOrbScale = {},
                minOrientationOrbRadius = {},
                centerRadius = {},
                formatDebugStringForSprite = {},
                debugStringPosition = {
                    fields = {
                        x = {},
                        y = {},
                    }
                },
                alwaysShowSpriteNames = {},
                defaultDebugStringFormat = {},
                shortcutString = {},
                captureScreenshot = {},
                captureSpriteScreenshot = {},
                captureFullScreenshot = {},
                spriteScreenshotsEnabled = {},
                defaultScreenshotPath = {},
                toggleDebugModeKey = {},
                togglePauseKey = {},
                toggleFPSKey = {},
                toggleSpriteCountKey = {},
                captureScreenshotKey = {},
                toggleCentersKey = {},
                toggleBoundsKey = {},
                toggleOrientationsKey = {},
                toggleCollideRectsKey = {},
                toggleInvisiblesKey = {},
                toggleCustomDrawKey = {},
                toggleDebugStringKey = {
                    fields = {
                        gsub = {},
                    }
                },
                keyMatch = {},
                altSymbolForKey = {},
                cycleForwardKey  = {
                    fields = {
                        gsub = {},
                    }
                },
                cycleBackwardKey = {
                    fields = {
                        gsub = {},
                    }
                },
            }
        },
    },
}

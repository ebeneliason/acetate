-- acetate globals
--
-- Luacheck support is provided for only for acetate itself (not tests). To run it,
-- install `luacheck` via `luarocks`, then from the top level Acetate directory:
--
--     % luacheck *.lua
--

return {
    globals = {
        acetate = {
            fields = {
                super = {
                    fields = {
                        className = {},
                        init = {}
                    },
                },
                className = {},
                init = {},
                initialized = {},
                update = {},
                restoreDefaults = {},
                loadConfig = {},
                defaults = {},
                loadDebugFont = {},
                debugFontPath = {},
                debugFont = {
                    fields = {
                        drawText = {},
                        getTextWidth = {},
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
                toggleOverlay = {},
                showOverlay = {},
                overlayColor = {},
                overlayAlpha = {},
                showOverlayOnEnable = {},
                hideOverlayOnDisable = {},
                _tw = {},
                _th = {},
                paused = {},
                retainFocusOnDisable = {},
                updateHandlerRef = {},
                color = {},
                showFPS = {},
                showSpriteCount = {},
                showShortcuts = {},
                showDebugString = {},
                debugStringBackground = {},
                displayPrecision = {},
                paddedPrecision = {},
                spriteCountPersists = {},
                FPSPersists = {},
                focusedSprite = {
                    fields = {
                        isVisible = {},
                        class = {},
                    }
                },
                focusedClass = {
                    fields = {
                        className = {},
                    }
                },
                focusedGroup = {},
                focusSprite = {},
                releaseSpriteFocus = {},
                spriteIsFocusable = {},
                focusClass = {},
                releaseClassFocus = {},
                toggleClassFocus = {},
                focusGroup = {},
                releaseGroupFocus = {},
                getFocusedSprites = {},
                getFocusableSprites = {},
                setGroupName = {},
                setGroupNames = {},
                groupNames = {
                    fields = { "?" },
                },
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
                customOverridesDefaults = {},
                onlyDrawRotatedOrbs = {},
                lineWidth = {},
                orientationOrbScale = {},
                minOrientationOrbRadius = {},
                centerRadius = {},
                formatDebugStringForSprite = {},
                printDebugInfo = {},
                printDebugInfoForSprite = {},
                debugStringPosition = {
                    fields = {
                        x = {},
                        y = {},
                    }
                },
                alwaysShowSpriteNames = {},
                defaultDebugStringFormat = {},
                defaultNudgeDebugStringFormat = {},
                shortcutString = {},
                captureScreenshot = {},
                captureSpriteScreenshot = {},
                captureFullScreenshot = {},
                spriteScreenshotsEnabled = {},
                defaultScreenshotPath = {},
                toggleDebugModeKey = {},
                togglePauseKey = {},
                toggleNudgeKey = {},
                toggleOverlayKey = {},
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
                cycleForwardInClassKey = {},
                cycleBackwardInClassKey = {},
                cycleGroups = {},
                cycleGroupsKey = {},
                cycleDebugGroupKey = {},
                toggleClassFocusKey = {},
                toggleDebugGroupKey ={},
                printDebugInfoKey = {},
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
                nudgeMode = {},
                toggleNudgeMode = {},
                nudge = {},
                stopNudging = {},
                scaleOrRotate = {},
                nudgeReset = {},
                quietMode = {},
            }
        },
        "AcetateEasyPattern",
        table = {
            fields = {
                filter = {},
            }
        },
    },
}

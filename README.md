# Acetate

[![MIT License](https://img.shields.io/github/license/ebeneliason/acetate)](LICENSE) [![Toybox Compatible](https://img.shields.io/badge/toybox.py-compatible-brightgreen)](https://toyboxpy.io) [![Latest Version](https://img.shields.io/github/v/tag/ebeneliason/acetate)](https://github.com/ebeneliason/acetate/tags)

_A visual debugging suite for Playdate._

## What is Acetate?

Acetate is a visual debugging utility for use with the [Playdate](https://play.date/) Simulator,
specifically optimized for use with the `playdate.graphics.sprite` class (and subclasses). It wraps
the built-in functionality for debug drawing, adding:

1.  The ability to do debug drawing from directly within your sprite classes
2.  Out-of-the-box visualizations for your sprites: bounding boxes, center points, rotation, etc.
3.  Controls for cycling through your sprites one by one
4.  Rich debug strings displayed in a custom monospaced font
5.  The option to pause your game while performing visual debugging
6.  Keyboard shortcuts for toggling debug mode and various visualization options
7.  Settings that let you decide how it looks and behaves

![Acetate debug visualizations](./screenshots/acetate_debug_layers.png?raw=true)

_Playdate is a registered trademark of [Panic](https://panic.com)._

## Installation

### Installing Manually

1. Clone this repo into your project folder (e.g. inside `source`).
2. Import it into your project within your `main.lua` file.
3. Move the `Acetate-Mono-*.fnt` files into your `source/fonts/` folder.

You can wrap the `import` statement in a condition to ensure it only loads in the simulator:

```lua
if playdate.isSimulator then
    import "acetate/Acetate" -- update path according to where you placed the directory
end
```

### Using [`toybox.py`](https://toyboxpy.io/)

1.  If you haven't already, download and install [`toybox.py`](https://toyboxpy.io/).
2.  Navigate to your project folder in a Terminal window.

    ```console
    cd "/path/to/myProject"
    ```

3.  Add Acetate to your project

    ```console
    toybox add acetate
    toybox update
    ```

4.  Then, if your code is in the `source` directory, import it as follows:

    ```lua
    import '../toyboxes/toyboxes.lua'
    ```

## Usage

### Introduction

Once you've imported Acetate in your project, you don't need to do anything else to start
taking advantage of its features.

1. Build and run your app in the Playdate Simulator.
2. Press the `D` key on your keyboard to enter debug mode.
3. Use `,` (<) and `.` (>) to cycle through individual sprites.
4. Refer to the list of [keyboard shortcuts](#keyboard-shortcuts) below for additional options.

Read on to learn how to implement custom debug drawing for your sprite classes and customize
the debug string displayed as you cycle through them in debug mode.

### Implementing Custom Debug Drawing for Your Sprites

Acetate provides several debug visualizations out-of-the-box, which are suitable for showing
basic properties common to most sprites. However, you may want to visualize custom properties
unique to your sprite as well. Acetate makes this easy!

You can implement the `debugDraw` function within your `playdate.graphics.sprite` subclasses and
Acetate will ensure it gets called automatically:

```lua
function MySprite:debugDraw()
    -- perform custom debug drawing here
end
```

Acetate prepares the graphics context for you automatically:

-   The color will be set to `kColorWhite` (the color used for all debug drawing).
-   The line width will be set to `1`.
-   The drawing offset will be set according to the position of your sprite, so you can do all
    drawing relative to your sprite (just like in your `draw` function).

Anything you draw within this function will appear in debug mode. You can toggle your custom
debug drawing on/off using the `M` key, or set `Acetate.customDebugDrawing` to `true` or `false`
from within your code.

NOTE: Because fonts are rendered as images and tend to be black-on-white, regular use of `drawText`
variants will likely not appear. To draw text in `debugDraw`, change the image drawing mode so
that your text will render in `kColorWhite` as follows:

```lua
gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
Acetate.debugFont:drawText("This text will render in the debug layer!", x, y)
```

### Reusing Acetate's Built-in Debug Visualizations

Acetate provides a handful of extensions to the sprite class specifically designed for drawing
debug info for common sprite properties. You can toggle these on/off globally using the
[keyboard shortcuts](#keyboard-shortcuts) or Acetate [settings](#settings), but occasionally
you'll want certain features for particular types of sprites and not others. For example, you might
want to show orientation orbs _only_ for sprites which rotate within your game.

You can call any of Acetate's debug draw functions from your own sprite's `debugDraw` function so
that they appear even when they are turned off globally.

```lua
function MySprite:debugDraw()
    self:drawOrientation()
    -- perform additional debug drawing here
end
```

The following built-in debug drawing functions are supported:

-   **`drawBounds`:** Draw the sprite's bounding box
-   **`drawCenter`:** Draw the sprite's center point
-   **`drawOrientation`:** Draw an indicator of the sprite's current rotation
-   **`drawCollideRect`:** Draw the sprite's collision rect, if set. (This option is also provided
    by the simulator itself. You can use the simulator version to overlay collision rects in a
    contrasting color.)

### Focusing Individual Sprites

Acetate allows you to cycle through sprites in the display list using the `,` and `.` keys in order
to see debug visualizations for one at a time. A debug string for the focused sprite is also shown
(the debug string can be toggled with the `/` key).

You can also focus a sprite programmatically. This makes it easy to initiate visual debugging at
the right time and for the right sprite.

```lua
Acetate.setFocus(mySprite)
```

If Acetate's debug mode isn't active when you call this function, it will be enabled automatically.

### Formatting Debug Strings

Acetate displays a debug string for the focused sprite while debug mode is active. By default, this
string indicates the size and position of the sprite. You can modify the debug string format to
include the most useful information for your use case in two ways:

1.  **Change the default.** Modify the `Acetate.defaultDebugFormatString` to change the debug
    string shown for all of your sprites.

2.  **Set custom strings.** Set the `debugFormatString` or `debugString` properties directly on
    your sprites, such as in their `init` functions. `debugFormatString` behaves just like the
    `defaultDebugFormatString`, with substitutions as described in the table below. The value of
    `debugString` will be displayed verbatim, which is slightly more performant at the cost of
    having to format the entire string yourself.

All substitution patterns begin with a dollar sign (`$`) followed by either one or two alphabetical
characters. They are case sensitive.

| Pattern | Substitution                                 |
| ------- | -------------------------------------------- |
| `$n`    | Class name, or `debugName` if provided       |
| `$p`    | Position coordinate in the form `(x, y)`     |
| `$x`    | X position                                   |
| `$y`    | Y position                                   |
| `$w`    | Width                                        |
| `$h`    | Height                                       |
| `$c`    | Center coordinate in local sprite space      |
| `$cx`   | Local center X position                      |
| `$cy`   | Local center Y position                      |
| `$co`   | Local center relative offset e.g. (0.5, 0.5) |
| `$C`    | Center coordinate in world space             |
| `$Cx`   | World center X position                      |
| `$Cy`   | World center Y position                      |
| `$r`    | Rotation (radians)                           |
| `$d`    | Rotation (degrees)                           |
| `$s`    | Scale                                        |
| `$t`    | Tag number                                   |
| `$u`    | Update status as "UPDATING" or "DISABLED"    |
| `$v`    | Visibility as "VISIBLE" or "INVISIBLE"       |
| `$z`    | Z-index                                      |

### Debug Names for Sprites

If you have just a small bit of custom identifying information you'd like to display &mdash; say,
the number of a pin in a bowling pin rack, or the name of a particular character &mdash; but
otherwise wish to use the default debug string settings, you can set the sprite's `debugName`
property. If set, its value will be used instead of the default `className` of the sprite when
cycling through sprites in debug mode. For instance:

```lua
function Pin:init(number)
    Pin.super.init(self)
    self.number = number
    self.debugName = "Pin " .. number
    -- more initialization
end
```

### Keyboard Shortcuts

Acetate provides a number of keyboard shortcuts. You're welcome to change any of these shortcuts
to fit your preference, or avoid conflict with other `keyPress` handlers defined elsewhere. Edit
the settings object or override the defaults in your project e.g. `Acetate.toggleDebugKey = "0"`.

| Key | Function                                                                     |
| --- | ---------------------------------------------------------------------------- |
| D   | Toggle Acetate's visual [D]ebugging mode on/off                              |
| C   | Toggle drawing of sprite [C]enters while in debug mode                       |
| B   | Toggle drawing of sprite [B]ounds while in debug mode                        |
| V   | Toggle drawing of sprite orientation [V]ectors while in debug mode           |
| X   | Toggle drawing of sprite colli[X]ion rects while in debug mode               |
| Z   | Toggle debug drawing of invi[Z]ible sprites while in debug mode              |
| M   | Toggle the use of custo[M] `debugDraw` functions defined in your own sprites |
| F   | Toggle the [F]PS display on/off                                              |
| N   | Toggle the total sprite count on/off                                         |
| /   | [?] Toggle display of the debug string while focused on an individual sprite |
| ,   | [<] Cycle forward through sprites to focus them one by one                   |
| .   | [>] Cycle backward through sprites                                           |
| P   | [P]ause/unpause the game while in debug mode                                 |
| Q   | [Q]uick-capture a screenshot of either the full screen or the focused sprite |

### Screenshots

Acetate also provides a shortcut for capturing instantaneous screenshots from the simulator. While
not strictly a debug feature, it's certainly a useful tool to have in your workflow. Capture
a screenshot by pressing the `Q` key at any time (even outside debug mode), or from within your
code:

```lua
Acetate.captureFullScreenshot([path, filename])
```

_NOTE: Acetate's debug layer will not appear in screenshots._

You can provide a destination path and filename, or let Acetate name it with a timestamp and save
it to the currently configured `Acetate.defaultScreenshotPath`. This is `~/Desktop` by default, but
may be changed in `settings.lua` or from within your app.

If you are focused on an individual sprite while in debug mode when you activate the capture
shortcut, Acetate will capture an image of just that sprite, rather than the full screen. You can
also capture a screenshot of an individual sprite with:

```lua
Acetate.captureSpriteScreenshot(sprite, [path, filename])
```

## Settings

Acetate's settings object allows you to change a wide array of options to configure the debugging
experience. You can change the configuration in one of two ways:

1.  **Edit the file.** You can edit the `settings.lua` file in the Acetate directory of your project
    to change the defaults that will apply when launching your app.

2.  **Set at runtime.** You can update the settings object directly at runtime from within your
    app, e.g. `Acetate.color = {0, 255, 0, 0.8}` and so on.

The following settings are available:

### State Tracking

| Setting     | Type    | Default | Description                                                                                                                          |
| ----------- | ------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `enabled`   | boolean | `false` | Indicates when Acetate debug mode is active. Do not set this directly; call `Acetate.enable()` or `Acetate.disable()` instead.       |
| `paused`    | boolean | `false` | Indicates when the app is paused during debug mode. Do not set this directly; call `Acetate.pause()` or `Acetate.unpause()` instead. |
| `autoPause` | boolean | `false` | Indicates whether the app should pause automatically when entering debug mode.                                                       |

### Debug Visualizations

| Setting              | Type    | Default | Description                                                                              |
| -------------------- | ------- | ------- | ---------------------------------------------------------------------------------------- |
| `drawCenters`        | boolean | `true`  | Whether center points are drawn for all sprites while debug mode is enabled.             |
| `drawBounds`         | boolean | `true`  | Whether bounding rects are drawn for all sprites while debug mode is enabled.            |
| `drawOrientations`   | boolean | `true`  | Whether orientation orbs are drawn for all sprites while debug mode is enabled.          |
| `drawCollideRects`   | boolean | `false` | Whether collision rects are drawn for all sprites while debug mode is enabled.           |
| `customDebugDrawing` | boolean | `true`  | Whether custom debug drawing, implemented in sprite `debugDraw` functions, is performed. |

### Drawing Options

| Setting                   | Type      | Default  | Description                                                                                                                                                     |
| ------------------------- | --------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `color`                   | {r,g,b,a} | cyan 75% | A table containing RGB values ([0,255]) and an alpha value ([0,1]) describing the color used for debug drawing.                                                 |
| `lineWidth`               | number    | `1`      | The default line width set for the debug drawing graphics context.                                                                                              |
| `centerRadius`            | number    | `2`      | The radius of the dot drawn when `drawCenters` is true.                                                                                                         |
| `orientationOrbScale`     | number    | `0.5`    | Orientation orbs are drawn in proportion to the sprite they belong to. This setting describes their _diameter_ with respect to the sprite's shortest dimension. |
| `minOrientationOrbRadius` | number    | `10`     | The minimum radius at which the orbs are drawn for smaller sprites, to aid clarity.                                                                             |
| `onlyDrawRotatedOrbs`     | boolean   | `true`   | Draw orientation orbs only for sprites which have a non-zero rotation. This helps keeps the view uncluttered when sprites aren't being rotated.                 |

### Debug Text

| Setting                    | Type    | Default                               | Description                                                                                                                                                         |
| -------------------------- | ------- | ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `showFPS`                  | boolean | `true`                                | Whether to show the current FPS (frames per second).                                                                                                                |
| `FPSPersists`              | boolean | `false`                               | Whether to show the FPS (frames per second) even while debug mode isn't enabled.                                                                                    |
| `showSpriteCount`          | boolean | `true`                                | Whether to show the total number of sprites.                                                                                                                        |
| `spriteCountPersists`      | boolean | `false`                               | Whether to show the total number of sprites even while debug mode isn't enabled.                                                                                    |
| `showDebugString`          | boolean | `true`                                | Whether the debug string is shown while focused on a single sprite in debug mode.                                                                                   |
| `defaultDebugFormatString` | string  | `"$n\nX: $x\nY: $y\nW: $w\nH: $h"`    | The format used for the debug string for any sprites which don't define their own. See [Debug String Formats](#formatting-debug-strings) for details.               |
| `alwaysShowSpriteNames`    | boolean | `true`                                | Whether to display the highlighted sprite's name even while the debug string is hidden.                                                                             |
| `debugStringPosition`      | {x,y}   | `{2, 2}`                              | A table containing the x and y position at which the debug string is drawn. By default, it draws just beneath the FPS counter at the top left corner of the screen. |
| `debugFontPath`            | string  | `"fonts/Acetate-Mono-Bold-Condensed"` | The path to the font to use for displaying the debug string.                                                                                                        |

### Setting Focus

| Setting                 | Type    | Default | Description                                                                                                           |
| ----------------------- | ------- | ------- | --------------------------------------------------------------------------------------------------------------------- |
| `focusedSprite`         | sprite  | `nil`   | The sprite that is currently focused for debug drawing. You can set this directly or call `Acetate.setFocus(sprite)`. |
| `retainFocusOnDisable`  | boolean | `true`  | When true, the focused sprite will remain focused the next time debug mode is entered.                                |
| `focusInvisibleSprites` | boolean | `false` | Whether to perform debug drawing for and allow focusing of sprites which are made invisible via `setVisible(false)`.  |

### Screenshots

| Setting                    | Type    | Default       | Description                                                                                                                               |
| -------------------------- | ------- | ------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `defaultScreenshotPath`    | string  | `"~/Desktop"` | The default location that all screenshots are saved unless otherwise specified.                                                           |
| `spriteScreenshotsEnabled` | boolean | true          | Whether the capture will contain only the sprite image, not the full screen, if taken while in debug mode and focused on a single sprite. |

### Keyboard Shortcuts

| Setting                 | Type      | Default | Description                                                                     |
| ----------------------- | --------- | ------- | ------------------------------------------------------------------------------- |
| `toggleDebugModeKey`    | character | `"d"`   | Key used to toggle Acetate's visual [D]ebugging mode on/off.                    |
| `toggleCentersKey`      | character | `"c"`   | Key used to toggle drawing of sprite [C]enters while in debug mode.             |
| `toggleBoundsKey`       | character | `"b"`   | Key used to toggle drawing of sprite [B]ounds while in debug mode.              |
| `toggleOrientationsKey` | character | `"v"`   | Key used to toggle drawing of sprite orientation [V]ectors while in debug mode. |
| `toggleCollideRectsKey` | character | `"x"`   | Key used to toggle drawing of sprite colli[X]ion rects while in debug mode.     |
| `toggleInvisiblesKey`   | character | `"z"`   | Key used to toggle debug drawing of invi[Z]ible sprites while in debug mode.    |
| `toggleCustomDrawKey`   | character | `"m"`   | Key used to toggle use of custo[M] sprite `debugDraw` functions.                |
| `toggleFPSKey`          | character | `"f"`   | Key used to toggle [F]PS display on/off.                                        |
| `toggleSpriteCountKey`  | character | `"n"`   | Key used to toggle display of the total sprite count.                           |
| `toggleDebugString`     | character | `"?"`   | Key used to toggle debug string display while focused a single sprite.          |
| `cycleForwardKey`       | character | `">"`   | Key used to cycle forward through sprites, one by one.                          |
| `cycleBackwardKey`      | character | `"<"`   | Key used to cycle backward through sprites, one by one.                         |
| `togglePauseKey`        | character | `"p"`   | Key used to [P]ause/unpause the game while in debug mode.                       |
| `captureScreenshotKey`  | character | `"q"`   | Key used to [Q]uick-capture a screenshot.                                       |

## Troubleshooting

If you can't activate Acetate debug mode for your app in the simulator, check the following:

1.  **Installation.** Be sure you've followed the installation instructions properly, that all
    the Acetate files are included in the directory, and that you've imported Acetate via the
    correct path relative to your source file.

2.  **Keyboard handler.** Acetate implements the `playdate.keyPressed` function, which provides
    shortcuts for, among other things, toggling its debug overlay. If you implement the
    `keyPressed` handler yourself, it will override Acetate's. In this case, you can call
    Acetate's from your own:

    ```lua
    function playdate.keyPressed(key)
        -- let Acetate handle any debug key presses
        Acetate.keyPressed(key)
        -- perform your own key handling here
    end
    ```

3.  **Debug draw.** Acetate implements the `playdate.debugDraw` function in order to render into
    the debug layer of the simulator. If you implement the `debugDraw` function yourself, it
    will override Acetate's. In this case, you can call Acetate's from your own:
    ```lua
    function playdate.debugDraw()
        -- let Acetate do its own debug drawing
        Acetate.debugDraw()
        -- perform additional debug drawing here
    end
    ```
    Note that you may not need to implement `playdate.debugDraw` yourself if you leverage Acetate's
    support for implementing `debugDraw` within your individual sprite classes. (You will, however,
    need to do your own debug drawing for anything not associated with sprites.)

## License

Acetate is distributed under the terms of the [MIT License](https://spdx.org/licenses/MIT.html).

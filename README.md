# Acetate

[![MIT License](https://img.shields.io/github/license/ebeneliason/acetate)](LICENSE) [![Toybox Compatible](https://img.shields.io/badge/toybox.py-compatible-brightgreen)](https://toyboxpy.io) [![Latest Version](https://img.shields.io/github/v/tag/ebeneliason/acetate)](https://github.com/ebeneliason/acetate/tags)

_A visual debugging suite for Playdate._

## What is Acetate?

Acetate is a visual debugging utility for use with the [Playdate](https://play.date/) Simulator,
specifically optimized for use with the `playdate.graphics.sprite` class (and subclasses). It wraps
the built-in functionality for debug drawing, adding:

1.  the ability to perform debug drawing from directly within your sprite classes
2.  out-of-the-box visual debugging for your sprite objects: bounding boxes, orientations,
    center points, etc.
3.  controls for cycling through all extant sprites to display live debug info for each
4.  rich debug string output with a custom monospaced font designed specifically for debugging
5.  the ability to pause your game while performing visual debugging
6.  a host of keyboard shortcuts that can be used to toggle Acetate's debugging UI and various
    layers of debugging information
7.  a simple configuration system that gives you full control over how it looks and behaves

_Playdate is a registered trademark of [Panic](https://panic.com)._

## Installation

### Installing Manually

1. Clone this repo into your project folder (e.g. inside `source`).
2. Import it into your project within your `main.lua` file.
3. Move the `Acetate-Mono-Bold.fnt` file into your `source/fonts/` directory.

You can wrap the import in a condition to ensure it only loads when you're using the simulator:

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
    toybox add ebeneliason/acetate
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

1. Build and run your app in the Playdate simulator
2. Press the `d` key on your keyboard
3. Use `,` (<) and `.` (>) to cycle through individual sprites
4. Refer to the list of keyboard shortcuts below for additional options

Read on to learn how to implement custom debug drawing for your sprite classes and customize
the debug string displayed as you cycle through them in debug mode.

### Implementing Custom Debug Drawing for Your Sprites

Acetate provides a number of basic debug drawing features out-of-the-box suitable for visualizing
basic properties common to most sprites. However, you might have a number of custom properties
unique to your sprite that you'd like to visualize as well. Acetate makes this easy! You can
implement the `debugDraw` function within your `playdate.graphics.sprite` subclasses and Acetate
will ensure it gets called automatically:

```lua
function MySprite:debugDraw()
	-- perform custom debug drawing here
end
```

Acetate sets up the graphics context for you automatically so you don't have to. Specifically:

-   The color will be set to `kColorWhite` (the color used for all debug drawing).
-   The line width will be set to 1.
-   The drawing offset will be set according to the position of your sprite, so you can do all
    drawing relative to your sprite (just like in `draw` itself).

Anything you add to this function will be drawn by default in debug mode. You can toggle it
on/off using the `m` key, or set `Acetate.customDebugDrawing` to `true` or `false` from within
your code.

### Reusing Acetate's Built-in Debug Visualizations

Acetate provides a handful of extensions to the sprite class specifically designed for drawing
debug info for common sprite properties. You can toggle these on/off globally using the keyboard
shortcuts or Acetate settings, but occasionally you'll want certain features for particular types
of sprites and not others. For example, you might want to show orientation orbs _only_ for
sprites which rotate within your game.

You can call any of Acetate's debug draw functions from your own sprite's `debugDraw` function so
that they appear even when they are turned off globally.

```lua
function MySprite:debugDraw()
	self:drawOrientation()
end
```

The following built-in debug drawing functions are supported:

-   **`drawBounds`:** Draw the sprite's bounding box
-   **`drawCenter`:** Draw the sprite's center point
-   **`drawOrientation`:** Draw an indicator of the sprite's current rotation
-   **`drawCollideRect`:** Draw the sprite's collision rect, if set (this option is also provided
    by the simulator itself, and as such can appear as a second debug layer in another color).

### Focusing Individual Sprites

Acetate allows you to cycle through all sprites in the display list using the `,` and `.` keys in
order to see only debug drawing info for that sprite, along with it's debug string (which can be
toggled independently with the `/` key).

You can also bring a sprite into focus programmatically. This makes it easy to reveal debug drawing
at the right time, for the right sprite.

```lua
local mySprite = MySprite()
mySprite:makeDebugDrawFocus()
```

Or from within your sprite class itself:

```lua
self:makeDebugDrawFocus()
```

If Acetate's debug mode isn't active when you call this function, it will toggle on automatically.

### Formatting Debug Strings

Acetate displays a debug string for the focused sprite while debug mode is active. By default, this
string indicates the size and position of the sprite. You can modify the debug string format to
include the most useful information to your use case in two ways:

1.  **Set the default.** Modify the `Acetate.defaultDebugStringFormat` setting to change the
    debug string shown for all of your sprites.

2.  **Set custom strings.** Set the `debugFormatString` or `debugString` properties directly on
    your sprites, such as in their `init` functions. The former behaves just like the default debug
    string, performing substitutions as described in the table below. The latter will display the
    provided string directly, which is slightly more performant depending on your needs at the cost
    of extra work to format the string yourself.

| Pattern | Substitution                                 |
| ------- | -------------------------------------------- |
| `$n`    | Class name                                   |
| `$p`    | Position coordinate in the form `(x, y)`     |
| `$x`    | Y position                                   |
| `$y`    | X position                                   |
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

### Keyboard Shortcuts

Acetate provides a number of keyboard shortcuts. You're welcome to change any of these shortcuts
to fit your preference, or avoid conflict with other `keyPress` handlers defined elsewhere. Edit
the settings object or override the defaults in your project e.g. `Acetate.toggleDebugKey = "0"`.

| Key | Function                                                                            |
| --- | ----------------------------------------------------------------------------------- |
| d   | Toggle Acetate's visual [D]ebugging mode on/off                                     |
| c   | Toggle drawing of sprite [C]enters while in debug mode                              |
| b   | toggle drawing of sprite [B]ounds while in debug mode                               |
| v   | toggle drawing of sprite orientation [V]ectors while in debug mode                  |
| x   | toggle drawing of sprite colli[X]ion rects while in debug mode                      |
| z   | toggle debug drawing of invi[Z]ible sprites while in debug mode                     |
| m   | toggle the use of custo[M] sprite `debugDraw` functions defined in your own sprites |
| f   | toggle the [F]PS display on/off                                                     |
| /   | toggle display of the debug string [?] while focused on an individual sprite        |
| .   | cycle forward [>] through sprites to focus them one by one and show additional info |
| ,   | cycle backward [<] through sprites                                                  |
| p   | [P]ause/unpause the game while in debug mode                                        |

## Settings

Acetate's settings object allows you to change a wide array of options to configure the debugging
experience. You can change the configuration in one of two ways:

1.  **Edit the file.** You can edit the settings file in the Acetate directory in your project to
    update the values that will apply when importing Acetate into your project.

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
| `drawCenters`        | boolean | `true`  | Whether center points are drawn for all sprites when debug mode is enabled.              |
| `drawBounds`         | boolean | `true`  | Whether bounding rects are drawn for all sprites when debug mode is enabled.             |
| `drawOrientations`   | boolean | `true`  | Whether orientation orbs are drawn for all sprites when debug mode is enabled.           |
| `drawCollideRects`   | boolean | `false` | Whether collision rects are drawn for all sprites when debug mode is enabled.            |
| `customDebugDrawing` | boolean | `true`  | Whether custom debug drawing, implemented in spites `debugDraw` functions, is performed. |

### Debug Text

| Setting                    | Type    | Default                            | Description                                                                                                                                                   |
| -------------------------- | ------- | ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `showFPS`                  | boolean | `true`                             | Whether to show the current FPS (frames per second).                                                                                                          |
| `showFPSAlways`            | boolean | `false`                            | Whether to show the FPS (frames per second) even when debug mode isn't enabled.                                                                               |
| `showDebugString`          | boolean | `true`                             | Whether the debug string is show when focused on a single sprite in debug mode.                                                                               |
| `defaultDebugStringFormat` | string  | `"$n\nX: $x\nY: $y\nW: $w\nH: $h"` | The debug string format used for any sprites which don't define their own. See [Debug String Formats](#formatting-debug-strings) for details.                 |
| `debugStringPosition`      | {x, y}  | `{2, 14}`                          | A table containing the x and y position at which the debug string is drawn. By default, it draws just beneath the FPS counter at the left edge of the screen. |
| `debugFontPath`            | string  | `"fonts/Acetate-Mono-Bold"`        | The path to the font to use for displaying the debug string.                                                                                                  |

### Drawing Options

| Setting                   | Type         | Default  | Description                                                                                                                                              |
| ------------------------- | ------------ | -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `color`                   | {r, g, b, a} | cyan 85% | A table containing RGB values ([0,255]) and an alpha value ([0,1]) describing the color used for debug drawing.                                          |
| `lineWidth`               | number       | `1`      | The default line width set for the debug drawing graphics context.                                                                                       |
| `CenterRadius`            | number       | `2`      | The radius of the dot drawn when `drawCenters` is true.                                                                                                  |
| `orientationOrbScale`     | number       | `0.5`    | Orientation orbs are drawn in proportion to the sprite they belong to. This setting describes their _diameter_ with respect to their shortest dimension. |
| `minOrientationOrbRadius` | number       | `10`     | This minimum radius at which the orbs are drawn for smaller sprites, for clarity.                                                                        |
| `onlyDrawRotatedOrbs`     | boolean      | `true`   | Draw orientation orbs only for sprites which have a non-zero rotation.                                                                                   |

### Setting Focus

| Setting                 | Type    | Default | Description                                                                                                           |
| ----------------------- | ------- | ------- | --------------------------------------------------------------------------------------------------------------------- |
| `focusedSprite`         | sprite  | `nil`   | The sprite that is currently focused for debug drawing. You can set this directly or call `Acetate.setFocus(sprite)`. |
| `unfocusOnDisable`      | boolean | `true`  | When true, Acetate will revert to debug drawing for all sprites the next time it is enabled.                          |
| `debugInvisibleSprites` | boolean | `false` | Whether to perform debug drawing for sprites which are made invisible via `setVisible(false)`.                        |

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
| `toggleFPSDisplay`      | character | `"f"`   | Key used to toggle [F]PS display on/off.                                        |
| `toggleDebugString`     | character | `"/"`   | Key used to toggle debug string display [?] while focused a single sprite.      |
| `cycleForwardKey`       | character | `"."`   | Key used to cycle forward [>] through sprites, one by one.                      |
| `cycleBackwardKey`      | character | `","`   | Key used to cycle backward [<] through sprites, one by one.                     |
| `togglePauseKey`        | character | `"p"`   | Key used to [P]ause/unpause the game while in debug mode.                       |

### Troubleshooting

If you can't activate Acetate debug mode for your app in the simulator, check the following:

1.  **Installation.** Be sure you've followed the installation instructions properly, that all
    the Acetate files are included in the directory, and that you've imported Acetate via the
    correct path relative to your source file.

2.  **Keyboard handler.** Acetate implements Playdate's `keyPressed` handler, which provides
    shortcuts for, among other things, toggling its debug overlay. If you implement the
    `keyPressed` handler yourself, it will override Acetate's. In this case, you can call
    Acetate's key press handler manually from your own:

    ```lua
    function playdate.keyPressed(key)
        -- let Acetate handle any debug key presses
        Acetate.keyPressed(key)
        -- perform your own key handling here
    end
    ```

3.  **Debug draw.** Acetate implements Playdate's `debugDraw` function in order to render into
    the debug layer of the simulator. If you implement the `debugDraw` function yourself, it
    will override Acetate's. In this case, you can call Acetate's `debugDraw` function
    manually from your own:
    ```lua
    function playdate.debugDraw()
        -- let Acetate do its own debug drawing
        Acetate.debugDraw()
        -- perform additional debug drawing here
    end
    ```
    Note you may not need to implement `debugDraw` yourself if you leverage Acetate's support
    for implementing `debugDraw` within your individual sprite classes. (You will, however,
    need to do your own debug drawing for any debugging not associated with sprites.)

## License

Acetate is distributed under the terms of the [MIT License](https://spdx.org/licenses/MIT.html).

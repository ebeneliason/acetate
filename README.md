# Acetate

[![MIT License](https://img.shields.io/github/license/ebeneliason/acetate)](LICENSE) [![Toybox Compatible](https://img.shields.io/badge/toybox.py-compatible-brightgreen)](https://toyboxpy.io) [![Latest Version](https://img.shields.io/github/v/tag/ebeneliason/acetate)](https://github.com/ebeneliason/acetate/tags)

_A visual debugging suite for Playdate._

## What is Acetate?

Acetate is a visual debugging utility for use with the [Playdate](https://play.date/) Simulator,
optimized for use with `playdate.graphics.sprite` classes. With Acetate, you can easily
enter a visual debugging mode at any time, cycle through debug visualizations for each sprite, and optionally
customize the visuals and information shown for each from directly within your sprite classes.

Acetate wraps the built-in functionality for debug drawing, and adds:

2.  Out-of-the-box visualizations for common properties: bounding boxes, center points, collision rects, rotation, etc.
3.  The ability to cycle through debug info for each sprite, one by one
4.  Rich debug strings displayed in a bespoke monospaced font
5.  The ability to do custom debug drawing from directly within your sprite classes
6.  An option to pause your game while performing visual debugging
7.  Customizable keyboard shortcuts for toggling debug mode and various visualization options
8.  Settings that let you decide how it looks and behaves

![Acetate debug visualizations](./screenshots/acetate_debug_layers.png?raw=true)

_Playdate is a registered trademark of [Panic](https://panic.com)._

## Installation

### Installing Manually

1.  Clone this repo into your project folder (e.g. inside `source`).
2.  Move the `Acetate-Mono-*.fnt` files into your `source/fonts/` folder.
3.  Import it into your project within your `main.lua` file.

    ```lua
    import 'Acetate/acetate'
    ```

4.  Initialize it for use.

    ```lua
    acetate.init()
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

5.  Lastly, be sure to initialize it.

    ```lua
    acetate.init()
    ```

## Usage

### Introduction

Once you've imported Acetate in your project, you don't need to do anything else to start
taking advantage of its features.

1. Build and run your app in the Playdate Simulator.
2. Press the `D` key on your keyboard to enter debug mode.
3. Use `,` (`<`) and `.` (`>`) to cycle through sprites (hold `SHIFT` to cycle through
   sprites of the same class as the currently focused sprite).
4. Refer to the list of [keyboard shortcuts](#keyboard-shortcuts) for additional options.

Out of the box, you can see the following information for each sprite:

- class name
- size and position
- bounding box
- center point
- collision rect
- orientation orb

You can also easily display additional information and visualizations unique to your sprites. Read
on to learn how to implement custom debug drawing for your sprite classes and customize the debug
string displayed as you cycle through them in debug mode.

_**NOTE:** If your game adjusts the draw offset, you may need to cache it so that debug drawing
appears in the correct position relative to your sprites. See the [#Troubleshooting](troubleshooting)
section for additional details._

### Customizing Debug Drawing for Your Sprites

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

- The color will be set to `kColorWhite` (the color used for all debug drawing).
- The line width will be set to `1`.
- The drawing offset will be set according to the position of your sprite, so you can do all
  drawing relative to your sprite (just like in your `draw` function).

Anything you draw within this function will appear in debug mode. You can toggle your custom
debug drawing on/off using the `M` key, or set `acetate.customDebugDrawing` to `true` or `false`
from within your code.

#### Rendering Text

Because fonts are rendered as images and tend to be black-on-white, regular use of `drawText`
variants will likely not appear. To draw text in `debugDraw`, change the image drawing mode so
that your text will render in `kColorWhite` as follows:

```lua
gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
acetate.debugFont:drawText("This text will render in the debug layer!", x, y)
```

#### Reusing Acetate's Built-in Debug Visualizations

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

- **`drawBounds`:** Draw the sprite's bounding box
- **`drawCenter`:** Draw the sprite's center point
- **`drawOrientation`:** Draw an indicator of the sprite's current rotation
- **`drawCollideRect`:** Draw the sprite's collision rect, if set. (This option is also provided
  by the simulator itself. You can use the simulator version to overlay collision rects in a
  contrasting color.)

### Displaying Debug Information

#### Sprite Debug Names

If you have a small bit of custom identifying information you'd like to display &mdash; say, the
number of a pin in a bowling pin rack, or the name of a particular character &mdash; you can set
the sprite's `debugName` property. When set, the debug name will be shown instead of the `className`
of the sprite when cycling through sprites in debug mode. For instance:

```lua
function Pin:init(number)
    Pin.super.init(self)
    self.number = number
    self.debugName = "Pin " .. number
    -- more initialization
end
```

#### Formatting Debug Strings

Acetate displays a debug string for the focused sprite while debug mode is active. By default, this
string indicates the size and position of the sprite. You can modify the debug string format to
include the most useful information for your use case in two ways:

1.  **Change the default.** Modify the `acetate.defaultDebugStringFormat` to change the debug
    string shown for all of your sprites.

2.  **Set custom strings.** Implement the `debugString()` function on your sprite. You can provide a
    fully formatted string, or include substitution patterns as shown in the table below,
    passing `true` as a second return value to indicate that substitutions are needed.

    ```lua
    function MySprite:debugString()
        local s
        -- construct `s` using any properties belonging to your sprite
        return s, true -- true indicates that substitutions are needed
    end
    ```

All substitution patterns begin with a dollar sign (`$`) followed by up to three alphabetical
characters. They are case sensitive.

| Pattern      | Substitution                                 |
| ------------ | -------------------------------------------- |
| `$n`         | `debugName` if given, class name otherwise   |
| `$cn`        | Class name                                   |
| `$str`       | `tostring()` output                          |
| `$a`         | Memory address                               |
| `$p`, `$pos` | Position coordinate in the form `(x, y)`     |
| `$x`         | X position                                   |
| `$y`         | Y position                                   |
| `$w`         | Width                                        |
| `$h`         | Height                                       |
| `$rx`        | Local relative horizontal center             |
| `$ry`        | Local relative vertical center               |
| `$rc`        | Local relative center point, e.g. (0.5, 0.5) |
| `$o`         | Origin coordinate (top left) in local space  |
| `$ox`        | Local origin X position                      |
| `$oy`        | Local origin Y position                      |
| `$O`         | Origin coordinate in world space             |
| `$Ox`        | Local origin X position                      |
| `$Oy`        | Local origin Y position                      |
| `$c`         | Center coordinate in local space             |
| `$cx`        | Local center X position                      |
| `$cy`        | Local center Y position                      |
| `$C`         | Center coordinate in world space             |
| `$Cx`        | World center X position                      |
| `$Cy`        | World center Y position                      |
| `$r`, `$rad` | Rotation (radians)                           |
| `$d`, `$deg` | Rotation (degrees)                           |
| `$s`         | Scale                                        |
| `$t`, `$tag` | Tag number                                   |
| `$q`         | Opaqueness as "OPAQUE" or "TRANSPARENT"      |
| `$u`         | Update status as "UPDATING" or "DISABLED"    |
| `$v`         | Visibility as "VISIBLE" or "INVISIBLE"       |
| `$z`         | Z-index                                      |

#### Printing Debug Info

You can print debug information for the currently focused sprite(s) to the console by pressing the `I` key. This makes it easy to review, compare, or copy/paste values. This works regardless of whether the current focus is an individual sprite, a class, a debug group, or all sprites currently in the global sprite list.

You can also dump debug info for a sprite programmatically in order to easily view debug data at specific points in your program's execution:

```lua
mySprite:printDebugInfo()
```

If desired, you can add a prefix that will print immediately before the info to provide context. Here's what that looks like if you print from within your sprite class:

```lua
-- e.g inside an overridden setSize()
self:printDebugInfo("Resized")
```

You can override the standard debug string in order to print just the information relevant in context, while still utilizing the convenience of Acetate's debug string substitution patterns. For example, here's how you could print just the updated size and center position of your sprite:

```lua
-- e.g inside an overridden setSize()
self:printDebugInfo("RESIZED", "$n: $sz, $c")
```

Which would output the following:

```console
RESIZED
MySprite: 100 x 200 (50, 100)
```

Lastly, Acetate also provides a convenience for printing the traceback to a given line of program execution. This also accepts an optional prefix and format string, just like `printDebugInfo()`.

```lua
-- from anywhere within your sprite
self:printDebugTrace("How did we get here?")
```

### Managing Focus

Cycling focus to obtain debug info for specific sprites is central to Acetate's functionality. Highlighting individual sprites or groups of related sprite allows you to isolate visual debug layers or access textual debug output for the things that matter in the moment, without needing to comment/uncomment and rebuild to surface that data. The beauty of Acetate is that you can define detailed debug visuals and text output for each class as part of its design, so it's all at the ready the next time you need to debug, without getting in the way in the meantime.

Acetate offers three main affordances for managing focus:

1. By sprite. Cycle through all sprites in the display list.
2. By class. Cycle through all sprites of a given class.
3. By Group. Cycle through sprites within an explicitly defined group.

As you focus each sprite, their visual debug drawing layer will appear. You can also toggle display of the sprite's debug string with the `/` (`?`) key. While a sprite is focused, you can also press the `I` key to print its debug string to the console for easy viewing/copying.

#### Cycling Through Sprites

Cycling through sprites one-by-one is Acetate's basic interaction mode. Press the comma (',') and period (`.`) keys to cycle backward and forward through the list of extant sprites, respectively. (As a "mnemonic" of sorts, it may be helpful to think of these as the `<` (backward) and `>` (forward) keys. When you first enable Acetate, _all_ visible sprites in the SDKs display list are focused at once—use these keys to isolate each in sequence.

> [!NOTE]
> Invisible sprites are excluded from the focus list by default. Press the `Z` key to toggle their inclusion.

#### Class Focus

Hold `SHIFT` while cycling to constrain focus to the currently selected sprite class. This makes it easy to quickly iterate through and compare similar sprites. You can also lock focus to the currently selected class by pressing the 'L' key, at which point you can continue cycling through sprites of that class without the `SHIFT` modifier. Press `L` again to unlock focus. A 🔒 symbols is displayed with the sprite name while class focus is locked.

#### Debug Groups

Debug groups make it easy to inspect distinct groups of sprites together, without the visual noise of other unrelated sprites. It also enables you to swiftly cycle through sprites in a given group. Set the `debugGroup` property of your sprite to a value in the range [1-9] to add it to that group.

```lua
mySprite.debugGroup = 1
```

Press the corresponding key while in debug mode to focus all sprites in that group. While a group is focused, the `.` [<] and `,` [>] keys will cycle through the sprites in the group. Press `0` to unfocus a debug group and restore default focus behaviors. The group number (or name, if set) will be shown while a group is focused. You can define names for each group by providing a list for the `groupNames` configuration setting.

#### Programmatically Focusing Sprites

Acetate allows you to cycle through sprites in the display list manually using the `,` and `.` keys. However,
you can also focus sprites programmatically, for example in response to a particular game event or
condition. This makes it easy to initiate visual debugging at the right time and for the right sprite.

```lua
-- focus a single sprite
acetate.focusSprite(mySprite)
-- release focus
acetate.releaseSpriteFocus()
```

If Acetate's debug mode isn't active when you call this function, it will be enabled automatically.
Optionally, you can enable the auto-pause behavior by setting `acetate.autoPause` to `true` (in init,
or at runtime), in order to pause for inspection when focusing your sprite.

You can also lock the focus to a specific class, so only sprites of that class get focused when
cycling with the keyboard shortcuts:

```lua
-- focus by class
acetate.focusClass(MyClass)
-- release focus
acetate.releaseClassFocus()
```

You can focus your debug groups by number or name:

```lua
-- focus group by number
acetate.focusGroup(1)
-- focus group by name
acetate.focusGroup("Enemy")
-- unlock focus
acetate.releaseGroupFocus()
```

Finally, you can remove all focus constraints to restore access to the entire display list:

```lua
acetate.releaseFocus()
```

### Keyboard Shortcuts

Acetate provides a number of keyboard shortcuts. You're welcome to change any of these shortcuts
to fit your preference, or avoid conflict with other `keyPress` handlers defined elsewhere. Edit
the settings object or override the defaults in your project e.g. `acetate.toggleDebugKey = "0"`.

| Key   | Function                                                                     |
| ----- | ---------------------------------------------------------------------------- |
| D     | Toggle Acetate's visual [D]ebugging mode on/off                              |
| C     | Toggle drawing of sprite [C]enters while in debug mode                       |
| B     | Toggle drawing of sprite [B]ounds while in debug mode                        |
| V     | Toggle drawing of sprite orientation [V]ectors while in debug mode           |
| X     | Toggle drawing of sprite colli[X]ion rects while in debug mode               |
| Z     | Toggle debug drawing of invi[Z]ible sprites while in debug mode              |
| M     | Toggle the use of custo[M] `debugDraw` functions defined in your own sprites |
| F     | Toggle the [F]PS display on/off                                              |
| N     | Toggle the total sprite count on/off                                         |
| /     | [?] Toggle display of the debug string while focused on an individual sprite |
| I     | Dump debug string [I]nfo for the currently focused sprite(s) to the console  |
| ,     | [<] Cycle forward through sprites to focus them one by one                   |
| .     | [>] Cycle backward through sprites                                           |
| <     | [SHIFT <] Cycle forward through sprites of the same class                    |
| >     | [SHIFT >] Cycle backward through sprites of the same class                   |
| L     | [L]ock focus cycling to the focused sprite class                             |
| P     | [P]ause/unpause the game for/while debugging                                 |
| Q     | [Q]uick-capture a screenshot of either the full screen or the focused sprite |
| [1-9] | Focus debug group (press again, or 0 to unfocus)                             |

### Screenshots

Acetate provides a shortcut for capturing instantaneous screenshots from the simulator. While
not strictly a debug feature, it's certainly a useful tool to have in your workflow. Capture
a screenshot by pressing the `Q` key at any time (even outside debug mode), or from within your
code:

```lua
acetate.captureFullScreenshot([path, filename])
```

_NOTE: Acetate's debug layer will not appear in screenshots._

You can provide a destination path and filename, or let Acetate name it with a timestamp and save
it to the currently configured `acetate.defaultScreenshotPath`. This is `~/Desktop` by default, but
may be changed in `settings.lua` or from within your app.

If you are focused on an individual sprite while in debug mode when you activate the capture
shortcut, Acetate will capture an image of just that sprite, rather than the full screen. You can
also capture a screenshot of an individual sprite with:

```lua
acetate.captureSpriteScreenshot(sprite, [path, filename])
```

## Settings

Acetate's settings object allows you to change a wide array of options to configure the debugging
experience. You can change the configuration in one of several ways:

1.  **Override at `init`.** You can override any defaults by passing named arguments to init:

    ```lua
    acetate.init {
        autoPause = true,
        debugColor = {0, 1, 0, 0.8},
        -- as many as you like
    }
    ```

2.  **Create a custom config.** If you intend to change many settings, or just want to keep your
    initialization code to a minimum, you can duplicate the `settings.lua` file, give the settings object
    therein a unique name (e.g. `myAcetateSettings = { … }`, import that file in `main.lua`, and then
    pass the named config object to `init`:

    ```lua
    acetate.init(myAcetateSettings)
    ```

3.  **Set individual values.** You can also override individual settings from within your app at
    runtime following initialization, e.g. `acetate.color = {0, 1, 0, 0.8}` and so on.

The following settings are available:

### State Tracking

| Setting     | Type    | Default | Description                                                                                                                          |
| ----------- | ------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `enabled`   | boolean | `false` | Indicates when Acetate debug mode is active. Do not set this directly; call `acetate.enable()` or `acetate.disable()` instead.       |
| `paused`    | boolean | `false` | Indicates when the app is paused during debug mode. Do not set this directly; call `acetate.pause()` or `acetate.unpause()` instead. |
| `autoPause` | boolean | `false` | Indicates whether the app should pause automatically when entering debug mode.                                                       |

### Debug Visualizations

| Setting                   | Type    | Default | Description                                                                             |
| ------------------------- | ------- | ------- | --------------------------------------------------------------------------------------- |
| `drawCenters`             | boolean | `true`  | Center points are shown for all sprites in debug mode when true.                        |
| `drawBounds`              | boolean | `true`  | Bounding rects are shown for all sprites in debug mode when true.                       |
| `drawOrientations`        | boolean | `true`  | Orientation orbs are shown for all sprites in debug mode when true.                     |
| `drawCollideRects`        | boolean | `false` | Collision rects are shown for all sprites while debug mode is enabled.                  |
| `customDebugDrawing`      | boolean | `true`  | Custom debug drawing (implemtented in sprite `debugDraw` functions) is shown when true. |
| `customOverridesDefaults` | boolean | `false` | Built-in debug drawing is hidden for sprites with custom debug drawing when true.       |

### Drawing Options

| Setting                   | Type      | Default  | Description                                                                                                                                                     |
| ------------------------- | --------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `color`                   | {r,g,b,a} | cyan 75% | A table containing RGBA values (in range [0,1]) describing the color used for debug drawing.                                                                    |
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
| `displayPrecision`         | number  | `3`                                   | An integer specifying the desired number of decimals used to display values for the provided format string.                                                         |
| `alwaysShowSpriteNames`    | boolean | `true`                                | Whether to display the highlighted sprite's name even while the debug string is hidden.                                                                             |
| `debugStringPosition`      | {x,y}   | `{2, 2}`                              | A table containing the x and y position at which the debug string is drawn. By default, it draws just beneath the FPS counter at the top left corner of the screen. |
| `debugFontPath`            | string  | `"fonts/Acetate-Mono-Bold-Condensed"` | The path to the font to use for displaying the debug string.                                                                                                        |

### Setting Focus

| Setting                 | Type    | Default | Description                                                                                                          |
| ----------------------- | ------- | ------- | -------------------------------------------------------------------------------------------------------------------- |
| `retainFocusOnDisable`  | boolean | `true`  | When true, the focused sprite will remain focused the next time debug mode is entered.                               |
| `focusInvisibleSprites` | boolean | `false` | Whether to perform debug drawing for and allow focusing of sprites which are made invisible via `setVisible(false)`. |
| `animateBoundsForFocus` | boolean | `true`. | When true, the bounds of the focused sprite will appear as an animated "marching ants" dotted line                   |

### Screenshots

| Setting                    | Type    | Default       | Description                                                                                                                               |
| -------------------------- | ------- | ------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `defaultScreenshotPath`    | string  | `"~/Desktop"` | The default location that all screenshots are saved unless otherwise specified.                                                           |
| `spriteScreenshotsEnabled` | boolean | true          | Whether the capture will contain only the sprite image, not the full screen, if taken while in debug mode and focused on a single sprite. |

### Keyboard Shortcuts

| Setting                   | Type      | Default | Description                                                                           |
| ------------------------- | --------- | ------- | ------------------------------------------------------------------------------------- |
| `toggleDebugModeKey`      | character | `"d"`   | Key used to toggle Acetate's visual [D]ebugging mode on/off.                          |
| `toggleCentersKey`        | character | `"c"`   | Key used to toggle drawing of sprite [C]enters while in debug mode.                   |
| `toggleBoundsKey`         | character | `"b"`   | Key used to toggle drawing of sprite [B]ounds while in debug mode.                    |
| `toggleOrientationsKey`   | character | `"v"`   | Key used to toggle drawing of sprite orientation [V]ectors while in debug mode.       |
| `toggleCollideRectsKey`   | character | `"x"`   | Key used to toggle drawing of sprite colli[X]ion rects while in debug mode.           |
| `toggleInvisiblesKey`     | character | `"z"`   | Key used to toggle debug drawing of invi[Z]ible sprites while in debug mode.          |
| `toggleCustomDrawKey`     | character | `"m"`   | Key used to toggle use of custo[M] sprite `debugDraw` functions.                      |
| `toggleFPSKey`            | character | `"f"`   | Key used to toggle [F]PS display on/off.                                              |
| `toggleSpriteCountKey`    | character | `"n"`   | Key used to toggle display of the total sprite count.                                 |
| `toggleDebugStringKey`    | character | `"?"`   | Key used to toggle debug string display while focused a single sprite.                |
| `printDebugInfoKey`       | character | `"I"`   | Key used to print the debug [I]nfo for the currently selected sprite(s).              |
| `cycleForwardKey`         | character | `"."`   | Key used to cycle forward through sprites, one by one.                                |
| `cycleBackwardKey`        | character | `","`   | Key used to cycle backward through sprites, one by one.                               |
| `cycleForwardInClassKey`  | character | `">"`   | Key used to cycle forward to the next sprite of the same class as the focused sprite. |
| `cycleBackwardInClassKey` | character | `"<"`   | Key used to cycle backward through sprites of the same class as the focused sprite.   |
| `toggleClassFocusKey`     | character | `"l"`   | Key used to [L]ock focus cycling to sprites of the same class as the focused sprite.  |
| `togglePauseKey`          | character | `"p"`   | Key used to [P]ause/unpause the game while in debug mode.                             |
| `captureScreenshotKey`    | character | `"q"`   | Key used to [Q]uick-capture a screenshot.                                             |

## Troubleshooting

### I can't enable the acetate debug layer.

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
        acetate.keyPressed(key)
        -- perform your own key handling here
    end
    ```

    If acetate keyboard handling interferes with your own, you can modify the keyboard shortcuts
    with custom settings, including the key used to enable/disble the acetate debug layer.

3.  **Debug draw.** Acetate implements the `playdate.debugDraw` function in order to render into
    the debug layer of the simulator. If you implement the `debugDraw` function yourself, it
    will override Acetate's. In this case, you can call Acetate's from your own:

    ```lua
    function playdate.debugDraw()
        -- let Acetate do its own debug drawing
        acetate.debugDraw()
        -- perform additional debug drawing here
    end
    ```

    Note that you may not need to implement `playdate.debugDraw` yourself if you leverage Acetate's
    support for implementing `debugDraw` within your individual sprite classes. (You will, however,
    need to do your own debug drawing for anything not associated with sprites.)

### Debug drawing doesn't align properly with my sprites.

Acetate attempts to adjust the draw offset so that debug drawing aligns properly with your sprites.
However, if your project adjusts the draw offset itself (via `playdate.graphics.setDrawOffset()`),
Acetate may not have sufficient knowledge to do so correctly. In this case, provide Acetate with
the appropriate draw offset by calling `cacheDrawOffset` from within your sprite's `draw` function:

```lua
function MySprite:draw()
    self:cacheDrawOffset()
    -- draw...
end
```

### Help, my app keeps crashing on Playdate hardware!

Acetate is not initialized on-device. Attempting to access its members or call its functions outside
the simulator will cause Playdate to crash. You can do so safely from within any _functions_ you write
(e.g. `debugString()`, `debugDraw()`, etc.) or within key handlers, as these will only be called inside
the simulator. Any access outside these contexts should be wrapped within a check to ensure acetate
has been initialized:

```lua
if acetate.initialized then
    -- safe to access acetate members here, for example to call `acetate.focusSprite(mySprite)`
end
```

## License

Acetate is distributed under the terms of the [MIT License](https://spdx.org/licenses/MIT.html).

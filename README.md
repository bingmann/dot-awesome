dot-awesome
===========

This repository contains my config for the AwesomeWM tiling window manager.

The default config of awesome is neither pretty, nor efficient and intuitive. My attempts to amend these drawbacks were somewhat successful, but there is still room for improvement. This config is therefore public to help others to start working with AwesomeWM.

In the following I will try to give a summary of the most common keys and gestures, the list is not complete. Please refer to the config itself for more window manipulation keys.

## Most Important Key Strokes

Most keys require the "Super" modifier, which is usually the Windows key.

 * Super-Enter - starts default terminal (urxvt)
 * Super-\ (Backslash) - start gnome-terminal
 * Super-Left/Right - switch virtual desktop left/right
 * Super-Up/Down - switch focus to window above/below on current desktop
 * Super-[1234567890] - switches to virtual desktop
 * Super-s - start programs in freedesktop application list
 * Super-r - run programs via plain Awesome launcher
 * Super-q - Quit/Close the currently focused window
 * Super-w - Launch webbrowser (firefox)
 * Super-f - Launch file manager (thunar)
 * Super-e - Launch editor (emacs)
 * Super-Shift-e - Exit Awesome
 
The config contains the above programs as default applications. If you want others, change the config.

## Common Mouse Gestures

The "window title" denotes the window description in the top bar.

 * Move - Focus follows the mouse, thus move the mouse to desired window, the focused window is red.
 * LeftClick - the window title hides (minimize?) the window, and grays it in the top bar.
 * Super-LeftClick - on a window **moves** the window among the tiles (or freely if floating).
 * Super-RightClick - resizes the current tiling boundaries or the focused floating window.
 * Middle-Click - a window title **closes** the window.
 * Wheel - The mouse wheel on desktop numbers switches the virtual desktops.
 * Shift+LeftClick on the numbers moves the focused window.
 * Shift+RightClick on the desktop show windows from both desktops at once.
 
## More Advanced Key Strokes
  
 * Super-Space - Switches layouts, I removed all but the most useful.
 * Super-Shift-Space - Cycles layouts in other direction.
 * Super-Tab - Switches to next monitor/screen in Multi-Monitor config.
 * Super-Ctrl-Up/Down - Cycles through other monitor/screens.
 * Super-a - Moves focused window to next monitor/screen.
 * Super-Shift-[1234567890] - Moves focused windows to other virtual desktop.
 * Super-z - Floats/Unfloats the focused window,
 * Super--/= (Minus/Equal) - Resizes the master tile size (I usually used the mouse).
 * Super-Shift--/= (Minus/Equal) - Add/Remove tile compartments to the master view.

## FAQ
 
Why is the focus color **red**?
 - because red+black is a cool color combination.
 - because red is the color of attention.
 - because I don't need to present a **blue**, cool, confident corporate image.

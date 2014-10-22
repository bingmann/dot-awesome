dot-awesome
===========

This repository contains my config for the AwesomeWM tiling window manager.

The default config of awesome is neither pretty, nor efficient and intuitive. My attempts to amend these drawbacks were somewhat successful, but there is still room for improvement. This config is therefore public to help others to start working with AwesomeWM.

In the following I will try to give a summary of the most common keys and gestures, the list is not complete. Please refer to the config itself for more window manipulation keys.

## Most Important Key Strokes

Most keys require the "Super" modifier, which is usually the Windows key (see FAQ on how to change CapsLock to Super).

Key                 | Action
------------------- | ------------------------------------------------------
Super-Enter         | starts default **terminal** (urxvt)
Ctrl+Alt+Shift Enter | also starts the default terminal (backup, in case Super doesn't work)
Super-\ (Backslash) | start gnome-terminal
Super-Left/Right    | switch virtual desktop left/right
Super-Up/Down       | switch focus to window above/below on current desktop
Super-[1234567890]  | switches to virtual desktop
Super-~ (Tilde)     | **Maximize**/Unmaximized the focused window (very useful).
Super-s             | **start** programs in freedesktop application list
Super-r             | **run** programs via plain Awesome launcher
Super-q             | **Quit**/Close the currently focused window
Super-w             | Launch **webbrowser** (firefox)
Super-f             | Launch **file** manager (thunar)
Super-e             | Launch **editor** (emacs) with default TODO file.
Break/Pause or Super-l | **Lock** screen using screensaver (xscreensaver)
Super-Ctrl-e       | **Exit** Awesome
Super-Ctrl-r       | **Reload** Awesome config
Super-Ctrl-w       | Switch to new random **wallpaper** (see FAQ)
 
The config contains the above programs as default applications. If you want others, change the config.

## Common Mouse Gestures

The "title" denotes the window title description in the top bar, the "window" any window frame, and "number" one of the 10 virtual desktop numbers in the top bar.

Gesture                 | Action
----------------------- | --------------------------------------------------------------------------------------------
Move                    | Focus follows the mouse, thus move the mouse to desired window, the focused window is red.
LeftClick title         | The window title hides/unhides (minimize?) the window, and grays it in the top bar.
Super-LeftClick window  | **Moves** the clicked window among the tiles (or freely if floating).
Super-RightClick window | **Resizes** the current tiling boundaries or the focused floating window.
Middle-Click title      | **Closes** the window.
Wheel number            | The mouse wheel on desktop numbers switches the virtual desktops.
LeftClick number        | Switch virtual desktop.
RightClick number       | Show both, current and clicked, virtual desktop at once.
Shift+LeftClick number  | Moves the focused window to the virtual desktop.
Shift+RightClick number | Copies/Removes the focused window to the virtual desktop (it is shown on both).
 
## More Advanced Key Strokes
  
Key                           | Action
----------------------------- | ------------------------------------------------------
Super-Space                   | Switches layouts, I removed all but the most useful.
Super-Shift-Space             | Cycles layouts in other direction.
Super-Tab                     | Switches to next monitor/screen in Multi-Monitor config.
Super-Ctrl-Up/Down            | Cycles through other monitor/screens.
Super-a                       | Moves focused window to next monitor/screen.
Super-Shift-[1234567890]      | Moves focused windows to other virtual desktop (beware of the mouse follow focus!)
Super-z                       | Floats/Unfloats the focused window,
Super-p                       | Pins the focused window so that it is always on top of all others.
Super-Shift-l                 | Disable screensaver for 90 minutes (think presentation).
Super-Shift-k                 | Launch "xkill" program to **really, really kill** a frozen window/application.
Printscreen                   | Make a **screenshot** (duh) using "xwd", saved as a PNG in the homedir.
Super--/= (Minus/Equal)       | Resizes the master tile size (I usually used the mouse).
Super-Shift--/= (Minus/Equal) | Add/Remove tile compartments to the master view.

# FAQ

I have no windows key! or: How to use CapsLock for something useful!
 - Well, neither does some of my older keyboards
 - run "setxkmap -option caps:super" makes CapsLock another Super key.
 - Please google how to make this permanent.
 
Why is the focus color **red**?
 - because red+black is a cool color combination.
 - because red is the color of attention.
 - because I don't need to present a **blue**, cool, confident corporate image.

What is the wallpaper?
 - The config choses a random wallpaper from the config directory, you can add your own.
 - The two example wallpapers are photos I made.

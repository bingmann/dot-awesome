------------------------------
-- Customized awesome theme --
------------------------------

theme = {}

config              = require("awful.util").getdir("config")
themedir            = config .. "/theme/"

theme.font          = "Terminus 8"

theme.bg_normal     = "#00000000"
theme.bg_focus      = "#31040480"
theme.bg_urgent     = "#ff0000"
theme.bg_minimize   = "#44444480"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#e0e0e0"
theme.fg_focus      = "#ff1010"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.border_width  = 1
theme.border_normal = "#303030"
theme.border_focus  = "#b40404"
theme.border_marked = "#91231c"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Display the taglist squares
theme.taglist_squares_unsel = themedir .. "/taglist/square4.png"
theme.taglist_squares_sel   = themedir .. "/taglist/square4f.png"

theme.tasklist_floating_icon = themedir .. "/taglist/floating-ghost.png"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = themedir .. "/submenu.png"
theme.menu_height = 20
theme.menu_width  = 100

theme.menu_bg_normal = "#000000"
theme.menu_bg_focus = "#310404"

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
titlebardir = themedir .. "/titlebar/simple/"
theme.titlebar_close_button_normal = titlebardir .. "/close_normal.png"
theme.titlebar_close_button_focus  = titlebardir .. "/close_focus.png"

theme.titlebar_ontop_button_normal_inactive = titlebardir .. "/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = titlebardir .. "/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = titlebardir .. "/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = titlebardir .. "/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = titlebardir .. "/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = titlebardir .. "/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = titlebardir .. "/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = titlebardir .. "/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = titlebardir .. "/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = titlebardir .. "/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = titlebardir .. "/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = titlebardir .. "/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = titlebardir .. "/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = titlebardir .. "/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = titlebardir .. "/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = titlebardir .. "/maximized_focus_active.png"

theme.wallpaper = "/home/tb/Dropbox/0-Dokumente/wallpaper/desktop/colorwheel2560.jpg"

-- You can use your own layout icons like this:
layoutdir = themedir .. "/layouts/red-transparent/"
theme.layout_fairh = layoutdir .. "/fairh.png"
theme.layout_fairv = layoutdir .. "/fairv.png"
theme.layout_floating  = layoutdir .. "/floating.png"
theme.layout_magnifier = layoutdir .. "/magnifier.png"
theme.layout_max = layoutdir .. "/max.png"
theme.layout_fullscreen = layoutdir .. "/fullscreen.png"
theme.layout_tilebottom = layoutdir .. "/tilebottom.png"
theme.layout_tileleft   = layoutdir .. "/tileleft.png"
theme.layout_tile = layoutdir .. "/tile.png"
theme.layout_tiletop = layoutdir .. "/tiletop.png"
theme.layout_spiral  = layoutdir .. "/spiral.png"
theme.layout_dwindle = layoutdir .. "/dwindle.png"

theme.awesome_icon = themedir .. "/awesome16t.png"

-- Define the icon theme for application icons. If not set then the icons 
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80

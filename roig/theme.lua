-- roig, awesome3 theme

--{{{ Main
require("awful.util")

theme = {}

home          = os.getenv("HOME")
config        = awful.util.getdir("config")
shared        = "/usr/share/awesome"
sharedicons   = shared .. "/icons"
sharedthemes  = shared .. "/themes"

themes        = config .. "/themes"
themename     = "/roig"
if not awful.util.file_readable(themes .. themename .. "/theme.lua") then
   themes = sharedthemes
end
themedir      = config .. "/roig"

wallpaper1    = home .. "/Dropbox/Dokumente/Wallpaper/tflXg.jpg"
wallpaper1    = home .. "/Dropbox/Dokumente/Wallpaper/upsct.jpg"
wallpaper1    = home .. "/Dropbox/0-Dokumente/wallpaper/colorwheel2560.jpg"
wallpaper1    = home .. "/Dropbox/0-Dokumente/wallpaper/thumb-1766844.png"
wallpaper2    = themedir .. "/background.jpg"

if awful.util.file_readable(wallpaper1) then
   theme.wallpaper_cmd = { "awsetbg -a " .. wallpaper1 }
else
   theme.wallpaper_cmd = { "awsetbg -a " .. wallpaper2 }
end
--}}}

theme.font          = "Terminus 9"

theme.bg_normal     = "#00000000"
theme.bg_focus      = "#31040480"
theme.bg_urgent     = "#ff0000"
theme.bg_minimize   = "#444444"

theme.fg_normal     = "#eeeeee"
theme.fg_focus      = "#ff1212"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.border_width  = "1"
theme.border_normal = "#303030"
theme.border_focus  = "#B40404"
theme.border_marked = "#91231c"

theme.bg_menu_normal = "#000000"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Display the taglist squares
theme.taglist_squares_sel   = themedir .. "/taglist/squarefw.png"
theme.taglist_squares_unsel = themedir .. "/taglist/squarew.png"

theme.tasklist_floating_icon = themedir .. "/tasklist/floatingw.png"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = themedir .. "/submenu.png"
theme.menu_height = "20"
theme.menu_width  = "100"

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- {{{ Widgets
theme.bg_widget        = "#080808"

theme.fg_widget        = "#A0CF7C"
theme.fg_center_widget = "#88A175"
theme.fg_end_widget    = "#FF4646"
theme.fg_off_widget    = "#191B1F"

theme.border_widget    = theme.bg_normal

theme.fg_widget_netup  = "#FF5F5F"
theme.fg_widget_netdn  = "#5F5FFF"

theme.fg_widget_value  = theme.fg_normal
theme.fg_widget_label  = "#737d8c"
-- }}}

-- Define the image to load
theme.titlebar_close_button_normal = themedir .. "/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = themedir .. "/titlebar/close_focus.png"

theme.titlebar_ontop_button_normal_inactive = themedir .. "/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = themedir .. "/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = themedir .. "/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = themedir .. "/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = themedir .. "/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = themedir .. "/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = themedir .. "/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = themedir .. "/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = themedir .. "/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = themedir .. "/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = themedir .. "/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = themedir .. "/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = themedir .. "/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = themedir .. "/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = themedir .. "/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = themedir .. "/titlebar/maximized_focus_active.png"

-- You can use your own layout icons like this:
theme.layout_fairh = themedir .. "/layouts/rt/fairh.png"
theme.layout_fairv = themedir .. "/layouts/rt/fairv.png"
theme.layout_floating  = themedir .. "/layouts/rt/floating.png"
theme.layout_magnifier = themedir .. "/layouts/rt/magnifier.png"
theme.layout_max = themedir .. "/layouts/rt/max.png"
theme.layout_fullscreen = themedir .. "/layouts/rt/fullscreen.png"
theme.layout_tilebottom = themedir .. "/layouts/rt/tilebottom.png"
theme.layout_tileleft   = themedir .. "/layouts/rt/tileleft.png"
theme.layout_tile = themedir .. "/layouts/rt/tile.png"
theme.layout_tiletop = themedir .. "/layouts/rt/tiletop.png"
theme.layout_spiral  = themedir .. "/layouts/rt/spiral.png"
theme.layout_dwindle = themedir .. "/layouts/rt/dwindle.png"

theme.awesome_icon = themedir .. "/awesome16t.png"

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80

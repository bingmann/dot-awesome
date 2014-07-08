-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
-- Vicious monitoring library
local vicious = require("vicious")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(os.getenv("HOME") .. "/.config/awesome/theme/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey = "Mod4"
local altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.tile,
    --awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier,
    awful.layout.suit.floating,
}
-- }}}

-- {{{ Wallpaper
function scanDir(directory)
    local fileList, popen = {}, io.popen
    for filename in popen([[find "]] ..directory.. [[" -type f]]):lines() do
        fileList[#fileList+1] = filename
    end
    return fileList
end

function random_wallpaper()
    wp_path = os.getenv("HOME") .. "/sync/0-Dokumente/wallpaper/desktop/"
    wp_list = scanDir(wp_path)
    if #wp_list == 0 then return end
    for s = 1, screen.count() do
        gears.wallpaper.fill(wp_list[math.random(1, #wp_list)], s)
    end
end
-- inital setting of random wallpapers
random_wallpaper()

-- setup the timer
wp_timeout = 30*60
wp_timer = timer { timeout = wp_timeout }
wp_timer:connect_signal("timeout",
    function()
        -- stop the timer (we don't need multiple instances running at the same time)
        --wp_timer:stop()

        -- randomize wallpaper
        random_wallpaper()

        --restart the timer
        --wp_timer.timeout = wp_timeout
        --wp_timer:start()
end)
-- initial start when rc.lua is first run
wp_timer:start()
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}
myshutdownmenu = {
   { "hibernate", "sudo /usr/sbin/hibernate" },
   { "halt", "sudo /sbin/shutdown -h now" },
   { "reboot", "sudo /sbin/shutdown -r now" },
   { "logout", awesome.quit }
}

mymainmenu = awful.menu({
    items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
              { "open terminal", terminal },
              { "shutdown", myshutdownmenu }
    }
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create separator of 2px
local separator = wibox.widget.textbox()
separator:set_markup(" ")

-- Create a textclock widget
local mytextclock = awful.widget.textclock(" %Y-%m-%d %H:%M ", 10)

-- {{{ CPU widget
local cpuicon = wibox.widget.imagebox(beautiful.widget_cpuicon)
-- initialize graph
local cpuwidget = awful.widget.graph({ width = 60 })
cpuwidget:set_background_color(beautiful.bg_widget)
cpuwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 0,10 },
                      stops = { {0, beautiful.fg_widget1}, {0.5, beautiful.fg_widget2}, {1, beautiful.fg_widget3} }})

local cpuwidget_tooltip = awful.tooltip({ objects = { cpuicon, cpuwidget } })
-- register vicious action
vicious.register(cpuwidget, vicious.widgets.cpu,
    function (widget, args)
        if cpuwidget_tooltip.visible then
            cpuwidget_tooltip:set_markup("CPU Usage: " .. args[1] .. "%")
        end
        return args[1]
end)
-- initialize frequency change menu
mycpufreqmenu = awful.menu(
    {
        theme = { width = 160 },
        items = {
            { "ondemand 2.4 GHz", "sudo /usr/bin/cpupower frequency-set -g ondemand --min 800000 --max 2400000" },
            { "ondemand 1.4 GHz", "sudo /usr/bin/cpupower frequency-set -g ondemand --min 800000 --max 1400000" },
            { "conservative 2.4 GHz", "sudo /usr/bin/cpupower frequency-set -g conservative --min 800000 --max 2400000" },
            { "conservative 1.4 GHz", "sudo /usr/bin/cpupower frequency-set -g conservative --min 800000 --max 1400000" },
            { "const 1.4 GHz", "sudo /usr/bin/cpupower frequency-set -g ondemand --min 1400000 --max 1400000" },
            { "powersave 0.8 GHz", "sudo /usr/bin/cpupower frequency-set -g powersave --min 800000 --max 800000" }
        }
})

-- initialize frequency text
local cpufreq = wibox.widget.textbox()
vicious.register(cpufreq, vicious.widgets.cpufreq,
                 function (widget, args)
                     return "<span color='#e00000'>" .. string.format("%.1f", args[2]) .. " GHz</span>"
                 end, 2, "cpu0")

cpufreq:buttons(awful.util.table.join(
                    awful.button({ }, 1, function () mycpufreqmenu:toggle() end)
))

vicious.cache(vicious.widgets.cpufreq)
-- initialize temperature text
local cputemp = wibox.widget.textbox()
vicious.register(cputemp, vicious.widgets.thermal, "<span color='#e00000'>$1&#176;C</span>", 5, { "coretemp.0", "core" })
vicious.cache(vicious.widgets.thermal)
-- }}} CPU widget

-- {{{ Network widget
local neticon = wibox.widget.imagebox(beautiful.widget_dishicon)
-- Initialize widgets
local netwidget = awful.widget.graph({ width = 60 })
netwidget:set_background_color(beautiful.bg_widget)
netwidget:set_stack(true):set_scale(true)
netwidget:set_stack_colors({ beautiful.fg_widget_netup, beautiful.fg_widget_netdn })
local netwidget_tooltip = awful.tooltip({ objects = { neticon, netwidget } })
-- register vicious action
vicious.register(neticon, vicious.widgets.net,
    function (widget, args)
        -- We sum up/down value for all interfaces
        local up, down = 0, 0
        local iface
        for name, value in pairs(args) do
            iface = name:match("^{(%S+) down_b}$")
            if iface and iface ~= "lo" then down = down + value end
            iface = name:match("^{(%S+) up_b}$")
            if iface and iface ~= "lo" then up = up + value end
        end
        -- Update the graph
        netwidget:add_value(up, 1)
        netwidget:add_value(down, 2)
        -- Format the string representation
        if netwidget_tooltip.visible then
            local format = function(val)
                if val > 900000 then
                    return string.format("%.1f MiB", val/1048576.)
                elseif val > 900 then
                    return string.format("%.1f KiB", val/1024.)
                end
                return string.format("%d B", val)
            end
            local ft = function (color) return '<span font="Terminus 8" color="' .. color .. '">' end
            netwidget_tooltip:set_markup(
                string.format(
                    ft(beautiful.fg_widget_netup) .. 'Up</span>' ..
                        ft(beautiful.fg_widget_netlabel) .. '/</span>' ..
                        ft(beautiful.fg_widget_netdn) .. 'Down</span>' ..
                        ft(beautiful.fg_widget_netlabel) .. ':</span> ' ..
                        ft(beautiful.fg_widget_netup) .. '%08s</span>' ..
                        ft(beautiful.fg_widget_netlabel) .. '/</span>' ..
                        ft(beautiful.fg_widget_netdn) .. '%08s</span>', format(up), format(down)))
        end
end)
-- }}} Network widget

-- {{{ Battery widget
local baticon = wibox.widget.imagebox(beautiful.widget_baticon)
-- initialize battery text
local battext = wibox.widget.textbox()
local bat_tooltip = awful.tooltip({ objects = { baticon, battext } })
function process_battext(widget, args)
    --if bat_tooltip.visible then
        bat_tooltip:set_markup("Time remaining: " .. args[3] .. ", wear " .. args[4])
    --end
    return "<span color='#e00000'>" .. args[1] .. args[2] .. "%</span>"
end
vicious.register(battext, vicious.widgets.bat, process_battext, 10, "BAT1")
vicious.cache(vicious.widgets.bat)
-- }}} Battery widget

-- {{{ Volume widget
local volicon = wibox.widget.imagebox(beautiful.widget_spkricon)
-- initialize progressbar
local volwidget = awful.widget.progressbar()
volwidget:set_vertical(true):set_ticks(true)
volwidget:set_width(6)
volwidget:set_ticks_size(100)
volwidget:set_background_color("#000000")
volwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 0,10 },
                      stops = { {0, beautiful.fg_widget1}, {0.5, beautiful.fg_widget2}, {1, beautiful.fg_widget3} }})
-- enable caching
vicious.cache(vicious.widgets.volume)
-- register vicious action
vicious.register(volwidget, vicious.widgets.volume, "$1", 2, "PCM")
-- functions, also for Fn-keys
function volumeRaise()
    awful.util.spawn("amixer -q set PCM 2dB+ unmute", false)
    vicious.force({volwidget})
end
function volumeLower()
    awful.util.spawn("amixer -q set PCM 2dB-", false)
    vicious.force({volwidget})
end
function volumeToggleMute()
    awful.util.spawn("amixer -q set PCM toggle", false)
    vicious.force({volwidget})
end
-- Register buttons
volicon:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("xfce4-mixer") end),
    awful.button({ }, 4, volumeRaise),
    awful.button({ }, 5, volumeLower)
))
-- Register assigned buttons
volwidget:buttons(volicon:buttons())
-- }}} Volume widget

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 2, function (c) c:kill() end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end)
                           --awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           --awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
                          ))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    --left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(mylayoutbox[s])
    if s == screen.count() then
        right_layout:add(cpuicon)
        right_layout:add(cpuwidget)
        right_layout:add(separator)
        right_layout:add(cpufreq)
        right_layout:add(separator)
        right_layout:add(cputemp)
        right_layout:add(separator)
        right_layout:add(neticon)
        right_layout:add(netwidget)
        right_layout:add(separator)
        right_layout:add(baticon)
        right_layout:add(battext)
        right_layout:add(separator)
        right_layout:add(volicon)
        right_layout:add(volwidget)
        right_layout:add(separator)
        right_layout:add(wibox.widget.systray())
        right_layout:add(mytextclock)
    end

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
rootbuttons = awful.util.table.join(
    awful.button({ }, 1, function () mymainmenu:hide(); mycpufreqmenu:hide() end),
    awful.button({ }, 3, function () mymainmenu:toggle() end)
    -- Mouse wheel up/down on root window
    --awful.button({ }, 4, awful.tag.viewnext),
    --awful.button({ }, 5, awful.tag.viewprev)
)
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Switch between tags on same screen
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext),

    -- Switch back to last tag
    --awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    -- Move focus within a tag
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    awful.key({ modkey,           }, "Down",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "Up",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    --awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),

    awful.key({ modkey, "Shift"   }, "Down", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "Up",   function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "Down", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "Up",   function () awful.screen.focus_relative(-1) end),

    awful.key({ modkey,           }, "u",    awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",  function () awful.screen.focus_relative( 1) end),

    -- Standard program
    awful.key({ modkey, "Control" }, "r",     awesome.restart),
    awful.key({ modkey, "Control" }, "e",     awesome.quit),

    awful.key({ modkey, "Control" }, "w",     random_wallpaper),

    awful.key({ modkey,           }, "-",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "=",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "=",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "-",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "=",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "-",     function () awful.tag.incncol(-1)         end),

    -- Switch layout algorithm
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompts
    awful.key({ modkey },            "s",     function () menubar.show() end),
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),

    -- Program Launchers
    awful.key({ modkey },            "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey },            "\\",     function () awful.util.spawn("gnome-terminal") end),
    awful.key({ modkey },            "w",     function () awful.util.spawn("firefox") end),
    awful.key({ modkey },            "f",     function () awful.util.spawn("thunar") end),
    awful.key({ modkey },            "e",     function () awful.util.spawn("emacsclient -nc --alternate-editor emacs ~/sync/0-Work/TODO.org") end),

    awful.key({ altkey, "Control", "Shift" }, "Return", function () awful.util.spawn(terminal) end), -- alternative terminal hotkey

    awful.key({ modkey, "Shift" },   "k",     function () awful.util.spawn("xkill") end),

    -- Screensaver Super-l or Ctrl+Alt+Del
    --awful.key({ "Control", altkey }, "Delete", function () awful.util.spawn("xscreensaver-command -lock") end),
    awful.key({ modkey },            "l",      function () awful.util.spawn("xscreensaver-command -lock") end),
    awful.key({ },                   "Pause",  function () awful.util.spawn("xscreensaver-command -lock") end),
    awful.key({ modkey, "Shift" },   "l",
              function ()
                  -- disable screensaver
                  awful.util.spawn("xset s 7200 dpms 7200 7200 7200 -dpms")
                  naughty.notify({ text = "screensaver disabled for 90 minutes" })

                  -- set up timer
                  ss_timer = timer{ timeout = 30 }
                  ss_countdown = 90*2
                  ss_timer:connect_signal("timeout",
                                          function()
                                              ss_countdown = ss_countdown - 1
                                              if ss_countdown == 0 then
                                                  -- enable screensaver
                                                  awful.util.spawn("xset s on s 300 360 +dpms dpms 420 600 600")
                                                  naughty.notify({ text = "screensaver enabled" })
                                                  ss_timer:stop()
                                              else
                                                  -- touch xscreensaver idle time
                                                  awful.util.spawn("xscreensaver-command --deactivate")
                                              end
                  end)
                  ss_timer:start()
    end),

    -- Hibernate
    awful.key({ modkey },            "h",
              function ()
                  awful.util.spawn("xscreensaver-command -lock")
                  awful.util.spawn("sudo /usr/sbin/pm-hibernate")
              end),

    -- Hibernate Control on ACPI lid close
    awful.key({ modkey, "Shift" },   "h",
              function ()
                  -- disable screensaver
                  awful.util.spawn("touch /tmp/hibernation.lock")
                  naughty.notify({ text = "automatic hibernation disabled for 60 minutes" })

                  -- set up timer
                  hib_timer = timer{ timeout = 60*60 }
                  hib_timer:connect_signal("timeout",
                                           function()
                                               awful.util.spawn("rm -f /tmp/hibernation.lock")
                                               naughty.notify({ text = "automatic hibernation renabled" })
                  end)
                  hib_timer:start()
    end),

    -- Keybindings for quickly making screenshots
    awful.key({ },                   "Print", function () awful.util.spawn("bash -c \"xwd -root | convert - ~/screenshot-$(date +%s).png\"") end),
    awful.key({ "Shift" },           "Print", function () awful.util.spawn("bash -c \"xwd -frame | convert - ~/screenshot-$(date +%s).png\"") end),
    awful.key({ "Control" },         "Print", function () awful.util.spawn("bash -c \"xwd | convert - ~/screenshot-$(date +%s).png\"") end),

    -- Keybindings for Notebook Fn-Keys
    awful.key({ }, "XF86AudioMute",           volumeToggleMute),
    awful.key({ }, "XF86AudioRaiseVolume",    volumeRaise),
    awful.key({ }, "XF86AudioLowerVolume",    volumeLower),
    awful.key({ }, "XF86MonBrightnessUp",     function () awful.util.spawn("/usr/bin/xbacklight -inc 15 -time 0") end),
    awful.key({ }, "XF86MonBrightnessDown",   function () awful.util.spawn("/usr/bin/xbacklight -dec 15 -time 0") end),
    awful.key({ }, "XF86Display",             function () awful.util.spawn("/usr/bin/autorandr -c") end),

    awful.key({ }, "XF86Launch1",             function () awful.util.spawn("/usr/bin/arandr") end),
    awful.key({ }, "XF86Launch3",             function () awful.util.spawn("sudo /root/samctl.sh perf") end),
    awful.key({ }, "XF86KbdBrightnessUp",     function () awful.util.spawn("sudo /root/samctl.sh kbdled inc") end),
    awful.key({ }, "XF86KbdBrightnessDown",   function () awful.util.spawn("sudo /root/samctl.sh kbdled dec") end),
    awful.key({ }, "XF86WLAN",                function () awful.util.spawn("sudo /root/samctl.sh wlan") end)
)

globalbuttons = awful.util.table.join(
    -- Switch between tags on same screen
    awful.button({ modkey         }, 4,        awful.tag.viewnext),
    awful.button({ modkey         }, 5,        awful.tag.viewprev),
    awful.button({ modkey         }, 7,        awful.tag.viewnext),
    awful.button({ modkey         }, 6,        awful.tag.viewprev)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "`",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end),
    awful.key({ modkey,           }, "z",      awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "a",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "p",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 10 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise(); mymainmenu:hide(); mycpufreqmenu:hide() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize),
    -- Super, Shift + Touchscreen -> resize
    awful.button({ modkey, "Shift" }, 1, awful.mouse.client.resize)
)

-- Set keys
root.keys(globalkeys)
root.buttons(rootbuttons)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp-2.8" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
    { rule = { class = "Thunar", name = "File Operation Progress" },
      properties = { floating = true },
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)

    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

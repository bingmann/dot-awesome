-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- Vicious monitoring library
local vicious = require("vicious")

-- startup (on each reconfig)
--awful.spawn("xautolock -time 10 -locker 'xtrlock -b' -notify 300 -notifier 'xset dpms force standby' -corners '----' -cornersize 16 -cornerdelay 7200")
awful.spawn("xautolock -time 5 -locker 'i3lock -t -i /home/tb/Dropbox/0-Dokumente/wallpaper/desktop/windows_10_wannacry.png -p win' -notify 300 -notifier 'xset dpms force standby' -corners '++++' -cornersize 16 -cornerdelay 7200")

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
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(os.getenv("HOME") .. "/.config/awesome/theme/theme.lua")

-- }}}

--------------------------------------------------------------------------------

-- {{{ Random Wallpaper Selector
function scanDir(directory)
    local fileList, popen = {}, io.popen
    for filename in popen([[find "]] ..directory.. [[" -type f]]):lines() do
        fileList[#fileList+1] = filename
    end
    return fileList
end

math.randomseed(os.time())
beautiful.wallpaper = function(s)
    wp_path = os.getenv("HOME") .. "/.config/awesome/wallpaper/"
    wp_list = scanDir(wp_path)
    if #wp_list == 0 then return end
    return wp_list[math.random(1, #wp_list)]
end

-- setup the timer
wp_timer = gears.timer {
    timeout = 30*60,
    autostart = true,
    callback = function()
         -- randomize wallpaper
        for s in screen do
            set_wallpaper(s)
        end
    end
}
-- }}}

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
awful.layout.layouts = {
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
    --awful.layout.suit.corner.nw,
    awful.layout.suit.floating,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end}
}
myshutdownmenu = {
   { "hibernate", "sudo /usr/sbin/hibernate" },
   { "halt", "sudo /sbin/shutdown -h now" },
   { "reboot", "sudo /sbin/shutdown -r now" },
   { "logout", awesome.quit }
}

mymainmenu = awful.menu({
        items = {
            { "awesome", myawesomemenu, beautiful.awesome_icon },
            { "open terminal", terminal },
            { "shutdown", myshutdownmenu }
        }
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar

-- Create separator of 2px
local separator = wibox.widget.textbox()
separator:set_markup(" ")

-- {{{ CPU widget
local cpuicon = wibox.widget.imagebox(beautiful.widget_cpuicon)
-- initialize graph
local cpuwidget = wibox.widget.graph({ width = 60 })
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
            { "ondemand 1.8 GHz", "sudo /usr/bin/cpupower frequency-set -g ondemand --min 800000 --max 1800000" },
            { "ondemand 1.4 GHz", "sudo /usr/bin/cpupower frequency-set -g ondemand --min 800000 --max 1400000" },
            { "conservative 2.4 GHz", "sudo /usr/bin/cpupower frequency-set -g conservative --min 800000 --max 2400000" },
            { "conservative 2.0 GHz", "sudo /usr/bin/cpupower frequency-set -g conservative --min 800000 --max 2000000" },
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
vicious.register(cputemp, vicious.widgets.thermal, "<span color='#e00000'>$1&#176;C</span>", 5, { "coretemp.0/hwmon/hwmon1", "core" })
vicious.cache(vicious.widgets.thermal)
-- }}} CPU widget

-- {{{ Network widget
local neticon = wibox.widget.imagebox(beautiful.widget_dishicon)
-- Initialize widgets
local netwidget = wibox.widget.graph({ width = 60 })
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
local volwidget_box = wibox.widget {
    {
        background_color = "#000000",
        color = {
            type = "linear", from = { 0, 0 }, to = { 10,0 },
            stops = { {0, beautiful.fg_widget1}, {0.5, beautiful.fg_widget2}, {1, beautiful.fg_widget3} }
        },
        widget = wibox.widget.progressbar
    },
    forced_width = 6,
    direction = 'east',
    layout = wibox.container.rotate,
}
local volwidget = volwidget_box.widget
-- enable caching
vicious.cache(vicious.widgets.volume)
-- register vicious action
--vicious.register(volwidget, vicious.widgets.volume, "$1", 2, "PCM")
-- functions, also for Fn-keys
function volumeRaise()
    --awful.spawn("amixer -q set PCM 2dB+ unmute", false)
    awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +2%", false)
    vicious.force({volwidget})
end
function volumeLower()
    --awful.spawn("amixer -q set PCM 2dB-", false)
    awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -2%", false)
    vicious.force({volwidget})
end
function volumeToggleMute()
    awful.spawn("amixer -q set PCM toggle", false)
    vicious.force({volwidget})
end
-- Register buttons
volicon:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.spawn("pavucontrol") end),
    awful.button({ }, 4, volumeRaise),
    awful.button({ }, 5, volumeLower)
))
-- Register assigned buttons
volwidget:buttons(volicon:buttons())
-- }}} Volume widget




-- Create a textclock widget
local mytextclock = wibox.widget.textclock(" %Y-%m-%d %H:%M ", 10)

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 2, function (c) c:kill() end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.fill(wallpaper, s)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            s.mylayoutbox,
            cpuicon, cpuwidget, separator,
            cpufreq, separator,
            cputemp, separator,
            neticon, netwidget, separator,
            baticon, battext, separator,
            volicon, volwidget_box, separator,
            wibox.widget.systray(),
            mytextclock,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
    -- Mouse wheel up/down on root window
    --awful.button({ }, 4, awful.tag.viewnext),
    --awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey, "Shift"   }, "/",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "Down",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "Up",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    --awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
    --          {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "Down", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "Up",   function () awful.client.swap.byidx( -1)    end,
        {description = "swap with previous client by index", group = "client"}),

    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),

    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
        {description = "open a terminal", group = "launcher"}),
    awful.key({ altkey, "Control", "Shift" }, "Return", function () awful.spawn(terminal) end,
        {description = "open a terminal (other binding)", group = "launcher"}),

    awful.key({ modkey, "Control" }, "r", awesome.restart,
        {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
        {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "w", function () awful.spawn("google-chrome-stable") end,
        {description = "launch web browser", group = "launcher"}),
    awful.key({ modkey,           }, "f", function () awful.spawn("pcmanfm") end,
        {description = "launch file manager", group = "launcher"}),
    awful.key({ modkey,           }, "e", function () awful.spawn(editor) end,
        {description = "launch editor (emacs)", group = "launcher"}),
    awful.key({ modkey,           }, "\\", function () awful.spawn("mate-terminal") end,
        {description = "launch other terminal (mate-terminal)", group = "launcher"}),
    awful.key({ modkey, "Shift"   }, "a", function () awful.spawn("autorandr -c") end,
        {description = "launch autorandr", group = "launcher"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.spawn("xkill") end,
        {description = "launch xkill", group = "launcher"}),

    -- Screensaver Super-l or Pause
    awful.key({ modkey },            "z",      function () awful.util.spawn("xautolock -locknow") end),
    awful.key({ },                   "Pause",  function () awful.util.spawn("xautolock -locknow") end),

    -- Launcher: Suspend
    awful.key({ modkey },            "y",
              function ()
                  awful.spawn("xautolock -locknow")
                  awful.spawn("systemctl suspend")
              end),
    awful.key({ "Control" },         "Pause",
              function ()
                  awful.spawn("xautolock -locknow")
                  awful.spawn("systemctl suspend")
    end),

    -- Launcher: Hibernate
    awful.key({ modkey },            "h",
              function ()
                  awful.spawn("xautolock -locknow")
                  awful.spawn("systemctl hibernate")
    end),

    -- Disable Screensaver
    awful.key({ modkey, "Shift" }, "y",
        function ()
            awful.spawn("xautolock -disable")
            naughty.notify({
                    title = "Autolock!",
                    text = "Disabled xautolock for 60minutes..."
            })

            gears.timer {
                timeout = 60,
                autostart = true,
                callback = function()
                    awful.spawn("xautolock -enable")
                    self:stop()
                    naughty.notify({
                            title = "Autolock!",
                            text = "Re-enabled xautolock..."
                    })
            end}
    end),

    -- Keybindings for quickly making screenshots
    awful.key({ },                   "Print", function () awful.spawn("bash -c \"xwd -root | convert xwd:- ~/screenshot-$(date +%s).png\"") end),
    awful.key({ "Shift" },           "Print", function () awful.spawn("bash -c \"xwd -frame | convert xwd:- ~/screenshot-$(date +%s).png\"") end),
    awful.key({ "Control" },         "Print", function () awful.spawn("bash -c \"xwd | convert xwd:- ~/screenshot-$(date +%s).png\"") end),

    -- Keybindings for Notebook Fn-Keys
    awful.key({ }, "XF86AudioMute",           volumeToggleMute),
    awful.key({ }, "XF86AudioRaiseVolume",    volumeRaise),
    awful.key({ }, "XF86AudioLowerVolume",    volumeLower),
    awful.key({ }, "XF86MonBrightnessUp",     function () awful.spawn("/usr/bin/xbacklight -inc 15 -time 0") end),
    awful.key({ }, "XF86MonBrightnessDown",   function () awful.spawn("/usr/bin/xbacklight -dec 15 -time 0") end),
    awful.key({ }, "XF86Display",             function () awful.spawn("/usr/bin/autorandr -c") end),

    awful.key({ }, "XF86Launch1",             function () awful.spawn("/usr/bin/arandr") end),
    awful.key({ }, "XF86Launch3",             function () awful.spawn("sudo /root/samctl.sh perf") end),
    awful.key({ }, "XF86KbdBrightnessUp",     function () awful.spawn("sudo /root/samctl.sh kbdled inc") end),
    awful.key({ }, "XF86KbdBrightnessDown",   function () awful.spawn("sudo /root/samctl.sh kbdled dec") end),
    awful.key({ }, "XF86WLAN",                function () awful.spawn("sudo /root/samctl.sh wlan") end),

    -- Layout manipulation
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
        {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
        {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey            }, "-",     function () awful.tag.incnmaster( 1, nil, true) end,
        {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey            }, "=",     function () awful.tag.incnmaster(-1, nil, true) end,
        {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
        {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
        {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
        {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
        {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "s", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "`",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "a",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 10 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize),
    -- Super, Shift + Touchscreen -> resize
    awful.button({ modkey, "Shift" }, 1, awful.mouse.client.resize)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer"},
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
    }, properties = { floating = true }},

    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "ffplay" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp-2.8" },
      properties = { floating = true } },
    { rule = { class = "Thunar", name = "File Operation Progress" },
      properties = { floating = true },
    },

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
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

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

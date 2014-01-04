-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")

-- Theme handling library
require("beautiful")

-- Notification library
require("naughty")

-- User libraries
vicious = require("vicious")

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
    awesome.add_signal("debug::error", function (err)
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
beautiful.init(os.getenv("HOME") .. "/.config/awesome/roig/theme.lua")

-- This is used later as the default terminal and editor to run.
local terminal = "urxvt"
local editor = os.getenv("EDITOR") or "nano"
local editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
local modkey = "Mod4"
local altkey = "Mod1"

-- load menubar addon for Mod4-S
require("menubar")
menubar.cache_entries = true
menubar.app_folders = { "/usr/share/applications/", home .. "/.local/share/applications/" }
menubar.show_categories = true   -- Change to false if you want only programs to appear in the menu
menubar.set_icon_theme("gnome")

-- applications menu
require('freedesktop.utils')
freedesktop.utils.terminal = terminal
freedesktop.utils.icon_theme = 'gnome'
require('freedesktop.menu')

local exec   = awful.util.spawn
local sexec  = awful.util.spawn_with_shell

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
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
    --awful.layout.suit.magnifier
    awful.layout.suit.floating,
}
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
mymenulist = freedesktop.menu.new()
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}
myshutdownmenu = {
   { "hibernate", "sudo /usr/sbin/hibernate" },
   { "halt", "sudo /sbin/shutdown -h now" },
   { "reboot", "sudo /sbin/shutdown -r now" },
   { "logout", awesome.quit }
}
table.insert(mymenulist, 1, { "awesome", myawesomemenu, beautiful.awesome_icon })
table.insert(mymenulist, { "Tassen", "cryptote /home/bingmann/Dropbox/0-Work/Tassen/Tassen.ect", freedesktop.utils.lookup_icon({icon = 'cryptote'}) })
table.insert(mymenulist, { "Terminal", terminal, freedesktop.utils.lookup_icon({icon = 'terminal'}) })
table.insert(mymenulist, { "Shutdown", myshutdownmenu, freedesktop.utils.lookup_icon({icon = 'exit'}) })

mymainmenu = awful.menu.new({ items = mymenulist, width = 150, bg_normal = beautiful.bg_menu_normal })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox

-- Create a textclock widget: format and update interval
local mytextclock = awful.widget.textclock({}, "%Y-%m-%d %H:%M", 10)

-- Create a systray
local mysystray = widget({ type = "systray" })

-- Separator of 2px
local separator = widget({ type = "textbox", bg = theme.bg_normal })
separator.width = 2

-- {{{ CPU widget
local cpuwidget = awful.widget.graph({ width = 60 })
cpuwidget:set_background_color(beautiful.bg_widget)
cpuwidget:set_color("#FF5656")
cpuwidget:set_gradient_colors({ beautiful.fg_end_widget, beautiful.fg_center_widget, beautiful.fg_widget })
cpuwidget:set_gradient_angle(0);
local cpuwidget_tooltip = awful.tooltip({ objects = { cpuwidget.widget } })
-- Register CPU widget
vicious.register(cpuwidget, vicious.widgets.cpu, 
                 function (widget, args)
                    cpuwidget_tooltip:set_text("CPU Usage: " .. args[1] .. "%")
                    return args[1]
                 end)
-- }}} CPU widget

-- {{{ Volume widget
local volicon = widget({ type = "imagebox" })
volicon.image = image(config .. "/roig/icons/vol.png")
-- Initialize widgets
local volbar = awful.widget.progressbar()
-- Progressbar properties
volbar:set_vertical(true):set_ticks(true)
volbar:set_width(8):set_ticks_size(2)
volbar:set_background_color(beautiful.bg_widget)
volbar:set_gradient_colors({ beautiful.fg_widget, beautiful.fg_center_widget, beautiful.fg_end_widget })
-- Enable caching
vicious.cache(vicious.widgets.volume)
-- Register widgets
vicious.register(volbar, vicious.widgets.volume, "$1", 2, "PCM")
-- Register buttons
volicon:buttons(awful.util.table.join(
   awful.button({ }, 1, function () exec("xfce4-mixer") end),
   awful.button({ }, 4, function () exec("amixer -q set PCM 2dB+", false) vicious.force({volbar}) end),
   awful.button({ }, 5, function () exec("amixer -q set PCM 2dB-", false) vicious.force({volbar}) end)
))
-- Register assigned buttons
volbar.widget:buttons(volicon:buttons())
-- }}} Volume widget

-- {{{ Network widget
local netwidget = awful.widget.graph({ width = 60 })
netwidget:set_background_color(beautiful.bg_widget)
netwidget:set_stack(true):set_scale(true)
netwidget:set_stack_colors({ beautiful.fg_widget_netup, beautiful.fg_widget_netdn })
local netwidget_tooltip = awful.tooltip({ objects = { netwidget.widget } })
-- Register Network widget
vicious.register(netwidget.widget, vicious.widgets.net,
    function (widget, args)
       -- We sum up/down value for all interfaces
       local up = 0
       local down = 0
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
       local format = function(val)
                         if val > 900000 then
                            return string.format("%.1f MB", val/1000000.)
                         elseif val > 900 then
                            return string.format("%.1f KB", val/1000.)
                         end
                         return string.format("%d B", val)
                      end
       local ft = function (color) return '<span font="Terminus 8" color="' .. color .. '">' end
       netwidget_tooltip:set_text(
          string.format(
             ft(beautiful.fg_widget_netup) .. 'Up</span>' ..
             ft(beautiful.fg_widget_label) .. '/</span>' ..
             ft(beautiful.fg_widget_netdn) .. 'Down</span>' ..
             ft(beautiful.fg_widget_label) .. ':</span> ' ..
             ft(beautiful.fg_widget_netup) .. '%08s</span>' ..
             ft(beautiful.fg_widget_label) .. '/</span>' ..
             ft(beautiful.fg_widget_netdn) .. '%08s</span>', format(up), format(down)))
    end)
-- }}} Network widget

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
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
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
                                                  -- TODO right-click on tasklist
                                                  --instance = awful.menu.clients({ width=250 })
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
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Add widgets to the wibox
    local on = function(n, what)
       if s == n or n > screen.count() then return what end
       return ""
    end

    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        --mylayoutbox[s], separator,
        on(2,mytextclock), on(2,separator),
        on(2,mysystray), on(2,separator),
        on(2,volbar.widget), on(2,volicon), on(2,separator),
	on(2,cpuwidget.widget), on(2,separator),
        on(2,netwidget.widget), on(2,separator),
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 1, function () mymainmenu:hide() end),
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    --awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "Up",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    awful.key({ modkey,           }, "Down",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),

    --awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    awful.key({ altkey,           }, "Tab",
        function ()
	    awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end    
        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "Up",    function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Shift"   }, "Down",  function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Control" }, "Up",    function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "Down",  function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u",     awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "-",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "=",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "=",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "-",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "=",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "-",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Run Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),
    --awful.key({ modkey },            "r",     function () menubar.show() end),

    awful.key({ modkey, "Shift" },   "r",     function () exec("dmenu_run -i -p 'Run:' -nf '#ffffff' -nb '#000000' -sf '#ff0000' -sb '#310404' -fn '-*-terminus-medium-r-*-*-*-120-*-*-*-*-*-*'") end),

    -- Program Launchers
    awful.key({ modkey },            "Return", function () exec(terminal) end),
    awful.key({ modkey },            "w",     function () exec("firefox") end),
    --awful.key({ modkey },            "w",     function () exec("chromium") end),
    awful.key({ modkey },            "f",     function () exec("thunar") end),
    awful.key({ modkey },            "e",     function () exec("emacsclient -nc --alternate-editor emacs ~/Dropbox/0-Work/TODO.org") end),

    awful.key({ modkey, "Control", "Shift" }, "Return", function () exec(terminal) end), -- alternative terminal hotkey

    awful.key({ modkey },            "Escape", function () exec("xkill") end),

    -- Screensaver
    awful.key({ "Control", altkey }, "Delete", function () exec("xscreensaver-command -lock") end),
    awful.key({ modkey },            "l",     function () exec("xscreensaver-command -lock") end),

    -- Keybindings for quickly making screenshots
    awful.key({ },                   "Print", function () exec("bash -c \"xwd -root | convert - ~/screenshot-$(date +%s).png\"") end),
    awful.key({ "Shift" },           "Print", function () exec("bash -c \"xwd -frame | convert - ~/screenshot-$(date +%s).png\"") end),
    awful.key({ "Control" },         "Print", function () exec("bash -c \"xwd | convert - ~/screenshot-$(date +%s).png\"") end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "`",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey            }, "q",      function (c) c:kill()                         end),
    awful.key({ altkey            }, "F4",     function (c) c:kill()                         end),
    awful.key({ modkey            }, "z",      awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "a",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
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

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(10, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise(); mymainmenu:hide() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
 )

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
   -- All clients will match this rule.
   { rule = { },
     properties = { border_width = beautiful.border_width,
                    border_color = beautiful.border_normal,
                    focus = true,
                    keys = clientkeys,
                    buttons = clientbuttons,
                    maximized_vertical = false,
                    maximized_horizontal = false,
                  } },
   { rule = { class = "MPlayer" },
     properties = { floating = true } },
   { rule = { class = "pinentry" },
     properties = { floating = true } },
   { rule = { class = "gimp" },
     properties = { floating = true } },
   -- Set Firefox to always map on tags number 2 of screen 1.
   -- { rule = { class = "Firefox" },
   --   properties = { tag = tags[1][2] } },
   { rule = { class = "Pidgin" },
     properties = { floating = true }
   },
   { rule = { class = "Pidgin", role = "buddy_list" },
     properties = { floating = true }
   },
   { rule = { class = "Pidgin", role = "conversation" },
     properties = { floating = true }
   },
   { rule = { class = "Thunar", name = "File Operation Progress" },
     properties = { floating = true },
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    --awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    --c:add_signal("mouse::enter", function(c)
    --    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
    --        and awful.client.focus.filter(c) then
    --        client.focus = c
    --    end
    --end)

    awful.placement.no_offscreen(c)

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
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

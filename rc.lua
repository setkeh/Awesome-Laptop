-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
require("awful.wibox")
require("awful.widget")
require("awful.widget.graph")
-- Widget and layout library
require("wibox")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Bash COnfiguration
--require("bashets")
-- Widget Library
local vicious = require("vicious")
require("vicious.helpers")
--Keybinding Library
local keydoc = require("keydoc")
-- Awesome MPD Library
require("awesompd/awesompd")
--FreeDesktop
require('freedesktop.utils')
require('freedesktop.menu')
freedesktop.utils.icon_theme = 'gnome'

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

-- This is used later as the default terminal and editor to run.
terminal = "urxvt -fg green -bg black"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
home_path  = os.getenv('HOME') .. '/'

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
local theme_path = home_path  .. '.config/awesome/themes/default/theme.lua'
beautiful.init(theme_path)

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
   names  = { 
      '☭:IRC',
      '⚡:Luakit', 
      '♨:Chrome', 
      '☠:Vim',  
      '☃:Vbox', 
      '⌥:Multimedia', 
      '⌘:Conky',
      '✇:IDE',
      '✣:Facepalm',
            },
   layout = {
      layouts[5],   -- 1:irc
      layouts[10],  -- 2:luakit
      layouts[10],  -- 3:chrome
      layouts[12],  -- 4:vim
      layouts[2],   -- 5:vbox
      layouts[10],  -- 6:multimedia
      layouts[10],  -- 7:conky
      layouts[2],   -- 8:ide
      layouts[10],  -- 9:facepalm
            }
        }

for s = 1, screen.count() do
   -- Each screen has its own tag table.
   tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- Wallpaper Changer Based On 
-- menu icon menu pdq 07-02-2012
local wallmenu = {}
local function wall_load(wall)
local f = io.popen('ln -sfn ' .. home_path .. '.config/awesome/wallpaper/' .. wall .. ' ' .. home_path .. '.config/awesome/themes/default/bg.png')
awesome.restart()
end
local function wall_menu()
local f = io.popen('ls -1 ' .. home_path .. '.config/awesome/wallpaper/')
for l in f:lines() do
local item = { l, function () wall_load(l) end }
table.insert(wallmenu, item)
end
f:close()
end
wall_menu()

-- {{{ Menu
-- Create a laucher widget and a main menu
menu_items = freedesktop.menu.new()
myawesomemenu = {
   { "manual", terminal .. " -e man awesome", freedesktop.utils.lookup_icon({ icon = 'help' }) },
   { "edit config", editor_cmd .. " " .. awesome.conffile, freedesktop.utils.lookup_icon({ icon = 'package_settings' }) },
   { "restart", awesome.restart, freedesktop.utils.lookup_icon({ icon = 'system-shutdown' }) },
   { "quit", awesome.quit, freedesktop.utils.lookup_icon({ icon = 'system-shutdown' }) }
}

myinternetmenu = {
   { "Chromium", "chromium" },
   { "Mumble", "mumble" },

}

mymediamenu = {
   { "Vlc", "vlc" },
   { "KdenLive", "kdenlive" },
   { "Pavucontrol", "pavucontrol" }
}

mytoolsmenu = {
   { "Virtualbox", "virtualbox" },
   { "GNS3", "gns3" },
   { "Eclipse", "eclipse" },
}

table.insert(menu_items, { "Awesome", myawesomemenu, beautiful.awesome_icon })

table.insert(menu_items, { "Wallpaper", wallmenu, freedesktop.utils.lookup_icon({ icon = 'gnome-settings-background' })}) 

mymainmenu = awful.menu({ items = menu_items, width = 150 })

mylauncher = awful.widget.launcher({ image = image(beautiful.arch_icon),
                                     menu = mymainmenu })
-- }}}

-- Bash Script Test Widgets

background_timers = {}                                                             
                                                                                  
function run_background(cmd,funtocall)                                             
local r = io.popen("mktemp")                                                   
local logfile = r:read("*line")                                                
r:close()                                                                      
                                                                                
cmdstr = cmd .. " &> " .. logfile .. " & "                                     
local cmdf = io.popen(cmdstr)                                                  
cmdf:close()                                                                   
background_timers[cmd] = {                                                     
file  = logfile,                                                           
timer = timer{timeout=1}                                                   
}                                                                              
background_timers[cmd].timer:add_signal("timeout",function()                   
local cmdf = io.popen("pgrep -f '" .. cmd .. "'")                          
local s = cmdf:read("*all")                                                
cmdf:close()                                                               
if (s=="") then                                                            
background_timers[cmd].timer:stop()                                    
local lf = io.open(background_timers[cmd].file)                        
funtocall(lf:read("*all"))                                             
lf:close()
io.popen("rm " .. background_timers[cmd].file)                                                            
end                                                                        
end)                                                                           
background_timers[cmd].timer:start()                                           
end

test = widget({ type = "textbox" })
run_background("ls -a | wc -l | tail",function(txt)
end)
test.txt = ("text=txt")


--Bashettes

--Pacman
pacman = widget({type="textbox"})
local t = timer({timeout = 280})
t:add_signal("timeout", function()
local f = io.popen("echo Pacman Updates: $(pacman -Qqu | wc -l | tail)", "r")
local s = f:read('*a')
f:close()
pacman.text = s
end)
t:emit_signal("timeout")
t:start()
pacmanup = require("pacmanup")
pacmanup.addToWidget(pacman, 280, 90, true)

--AUR
aur = widget({type="textbox"})
local t = timer({timeout = 240})
t:add_signal("timeout", function()
local f = io.popen("echo AUR Updates: $(cower -u | wc -l | tail)", "r")
local s = f:read('*a')
f:close()
aur.text = s
end)
t:emit_signal("timeout")
t:start()
aurup = require("aurup")
aurup.addToWidget(aur, 240, 90, true)

spacer       = widget({ type = "textbox"  })
spacer.text  = ' | '

bitcoin       = widget({ type = "textbox"  })
bitcoin.text  = ' BTC '
bitno = require("bitcoin")
bitno.addToWidget(bitcoin, 240, 90, true)

namecoin       = widget({ type = "textbox"  })
namecoin.text  = ' NMC '
nameno = require("namecoin")
nameno.addToWidget(namecoin, 240, 90, true)

--Vicious Widgets Derived from http://awesome.naquadah.org/wiki/Vicious

-- Initialize Memory TEXT widget
mem1widget = widget({ type = "textbox" })
-- Register widget
vicious.register(mem1widget, vicious.widgets.mem, "RAM: $1% ($2MB/$3MB)", 13)

--RAM GRAPH usage widget
  memwidget = awful.widget.graph()
  memwidget:set_width(50)
  memwidget:set_background_color("#494B4F")
  memwidget:set_color("#FF5656")
  memwidget:set_gradient_colors({ "#FF5656", "#88A175", "#AECF96" })
  vicious.register(memwidget, vicious.widgets.mem, "$1", 3)

-- Initialize Uptime widget
uptimewidget = widget({ type = "textbox" })
-- Register widget
vicious.register(uptimewidget, vicious.widgets.uptime, "Uptime: D:$1 H:$2 M:$3")

-- Initialize CPU TEXT widget
cpu1widget = widget({ type = "textbox" })
-- Register widget
vicious.register(cpu1widget, vicious.widgets.cpu, "CPU: A:$1% C1: $2% C2: $3%")

--CPU usage widget
  cpuwidget = awful.widget.graph()
  cpuwidget:set_width(50)
  cpuwidget:set_background_color("#494B4F")
  cpuwidget:set_color("#FF5656")
  cpuwidget:set_gradient_colors({ "#FF5656", "#88A175", "#AECF96" })
  vicious.register(cpuwidget, vicious.widgets.cpu, "$1", 3)

-- Initialize Battery widget
batwidget = widget({ type = "textbox" })
-- Register widget
--vicious.register(batwidget, vicious.widgets.bat, "$1 Charge:$2% Rem:$3", 61, "BAT1",
vicious.register(batwidget, vicious.widgets.bat, 
--Bat % Warning
function (widget, args)
	if args[2] < 20 then 
		naughty.notify({ title      = "<span color='red'>Battery Warning</span>"
		, text       = "<span color='red'>Battery low! "..args[2].."% left!</span>"
		, timeout    = 60
		, position   = "top_right"
		, fg         = beautiful.fg_focus
		, bg         = beautiful.bg_focus
	})
end
--return '<span color="red">$1$2%</span> <span color="cyan">$3</span>'
return '<span color="white">(Bat: ' .. args[1] .. args[2] .. '% ' .. string.sub(args[3], 0, 5) .. ')</span>' end , 30, "BAT1")
--return '<span color="' .. bottom_panel_text_color .. '">( args[1] .. 'Charge:' .. args[2] .. '% Rem:' .. string.sub(args[3], 0, 5) .. ')</span>' end , 30, "BAT1")

-- Initialize Progressbar
batprog = awful.widget.progressbar()
-- Progressbar properties
batprog:set_width(30):set_ticks_size(2)
batprog:set_height(20)
batprog:set_vertical(false):set_ticks(true)
batprog:set_background_color("#494B4F")
batprog:set_border_color(nil)
batprog:set_color("#AECF96")
batprog:set_gradient_colors({ "#FF5656", "#88A175", "#AECF96" })
vicious.register(batprog, vicious.widgets.bat, "$2 ", 61, "BAT1")
--batprog.addToWidget(batwidget, 5, 5, true)

-- Initialize Wifi widget
wifiwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(wifiwidget, vicious.widgets.wifi, "${ssid} Qual:${link}% Rate:${rate} MB/s", 10, "wlan0")

-- Initialize widget
oswidget = widget({ type = "textbox" })
-- Register widget
vicious.register(oswidget, vicious.widgets.os, "$3@$4")
sys = require("sysinf")
sys.addToWidget(oswidget, 240, 90, true)

-- Initialize Net widget
net = widget({ type = "textbox" })
-- Register widget
vicious.register(net, vicious.widgets.net, "DOWN: ${wlan0 down_kb}KB/s UP: ${wlan0 up_kb}KB/s")
--vicious.register(net, vicious.widgets.net, 
--function (widget, args)
--end
--return '<span color="white">(Bat: ' .. args[1] .. args[2] .. '% ' .. string.sub(args[3], 0, 5) .. ')</span>' end)

-- Initialize Netup Progressbar
netup = awful.widget.progressbar()
-- Progressbar properties
netup:set_width(15)
netup:set_height(20)
netup:set_vertical(true)
netup:set_background_color("#494B4F")
netup:set_border_color(nil)
netup:set_color("#AECF96")
netup:set_gradient_colors({ "#FF5656", "#88A175", "#AECF96" })
vicious.register(netup, vicious.widgets.net, "${wlan0 up_kb}")

-- Initialize NetDown Progress bar
netdown = awful.widget.progressbar()
-- Progressbar properties
netdown:set_width(15)
netdown:set_height(20)
netdown:set_vertical(true)
netdown:set_background_color("#494B4F")
netdown:set_border_color(nil)
netdown:set_color("#AECF96")
netdown:set_gradient_colors({ "#FF5656", "#88A175", "#AECF96" })
vicious.register(netdown, vicious.widgets.net, "${wlan0 down_kb")

-- MPD WIDGET
-- Initialize widget MPD
-- awesome.naquadah.org/wiki/Awesompd_widget
musicwidget = awesompd:create() -- Create awesompd widget
musicwidget.font = 'terminus' -- Set widget font 
musicwidget.scrolling = true -- If true, the text in the widget will be scrolled
musicwidget.output_size = 30 -- Set the size of widget in symbols
musicwidget.update_interval = 10 -- Set the update interval in seconds
-- Set the folder where icons are located (change username to your login name)
musicwidget.path_to_icons = "/home/setkeh/.config/awesome/awesompd/icons" 
-- Set the default music format for Jamendo streams. You can change
-- this option on the fly in awesompd itself.
-- possible formats: awesompd.FORMAT_MP3, awesompd.FORMAT_OGG
musicwidget.jamendo_format = awesompd.FORMAT_MP3
-- If true, song notifications for Jamendo tracks and local tracks will also contain
-- album cover image.
musicwidget.show_album_cover = true
-- Specify how big in pixels should an album cover be. Maximum value
-- is 100.
musicwidget.album_cover_size = 50
-- This option is necessary if you want the album covers to be shown
-- for your local tracks.
musicwidget.mpd_config = "/etc/mpd.conf"
-- Specify the browser you use so awesompd can open links from
-- Jamendo in it.
musicwidget.browser = 'luakit'
-- Specify decorators on the left and the right side of the
-- widget. Or just leave empty strings if you decorate the widget
-- from outside.
 musicwidget.ldecorator = ' &#9835; '
 musicwidget.rdecorator = ' &#9835; '
-- Set all the servers to work with (here can be any servers you use)
musicwidget.servers = {
{ server = 'localhost',
port = 6600 } }
--  { server = '192.168.0.72',
--       port = 6600 } }
-- Set the buttons of the widget
musicwidget:register_buttons({ { '', awesompd.MOUSE_LEFT, musicwidget:command_toggle() },
                             { 'Control', awesompd.MOUSE_SCROLL_UP, musicwidget:command_prev_track() },
                             { 'Control', awesompd.MOUSE_SCROLL_DOWN, musicwidget:command_next_track() },
                             { '', 'XF86AudioPrev', musicwidget:command_prev_track() },
			     { '', 'XF86AudioNext', musicwidget:command_next_track() },
			     { '', awesompd.MOUSE_SCROLL_UP, musicwidget:command_volume_up() },
			     { '', awesompd.MOUSE_SCROLL_DOWN, musicwidget:command_volume_down() },
			     { '', awesompd.MOUSE_RIGHT, musicwidget:command_show_menu() },
			     { modkey, 'XF86AudioLowerVolume', musicwidget:command_volume_down() },
			     { modkey, 'XF86AudioRaiseVolume', musicwidget:command_volume_up() },
			     { '', 'XF86AudioStop', musicwidget:command_stop() },
			     { '', 'XF86AudioPlay', musicwidget:command_playpause() } })
musicwidget:run() -- After all configuration is done, run the widget
-- End mpd

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
myinfowibox = {}
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
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock, spacer, namecoin, spacer, bitcoin, spacer, uptimewidget, spacer, musicwidget.widget,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
   

   -- Create the bottom wibox
   myinfowibox[s] = awful.wibox({ position = "bottom", screen = s })
   -- Add widgets to the bottom wibox
     myinfowibox[s].widgets = { 
	     oswidget,
	     spacer,
             netup,
	     netdown,
	     net,
	     spacer,
	     batprog,
	     batwidget, 
	     spacer, 
	     pacman, 
	     spacer, 
	     aur, 
	     spacer, 
	     memwidget,
	     mem1widget, 
	     spacer, 
	     cpuwidget, 
	     cpu1widget,
--	     spacer, 
--	     uptimewidget, 
	     spacer, 
	     wifiwidget,
	     spacer,
     layout = awful.widget.layout.horizontal.leftright}

end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    awful.key({ modkey,           }, "F1",     keydoc.display),

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
    awful.key({ }, "Print", function () awful.util.spawn("upload_screens scr") end),

    -- Layout manipulation
    keydoc.group("Layout manipulation"),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end, "Swap With Next Window"),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end, "Swap With Previous Window"),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end, "Cycle Windows, Windows Style"),

    -- Standard program
    keydoc.group("Programs"),
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end, "Start RXVT-Unicode"),
    awful.key({ modkey, "Control" }, "r", awesome.restart, "Restart Awesome"),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit, "Quit Awesome"),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end, "Increase Window Size"),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end, "Decrese Window Size"),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end, "Cycle Layouts Forwards"),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end, "Cycle Layouts Reverse"),
    awful.key({ modkey,           }, "w",     function () awful.util.spawn("luakit")    end, "Start Luakit Web Browser"),
    awful.key({ modkey,           }, "a", function () mymainmenu:show({keygrabber=true}) end, "Show Main Menu"),


    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)
keydoc.group("Window Management")
clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end, "Toggle Fulscreen"),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end, "Kill Window"),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end, "Redraw Window"),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end, "Minimise Window"),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)


-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
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
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

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
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
     { rule = { class = "Chromium" },
       properties = { tag = tags[1][3] } },
     { rule = { class = "Vlc" },
       properties = { tag = tags[1][6] } },
     { rule = { class = "VirtualBox" },
       properties = { tag = tags[1][5] } },
     { rule = { class = "Gns3" },
       properties = { tag = tags[1][5] } },
     { rule = { class = "Bitcoin-qt" },
       properties = { tag = tags[1][9] } },
      { rule = { class = "luakit" },
       properties = { tag = tags[1][2] } }, 

}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
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
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Hyprland Lua config (Hyprland 0.55+)
-- Migrated from hyprland.conf; hyprlang was deprecated in 0.55 in favor of Lua.
-- Key benefit: initial_class matching for workspace assignment works correctly here.

require("colors")

--------------------
---- MONITORS ----
--------------------

hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })

---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "nautilus"
local menuApp     = "rofi -show drun -show-icons"
local menuClip    = "rofi -modi clipboard:/home/jona/.config/rofi/modis/clipboard-history-modi.sh -show clipboard -show-icons -theme clipboard"
local browser     = "brave"

-- Smart workspace switch: if the target workspace is inactive on a different
-- monitor, pull it to the current monitor before switching to it.
local function switchWorkspace(n)
    local ws  = hl.get_workspace(n)
    local mon = hl.get_active_monitor()
    if ws and ws.monitor and mon and ws.monitor.id ~= mon.id then
        local wsOnOtherMon = ws.monitor.active_workspace
        if not wsOnOtherMon or wsOnOtherMon.id ~= ws.id then
            hl.dispatch(hl.dsp.workspace.move({ workspace = n, monitor = mon.name }))
        end
    end
    hl.dispatch(hl.dsp.focus({ workspace = n }))
end

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    -- background services
    hl.exec_cmd("waybar")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hyprsunset")

    -- apps (workspace assignment handled by window rules below)
    hl.exec_cmd(browser)
    hl.exec_cmd("keepassxc")
    hl.exec_cmd("kitty tmux new-session -A -s main")
    hl.exec_cmd("obsidian")
    hl.exec_cmd("spotify")
    hl.exec_cmd("signal-desktop")
    hl.exec_cmd("element-desktop")
    hl.exec_cmd("telegram-desktop")
    hl.exec_cmd("thunderbird")
    hl.exec_cmd("gnome-calendar")
    hl.exec_cmd([[brave --user-data-dir=/home/jona/.local/share/brave-pwa/gemini --profile-directory=Default --app=https://gemini.google.com]])
    hl.exec_cmd([[brave --user-data-dir=/home/jona/.local/share/brave-pwa/chatgpt --profile-directory=Default --app=https://chatgpt.com]])
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("NIXOS_OZONE_WL", "1")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 0,
        gaps_out = 0,

        border_size = 1,
        col = {
            active_border   = { colors = {yellow, yellow}, angle = 45 },
            inactive_border = bg,
        },

        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    group = {
        groupbar = {
            font_size  = 12,
            height     = 18,
            col = {
                active   = { colors = {yellow, yellow}, angle = 45 },
                inactive = bg,
            },
            text_color = green,
        },
    },

    decoration = {
        rounding       = 0,
        rounding_power = 0,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
    },

    animations = {
        enabled = false,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 1,
        disable_hyprland_logo   = true,
    },
})

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "gcj",
        follow_mouse = 0,
        sensitivity  = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + return",      hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + q",           hl.dsp.window.close())
hl.bind(mainMod .. " + e",           hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + d",           hl.dsp.exec_cmd(menuApp))
hl.bind(mainMod .. " + v",           hl.dsp.exec_cmd(menuClip))
hl.bind(mainMod .. " + g",           hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + f",           hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + t",           hl.dsp.exec_cmd("/home/jona/nix-config/home/programs/hyprland/kanata-toggle.sh"))

-- lid switch
hl.bind("switch:on:Lid Switch",  hl.dsp.exec_cmd([[hyprctl monitor "eDP-1, disable"]]),          { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd([[hyprctl monitor "eDP-1, preferred, auto, 1"]]), { locked = true })

-- screenshots
hl.bind("Print",       hl.dsp.exec_cmd([[hyprshot -m window -f "$(date +'%Y-%m-%d_%H-%M-%S_screenshot.png')" -o ~/pictures/screenshots]]))
hl.bind("SHIFT+Print", hl.dsp.exec_cmd([[hyprshot -m region -f "$(date +'%Y-%m-%d_%H-%M-%S_screenshot.png')" -o ~/pictures/screenshots]]))

-- session submap
local sessionName = "(S)hutdown, (r)eboot, (s)uspend, (h)ibernate, (l)lock, (L)logout"
hl.bind(mainMod .. " + minus", hl.dsp.submap(sessionName))

hl.define_submap(sessionName, function()
    hl.bind("l", function()
        hl.dispatch(hl.dsp.exec_cmd("playerctl pause; loginctl lock-session"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("SHIFT + l", function()
        hl.dispatch(hl.dsp.exec_cmd("uwsm stop"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("SHIFT + s", function()
        hl.dispatch(hl.dsp.exec_cmd("systemctl poweroff"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("s", function()
        hl.dispatch(hl.dsp.exec_cmd("systemctl suspend"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("h", function()
        hl.dispatch(hl.dsp.exec_cmd("systemctl hibernate"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("r", function()
        hl.dispatch(hl.dsp.exec_cmd("systemctl reboot"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("return", hl.dsp.submap("reset"))
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("q",      hl.dsp.submap("reset"))
end)

-- group management
hl.bind(mainMod .. " + CTRL + j", hl.dsp.group.toggle())
hl.bind(mainMod .. " + CTRL + l", hl.dsp.group.next())
hl.bind(mainMod .. " + CTRL + h", hl.dsp.group.prev())
hl.bind(mainMod .. " + CTRL + k", function()
    hl.dispatch(hl.dsp.group.move_window("l"))
    hl.dispatch(hl.dsp.group.move_window("r"))
    hl.dispatch(hl.dsp.group.move_window("u"))
    hl.dispatch(hl.dsp.group.move_window("d"))
end)

hl.bind(mainMod .. " + SHIFT + Space", hl.dsp.window.float({ action = "toggle" }))

-- focus
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left"  }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up"    }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down"  }))

-- move windows
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "left"  }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "up"    }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "down"  }))

-- workspace navigation
hl.bind("ALT + TAB", hl.dsp.focus({ workspace = "previous" }))

-- switch workspaces
hl.bind(mainMod .. " + 1",         function() switchWorkspace(1)  end)
hl.bind(mainMod .. " + 2",         function() switchWorkspace(2)  end)
hl.bind(mainMod .. " + 3",         function() switchWorkspace(3)  end)
hl.bind(mainMod .. " + 4",         function() switchWorkspace(4)  end)
hl.bind(mainMod .. " + 5",         function() switchWorkspace(5)  end)
hl.bind(mainMod .. " + 6",         function() switchWorkspace(6)  end)
hl.bind(mainMod .. " + 7",         function() switchWorkspace(7)  end)
hl.bind(mainMod .. " + 8",         function() switchWorkspace(8)  end)
hl.bind(mainMod .. " + 9",         function() switchWorkspace(9)  end)
hl.bind(mainMod .. " + 0",         function() switchWorkspace(10) end)
hl.bind(mainMod .. " + m",         function() switchWorkspace(11) end)
hl.bind(mainMod .. " + slash",     function() switchWorkspace(12) end)
hl.bind(mainMod .. " + p",         function() switchWorkspace(13) end)
hl.bind(mainMod .. " + comma",     function() switchWorkspace(14) end)
hl.bind(mainMod .. " + u",         function() switchWorkspace(15) end)
hl.bind(mainMod .. " + n",         function() switchWorkspace(16) end)
hl.bind(mainMod .. " + parenleft", function() switchWorkspace(17) end)
hl.bind(mainMod .. " + i",         function() switchWorkspace(18) end)
hl.bind(mainMod .. " + o",         function() switchWorkspace(19) end)
hl.bind(mainMod .. " + period",    function() switchWorkspace(20) end)

-- move window to workspace
hl.bind(mainMod .. " + SHIFT + 1",         hl.dsp.window.move({ workspace = 1  }))
hl.bind(mainMod .. " + SHIFT + 2",         hl.dsp.window.move({ workspace = 2  }))
hl.bind(mainMod .. " + SHIFT + 3",         hl.dsp.window.move({ workspace = 3  }))
hl.bind(mainMod .. " + SHIFT + 4",         hl.dsp.window.move({ workspace = 4  }))
hl.bind(mainMod .. " + SHIFT + 5",         hl.dsp.window.move({ workspace = 5  }))
hl.bind(mainMod .. " + SHIFT + 6",         hl.dsp.window.move({ workspace = 6  }))
hl.bind(mainMod .. " + SHIFT + 7",         hl.dsp.window.move({ workspace = 7  }))
hl.bind(mainMod .. " + SHIFT + 8",         hl.dsp.window.move({ workspace = 8  }))
hl.bind(mainMod .. " + SHIFT + 9",         hl.dsp.window.move({ workspace = 9  }))
hl.bind(mainMod .. " + SHIFT + 0",         hl.dsp.window.move({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + m",         hl.dsp.window.move({ workspace = 11 }))
hl.bind(mainMod .. " + SHIFT + slash",     hl.dsp.window.move({ workspace = 12 }))
hl.bind(mainMod .. " + SHIFT + p",         hl.dsp.window.move({ workspace = 13 }))
hl.bind(mainMod .. " + SHIFT + comma",     hl.dsp.window.move({ workspace = 14 }))
hl.bind(mainMod .. " + SHIFT + u",         hl.dsp.window.move({ workspace = 15 }))
hl.bind(mainMod .. " + SHIFT + n",         hl.dsp.window.move({ workspace = 16 }))
hl.bind(mainMod .. " + SHIFT + parenleft", hl.dsp.window.move({ workspace = 17 }))
hl.bind(mainMod .. " + SHIFT + i",         hl.dsp.window.move({ workspace = 18 }))
hl.bind(mainMod .. " + SHIFT + o",         hl.dsp.window.move({ workspace = 19 }))
hl.bind(mainMod .. " + SHIFT + period",    hl.dsp.window.move({ workspace = 20 }))

-- scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- drag/resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- volume / brightness / media
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("/run/current-system/sw/bin/wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("/run/current-system/sw/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("/run/current-system/sw/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),       { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("/run/current-system/sw/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 10%+"),                                              { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 10%-"),                                              { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),        { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),    { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- suppress maximize requests
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- fix XWayland drag ghost windows
hl.window_rule({
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- hide border when only one window on workspace
hl.window_rule({ match = { workspace = "w[t1]" }, decorate = false })

-- workspace assignments (initial_class fires at creation time, unlike tag-based rules)
hl.window_rule({ match = { initial_class = "brave-browser"                        }, workspace = "18 silent" })
hl.window_rule({ match = { initial_class = "org.keepassxc.KeePassXC"             }, workspace = "20 silent" })
hl.window_rule({ match = { initial_class = "obsidian"                            }, workspace = "14 silent" })
hl.window_rule({ match = { initial_class = "Spotify"                             }, workspace = "11 silent" })
hl.window_rule({ match = { initial_class = "signal"                              }, workspace = "15 silent" })
hl.window_rule({ match = { initial_class = "element"                             }, workspace = "15 silent" })
hl.window_rule({ match = { initial_class = "org.telegram.desktop"                }, workspace = "15 silent" })
hl.window_rule({ match = { initial_class = "thunderbird"                         }, workspace = "17 silent" })
hl.window_rule({ match = { initial_class = "org.gnome.Calendar"                  }, workspace = "16 silent" })
hl.window_rule({ match = { initial_class = "brave-gemini.google.com__-Default"   }, workspace = "13 silent" })
hl.window_rule({ match = { initial_class = "brave-chatgpt.com__-Default"         }, workspace = "13 silent" })

-- group messaging apps together
hl.window_rule({ match = { initial_class = "signal"               }, group = "set" })
hl.window_rule({ match = { initial_class = "element"              }, group = "set" })
hl.window_rule({ match = { initial_class = "org.telegram.desktop" }, group = "set" })

-- group AI tools together
hl.window_rule({ match = { initial_class = "brave-gemini.google.com__-Default" }, group = "set" })
hl.window_rule({ match = { initial_class = "brave-chatgpt.com__-Default"       }, group = "set" })

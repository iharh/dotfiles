local awful_util = require("awful.util")

local terminal = "kitty" -- "urxvt"
local editor = "vim"
local local_config = {}

function local_config.init(awesome_context)
    local conf = awesome_context.config
    conf.wlan_if = 'wlp4s0'
    conf.eth_if = 'enp2s0'
    conf.net_preset = 'systemd'
    conf.music_players = { 'spotify', 'clementine', 'mopidy' }

    -- awesome_context.theme_dir = awful_util.getdir("config") .. "/themes/lcars-xresources-hidpi/theme.lua"
    -- awesome_context.theme_dir = awful_util.getdir("config") .. "/themes/twmish/theme.lua"
    awesome_context.theme_dir = awful_util.getdir("config") .. "/themes/gtk/theme.lua"

    awesome_context.autorun = {
        "parcellite",
        "setxkbmap -model pc104 -layout us,ru -variant ,, -option grp:ctrl_shift_toggle",
        --"~/.scripts/tp_unmute",
        --"killall compton ; compton",
    }

    awesome_context.have_battery = false
    awesome_context.have_music = false
    awesome_context.sensor = "temp1"

    awesome_context.before_config_loaded = function()
        -- size fixes for Fanstasque Sans Mono:
        local beautiful = require("beautiful")
        beautiful.font = "Monospace Bold 13"
        beautiful.tasklist_font = "Monospace 13"
        beautiful.panel_widget_font = beautiful.tasklist_font
        beautiful.taglist_font =  beautiful.font
        beautiful.titlebar_font =  beautiful.font
        beautiful.sans_font = "Sans 13"

        beautiful.tasklist_disable_icon = false

        beautiful.tasklist_fg_normal = "#3c3e3c" -- need to strip tailing ff from beautiful.fg
        -- beautiful.titlebar_fg_normal

        -- beautiful.clock_fg = beautiful.panel_fg
        -- beautiful.clock_fg = beautiful.fg
        -- beautiful.clock_fg = "#3c3e3cff"

        -- nlog(beautiful.tasklist_fg_normal)
    end

    awesome_context.after_config_loaded = function()
    end

    awesome_context.cmds = {
        terminal = terminal,
        terminal_light = terminal,  -- @TODO: add it
        editor_cmd = terminal .. " -e " .. editor,
        compositor = "killall compton; compton",
        file_manager = "pcmanfm",
        tmux = terminal, -- .. " -e bash \\-c tmux",
        tmux_light = terminal, -- .. " -e bash \\-c tmux",  -- @TODO: add it
        tmux_run   = terminal, -- .. " -e tmux new-session ",
        scrot_preview_cmd = [['mv $f ~/images/ && viewnior ~/images/$f']],
    }

    return awesome_context
end

return local_config

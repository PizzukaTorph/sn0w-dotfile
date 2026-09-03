-- sn0w Hyprland entrypoint
-- Native Lua configuration for Hyprland 0.55+.

local terminal = "foot"
local fileManager = "nautilus"

-- Safe VM/default monitor rule. Asahi-specific scaling will live in its profile.
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

hl.config({
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true,
            ["tap-to-click"] = true,
        },
    },
})

-- Quickshell owns the visible sn0w shell and must inherit this Wayland session.
hl.exec_once({ "qs" })

-- Core sn0w contracts.
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("qs ipc call launcher toggle"))
hl.bind("SUPER + TAB", hl.dsp.exec_cmd("qs ipc call switcher toggle"))
hl.bind("SUPER + UP", hl.dsp.exec_cmd("qs ipc call overview toggle"))
hl.bind("SUPER + SHIFT + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager))

-- Essential window management while the custom shell is still being built.
hl.bind("SUPER + W", hl.dsp.window.kill_active())
hl.bind("SUPER + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))

-- Focus navigation.
hl.bind("SUPER + LEFT", hl.dsp.window.move_focus("l"))
hl.bind("SUPER + RIGHT", hl.dsp.window.move_focus("r"))
hl.bind("SUPER + UP", hl.dsp.window.move_focus("u"))
hl.bind("SUPER + DOWN", hl.dsp.window.move_focus("d"))

-- Workspace navigation. Keep plain Command+arrows available for app semantics.
hl.bind("SUPER + CTRL + LEFT", hl.dsp.workspace.change("e-1"))
hl.bind("SUPER + CTRL + RIGHT", hl.dsp.workspace.change("e+1"))
hl.bind("SUPER + CTRL + SHIFT + LEFT", hl.dsp.window.move_to_workspace("e-1"))
hl.bind("SUPER + CTRL + SHIFT + RIGHT", hl.dsp.window.move_to_workspace("e+1"))

-- Recovery escape hatch during bootstrap/debug.
hl.bind("SUPER + SHIFT + Q", hl.dsp.exit())

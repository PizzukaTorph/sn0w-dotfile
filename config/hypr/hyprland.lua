-- sn0w Hyprland entrypoint
-- Native Lua configuration for Hyprland 0.55+.

local terminal = "foot"
local fileManager = "nautilus"

-- Make the desktop identity explicit for portals and session services.
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

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
            tap_to_click = true,
        },
    },
})

-- Hyprland is the owner of the live Wayland session. Export its environment to
-- the systemd user manager for portals, then launch Quickshell directly from
-- this compositor process. This avoids a race where graphical-session.target
-- starts the shell before WAYLAND_DISPLAY reaches the user manager.
hl.on("hyprland.start", function()
    hl.exec_cmd("sh -lc 'dbus-update-activation-environment --systemd --all; systemctl --user import-environment WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE PATH; systemctl --user start graphical-session.target; systemctl --user restart xdg-desktop-portal-hyprland.service xdg-desktop-portal.service'")
    hl.exec_cmd("sh -lc 'pkill -x qs 2>/dev/null || true; exec qs'")
end)

-- Core sn0w contracts.
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("qs ipc call launcher toggle"))
hl.bind("SUPER + TAB", hl.dsp.exec_cmd("qs ipc call switcher toggle"))
hl.bind("SUPER + UP", hl.dsp.exec_cmd("qs ipc call overview toggle"))
hl.bind("SUPER + SHIFT + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager))

-- Essential window management while the custom shell is still being built.
hl.bind("SUPER + W", hl.dsp.window.close({}))
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" }))
hl.bind("SUPER + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))

-- Focus navigation. SUPER+UP stays reserved for sn0w Overview.
hl.bind("SUPER + LEFT", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + RIGHT", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + DOWN", hl.dsp.focus({ direction = "d" }))

-- Workspace navigation uses CTRL so plain Command+arrows can later preserve
-- application-level Mac muscle memory.
hl.bind("SUPER + CTRL + LEFT", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + CTRL + RIGHT", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + CTRL + SHIFT + LEFT", hl.dsp.window.move({ workspace = "e-1" }))
hl.bind("SUPER + CTRL + SHIFT + RIGHT", hl.dsp.window.move({ workspace = "e+1" }))

-- Recovery escape hatch during bootstrap/debug.
hl.bind("SUPER + SHIFT + Q", hl.dsp.exit())

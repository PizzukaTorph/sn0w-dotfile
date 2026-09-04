-- sn0w Hyprland entrypoint
-- Native Lua configuration for Hyprland 0.55+.

local terminal = "foot"
local fileManager = "nautilus"

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GTK_THEME", "Adwaita:dark")

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

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

-- Centered sn0w system surfaces must never enter the tiling tree.
-- Match both initial_title and live title because Quickshell can publish the
-- final xdg-toplevel title after the surface has already been created.
local sn0wModalTitle = "^sn0w (Launcher|App Switcher|Overview|Project Center|Settings|Clipboard|Capture)$"

hl.window_rule({
    name = "sn0w-centered-surfaces-initial",
    match = {
        initial_title = sn0wModalTitle,
    },
    float = true,
    center = true,
})

hl.window_rule({
    name = "sn0w-centered-surfaces-live",
    match = {
        title = sn0wModalTitle,
    },
    float = true,
    center = true,
})

-- Control Center and Power are topbar-owned PopupWindows. Never tile them and
-- never center them: Quickshell anchors them beneath the clicked control.
hl.window_rule({
    name = "sn0w-topbar-popovers",
    match = {
        initial_title = "^sn0w (Control Center|Power)$",
    },
    float = true,
})

hl.on("hyprland.start", function()
    hl.exec_cmd("sh -lc 'dbus-update-activation-environment --systemd --all; systemctl --user import-environment WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE GTK_THEME PATH; systemctl --user start sn0w-graphical-session.service; systemctl --user restart xdg-desktop-portal-hyprland.service xdg-desktop-portal-gtk.service xdg-desktop-portal.service'")
    hl.exec_cmd("sh -lc 'pkill -x qs 2>/dev/null || true; exec qs'")
    hl.exec_cmd("sh -lc 'pkill -f \"wl-paste.*cliphist store\" 2>/dev/null || true; wl-paste --type text --watch cliphist store >/dev/null 2>&1 & wl-paste --type image --watch cliphist store >/dev/null 2>&1 &' ")
end)

-- Core sn0w contracts.
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("qs ipc call launcher toggle"))
hl.bind("SUPER + TAB", hl.dsp.exec_cmd("qs ipc call switcher cycle"))
hl.bind("SUPER + UP", hl.dsp.exec_cmd("qs ipc call overview toggle"))
hl.bind("SUPER + ALT + D", hl.dsp.exec_cmd("qs ipc call projects toggle"))
hl.bind("SUPER + COMMA", hl.dsp.exec_cmd("qs ipc call settings toggle"))
hl.bind("SUPER + SHIFT + V", hl.dsp.exec_cmd("qs ipc call clipboard toggle"))
hl.bind("SUPER + SHIFT + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager))

-- Capture contracts, matching macOS muscle memory.
hl.bind("SUPER + SHIFT + 3", hl.dsp.exec_cmd("sh -lc 'mkdir -p ~/Pictures/Screenshots; grim ~/Pictures/Screenshots/sn0w-$(date +%Y%m%d-%H%M%S).png'"))
hl.bind("SUPER + SHIFT + 4", hl.dsp.exec_cmd("sh -lc 'mkdir -p ~/Pictures/Screenshots; grim -g \"$(slurp)\" ~/Pictures/Screenshots/sn0w-$(date +%Y%m%d-%H%M%S).png'"))
hl.bind("SUPER + SHIFT + 5", hl.dsp.exec_cmd("qs ipc call capture toggle"))

-- Media keys. Keep shell commands deliberately simple; Quickshell owns state
-- presentation and derives the next value from SystemState.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("qs ipc call osd volumeUp"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("qs ipc call osd volumeDown"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("qs ipc call osd muteToggle"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("qs ipc call osd brightnessUp"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("qs ipc call osd brightnessDown"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

-- Essential window management.
hl.bind("SUPER + W", hl.dsp.window.close({}))
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" }))
hl.bind("SUPER + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))

-- Focus navigation. SUPER+UP stays reserved for sn0w Overview.
hl.bind("SUPER + LEFT", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + RIGHT", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + DOWN", hl.dsp.focus({ direction = "d" }))

-- Workspace navigation uses CTRL so plain Command+arrows remain available for app semantics.
hl.bind("SUPER + CTRL + LEFT", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + CTRL + RIGHT", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + CTRL + SHIFT + LEFT", hl.dsp.window.move({ workspace = "e-1" }))
hl.bind("SUPER + CTRL + SHIFT + RIGHT", hl.dsp.window.move({ workspace = "e+1" }))

hl.bind("SUPER + SHIFT + Q", hl.dsp.exit())

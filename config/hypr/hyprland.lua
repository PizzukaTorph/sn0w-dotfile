-- sn0w Hyprland entrypoint
-- Native Lua configuration for Hyprland 0.55+.

local terminal = "foot"
local fileManager = "nautilus"

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("QT_QPA_PLATFORMTHEME", "gnome")

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.config({
    general = {
        -- sn0w uses shape, spacing and shadow rather than focus rings.
        -- Keep this global so GTK, Qt, terminals and sn0w surfaces are coherent.
        border_size = 0,
    },
    decoration = {
        rounding = 12,
        rounding_power = 2.0,
    },
    input = {
        kb_layout = "us",
        follow_mouse = 1,

        -- Mac-like defaults. SettingsState reapplies the persisted user choices
        -- after Quickshell starts, so these are also the first-boot fallback.
        natural_scroll = true,
        sensitivity = 0.0,
        scroll_factor = 1.0,
        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            clickfinger_behavior = true,
            tap_and_drag = true,
            drag_lock = 1,
            disable_while_typing = true,
            scroll_factor = 1.0,
        },
    },
})

-- Three-finger gestures are always registered, but can be disabled instantly
-- from sn0w Settings. A tiny marker file keeps the gesture callback cheap and
-- avoids reloading Hyprland whenever the user toggles the feature.
local function sn0wGesturesEnabled()
    local home = os.getenv("HOME") or ""
    local file = io.open(home .. "/.config/sn0w/gestures-disabled", "r")
    if file then
        file:close()
        return false
    end
    return true
end

local function sn0wGesture(command)
    return function()
        if sn0wGesturesEnabled() then
            hl.exec_cmd(command)
        end
    end
end

hl.gesture({
    fingers = 3,
    direction = "left",
    action = sn0wGesture("hyprctl dispatch workspace e+1"),
})

hl.gesture({
    fingers = 3,
    direction = "right",
    action = sn0wGesture("hyprctl dispatch workspace e-1"),
})

hl.gesture({
    fingers = 3,
    direction = "up",
    action = sn0wGesture("qs ipc call overview toggle"),
})

hl.gesture({
    fingers = 3,
    direction = "down",
    action = sn0wGesture("hyprctl dispatch killactive"),
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
    hl.exec_cmd("sh -lc 'dbus-update-activation-environment --systemd --all; systemctl --user import-environment WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE GTK_THEME QT_QPA_PLATFORMTHEME PATH; systemctl --user start sn0w-graphical-session.service; systemctl --user restart xdg-desktop-portal-hyprland.service xdg-desktop-portal-gtk.service xdg-desktop-portal.service'")
    hl.exec_cmd("sh -lc 'pkill -x qs 2>/dev/null || true; exec qs'")
    hl.exec_cmd("sh -lc 'pkill -f \"wl-paste.*cliphist store\" 2>/dev/null || true; wl-paste --type text --watch cliphist store >/dev/null 2>&1 & wl-paste --type image --watch cliphist store >/dev/null 2>&1 &' ")
end)

-- Core sn0w contracts.
-- Launcher is intentionally open-only from the global shortcut. Visibility can
-- desynchronise briefly while a launched desktop entry takes focus; using
-- `open` makes SUPER+SPACE idempotent instead of letting stale state turn the
-- next press into an accidental close.
hl.bind(
    "SUPER + SPACE",
    hl.dsp.exec_cmd("qs ipc call launcher open"),
    {
        dont_inhibit = true,
        transparent = true,
    }
)

hl.bind("SUPER + TAB", hl.dsp.exec_cmd("qs ipc call switcher cycle"))

-- Modifier-only binds must use the actual modifier keysym without also listing
-- SUPER as a modifier. Requiring SUPER while releasing Super_L/Super_R can race
-- with modifier-state teardown and interfere with adjacent Command shortcuts.
hl.bind(
    "Super_L",
    hl.dsp.exec_cmd("qs ipc call switcher commit"),
    {
        release = true,
        transparent = true,
        dont_inhibit = true,
    }
)

hl.bind(
    "Super_R",
    hl.dsp.exec_cmd("qs ipc call switcher commit"),
    {
        release = true,
        transparent = true,
        dont_inhibit = true,
    }
)

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

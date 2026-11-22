-- This is an example Hyprland Lua config file.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/configuring/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- You can (and should!!) split this configuration into multiple files
-- Create your files separately and then require them like this:
-- require("myColors")

------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/configuring/core/monitors/
hl.monitor({
	output = "eDP-2",
	mode = "1920x1080@144.0",
	position = "1920x0",
	scale = 1,
})

hl.monitor({
	output = "HDMI-A-1",
	mode = "1920x1080@240.0",
	position = "3840x0",
	scale = 1,
})

hl.monitor({
	output = "DVI-I-1",
	mode = "1920x1080@60.0",
	position = "0x0",
	scale = 1,
})

---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal = "kitty"
local fileManager = terminal .. " -e yazi"
local menu = "fuzzel"

-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/configuring/core/autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
-- hl.on("hyprland.start", function ()
--   hl.exec_cmd(terminal)
--   hl.exec_cmd("nm-applet")
--   hl.exec_cmd("waybar & hyprpaper & firefox")
-- end)

hl.on("hyprland.start", function()
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	hl.exec_cmd("hypridle")

	-- Core layer rules
	-- hl.exec_cmd("hyprctl keyword layerrule ignorezero,quickshell")
	-- hl.exec_cmd("hyprctl keyword layerrule ignorealpha 0.1,quickshell")

	-- Wallpaper engine (NeoBrix now renders wallpapers through Quickshell)
	-- hl.exec_cmd("hyprpaper")

	-- iOS Liquid Glass Blur Engine
	-- hl.exec_cmd("hyprctl keyword layerrule blurpasses 3,quickshell")
	-- hl.exec_cmd("hyprctl keyword layerrule blursize 8,quickshell")
	-- hl.exec_cmd("hyprctl keyword layerrule vibrancy 0.5,quickshell")

	-- Launch Quickshell with the session
	hl.exec_cmd("/home/rombie/.local/share/neobrix-compatible/start-neobrix.sh")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/configuring/core/environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Force Aquamarine to use AMD iGPU as primary and NVIDIA dGPU as secondary for external displays:
hl.env("AQ_DRM_DEVICES", "/dev/dri/amd-igpu:/dev/dri/nvidia-dgpu:/dev/dri/card0")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "mesa")
hl.env("VK_DRIVER_FILES", "/usr/share/vulkan/icd.d/radeon_icd.json")

-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/configuring/core/advanced-configuration/permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/configuring/core/config-options/
hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 20,

		border_size = 2,

		col = {
			active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},

		-- Set to true to enable resizing windows by clicking and dragging on borders and gaps
		resize_on_border = false,

		-- Please see https://wiki.hypr.land/configuring/extra/tearing/ before you turn this on
		allow_tearing = false,

		layout = "dwindle",
	},

	decoration = {
		rounding = 10,
		rounding_power = 2,

		-- Change transparency of focused and unfocused windows
		active_opacity = 0.85,
		inactive_opacity = 0.55,

		shadow = {
			enabled = true,
			range = 20,
			render_power = 4,
			color = 0x66000000,
		},

		blur = {
			enabled = true,
			size = 5,
			passes = 4,
			new_optimizations = true,
			xray = true,
			noise = 0.015,
			contrast = 1.15,
			brightness = 1.05,
			vibrancy = 0.45,
			vibrancy_darkness = 0.2,
		},
	},

	animations = {
		enabled = true,
	},
})

-- Default curves and animations, see https://wiki.hypr.land/configuring/core/animations/
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- Default springs
hl.curve("easy", { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24 })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- Ref https://wiki.hypr.land/configuring/core/rules/workspace-rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
hl.window_rule({
	name = "learnGL-float",
	match = { class = "^(learnGL)$" },
	float = true,
})
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- See https://wiki.hypr.land/configuring/layouts/dwindle-layout/ for more
hl.config({
	dwindle = {
		preserve_split = true, -- You probably want this
	},
})

-- See https://wiki.hypr.land/configuring/layouts/master-layout/ for more
hl.config({
	master = {
		new_status = "master",
	},
})

-- See https://wiki.hypr.land/configuring/layouts/scrolling-layout/ for more
hl.config({
	scrolling = {
		fullscreen_on_one_column = true,
	},
})

----------------
----  MISC  ----
----------------

hl.config({
	misc = {
		force_default_wallpaper = -1, -- Set to 0 or 1 to disable the anime mascot wallpapers
		disable_hyprland_logo = false, -- If true disables the random hyprland logo / anime girl background. :(
	},
})

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		follow_mouse = 1,

		sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

		touchpad = {
			natural_scroll = false,
		},
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- Example per-device config
-- See https://wiki.hypr.land/configuring/core/devices/ for more
hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local superMod = "SUPER + SHIFT" -- Sets "SHIFT" key as second modifier
local altMod = "SUPER + ALT" -- Sets "SHIFT" key as second modifier

-- Example binds, see https://wiki.hypr.land/configuring/core/binds/ for more
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())

hl.bind(
	superMod .. " + Q",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

-- Move windows with mainMod + secondMod + arrow keys
hl.bind(superMod .. " + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(superMod .. " + J", hl.dsp.window.move({ direction = "d" }))
hl.bind(superMod .. " + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(superMod .. " + L", hl.dsp.window.move({ direction = "r" }))

----------------------------------------
---------  NEOBRIX SHORTCUTS -----------
----------------------------------------
-- Application launcher
hl.bind(mainMod .. " + SPACE", hl.dsp.global("neobrix:launcher"))

-- System control center
hl.bind(mainMod .. " + X", hl.dsp.global("neobrix:control"))

-- Notifications
hl.bind(mainMod .. " + A", hl.dsp.global("neobrix:notifications"))

-- Notifications
hl.bind(mainMod .. " + C", hl.dsp.global("neobrix:calendar"))

-- Clipboard history
hl.bind(altMod .. " + V", hl.dsp.global("neobrix:clipboard"))

-- Dawn / Dusk theme switch
hl.bind(superMod .. " + T", hl.dsp.global("neobrix:theme"))

-- Wallpaper Picker
hl.bind(altMod .. " + W", hl.dsp.global("neobrix:wallpapers"))

-- NeoBrix scratchpad

-- Show / hide the scratchpad
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("scratch"))

-- Send the active window to the scratchpad
hl.bind(mainMod .. " + ALT + S", hl.dsp.window.move({workspace = "special:scratch",}))

-- Clipboard History Picker (SUPER + V)
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))

-- Screenshots (Grim + Slurp -> Clipboard + Notification)
hl.bind(
	superMod .. " + S",
	hl.dsp.exec_cmd([[grim -g "$(slurp -w 0)" - | wl-copy && notify-send "Screenshot" "Region copied to clipboard"]])
)
hl.bind("PRINT", hl.dsp.exec_cmd('grim - | wl-copy && notify-send "Screenshot" "Fullscreen copied to clipboard"'))

-- Color Picker
hl.bind(superMod .. " + C", hl.dsp.exec_cmd("hyprpicker -a"))

-- Lock Screen Immediately
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("hyprlock"))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
-- NeoBrix: 5 independent workspaces per monitor
local nbWorkspaces =
    os.getenv("HOME") ..
    "/.local/share/neobrix-compatible/bin/neobrix-workspaces"

for i = 1, 5 do
    -- Focus local workspace 1-5
    hl.bind(
        mainMod .. " + " .. i,
        hl.dsp.exec_cmd(nbWorkspaces .. " focus " .. i)
    )

    -- Move active window to local workspace 1-5
    hl.bind(
        mainMod .. " + SHIFT + " .. i,
        hl.dsp.exec_cmd(nbWorkspaces .. " move " .. i)
    )
end


-- Example special workspace (scratchpad)
-- hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
-- hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll


-- Cycle local workspaces on focused monitor
hl.bind(
    mainMod .. " + mouse_down",
    hl.dsp.exec_cmd(nbWorkspaces .. " cycle 1")
)

hl.bind(
    mainMod .. " + mouse_up",
    hl.dsp.exec_cmd(nbWorkspaces .. " cycle -1")
)

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), {
	locked = true,
	repeating = true,
})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), {
	locked = true,
	repeating = true,
})
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), {
	locked = true,
	repeating = true,
})
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), {
	locked = true,
	repeating = true,
})
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), {
	locked = true,
	repeating = true,
})
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), {
	locked = true,
	repeating = true,
})

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/configuring/core/rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)
hl.layer_rule({
	name = "no-anim-slurp",
	match = { namespace = "^selection$" },
	no_anim = true,
})

hl.layer_rule({
	name = "quickshell-glass",
	match = { namespace = "^quickshell$" },
	blur = true,
	ignore_alpha = 0.05,
})

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})

-- BEGIN NEOBRIX COMPAT APPEARANCE (managed by adapt_neobrix.py)
-- Visual styling only: your monitors, GPU variables, binds and input stay unchanged.
dofile(
	(os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")) .. "/neobrix-compatible/hypr/appearance.lua"
)
-- END NEOBRIX COMPAT APPEARANCE

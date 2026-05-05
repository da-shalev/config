-- Hyprland native Lua config - mirror of hyprland.conf

--------------------------------------------------------------------------------
-- Look and feel
--------------------------------------------------------------------------------

hl.config({
  general = {
    border_size = 0,
    gaps_in = 0,
    gaps_out = 0,
    layout = 'master',
  },
  decoration = {
    rounding = 0,
    shadow = { enabled = false },
  },
  misc = {
    focus_on_activate = true,
    background_color = 0x000000,
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
  },
  cursor = {
    no_hardware_cursors = true,
  },
  ecosystem = {
    no_update_news = true,
    no_donation_nag = true,
  },
  group = {
    groupbar = { enabled = false },
  },
  master = {
    mfact = 0.5,
  },
  render = {
    direct_scanout = true,
  },
  animations = {
    enabled = true,
  },
})

-- `animation = workspaces, 0` -> speed 0 / disabled
hl.animation({ leaf = 'workspaces', enabled = false })
hl.animation({ leaf = 'windows', enabled = true, speed = 1.3, bezier = 'default' })
hl.animation({ leaf = 'zoomFactor', enabled = true, speed = 1.3, bezier = 'default' })

--------------------------------------------------------------------------------
-- Input
--------------------------------------------------------------------------------

hl.config({
  input = {
    accel_profile = 'flat',
    follow_mouse = 0,
    kb_layout = 'us',
    kb_model = '',
    kb_options = 'caps:escape',
    kb_rules = 'evdev',
    kb_variant = '',
    mouse_refocus = false,
    repeat_delay = 300,
    repeat_rate = 50,
    sensitivity = 0,
    touchpad = {
      disable_while_typing = false,
      natural_scroll = true,
      scroll_factor = 0.2,
    },
  },
})

--------------------------------------------------------------------------------
-- Layer / window rules
--------------------------------------------------------------------------------

hl.layer_rule({
  name = 'vicinae-blur',
  match = { namespace = 'vicinae' },
  blur = true,
})

hl.layer_rule({
  name = 'vicinae-ignore-alpha',
  match = { namespace = 'vicinae' },
  ignore_alpha = 0,
})

hl.window_rule({
  name = 'pip',
  match = { title = '(?i:^(Picture)(?:[- ]in[- ]Picture)$)' },
  float = true,
  pin = true,
  move = '(monitor_w*0.7) 0',
  size = '(monitor_w*0.3) (monitor_h*0.3)',
})

--------------------------------------------------------------------------------
-- Autostart (exec-once semantics: only on first launch, not on every reload)
--------------------------------------------------------------------------------

hl.on('hyprland.start', function()
  hl.exec_cmd('foot --server --log-no-syslog')
  hl.exec_cmd('fnott')
  hl.exec_cmd('mpd')
  hl.exec_cmd('vicinae server')
  hl.exec_cmd('hypridle')
end)

--------------------------------------------------------------------------------
-- Keybinds
--------------------------------------------------------------------------------

local mod = 'SUPER'
local modShift = 'SUPER + SHIFT'

-- Apps / utilities
hl.bind(mod .. ' + Return', hl.dsp.exec_cmd('footclient -D ~/media'))
hl.bind(mod .. ' + F2', hl.dsp.exec_cmd('hyprshot -m active -m output'))
hl.bind(mod .. ' + F3', hl.dsp.exec_cmd('hyprshot -m region'))
hl.bind(mod .. ' + F4', hl.dsp.exec_cmd('hyprshot -m window'))
hl.bind(mod .. ' + F5', hl.dsp.exec_cmd('hyprshot -m active -m window'))
hl.bind(mod .. ' + period', hl.dsp.exec_cmd('whisper-dictation'))
hl.bind(modShift .. ' + N', hl.dsp.exec_cmd('pkill hyprsunset || hyprsunset -t 4000'))
hl.bind(
  modShift .. ' + C',
  hl.dsp.exec_cmd('pkill hyprpicker || hyprpicker | wl-clipboard "wl-copy"')
)
hl.bind(
  modShift .. ' + E',
  hl.dsp.exec_cmd('vicinae deeplink vicinae://extensions/vicinae/core/search-emojis')
)
hl.bind(
  modShift .. ' + R',
  hl.dsp.exec_cmd('vicinae deeplink vicinae://extensions/vicinae/core/refresh-apps')
)
hl.bind(mod .. ' + Space', hl.dsp.exec_cmd('vicinae toggle'))
hl.bind(
  mod .. ' + Tab',
  hl.dsp.exec_cmd('vicinae deeplink vicinae://extensions/vicinae/wm/switch-windows')
)

-- Media keys
hl.bind('XF86AudioPlay', hl.dsp.exec_cmd('mpc toggle'))
hl.bind('XF86AudioPrev', hl.dsp.exec_cmd('mpc prev'))
hl.bind('XF86AudioNext', hl.dsp.exec_cmd('mpc next'))

-- Session / window management
hl.bind(modShift .. ' + Q', hl.dsp.exit())
hl.bind(modShift .. ' + 0', hl.dsp.window.pin())
hl.bind(modShift .. ' + H', hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
hl.bind(modShift .. ' + L', hl.dsp.window.resize({ x = 50, y = 0, relative = true }))
hl.bind(modShift .. ' + J', hl.dsp.layout('swapnext'))
hl.bind(modShift .. ' + K', hl.dsp.layout('swapprev'))
hl.bind(mod .. ' + Q', hl.dsp.window.close())
hl.bind(mod .. ' + F', hl.dsp.window.fullscreen({ mode = 'fullscreen' }))
hl.bind(mod .. ' + S', hl.dsp.window.float({ action = 'toggle' }))
hl.bind(mod .. ' + J', hl.dsp.layout('cyclenext'))
hl.bind(mod .. ' + K', hl.dsp.layout('cycleprev'))

-- Workspaces (physical keycodes 10..18 map to 1..9 across layouts)
for i = 1, 9 do
  local code = 'code:' .. (9 + i)
  hl.bind(mod .. ' + ' .. code, hl.dsp.focus({ workspace = i }))
  hl.bind(modShift .. ' + ' .. code, hl.dsp.window.move({ workspace = i }))
end

-- Mouse
hl.bind(mod .. ' + mouse:272', hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. ' + mouse:273', hl.dsp.window.resize(), { mouse = true })

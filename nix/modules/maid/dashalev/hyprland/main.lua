local b = require('binds')

hl.config({
  general = {
    border_size = 0,
    gaps_in = 0,
    gaps_out = 0,
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
  render = {
    direct_scanout = true,
  },
  animations = {
    enabled = true,
  },
})

hl.curve('easy', { type = 'spring', mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = 'workspaces', enabled = false })
hl.animation({ leaf = 'windows', enabled = true, speed = 4.79, spring = 'easy' })
hl.animation({ leaf = 'zoomFactor', enabled = true, speed = 1.3, bezier = 'default' })

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

hl.layer_rule({
  name = 'vicinae-anim',
  match = { namespace = 'vicinae' },
  animation = 'popin 85%',
})

hl.window_rule({
  name = 'pip',
  match = { title = '(?i:^(Picture)(?:[- ]in[- ]Picture)$)' },
  float = true,
  pin = true,
  move = '(monitor_w*0.7) 0',
  size = '(monitor_w*0.3) (monitor_h*0.3)',
})

hl.window_rule({
  name = 'sushi',
  match = { class = '^org\\.gnome\\.NautilusPreviewer$' },
  float = true,
  size = '(monitor_w*0.6) (monitor_h*0.7)',
  move = 'cursor_x-(window_w/2) cursor_y-(window_h/2)',
})

hl.bind(b.mod .. ' + Return', hl.dsp.exec_cmd('footclient -D ~/media'))
hl.bind(b.mod .. ' + F2', hl.dsp.exec_cmd('hyprshot -m active -m output'))
hl.bind(b.mod .. ' + F3', hl.dsp.exec_cmd('hyprshot -m region'))
hl.bind(b.mod .. ' + F4', hl.dsp.exec_cmd('hyprshot -m window'))
hl.bind(b.mod .. ' + F5', hl.dsp.exec_cmd('hyprshot -m active -m window'))
hl.bind(b.modShift .. ' + N', hl.dsp.exec_cmd('pkill hyprsunset || hyprsunset -t 4000'))
hl.bind(
  b.modShift .. ' + C',
  hl.dsp.exec_cmd('pkill hyprpicker || hyprpicker | wl-clipboard "wl-copy"')
)
hl.bind(
  b.modShift .. ' + E',
  hl.dsp.exec_cmd('vicinae deeplink vicinae://extensions/vicinae/core/search-emojis')
)
hl.bind(
  b.modShift .. ' + R',
  hl.dsp.exec_cmd('vicinae deeplink vicinae://extensions/vicinae/core/refresh-apps')
)
hl.bind(b.mod .. ' + Space', hl.dsp.exec_cmd('vicinae toggle'))
hl.bind(
  b.mod .. ' + Tab',
  hl.dsp.exec_cmd('vicinae deeplink vicinae://extensions/vicinae/wm/switch-windows')
)

-- Media keys
hl.bind('XF86AudioPlay', hl.dsp.exec_cmd('mpc toggle'))
hl.bind('XF86AudioPrev', hl.dsp.exec_cmd('mpc prev'))
hl.bind('XF86AudioNext', hl.dsp.exec_cmd('mpc next'))

-- Session / window management
hl.bind(b.modShift .. ' + Q', hl.dsp.exit())
hl.bind(b.modShift .. ' + 0', hl.dsp.window.pin())
hl.bind(b.mod .. ' + Q', hl.dsp.window.close())
hl.bind(b.mod .. ' + F', hl.dsp.window.fullscreen({ mode = 'fullscreen' }))
hl.bind(b.mod .. ' + S', hl.dsp.window.float({ action = 'toggle' }))

-- Workspaces (physical keycodes 10..18 map to 1..9 across layouts)
for i = 1, 9 do
  local code = 'code:' .. (9 + i)
  hl.bind(b.mod .. ' + ' .. code, hl.dsp.focus({ workspace = i }))
  hl.bind(b.modShift .. ' + ' .. code, hl.dsp.window.move({ workspace = i }))
end

hl.bind(b.mod .. ' + mouse:272', hl.dsp.window.drag(), { mouse = true })
hl.bind(b.mod .. ' + mouse:273', hl.dsp.window.resize(), { mouse = true })

require('scrolling')

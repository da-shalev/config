-- Scrolling layout (PaperWM-style tape of columns).
-- Bindings follow niri's default-config.kdl conventions.
local b = require('binds')

hl.config({
  general = { layout = 'scrolling' },
  scrolling = {
    direction = 'right',
    column_width = 0.5,
    fullscreen_on_one_column = true,
    follow_focus = true,
  },
})

-- Focus: H/L = columns, J/K = within-column stack
hl.bind(b.mod .. ' + H', hl.dsp.layout('focus l'))
hl.bind(b.mod .. ' + L', hl.dsp.layout('focus r'))
hl.bind(b.mod .. ' + J', hl.dsp.focus({ direction = 'down' }))
hl.bind(b.mod .. ' + K', hl.dsp.focus({ direction = 'up' }))

-- Move
hl.bind(b.modShift .. ' + H', hl.dsp.layout('swapcol l'))
hl.bind(b.modShift .. ' + L', hl.dsp.layout('swapcol r'))
hl.bind(b.modShift .. ' + J', hl.dsp.window.swap({ direction = 'down' }))
hl.bind(b.modShift .. ' + K', hl.dsp.window.swap({ direction = 'up' }))

-- Consume / expel
hl.bind(b.mod .. ' + bracketleft', hl.dsp.layout('consume_or_expel prev'))
hl.bind(b.mod .. ' + bracketright', hl.dsp.layout('consume_or_expel next'))
hl.bind(b.mod .. ' + comma', hl.dsp.layout('consume'))
hl.bind(b.mod .. ' + period', hl.dsp.layout('expel'))

-- Column width
hl.bind(b.mod .. ' + R', hl.dsp.layout('colresize +conf'))

-- Mouse wheel: scroll the tape
hl.bind(b.mod .. ' + mouse_down', hl.dsp.layout('focus r'))
hl.bind(b.mod .. ' + mouse_up', hl.dsp.layout('focus l'))
hl.bind(b.mod .. ' + mouse_right', hl.dsp.layout('focus r'))
hl.bind(b.mod .. ' + mouse_left', hl.dsp.layout('focus l'))
hl.bind(b.modShift .. ' + mouse_down', hl.dsp.layout('swapcol r'))
hl.bind(b.modShift .. ' + mouse_up', hl.dsp.layout('swapcol l'))
hl.bind(b.modShift .. ' + mouse_right', hl.dsp.layout('swapcol r'))
hl.bind(b.modShift .. ' + mouse_left', hl.dsp.layout('swapcol l'))

-- Trackpad gestures (niri-style)
hl.gesture({ fingers = 3, direction = 'horizontal', action = 'scroll_move' })
hl.gesture({ fingers = 3, direction = 'vertical', action = 'workspace' })

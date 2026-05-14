-- Master layout.
local b = require('binds')

hl.config({
  general = { layout = 'master' },
  master = { mfact = 0.5 },
})

-- Resize master split
hl.bind(b.modShift .. ' + H', hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
hl.bind(b.modShift .. ' + L', hl.dsp.window.resize({ x = 50, y = 0, relative = true }))

-- Focus / swap within the stack
hl.bind(b.mod .. ' + J', hl.dsp.layout('cyclenext'))
hl.bind(b.mod .. ' + K', hl.dsp.layout('cycleprev'))
hl.bind(b.modShift .. ' + J', hl.dsp.layout('swapnext'))
hl.bind(b.modShift .. ' + K', hl.dsp.layout('swapprev'))

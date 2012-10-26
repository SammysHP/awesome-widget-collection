local io = io
local widget = widget
local timer = timer
local string = string

module("widgets.loadavg")

function currentLoad ()
    local lf = io.open("/proc/loadavg")
    local l = lf:read()
    lf:close()
    return string.match(l, "(%d.%d+).*")
end

function createWidget (interval)
    local w = widget({type = "textbox", align = "right" })
    w.text = currentLoad()
    local t = timer({ timeout = interval })
    t:add_signal("timeout", function() w.text = currentLoad() end)
    t:start()
    return w
end

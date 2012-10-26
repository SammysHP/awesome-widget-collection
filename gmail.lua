local io = io
local widget = widget
local timer = timer
local awful = awful

module("widgets.gmail")

local cachePath = awful.util.getdir("cache") .. "/gmailcount"

function fetchC (url, w)
    local t = timer({ timeout = 10 })
    t:add_signal("timeout", function () t:stop(); w.text = readCache() end)

    return function ()
        awful.util.spawn_with_shell("curl --connect-timeout 5 -m 9 -fs \"" .. url .. "\" > " .. cachePath)
        t:start()
    end
end

function readCache ()
    local f = io.open(cachePath)
    local count = "?"
    if f ~= nil then
        count = f:read() or "?"
        f:close()
    end
    return "✉" .. count
end

function createWidget (url, interval)
    local w = widget({ type = "textbox", align = "right" })
    local fetch = fetchC(url, w)
    fetch()
    w.text = "✉?"
    w:buttons(awful.util.table.join(
        awful.button({ }, 1, function()
            awful.util.spawn("xdg-open http://mail.google.com/")
        end)
    ))
    local t = timer({ timeout = interval })
    t:add_signal("timeout", fetch)
    t:start()
    return w
end

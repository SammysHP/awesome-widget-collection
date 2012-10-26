local io = io
local widget = widget
local timer = timer
local awful = awful

module("widgets.gmail")

local cache = awful.util.getdir("cache") .. "/gmailcount"

function spawnFetching (url)
    awful.util.spawn_with_shell("curl --connect-timeout 5 -m 10 -fs \"" .. url .. "\" > " .. cache)
end

function refreshC (url)
    return function ()
        local f = io.open(cache)
        local count = "?"
        if f ~= nil then
            count = f:read() or "?"
            f:close()
        end
        spawnFetching(url)
        return "✉" .. count
    end
end

function createWidget (url, interval)
    spawnFetching(url)
    local w = widget({ type = "textbox", align = "right" })
    local refresh = refreshC(url)
    w.text = "✉?"
    w:buttons(awful.util.table.join(
        awful.button({ }, 1, function()
            awful.util.spawn("xdg-open http://mail.google.com/")
        end)
    ))
    local t = timer({ timeout = interval })
    t:add_signal("timeout", function() w.text = refresh() end)
    t:start()
    return w
end

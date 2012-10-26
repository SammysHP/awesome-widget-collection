local io = io
local string = string
local widget = widget
local timer = timer
local awful = awful

module("widgets.volume")

function getVolumeText ()
    local fd = io.popen("amixer sget Master")
    local status = fd:read("*all")
    fd:close()
    
    local volume = string.match(status, "(%d?%d?%d)%%")

    status = string.match(status, "%[(o[^%]]*)%]")

    if string.find(status, "on", 1, true) then
        volume = "♫" .. volume
    else
        volume = "♫M"
    end
    return volume
end

function raiseVolume (w)
    awful.util.spawn("amixer -q set Master 2+ unmute")
    if w ~= nil then
        w.text = getVolumeText()
    end
end

function lowerVolume (w)
    awful.util.spawn("amixer -q set Master 2- unmute")
    if w ~= nil then
        w.text = getVolumeText()
    end
end

function toggleMute (w)
    awful.util.spawn("amixer -q set Master toggle")
    if w ~= nil then
        w.text = getVolumeText()
    end
end

function createWidget ()
    local w = widget({ type = "textbox", align = "right" })
    w.text = getVolumeText()
    w:buttons(awful.util.table.join(
        awful.button({ }, 1, function()
            awful.util.spawn("x-terminal-emulator -e alsamixer")
        end)
    ))

    local t = timer({ timeout = 30 })
    t:add_signal("timeout", function() w.text = getVolumeText() end)
    t:start()

    obj = { widget = w,
            raise = function () raiseVolume(w) end,
            lower = function () lowerVolume(w) end,
            mute = function () toggleMute(w) end
          }

    return obj
end

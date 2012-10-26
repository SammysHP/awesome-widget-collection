local io = io
local math = math
local string = string
local widget = widget
local timer = timer
local naughty = naughty
local awful = awful

local BAT_UNKNOWN = 0
local BAT_DISCHARGING = 1
local BAT_CHARGING = 2
local BAT_AC = 3

module("widgets.battery")

function get_bat_state (adapter)
    local fper = io.open("/sys/devices/platform/smapi/" .. adapter .. "/remaining_percent")
    local percent = fper:read()
    fper:close()

    local fsta = io.open("/sys/devices/platform/smapi/" .. adapter .. "/state")
    local sta = fsta:read()
    fsta:close()

    local fpow = io.open("/sys/devices/platform/smapi/" .. adapter .. "/power_avg")
    local pow = fpow:read()
    fpow:close()

    local frem = io.open("/sys/devices/platform/smapi/" .. adapter .. "/remaining_running_time")
    local rem = frem:read()
    frem:close()

    local status
    if sta:match("discharging") then
        status = BAT_DISCHARGING
    elseif sta:match("charging") then
        status = BAT_CHARGING
    else
        status = BAT_AC
    end

    return status, percent, pow, rem
end

function batclosure (adapter)
    return function ()
        local status, percent, power, rem = get_bat_state(adapter)

        local indicator
        local watt = ""
        local remaining = ""
        if status == BAT_DISCHARGING then
            indicator = "↓"
            watt = string.format(" %.2f", power / -1000) .. "W"
            remaining = string.format(" %dh%dm", rem / 60, rem % 60)
        elseif status == BAT_CHARGING then
            indicator = "↑"
        elseif status == BAT_AC then
            indicator = "AC"
            percent = ""
        else
            indicator = "?"
            percent = ""
        end

        return "⚡" .. percent .. indicator .. watt .. remaining
    end
end

function openPopup (adapter)
    local fremaining = io.open("/sys/devices/platform/smapi/" .. adapter .. "/remaining_running_time")
    local remainingMin = fremaining:read()
    fremaining:close()

    naughty.notify({
        text = string.format("%dh %dm", remainingMin / 60, remainingMin % 60 ),
        position = "top_right",
        timeout = 3,
        screen = 1,
        ontop = true
    })
end

function createWidget (adapter, interval)
    local w = widget({type = "textbox", align = "right" })
    local c = batclosure(adapter)
    w.text = c()
    --w:buttons(awful.util.table.join(
    --    awful.button({ }, 1, function () openPopup(adapter) end)
    --))
    local t = timer({ timeout = interval })
    t:add_signal("timeout", function() w.text = c() end)
    t:start()
    return w
end

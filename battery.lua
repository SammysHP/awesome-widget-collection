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
    local fcur = io.open("/sys/class/power_supply/"..adapter.."/energy_now")
    local fcap = io.open("/sys/class/power_supply/"..adapter.."/energy_full")
    local fsta = io.open("/sys/class/power_supply/"..adapter.."/status")
    local fpow = io.open("/sys/class/power_supply/"..adapter.."/power_now")
    local cur = fcur:read()
    local cap = fcap:read()
    local sta = fsta:read()
    local pow = fpow:read()
    fcur:close()
    fcap:close()
    fsta:close()
    fpow:close()

    local percent = math.floor(cur * 100 / cap)

    local status
    if sta:match("Charging") then
        status = BAT_CHARGING
    elseif sta:match("Discharging") then
        status = BAT_DISCHARGING
    else
        status = BAT_AC
    end

    return status, percent, pow
end

function batclosure (adapter)
    return function ()
        local status, percent, power = get_bat_state(adapter)

        local indicator
        local watt = ""
        if status == BAT_DISCHARGING then
            indicator = "↓"
            watt = "  " .. string.format("%.2f", power / 1000000) .. "W"
        elseif status == BAT_CHARGING then
            indicator = "↑"
        elseif status == BAT_AC then
            indicator = "AC"
            percent = ""
        else
            indicator = "?"
            percent = ""
        end

        return " ⚡" .. percent .. indicator .. watt .. " "
    end
end

function openPopup ()
    local facpi = io.popen("acpi -b")
    naughty.notify({
        text = facpi:read(),
        position = "top_right",
        timeout = 3,
        screen = 1,
        ontop = true
    })
    facpi:close()
end

function createWidget (adapter, interval)
    local w = widget({type = "textbox", align = "right" })
    local c = batclosure(adapter)
    w.text = c()
    w:buttons(awful.util.table.join(
        awful.button({ }, 1, openPopup)
    ))
    local t = timer({ timeout = interval })
    t:add_signal("timeout", function() w.text = c() end)
    t:start()
    return w
end

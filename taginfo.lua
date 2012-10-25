local widget = widget
local awful = awful

module("widgets.taginfo")

function refresh (w)
    return function (tag)
        local master = awful.tag.getnmaster(tag)
        local slave  = awful.tag.getncol(tag)
        w.text = " " .. master .. "/" .. slave .. " "
    end
end

function createWidget (screen)
    local w = widget({ type = "textbox", align = "right" })
    local callback = refresh(w)
    w.text = " -/- "
    awful.tag.attached_add_signal(screen, "property::nmaster", callback)
    awful.tag.attached_add_signal(screen, "property::ncol", callback)
    awful.tag.attached_add_signal(screen, "property::selected", callback)
    return w
end

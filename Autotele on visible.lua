local checkbox = ui.new_checkbox("AA", "Anti-aimbot angles", "Autoteleport (alles)")
local fakelag_limit = ui.reference("AA", "Fake lag", "Limit")
local dtref = {ui.reference("RAGE", "Aimbot", "Double tap")}

local function telehandle()
    local enemies = entity.get_players(enemies_only)
    local localPlayer = entity.get_local_player()
    local x1, y1, z1 = entity.get_origin(localPlayer)

    local current_threat = client.current_threat()

    if current_threat ~= nil then
        local x2, y2, z2 = entity.get_origin(current_threat)
        local fraction, _ = client.trace_line(localPlayer, x1, y1, z1, x2, y2, z2)

        if fraction >= 0.3 then
            return true
        end
    end

    return false
end

local function main(cmd)
    if not ui.get(checkbox) then
        return
    end

    if telehandle() then
        ui.set(dtref[2], "Always on")
    else
        ui.set(dtref[2], "Toggle")
    end
end

client.set_event_callback("paint", main)





local function drawfakelag()
    uiget = ui.get(fakelag_limit)
    renderer.text(1000, 500, 100, 100, 220, 255, "+", 0, ui.get(dtref[2]))
end
client.set_event_callback("paint", drawfakelag)
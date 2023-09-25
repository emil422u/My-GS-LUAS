--used for velocity calc function
local vector = require("vector")

--storing ui elements in a table to make it easier to loop over them
local menu = {
    string_1 = ui.new_label("LUA", "A", " "),
    ui.new_label("LUA", "A", "\aff3300ff  ⟝                                           ⟞ \a"),

    check_on = ui.new_checkbox("LUA", "A", "                            On", false),
    check_cond = ui.new_checkbox("LUA", "A", "                     Conditional", false),
    jitter_width = ui.new_slider("LUA", "A", "Jitter Width", 2, 180, 0, true, nil, 1, { 2, 3, 4, 5, 6, 7, 8, 9, 10 }),
    jitter_speed = ui.new_slider("LUA", "A", "jitter Speed", 2, 100, 0, true, nil, 1, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 })

}

local conds = { "Standing", "Moving", "Air" }

--loop over conditions to build ui elements instead of hardcoding
local builder = {}
for k, v in ipairs(conds) do
    builder[v] = {
        label = ui.new_label("LUA", "A", "\a4ef565ff[" .. v .. " condition] \a"),
        width = ui.new_slider("LUA", "A", "Width", 2, 180, 0, true, nil, 1, { 2, 3, 4, 5, 6, 7, 8, 9, 10 }),
        speed = ui.new_slider("LUA", "A", "Speed", 2, 100, 0, true, nil, 1, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 })
    }
end

-- references to ui elements
local refs = {
    yawJitter = ui.reference("AA", "Anti-aimbot angles", "Yaw jitter"),
    yaw = { ui.reference("AA", "Anti-aimbot angles", "Yaw") }
}

--using a string builder for clantag instead of hardcoding all clantag "values"
local base_string = "Ultimate Yaw"
local color_code = "\aff3300ff"
local index = 1
local delay = 0.3
local last_update_time = 0

local function on_net_update_end()
    if globals.realtime() - last_update_time >= delay then
        local str_len = #base_string
        if index > str_len then
            index = 1
        end

        local substring = string.sub(base_string, 1, index)
        local final_string = color_code .. " ★ " .. substring .. "| \a"
        ui.set(menu.string_1, final_string)

        index = index + 1
        last_update_time = globals.realtime()
    end
end

-- optimized get velocity function using vector lib
local function get_velocity(player)
    return vector(entity.get_prop(player, "m_vecVelocity")):length2d()
end

-- handle ui in a ui callback instead of running every "frame" (never run ui visibility on "paint" event)
local function handle_ui()
    local is_enabled = ui.get(menu.check_on)
    local is_cond = ui.get(menu.check_cond)

    ui.set_visible(menu.jitter_width, is_enabled and not is_cond)
    ui.set_visible(menu.jitter_speed, is_enabled and not is_cond)
    ui.set_visible(menu.check_cond, is_enabled)


    -- conditional handling using loops

    for k, v in pairs(conds) do
        ui.set_visible(builder[v].label, is_cond and is_enabled)
        ui.set_visible(builder[v].width, is_cond and is_enabled)
        ui.set_visible(builder[v].speed, is_cond and is_enabled)
    end
end


local function main(cmd)
    local lp = entity.get_local_player()
    if not lp or not entity.is_alive(lp) then return end

    local on_ground = bit.band(entity.get_prop(lp, "m_fFlags"), 1)
    local velocity = get_velocity(lp)


    --guard clauses to minimize nesting (this is a good practice to follow in general)
    if not ui.get(menu.check_cond) then
        local elapsed_commands = cmd.command_number % ui.get(menu.jitter_speed)
        local jitter = ui.get(menu.jitter_width)
        ui.set(refs.yaw[2], elapsed_commands <= ui.get(menu.jitter_speed) / 2 and jitter or -jitter)
    end

    local conditions = {
        Air = on_ground == 0,
        Standing = velocity <= 100,
        Moving = velocity > 100 and on_ground == 1
    }

    -- looping over all conditions and checking if they are true
    for condition, condition_state in pairs(conditions) do
        if condition_state then
            local elapsed_commands = cmd.command_number % ui.get(builder[condition].speed)
            local width = ui.get(builder[condition].width)
            ui.set(refs.yaw[2], elapsed_commands <= ui.get(builder[condition].speed) / 2 and width or -width)
            return
        end
    end
end

--callback handler to turn on/off callbacks
local function handle_callbacks()
    --ui elements are also dependant on this checkbox and since we already have a ui ballback on the main checkbox to turn on game event callbacks we can just use that.
    handle_ui()
    local update_callback = ui.get(menu.check_on) and client.set_event_callback or client.unset_event_callback

    update_callback("predict_command", main)
    update_callback("net_update_end", on_net_update_end)
end

ui.set_callback(menu.check_on, handle_callbacks)
ui.set_callback(menu.check_cond, handle_ui)
handle_callbacks()
handle_ui()

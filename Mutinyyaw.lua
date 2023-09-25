require 'bit'

local vars = {
    m1_time = 0
}
--refs
local aamain = ui.reference("AA", "Anti-aimbot angles", "Enabled")
local aamain2 = ui.reference("AA", "Anti-aimbot angles", "pitch")
local aamain4 = ui.reference("AA", "Anti-aimbot angles", "Yaw base")
local aamain5 = ui.reference("AA", "Anti-aimbot angles", "Yaw")
local aamain51 = {ui.reference("AA", "Anti-aimbot angles", "Yaw")}
local aamain6 = ui.reference("AA", "Anti-aimbot angles", "Yaw jitter")
local aamain61 = {ui.reference("AA", "Anti-aimbot angles", "Yaw jitter")}
local aamain7 = ui.reference("AA", "Anti-aimbot angles", "Body yaw")
local aamain71 = {ui.reference("AA", "Anti-aimbot angles", "Body yaw")}
local aamain8 = ui.reference("AA", "Anti-aimbot angles", "Freestanding body yaw")
local aamain9 = ui.reference("AA", "Anti-aimbot angles", "Edge yaw")
local aamain10 = ui.reference("AA", "Anti-aimbot angles", "Freestanding")
local aamain101 = {ui.reference("AA", "Anti-aimbot angles", "Freestanding")}
local aamain11 = ui.reference("AA", "Anti-aimbot angles", "Roll")


local function uisets()
    if ui.get(check_yaw) then
        --enabled off
        ui.set(aamain, false)

        ui.set_visible(aamain, false)
        ui.set_visible(aamain2, false)
        ui.set_visible(aamain4, false)
        ui.set_visible(aamain5, false)
        ui.set_visible(aamain6, false)
        ui.set_visible(aamain7, false)
        ui.set_visible(aamain8, false)
        ui.set_visible(aamain9, false)
        ui.set_visible(aamain10, false)
        ui.set_visible(aamain11, false)
        ui.set_visible(aamain51[2], false)
        ui.set_visible(aamain71[2], false)
        ui.set_visible(aamain101[2], false)
        ui.set_visible(aamain61[2], false)
    else
        ui.set_visible(aamain, true)
        ui.set_visible(aamain2, true)
        ui.set_visible(aamain4, true)
        ui.set_visible(aamain5, true)
        ui.set_visible(aamain6, true)
        ui.set_visible(aamain7, true)
        ui.set_visible(aamain8, true)
        ui.set_visible(aamain9, true)
        ui.set_visible(aamain10, true)
        ui.set_visible(aamain11, true)
        ui.set_visible(aamain51[2], true)
        ui.set_visible(aamain71[2], true)
        ui.set_visible(aamain101[2], true)
        ui.set_visible(aamain61[2], true)
    end

    if ui.get(check_customop) then
        ui.set_visible(dropdown_custom, true)
    elseif not ui.get(check_customop) then
        ui.set_visible(dropdown_custom, false)
    end
	if not ui.get(check_animation) then
		ui.set_visible(animations, false)
	elseif ui.get(check_animation) then
		ui.set_visible(animations, true)
	end


end

client.set_event_callback("paint", uisets)



local chocked_commands_mapping = {
    [0] = " ",
    [1] = "_",
    [2] = "__",
    [3] = "___",
    [4] = "____",
    [5] = "_____",
    [6] = "______",
    [7] = "_______",
    [8] = "________",
    [9] = "_________",
    [10] = "__________",
    [11] = "___________",
    [12] = "_____________",
    [13] = "_______________",
    [14] = "_________________",
    [15] = "__________________"
}

local function my_callback()
    local chockedcommands = globals.chokedcommands()
    drawntext = chocked_commands_mapping[chockedcommands]

    client.delay_call(0.05, my_callback)
end

my_callback()

local function chockedticks()
    local check_indicator_check = ui.get(check_indicator)
    if not check_indicator_check then
        return
    end

    local color = {255, 255, 255, 255}
    
    local stringlenght = string.len(drawntext)
    if stringlenght <= 6 then
        color = {0, 255, 0, 255}
    elseif stringlenght > 6 and stringlenght < 12 then
        color = {255, 0, 0, 255}
    elseif stringlenght >= 12 then
        color = {255, 255, 0, 255}
    end

    renderer.indicator(color[1], color[2], color[3], color[4], drawntext)
end

client.set_event_callback("paint", chockedticks)


-- fuckin anglecalc (for yawadd)
local threat_angle = 0  

local function get_angle_and_z_to_threat()
    local threat_entity_index = client.current_threat()

    if threat_entity_index ~= nil and threat_entity_index ~= 0 then
        local x, y, z = entity.get_origin(threat_entity_index)
        
        if x and y then
            local local_player_index = entity.get_local_player()
            local local_x, local_y, local_z = entity.get_origin(local_player_index)
            
            local delta_x = x - local_x
            local delta_y = y - local_y
            
            threat_angle = math.deg(math.atan2(delta_y, delta_x))  
            local z_distance = z - local_z
            
            return threat_angle, z_distance
        end
    end
    
    threat_angle = nil  
    return nil, nil
end


-- lav yaw movement bredere når movement speed er ???
local function yawaddition(cmd)
    local threat_angle, threat_z = get_angle_and_z_to_threat()
    
    if not ui.get(check_yaw) or threat_angle == nil then
        return
    end
    -- Grenade fix
    local local_player_index = entity.get_local_player()
    local weapon_entindex = entity.get_player_weapon(local_player_index)

    if cmd.in_attack or cmd.in_attack2 then
        local weapon_classname = entity.get_classname(weapon_entindex)
        if weapon_classname and weapon_classname:find("Grenade") then
            return
        end
    end
    
    
    -- Fast ladder (up)
    local move_type = entity.get_prop(local_player_index, "m_MoveType")
    if move_type == 9 then
        cmd.yaw = math.floor(cmd.yaw + 0.5)
        cmd.roll = 0

        if cmd.forwardmove > 0 then
            local pitch, yaw = client.camera_angles()
            if pitch < 45 then
                cmd.pitch = 89
                cmd.in_moveright = 1
                cmd.in_moveleft = 0
                cmd.in_forward = 0
                cmd.in_back = 1

                if cmd.sidemove == 0 then
                    cmd.yaw = cmd.yaw + 90
                end
                if cmd.sidemove > 0 then
                    cmd.yaw = cmd.yaw + 30
                end
            end
        end
    else
        -- Freakyaw normal settings
        local elapsed_commands_yaw = cmd.command_number % 8
        threat_angle = threat_angle + 180
        if elapsed_commands_yaw <= 2 then
            ui.set(aamain, true)
        elseif elapsed_commands_yaw <= 4 then
            ui.set(aamain, false)
            cmd.pitch = 90
            cmd.yaw = threat_angle - 30
        elseif elapsed_commands_yaw <= 6 then
            ui.set(aamain, true)
        else
            ui.set(aamain, false)
            cmd.pitch = 90
            cmd.yaw = threat_angle + 30
        end
    end
end
client.set_event_callback("setup_command", yawaddition)


-- custom section
string_custom2 = ui.new_label("AA", "Anti-aimbot angles", "\n")
string_custom1 = ui.new_label("AA", "Anti-aimbot angles", "\afe7FFFF ★ Mutiny skeet upgrade \a")
string_custom = ui.new_label("AA", "Anti-aimbot angles", "\n")
check_customop = ui.new_checkbox("AA", "Anti-aimbot angles", "\afe7FFFF ➩ \af7f2f2FFAA MODIFIER")
local dropdown_items = {"3 way jitter", "5 way jitter", "Ultra aggresive"}
check_forcedefensive = ui.new_checkbox("AA", "Anti-aimbot angles", "Force defensive")
dropdown_custom = ui.new_combobox("AA", "Anti-aimbot angles", "\afe7FFFF ↪ \af7f2f2FFcustom modes", dropdown_items)

-- end
-- vector library
local vector = require('vector')

-- text for the indicator, change it if u want
local indicator_text = 'Sigma peek'

local allowed_hitscan = {0, 2, 4, 5, 7, 8}
local hitscan = allowed_hitscan
local prev_data = {}
local tmp_pos, count = 1
local start_pos, cur_target, did_shoot
local should_return = false

local hitscan_to_hitboxes = {
	['head'] = {0}, -- neck=1 but we wont use it cuz aimbot wont shoot neck. at least not if i play on hs only servers
	['chest'] = {2, 3, 4},
	['stomach'] = {5, 6},
	['arms'] = {13, 14, 15, 16, 17, 18}, 
	['legs'] = {7, 8, 9, 10}, 
	['feet'] = {11, 12}
}

local hitgroup_data = {
	['Head'] = 1,
	['Neck'] = 8,
	['Pelvis'] = 2,
	['Spine 4'] = 3,
	['Spine 3'] = 3,
	['Spine 2'] = 3,
	['Spine 1'] = 3,
	['Leg Upper L'] = 6,
	['Leg Upper R'] = 7,
	['Leg Lower L'] = 6,
	['Leg Lower R'] = 7,
	['Foot L'] = 6,
	['Foot R'] = 7,
	['Hand L'] = 4,
	['Hand R'] = 5,
	['Arm Upper L'] = 4,
	['Arm Upper R'] = 5,
	['Arm Lower L'] = 4,
	['Arm Lower R'] = 5
}

local hitboxes_num2text = {
	[0] = 'Head',
	[1] = 'Neck',
	[2] = 'Pelvis',
	[3] = 'Spine 4',
	[4] = 'Spine 3',
	[5] = 'Spine 2',
	[6] = 'Spine 1',
	[7] = 'Leg Upper L',
	[8] = 'Leg Upper R',
	[9] = 'Leg Lower L',
	[10] = 'Leg Lower R',
	[11] = 'Foot L',
	[12] = 'Foot R',
	[13] = 'Hand L',
	[14] = 'Hand R',
	[15] = 'Arm Upper L',
	[16] = 'Arm Upper R',
	[17] = 'Arm Lower L',
	[18] = 'Arm Lower R',
}

-- ui referenceseses
local refs = {
	mindmg = ui.reference('RAGE', 'Aimbot', 'Minimum damage'),
	target_hitbox = ui.reference('RAGE', 'Aimbot', 'Target hitbox'),
	menu_color = ui.reference('MISC', 'Settings', 'Menu color')
}

-- options for the multiselect ui object
local options_t = {
	'Allow limbs',
	'Indicator',
	'Draw trace',
    "Doubletap on peek"
}

local menu_color = {ui.get(refs.menu_color)}



-- new ui objects or elemenst idk how u wanna call it

local enabled = ui.new_checkbox("AA", "Anti-aimbot angles", "\afe7FFFF ➩ \af7f2f2FFSigma peek-assist")
local ui_obj = {
	peek_key = ui.new_hotkey("AA", "Anti-aimbot angles", "On key", true),
	options = ui.new_multiselect("AA", "Anti-aimbot angles", "\afe7FFFF ↪ \af7f2f2FFPeek-assist options", options_t),
	max_dist = ui.new_slider("AA", "Anti-aimbot angles", "Max peek distance", 30, 300, 45, true, 'u'),
	steps = ui.new_slider("AA", "Anti-aimbot angles", "Trace steps", 1, 100, 10, true, 'u'),
	proc_speed = ui.new_slider("AA", "Anti-aimbot angles", "Process update rate", 0, 10, 0, true, 's', 0.01),
	color = ui.new_color_picker("AA", "Anti-aimbot angles", "Indicator color", menu_color[1], menu_color[2], menu_color[3])
}


-- min egen
local doubletap_ref_1 = {ui.reference("RAGE", "Aimbot", "Double tap")}

-- Function to check if "Doubletap on peek" is enabled and peek key is pressed
local function checkDoubletapOnPeek()
    -- Check if the peek key is pressed
    local isPeekKeyActive = ui.get(ui_obj.peek_key)

    -- Get the selected options in the multiselect
    local selectedOptions = ui.get(ui_obj.options)

    -- Check if "Doubletap on peek" is in the selected options and peek key is active
    local isDoubletapEnabled = false
    if isPeekKeyActive then
        for _, option in ipairs(selectedOptions) do
            if option == "Doubletap on peek" then
                isDoubletapEnabled = true
                break
            end
        end
    end

    if isDoubletapEnabled then
        ui.set(doubletap_ref_1[2], "Always on")
    else
        ui.set(doubletap_ref_1[2], "Toggle")
    end
end

-- Register the function to be called when the paint event occurs
client.set_event_callback("paint", checkDoubletapOnPeek)


-- Register the function to be called when the paint event occurs
client.set_event_callback("paint", checkDoubletapOnPeek)

-- slut min egen
-- Utility functions
local function table_contains(t, val)
	if not t or not val then
		return false
	end
	for i=1,#t do
		if t[i] == val then
			return true
		end
	end
	return false
end

local function table_queue( t, v, max )
	for i = max, 1, -1 do
		if( t[ i ] ~= nil ) then
			t[ i + 1 ] = t[ i ]
		end
	end

	t[ 1 ] = v
	return t
end
  
local function math_clamp(x, min, max)
	return math.min(math.max(min, x), max)
end

local function math_round(num, decimals)
	num = num or 0
	local mult = 10 ^ (decimals or 0)
	return math.floor(num * mult + 0.5) / mult
end

local function math_between(v, min, max)
	return (v and min and max) and (v > min and v < max) or false
end

local function degree_to_radian(degree)
	return (math.pi / 180) * degree
end

-- angle to vector calculation function i stole from my mom
local function AngleToVector (x, y)
	local pitch = degree_to_radian(x)
	local yaw = degree_to_radian(y)
	return math.cos(pitch) * math.cos(yaw), math.cos(pitch) * math.sin(yaw), -math.sin(pitch)
end

local client, o_trace_bullet, o_trace_line = client, client.trace_bullet, client.trace_line
local trace_cache = {
	bullet = {},
	line = {},
	line_cache = {},
	bullet_cache = {}
}

-- trace_line hook to crack luas
function client.trace_line(skip_entindex, from_x, from_y, from_z, to_x, to_y, to_z, name)
	-- for remembering and reusing trace results, which is stupit cuz trace_line drops close to 0 performance
	local cache_n = from_x..' '..from_y..' '..from_z..' '..to_x..' '..to_y..' '..to_z
	
	-- check if same trace was already made before and return the data in the table
	if trace_cache.line_cache[cache_n] then
		return trace_cache.line_cache[cache_n][1], trace_cache.line_cache[cache_n][2]
	end

	-- trace the line
	local frac, idx = o_trace_line(skip_entindex, from_x, from_y, from_z, to_x, to_y, to_z)
	
	-- store the trace data
	trace_cache.line_cache[cache_n] = {frac, idx}
	
	-- for drawing the trace lines 
	table_queue( trace_cache.line, {from = vector( from_x, from_y, from_z ), to = vector( to_x, to_y, to_z ), name = name or '', fraction = math_round(frac, 3)}, 1 )
	return frac, idx
end

function client.trace_bullet(from_player, from_x, from_y, from_z, to_x, to_y, to_z, skip_players, name)
	local idx, dmg = o_trace_bullet(from_player, from_x, from_y, from_z, to_x, to_y, to_z, skip_players)
	
	-- for drawing the damage traces 
	table_queue( trace_cache.bullet, {from = vector( from_x, from_y, from_z ), to = vector( to_x, to_y, to_z ), name = name or '', damage = dmg}, 1 )
	return idx, dmg
end

-- returns true if the entity is able to shoot, else it returns false
local function can_shoot(ent)
	ent = ent or entity.get_local_player()	
	local active_weapon = entity.get_prop(ent, "m_hActiveWeapon")
	local nextAttack = entity.get_prop(active_weapon, "m_flNextPrimaryAttack")
	return globals.curtime() >= nextAttack
end

-- make local player move to the given position
local function set_movement(cmd, desired_pos)
    local local_player = entity.get_local_player()
	local vec_angles = {
		vector(
			entity.get_origin( local_player )
		):to(
			desired_pos
		):angles()
	}

    local pitch, yaw = vec_angles[1], vec_angles[2]

    cmd.in_forward = 1
    cmd.in_back = 0
    cmd.in_moveleft = 0
    cmd.in_moveright = 0
    cmd.in_speed = 0
    cmd.forwardmove = 800
    cmd.sidemove = 0
    cmd.move_yaw = yaw
end


-- update the allowed hitscan if option allow limbs changed
local function update_allowed_hitscan(obj)
	local options = ui.get(obj)
	local limbs_allowed = table_contains(options, 'Allow limbs')

	-- i keep the commented out values just as an bridge of thought
	allowed_hitscan = (
		limbs_allowed and
		{0, --[[1, no neck. remember?]] 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18} or
		{0, --[[1, still no neck]] 2, --[[3,]] 4, 5, --[[6,]] 7, 8,--[[ 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]]}
	)
end
ui.set_callback(ui_obj.options, update_allowed_hitscan)

-- update the hitscan if target hitbox settings changed
local function update_hitscan(obj)
	local t_hitscan = {}
	local target_hitboxes = ui.get(obj)

	-- loop through all enabled target hitboxes
	for i=1, #target_hitboxes do
		local hitbox_t = hitscan_to_hitboxes[target_hitboxes[i]:lower()]

		-- store all hitbox numbers in an temporary table
		for i2=1, #hitbox_t do
			local hitbox = hitbox_t[i2]

			if table_contains(allowed_hitscan, hitbox) then
				table.insert(t_hitscan, hitbox)
			end
		end
	end
	
	-- set the hitscan
	hitscan = t_hitscan
end
ui.set_callback(refs.target_hitbox, update_hitscan)

update_hitscan( refs.target_hitbox )

local function handle_trace(ent, left_x, left_y, right_x, right_x, right_y, lp_eye_pos, dist)
	dist = dist or 1
	count = count or 1

	local max_dist = ui.get(ui_obj.max_dist)

	-- stop if trace distance reached max distance and reset
	if dist > max_dist then
		tmp_pos = nil
	    prev_data = {}
		return
	end              
		
	local local_player = entity.get_local_player()

	-- currently traced hitbox
	local cur_hitbox = hitscan[count]
	
	-- target hitbox position
	local enemy_hitbox = vector( entity.hitbox_position( ent, cur_hitbox ) )
	
	-- set the next traced hitbox
	count = count < #hitscan and count + 1 or 1
	
	local eye_left = vector( left_x * dist + lp_eye_pos.x, left_y * dist + lp_eye_pos.y, lp_eye_pos.z )	-- calculation for the position to your left
	local eye_right = vector( right_x * dist + lp_eye_pos.x, right_y * dist + lp_eye_pos.y, lp_eye_pos.z )-- calculation for the position to your left

	-- trace the fraction of your left and right to prevent tracing points starting inside a wall
	local fraction_l, _entindex = client.trace_line( local_player, lp_eye_pos.x, lp_eye_pos.y, lp_eye_pos.z, eye_left.x, eye_left.y, eye_left.z )		-- fraction from your eye position to the left
	local fraction_r, _entindex2 = client.trace_line( local_player, lp_eye_pos.x, lp_eye_pos.y, lp_eye_pos.z, eye_right.x, eye_right.y, eye_right.z )	-- fraction from your eye position to the right
	
	-- there has to be an reason why i did this trace...
	-- oh god, alzheimer kicks in... what is this? where am i? hello? yes, this is hello... or is it? idk i am retarted
	local frac_l_to_ent, entindex = client.trace_line( local_player, eye_left.x, eye_left.y, eye_left.z, enemy_hitbox.x, enemy_hitbox.y, enemy_hitbox.z )		-- fraction from your left side to the target entity
	local frac_r_to_ent, entindex2 = client.trace_line( local_player, eye_right.x, eye_right.y, eye_right.z, enemy_hitbox.x, enemy_hitbox.y, enemy_hitbox.z )	-- fraction from your right side to the target entity

	-- get the possible damage from your left and right
	local _, dmg_l = client.trace_bullet( local_player, eye_left.x, eye_left.y, eye_left.z, enemy_hitbox.x, enemy_hitbox.y, enemy_hitbox.z )		-- damage from your left side to the target entity hitbox
	local _, dmg_r = client.trace_bullet( local_player, eye_right.x, eye_right.y, eye_right.z, enemy_hitbox.x, enemy_hitbox.y, enemy_hitbox.z )	-- damage from your right side to the target entity hitbox
	
	-- convert hitbox number to hitbox name
	local hitbox_name = hitboxes_num2text[cur_hitbox]

	-- get the hitgroup of the hitbox
	local hitgroup = hitgroup_data[hitbox_name]
	
	-- adjust the damage for the hitgroup
	dmg_l = client.scale_damage(ent, hitgroup, dmg_l)
	dmg_r = client.scale_damage(ent, hitgroup, dmg_r)
	
	local mindmg = ui.get(refs.mindmg)

	if fraction_l == 1 and dmg_l >= mindmg  then
		tmp_pos = eye_left
	    prev_data = {}
		return
	else
		prev_data.left = eye_left
	end

	if fraction_r == 1 and dmg_r >= mindmg then
	   tmp_pos = eye_right
	   prev_data = {}
	   return
	else
		prev_data.right = eye_right
	end
	
	-- check if it tracing should continue on the next distance
	if (fraction_l == 1 or fraction_r == 1) and (frac_l_to_ent < 1 and frac_r_to_ent < 1) and (entindex ~= ent and entindex2 ~= ent) and (dmg_r < mindmg and dmg_l < mindmg) then
		
		-- delay call for the next trace with and distance increase of default: 10 units
		-- less distance increment is finer but slower tracing and more increment is the opposite
		client.delay_call(ui.get( ui_obj.proc_speed ) / 100, handle_trace, ent, left_x, left_y, right_x, right_x, right_y, lp_eye_pos, dist + ui.get( ui_obj.steps ))
	else
		prev_data = {}
	end
end

local function do_return( cmd )
	-- check if player should return to start position
	if start_pos and should_return then
		local m_vecOrigin_lp = vector( entity.get_origin( entity.get_local_player() ) )
		if start_pos:dist2d( m_vecOrigin_lp ) > 5 then
			set_movement( cmd, start_pos )
		else
			should_return = false
		end
	end
end

local function on_setup_command(cmd)
	if not ui.get(enabled) or not ui.get(ui_obj.peek_key) then
		should_return = false
		tmp_pos = nil
		start_pos = nil
	    prev_data = {}
		return
	end

	local local_player = entity.get_local_player()

	-- check if local player is alive
	if not entity.is_alive(local_player) then
		prev_data = {}	
		tmp_pos = nil
	   return
	end

	-- i use current_threat so we wont need to loop through all players and calculate the best target
	local ent = client.current_threat()
	
	-- as an backup to prevent target switch while peeking
	cur_target = cur_target or ent

	-- check if the target can be switched and set to new target if so
	cur_target = cur_target ~= ent and ((not tmp_pos or should_return) and ent or cur_target) or cur_target
	
	-- set ent to cur_target just cuz i am to lazy to change ent to cur_target. which i could have done while writing this comment like an schizophrenic.
	ent = cur_target

	-- check if target exists and is alive
	if not ent or not entity.is_alive(ent) then
		-- return to start pos
		return do_return( cmd )
	end

	local m_vecOrigin_lp = vector(entity.get_origin( local_player ))
	local m_vecOrigin_enemy = vector(entity.get_origin( ent ))

	start_pos = start_pos or m_vecOrigin_lp

	local lp_eye_pos = vector( client.eye_position() )
	
	local vec2enemy_x, vec2enemy_y = lp_eye_pos.x - m_vecOrigin_enemy.x, lp_eye_pos.y - m_vecOrigin_enemy.y
	local ang2enemy = math.atan2( vec2enemy_y, vec2enemy_x ) * ( 180 / math.pi )
	
	local vec2enemy_x2, vec2enemy_y2 = lp_eye_pos.x - m_vecOrigin_enemy.x, lp_eye_pos.y - m_vecOrigin_enemy.y
	local ang2enemy2 = math.atan2( vec2enemy_y2, vec2enemy_x2 ) * ( 180 / math.pi )
	
	local left_x, left_y, left_z = AngleToVector( 0, ang2enemy - 90 )
	local right_x, right_y, right_z = AngleToVector( 0, ang2enemy + 90 )

	-- can u?
	local can_shit = can_shoot()

	should_return = can_shit and false or should_return

	-- check if trace handeling function should be called
	if not prev_data.left and not prev_data.right and not tmp_pos then	
		handle_trace( ent, left_x, left_y, right_x, right_x, right_y, lp_eye_pos )
	end

	-- if shot fired, the peek was successful and the player should return
	if did_shoot then
		should_return = true
		did_shoot = false
		prev_data = {}	
		tmp_pos = nil
	end
	
	if tmp_pos then
		local move_dist = tmp_pos:dist2d( m_vecOrigin_lp )

		-- as long the player can shoot and is far from the goal, the player should move to the goal
		if move_dist > 5 and can_shit then
			should_return = false
			set_movement( cmd, tmp_pos )
		else
			should_return = true
			tmp_pos = nil
		end
	end

	-- check if player should return to start position
	do_return( cmd )
end	

local function draw_trace_lines(color)
	if not ui.get(enabled) or not ui.get(ui_obj.peek_key) then
		return
	end

	local options = ui.get( ui_obj.options )
	
	if table_contains(options, 'Indicator') then
		local r, g, b, a = ui.get(ui_obj.color)
		renderer.indicator(r, g, b, a, indicator_text)
	end

	if not table_contains(options, 'Draw trace') then
		return
	end

	for i=1, #trace_cache.bullet do
		local from = trace_cache.bullet[i]['from']
		local to = trace_cache.bullet[i]['to']
		local name = trace_cache.bullet[i]['name']
		local dmg = trace_cache.bullet[i]['damage']
		
		local scr_from_x, scr_from_y = renderer.world_to_screen( from.x, from.y, from.z )
		local scr_to_x, scr_to_y = renderer.world_to_screen( to.x, to.y, to.z )

		if scr_from_x and scr_from_y and scr_to_x and scr_to_y then
			renderer.line( scr_from_x, scr_from_y, scr_to_x, scr_to_y, math_clamp( 200 + dmg, 0, 255 ), math_clamp( 255 - dmg, 0, 255 ), math_clamp( 100 - dmg, 0, 255 ), 255 )
			renderer.text( scr_from_x + 20, scr_from_y + 20, math_clamp( 200 + dmg, 0, 255 ), math_clamp( 255 - dmg, 0, 255 ), math_clamp( 100 - dmg, 0, 255 ), 255, 'c', 0, dmg )
		end
	end

end

-- set start position on key press
local key_pressed
ui.set_callback( ui_obj.peek_key, function(obj)
	local key_press = ui.get(obj)
	key_pressed = key_pressed and not key_press and false or key_pressed
	
	if key_pressed then
		return
	end

	key_pressed = true
	start_pos = vector( entity.get_origin( entity.get_local_player() ) )
	should_return = false
	did_shoot = false
	prev_data = {}	
	tmp_pos = nil
end )

-- do things if player spawned
local function on_player_spawn( e )
	local ent = client.userid_to_entindex( e.userid )
	local local_player = entity.get_local_player()
	
	
	if ent == local_player then
		-- update the hitscan if local player is spawned
		update_hitscan( refs.target_hitbox )
		
		-- reset the trace cache
		trace_cache = {
			bullet = {},
			line = {},
			line_cache = {},
			bullet_cache = {}
		}
	end
end

-- do things if an weapon is fired
local function on_weapon_fire( e )
	local ent = client.userid_to_entindex( e.userid )
	local local_player = entity.get_local_player()
	
	-- did the local player shoot?
	should_return = ent == local_player and true or should_return
	did_shoot = ent == local_player
	tmp_pos = nil
end

-- set ui object invisible/visible
local function ui_obj_visibility(param)
	local succ, val = pcall(ui.get, type(param) == 'boolean' and enabled or param)
	param = not succ and param or (val)
	
	-- set or unset the event callbacks depending on if the checkbox is enabled or disabled
	local handle_event_callback = param and client.set_event_callback or client.unset_event_callback
	
	-- gs events
	handle_event_callback( 'paint', draw_trace_lines )
	handle_event_callback( 'setup_command', on_setup_command )	
	
	-- game events
	handle_event_callback( "weapon_fire", on_weapon_fire )
	handle_event_callback( "player_spawn", on_player_spawn )
	
	for k, v in pairs(ui_obj) do
		ui.set_visible(v, param)
	end
end
ui_obj_visibility(false)
ui.set_callback(enabled, ui_obj_visibility)

-- mutiny section
local string_aa2 = ui.new_label("AA", "Anti-aimbot angles", "\afe7FFFF  ⟝                                           ⟞ \a")
check_yaw = ui.new_checkbox("AA", "Anti-aimbot angles", "Mutiny | Yaw [custom packets, WIP]")
check_pitch = ui.new_checkbox("AA", "Anti-aimbot angles", "Mutiny | Pitch [Optimal pitch onshot]")
check_fakelag = ui.new_checkbox("AA", "Anti-aimbot angles", "Mutiny | Lag [Otimal interpolation manipulation]")

-- pitch addition

local function pitchaddition(cmd)
    if not ui.get(check_pitch) then
        return
    end
    cmd.pitch = -90
    client.unset_event_callback("setup_command", pitchaddition)
end

local function shootgrab()
    if not ui.get(check_pitch) then
        return
    end
    client.set_event_callback("setup_command", pitchaddition)
end

client.set_event_callback("aim_fire", shootgrab)


-- visual sexction
local string_visual = ui.new_label("AA", "Anti-aimbot angles", "\afe7FFFF  ⟝                                           ⟞ \a")
check_indicator = ui.new_checkbox("AA", "Anti-aimbot angles", "Chocked-ticks indicator")
check_indi_freaked = ui.new_checkbox("AA", "Anti-aimbot angles", "Freaked yaw indicator")
check_drawresolve = ui.new_checkbox("AA", "Anti-aimbot angles", "Draw resolved opponent")
local dmg_ind = ui.new_checkbox("AA", "Anti-aimbot angles", "Min dmg indicator")
local color = ui.new_color_picker("AA", "Anti-aimbot angles", 255, 255, 255, 255)
check_killeffect = ui.new_checkbox("AA", "Anti-aimbot angles", "Kill effect")
check_clantag = ui.new_checkbox("AA", "Anti-aimbot angles", "Mutiny Tag")


-- fakelag addition
local fakelag_enabled = ui.reference("AA", "Fake lag", "Enabled")
local fakelag_limit = ui.reference("AA", "Fake lag", "Limit")

local function fladd(cmd)
    if not ui.get(check_fakelag) then  
        return
    end
    if not ui.get(fakelag_enabled) then
        ui.set(fakelag_enabled, true)
    end
    --logic
    local elapsed_commands_fakelag = cmd.command_number % 25
    if elapsed_commands_fakelag <= 5 then
        ui.set(fakelag_limit, 14)
    elseif elapsed_commands_fakelag <= 13 then  
        ui.set(fakelag_limit, 15)  
    elseif elapsed_commands_fakelag <= 25 then
        ui.set(fakelag_limit, 1)
    end
end
client.set_event_callback("setup_command", fladd)




-- menu addition, freakyaw mark



client.set_event_callback("paint", function()
    local menuopen = ui.is_menu_open()
    local px, py = ui.menu_position()
    local sx, sy = ui.menu_size()

    local tick_count = globals.tickcount()
    local r = math.floor(127 + 127 * math.sin(tick_count * 0.01))  
    local g = math.floor(127 + 127 * math.sin(tick_count * 0.01 + 2)) 
    local b = math.floor(127 + 127 * math.sin(tick_count * 0.01 + 4)) 

    if not menuopen then
        return
    end
    -- menu shadow
    renderer.rectangle(px - 10, py - 30, sx + 20, sy + 37, 70, 70, 70, 100)

    -- wm bar
    renderer.rectangle(px, py - 20, sx, sy, 15, 15, 15, 120)

    local local_player_index = entity.get_local_player()
    local local_player_name = entity.get_player_name(local_player_index)

    local top_text = "Mutiny - developer version │ " .. local_player_name 
    local top_text_x = px + sx / 2 - renderer.measure_text(nil, top_text) / 2
    local top_text_y = py - 18

    renderer.text(top_text_x, top_text_y, r, g, b, 255, "b", 0, top_text)
end)





-- killeffect

local refkill = ui.reference("AA", "Anti-aimbot angles", "Kill effect")
local lpModelRef = {ui.reference("VISUALS", "Colored models", "Local player")}
local cr, cg, cb, ca = ui.get(lpModelRef[2])

local function onPlayerDeath(e)
    local isonkill = ui.get(refkill) 
    if not isonkill then
        return
    end
    local lpIndex = entity.get_local_player()
    local killerIndex = client.userid_to_entindex(e.attacker)

    if killerIndex == lpIndex then
        ui.set(lpModelRef[1], true)
        ui.set(lpModelRef[2], 255, 50, 10, 255)
        client.delay_call(0.9, function()
            ui.set(lpModelRef[2], cr, cg, cb, ca)
        end)
    end
end

client.set_event_callback("player_death", onPlayerDeath)







-- minddmg indicator
local ref_mindmg = ui.reference( "rage" , "aimbot" , "Minimum damage" ) 
local ovr_checkbox , ovr_hotkey , ovr_value =  ui.reference( "rage" , "aimbot" , "Minimum damage override" ) 
local client_screen_size = client.screen_size
local renderer_text = renderer.text

client.set_event_callback('paint', function()
    local player_dude_self = entity.get_local_player()
    local alive_is = entity.is_alive(player_dude_self)
    if not ui.get(dmg_ind) or not alive_is then return end
    local w, h = client_screen_size()
    local center_x, center_y = w / 2, h / 2
    local red, green, blue, alpha = ui.get(color)

    if ui.get(ovr_checkbox) and ui.get(ovr_hotkey)  then
        renderer_text(center_x + 25, center_y - 15, red, green, blue, alpha, "c", 0, ui.get(ovr_value))
    else
        renderer_text(center_x + 25, center_y - 15, red, green, blue, alpha, "c", 0, ui.get(ref_mindmg))
    end
end)


--freaked yaw indicator
local freakyaw_ref = ui.reference("AA", "Anti-aimbot angles", "Freaked yaw indicator")
local show_first_indicator = true
local indicator_duration = 0.7  -- Adjust this duration as needed
local last_switch_time = 0

local function freakedyaw()
    if not ui.get(freakyaw_ref) then
        return
    end
    local current_time = globals.realtime()

    -- Check if it's time to switch indicators
    if current_time - last_switch_time >= indicator_duration then
        show_first_indicator = not show_first_indicator
        last_switch_time = current_time
    end
end

client.set_event_callback("paint", freakedyaw)

local function draw_indicators()
    if not ui.get(freakyaw_ref) then
        return
    end
    if not ui.get(check_yaw) then
        return
    end

    if show_first_indicator then
        renderer.indicator(255, 0, 100, 255, "FREAKED YAW")
    else
        renderer.indicator(255, 0, 100, 100, "FREAKED YAW")
    end
end

client.set_event_callback("paint_ui", draw_indicators)





local function customaamain(cmd)
    local customdropref = ui.reference("AA", "Anti-aimbot angles", "\afe7FFFF ↪ \af7f2f2FFcustom modes")

    if not ui.get(check_customop) then
        return
    end
    -- needs

    if ui.get(customdropref) == "3 way jitter" then
        ui.set(aamain6, "Off")
        ui.set(aamain5, "180")
        local elapsedcoms_customyaw = cmd.command_number % 4
        if elapsedcoms_customyaw ==1 then
            ui.set(aamain51[2], 0)
        elseif elapsedcoms_customyaw ==2 then
            ui.set(aamain51[2], 40)
        elseif elapsedcoms_customyaw ==3 then
            ui.set(aamain51[2], -40)
        end
    end
    if ui.get(customdropref) == "5 way jitter" then
        ui.set(aamain6, "Off")
        ui.set(aamain5, "180")
        local elapsedcoms_customyaw2 = cmd.command_number % 5
        local value
    
        if elapsedcoms_customyaw2 == 0 then
            value = 0
        elseif elapsedcoms_customyaw2 == 1 then
            value = 20
        elseif elapsedcoms_customyaw2 == 2 then
            value = -20
        elseif elapsedcoms_customyaw2 == 3 then
            value = 40
        elseif elapsedcoms_customyaw2 == 4 then
            value = -40
        end
    
        ui.set(aamain51[2], value)    
    end
    if ui.get(customdropref) == "Ultra aggresive" then
        ui.set(aamain5, "Spin")
        ui.set(aamain51[2], -176)
        ui.set(aamain6, "Center")
        ui.set(aamain61[2], -50)
    end

end

client.set_event_callback("setup_command", customaamain)


-- Clan tag
local tag = {
    "M|", "Mu|", "Mut|", "Muti|", "Mutin|", "Mutiny|", "Mutiny|", "Mutiny.|", "Mutiny.p|", "Mutiny.pw|", "Mutiny.pw", "Mutiny.pw", ""
}
local index = 1
local delay = 0.7
local last_update_time = 0

function update_clantag()

    if index > #tag then
        index = 1
    end
    client.set_clan_tag(tag[index])
    index = index + 1
    last_update_time = globals.realtime()
end

function on_net_update_end()
	if not ui.get(check_clantag) then
		client.set_clan_tag("")
	elseif ui.get(check_clantag) and globals.realtime() - last_update_time >= delay then
        update_clantag()
    end
end

-- Register the net update end callback

-- hitthing
client.set_event_callback("net_update_end", on_net_update_end)






local hitgroup_names = {"generic", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear"}

local function aim_fire(e)
    local flags = {
        e.teleported and "T" or "",
        e.interpolated and "I" or "",
        e.extrapolated and "E" or "",
        e.boosted and "B" or "",
        e.high_priority and "H" or ""
    }

    local group = hitgroup_names[e.hitgroup + 1] or "?"
    print(string.format(
        "Fired at %s (%s) for %d dmg (chance=%d%%, bt=%2d, flags=%s)",
        entity.get_player_name(e.target), group, e.damage,
        math.floor(e.hit_chance + 0.5), toticks(e.backtrack),
        table.concat(flags)
    ))
end

client.set_event_callback("aim_fire", aim_fire)
-- hitthing end


-- start new seciotn
local string_aa7 = ui.new_label("AA", "Anti-aimbot angles", "\afe7FFFF  ⟝                                           ⟞ \a")



-- ANIMATION BREAKS
check_animation = ui.new_checkbox("AA", "Anti-aimbot angles", "Fake Animations")
local dropdown_items_anim = {"Static legs", "Zero pitch on hop"}
animations = ui.new_multiselect("AA", "Anti-aimbot angles", "Anim breakers", dropdown_items_anim)
animation_ref = ui.reference("AA", "Anti-aimbot angles", "Anim breakers")
local fakelag = ui.reference("AA", "Fake lag", "Limit")
local ground_ticks, end_time = 1, 0

client.set_event_callback("pre_render", function()
    if not ui.get(check_animation) then
        return
    end

    -- Check if "Static legs" is in the selected options
    local selected_options = ui.get(animation_ref)
    if selected_options then
        for _, option in ipairs(selected_options) do
            if option == "Static legs" then
                entity.set_prop(entity.get_local_player(), "m_flPoseParameter", 1, 6)
                break
            end
        end
    end

    if entity.is_alive(entity.get_local_player()) then
        -- Check if "Zero pitch on hop" is in the selected options
        if selected_options then
            for _, option in ipairs(selected_options) do
                if option == "Zero pitch on hop" then
                    local on_ground = bit.band(entity.get_prop(entity.get_local_player(), "m_fFlags"), 1)

                    if on_ground == 1 then
                        ground_ticks = ground_ticks + 1
                    else
                        ground_ticks = 0
                        end_time = globals.curtime() + 1
                    end

                    if ground_ticks > ui.get(fakelag) + 1 and end_time > globals.curtime() then
                        entity.set_prop(entity.get_local_player(), "m_flPoseParameter", 0.5, 12)
                    end
                    break
                end
            end
        end
    end
end)


-- floating indis
local ui = _G["ui"]
local ui_new_checkbox, ui_new_color_picker, ui_get, ui_set_callback = ui.new_checkbox, ui.new_color_picker, ui.get, ui.set_callback
local renderer = _G["renderer"]
local renderer_gradient, renderer_text, renderer_measure_text = renderer.gradient, renderer.text, renderer.measure_text
local client = _G["client"]
local client_set_event_callback, client_unset_event_callback = client.set_event_callback, client.unset_event_callback
local main = ui_new_checkbox("VISUALS", "Other ESP", "Enable floating indicators")
local override = ui_new_checkbox("VISUALS", "Other ESP", "Enable Custom color")
local override_color = ui_new_color_picker("VISUALS", "Other ESP", "override_indicator_color", 0, 150, 255, 225)
local indicators = {}
local function rendery(x,startingy,r,g,b,a,text)
    local width, height = renderer_measure_text('cd+', text)
    local offset =1 * (height + 8)
    local gradient_width = math.floor(width / 2)
    local y = startingy - offset
    renderer_gradient(x, y, gradient_width, height + 2,0, 0, 0, 4 ,0, 0, 0, 60, true)
    renderer_gradient(x + gradient_width, y, gradient_width, height + 2, 0, 0, 0, 60, 0, 0, 0, 0, true)
    renderer_text(x , y + 2,r,g,b,a, 'd+', 0, text)
  end 
  local x_mod = 0 
local function on_paint()
    for i,v in ipairs(indicators) do
       -- stolen from chinese
        local eyex, eyey, eyez = client.eye_position() 
        local camp, camy = client.camera_angles()
        local rad = math.rad(camy - 90)
        local px, py, pz = eyex + 25 * math.cos(rad), eyey + 25 * math.sin(rad), eyez + 20
        local sx, sy = renderer.world_to_screen(px, py, pz)
        if not sx or not sy then return end
        local me = entity.get_local_player()
        local scoped = entity.get_prop(me, "m_bIsScoped")
        local frames = 2 * globals.frametime() -- modify to change scoped animation speed
        if scoped == 1 then x_mod = x_mod + frames; if x_mod > 0.99 then x_mod = 1 end else x_mod = x_mod - frames; if x_mod < 0 then x_mod = 0 end end 
        local add_x = (-250) * x_mod
        if ui.get(main) then 
            rendery(sx+add_x,sy+200+(30*i),v[1],v[2],v[3],v[4],v[5]) -- change the number in (30*1) for spacing 
        end

    end

    indicators = {}
end

local function on_indicator(e)

    if e.text == "DT" and e.r == 255 and e.g == 0 and e.b == 50 and e.a == 255 then
        r, g, b = 255, 0, 50
    end
    if ui.get(override) then
     r, g, b, a = ui_get(override_color)
        else 
            r,g,b,a = e.r,e.g,e.b,e.a 
        end
    
    indicators[#indicators + 1] = {r, g, b, a, e.text}
end

local function handle_callbacks()
    local event_callback = ui_get(main) and client_set_event_callback or client_unset_event_callback

    event_callback("paint", on_paint)
    event_callback("indicator", on_indicator)
end

handle_callbacks()
ui_set_callback(main, handle_callbacks)




local function forcedef(cmd)
    if ui.get(check_forcedefensive) then
        cmd.force_defensive = true
    elseif not ui.get(check_forcedefensive) then
        cmd.force_defensive = false
    end
end
client.set_event_callback("setup_command", forcedef)
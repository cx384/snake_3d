function snake_3d.game_over(player, type)
	local meta = player:get_meta()
	local playername = player:get_player_name()
	meta:set_string("snake_active", "false")
	player:set_velocity({0,0,0})
	minetest.sound_play("snake_3d_death", {
		to_player = playername,
	})
	snake_3d.show_death_formspec(player)
end

local all_dirs = {
	{x = 1, y = 0, z = 0},
	{x = 0, y = 1, z = 0},
	{x = 0, y = 0, z = 1},
	{x = -1, y = 0, z = 0},
	{x = 0, y = -1, z = 0},
	{x = 0, y = 0, z = -1}
}

local function get_pos_dir_sum(pos, dir)
	local r = {}
	r.x = pos.x + dir.x
	r.y = pos.y + dir.y
	r.z = pos.z + dir.z
	return r
end

local function set_look_from_dir(player, dir)
	if dir.y == 1 then
		player:set_look_vertical(-math.pi/2)
	elseif dir.y == -1 then
		player:set_look_vertical(math.pi/2)
	else
		player:set_look_vertical(0)
		player:set_look_horizontal(minetest.dir_to_yaw(dir))
	end
end

local function dir_turn_right(dir)
	if dir.x == 1 then
		return {x = 0, y = 0, z = -1}
	elseif dir.z == -1 then
		return {x = -1, y = 0, z = 0}
	elseif dir.x == -1 then
		return {x = 0, y = 0, z = 1}
	else
		return {x = 1, y = 0, z = 0}
	end
end

local function get_player_control_dir(player)
	local pk = player:get_player_control()
	local dir = minetest.yaw_to_dir(player:get_look_horizontal())
	
	if dir.x < -0.5 then
		dir.x = -1
		dir.z = 0
	elseif dir.x > 0.5 then
		dir.x = 1
		dir.z = 0
	elseif dir.z < -0.5 then
		dir.z = -1
		dir.x = 0
	elseif dir.z > 0.5 then
		dir.z = 1
		dir.x = 0
	end

	if pk.sneak then
		return {x = 0, y = -1, z = 0}
	elseif pk.jump then
		return {x = 0, y = 1, z = 0}
	elseif pk.up then
		return dir
	elseif pk.down then
		return dir_turn_right(dir_turn_right(dir))
	elseif pk.left then
		return dir_turn_right(dir_turn_right(dir_turn_right(dir)))
	elseif pk.right then
		return dir_turn_right(dir)
	end
	
	return nil
end

function snake_3d.start_snake(player)
	local playername = player:get_player_name()
	minetest.close_formspec(playername, "")
	minetest.close_formspec(playername, "snake_3d:death")
	local meta = player:get_meta()

	local pos = snake_3d.get_empty_pos()
	if not pos then
		snake_3d.game_over(player, "invalid_start")
		return
	end
	player:set_pos(pos)
	
	-- get a nice direction
	local dirs1 = {}
	for _, dir in ipairs(all_dirs) do
		if minetest.get_node(get_pos_dir_sum(pos, dir)).name == "air" then
			table.insert(dirs1, dir)
		end
	end
	local dirs2 = {}
	for _, dir in ipairs(dirs1) do
		if minetest.get_node(get_pos_dir_sum(get_pos_dir_sum(pos, dir),dir)).name == "air" then
			table.insert(dirs2, dir)
		end
	end
	local dirs3 = {} -- 3 nodes space is enough
	for _, dir in ipairs(dirs2) do
		if minetest.get_node(get_pos_dir_sum(get_pos_dir_sum(get_pos_dir_sum(pos, dir),dir),dir)).name == "air" then
			table.insert(dirs3, dir)
		end
	end
	
	local dir
	if #dirs3 ~= 0 then
		dir = dirs3[math.random(1, #dirs3)]
	elseif #dirs2 ~= 0 then
		dir = dirs2[math.random(1, #dirs2)]
	elseif #dirs1 ~= 0 then
		dir = dirs1[math.random(1, #dirs1)]
	else
		dir = all_dirs[math.random(1, #all_dirs)]
	end
	
	set_look_from_dir(player, dir)
	
	meta:set_string("snake_direction", minetest.pos_to_string(dir, 0))
	meta:set_string("snake_active", "true")
	
	meta:set_string("snake_list", minetest.serialize({pos}))
	minetest.set_node(pos, {name = "snake_3d:snake_dummy_head"})
	
	meta:set_int("snake_stomach", snake_3d.start_size)
	
	meta:set_int("score", 0)
	local hud_score_id = meta:get_int("hud_score")
	player:hud_change(hud_score_id, "text", "Score: ".. 0)
end

local function get_dif(a, b)
	local big = math.max(a,b)
	local small = math.min(a,b)
	return math.abs(big-small)
end

function snake_3d.execute_snake_step(player)
	local playername = player:get_player_name()
	local meta = player:get_meta()
	if not (meta:get_string("snake_active") == "true") then
		return
	end
	
	local dir = minetest.string_to_pos((meta:get_string("snake_direction")))
	
	if not snake_3d.fast_control then
		local player_control_dir = get_player_control_dir(player)
		if player_control_dir then
			dir = player_control_dir
		end
	end
	
	local snake_list = minetest.deserialize(meta:get_string("snake_list"))
	local head_pos = snake_list[1]
	local stomach = meta:get_int("snake_stomach")
	
	local next_pos = get_pos_dir_sum(head_pos, dir)
	local node_name = minetest.get_node(next_pos).name
	local food = minetest.get_item_group(node_name, "food")
	stomach = stomach + food

	if food > 0 then
		minetest.sound_play("snake_3d_eat", {
			to_player = playername,
		})
		snake_3d.spawn_apple()
		meta:set_int("score", meta:get_int("score")+food)
		
	elseif node_name ~= "air" then
		snake_3d.game_over(player, "crash")
		return
	end
	
	if snake_3d.smooth then
		player:set_velocity({x = (dir.x*snake_3d.speed), y = (dir.y*snake_3d.speed), z = (dir.z*snake_3d.speed)})
	end
	
	local player_pos = player:get_pos()
	if get_dif(player_pos.x, next_pos.x) > snake_3d.move_teleport_dif or
			get_dif(player_pos.y, next_pos.y) > snake_3d.move_teleport_dif or
			get_dif(player_pos.z, next_pos.z) > snake_3d.move_teleport_dif then
		player:set_pos(next_pos)
	end
	
	minetest.set_node(head_pos, {name = snake_3d.snake_node})
	minetest.set_node(next_pos, {name = "snake_3d:snake_dummy_head"})
	table.insert(snake_list, 1, next_pos)
	
	if stomach > 0 then
		stomach = stomach - 1
	else
		minetest.set_node(snake_list[#snake_list], {name = "air"})
		table.remove(snake_list, #snake_list)
	end
	
	local hud_score_id = meta:get_int("hud_score")
	player:hud_change(hud_score_id, "text", "Score: ".. meta:get_int("score"))
	
	meta:set_string("snake_list", minetest.serialize(snake_list))
	meta:set_int("snake_stomach", stomach)
	meta:set_string("snake_direction", minetest.pos_to_string(dir, 0))
end

local step_time = 0
minetest.register_globalstep(function(dtime)
	step_time = step_time + dtime
	
	-- maybe too slow
	if snake_3d.fast_control then
		for _, player in ipairs(minetest.get_connected_players()) do
			-- handle player inputs
			local dir = get_player_control_dir(player)
			if dir then
				local meta = player:get_meta()
				meta:set_string("snake_direction", minetest.pos_to_string(dir, 0))
			end
		end
	end
	
	-- execute step
	if step_time >= 1/snake_3d.speed then
		step_time = 0
		for _, player in ipairs(minetest.get_connected_players()) do
			snake_3d.execute_snake_step(player)
		end
	end
end)

minetest.register_craftitem("snake_3d:hand", {
	range = 0,
	groups = {not_in_creative_inventory=1}
})

minetest.register_on_joinplayer(function(player)
	-- visuals
	player:hud_set_flags({
		hotbar = false,
		healthbar= false,
		crosshair = false,
		wielditem = false,
		breathbar = false,
		minimap = false,
		minimap_radar = false
	})
	player:override_day_night_ratio(1)
	player:set_sky({clouds = false,
		type = "plain",
		base_color = "#000000",
		sky_color = {}
	})
	player:set_sun({visible = false, sunrise_visible = false})
	player:set_moon({visible = false})
	player:set_stars({visible = false})
	player:set_properties({
		eye_height = 0,
		physical = false,
		collisionbox = {0,0,0,0,0,0},
		pointable = false,
		
		visual = "cube",
		textures = snake_3d.snake_head_textures,
		visual_size = {x = 1, y = 1, z = 1},
		is_visible = false
	})
	
	player:set_physics_override({speed = 0, jump = 0, gravity = 0, sneak = false})
	player:set_inventory_formspec(snake_3d.inventory_formspec)
	
	--player:set_eye_offset({x=-5, y=-5, z=-5})
	--player:set_fov(1.5, true, 0)
	
	local inv = minetest.get_inventory({type="player", name=player:get_player_name()})
	inv:set_size("hand", 1)
	inv:set_stack("hand", 1, "snake_3d:hand")
	
	local playername = player:get_player_name()
	minetest.show_formspec(playername, "", snake_3d.inventory_formspec)
	
	if snake_3d.mod_storage:get_string("is_map") ~= "true" then
		snake_3d.set_world()
		snake_3d.mod_storage:set_string("is_map", "true")
	end
	
	local meta = player:get_meta()
	local hud_score_id = player:hud_add({
		hud_elem_type = "text",
		position = {x=0.5, y=0.95},
		--scale = {x = 2, y = 2},
		text = "Score:",
		number = 0xFF0000,
		alignment = {x=0, y=0},
		offset = {x=0, y=0},
		size = { x=2, y=2 },
		z_index = 0,
	})
	meta:set_int("hud_score", hud_score_id)
end)


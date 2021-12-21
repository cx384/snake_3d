-- inv
snake_3d.inventory_formspec =
	"formspec_version[3]"..
	"size[3,2]"..
	"button[0.5,0.5;2,1;start;Start]"

-- death
function snake_3d.show_death_formspec(player)
	local playername = player:get_player_name()
	local meta = player:get_meta()
	local score = meta:get_int("score")
	local highscore = meta:get_int("highscore")
	local message = "Game over!"
	
	if score > highscore then
		highscore = score
		meta:set_int("highscore", score)
		message = "New Highscore!"
	end
	
	local formspec =
		"formspec_version[3]"..
		"size[3,3.5]"..
		"label[0.5,0.5;"..message.."]"..
		"label[0.5,1;Score: "..score.."]"..
		"label[0.5,1.5;Highscore: "..highscore.."]"..
		"button[0.5,2;2,1;restart;Restart]"

	minetest.show_formspec(playername, "snake_3d:death", formspec)
end

-- new_map
snake_3d.new_map_formspec =
	"formspec_version[3]"..
	"size[3,3]"..
	""..
	"button[0.5,1.5;2,1;start;Start]"

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.restart or fields.start then
		local meta = player:get_meta()
		if snake_3d.mod_storage:get_string("is_map") ~= "true" then
			minetest.chat_send_player(player:get_player_name(), "Create a map first!")
			return
		end
		
		--[[ no multiplayer for now
		local snake_list = minetest.deserialize(meta:get_string("snake_list"))
		if snake_list then
			for _,pos in ipairs(snake_list) do
				minetest.set_node(pos, {name = "air"})
			end
		end
		]]
		snake_3d.set_world()
		
		snake_3d.start_snake(player)
	end
end)

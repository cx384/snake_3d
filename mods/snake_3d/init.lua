local modpath = minetest.get_modpath("snake_3d")
snake_3d = {}
snake_3d.mod_storage = minetest.get_mod_storage()

snake_3d.speed = 2
snake_3d.start_size = 3
snake_3d.apple_count = 1
snake_3d.fast_control = true

-- pos inside the map
snake_3d.minp = {x = 1, y = 1, z =1}
snake_3d.maxp = {x = 10, y = 10, z = 10}

-- smooth movement doesn't work well
snake_3d.smooth = false
snake_3d.move_teleport_dif = 0.1

snake_3d.snake_node = "snake_3d:snake"
snake_3d.snake_head_textures = {"snake_3d_snake.png","snake_3d_snake.png","snake_3d_snake.png",
		"snake_3d_snake.png","snake_3d_snake.png","snake_3d_snake.png"}

dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/world.lua")
dofile(modpath .. "/snake.lua")
dofile(modpath .. "/menu.lua")
dofile(modpath .. "/palyer.lua")

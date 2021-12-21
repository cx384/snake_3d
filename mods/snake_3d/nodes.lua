-- snake

minetest.register_node("snake_3d:snake", {
	tiles = {"snake_3d_snake.png"},
	groups = {snake = 1},
	paramtype = "light",
	sunlight_propagates = true,
	light_source = minetest.LIGHT_MAX,
	walkable = false,
	pointable = false,
	drawtype = "allfaces"
})

minetest.register_node("snake_3d:snake_dummy_head", {
	groups = {snake = 1, not_in_creative_inventory=1},
	paramtype = "light",
	sunlight_propagates = true,
	light_source = minetest.LIGHT_MAX,
	drawtype = "airlike",
	walkable = false,
	pointable = false
})

-- wall

minetest.register_node("snake_3d:wall", {
	tiles = {"snake_3d_wall.png"},
	groups = {wall = 1},
	paramtype = "light",
	sunlight_propagates = true
})

-- ceiling and floor may get another texture
minetest.register_node("snake_3d:ceiling", {
	tiles = {"snake_3d_wall.png"},
	groups = {wall = 1},
	paramtype = "light",
	sunlight_propagates = true
})

minetest.register_node("snake_3d:floor", {
	tiles = {"snake_3d_wall.png"},
	groups = {wall = 1},
	paramtype = "light",
	sunlight_propagates = true
})

-- food

minetest.register_node("snake_3d:apple", {
	tiles = {"snake_3d_apple_top.png", "snake_3d_apple_side.png", "snake_3d_apple_side.png"},
	groups = {food = 1},
	paramtype = "light",
	sunlight_propagates = true,
	light_source = minetest.LIGHT_MAX
})

minetest.register_node("snake_3d:mese", {
	tiles = {"snake_3d_mese.png"},
	groups = {food = 3},
	paramtype = "light",
	sunlight_propagates = true,
	light_source = minetest.LIGHT_MAX
})

minetest.register_node("snake_3d:nyancat", {
	tile_images = {"snake_3d_nc_side.png", "snake_3d_nc_side.png", "snake_3d_nc_side.png",
		"snake_3d_nc_side.png", "snake_3d_nc_back.png", "snake_3d_nc_front.png"},
	groups = {food = 9},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	light_source = minetest.LIGHT_MAX
})

-- returns nil if map is full
function snake_3d.get_empty_pos()
	local pos = {}
	for i = 1, 5, 1 do
		pos.x = math.random(snake_3d.minp.x, snake_3d.maxp.x)
		pos.y = math.random(snake_3d.minp.y, snake_3d.maxp.y)
		pos.z = math.random(snake_3d.minp.z, snake_3d.maxp.z)
		if minetest.get_node(pos).name == "air" then
			return pos
		end
	end
	
	local empty_ids = {}
	
	local vm = VoxelManip()
	local pmin, pmax = vm:read_from_map(snake_3d.minp, snake_3d.maxp)
	local area = VoxelArea:new{MinEdge = pmin, MaxEdge = pmax}
	local data = vm:get_data()
	
	for i in area:iterp(snake_3d.minp, snake_3d.maxp) do
		if data[i] == "air" then
			table.insert (empty_ids, i)
		end
	end
	
	if #empty_ids == 0 then
		return nil
	else
		return area:position(empty_ids[math.random(1, #empty_ids)])
	end
end

function snake_3d.spawn_apple()
	local pos = snake_3d.get_empty_pos()
	if not pos then
		return
	end
	if math.random(1, 25) > 1 then
		minetest.set_node(pos, {name = "snake_3d:apple"})
	elseif math.random(1, 40) > 1 then
		minetest.set_node(pos, {name = "snake_3d:mese"})
	else
		minetest.set_node(pos, {name = "snake_3d:nyancat"})
	end
end

local wall_id = minetest.get_content_id("snake_3d:wall")
local ceiling_id = minetest.get_content_id("snake_3d:ceiling")
local floor_id = minetest.get_content_id("snake_3d:floor")
local air_id = minetest.get_content_id("air")

function snake_3d.set_world()
	-- pos outside the map
	local minpo = {x = snake_3d.minp.x -1, y = snake_3d.minp.y -1, z = snake_3d.minp.z -1}
	local maxpo = {x = snake_3d.maxp.x +1, y = snake_3d.maxp.y +1, z = snake_3d.maxp.z +1}

	local vm = VoxelManip()
	local pmin, pmax = vm:read_from_map(minpo, maxpo)
	local area = VoxelArea:new{MinEdge = pmin, MaxEdge = pmax}
	local data = vm:get_data()
	
	
	for i in area:iterp(minpo, maxpo) do
		local pos = area:position(i)
		if pos.y == minpo.y then
			data[i] = floor_id
		elseif pos.y == maxpo.y then
			data[i] = ceiling_id
		elseif pos.x == minpo.x or
				pos.z == minpo.z or
				pos.x == maxpo.x or
				pos.z == maxpo.z then
			data[i] = wall_id
		else
			data[i] = air_id
		end
	end
	
	vm:set_data(data)
	vm:write_to_map()
	
	for i = 1, snake_3d.apple_count, 1 do
		snake_3d.spawn_apple()
	end
end

function snake_3d.clear_world()
	local minpo = {x = snake_3d.minp.x -1, y = snake_3d.minp.y -1, z = snake_3d.minp.z -1}
	local maxpo = {x = snake_3d.maxp.x +1, y = snake_3d.maxp.y +1, z = snake_3d.maxp.z +1}
	
	local vm = VoxelManip()
	local pmin, pmax = vm:read_from_map(minpo, maxpo)
	local area = VoxelArea:new{MinEdge = pmin, MaxEdge = pmax}
	local data = vm:get_data()
	
	for i in area:iterp(minpo, maxpo) do
		data[i] = air_id
	end
	
	vm:set_data(data)
	vm:write_to_map()
end


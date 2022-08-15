dofile_once("data/scripts/lib/utilities.lua")

--Pit Boss ID and Position
local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform(GetUpdatedEntityID())
SetRandomSeed(x, y * GameGetFrameNum())

--Player ID
local players = EntityGetWithTag("player_unit")
local player = players[1]

--Gets VariableStorageComponents "phase", "memory", "max_wands_allowed"
local phase = 0
local proj = ""
local max_wands_allowed = 0
local comps = EntityGetComponent(entity_id, "VariableStorageComponent")
if (comps ~= nil) then
	for i, v in ipairs(comps) do
		local n = ComponentGetValue2(v, "name")
		if (n == "phase") then
			phase = ComponentGetValue2(v, "value_int")
		elseif (n == "memory") then
			--print( ComponentGetValue2( v, "value_string" ) )
			proj = ComponentGetValue2(v, "value_string")

			if (#proj == 0) then
				proj = "data/entities/projectiles/enlightened_laser_darkbeam.xml"
				ComponentSetValue2(v, "value_string", proj)
			end
		elseif (n == "max_wands_allowed") then
			max_wands_allowed = ComponentGetValue2(v, "value_int")
		end
	end
end

--Phase 1
--Spawns a wand every 3 seconds that shoots from a list of spells
if phase == 1 then
	if (#proj > 0) then
		local wand_ids = EntityGetInRadiusWithTag(x, y, 100, "pit_boss_wand")
		if #wand_ids <= max_wands_allowed then
			local angle = Random(1, 200) * math.pi
			local vel_x = math.cos(angle) * 100
			local vel_y = 0 - math.cos(angle) * 100

			local spells = {"rocket", "rocket_tier_2", "rocket_tier_3", "grenade", "grenade_tier_2", "grenade_tier_3", "rubber_ball"}
			local rnd = Random(1, #spells)
			local path = "data/entities/projectiles/deck/" .. spells[rnd] .. ".xml"

			local wid = shoot_projectile(entity_id, "data/entities/animals/boss_pit/wand.xml", x, y, vel_x, vel_y)
			edit_component(
				wid,
				"VariableStorageComponent",
				function(comp, vars)
					ComponentSetValue2(comp, "value_string", path)
				end
			)

			EntityAddComponent(
				wid,
				"HomingComponent",
				{
					homing_targeting_coeff = "30.0",
					homing_velocity_multiplier = "0.16",
					target_tag = "player_unit"
				}
			)

			if (string.find(path, "rocket") ~= nil) then
				EntityAddComponent(
					wid,
					"VariableStorageComponent",
					{
						name = "mult",
						value_float = 0.5
					}
				)
			else
				EntityAddComponent(
					wid,
					"VariableStorageComponent",
					{
						name = "mult",
						value_float = 1.2
					}
				)
			end
		end
	end
end

--Phase 2
if phase == 2 then
	--[[ TOO CHAOTIC
	if (#proj > 0) then
		local wand_ids = EntityGetInRadiusWithTag(x, y, 100, "pit_boss_wand")
		if #wand_ids <= max_wands_allowed then
			for i = 1, 3 do
				local angle = Random(1, 200) * math.pi
				local vel_x = math.cos(angle) * 100
				local vel_y = 0 - math.cos(angle) * 100

				local spells = {"rocket", "rocket_tier_2", "rocket_tier_3", "grenade", "grenade_tier_2", "grenade_tier_3", "rubber_ball"}
				local rnd = Random(1, #spells)
				local path = "data/entities/projectiles/deck/" .. spells[rnd] .. ".xml"

				local wid = shoot_projectile(entity_id, "data/entities/animals/boss_pit/wand.xml", x, y, vel_x, vel_y)
				edit_component(
					wid,
					"VariableStorageComponent",
					function(comp, vars)
						ComponentSetValue2(comp, "value_string", path)
					end
				)

				EntityAddComponent(
					wid,
					"HomingComponent",
					{
						homing_targeting_coeff = "30.0",
						homing_velocity_multiplier = "0.16",
						target_tag = "player_unit"
					}
				)

				if (string.find(path, "rocket") ~= nil) then
					EntityAddComponent(
						wid,
						"VariableStorageComponent",
						{
							name = "mult",
							value_float = 0.5
						}
					)
				else
					EntityAddComponent(
						wid,
						"VariableStorageComponent",
						{
							name = "mult",
							value_float = 1.2
						}
					)
				end
			end
		end
	end
	]]

	--Phase 3
	if phase == 3 then
		--Summons duplicate of the player's wand
		if (#p > 0 and p ~= "data/entities/projectiles/deck/heal_bullet.xml" and p ~= "mods/purgatory/files/entities/animals/boss_pit/wand_of_shielding/shield_shot_large.xml") then
			local player_id = getPlayerEntity()
			local player_x, player_y = EntityGetTransform(player_id)

			local wand_ids = EntityGetInRadiusWithTag(player_x, player_y, 250, "wand_ghost_mimic")

			if #wand_ids < max_wands_allowed then
				--Summon Wandghost with player's wand
				EntityLoad("mods/purgatory/files/entities/animals/boss_pit/wand_ghost_mimic/wand_ghost_mimic.xml", x, y - 30)
			end
		end
	end
end

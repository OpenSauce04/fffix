local mod = FiendFolio
local game = Game()

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, eff)
	FiendFolio.scheduleForUpdate(function()
		if not eff then return end
		local room = Game():GetRoom()
		if room:GetType() == RoomType.ROOM_DUNGEON then
			local brokeGrid = false
			local radius = 100 * eff.SpriteScale.X
			local size = room:GetGridSize()
			for i=0, size do
				local gridEntity = room:GetGridEntity(i)
				if gridEntity and gridEntity:ToRock() and (gridEntity.State == 1 or gridEntity.State == 4) then
					local gridpos = room:GetGridPosition(i)
					if (eff.Position:Distance(gridpos) < radius) then
						gridEntity:Destroy(true)
						brokeGrid = true
						if gridEntity:GetType() == GridEntityType.GRID_ROCK_BOMB then
							FiendFolio.scheduleForUpdate(function()
								Game():BombExplosionEffects(gridpos, 40)
							end, 5)
						end
					end
				end
			end
			if brokeGrid then
				for _, rocktop in ipairs(Isaac.FindByType(1000, Isaac.GetEntityVariantByName("Crawlspace Rocktop"), -1, true)) do
					rocktop:Update()
				end
				for _, renderer in ipairs(Isaac.FindByType(1000, Isaac.GetEntityVariantByName("Crawlspace Grid Rerenderer"), -1, true)) do
					renderer:Update()
				end
			end
		end
	end, 1)
end, 1)

local function getBombRadius(bomb)
    local val
    local damage = bomb.ExplosionDamage
    if bomb:HasTearFlags(TearFlags.TEAR_GIGA_BOMB) then
        val = 130
    elseif 175.0 <= damage then
        val = 105.0
    else
        if damage <= 140.0 then
            val = 75.0
        else
            val = 90.0
        end
    end
    val = val * bomb.RadiusMultiplier
    return val
end

function mod:handleExplosionsInItemDungeons(bomb)
    --print(bomb:ToBomb().RadiusMultiplier)
	if bomb:IsDead() then
        FiendFolio.scheduleForUpdate(function()
            if not bomb then return end
            local room = Game():GetRoom()
            if room:GetType() == RoomType.ROOM_DUNGEON then
				local brokeGrid = false
                local radius = getBombRadius(bomb)
                local size = room:GetGridSize()
                for i=0, size do
                    local gridEntity = room:GetGridEntity(i)
                    if gridEntity and gridEntity:ToRock() and gridEntity.State == 1 then
                        local gridpos = room:GetGridPosition(i)
                        if (bomb.Position:Distance(gridpos) < radius) then
                            gridEntity:Destroy(true)
							brokeGrid = true
                            if gridEntity:GetType() == GridEntityType.GRID_ROCK_BOMB then
                                FiendFolio.scheduleForUpdate(function()
                                    local newbomb = Isaac.Spawn(4, 0, 0, gridpos, Vector.Zero, nil):ToBomb()
                                    newbomb.ExplosionDamage = 40
                                    newbomb:SetExplosionCountdown(0)
                                end, 5)
                            end
                        end
                    end
                end
				if brokeGrid then
					for _, rocktop in ipairs(Isaac.FindByType(1000, Isaac.GetEntityVariantByName("Crawlspace Rocktop"), -1, true)) do
						rocktop:Update()
					end
					for _, renderer in ipairs(Isaac.FindByType(1000, Isaac.GetEntityVariantByName("Crawlspace Grid Rerenderer"), -1, true)) do
						renderer:Update()
					end
				end
            end
        end, 1)
	end
end
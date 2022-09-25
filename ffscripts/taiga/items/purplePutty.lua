-- Purple Putty --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, id, rng, player, useflags, activeslot, customvardata)
	local player = mod:GetPlayerUsingItem()
	FiendFolio:AddImmoralHearts(player, 2)
	sfx:Play(mod.Sounds.FiendHeartPickup, 1, 0, false, 1)
	return useflags ~= useflags | UseFlag.USE_NOANIM
end, FiendFolio.ITEM.COLLECTIBLE.PURPLE_PUTTY)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, e)
	if e.Variant == FamiliarVariant.WISP and e.SubType == FiendFolio.ITEM.COLLECTIBLE.PURPLE_PUTTY then
		local player = e:ToFamiliar().Player
		if player then
			local egg = Isaac.Spawn(1000, EffectVariant.PICKUP_FIEND_MINION, 0, e.Position, nilvector, player)
			egg:GetData().canreroll = false
			egg.EntityCollisionClass = 4
			egg.Parent = player
			egg:GetData().hollow = true
			
			egg:GetSprite():Play("Drop", true)
			if math.random(2) == 1 then
				egg:GetSprite().FlipX = true
			end

			local isActiveRoom = mod.IsActiveRoom()
			if not isActiveRoom then
				egg:GetData().mixPersistent = true
				egg:GetData().mixRemainingRooms = 1
				egg:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
			end
			
			egg:Update()
		end
	end
end, EntityType.ENTITY_FAMILIAR)

local tearsToBePostFired = {}
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	if familiar.SubType == FiendFolio.ITEM.COLLECTIBLE.PURPLE_PUTTY then
		for _, tear in pairs(tearsToBePostFired) do
			if math.random(25) == 1 then
				tear:GetData().isImpSodaTear = true
				if not tear:GetData().critLightning or not tear:GetData().critLightning:Exists() then
					sfx:Play(mod.Sounds.CritShoot, 0.3, 0, false, math.random(80,120)/100)
					local critLightning = Isaac.Spawn(1000, 1737, 1, tear.Position, nilvector, tear):ToEffect()
					critLightning.Parent = tear
					critLightning.Color = Color(1,1,1,0,0,0,1)
					critLightning:Update()
					tear:GetData().critLightning = critLightning
				end
				tear.CollisionDamage = tear.CollisionDamage * 5
				tear.Color = Color(1.3,1.3,1.3,1,100/255,-150/255,100/255)
			end
		end

		tearsToBePostFired = {}
	end
end, FamiliarVariant.WISP)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function(_, tear)
	if tear.SpawnerEntity and
	   tear.SpawnerEntity.Type == EntityType.ENTITY_FAMILIAR and
	   tear.SpawnerEntity.Variant == FamiliarVariant.WISP and
	   tear.SpawnerEntity.SubType == FiendFolio.ITEM.COLLECTIBLE.PURPLE_PUTTY
	then
		tearsToBePostFired[tear.Index .. " " .. tear.InitSeed] = tear
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, tear)
	if tearsToBePostFired[tear.Index .. " " .. tear.InitSeed] then
		tearsToBePostFired[tear.Index .. " " .. tear.InitSeed] = nil
	end
end, EntityType.ENTITY_TEAR)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	tearsToBePostFired = {}
end)

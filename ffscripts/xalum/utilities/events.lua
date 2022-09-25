local mod = FiendFolio
local game = Game()

function mod.TriggerEvent(id)
	local room = game:GetRoom()
	local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, false, false)
	local tile = room:GetGridIndex(pos)

	room:SpawnGridEntity(tile, 20, 10 + id, 0, 0)
	local button = room:GetGridEntity(tile)

	local sprite = button:GetSprite()
	sprite:ReplaceSpritesheet(0, "")
	sprite:LoadGraphics()

	button:ToPressurePlate():Reward()

	room:RemoveGridEntity(tile, 0, false)
end

mod.EnemyTriggerHostBlacklist = {}

local function CreateEnemiesCache()
	mod.RoomEntitiesCache = Isaac.GetRoomEntities()
	return mod.RoomEntitiesCache
end

local function GetClosestEnemy(pos, excludeFiresAndTNT)
	local ents = mod.RoomEntitiesCache or CreateEnemiesCache()

	local closest
	local dist = 99999

	for _, ent in pairs(ents) do
		if ent:IsEnemy() and not (ent:HasEntityFlags(EntityFlag.FLAG_PERSISTENT) or ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
			if not excludeFiresAndTNT or (ent.Type ~= 33 and ent.Type ~= 292) then
				local d = pos:Distance(ent.Position)

				if d < dist then
					closest = ent
					dist = d
				end
			end
		end
	end

	return closest
end

mod.CustomTriggers = {
	[0] = function(effect)
		local data = effect:GetData()

		if data.targets then
			local alive = false

			for _, ent in pairs(data.targets) do
				if ent:Exists() and not ent:IsDead() then
					alive = true
				end
			end

			if not alive then
				mod.TriggerEvent(effect.SubType)
				effect:Remove()
			end
		else
			data.targets = {GetClosestEnemy(effect.Position)}

			for _, other in pairs(Isaac.FindByType(effect.Type, effect.Variant, effect.SubType)) do
				if GetPtrHash(other) ~= GetPtrHash(effect) then
					table.insert(data.targets, GetClosestEnemy(other.Position))
					other:Remove()
				end
			end
		end
	end,
	[10] = function(effect)
		if not GetClosestEnemy(effect.Position, true) then
			mod.TriggerEvent(effect.SubType - 10)
		end
	end,
}

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	if effect:Exists() then
		if effect.SubType < 10 then
			mod.CustomTriggers[0](effect)
		elseif effect.SubType < 20 then
			mod.CustomTriggers[10](effect)
		end
	end
end, mod.FF.CustomEventTrigger.Var)
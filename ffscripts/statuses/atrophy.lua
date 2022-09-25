-- Atrophy --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local statusColorPriority = 1

-- NOTE: Unfinished

function mod:handleAtrophy(entity, data, sprite)
	-- nothing for now
end

function FiendFolio.AddAtrophy(entity, source, duration, isCloned)
	local data = entity:GetData()
	if not (entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) or mod:isStatusBlacklisted(entity) or data.FFBossStatusResistance) or ((entity.Type == EntityType.ENTITY_MASK or entity.Type == EntityType.ENTITY_MASK_OF_INFAMY) and isCloned) then
		data.FFAtrophyDuration = duration
		data.FFAtrophySource = source
		
		if entity:IsBoss() then
			data.FFBossStatusResistance = FiendFolio.StatusEffectVariables.BossStatusResistanceFrameCount
		end
	end
end

function FiendFolio.RemoveAtrophy(entity)
	local data = entity:GetData()
	data.FFAtrophyDuration = nil
end

function mod:atrophyOnUpdate(npc, data, sprite, clearingStatus)
	if data.FFAtrophyDuration ~= nil and data.FFAtrophyDuration > 0 and not clearingStatus then
		mod:handleAtrophy(npc, data, sprite)
	else
		data.FFAtrophyDuration = nil
	end
end

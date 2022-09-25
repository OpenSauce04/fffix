-- Blind --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local statusColorPriority = 1

-- NOTE: Unfinished

function mod:handleBlind(entity, data, sprite)
	-- nothing for now
end

function FiendFolio.AddBlind(entity, source, duration, isCloned)
	local data = entity:GetData()
	if not (entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) or mod:isStatusBlacklisted(entity) or data.FFBossStatusResistance) or ((entity.Type == EntityType.ENTITY_MASK or entity.Type == EntityType.ENTITY_MASK_OF_INFAMY) and isCloned) then
		data.FFBlindDuration = duration
		data.FFBlindSource = source
		
		if entity:IsBoss() then
			data.FFBossStatusResistance = FiendFolio.StatusEffectVariables.BossStatusResistanceFrameCount
		end
	end
end

function FiendFolio.RemoveBlind(entity)
	local data = entity:GetData()
	data.FFBlindDuration = nil
end

function mod:blindOnUpdate(npc, data, sprite, clearingStatus)
	if data.FFBlindDuration ~= nil and data.FFBlindDuration > 0 and not clearingStatus then
		mod:handleBlind(npc, data, sprite)
	else
		data.FFBlindDuration = nil
	end
end

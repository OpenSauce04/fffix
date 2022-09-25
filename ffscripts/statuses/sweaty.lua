-- Sweaty --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local statusColorPriority = 1

-- NOTE: Unfinished

function mod:handleSweaty(entity, data, sprite)
	-- nothing for now
end

function FiendFolio.AddSweaty(entity, source, duration, damage, isCloned)
	local data = entity:GetData()
	if not (entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) or mod:isStatusBlacklisted(entity) or data.FFBossStatusResistance) or ((entity.Type == EntityType.ENTITY_MASK or entity.Type == EntityType.ENTITY_MASK_OF_INFAMY) and isCloned) then
		data.FFSweatyDuration = duration
		data.FFSweatyDamage = damage
		data.FFSweatySource = source
		
		if entity:IsBoss() then
			data.FFBossStatusResistance = FiendFolio.StatusEffectVariables.BossStatusResistanceFrameCount
		end
	end
end

function FiendFolio.RemoveSweaty(entity)
	local data = entity:GetData()
	data.FFSweatyDuration = nil
end

function mod:sweatyOnUpdate(npc, data, sprite, clearingStatus)
	if data.FFSweatyDuration ~= nil and data.FFSweatyDuration > 0 and not clearingStatus then
		mod:handleSweaty(npc, data, sprite)
	else
		data.FFSweatyDuration = nil
	end
end

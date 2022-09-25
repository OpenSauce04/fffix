local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_USE_PILL, function(_, pillEffect, player, flags)
    player:AnimatePill(player:GetPill(0))
	local doHorseEffect = mod.XalumIsPlayerUsingHorsePill(player, flags)
	local pitch = 1
	local effectStrength = 1

	if doHorseEffect then
		pitch = 0.5
		effectStrength = 2
		mod:trySayAnnouncerLine(mod.Sounds.VAPillHorseMelatonin, flags, 100)
	else
		mod:trySayAnnouncerLine(mod.Sounds.VAPillMelatonin, flags, 60)
	end
    sfx:Play(mod.Sounds.Melatonin, 1, 0, false, pitch)
    
    local secondHandMultiplier = player:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND) + 1
	local duration = 120 * secondHandMultiplier * effectStrength

    game:Darken(1, duration + 60)

	local entities = Isaac.GetRoomEntities()
	for _,entity in ipairs(entities) do
		if entity:ToNPC() and mod:checkIfStatusLogicIsApplied(entity, false) and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
			FiendFolio.AddDrowsy(entity, player, 60, duration, isCloned)
		end
	end
end, PillEffect.PILLEFFECT_MELATONIN)
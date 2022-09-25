local mod = FiendFolio
local heartacheRecursion

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flags, source, cooldown)
	local player = entity:ToPlayer()
	if player:GetTrinketMultiplier(mod.ITEM.TRINKET.HEARTACHE) > 0 and not heartacheRecursion and flags & DamageFlag.DAMAGE_FAKE == 0 then
		heartacheRecursion = true

		local brokens = player:GetTrinketMultiplier(mod.ITEM.TRINKET.HEARTACHE)
		local playerType = player:GetPlayerType()

		if playerType == PlayerType.PLAYER_THELOST or playerType == PlayerType.PLAYER_THELOST_B then brokens = brokens * 3 end
		if player:GetBrokenHearts() + brokens >= 12 then
			local reviveHappened = false

			if mod.CanPlayerReviveWithFrogPuppet(player) then
				mod.DoFrogPuppetRevive(player)
				reviveHappened = true
			elseif mod.CanPlayerReviveWithCursedUrn(player) then
				mod.DoCursedUrnRevive(player)
				reviveHappened = true
			end

			if reviveHappened then
				player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, source, cooldown)
				return false
			end
		end

		player:AddBrokenHearts(brokens)

		if player:GetBrokenHearts() >= 12 then
			player:TakeDamage(1, 0, source, cooldown)
		else
			player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, source, cooldown)
		end

		heartacheRecursion = false
		return false
	end
end, 1)
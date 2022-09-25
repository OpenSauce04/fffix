local mod = FiendFolio
local sfx = SFXManager()
local stud = mod.ITEM.CARD.STUD

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, flags)
	Isaac.Spawn(5, 20, mod.PICKUP.COIN.LEGOSTUD, player.Position, Vector.Zero, player)
end, stud)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	if pickup.SubType == mod.PICKUP.COIN.LEGOSTUD then
		if pickup:GetSprite():IsEventTriggered("DropSound") then
			sfx:Play(SoundEffect.SOUND_SCAMPER)
		end

		if pickup.EntityCollisionClass ~= 0 and pickup.FrameCount % 5 == 0 then
			for _, entity in pairs(Isaac.FindInRadius(pickup.Position, pickup.Size * 1.5, EntityPartition.ENEMY)) do
				if entity:ToNPC() and entity:IsVulnerableEnemy() then
					entity:TakeDamage(5, 0, EntityRef(pickup.SpawnerEntity or pickup), 0)
				end
			end
		end
	end
end, PickupVariant.PICKUP_COIN)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	if pickup.SubType == mod.PICKUP.COIN.LEGOSTUD then
		if collider:ToPlayer() or collider:ToFamiliar() then
			pickup.SubType = 1

			mod.scheduleForUpdate(function()
				sfx:Stop(SoundEffect.SOUND_PENNYPICKUP)
				sfx:Play(mod.Sounds.LegoStudPickup)
			end, 1)

			local player = collider:ToPlayer()
			if player then
				player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(player), 0)
			end
		end
	end
end, PickupVariant.PICKUP_COIN)
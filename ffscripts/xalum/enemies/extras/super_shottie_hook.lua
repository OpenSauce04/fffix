local mod = FiendFolio
local sfx = SFXManager()

local HookState = {
	FLY_OUT		= 1,
	FLY_IN 		= 2,
	HOOKED		= 3,
	HOOKED_IN 	= 4,
}

local function RemoveHook(npc)
	npc:Remove()
	sfx:Stop(mod.Sounds.SuperShottieChainLoop)

	if npc.SpawnerEntity then
		local data = npc.SpawnerEntity:GetData()
		if data.chainElements then
			for _, dummy in pairs(data.chainElements) do
				dummy:Remove()
			end
		end
	end
end

return {
	Init = function(npc)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS

		local data = npc:GetData()
		data.state = HookState.FLY_OUT
		data.velocityCache = npc.Velocity

		npc.SpriteOffset = Vector(0, -16)
	end,

	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if not npc.SpawnerEntity or npc.SpawnerEntity:IsDead() or not npc.SpawnerEntity:Exists() then
			RemoveHook(npc)
		end

		if data.state == HookState.HOOKED then
			sprite:Play("Hook02")
			sprite.Rotation = (data.hookedPlayer.Position - npc.SpawnerEntity.Position):GetAngleDegrees() + 180
			npc.Velocity = data.hookedPlayer.Position + data.hookedPosition - npc.Position
		elseif data.state == HookState.HOOKED_IN then
			npc.Velocity = (npc.SpawnerEntity.Position - npc.Position):Resized(data.velocityCache:Length())

			if npc.Position:Distance(npc.SpawnerEntity.Position) < npc.SpawnerEntity.Size + npc.Size + 20 then
				RemoveHook(npc)
			end
		else
			sprite:Play("Hook")
			sprite.Rotation = data.velocityCache:GetAngleDegrees() + 180

			if data.state == HookState.FLY_OUT then
				npc.Velocity = data.velocityCache

				if npc:CollidesWithGrid() then
					data.state = HookState.FLY_IN
					sfx:Play(mod.Sounds.CleaverHitWorld, 0.4, 0, false, 1.2)
				end
			end

			if data.state == HookState.FLY_IN then
				npc.Velocity = -data.velocityCache

				if npc.Position:Distance(npc.SpawnerEntity.Position) < npc.SpawnerEntity.Size + npc.Size + 20 then
					npc.SpawnerEntity:GetSprite():Play("HookFail")
					sfx:Play(SoundEffect.SOUND_FAT_WIGGLE)
					RemoveHook(npc)
				end
			end
		end
	end,

	Collision = function(npc, collider)
		if collider:ToPlayer() then
			local data = npc:GetData()
			data.state = HookState.HOOKED
			data.hookedPosition = npc.Position - collider.Position
			data.hookedPlayer = collider:ToPlayer()

			for i = 1, 4 do
				Isaac.Spawn(1000, 5, 0, collider.Position, RandomVector() + npc.Velocity:Resized(5), collider)
			end
			Isaac.Spawn(1000, 17, 0, collider.Position, Vector.Zero, collider).SpriteOffset = Vector(0, -12)
			collider:BloodExplode()

			npc.Velocity = Vector.Zero
			npc.EntityCollisionClass = 0
			npc.SpawnerEntity:GetSprite():Play("HookLand")

			sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)
			sfx:Play(mod.Sounds.CleaverHit, 1)
			sfx:Play(SoundEffect.SOUND_MONSTER_YELL_A)
			sfx:Stop(mod.Sounds.SuperShottieChainLoop)
		end
	end,
}
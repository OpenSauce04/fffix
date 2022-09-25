local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

return {
	Init = function(npc)
		local data = npc:GetData()

		data.bounces = 0
		data.stage = 0
		data.direction = "Right"

		data.rng = RNG()
		data.rng:SetSeed(npc.InitSeed, 42)

		data.splashParams = ProjectileParams()
		data.splashParams.FallingAccelModifier = 2
	end,
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if sprite:IsFinished("Appear" .. data.direction) then
			data.stage = 1
			sprite:Play(data.direction .. data.stage)
		end

		npc.Velocity = mod.XalumLerp(npc.Velocity, npc.Velocity:Resized(5), 0.2)

		if npc:CollidesWithGrid() then
			local room = game:GetRoom()
			local grid = room:GetGridEntityFromPos(npc.Position)
			local position = grid and grid.Position or mod.XalumAlignPositionToGrid(npc.Position + npc.Velocity)
			local difference = position - npc.Position

			if math.abs(difference.X) > math.abs(difference.Y) then
				npc.Velocity = Vector(-npc.Velocity.X, npc.Velocity.Y)
			else
				npc.Velocity = Vector(npc.Velocity.X, -npc.Velocity.Y)
			end
		end

		if npc.Velocity.X > 0 then
			if data.direction == "Left" and data.stage > 0 then
				local frame = sprite:GetFrame()
				sprite:Play("Right" .. data.stage)
				sprite:SetFrame(frame)
			end

			data.direction = "Right"
		else
			if data.direction == "Right" and data.stage > 0 then
				local frame = sprite:GetFrame()
				sprite:Play("Left" .. data.stage)
				sprite:SetFrame(frame)
			end

			data.direction = "Left"
		end

		if (sprite:IsPlaying("Appear" .. data.direction) and sprite:GetFrame() == 9) or (sprite:IsPlaying(data.direction .. data.stage) and sprite:GetFrame() == 18) then
			for i = 0, 2 do
				Isaac.Spawn(1000, 22, 0, npc.Position + npc.Velocity * i, Vector.Zero, npc)
			end

			Isaac.Spawn(1000, 14, 1, npc.Position, Vector.Zero, npc)

			npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS_OLD, 1, 0, false, 1.5)
			data.bounces = data.bounces + 1
		end

		if (data.bounces > 3 and sprite:GetFrame() == 19) or npc.HitPoints < npc.MaxHitPoints * (1 - data.stage / 4) then
			data.bounces = 0
			data.stage = data.stage + 1

			if data.stage < 5 then
				local frame = sprite:GetFrame()
				sprite:Play(data.direction .. data.stage)
				sprite:SetFrame(frame)
			end
		end

		if (data.stage >= 5 or npc:HasMortalDamage()) and not mod:isLeavingStatusCorpse(npc) and not npc:IsDead() then
			npc.Velocity = Vector.Zero
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

			for i = 1, 6 + data.rng:RandomInt(4) do
				data.splashParams.FallingSpeedModifier = data.rng:RandomInt(16) * 1.5 - 30
				npc:FireProjectiles(npc.Position, RandomVector():Resized(4 - data.rng:RandomFloat() * 2), 0, data.splashParams)
			end

			npc:PlaySound(mod.Sounds.DeadEyeBurst, 0.5, 0, false, 0.4)

			sprite:Play("Pop")
			npc:Die()
		end

		if sprite:IsFinished("Pop") then
			npc:Remove()
		end
	end,
}
local game = Game()
local sfx = SFXManager()

local function turn(sprite)
	if sprite:IsPlaying("WalkLeft") then
		sprite:Play("TurnLR")
	elseif sprite:IsPlaying("WalkRight") then
		sprite:Play("TurnRL")
	end
end

return {
	Init = function(npc)
		local sprite = npc:GetSprite()
		local data = npc:GetData()

		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		--npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
		npc.Position = npc.Position + Vector(0, 10)

		data.rng = RNG()
		data.rng:SetSeed(npc.InitSeed, 23)

		if npc.SubType == 0 then
			npc.SubType = data.rng:RandomInt(2) + 1
		end

		if npc.SubType == 1 then
			sprite:Play("SpawnLeft")
		else
			sprite:Play("SpawnRight")
		end
	end,
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if not data.init then
			sprite:Play(sprite:GetAnimation())

			local brain = Isaac.Spawn(FiendFolio.FF.LonelyKnightBrain.ID, FiendFolio.FF.LonelyKnightBrain.Var, 0, npc.Position, Vector.Zero, npc)
			brain:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			brain:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK + EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
			brain.Visible = false
			brain:GetData().NoCustomStatusIndicators = true
			brain:GetSprite():Play("Hidden", true) -- To hide basegame status indicators

			local shell

			for i = 1, 2 do
				shell = Isaac.Spawn(FiendFolio.FF.LonelyKnightShell.ID, FiendFolio.FF.LonelyKnightShell.Var, 0, npc.Position, Vector.Zero, npc)
				shell:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				shell:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK + EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)-- + EntityFlag.FLAG_NO_TARGET)
				shell.Visible = false
				shell:GetData().NoCustomStatusIndicators = true
				shell:GetSprite():Play("Hidden", true) -- To hide basegame status indicators
			end

			shell:GetData().offset = Vector(0, 0)
			shell.Size = shell.Size * 0.9

			data.init = true
		end

		if data.toturn then
			turn(sprite)
			data.toturn = false
		end

		if sprite:IsFinished("SpawnLeft") or sprite:IsFinished("TurnRL") then
			sprite:Play("WalkLeft")
		elseif sprite:IsFinished("SpawnRight") or sprite:IsFinished("TurnLR") then
			sprite:Play("WalkRight")
		end

		local anim = sprite:GetAnimation()
		local targetvec = Vector.Zero

		if anim == "WalkLeft" then targetvec = Vector(-4, 0) end
		if anim == "WalkRight" then targetvec = Vector(4, 0) end

		local room = game:GetRoom()
		local wall = room:GetGridEntityFromPos(npc.Position + targetvec:Resized(20))

		local floor_ahead = room:GetGridEntityFromPos(npc.Position + Vector(0, 30) + targetvec:Resized(20))
		local is_solid_ground = floor_ahead and floor_ahead.CollisionClass ~= 0
		local is_decoration_c = floor_ahead and floor_ahead:GetType() == GridEntityType.GRID_DECORATION and floor_ahead:GetVariant() == 30

		local safe_floor = is_solid_ground or is_decoration_c

		if not room:IsPositionInRoom(npc.Position + targetvec:Resized(20), 0) or (wall and wall.CollisionClass ~= 0) or not safe_floor then
			turn(sprite)
			targetvec = Vector.Zero
		end

		local below = room:GetGridEntityFromPos(npc.Position + Vector(0, 20))

		local offset = Vector(0, 3)
		if is_decoration_c or below and below:GetType() == GridEntityType.GRID_DECORATION then
			if not data.stick_to_y then
				data.stick_to_y = npc.Position.Y
			end

			offset = Vector.Zero
		else
			data.stick_to_y = nil
		end

		npc.Velocity = FiendFolio.Xalum_Lerp(npc.Velocity, targetvec, 0.25)

		if data.stick_to_y and data.stick_to_y ~= npc.Position.Y then
			npc.Velocity = Vector(npc.Velocity.X, data.stick_to_y - npc.Position.Y)
		end
	end,
	Damage = function(npc, amount, flags)
		local data = npc:GetData()

		if flags == flags | DamageFlag.DAMAGE_POISON_BURN then -- Keep Poison/Burn synced to once per 40 frames
			data.FFLastPoisonProc = data.FFLastPoisonProc or 0
			if Isaac.GetFrameCount() - data.FFLastPoisonProc < 40 then
				return false
			end
			data.FFLastPoisonProc = Isaac.GetFrameCount()
		elseif flags ~= flags | DamageFlag.DAMAGE_CLONES and not data.FFTakingBleedDamage then -- Regular damage
			return false
		end
	end,
	Death = function(npc)
		for _, brain in pairs(Isaac.FindByType(FiendFolio.FF.LonelyKnightBrain.ID, FiendFolio.FF.LonelyKnightBrain.Var)) do
			if brain.SpawnerEntity and brain.SpawnerEntity.Index == npc.Index and brain.SpawnerEntity.InitSeed == npc.InitSeed then
				brain:Remove()
			end
		end
		
		for _, shell in pairs(Isaac.FindByType(FiendFolio.FF.LonelyKnightShell.ID, FiendFolio.FF.LonelyKnightShell.Var)) do
			if shell.SpawnerEntity and shell.SpawnerEntity.Index == npc.Index and shell.SpawnerEntity.InitSeed == npc.InitSeed then
				shell:Remove()
			end
		end
	end,
	Collision = function(npc, collider, first)
		if collider:ToNPC() or collider:ToPlayer() then
			if collider.Type == FiendFolio.FF.LonelyKnightBrain.ID and collider.Variant == FiendFolio.FF.LonelyKnightBrain.Var then
				return true
			end
			if collider.Type == FiendFolio.FF.LonelyKnightShell.ID and collider.Variant == FiendFolio.FF.LonelyKnightShell.Var then
				return true
			end

			local sprite = npc:GetSprite()
			local facing_left = sprite:IsPlaying("WalkLeft") or sprite:IsPlaying("TurnRL")
			local facing_vec = facing_left and Vector(0, -5) or Vector(0, 5)
			local moving_towards = (npc.Position + facing_vec):Distance(collider.Position) < npc.Position:Distance(collider.Position)

			if moving_towards then
				turn(npc:GetSprite())
			end
		end
	end,
}
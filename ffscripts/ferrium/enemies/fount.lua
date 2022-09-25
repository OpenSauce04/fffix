local mod = FiendFolio

function mod:fountAI(npc) -- Similar to frogs. When attacking, fires an underwater geyser that slowly travels, flitting up bubbles. On impact with Isaac's old location, fires fount.
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local rand = npc:GetDropRNG()

	if not data.init then
		npc.StateFrame = 0
		npc.SplatColor = mod.ColorWaterPeople
		data.state = "Idle"
		data.attacked = false
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
        local pit = Isaac.GridSpawn(7, 0, npc.Position, true)
        mod:UpdatePits()
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
		npc.Velocity = Vector.Zero
		if not mod:IsCurrentPitSafe(npc) then
            npc:Kill()
        end
	end

	if data.state == "Idle" then
		if npc.StateFrame == 80 and data.attacked == false then
			sprite:Play("StartAttack")
			data.state = "Attack"
		elseif npc.StateFrame == 80 and data.attacked == true then
			sprite:Play("Burrow")
			data.state = "Movering"
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "Idle")
		end
	elseif data.state == "Attack" then
		if sprite:IsPlaying("BubbleIdle") then
			if npc.StateFrame % 17 == 0 then
				local bubble = Isaac.Spawn(mod.FF.Bubble.ID, mod.FF.Bubble.Var, math.random(2), data.currentTarget, Vector.Zero, npc)
				bubble:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				bubble:GetData().spawning = true
				bubble:Update()
			end

			data.currentTarget = data.currentTarget+data.currentVel

			if (data.currentTarget - data.realTarget):Length() < 4 then
				if npc.Child and npc.Child:Exists() then
					npc.Child.Parent = nil
					npc.Child = nil
				end
				npc:PlaySound(SoundEffect.SOUND_BOSS2_DIVE, 0.4, 0, false, 1)
				Isaac.Spawn(1000, 14, 0, data.realTarget, Vector.Zero, npc)
				for i=0,25 do
					local projectile = Isaac.Spawn(9, 4, 0, data.realTarget, RandomVector():Resized(math.random(10,35)/15), npc):ToProjectile()
					projectile.FallingSpeed = -math.random(18,65)
					projectile.FallingAccel = math.random(7,14)/8
				end
				sprite:Play("AttackEnd")
			end
		elseif sprite:IsFinished("StartAttack") then
			sprite:Play("BubbleIdle")
			data.realTarget = target.Position
			data.currentTarget = npc.Position
			data.currentVel = (data.realTarget-data.currentTarget):Resized(1.5)
			local effect = Isaac.Spawn(1000, 1743, 0, data.realTarget, Vector.Zero, nil)
			mod:spritePlay(effect:GetSprite(), "Appear")
			effect.Parent = npc
			npc.Child = effect
			effect:Update()
		elseif sprite:IsFinished("AttackEnd") then
			data.attacked = true
			npc.StateFrame = 0
			data.state = "Idle"
		end
	elseif data.state == "Movering" then
		if sprite:IsFinished("Burrow") and npc.StateFrame > 15 then
			local newPosition = mod:FindRandomPit(npc)
            npc.Position = newPosition
            sprite:Play("Emerge")
		elseif sprite:IsFinished("Emerge") then
			npc.StateFrame = 0
			data.attacked = false
			data.state = "Idle"
		end
	end
end
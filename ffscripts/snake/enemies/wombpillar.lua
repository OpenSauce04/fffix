local mod = FiendFolio
local game = Game()

function mod:WombPillarUpdate(npc)
	local d = npc:GetData()
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()

	local minBullets = 5   -- if detected, minimum bullets it fires before stopping even if player is out of range
	local detectRange = 80

	if not d.Init then
		d.BulletsShot = 0
		d.State = "Idle"
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
        local room = game:GetRoom()
        FiendFolio.NPCBlockerGrid:Spawn(room:GetGridIndex(npc.Position), true, false, { Parent = npc })
		d.Init = true
	end

	if npc.FrameCount % 10 == 0 then
		for _,ClosePickup in ipairs(Isaac.FindInRadius(npc.Position, 1, EntityPartition.PICKUP)) do
			ClosePickup.Velocity = RandomVector()*2
		end
	end

	if d.State == "Idle" then
		mod:spritePlay(sprite, "Idle")

		if npc.Position:Distance(target.Position) < detectRange or d.hurting then
			mod:spritePlay(sprite, "Charge")
			d.State = "Charge"
		end

	elseif d.State == "Charge" then

		if sprite:IsFinished("Charge") then
			mod:spritePlay(sprite, "Shoot")

			d.State = "Shooting"
		end

	elseif d.State == "Shooting" then
		mod:spritePlay(sprite, "Shoot")

		if sprite:IsEventTriggered("Shoot") then
			local params = ProjectileParams()
			params.FallingSpeedModifier = -math.random(8, 10)
			params.FallingAccelModifier = 1.5
			params.HeightModifier = -45

			npc:FireProjectiles(npc.Position, RandomVector() * math.random(4,8), 0, params)
			d.BulletsShot = d.BulletsShot + 1

			if d.BulletsShot > minBullets and npc.Position:Distance(target.Position) > detectRange then
				d.BulletsShot = 0
				d.State = "Finish"
			end

			local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, npc.Position, Vector(0,0), npc):ToEffect()
			creep.SpriteScale = Vector(d.BulletsShot, 1.5 * d.BulletsShot)
			creep:Update()
		end
	elseif d.State == "Finish" then
		mod:spritePlay(sprite, "Finish")

		if sprite:IsFinished("Finish") then
            d.hurting = nil
			mod:spritePlay(sprite, "Idle")
			d.State = "Idle"
		end
	end
end

function mod:WombPillarHurt(npc, damage, flag, source, countdown)
	local d = npc:GetData()
	local sprite = npc:GetSprite()
	
	if d.State == "Idle" then
		mod:spritePlay(sprite, "Charge")
		d.State = "Charge"
	end
	
	return false
end
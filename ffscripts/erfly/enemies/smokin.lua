local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:smokinAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()
	npc.SpriteOffset = Vector(0,-10)

	if not d.init then
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.SplatColor = mod.ColorCharred
		local distance = 9999
		local closest = nil
		npc.StateFrame = 30
		for _, fire in pairs(Isaac.FindByType(33, -1, -1, false, false)) do
			local firedist = fire.Position:Distance(npc.Position)
			if firedist < distance then
				distance = firedist
				closest = fire
			end
		end
		if closest and closest.HitPoints > 1 then
			d.state = "idle"
			npc.Parent = closest
			d.currenthealth = npc.Parent.HitPoints
		else
			npc:Remove()
		end
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	local distance = 20
	local speed = 3

	if d.state == "idle" then
		if npc.Parent then
			d.currenthealth = d.currenthealth or npc.Parent.HitPoints
			if npc.Parent.HitPoints < 2 then
				d.state = "FUCKINGPISSED"
				npc.StateFrame = 0
				mod:spritePlay(sprite, "Angered")
				d.orbitoffset = nil
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
				npc.Parent = mod.FindClosestEntity(target.Position, 99999, 1)
			elseif npc.Parent.HitPoints < d.currenthealth then
				d.currenthealth = npc.Parent.Hitpoints
				mod:spritePlay(sprite, "Angy")
			else
				if sprite:IsFinished("Angy") or not sprite:IsPlaying("Angy") then
					mod:spritePlay(sprite, "Float")
				end
			end

			if sprite:IsFinished("Angered") then
				mod:spritePlay(sprite, "FloatAnger")
			end
			if sprite:IsEventTriggered("Shoot") then
				npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1)
				npc:FireProjectiles(npc.Position, (target.Position - npc.Position):Normalized()*7, 0, ProjectileParams())
				for _, proj in pairs(Isaac.FindByType(9, 0, 0)) do
					if proj.FrameCount < 1 and proj.SpawnerType == npc.Type and proj.SpawnerVariant == npc.Variant then
						local pSprite = proj:GetSprite()
						pSprite:ReplaceSpritesheet(0, "gfx/projectiles/brisket_tear.png")
						pSprite:LoadGraphics()
						proj:GetData().customProjSplat = "gfx/projectiles/brisket_splat.png"
					end
				end
			end
		else
			d.state = "FUCKINGPISSED"
			npc.StateFrame = 0
			mod:spritePlay(sprite, "FireStart")
			d.orbitoffset = nil
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			npc.Parent = mod.FindClosestEntity(target.Position, 99999, 1)
		end
	elseif d.state == "FUCKINGPISSED" then
		npc.CanShutDoors = true
		distance = 140
		speed = 5
		if d.attacking then
			d.value = d.value or 0
			if d.value < 4 then
				d.value = d.value + 0.3
			end
			speed = 5 - d.value
			if sprite:IsFinished("FireStart") then
				d.attacking = false
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("FWOOM") then
				npc:PlaySound(mod.Sounds.FireLight, 1.5, 0, false, math.random(110,130)/100)
				d.flamin = true
				npc.SplatColor = mod.ColorFireJuicy
			elseif sprite:IsEventTriggered("Firestop") then
				d.flamin = false
				npc.SplatColor = mod.ColorCharred
			else
				mod:spritePlay(sprite, "FireStart")
			end
		else
			mod:spritePlay(sprite, "FloatAnger")
			d.value = d.value or 0
			if mod:isScareOrConfuse(npc) then
				if d.value < 4 then
					d.value = d.value + 0.3
				end
			elseif d.value > 0 then
				d.value = d.value - 0.3
			end
			speed = 5 - d.value
			if npc.StateFrame > 15 and not mod:isScareOrConfuse(npc) then
				d.attacking = true
			end
		end
	end

	if d.state then
		if d.flamin then
			if npc.FrameCount % 2 == 1 then
				local fire = Isaac.Spawn(1000,7005, 0, npc.Position, nilvector, npc):ToEffect()
				fire.Parent = npc
				fire:Update()
			end
		else
			local extravel = (npc.Velocity * -1):Rotated(-20 + math.random(40))
			local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position, extravel, npc)
			--smoke.SpriteScale = Vector(1.3,1.3)
			smoke.SpriteOffset = Vector(0, -10)
			smoke.SpriteRotation = math.random(360)
			smoke:Update()
		end
	end

	if npc.Parent then
		if not d.orbitoffset then
			d.orbitoffset = (npc.Parent.Position - npc.Position):GetAngleDegrees()
		end
		d.orbitoffset = d.orbitoffset + speed
		local targpos = (npc.Parent.Position + npc.Parent.Velocity * 10) + Vector(-1,1):Resized(distance):Rotated(d.orbitoffset + 45)
		local targvec = (targpos - npc.Position)
		local targvel = targvec:Resized(math.max(speed / 3, targvec:Length() / 10))
		npc.Velocity = targvel
	end
end

function mod:flaminChainAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()

	if not d.init then
		--npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.SplatColor = mod.ColorInvisible
		d.flaming = true
		npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_DEATH_TRIGGER | EntityFlag.FLAG_HIDE_HP_BAR | EntityFlag.FLAG_NO_FLASH_ON_DAMAGE | EntityFlag.FLAG_NO_REWARD)
		d.init = true
		npc.SpriteScale = npc.SpriteScale * 0.2
	end

	mod:spritePlay(sprite, "Idle")



	if npc.Child and npc.Parent and npc.Child.HitPoints > 1 then
		local p1 = npc.Parent.Position
		local p2 = npc.Child.Position
		local vec = p2 - p1
		npc.Position = p2 - vec * d.PeckingOrder[1] / d.PeckingOrder[2]
		local var = d.PeckingOrder[1] / d.PeckingOrder[2] * -10
		npc.SpriteOffset = Vector(0,var)

		if npc.Child.Variant ~= d.savedFireCol then
			local p = npc.Child
			local spriteReplace = ""
			if p.Variant == 1 then
				spriteReplace = "_red"
			elseif p.Variant == 2 then
				spriteReplace = "_blue"
			elseif p.Variant == 3 then
				spriteReplace = "_purple"
			end
			sprite:ReplaceSpritesheet(0, "gfx/enemies/smokin/chain" .. spriteReplace .. ".png")
			sprite:LoadGraphics()
			d.savedFireCol = p.Variant
		end
	else
		local blood = Isaac.Spawn(1000, 2, 10, npc.Position, nilvector, npc):ToEffect()
		if d.savedFireCol then
			blood.Color = mod.flaminSplatCols[d.savedFireCol]
		end
		npc:Kill()
	end
end

mod.flaminSplatCols = {
	[0] = Color(1,1,1,1,20 / 255,50 / 255,-50 / 255),
	[1] = Color(1,1,1,1,20 / 255,50 / 255,-50 / 255),
	[2] = Color(1,1,1,1,0 / 255,150 / 255,250 / 255),
	[3] = Color(1,1,1,1,50 / 255,0 / 255,150 / 255),
}

function mod:flaminAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()
	npc.SpriteOffset = Vector(0,-10)

	if not d.init then
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
		npc.SplatColor = mod.ColorInvisible
		npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
		d.flaming = true
		local distance = 9999
		local closest = nil
		npc.StateFrame = 30
		for _, fire in pairs(Isaac.FindByType(33, -1, -1, false, false)) do
			local firedist = fire.Position:Distance(npc.Position)
			if firedist < distance then
				distance = firedist
				closest = fire
			end
		end
		if closest and closest.HitPoints > 1 then
			d.state = "idle"
			d.savedFireCol = closest.Variant
			local spriteReplace
			if closest.Variant > 0 then
				if closest.Variant == 1 then
					spriteReplace = "_red"
				elseif closest.Variant == 2 then
					spriteReplace = "_blue"
				elseif closest.Variant == 3 then
					spriteReplace = "_purple"
				end
			end

			if spriteReplace then
				sprite:Load("gfx/enemies/smokin/monster_flamin" .. spriteReplace .. ".anm2", true)
			end

			npc.Parent = closest
			local vec = npc.Parent.Position - npc.Position

            d.numchains = FiendFolio.GetBits(npc.SubType, 1, 4) + 1
			for i = 1, d.numchains do
				local ball = Isaac.Spawn(mod.FF.FlaminChain.ID, mod.FF.FlaminChain.Var, 0, npc.Position + ((vec * i) / (d.numchains + 1)), nilvector, npc):ToNPC()
				ball.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
				ball.GridCollisionClass = GridCollisionClass.COLLISION_NONE
				ball:GetData().PeckingOrder = {i, d.numchains + 1}
				ball:GetData().savedFireCol = closest.Variant
				if spriteReplace then
					ball:GetSprite():Load("gfx/enemies/smokin/chain" .. spriteReplace .. ".anm2", true)
				end
				ball.Parent = npc
				ball.Child = npc.Parent
				ball:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				ball:Update()
			end
		else
			npc:Die()
		end
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	local distance = 50
	if d.numchains then
		distance = 25 * d.numchains
	end
	local speed = 5

	if mod:isScareOrConfuse(npc) then
		speed = speed * 0.5
	end

	if d.state == "idle" then
		if npc.Parent and npc.Parent.HitPoints > 1 then
			mod:spritePlay(sprite, "Fire")
			if npc.Parent.HitPoints < 2 then
				npc.Parent = nil
				npc.CollisionDamage = 0
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			elseif npc.Parent.HitPoints < 3 then
				speed = 7
				distance = distance * 2
			elseif npc.Parent.HitPoints < 4 then
				speed = 6
				distance = distance * 1.6
			elseif npc.Parent.HitPoints < 5 then
				speed = 5.5
				distance = distance * 1.3
			end
		else
			--[[-npc.Velocity = npc.Velocity * 0.92
			npc.CollisionDamage = 0
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			if sprite:IsFinished("FireEnd") then
				npc.SplatColor = mod.ColorCharred
				npc:Kill()
			else
				mod:spritePlay(sprite, "FireEnd")
			end]]
			npc.Velocity = nilvector
			local blood = Isaac.Spawn(1000, 2, 10, npc.Position, nilvector, npc):ToEffect()
			if d.savedFireCol then
				blood.Color = mod.flaminSplatCols[d.savedFireCol]
			end
			npc:Die()
		end
	end

	if npc.Parent then
		if not d.orbitoffset then
			d.orbitoffset = (npc.Parent.Position - npc.Position):GetAngleDegrees()
		end

        if FiendFolio.GetBits(npc.SubType, 0, 1) == 1 then
            d.orbitoffset = d.orbitoffset - speed
        else
            d.orbitoffset = d.orbitoffset + speed
        end

        local targpos = (npc.Parent.Position + npc.Parent.Velocity * 10) + Vector(-1,1):Resized(distance):Rotated(d.orbitoffset + 45)
		local targvec = (targpos - npc.Position)
		local targvel = targvec:Resized(math.max(speed / 3, targvec:Length() / 10))
		npc.Velocity = targvel

		if npc.Parent.Variant ~= d.savedFireCol then
			local p = npc.Parent
			local spriteReplace = ""
			if p.Variant == 1 then
				spriteReplace = "_red"
			elseif p.Variant == 2 then
				spriteReplace = "_blue"
			elseif p.Variant == 3 then
				spriteReplace = "_purple"
			end
			sprite:ReplaceSpritesheet(0, "gfx/enemies/smokin/monster_smokin" .. spriteReplace .. ".png")
			sprite:LoadGraphics()
			d.savedFireCol = p.Variant
		end
	end
end

--------------------------------------------------------------------------------------------
--Old shit

function mod:smokinUltimateAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()
	npc.SpriteOffset = Vector(0,-10)

	if not d.init then
		d.state = "idle"
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		npc.SplatColor = mod.ColorCharred
		local distance = 9999
		local closest = nil
		npc.StateFrame = 30
		for _, fire in pairs(Isaac.FindByType(33, -1, -1, false, false)) do
			local firedist = fire.Position:Distance(npc.Position)
			if firedist < distance then
				distance = firedist
				closest = fire
			end
		end
		if closest then
			npc.Parent = closest
		else
			npc:Remove()
		end
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	local distance = 50
	local speed = 3

	if d.state == "idle" then
		if npc.Parent then
			--Isaac.ConsoleOutput(npc.Parent.HitPoints .. "\n")
			if npc.Parent.HitPoints < 2 then
				d.state = "FUCKINGPISSED"
				mod:spritePlay(sprite, "FireStart")
				d.orbitoffset = nil
				d.waitingtorobit = true
				npc.Parent = mod.FindClosestEntity(target.Position, 99999, 1)
			elseif npc.Parent.HitPoints < 5 then
				speed = 5
				distance = 80
				if not d.hangon then
					mod:spritePlay(sprite, "Angered")
					d.orbitoffset = nil
					npc.StateFrame = -10
					d.hangon = true
				end
			else
				mod:spritePlay(sprite, "Float")
			end

			if sprite:IsFinished("Angered") then
				mod:spritePlay(sprite, "FloatAnger")
			end
		else
			d.state = "FUCKINGPISSED"
			mod:spritePlay(sprite, "FireStart")
			d.orbitoffset = nil
			--d.waitingtorobit = true
			npc.Parent = mod.FindClosestEntity(target.Position, 99999, 1)
		end
	elseif d.state == "FUCKINGPISSED" then
		npc.CanShutDoors = true
		distance = 140
		speed = 5
		if sprite:IsFinished("FireStart") then
			mod:spritePlay(sprite, "Fire")
		elseif sprite:IsEventTriggered("FWOOM") then
			d.flaming = true
			npc:PlaySound(mod.Sounds.FireLight, 0.6, 0, false, 1.2)
			npc.SplatColor = mod.ColorFireJuicy
		end

		if d.waitingtorobit then
			if npc.Parent then
				local targvel = (npc.Parent.Position - npc.Position):Resized(15)
				npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.2)
				if npc.Position:Distance(npc.Parent.Position) < 100 then
					d.waitingtorobit = false
					npc.StateFrame = -10
				end
			end
		end

		if d.flaming then
			if npc.StateFrame % 20 == 0 then
				local fire = Isaac.Spawn(1000,7005, 0, npc.Position, nilvector, npc):ToEffect()
				fire.Parent = npc
				fire:Update()
			end
		end
	end

	if npc.Parent then
		if not d.waitingtorobit then
			if not d.orbitoffset then
				d.orbitoffset = (npc.Parent.Position - npc.Position):GetAngleDegrees()
			end
			d.orbitoffset = d.orbitoffset + speed
			local targpos = (npc.Parent.Position + npc.Parent.Velocity * 10) + Vector(-1,1):Resized(distance):Rotated(d.orbitoffset + 45)
			local targvec = (targpos - npc.Position)
			local targvel = targvec:Resized(math.max(speed / 3, targvec:Length() / 10))
			npc.Velocity = targvel
		end
	end
end

function mod:recalculateOrbitalOffset(npcpos, targetpos, speed)
	local angle = (targetpos - npcpos):GetAngleDegrees()
	local calcdoffset = speed*math.pi + (angle / 360 * speed * math.pi * 2)
	return calcdoffset
end

function mod:orbitAI(npc, d, pos, clockwise, speed, distance, returnpos, lerp)
	speed = speed or 15
	distance = distance or 50
	lerp = lerp or 0.05
	if clockwise then
		clockwise = 1
	else
		clockwise = 0
	end
	if pos then
		local frame = npc.FrameCount
		if d then
			if d.orbitoffset then
				frame = -30 + npc.StateFrame + d.orbitoffset
			end
		end

		local xvel = math.cos(((frame * clockwise) / speed) + math.pi) * (distance)
		local yvel = math.sin(((frame * clockwise) / speed) + math.pi) * (distance)

		local newpos = Vector(pos.X - xvel, pos.Y - yvel)
		local direction = newpos - npc.Position

		if direction:Length() > distance then
			direction:Resize(distance)
		end
		if returnpos then
			return direction
		else
			npc.Position = mod:Lerp(npc.Position, newpos, lerp)
			npc.Velocity = mod:Lerp(npc.Velocity, direction, lerp)
		end
	end
end

function mod:smokinAIOLD(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()
	npc.SpriteOffset = Vector(0,-10)

	if not d.init then
		d.state = "idle"
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		npc.SplatColor = mod.ColorCharred
		local distance = 9999
		local closest = nil
		npc.StateFrame = 30
		for _, fire in pairs(Isaac.FindByType(33, -1, -1, false, false)) do
			local firedist = fire.Position:Distance(npc.Position)
			if firedist < distance then
				distance = firedist
				closest = fire
			end
		end
		if closest then
			npc.Parent = closest
		else
			npc:Remove()
		end
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	local distance = 50
	local speed = 15

	if d.state == "idle" then
		if npc.Parent then
			--Isaac.ConsoleOutput(npc.Parent.HitPoints .. "\n")
			if npc.Parent.HitPoints < 2 then
				d.state = "FUCKINGPISSED"
				mod:spritePlay(sprite, "FireStart")
				d.orbitoffset = nil
				d.waitingtorobit = true
				npc.Parent = mod.FindClosestEntity(target.Position, 99999, 1)
			elseif npc.Parent.HitPoints < 5 then
				speed = 7
				distance = 70
				if not d.hangon then
					mod:spritePlay(sprite, "Angered")
					d.orbitoffset = nil
					npc.StateFrame = -10
					d.hangon = true
				end
			else
				mod:spritePlay(sprite, "Float")
			end

			if sprite:IsFinished("Angered") then
				mod:spritePlay(sprite, "FloatAnger")
			end
		else
			d.state = "FUCKINGPISSED"
			mod:spritePlay(sprite, "FireStart")
			d.orbitoffset = nil
			d.waitingtorobit = true
			npc.Parent = mod.FindClosestEntity(target.Position, 99999, 1)
		end
	elseif d.state == "FUCKINGPISSED" then
		distance = 70
		speed = 7
		if sprite:IsFinished("FireStart") then
			mod:spritePlay(sprite, "Fire")
		elseif sprite:IsEventTriggered("FWOOM") then
			d.flaming = true
			npc:PlaySound(mod.Sounds.FireLight, 0.6, 0, false, 1.2)
			npc.SplatColor = mod.ColorFireJuicy
		end

		if d.waitingtorobit then
			if npc.Parent then
				local targvel = (npc.Parent.Position - npc.Position):Resized(15)
				npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.2)
				if npc.Position:Distance(npc.Parent.Position) < 100 then
					d.waitingtorobit = false
					npc.StateFrame = -10
				end
			end
		end

		if d.flaming then
			if npc.StateFrame % 20 == 0 then
				local fire = Isaac.Spawn(1000,7005, 0, npc.Position, nilvector, npc):ToEffect()
				fire.Parent = npc
				fire:Update()
			end
		end
	end

	if npc.Parent then
		if not d.waitingtorobit then
			if not d.orbitoffset then
				d.orbitoffset = mod:recalculateOrbitalOffset(npc.Position, npc.Parent.Position, speed)
			end
			mod:orbitAI(npc, d, npc.Parent.Position, true, speed, distance, false, 0.3)
		end
	end
end

function mod:Hurt(npc, damage, flag, source)
    if flag & DamageFlag.DAMAGE_FIRE ~= 0 and source.Type ~= 1 then
        return false
    end
end
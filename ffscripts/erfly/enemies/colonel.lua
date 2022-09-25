local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:colonelRelay(npc, subType)
    if subType == mod.FF.ColonelOld.Sub then
        mod:colonelAIOLD(npc)
    else
        mod:colonelAI(npc)
    end
end

function mod:colonelAI(npc, subt)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:confusePos(npc, target.Position)


	--TEMPORARY
	--npc:Morph(mod.FF.ColonelOld.ID, mod.FF.ColonelOld.Var, mod.FF.ColonelOld.Sub, -1)

	local beesub = mod.FF.Zingy.Var
	if subt == 1 then
		beesub = mod.FF.Zingling.Var
	end

	if not d.init then
		d.state = "idle"
		d.init = true
		npc.SpriteOffset = Vector(0, -20)
		d.respawncooldown = 2
		npc.StateFrame = 80
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Walk")
		if mod:isScare(npc) or npc.Position:Distance(targetpos) < 120 then
			d.targetvel = (targetpos - npc.Position):Resized(-4)
			d.running = true
		else
			if npc.StateFrame % 30 == 0 or d.running or (mod:isConfuse(npc) and npc.StateFrame % 5 == 0) then
				--local gridtarget = mod:FindRandomFreePosAir(target.Position, 120)
				d.targetvel = (targetpos - npc.Position):Resized(3):Rotated(mod:RandomInt(-90,90)) --(gridtarget - npc.Position):Resized(3)
				d.running = false
			end
		end
		if d.targetvel then
			npc.Velocity = mod:Lerp(npc.Velocity, d.targetvel, 0.05)
		end
		if npc.StateFrame > 100 and not (mod:isScareOrConfuse(npc)) then
			if not d.spawnedbees then
				d.state = "summon"
				d.spawnedbees = true
			else
				if d.beehurt then
					if d.nextattackwillbeshootinggg then
						d.state = "attack1"
						npc:PlaySound(mod.Sounds.BeeBuzzDown,1,0,false,0.5)
						d.nextattackwillbeshootinggg = false
					else
						d.state = "attack2"
						npc:PlaySound(mod.Sounds.BeeBuzzPrep,1,0,false,0.5)
						d.chargin = true
					end
				else
					d.state = "attack1"
					npc:PlaySound(mod.Sounds.BeeBuzzDown,1,0,false,0.5)
				end
				d.respawncooldown = d.respawncooldown - 1
			end
		end

	elseif d.state == "summon" then
		npc.Velocity = npc.Velocity * 0.95
		if sprite:IsFinished("Summon") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Summon") then
			sfx:Play(SoundEffect.SOUND_WHEEZY_COUGH, 0.5, 1, false, 0.6)
			local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position + Vector(0,10), nilvector, npc)
			smoke.SpriteScale = Vector(3.5,3.5)
			smoke.SpriteOffset = Vector(0, -20)
			smoke.RenderZOffset = 10000
			smoke:Update()
			local maxval = d.beeamount or 8 --npc.SubType
			for i = 1, maxval do
				local bee = mod.spawnent(npc, npc.Position, Vector(0,10):Rotated(-25 + math.random(50) + i * (360 / maxval)), mod.FFID.Erfly, beesub)
				bee.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
				bee.Parent = npc
			end
		elseif sprite:GetFrame() == 18 then
			mod.recomputateColonelOrbitals(npc)
		else
			mod:spritePlay(sprite, "Summon")
		end
	elseif d.state == "attack1" then
		npc.Velocity = npc.Velocity * 0.95
		if sprite:IsFinished("Attack1") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("BeeAttack") then
			for _, bee in pairs(Isaac.FindByType(mod.FF.Zingling.ID, beesub, 0, false, false)) do
				if bee.Parent and not bee:IsDead() then
					if bee.Parent.InitSeed == npc.InitSeed and not bee:GetData().IObeyNobody then
						bee:GetData().state = "shoot"
						bee:GetData().forcedvel = target.Position - bee.Position
						bee:GetData().target = target
					end
				end
			end
		else
			mod:spritePlay(sprite, "Attack1")
		end
	elseif d.state == "attack2" then
		npc.Velocity = npc.Velocity * 0.95
		if sprite:IsFinished("Attack2") then
			d.state = "idle"
			d.nextattackwillbeshootinggg = true
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("BeeShoot") then
			local closestDist = 99999
			local chosenOne
			for _, bee in pairs(Isaac.FindByType(mod.FF.Zingling.ID, beesub, 0, false, false)) do
				if bee.Parent and not bee:IsDead() then
					if bee.Parent.InitSeed == npc.InitSeed and not bee:GetData().IObeyNobody then
						if bee.Position:Distance(target.Position) < closestDist then
							closestDist = bee.Position:Distance(target.Position)
							chosenOne = bee
						end
					end
				end
			end
			if chosenOne then
				chosenOne:GetData().state = "chargestart"
				chosenOne:GetData().rotval = nil
				chosenOne:GetData().IObeyNobody = true
				chosenOne:GetData().forcedvel = chosenOne:ToNPC():GetPlayerTarget().Position - chosenOne.Position
			end
			mod.recomputateColonelOrbitals(npc)
		else
			mod:spritePlay(sprite, "Attack2")
		end
	end
end

mod.zingySuffix = {8,1,2,3,4,5,6,7}

function mod:zingyAI(npc)
    local sprite = npc:GetSprite()
    local d = npc:GetData()
    local target = npc:GetPlayerTarget()
    local r = npc:GetDropRNG()

	if not d.init then
		d.state = "idle"
		d.colltimer = 0
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end
	local vel = d.forcedvel or npc.Velocity 
	local AnimDir = mod.zingySuffix[math.floor(((mod:GetAngleDegreesButGood(vel))%360)/45) + 1]
	--local AnimDir = math.floor(((mod:GetAngleDegreesButGood(npc.Velocity) / 45 - 2) % 8) + 0.5)
	if AnimDir > 8 or AnimDir < 1 then print ("Zingy is misbehaving...") end
	if d.state == "chargestart" then
		npc.Velocity = npc.Velocity * 0.8
		if sprite:IsFinished("Shoot0" .. AnimDir) then
			d.state = "charge"
			d.forcedvel = nil
			mod:spritePlay(sprite, "Idle0" .. AnimDir)
			npc.StateFrame = 0
			npc.Velocity = mod:Lerp(npc.Velocity, (target.Position - npc.Position):Resized(40), 0.2)
			if npc.Parent then
				mod.recomputateColonelOrbitals(npc.Parent)
			end
			d.IObeyNobody = true
		else
			mod:spritePlay(sprite, "Shoot0" .. AnimDir)
		end
	elseif d.state == "charge" then
		npc.CollisionDamage = 1
		mod:spritePlay(sprite, "Idle0" .. AnimDir)
		npc.Velocity = mod:Lerp(npc.Velocity, (target.Position - npc.Position):Resized(40), 0.015)
		if npc:CollidesWithGrid() then
			if npc.Velocity:Length() > 4 and d.colltimer > 10 then
				d.state = "stuck"
				sfx:Play(SoundEffect.SOUND_GOOATTACH0, 0.5, 0, false, 1.5)
				d.stuckdir = AnimDir
				npc.StateFrame = 0
				npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
			end
			d.colltimer = 0
		else
			d.colltimer = d.colltimer + 1
		end
	elseif d.state == "stuck" then
		mod:spritePlay(sprite, "InWall0"..d.stuckdir)
		npc.Velocity = Vector.Zero
		npc.CanShutDoors = false
		if npc.StateFrame > 1500 then
			npc:Kill()
		else
			npc.StateFrame = npc.StateFrame + 1
		end
	elseif npc.Parent and npc.Parent:Exists() and not (mod:isStatusCorpse(npc.Parent) or npc.Parent:IsDead()) then
		if npc.HitPoints < npc.MaxHitPoints then
			npc.Parent:GetData().beehurt = true
		end
		if d.state == "shoot" then
			if sprite:IsFinished("Shoot0" .. AnimDir) then
				npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1)
				local shoottarget = d.target or target
				npc:FireProjectiles(npc.Position, (shoottarget.Position - npc.Position):Resized(9), 0, ProjectileParams())
				d.state = "idle"
				d.forcedvel = nil
				npc.StateFrame = 0		
			else
				mod:spritePlay(sprite, "Shoot0" .. AnimDir)
			end
		elseif d.state == "idle" then
			mod:spritePlay(sprite, "Idle0" .. AnimDir)
		end
		if npc:IsDead() then
			mod.recomputateColonelOrbitals(npc.Parent)
		elseif npc.Parent:IsDead() then
			npc.Parent = nil
		end

		if d.rotval then
			local target = npc.Parent.Position
			d.rotval = 1 + d.rotval
			local distance = 45

			local xvel = math.cos((d.rotval / 12) + math.pi) * (distance)
			local yvel = math.sin((d.rotval / 12) + math.pi) * (distance)

			local direction = Vector(target.X - xvel, target.Y - yvel) - npc.Position

			if direction:Length() > 10 then
				direction:Resize(10)
			end

			npc.Velocity = mod:Lerp(npc.Velocity, direction, 0.1  )
		else
			npc.Velocity = npc.Velocity * 0.9
		end
	else
		d.state = "chargestart"
		d.forcedvel = target.Position - npc.Position
		d.IObeyNobody = true
	end
end

function mod.recomputateColonelOrbitals(npc)
	if npc and npc:Exists() then
		local d = npc:GetData()
		local bees = {}
		for _, bee in pairs(Isaac.FindByType(mod.FF.Zingling.ID, mod.FF.Zingling.Var, 0, false, false)) do
			if bee.Parent and not bee:IsDead() then
				if bee.Parent.InitSeed == npc.InitSeed and not bee:GetData().IObeyNobody then
					local angle = (bee.Position - npc.Position):GetAngleDegrees()
					table.insert(bees, {bee, angle})
				end
			end
		end
		for _, bee in pairs(Isaac.FindByType(mod.FF.Zingy.ID, mod.FF.Zingy.Var, 0, false, false)) do
			if bee.Parent and not bee:IsDead() then
				if bee.Parent.InitSeed == npc.InitSeed and not bee:GetData().IObeyNobody then
					local angle = (bee.Position - npc.Position):GetAngleDegrees()
					table.insert(bees, {bee, angle})
				end
			end
		end
		table.sort(bees, function( a, b ) return a[2] < b[2] end )
		if #bees <= 2 and d.respawncooldown <= 0 then
			d.beeamount = 8 - #bees
			d.respawncooldown = 2
			d.spawnedbees = nil
			d.chargin = nil
			--Isaac.ConsoleOutput("a")
		--[[elseif #bees < 4 and npc.SubType == mod.FF.ColonelOld.Sub then 
			local d = npc:GetData()
			if not d.chargin then
				d.spawnedbees = nil
				d.beeamount = 8 - #bees 
			end]]
		end
		for i = 1, #bees do
			local d = bees[i][1]:GetData()
			d.rotval = ((75 / #bees) * i) + 35
		end
	end
end

function mod:colonelAIOLD(npc)
    local sprite = npc:GetSprite()
    local d = npc:GetData()
    local target = npc:GetPlayerTarget()

	if not d.init then
		d.state = "idle"
		d.init = true
		npc.SpriteOffset = Vector(0, -20)
		npc.StateFrame = 80
		local gridtarget = mod:FindRandomFreePosAir(target.Position, 120)
		d.targetvel = (gridtarget - npc.Position):Resized(3)
		d.shoots = 0
	else
		if d.chargin then
			npc.StateFrame = 0
		else
			npc.StateFrame = npc.StateFrame + 1
		end
	end
	if d.state == "idle" then
		mod:spritePlay(sprite, "Walk")
		if mod:isScare(npc) or npc.Position:Distance(target.Position) < 120 then
			d.targetvel = (target.Position - npc.Position):Resized(-6)
			d.running = true
		else
			if npc.StateFrame % 30 == 0 or d.running or (mod:isConfuse(npc) and npc.StateFrame % 5 == 0) then
				local gridtarget = mod:FindRandomFreePosAir(target.Position, 120)
				d.targetvel = (gridtarget - npc.Position):Resized(3)
				d.running = false
			end
		end
		npc.Velocity = mod:Lerp(npc.Velocity, d.targetvel, 0.05)
		if npc.StateFrame > 100 and not (d.chargin or mod:isScareOrConfuse(npc)) then
			if not d.spawnedbees then
				d.state = "summon"
				d.spawnedbees = true
			elseif d.beehurt then
				if d.shoots == 2 or (d.shoots == 1 and math.random(2) == 1) then
					d.state = "attack2"
					d.chargin = true
					d.shoots = 0
				else
					d.state = "attack1"
					d.shoots = d.shoots + 1
				end
			end
		end

	elseif d.state == "summon" then
		if sprite:IsFinished("Summon") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Summon") then
			sfx:Play(SoundEffect.SOUND_WHEEZY_COUGH, 0.5, 1, false, 0.9)
			local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position + Vector(0,10), nilvector, npc)
			smoke.SpriteScale = Vector(3.5,3.5)
			smoke.SpriteOffset = Vector(0, -20)
			smoke.RenderZOffset = 10000
			smoke:Update()
			local maxval = math.random(6,8)
			for i = 1, maxval do
				local bee = mod.spawnent(npc, npc.Position, Vector(0,10):Rotated(-25 + math.random(50) + i * (360 / maxval)), mod.FF.Zingling.ID, mod.FF.Zingling.Var)
				bee.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
				bee.Parent = npc
			end
		elseif sprite:GetFrame() == 18 then
			mod.recomputateColonelOrbitals(npc)
		else
			mod:spritePlay(sprite, "Summon")
		end
	elseif d.state == "attack1" then
		if sprite:IsFinished("Attack1") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("BeeAttack") then
			npc:PlaySound(SoundEffect["SOUND_LITTLE_HORN_GRUNT_" .. math.random(2)],1.3,2,false,0.5)
			for _, bee in pairs(Isaac.FindByType(mod.FF.Zingling.ID, mod.FF.Zingling.Var, 0, false, false)) do
				if bee.Parent and not bee:IsDead() then
					if bee.Parent.InitSeed == npc.InitSeed and not bee:GetData().IObeyNobody then
						bee:GetData().state = "shoot"
					end
				end
			end
		else
			mod:spritePlay(sprite, "Attack1")
		end
	elseif d.state == "attack2" then
		if sprite:IsFinished("Attack2") then
			d.state = "idle"
		elseif sprite:GetFrame() == 2 then
			for _, bee in pairs(Isaac.FindByType(mod.FF.Zingling.ID, mod.FF.Zingling.Var, 0, false, false)) do
				if bee.Parent and not bee:IsDead() then
					if bee.Parent.InitSeed == npc.InitSeed and not bee:GetData().IObeyNobody then
						bee:GetData().state = "chargestart"
					end
				end
			end
		elseif sprite:IsEventTriggered("BeeShoot") then
			npc:PlaySound(SoundEffect.SOUND_LITTLE_HORN_COUGH,1,2,false,0.7)
		else
			mod:spritePlay(sprite, "Attack2")
		end
	end
end

function mod:zinglingAI(npc)
    local sprite = npc:GetSprite()
    local d = npc:GetData()
    local target = npc:GetPlayerTarget()
    local r = npc:GetDropRNG()

	if not d.init then
		d.state = "idle"
		d.colltimer = 0
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if not (d.deadstate or d.state == "charge") then
		if target.Position.X < npc.Position.X then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end
	end

	if npc.Parent and not mod:isStatusCorpse(npc.Parent) then
		if npc.HitPoints < npc.MaxHitPoints then
			npc.Parent:GetData().beehurt = true
		end
		if d.state == "shoot" then
			if sprite:IsFinished("Attack01") then
				d.state = "idle"
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("Shoot") then
				npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1)
				npc:FireProjectiles(npc.Position, (target.Position - npc.Position):Resized(9), 0, ProjectileParams())
			else
				mod:spritePlay(sprite, "Attack01")
			end
		elseif d.state == "chargestart" then
			if sprite:IsFinished("ChargeStart") then
				d.state = "charge"
				mod:spritePlay(sprite, "Charge")
				npc.StateFrame = 0
				npc.Velocity = mod:Lerp(npc.Velocity, (target.Position - npc.Position):Resized(20), 0.4)
			else
				mod:spritePlay(sprite, "ChargeStart")
			end
		elseif d.state == "idle" then
			mod:spritePlay(sprite, "Fly")
		end
		if npc:IsDead() then
			mod.recomputateColonelOrbitals(npc.Parent)
		elseif npc.Parent:IsDead() then
			npc.Parent = nil
			d.state = "drop"
			d.deadstate = r:RandomInt(3) + 1
			npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		else
			if d.state == "charge" then
				npc.CollisionDamage = 1
				if npc.Velocity.X < 0 then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end

				if npc.StateFrame > 80 then
					npc.Parent:GetData().chargin = nil
					d.state = "idle"
					npc.CollisionDamage = 0
					d.waitval = 0
				end

				mod:spritePlay(sprite, "Charge")
				npc.Velocity = mod:Lerp(npc.Velocity, (target.Position - npc.Position):Resized(20), 0.03)
				if npc:CollidesWithGrid() then
					if npc.Velocity:Length() > 6 and d.colltimer > 10 then
						npc:Kill()
						mod.recomputateColonelOrbitals(npc.Parent)
					end
					d.colltimer = 0
				else
					d.colltimer = d.colltimer + 1
				end
			elseif d.rotval then
				local target = npc.Parent.Position
				d.rotval = 1 + d.rotval
				local distance = 60

				local xvel = math.cos((d.rotval / 12) + math.pi) * (distance)
				local yvel = math.sin((d.rotval / 12) + math.pi) * (distance)

				local direction = Vector(target.X - xvel, target.Y - yvel) - npc.Position

				if direction:Length() > 10 then
					direction:Resize(10)
				end

				npc.Velocity = mod:Lerp(npc.Velocity, direction, 0.1  )
			else
				npc.Velocity = npc.Velocity * 0.9
			end
		end
	else

		if not d.deadstate then
			local targetVelocity = (target.Position - npc.Position):Resized(1)
			if mod:isScare(npc) then
				targetVelocity = targetVelocity * -3
			elseif mod:isConfuse(npc) then
				targetVelocity = RandomVector() * 3
			end
			npc.Velocity = mod:Lerp(npc.Velocity, targetVelocity, 0.1)
		end


		if d.state == "idle" then
			mod:spritePlay(sprite, "Fly")
			if ((r:RandomInt(10)+1 == 1 and npc.StateFrame > 10) or npc.StateFrame > 60) and game:GetRoom():CheckLine(target.Position,npc.Position,3,900,false,false) and not (mod:isScareOrConfuse(npc) or mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE)) then
				if npc.HitPoints < npc.MaxHitPoints then
					d.state = "suicide"
				else
					d.state = "attack"
				end
			end
		elseif d.state == "attack" or d.state == "shoot" then
			if sprite:IsFinished("Attack01") then
				d.state = "idle"
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("Shoot") then
				npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1)
				npc:FireProjectiles(npc.Position, (target.Position - npc.Position):Resized(9), 0, ProjectileParams())
			else
				mod:spritePlay(sprite, "Attack01")
			end
		elseif d.state == "suicide" then
			if sprite:IsFinished("StingShoot") then
				d.state = "drop"
				d.deadstate = r:RandomInt(3) + 1
				npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
			elseif sprite:IsEventTriggered("Shoot") then
				npc:PlaySound(mod.Sounds.FrogShoot,0.7,0,false,math.random(12,14)/10)
				mod.shootStinger(npc, npc.Position, (target.Position - npc.Position):Resized(9))
			else
				mod:spritePlay(sprite, "StingShoot")
			end
		elseif d.state == "drop" then
			npc.Velocity = nilvector
			if sprite:IsFinished("Drop0" .. d.deadstate) then
				if npc.Pathfinder:HasPathToPos(target.Position, true) then
					npc.CanShutDoors = false
					d.state = "twitch"
				else
					npc:BloodExplode()
					npc:Remove()
				end
			elseif sprite:GetFrame() == 3 then --splat
				local landingzone = game:GetRoom():GetGridCollisionAtPos(npc.Position)
				if landingzone ~= GridCollisionClass.COLLISION_NONE then
					npc:BloodExplode()
					npc:Remove()
				else
					npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
					local creep = Isaac.Spawn(1000, 22, 0, npc.Position, nilvector, npc):ToEffect()
					creep:Update()
				end
			else
				mod:spritePlay(sprite, "Drop0" .. d.deadstate)
			end
		elseif d.state == "twitch" then
			npc.Velocity = nilvector
			if sprite:IsFinished("Twitch0" .. d.deadstate) then
				d.state = "dead"
				npc.StateFrame = 0
			elseif sprite:GetFrame() == 8 then
				local creep = Isaac.Spawn(1000, 22, 0, npc.Position, nilvector, npc):ToEffect()
				creep:Update()
			else
				mod:spritePlay(sprite, "Twitch0" .. d.deadstate)
			end
		elseif d.state == "dead" then
			npc.Velocity = nilvector
			mod:spritePlay(sprite, "Dead0" .. d.deadstate)
			if r:RandomInt(60) == 1 and npc.StateFrame > 50 then
				d.state = "twitch"
			end
		elseif d.state == "chargestart" then
			if sprite:IsFinished("ChargeStart") then
				d.state = "charge"
				npc.Velocity = nilvector
				mod:spritePlay(sprite, "Charge")
				npc.StateFrame = 0
				npc.Velocity = mod:Lerp(npc.Velocity, (target.Position - npc.Position):Resized(20), 0.4)
			else
				mod:spritePlay(sprite, "ChargeStart")
			end
		elseif d.state == "charge" then
			npc.CollisionDamage = 1
			if npc.Velocity.X < 0 then
				sprite.FlipX = true
			else
				sprite.FlipX = false
			end

			mod:spritePlay(sprite, "Charge")
			npc.Velocity = mod:Lerp(npc.Velocity, (target.Position - npc.Position):Resized(20), 0.03)

			if npc.StateFrame > 50 then
				d.state = "idle"
				npc.CollisionDamage = 0
			end

			if npc:CollidesWithGrid() then
				if npc.Velocity:Length() > 6 and d.colltimer > 10 then
					npc:Kill()
				end
				d.colltimer = 0
			else
				d.colltimer = d.colltimer + 1
			end
		else
			d.state = "idle"
			npc.StateFrame = 0
		end
	end
end

function mod.shootStinger(npc, pos, vec, maxcount)
	maxcount = maxcount or 5

	local stinger = mod.spawnent(npc, pos, vec, mod.FF.StingerProj.ID, mod.FF.StingerProj.Var)
	stinger:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	stinger.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
	stinger.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
	stinger:GetData().maxcount = maxcount
	stinger:Update()
end

function mod:stingerProjectileAI(npc)
    local d = npc:GetData()
	if not d.init then
		d.speed = npc.Velocity:Length()
		d.init = true
		d.maxcount = d.maxcount or 10
		d.count = 0
		npc.SpriteOffset = Vector(0, -15)
	end

	mod:spritePlay(npc:GetSprite(), "Idle")

	if npc:CollidesWithGrid() then
		d.count = d.count + 1
		if d.count > d.maxcount then
			local effect = Isaac.Spawn(1000,7014,0,npc.Position,nilvector,nil)
			effect.SpriteRotation = npc.SpriteRotation
			effect:Update()
			npc:Remove()
		else
			npc:PlaySound(mod.Sounds.Ricochet,1,0,false,1)
		end
	end

	npc.Velocity = npc.Velocity:Resized(d.speed)
	npc.SpriteRotation = npc.Velocity:GetAngleDegrees()
end
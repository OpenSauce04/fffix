local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:recalcZapBOffset(npc)
	local wires = {}
	local d = npc:GetData()
	d.babies = {}
	if d.lasers then
		for i = 1, #d.lasers do
			d.lasers[i][1]:Remove()
		end
	end
	d.lasers = {}

	local initialoffset
	for _, wire in pairs(Isaac.FindByType(mod.FF.Wire.ID, mod.FF.Wire.Var, -1, false, false)) do
		if wire:Exists() and not (wire:IsDead() or mod:isStatusCorpse(wire) or mod:isLeavingStatusCorpse(wire)) then
			if wire.Parent then
				if wire.Parent.InitSeed == npc.InitSeed then
					local wireD = wire:GetData()
					if #wires < 1 then
						table.insert(wires, wire)
					else
						for i = 1, #wires do
							if wireD.orbitoffset < wires[i]:GetData().orbitoffset then
								table.insert(wires, i, wire)
								break
							end
						end
						if wireD.orbitoffset > wires[#wires]:GetData().orbitoffset then
							table.insert(wires, wire)
						end
					end
				end
			end
		end
	end

	if #wires > 0 then
		local initialoffset = wires[1]:GetData().orbitoffset
		local divnum = #wires
		d.babies = {}

		for i = 1, divnum do
			wires[i]:GetData().orbitoffset = initialoffset + (360/divnum) * (i - 1)
			table.insert(d.babies, wires[i])
		end
	end
	npc:Update()
end

function mod:zapBladderAI(npc, subt)
	local sprite = npc:GetSprite()
	local path = npc.Pathfinder
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	npc.SpriteOffset = Vector(0, -10)

	if not d.init then
		d.state = "idle"
		npc.SplatColor = mod.ColorWaterPeople
		d.init = true
		npc.StateFrame = 40

		local spawnnum = 6
		if subt > 0 then
			spawnnum = subt
		end
		d.babies = {}
		for i = 1, spawnnum do
			local vecfun = Vector(0,10):Rotated(i * (360 / spawnnum))
			local wire = mod.spawnent(npc, npc.Position + vecfun, nilvector, mod.FF.Wire.ID, mod.FF.Wire.Var)
			wire.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			wire.Parent = npc
			wire:GetData().orbitoffset = i * (360 / spawnnum)
			table.insert(d.babies, wire)

			wire:Update()
		end
	else
		npc.StateFrame = npc.StateFrame + 1
		npc.Velocity = npc.Velocity * 0.96
	end

	if sprite:IsEventTriggered("Move") then
		npc:PlaySound(mod.Sounds.WaterSwish,0.7,0,false,math.random(90,110)/100)
		if mod:isScare(npc) then
			npc.Velocity = (target.Position - npc.Position):Resized(-5)
		elseif (not mod:isConfuse(npc)) and math.random(3) == 1 then
			npc.Velocity = (target.Position - npc.Position):Resized(5)
		else
			npc.Velocity = RandomVector() * 5
		end
	elseif sprite:IsEventTriggered("ZapStartActual") then
		npc.Velocity = (target.Position - npc.Position):Resized(3)
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Walk")
		if sprite:GetFrame() < 6 or sprite:GetFrame() > 37 then
			if (not mod:isScareOrConfuse(npc)) and #d.babies > 0 and npc.StateFrame > 50 and math.random(10) == 1 then
				d.state = "attacking"
				mod:spritePlay(sprite, "Attack")
			end
		end

	elseif d.state == "attacking" then
		if sprite:IsFinished("Attack") then
			mod:spritePlay(sprite, "AttackLoop")
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("ZapStart") then
			d.zappyzap = true
			npc:PlaySound(mod.Sounds.FrogHurgle,0.7,0,false,math.random(60,70)/100)
		end

		if (sprite:IsPlaying("AttackLoop") and npc.StateFrame > 90) or #d.babies < 1 or mod:isScareOrConfuse(npc) then
			d.state = "attackend"
			mod:spritePlay(sprite, "AttackEnd")
		end

	elseif d.state == "attackend" then
		if sprite:IsFinished("AttackEnd") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("ZapEnd") then
		--elseif sprite:GetFrame() == 2 then
			d.zappyzap = false
			sfx:Stop(mod.Sounds.LightningFlyBuzzLoop)
			npc:PlaySound(mod.Sounds.FrogHurgleShort,0.7,0,false,math.random(60,70)/100)
		else
			mod:spritePlay(sprite, "AttackEnd")
		end
	end

	if d.zappyzap and not sfx:IsPlaying(mod.Sounds.LightningFlyBuzzLoop) then
		sfx:Play(mod.Sounds.LightningFlyBuzzLoop, 0.5, 0, true, 1)
	end
	if not d.lasers then d.lasers = {} end
	if not d.babies then d.babies = {} end
	if #d.babies > 0 then
		for i = 1, #d.babies do
			local wire = d.babies[i]
			local wireD = wire:GetData()
			if wireD.zappin then
				--oh boy
				if not d.lasers[i] then
					local Ltarget = wire
					local source
					if #d.babies > 2 then
						if i == #d.babies then
							source = d.babies[1]
						else
							source = d.babies[i + 1]
						end
					else
						source = npc
					end
					local vec = Ltarget.Position - source.Position
					local laser = EntityLaser.ShootAngle(2, source.Position, vec:GetAngleDegrees(), 999999999, Vector(0, -30), source)
					laser.MaxDistance = vec:Length()
					laser.Color = Color(0,0,0,1,200 / 255,200 / 255,50 / 255)
					laser.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
					laser.CollisionDamage = 0
					laser:Update()
					Ltarget.Child = laser
					table.insert(d.lasers, {laser, source, Ltarget})
				end
			else
				for i = 1, #d.lasers do
					d.lasers[i][1]:Remove()
				end
				d.lasers = {}
			end
		end
	end

	if #d.lasers > 0 then
		for i = 1, #d.lasers do
			local vec = d.lasers[i][3].Position - d.lasers[i][2].Position
			local laser = d.lasers[i][1]
			laser.Angle = vec:GetAngleDegrees()
			laser.MaxDistance = vec:Length()
            laser.Mass = 0
			laser.Parent = d.lasers[i][2]
			laser.SpawnerEntity = d.lasers[i][2]
			laser:Update()
		end
	end

	if npc:IsDead() or mod:isLeavingStatusCorpse(npc) then
		sfx:Stop(mod.Sounds.LightningFlyBuzzLoop)
		if d.laser then
			for i = 1, #d.laser do
				d.laser[i]:Remove()
			end
		end
	end
end

function mod:wireAI(npc)
	local sprite = npc:GetSprite()
	local path = npc.Pathfinder
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	npc.SpriteOffset = Vector(0, -10)

	local distance = 75
	local speed = 5

	if not d.init then
		d.state = "idle"
		npc.SplatColor = mod.ColorWaterPeople
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Move01")
	elseif d.state == "zappin" then
		if sprite:IsFinished("Shock") then
			mod:spritePlay(sprite, "Move02")
		elseif sprite:IsEventTriggered("zap") then
			d.zappin = true
		end
	elseif d.state == "zapend" then
		if sprite:IsFinished("Normal") then
			d.state = "idle"
		elseif sprite:IsEventTriggered("zapdos") then
			d.zappin = false
		else
			mod:spritePlay(sprite, "Normal")
		end
	end


	if npc.Parent and not mod:isStatusCorpse(npc.Parent) then
		local pd = npc.Parent:GetData()

		if d.zappin then
			distance = 120
			speed = 3
		end

		if pd.zappyzap then
			if d.state == "idle" then
				d.state = "zappin"
				mod:spritePlay(sprite, "Shock")
			end
		elseif d.zappin then
			d.state = "zapend"
		end

		local targpos = npc.Parent.Position + Vector(0, distance):Rotated(d.orbitoffset)
		local targvec = (targpos - npc.Position)
		local targvel = targvec:Resized(math.min(10, targvec:Length() / 10))
		npc.Velocity = mod:Lerp(npc.Velocity, targvel, 1)

		d.orbitoffset = d.orbitoffset + speed

		if npc:IsDead() or mod:isLeavingStatusCorpse(npc) then
			mod:recalcZapBOffset(npc.Parent)
		end
	else
		d.state = "idle"
		if sprite:GetFrame() == 6 then
			--npc:PlaySound(mod.Sounds.WaterSwish,0.2,0,false,math.random(150,170)/100)
			if game:GetRoom():IsPositionInRoom(npc.Position, 0) then
				if d.outroom then
					npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
					d.outroom = false
				end
				if mod:isScare(npc) then
					npc.Velocity = (target.Position - npc.Position):Resized(-5)
				elseif mod:isConfuse(npc) or math.random(2) == 1 then
					npc.Velocity = RandomVector() * 5
				else
					npc.Velocity = (target.Position - npc.Position):Resized(5)
				end
			else
				d.outroom = true
				npc.Velocity = (target.Position - npc.Position):Resized(5)
			end
		end
		npc.Velocity = npc.Velocity * 0.9
		if npc.Child then
			npc.Child:Remove()
		end
	end
end
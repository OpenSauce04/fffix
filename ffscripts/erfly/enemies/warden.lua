local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:wardenAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	npc.SpriteOffset = Vector(0,-25)

	if not d.init then
		d.state = "idle"
		d.flapcount = 0
		d.init = true
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if npc.State == 11 then
		npc.Velocity = nilvector
		if sprite:IsFinished("Death") then
			for i = 30, 360, 30 do
				local expvec = Vector(0,math.random(10,35)):Rotated(i)
				local sparkle = Isaac.Spawn(1000, 1727, 0, npc.Position + expvec * 0.1, expvec * 0.3, npc):ToEffect()
				sparkle.SpriteOffset = Vector(0,-25)
				sparkle:Update()
			end
			npc:Kill()
		elseif sprite:IsEventTriggered("BloodStart") then
			d.bleeding = true
		elseif not sprite:IsPlaying("Death") then
			sprite:Play("Death", true)
		end
		if d.bleeding then
			if npc.FrameCount % 4 == 0 then
				local blood = Isaac.Spawn(1000, 5, 0, npc.Position, RandomVector()*3, npc):ToEffect();
				blood:Update()

				local bloo2 = Isaac.Spawn(1000, 2, 0, npc.Position, RandomVector()*3, npc):ToEffect();
				bloo2.SpriteScale = Vector(1,1)
				bloo2.SpriteOffset = Vector(-3+math.random(14), -45+math.random(40))
				bloo2:Update()

				npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,0.2,0,false,0.8)
			end
		end
	else
		if d.bleeding then
			d.bleeding = false
		end
		if not d.flickerspirited then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		end
		if d.state == "idle" then
			npc.Velocity = npc.Velocity * 0.96
			mod:spritePlay(sprite, "Idle")

			local becheckin = true
			local spawnshot = true
			for _, entity in pairs(Isaac.FindByType(1000, 1728, -1, false, false)) do
				if entity then becheckin = false end
			end
			for _, entity in pairs(Isaac.FindByType(mod.FF.WardenStar.ID, mod.FF.WardenStar.Var, mod.FF.WardenStarAbs.Sub, false, false)) do
				if entity then spawnshot = false end
			end

			if mod:isScareOrConfuse(npc) then
				becheckin = false
			end

			if sprite:IsEventTriggered("Floosh") then
				npc:PlaySound(mod.Sounds.WingFlap,0.5,0,false,math.random(110,130)/100)
				if d.flapcount == 0 then
					d.flapcount = 60
				else
					d.flapcount = 0
				end
				local mult = -7
				if becheckin then
					mult = 5
				end
				local vec = mod:randomVecConfuse(npc, ((target.Position-npc.Position):Resized(mult):Rotated(-30 + d.flapcount)), mult)
				npc.Velocity = mod:Lerp(npc.Velocity, vec, 0.5)
			end

			if becheckin and spawnshot and game:GetRoom():CheckLine(target.Position,npc.Position,3,900,false,false) and npc.StateFrame > 5 then
				d.state = "sparkle"
			end
		elseif d.state == "sparkle" then
			npc.Velocity = npc.Velocity * 0.96
			if sprite:IsFinished("Attack") then
				d.state = "idle"
				npc.StateFrame = 0
			elseif sprite:GetFrame() == 11 then
				npc:PlaySound(mod.Sounds.WardenCharge,1,0,false,1)
			elseif sprite:IsEventTriggered("Badoosh") then
				npc:PlaySound(mod.Sounds.WardenAttack,1,0,false,1)
				local vec = (target.Position + target.Velocity * 10) - npc.Position
				local cross = Isaac.Spawn(mod.FF.WardenStar.ID, mod.FF.WardenStar.Var, 0, npc.Position, vec:Resized(10), npc):ToNPC()
				cross:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				cross:Update()
			else
				mod:spritePlay(sprite, "Attack")
			end
		end
	end
end

function mod:wardenHurt(npc, damage, flag, source)
    if npc:ToNPC().State == 11 then
        return false
    end
end

function mod:wardenBallAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	if not d.init then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.SpriteOffset = Vector(0,-15)
		mod:spritePlay(sprite, "wee")
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
		d.movin = true
		d.init = true
	end

	if d.jivin then
		npc.Velocity = nilvector
		if sprite:IsFinished("ImpactWithPlayer") then
			npc:Remove()
		else
			mod:spritePlay(sprite, "ImpactWithPlayer")
		end
	elseif d.movin then
		local vec = ((target.Position + target.Velocity * 10) - npc.Position):Resized(10)
		local lerpval = math.max(0.05, 0.15 - (npc.FrameCount * 0.001))
		npc.Velocity = mod:Lerp(npc.Velocity, vec, lerpval)
		for _, entity in pairs(Isaac.FindByType(1000, 1728, -1, false, false)) do
			if entity then
				d.movin = false
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			end
		end
		if npc.FrameCount % 2 == 0 then
			local sparkle = Isaac.Spawn(1000, 1727, 0, npc.Position, nilvector, npc):ToEffect()
			sparkle.RenderZOffset = -5
			sparkle.SpriteOffset = Vector(-10 + math.random(20), -30 + math.random(20))
			--sparkle.SpriteScale = Vector(0.3,0.3)
		end
		local numwardens = mod.GetEntityCount(mod.FF.Warden.ID, mod.FF.Warden.Var)
		if npc:CollidesWithGrid() or (game:GetRoom():IsClear() and numwardens < 1) then
			d.movin = false
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		end
	else
		npc.Velocity = nilvector
		if sprite:IsFinished("Impact") then
			npc:Remove()
		else
			mod:spritePlay(sprite, "Impact")
		end
	end
end

function mod:WardenBarrier(e)
	local sprite = e:GetSprite()
	e.RenderZOffset = 37935

	--Animation funsies
	if sprite:IsFinished("Appear") then
		mod:spritePlay(sprite, "Idle")
	elseif sprite:IsFinished("Disapear") then
		e:Remove()
	elseif e.SubType ~= 1 and e.FrameCount > 150 then
		mod:spritePlay(sprite, "Disapear")
	end

	--Player movement
	for _, entity in pairs(Isaac.FindByType(1, -1, -1, false, false)) do
		local distance = entity.Position:Distance(e.Position)
		--[[if entity.Position:Distance(e.Position) > 180 then
			entity.Position = e.Position + (entity.Position - e.Position):Resized(100)
			sfx:Play(SoundEffect.SOUND_HELL_PORTAL1,1,0,false,1)
			entity.Velocity = nilvector]]
		if entity.Position:Distance(e.Position) > 120 then
			entity.Velocity = entity.Velocity + (e.Position - entity.Position):Resized(math.min(10, distance - 120))
			entity.Position = e.Position + (entity.Position - e.Position):Resized(120)
		end
	end

	--Sparkles
	local vec = RandomVector() * math.random(150, 250)
	local sparkpos = e.Position + vec
	if game:GetRoom():IsPositionInRoom(sparkpos, 0) then
		local sparkle = Isaac.Spawn(1000, 1727, 0, sparkpos, nilvector, e):ToEffect()
		sparkle:Update()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.WardenBarrier, 1728)

function mod:WardenSparkle(e)
	local d = e:GetData()
	local sprite = e:GetSprite()
	e.RenderZOffset = 97936
	d.SparkleValue = d.SparkleValue or math.random(6)

	if sprite:IsFinished(d.SparkleValue) then
		e:Remove()
	else
		mod:spritePlay(sprite, d.SparkleValue)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.WardenSparkle, 1727)
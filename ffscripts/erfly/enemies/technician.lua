local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:technicianAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not d.init then
		npc.SpriteOffset = Vector(0, -5)
		d.state = "idle"
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		if game:GetRoom():CheckLine(target.Position,npc.Position,3,900,false,false) and not mod:isScareOrConfuse(npc) then
			d.RandVec = d.RandVec or RandomVector():Resized(2)
			npc.Velocity = mod:Lerp(npc.Velocity, d.RandVec, 0.1)
			if ((npc.StateFrame > 60 and math.random(30)) or npc.StateFrame > 120) then
				d.state = "shoot"
				d.RandVec = nil
			end
		else
			d.RandVec = nil
			local targpos = mod:confusePos(npc, target.Position)
			local targvel = mod:reverseIfFear(npc, (targpos - npc.Position):Resized(2))
			npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.1)
		end
	elseif d.state == "shoot" then
		npc.Velocity = npc.Velocity * 0.9
		if sprite:IsFinished("Attack") then
			d.state = "shootEnd"
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_EDEN_GLITCH, 1, 0, false, math.random(70,80)/100)
			local proj = Isaac.Spawn(mod.FF.TechnicianProj.ID, mod.FF.TechnicianProj.Var, mod.FF.TechnicianProj.Sub, npc.Position, (target.Position - npc.Position):Resized(5), npc)
			proj.SpawnerEntity = npc
			npc.Child = proj
			proj:Update()
		else
			mod:spritePlay(sprite, "Attack")
		end
	elseif d.state == "shootEnd" then
		npc.Velocity = npc.Velocity * 0.9
		if npc.Child and npc.Child:Exists() then
			mod:spritePlay(sprite, "Idle2")
		else
			if sprite:IsFinished("AttackWinddown") then
				d.state = "idle"
				npc.StateFrame = 0
			else
				mod:spritePlay(sprite, "AttackWinddown")
			end
		end
	end
end

function mod:dieTechnicianProj(npc)
	npc:PlaySound(SoundEffect.SOUND_BULB_FLASH,1,2,false,math.random(110,130)/100)
	local death = Isaac.Spawn(1000, mod.FF.TechnicianProjEf.Var, mod.FF.TechnicianProjEf.Sub, npc.Position, nilvector, npc)
	death.SpriteOffset = npc.SpriteOffset
	death:GetSprite():Play("bulletdie", true)
	death:Update()
	npc:Remove()
end

function mod:technicianProjAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	if not d.init then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.SpriteOffset = Vector(0,-15)
		mod:spritePlay(sprite, "projectile")
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
		d.movin = true
		d.init = true
	end

	if d.jivin then
		npc.Velocity = nilvector
		if sprite:IsFinished("bulletdie") then
			npc:Remove()
		else
			mod:spritePlay(sprite, "bulletdie")
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
			sparkle.RenderZOffset = -50
			sparkle.SpriteRotation = math.random(360)
			sparkle.SpriteOffset = Vector(-10 + math.random(20), -20 + math.random(10))
			sparkle.Color = Color(5, 0, 0)
			sparkle.SpriteScale = Vector(0.3,0.3)
			sparkle:Update()
		end
		if npc:CollidesWithGrid() then
			mod:dieTechnicianProj(npc)
		end
	else
		mod:dieTechnicianProj(npc)
	end
end

function mod:dyingTechShotAI(e)
	local sprite = e:GetSprite()
	if sprite:IsFinished("bulletdie") then
		e:Remove()
	else
		mod:spritePlay(sprite, "bulletdie")
	end
end
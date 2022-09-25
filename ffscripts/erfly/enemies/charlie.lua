local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:charlieAI(npc)
	local sprite = npc:GetSprite()
	local path = npc.Pathfinder
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:confusePos(npc, target.Position)
	local r = npc:GetDropRNG()

	if not d.init then
		d.state = "idle"
		npc.SplatColor = mod.ColorCharred
		local headnum = math.random(10)
		mod:ReplaceEnemySpritesheet(npc, "gfx/enemies/smokey/charlie_head" .. headnum, 1);
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if npc:IsDead() then
		for i = -30, 30, 30 do
			local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position, Vector(0,-10):Rotated(i), npc)
			--smoke.SpriteScale = Vector(1,1)
			smoke.SpriteOffset = Vector(0, -10)
			smoke:Update()
		end
	end

	if d.state == "idle" then
		if npc.Velocity:Length() > 0.1 then
			npc:AnimWalkFrame("WalkHori","WalkVert",0)
		else
			sprite:SetFrame("WalkVert", 0)
		end

		if mod:isScare(npc) then
			local targetvel = (targetpos - npc.Position):Resized(-4)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
		elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
			local targetvel = (targetpos - npc.Position):Resized(4)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
		else
			path:FindGridPath(targetpos, 0.5, 900, true)
		end

		if npc.StateFrame > 50 and not mod:isScareOrConfuse(npc) then
			if r:RandomInt(20) == 0 then
				d.state = "attack"
				mod:spritePlay(sprite, "Attack")
			end
		end

	elseif d.state == "attack" then
		npc.Velocity = npc.Velocity * 0.9
		if sprite:IsFinished("Attack") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:GetFrame() == 5 then
			npc:PlaySound(mod.Sounds.CoughRasp,1,0,false,math.random(90,100)/100)
			local vel = ((targetpos - npc.Position) / 30)
			if vel:Length() > 13 then
				vel = vel:Resized(13)
			end
			local coal = Isaac.Spawn(9, 1, 0, npc.Position, vel, npc):ToProjectile()
			coal.SpawnerEntity = npc
			local coald = coal:GetData()
			coald.projType = "coal"
			coal.FallingSpeed = -20
			coal.FallingAccel = 1.2
			local coals = coal:GetSprite()
			coals:Load("gfx/projectiles/sooty_tear.anm2",true)
			coals:Play("spin",true)
			coal:Update()

			for i = 1, 5 do
				local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position, npc.Velocity * 1.3 + Vector(0,math.random(4,7)):Rotated(-60 + math.random(120)), npc):ToEffect()
				smoke.SpriteRotation = math.random(360)
				smoke.Color = Color(1,1,1,0.6,0,0,0)
				--smoke.SpriteScale = Vector(2,2)
				smoke.SpriteOffset = Vector(0, -16)
				smoke.RenderZOffset = 300
				smoke:Update()
			end
		else
			mod:spritePlay(sprite, "Attack")
		end

	end
end
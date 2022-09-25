local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:sootyAI(npc)
	local sprite = npc:GetSprite()
	local path = npc.Pathfinder
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:confusePos(npc, target.Position)
	local r = npc:GetDropRNG()

	if npc.Velocity:Length() > 0.1 then
		npc:AnimWalkFrame("WalkHori","WalkVert",0)
	else
		sprite:SetFrame("WalkVert", 0)
	end

	if not d.init then
		d.state = "idle"
		sprite:PlayOverlay("Head")
		npc.SplatColor = mod.ColorCharred
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

	if mod:isScare(npc) then
        local targetvel = (targetpos - npc.Position):Resized(-3)
        npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
	elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
		local targetvel = (targetpos - npc.Position):Resized(3)
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
	else
		path:FindGridPath(targetpos, 0.4, 900, true)
	end

	if d.state == "idle" then
		sprite:PlayOverlay("Head")
		if npc.StateFrame > 50 and not mod:isScareOrConfuse(npc) then
			if r:RandomInt(40) == 0 then
				d.state = "attack"
			end
		end
	elseif d.state == "attack" then
		if sprite:IsOverlayFinished("Attack") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:GetOverlayFrame() == 3 then
			npc:PlaySound(mod.Sounds.CoughRasp,1,0,false,math.random(90,100)/100)
			--local attackpos = mod:FindClosestUnlitPowder(npc.Position, npc, targetpos)
			local vel = (targetpos - npc.Position):Resized(7)
			local coal = Isaac.Spawn(9, 1, 0, npc.Position, vel, npc):ToProjectile()
			coal.SpawnerEntity = npc
			local coald = coal:GetData()
			coald.projType = "coal2"
			coald.projSpeed = 5
			coal.FallingSpeed = -15
			coal.FallingAccel = 1
			local coals = coal:GetSprite()
			coals:Load("gfx/projectiles/sooty_tear2.anm2",true)
			coals:Play("spin",true)
			coal:Update()

			for i = 1, 5 do
				local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position, npc.Velocity * 1.3 + Vector(0,math.random(4,7)):Rotated(-60 + math.random(120)), npc):ToEffect()
				smoke.SpriteRotation = math.random(360)
				smoke.Color = Color(2,2,2,0.3,180 / 255,95 / 255,-55 / 255)
				--smoke.SpriteScale = Vector(2,2)
				smoke.SpriteOffset = Vector(0, -26)
				smoke.RenderZOffset = 300
				smoke:Update()

				local ember = Isaac.Spawn(1000, 66, 0, npc.Position, npc.Velocity + Vector(0,math.random(2,4)):Rotated(-60 + math.random(120)) * 0.7, npc):ToEffect()
				ember:Update()
			end
		else
			mod:spriteOverlayPlay(sprite, "Attack")
		end
	end
end

function mod:checkSootyTearPoof(e)
	local sprite = e:GetSprite()
	if sprite:IsFinished("Destroy") then
		e:Remove()
	else
		mod:spritePlay(sprite, "Destroy")
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.checkSootyTearPoof, mod.FF.SootyTearPoof.Var)
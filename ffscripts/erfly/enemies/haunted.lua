local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:hauntedAI(npc)
	local sprite = npc:GetSprite()
	local path = npc.Pathfinder
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local r = npc:GetDropRNG()

	if not d.init then
		d.state = "idle"
		d.init = true
	elseif d.init then
		npc.StateFrame = npc.StateFrame + 1
	end

	if npc.Velocity:Length() > 0.1 then
		npc:AnimWalkFrame("WalkHori","WalkVert",0)
	else
		sprite:SetFrame("WalkVert", 0)
	end

	if mod:isScare(npc) then
		local targetvel = (targetpos - npc.Position):Resized(-5)
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
	elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
		local targetvel = (targetpos - npc.Position):Resized(4)
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
	else
		path:FindGridPath(targetpos, 0.6, 900, true)
	end

	if d.state == "idle" then
		sprite:PlayOverlay("Head",true)

		if npc.StateFrame > 30 and r:RandomInt(20)+1 == 1 and (targetpos - npc.Position):Length() < 200 and not mod:isScareOrConfuse(npc) then
			d.state = "shoot"
		end

	elseif d.state == "shoot" then
		if sprite:IsOverlayFinished("Shoot") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:GetOverlayFrame() == 10 then
			local params = ProjectileParams()
			params.BulletFlags = params.BulletFlags | ProjectileFlags.GHOST
			params.Variant = 4
			npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1)
			npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(11), 0, params)
		else
			mod:spriteOverlayPlay(sprite, "Shoot")
		end
	end


	if npc:IsDead() then
		local e = Isaac.Spawn(mod.FF.Yawner.ID, mod.FF.Yawner.Var, 0, npc.Position, nilvector, npc):ToNPC()
		e:GetData().ChangedHP = true
		e:GetData().HPIncrease = 0.1
	end

end

function mod:yawnerAI(npc)
	local target = npc:GetPlayerTarget()
	local sprite = npc:GetSprite()
	local targetpos = mod:randomConfuse(npc, target.Position)
	--local targetpos = target.Position + target.Velocity*10

	npc.SpriteOffset = Vector(0, -5)
	mod:spritePlay(sprite, "Move")

	if mod:isScare(npc) then
		mod:UnscareWhenOutOfRoom(npc)
		if npc.Position:Distance(target.Position) < 300 then
			local targetvel = (targetpos - npc.Position):Resized(-11)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.05)
		else
			npc.Velocity = npc.Velocity * 0.9
		end
	else
		local targetvel = (targetpos - npc.Position):Resized(11)
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.05)
	end

	npc.SplatColor = mod.ColorGhostly
end
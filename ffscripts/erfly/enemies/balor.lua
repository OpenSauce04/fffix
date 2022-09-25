local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:balorAI(npc, subt)
	local sprite = npc:GetSprite()
	local path = npc.Pathfinder
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
    local room = game:GetRoom()

	npc.StateFrame = npc.StateFrame + 1

	local creeptype = 22
	if subt == 1 then
		creeptype = 23
	end

	if npc.Velocity:Length() > 0.1 then
		npc:AnimWalkFrame("WalkHori","WalkVert",0)
	else
		sprite:SetFrame("WalkVert", 0)
	end

	if mod:isScare(npc) then
		local targetvel = (targetpos - npc.Position):Resized(-6)
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
	elseif room:CheckLine(npc.Position,targetpos,0,1,false,false) then
		local targetvel = (targetpos - npc.Position):Resized(4)
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
	else
		path:FindGridPath(targetpos, 0.6, 900, true)
	end

	if npc.FrameCount % (#mod.creepSpawnerCount/2) == 0 then
		if d.lastcreepleft then
			if d.lastcreepleft:Distance(npc.Position) > 15 then
				local creep = Isaac.Spawn(1000, creeptype, 0, npc.Position, nilvector, npc):ToEffect();
				creep.Scale = (0.7)
				creep:SetTimeout(30)
				creep:Update();
				d.lastcreepleft = npc.Position
			end
		else
			local creep = Isaac.Spawn(1000, creeptype, 0, npc.Position, nilvector, npc):ToEffect();
			creep.Scale = (0.7)
			creep:SetTimeout(30)
			creep:Update();
			d.lastcreepleft = npc.Position
		end
	end

	if npc.State == 4 then
		mod:spriteOverlayPlay(sprite, "Head")
		if npc.StateFrame > 50 and math.random(5) == 1 and room:CheckLine(npc.Position,targetpos,3,1,false,false) and npc.Position:Distance(targetpos) < 150 and not mod:isScareOrConfuse(npc) then
			npc.State = 8
		end
	elseif npc.State == 8 then
		if sprite:IsOverlayFinished("Attack") then
			npc.State = 4
			npc.StateFrame = 0
		elseif sprite:GetOverlayFrame() == 6 then
			npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1)
			local params = ProjectileParams()
			params.Scale = 2
			params.HeightModifier = 5
			params.FallingAccelModifier = -0.1
			if subt == 1 then
				params.BulletFlags = params.BulletFlags | ProjectileFlags.ACID_GREEN | ProjectileFlags.EXPLODE
				params.Color = mod.ColorIpecac
			else
				params.BulletFlags = params.BulletFlags | ProjectileFlags.RED_CREEP
			end
			local vec1 = (target.Position - npc.Position):Normalized()
			npc:FireProjectiles(npc.Position + vec1*10, vec1*7, 0, params)
		else
			mod:spriteOverlayPlay(sprite, "Attack")
		end
	else
		mod:spriteOverlayPlay(sprite, "Head")
		npc.State = 4
	end
end
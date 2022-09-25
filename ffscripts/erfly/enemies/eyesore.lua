local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:eyesoreAI(npc)
	local sprite = npc:GetSprite()
	local path = npc.Pathfinder
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = target.Position
    local room = game:GetRoom()

	npc.StateFrame = npc.StateFrame + 1

	if npc.Velocity:Length() > 0.1 then
		if d.eyeless then
			npc:AnimWalkFrame("WalkHoriBlood","WalkVertBlood",0)
		else
			npc:AnimWalkFrame("WalkHori","WalkVert",0)
		end
	else
		if d.eyeless then
			sprite:SetFrame("WalkVertBlood", 0)
		else
			sprite:SetFrame("WalkVert", 0)
		end
	end

	if room:CheckLine(npc.Position,targetpos,0,1,false,false) then
		local targetvel = (targetpos - npc.Position):Resized(4)
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
	else
		path:FindGridPath(targetpos, 0.6, 900, true)
	end

	if (not d.inMinecart) and npc.FrameCount % (#mod.creepSpawnerCount/2) == 0 and d.eyeless then
		if d.lastcreepleft then
			if d.lastcreepleft:Distance(npc.Position) > 15 then
				local creep = Isaac.Spawn(1000, 22, 0, npc.Position, nilvector, npc):ToEffect();
				creep.Scale = (0.7)
				creep:SetTimeout(20)
				creep:Update();
				d.lastcreepleft = npc.Position
			end
		else
			local creep = Isaac.Spawn(1000, 22, 0, npc.Position, nilvector, npc):ToEffect();
			creep.Scale = (0.7)
			creep:SetTimeout(30)
			creep:Update();
			d.lastcreepleft = npc.Position
		end
	end

	if npc.State == 4 then
		if d.eyeless then
			sprite:PlayOverlay("HeadBloody",true)
		else
			sprite:PlayOverlay("HeadNormal",true)
			if npc.StateFrame > 15 then
				npc.State = 8
				d.state = "shooteye"
			end
		end
		if npc.StateFrame > 50 and math.random(5) == 1 and room:CheckLine(npc.Position,targetpos,0,3,false,false) and npc.Position:Distance(targetpos) < 150 then
			npc.State = 8
			if d.eyeless then
				d.state = "shootnormal"
			else
				--residual
				d.state = "shooteye"
			end
		end
	elseif npc.State == 8 then
		if d.state == "shootnormal" then
			if sprite:IsOverlayFinished("ShootBloody") then
				npc.State = 4
				npc.StateFrame = 0
			elseif sprite:GetOverlayFrame() == 6 then
				npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1)
				local params = ProjectileParams()
				npc:FireBossProjectiles(4, target.Position, 10, params)
			else
				mod:spriteOverlayPlay(sprite, "ShootBloody")
			end
		elseif d.state == "shooteye" then
			if sprite:IsOverlayFinished("EyeShoot") then
				npc.State = 4
				npc.StateFrame = 0
				d.eyeless = true
			elseif sprite:GetOverlayFrame() == 6 then
				npc:PlaySound(SoundEffect.SOUND_PLOP,1,2,false,1)
				local vec1 = (target.Position - npc.Position):Normalized()
				local eye = mod.spawnent(npc, npc.Position + vec1*10, vec1*7, mod.FF.Gander.ID, mod.FF.Gander.Var)
				eye.Parent = npc
				eye:Update()
			else
				mod:spriteOverlayPlay(sprite, "EyeShoot")
			end
		end
	else
		sprite:PlayOverlay("HeadNormal",true)
		npc.State = 4
	end
end

function mod:ganderAI(npc)
	local sprite = npc:GetSprite()
	mod:spritePlay(sprite,"Eye")

	local targetvel = mod:diagonalMove(npc, 3.5, 1)
	npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.1)

	if npc.FrameCount < 2 then
		npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
	end

	if npc.FrameCount % 2 == 0 then
		local blood = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc)
		blood.SpriteScale = Vector(0.2,0.2)
		blood:Update()
	end

	if npc.Parent then
		if npc.Parent:IsDead() or mod:isStatusCorpse(npc.Parent) then
			npc:Kill()
		end
	else
		npc:Kill()
	end
end
local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:sourpatchAI(npc, subt)
	local d = npc:GetData()
	local sprite = npc:GetSprite();
	local path = npc.Pathfinder
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)

	sprite:PlayOverlay("Head")

	if not d.init then
		if subt == 1 then
			npc.SplatColor = mod.ColorIpecacProper
		else
			npc.SplatColor = mod.ColorLemonYellow
		end
		d.init = true
	end

	if npc.Velocity:Length() > 1 then
		npc:AnimWalkFrame("WalkHori","WalkVert",0)
	else
		sprite:SetFrame("WalkVert", 0)
	end

	if mod:isScare(npc) then
		local targetvel = (targetpos - npc.Position):Resized(-6)
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
	elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
		local targetvel = (targetpos - npc.Position):Resized(4)
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
	else
		path:FindGridPath(targetpos, 0.6, 900, true)
	end
end

function mod:sourpatchKill(npc)
    if not (npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) or npc:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) or mod:isLeavingStatusCorpse(npc)) then
        --Spawn head
		npc = npc:ToNPC()
        local targetpos = npc:ToNPC():GetPlayerTarget().Position
        local lemon = mod.spawnent(npc, npc.Position, (targetpos - npc.Position):Resized(-8), 29, 962, npc.SubType, 10):ToNPC()
        lemon:GetData().targ = game:GetRoom():FindFreeTilePosition(npc.Position + (targetpos - npc.Position):Resized(-200), 0)
        lemon:ToNPC().State = 10
        lemon.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		if npc:IsChampion() then
			lemon:MakeChampion(69, npc:GetChampionColorIdx(), true)
			lemon.HitPoints = lemon.MaxHitPoints
		end

        --Spawn body
        local spawned = Isaac.Spawn(mod.FF.SourpatchBody.ID, mod.FF.SourpatchBody.Var, npc.SubType, npc.Position, npc.Velocity, npc)
        spawned:ToNPC():Morph(spawned.Type, spawned.Variant, spawned.SubType, npc:ToNPC():GetChampionColorIdx())
        spawned.MaxHitPoints = 10
        spawned.HitPoints = npc.MaxHitPoints
        spawned:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

        if (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            spawned:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
        end

        npc:Remove()
    end
end

function mod:sourpatchBodyAI(npc, subt)
	local sprite = npc:GetSprite();
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder
	sprite:PlayOverlay("Blood")

	if not d.init then
		if subt == 1 then
			npc.SplatColor = mod.ColorIpecacProper
		else
			npc.SplatColor = mod.ColorLemonYellow
		end
		d.gopos = RandomVector()*40
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if mod:isScare(npc) then
		local targetvel = (target.Position - npc.Position):Resized(-4)
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
	elseif d.gopos then
		path:EvadeTarget(npc.Position + (d.gopos-npc.Position):Resized(-5))
		if game:GetRoom():CheckLine(npc.Position,d.gopos,0,1,false,false) then
			local targetvel = (d.gopos - npc.Position):Resized(4):Rotated(-25 + math.random(50))
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.07)
		else
			--Isaac.ConsoleOutput("a")
			if npc.FrameCount % 3 == 1 then
				mod:CatheryPathFinding(npc, d.gopos, {
                    Speed = 4,
                    Accel = 0.14,
                    GiveUp = true
                })
			end
		end
	else
		d.gopos = RandomVector()*40
	end

	if npc.StateFrame % 20 == 1 then
		d.gopos = mod:FindRandomValidPathPosition(npc, 3)
	end
	if npc.StateFrame % 10 == 1 and not mod:isScareOrConfuse(npc) then
		local shootvec = npc.Velocity:Resized(8)
		if subt == 1 then
			local proj = Isaac.Spawn(9, 0, 0, npc.Position, shootvec, npc):ToProjectile()
			proj.Color = mod.ColorSpittyGreen
			proj.FallingSpeed = 1
			proj.FallingAccel = 0.5
			local pd = proj:GetData()
			pd.projType = "acidic splot"
		else
			local params = ProjectileParams()
			params.FallingSpeedModifier = -8
			params.FallingAccelModifier = 1.5
			params.Color = mod.ColorLemonYellow
			npc:FireProjectiles(npc.Position, shootvec, 0, params)
		end
		mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc, 1.5, 0.6)
	end

	if npc.Velocity:Length() > 0.1 then
		npc:AnimWalkFrame("WalkHori","WalkVert",0)
		if npc.FrameCount % 10 == 1 then
			local blood = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc)
			blood.SpriteScale = Vector(0.6,0.6)
			if subt == 1 then
				blood.Color = mod.ColorIpecacProper
			else
				blood.Color = mod.ColorLemonYellow
			end
			blood:Update()
		end
	else
		sprite:SetFrame("WalkVert", 0)
	end
end

function mod:sourpatchHeadAI(npc, subt)
	local d = npc:GetData()
	local sprite = npc:GetSprite()

	if not d.init then
		if subt == 1 then
			npc.SplatColor = mod.ColorIpecacProper
		else
			npc.SplatColor = mod.ColorLemonYellow
		end
		d.init = true
	end

	if sprite:IsEventTriggered("Bounce") then
		local creepnum = 24
		if subt == 1 then creepnum = 23 end
		local creep = Isaac.Spawn(1000, creepnum, 0, npc.Position, nilvector, npc):ToEffect();
		mod:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH, npc, 1.5, 0.6)
		creep.SpriteScale = creep.SpriteScale * 1.5
		creep:SetTimeout(90)
		creep:Update();
	end

	if npc.State == 4 then
		if npc.Velocity.X < 0 then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end
		if npc.StateFrame > 24 then
			npc.State = 5
		end
	elseif npc.State == 5 then
		if npc.StateFrame > 34 then
			npc.State = 3
		end
	elseif npc.State == 10 then
		if sprite:IsFinished("HopOff") then
			npc.State = 5
			npc.StateFrame = 20
		elseif sprite:IsEventTriggered("Stop") then
			d.stopped = true
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc.Velocity = npc.Velocity * 0.7
		else
			mod:spritePlay(sprite, "HopOff")
			if not d.targ then
				d.targ = game:GetRoom():FindFreeTilePosition(npc.Position + npc.Velocity*200, 0)
			end
			if not d.stopped then
				local targetvel = (d.targ - npc.Position):Resized(13)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.7)
			else
				npc.Velocity = npc.Velocity * 0.7
			end
		end
	end

	if subt == 1 and npc:IsDead() then
		Isaac.Explode(npc.Position, npc, 10)
		npc:Kill()
	end
end

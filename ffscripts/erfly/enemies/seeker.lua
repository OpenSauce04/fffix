local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:seekerAI(npc, subt)
	local sprite = npc:GetSprite();
	local d = npc:GetData();
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder

	if not d.init then
		d.state = "idle"
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if sprite:IsEventTriggered("Whoosh") then
		sfx:Play(mod.Sounds.WingFlap,0.5,0,false,math.random(120,130)/100)
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")

		if mod:isScare(npc) then
			npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position - target.Position):Resized(5), 0.2)
		else
			d.walktarg = d.walktarg or mod:FindRandomValidPathPosition(npc)
			if npc.Position:Distance(d.walktarg) < 10 or (mod:isConfuse(npc) and npc.FrameCount % 10 == 0) then
				d.walktarg = mod:FindRandomValidPathPosition(npc, 2)
			end
			path:FindGridPath(d.walktarg, 1, 900, false)
		end
		if npc.StateFrame > 45 and not mod:isScareOrConfuse(npc) then
			d.state = "shoot"
			npc.StateFrame = 0
			sfx:Play(mod.Sounds.PinballHit,2,0,false,math.random(50,60)/100)
		end
	elseif d.state == "shoot" then
        local room = game:GetRoom()
		local pos = room:GetGridPosition(room:GetGridIndex(npc.Position))
		npc.Position = mod:Lerp(npc.Position, pos, 0.1)
		npc.Velocity = npc.Velocity * 0.9
		d.walktarg = nil
		if sprite:IsFinished("Shoot") then
			d.state = "idle"
			npc.StateFrame = 0
		--elseif sprite:IsEventTriggered("Cronch") then
		elseif sprite:IsEventTriggered("Shoot") then
			d.shootin = true
		elseif sprite:IsEventTriggered("ShootStop") then
			d.shootin = false
		else
			mod:spritePlay(sprite, "Shoot")
		end
	end

	if d.shootin and npc.StateFrame % 2 == 0 and not mod:isScareOrConfuse(npc) then
		npc:PlaySound(mod.Sounds.WatcherEyeShoot,0.7,2,false,math.random(50,80)/100)
		local projectile = Isaac.Spawn(9, 0, 0, npc.Position, (target.Position - npc.Position):Resized(1), npc):ToProjectile();
		local projdata = projectile:GetData();
		projectile.FallingSpeed = 0
		projectile.FallingAccel = -0.1
		projectile.Height = -20
		projectile.Color = mod.ColorDarkPurpleGrape
		projectile:AddProjectileFlags(ProjectileFlags.BOUNCE)
		projdata.projType = "seekerTear"
		projectile.Parent = npc
	end
end

function mod.seekerProjectiles(v,d)
	if d.projType == "seekerTear" then
		if v.Parent then
			if v.Parent:IsDead() then
				d.mode = 2
			end
			d.targetpos = v.Parent:ToNPC():GetPlayerTarget().Position
		else
			d.targetpos = game:GetNearestPlayer(v.Position).Position
		end
		--[[if d.seekerLeader then
			d.targetpos = game:GetNearestPlayer(v.Position).Position
			d.prevPoses = d.prevPoses or {}
			d.prevPoses[v.FrameCount] = v.Position
		else
			if v.Parent and v.Parent:GetData().prevPoses then
				local potential = v.Parent:GetData().prevPoses[v.FrameCount + 2]
				if potential then
					d.targetpos = potential
				end
			end
		end]]
		v.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
		if not d.mode then
			if v.FrameCount < 60 and d.targetpos then
				mod:CatheryPathFinding(v, d.targetpos, {
				Speed = 7,
				Accel = 0.3,
				Threshold = 400,
				GiveUp = false,
				})
			else
				d.mode = 2
			end
			--[[if v.Velocity:Length() < 0.1 or (v.Position:Distance(d.targetpos) < 50 and game:GetRoom():CheckLine(v.Position,d.targetpos,0,1,false,false)) then
				d.mode = 2
			end]]
		elseif d.mode == 2 then
			v.FallingSpeed = 3
			v.FallingAccel = 0
			v.Velocity = v.Velocity * 0.95
			v:ClearProjectileFlags(ProjectileFlags.BOUNCE)
			d.mode = 0
		end
	end
end
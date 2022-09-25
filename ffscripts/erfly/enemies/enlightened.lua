local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:innerEyeAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder

	if not d.init then
		d.state = "idle"
		npc.SplatColor = mod.ColorPsy3ForMe
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		if sprite:IsFinished("Hop") or sprite:IsFinished("BiggerHop") or sprite:IsFinished("Appear") or sprite:IsFinished("Fall") or sprite:IsFinished("Land") then
			d.landing = false
			local speed = 5

			local host = mod.FindClosestSpecificEntity(npc.Position, mod.FF.Unenlightened.ID, mod.FF.Unenlightened.Var, mod.FF.Unenlightened.Sub, nil, path)
			if host and npc.Position:Distance(host.Position) < 100 then
				d.state = "input"
				npc.Parent = host
			else
				if not mod:isScareOrConfuse(npc) and d.CanShoot then
					local params = ProjectileParams()
					params.BulletFlags = params.BulletFlags | ProjectileFlags.SMART
					params.HomingStrength = 0.5
					params.Scale = 0.5
					params.FallingSpeedModifier = 1.8
					params.HeightModifier = 5
					npc:FireProjectiles(npc.Position, (target.Position - npc.Position):Resized(8), 0, params)
					d.CanShoot = false
				else
					d.CanShoot = true
				end
				if math.random(2) == 1 then
					sprite:Play("Hop", true)
					npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,1,0,false,1)
				else
					sprite:Play("BiggerHop", true)
					npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,1,0,false,0.7)
					speed = 7
				end

				local targetpos
				if mod:isCharmOrBerserk(npc) then
					targetpos = target.Position
				elseif mod:isScare(npc) then
					targetpos = target.Position
				elseif host then
					targetpos = host.Position
				else
					targetpos = mod:FindRandomValidPathPosition(npc)
				end

				local room = Game():GetRoom()
				if room:CheckLine(npc.Position,targetpos,0,1,false,false) and mod:isScare(npc) then
					npc.Velocity = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(speed))
				else
					path:FindGridPath(targetpos, speed * 0.6, 900, false)
				end
			end

		elseif sprite:IsEventTriggered("Land") then
			d.landing = true
			npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS,1,2,false,1.3)
			local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, npc.Position, nilvector, npc):ToEffect();
			creep.Color = Color(1,1,10,1,0,0,0)
			creep:SetTimeout(60)
			creep:Update()
		end
		if d.landing then
			npc.Velocity = npc.Velocity * 0.3
		end
	elseif d.state == "input" then
		if npc.Parent and npc.Parent.SubType == 1 then
			if sprite:IsFinished("JumpIntoHost") then
				npc.Parent.SubType = 0
				npc.Parent:GetData().ieHealth = npc.HitPoints
				npc.Parent:GetData().lobtimer = mod:RandomInt(120,240)
				npc.Parent:GetData().state = "activated"
				npc.Parent:GetData().launchedEye = false
				npc.Parent:ToNPC().CanShutDoors = true
				mod:spriteOverlayPlay(npc.Parent:GetSprite(), "HeadActivated")
				npc.Parent:Update()
				npc:Remove()
			elseif sprite:IsPlaying("JumpIntoHost") and sprite:GetFrame() == 12 then
				npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,1,2,false,0.7)
			elseif sprite:WasEventTriggered("Jumped") then
				npc.Velocity = (npc.Parent.Position - npc.Position) * 0.2
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			else
				npc.Velocity = npc.Velocity * 0.3
				mod:spritePlay(sprite, "JumpIntoHost")
			end
		else
			d.state = "idle"
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			mod:spritePlay(sprite, "Land")
			npc.Parent = nil
			d.landing = true
		end
	elseif d.state == "launched" then
		npc.Velocity = nilvector
		if sprite:IsFinished("Launch") then
			d.state = "indicate"
			npc.StateFrame = 0
            local room = game:GetRoom()
			if room:GetGridCollisionAtPos(target.Position) ~= GridCollisionClass.COLLISION_NONE then
				if d.safepos then
					npc.Position = d.safepos
				else
					npc.Position = Isaac.GetFreeNearPosition(target.Position, 0)
				end
			else
				npc.Position = target.Position
			end
		else
			mod:spritePlay(sprite, "Launch")
		end
	elseif d.state == "indicate" then
		npc.Velocity = nilvector
		mod:spriteOverlayPlay(sprite, "Indicator")
		if npc.StateFrame > 5 then
			d.state = "fall"
		end
	elseif d.state == "fall" then
		if sprite:IsFinished("Fall") then
			d.state = "idle"
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		elseif sprite:IsEventTriggered("Land") then
			sprite:RemoveOverlay()
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS,1,2,false,1)
			local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, npc.Position, nilvector, npc):ToEffect();
			creep.Color = Color(1,1,10,1,0,0,0)
			creep.SpriteScale = creep.SpriteScale * 3
			creep:SetTimeout(60)
			creep:Update()
			local effect = Isaac.Spawn(1000,16,3,npc.Position,Vector.Zero,npc):ToEffect()
			effect.Color = mod.ColorPsy3ForMe
			effect.DepthOffset = creep.Position.Y * 1.25
			effect:GetSprite().Scale = effect:GetSprite().Scale * 0.75

			d.state = "idle"
			d.landing = true
		else
			mod:spritePlay(sprite, "Fall")
		end
	end
end

function mod:enlightenedAI(npc, subt)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder
	local target = npc:GetPlayerTarget()
	local targetpos = mod:confusePos(npc, target.Position)

	if not d.init then
		d.state = "idle"
		d.lobtimer = d.lobtimer or mod:RandomInt(120,240)
		d.init = true
		npc.StateFrame = 20
		--npc.SplatColor = Color(0,0,0,1,20 / 255,10 / 255,10 / 255);
	else
		npc.StateFrame = npc.StateFrame + 1
		d.lobtimer = d.lobtimer or mod:RandomInt(120,240)
		d.lobtimer = d.lobtimer - 1
	end

	if subt == 1 then
		if npc.CanShutDoors then
			npc.CanShutDoors = false
			npc.CollisionDamage = 0
		end
		npc.Velocity = npc.Velocity * 0.3
		sprite:SetFrame("BodyInactive", 0)
		if not sprite:IsOverlayPlaying("HeadLaunch") then
			sprite:SetOverlayFrame("HeadInactive", 0)
		end
	else
		if not npc.CanShutDoors then
			npc.CanShutDoors = true
			npc.CollisionDamage = 1
		end
		if d.state == "idle" then
			mod:spriteOverlayPlay(sprite, "Head")
			if not mod:isScareOrConfuse(npc) then
				if npc.StateFrame > 60 and math.random(15) == 1 then
					d.state = "attack"
					mod:spriteOverlayPlay(sprite, "HeadShoot")
				elseif d.lobtimer <= 0 and game:GetRoom():GetGridCollisionAtPos(target.Position) == GridCollisionClass.COLLISION_NONE then
					d.state = "lob"
					d.safepos = target.Position
				end
			end
		elseif d.state == "attack" then
			npc.Velocity = npc.Velocity * 0.5
			if sprite:IsOverlayFinished("HeadShoot") then
				d.state = "idle"
				npc.StateFrame = 0
			elseif sprite:GetOverlayFrame() == 11 then
				npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1)
				npc.Velocity = npc.Velocity * 0.1
				local params = ProjectileParams()
				params.BulletFlags = params.BulletFlags | ProjectileFlags.SMART
				params.HomingStrength = 0.3
				for i = 90, 360, 90 do
					npc:FireProjectiles(npc.Position + npc.Velocity:Resized(10), Vector(9,0):Rotated(i), 0, params)
				end
				local effect = Isaac.Spawn(1000, 2, 5, npc.Position, npc.Velocity, npc):ToEffect()
				effect.SpriteOffset = Vector(0,-22)
				effect:FollowParent(npc)
				effect.DepthOffset = npc.Position.Y * 1.25
				effect.Color =  Color(1,1,10,0.5)
			elseif sprite:GetOverlayFrame() == 28 then
				npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1)
				npc.Velocity = npc.Velocity * 0.1
				local params = ProjectileParams()
				params.BulletFlags = params.BulletFlags | ProjectileFlags.SMART
				params.HomingStrength = 0.3
				for i = 45, 315, 90 do
					npc:FireProjectiles(npc.Position + npc.Velocity:Resized(10), Vector(9,0):Rotated(i), 0, params)
				end
				local effect = Isaac.Spawn(1000, 2, 5, npc.Position, npc.Velocity, npc):ToEffect()
				effect.SpriteOffset = Vector(0,-22)
				effect:FollowParent(npc)
				effect.DepthOffset = npc.Position.Y * 1.25
				effect.Color =  Color(1,1,10,0.5)
			else
				mod:spriteOverlayPlay(sprite, "HeadShoot")
			end
		elseif d.state == "lob" then
			npc.Velocity = npc.Velocity * 0.5
			if sprite:IsOverlayFinished("HeadLaunch") then
				npc.SubType = 1
			elseif sprite:IsOverlayPlaying("HeadLaunch") and sprite:GetOverlayFrame() == 24 then
				npc.SubType = 1
				local ieye = Isaac.Spawn(mod.FF.InnerEye.ID, mod.FF.InnerEye.Var, 0, npc.Position, nilvector, npc):ToNPC()
				ieye.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				if d.ieHealth then
					ieye.HitPoints = d.ieHealth
				end
				ieye:GetData().state = "launched"
				ieye:GetData().init = true
				ieye.SplatColor = mod.ColorPsy3ForMe
				ieye:GetData().safepos = d.safepos
				ieye:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				ieye:GetData().ChangedHP = true
				ieye:GetData().HPIncrease = 0.1
				ieye:Update()
				npc:PlaySound(mod.Sounds.PiperAttack,1,0,false,math.random(90,110)/100)
				local effect = Isaac.Spawn(1000, 2, 3, npc.Position, npc.Velocity, npc):ToEffect()
				effect.SpriteOffset = Vector(0,-22)
				effect:FollowParent(npc)
				effect.DepthOffset = npc.Position.Y * 1.25
				effect.Color = mod.ColorPsy3ForMe --Color(1,1,10,1)
				d.launchedEye = true
			else
				mod:spriteOverlayPlay(sprite, "HeadLaunch")
			end
		elseif d.state == "activated" then
			if sprite:IsOverlayFinished("HeadActivated") then
				d.state = "idle"
				npc.StateFrame = 0
			else
				mod:spriteOverlayPlay(sprite, "HeadActivated")
			end
		end

		if npc.Velocity:Length() > 0.1 then
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

		if npc:IsDead() and not d.launchedEye then
			local innerEye = Isaac.Spawn(mod.FF.InnerEye.ID, mod.FF.InnerEye.Var, 0, npc.Position, nilvector, npc):ToNPC()
			if d.ieHealth then
				innerEye.HitPoints = d.ieHealth
			end
			innerEye:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			innerEye:GetData().ChangedHP = true
			innerEye:GetData().HPIncrease = 0.1
			innerEye:Update()
		end
	end
end

function mod:enlightenedHurt(npc, damage, flag, source)
    if npc.SubType == mod.FF.Unenlightened.Sub then
        if flag == flag | DamageFlag.DAMAGE_EXPLOSION or flag == flag | DamageFlag.DAMAGE_TNT then
            npc.HitPoints = 0.0
        else
            return false
        end
    end
end
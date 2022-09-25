local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:bowlerRelay(npc, subType, variant)
    if subType == mod.FF.BowlerHead.Sub then
        mod:bowlerHeadAI(npc, variant)
    else
        mod:bowlerAI(npc, subType, variant)
    end
end

function mod:bowlerAI(npc, subt, var)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder
	local r = npc:GetDropRNG()
    local room = game:GetRoom()

	if not d.init then
		d.state = "appear"
		if subt == 1 then
			d.headstate = 2
			sprite:SetFrame("WalkDown02", 0)
		else
			d.headstate = 1
			sprite:SetFrame("WalkDown01", 0)
		end
		d.headhealth = npc.MaxHitPoints
		npc.StateFrame = 40
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "appear" then
		sprite:SetFrame("WalkDown0" .. d.headstate, 0)
		d.state = "idle"
		npc.StateFrame = 0
	elseif d.state == "idle" then
		local sframe = npc.StateFrame % 32
		d.dir = d.dir or "Down"

		if d.headstate == 1 and d.headhealth < 0 and var ~= 761 and not mod:isLeavingStatusCorpse(npc) then
			d.headstate = 2
			npc:BloodExplode()
		end

		if d.moving then
			local truetarg = target
			local speed = 4
			if d.headstate == 2 and not mod:isScareOrConfuse(npc) then
				speed = 5
				truetarg = mod.FindClosestEntity(npc.Position, 999999, npc.Type, var, 2, npc)
				if truetarg then
					if npc.Position:Distance(truetarg.Position) < 20 then
						d.state = "pickup"
						npc.Child = truetarg
						truetarg.Parent = npc
					end
				end
			end
			if truetarg and not mod:isConfuse(npc) then
				if room:CheckLine(npc.Position,truetarg.Position,0,1,false,false) or mod:isScare(npc) then
					local targetvel = mod:reverseIfFear(npc, (truetarg.Position - npc.Position):Resized(speed))
					npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
				else
					if path:HasPathToPos(truetarg.Position, false) then
						path:FindGridPath(truetarg.Position, 0.6, 900, false)
					else
						d.randir = d.randir or RandomVector():Resized(speed)
						npc.Velocity = mod:Lerp(npc.Velocity, d.randir, 0.25)
					end
				end
			else
				d.randir = d.randir or RandomVector():Resized(speed)
				npc.Velocity = mod:Lerp(npc.Velocity, d.randir, 0.25)
			end

			if math.abs(npc.Velocity.Y) > math.abs(npc.Velocity.X) then
				if npc.Velocity.Y > 0 then
					d.dir = "Down"
				else
					d.dir = "Up"
				end
			else
				d.dir = "Hori"
				if npc.Velocity.X > 0 then
					sprite.FlipX = false
				else
					sprite.FlipX = true
				end
			end
		else
			npc.Velocity = npc.Velocity * 0.75
			d.randir = nil
		end

		sprite:SetFrame("Walk" .. d.dir .. "0" .. d.headstate, sframe)
		if sprite:IsEventTriggered("StartStep") or sframe == 2 or sframe == 18 then
			d.moving = true
		elseif sprite:IsEventTriggered("StopStep") or sframe == 9 or sframe == 25 then
			d.moving = false
			npc:PlaySound(SoundEffect.SOUND_SCAMPER, 0.3, 0, false, 0.6)
		end

		if npc.StateFrame > 90 and d.headstate == 1 and (var == 761 or room:CheckLine(npc.Position,target.Position,0,1,false,false)) then
			if npc.Position:Distance(target.Position) < 200 and not mod:isScareOrConfuse(npc) then
				d.state = "throwheadstart"
				if target.Position.X > npc.Position.X then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end
			end
		end
	elseif d.state == "throwheadstart" then
		npc.Velocity = npc.Velocity * 0.9
		if d.headhealth < 0 and var ~= 761 then
			npc:BloodExplode()
			d.state = "idle"
			d.dir = "Down"
		end
		if sprite:IsFinished("HeadThrowStart") then
			npc:PlaySound(SoundEffect.SOUND_SHELLGAME, 1, 0, false, 0.7)
			d.state = "throwhead"
			d.throwtarg = target.Position
			d.vec = (d.throwtarg - npc.Position)
			if math.abs(d.vec.Y) > math.abs(d.vec.X) and d.vec.Y < 0 then
				d.throwdir = 2
			else
				d.throwdir = 1
			end
			if d.vec.X > 0 then
				sprite.FlipX = true
			else
				sprite.FlipX = false
			end
		else
			mod:spritePlay(sprite, "HeadThrowStart")
		end
	elseif d.state == "throwhead" then
		if d.headhealth < 0 and (not d.thrown) and var ~= 761  then
			npc:BloodExplode()
			d.state = "idle"
			d.dir = "Down"
			d.headstate = 2
			d.thrown = nil
		end
		if sprite:IsFinished("HeadThrowShoot0" .. d.throwdir) then
			d.state = "idle"
			d.dir = "Down"
			d.thrown = nil
			d.headstate = 2
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			local speed = 12
			if var == 761 then
				speed = 16
			end
			local head = Isaac.Spawn(npc.Type, var, 2, npc.Position + d.vec:Resized(10), d.vec:Resized(speed), npc)
			head:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			head.HitPoints = d.headhealth
			head:GetData().ChangedHP = true
			head:GetData().HPIncrease = 0.1
			head:Update()
			d.headstate = 2
			d.thrown = true
		elseif sprite:IsEventTriggered("Hop") then
			d.hoppin = true
		elseif sprite:IsEventTriggered("Land") then
			d.hoppin = false
			npc:PlaySound(SoundEffect.SOUND_SCAMPER, 0.3, 0, false, 0.6)
		else
			mod:spritePlay(sprite, "HeadThrowShoot0" .. d.throwdir)
		end

		if d.hoppin then
			npc.Velocity = mod:Lerp(npc.Velocity, d.vec:Resized(4), 0.3)
		else
			npc.Velocity = npc.Velocity * 0.75
		end
	elseif d.state == "pickup" then
		if not (npc.Child or d.picked) then
			d.state = "idle"
			d.picked = false
			d.dir = "Down"
			d.headstate = 2
			npc.StateFrame = 0
		elseif d.picked then
			npc.Velocity = npc.Velocity * 0.75
			if d.headhealth < 0 then
				npc:BloodExplode()
				d.state = "idle"
				d.picked = false
				d.dir = "Down"
				d.headstate = 2
			end
		elseif npc.Child then
			local targvel = ((npc.Child.Position + Vector(0, -10)) - npc.Position)
			npc.Velocity = mod:Lerp(npc.Velocity, targvel:Resized(targvel:Length()/3), 0.25)
		end

		if sprite:IsFinished("Recover") then
			d.state = "idle"
			d.dir = "Down"
			d.headstate = 1
			npc.StateFrame = 0
			d.picked = false
		elseif sprite:IsEventTriggered("Pick") and npc.Child then
			sfx:Stop(mod.Sounds.RolyPolyRoll)
			npc:PlaySound(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1)
			d.headhealth = npc.Child.HitPoints
			npc.Child:Remove()
			d.headstate = 1
			d.picked = true
		else
			mod:spritePlay(sprite, "Recover")
		end
	end

	if npc:IsDead() and var == mod.FF.Striker.Var and d.headstate == 1 then
		local head = Isaac.Spawn(mod.FF.StrikerHead.ID, mod.FF.StrikerHead.Var, mod.FF.StrikerHead.Sub, npc.Position, npc.Velocity, npc)
		head:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		head:Update()
	end
end

function mod:bowlerHeadAI(npc, var)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
	npc.SpriteOffset = Vector(0,-8)

	if not d.init then
		if var == 761 then
			npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_BLOOD_SPLASH)
		end
	end

	--picking up
	if npc.Parent then
		npc.Velocity = npc.Velocity * 0.1
	end

	local speed = npc.Velocity:Length()
	local targvel = (target.Position - npc.Position):Resized(speed)
	if speed < 0.5 then
		npc.Velocity = npc.Velocity * 0.9
		if d.startedit and sfx:IsPlaying(mod.Sounds.RolyPolyRoll) then
			sfx:Stop(mod.Sounds.RolyPolyRoll)
			d.startedit = nil
		end
		if var == 761 and game:GetRoom():IsClear() then
			npc:Kill()
		end
	else
		if var == 761 then
			npc.Velocity = npc.Velocity * 0.98
			if npc.Velocity:Length() > 3 then
				for k,v in ipairs(mod.GetGridEntities()) do
					if v.Position:Distance(npc.Position + npc.Velocity) < 45 then
						if v:Destroy() then
							local r = npc:GetDropRNG()
							local params = ProjectileParams()
							params.Variant = 9
							params.FallingAccelModifier = 1.5
							params.Scale = 0.9
							for i = 60, 360, 60 do
								params.FallingSpeedModifier = -30 + math.random(10)
								local rand = r:RandomFloat()
								npc:FireProjectiles(v.Position, Vector(0,2):Rotated(i-40+rand*80), 0, params)
								--[[local rand = r:RandomFloat()
								local coal = Isaac.Spawn(9, 3, 0, v.Position, Vector(0,2):Rotated(i-40+rand*80), npc):ToProjectile()
								local coald = coal:GetData()
								coald.projType = "coalButActuallyRock"
								coal.FallingSpeed = -10 + math.random(5) - npc.Velocity:Length()
								coal.FallingAccel = 1.2
								local coals = coal:GetSprite()
								coals:Load("gfx/projectiles/sooty_tear_rock.anm2",true)
								coals:Play("spin",true)
								coal.SpriteScale = coal.SpriteScale * 0.7
								coal:Update()]]
							end
						end
					end
				end

				if npc:CollidesWithGrid() then
					Game():ShakeScreen(5)
					npc:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND,0.5,2,false,2.6)
				end
			end
		else
			npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.15) * 0.98
		end

		if not sfx:IsPlaying(mod.Sounds.RolyPolyRoll) then
			sfx:Play(mod.Sounds.RolyPolyRoll, 0.5, 0, true, 0.7)
			d.startedit = true
		end
		if var == 769 and npc.FrameCount % 3 == 0 then
			local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_GREEN, 0, npc.Position, nilvector, npc):ToEffect();
			creep:Update()
		end

		if speed > 3 then
			npc.StateFrame = npc.StateFrame + 1
		else
			if npc.FrameCount % 2 == 1 then
				npc.StateFrame = npc.StateFrame + 1
			end
		end
	end

	if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
		d.dir = "Hori"
		if npc.Velocity.X > 0 then
			sprite.FlipX = false
		else
			sprite.FlipX = true
		end
	else
		if npc.Velocity.Y > 0 then
			d.dir = "Down"
		else
			d.dir = "Up"
		end
	end

	if npc:HasMortalDamage() then
		sfx:Stop(mod.Sounds.RolyPolyRoll)
	end

	sprite:SetFrame("HeadRoll" .. d.dir, npc.StateFrame % 16)
end

function mod:bowlerHurt(npc, damage, flag, source)
    local variant = npc.Variant
    local subt = npc.SubType
    if variant == mod.FF.StrikerHead.Var and subt == mod.FF.StrikerHead.Sub then
        return false
    end
    if subt ~= mod.FF.StrikerHead.Sub then
        local d = npc:GetData()
        if d.headhealth then
            d.headhealth = d.headhealth - damage
        end
    end
end
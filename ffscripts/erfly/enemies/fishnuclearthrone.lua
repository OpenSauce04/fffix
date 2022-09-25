local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local function GetFishTarget(npc)
	local filter = function(_, npc)
		if npc.Type == mod.FFID.GuwahJoke and (npc.Variant == mod.FF.IDPDGrunt.Var or npc.Variant == mod.FF.IDPDInspector.Var or npc.Variant == mod.FF.IDPDShielder.Var) then
			return true
		end
	end

	local popo
	local dist = 9999
	for _, idpd in pairs(mod:GetAllEnemies(filter)) do
		if idpd.Position:Distance(npc.Position) < dist then
			popo = idpd
			dist = popo.Position:Distance(npc.Position)
		end
	end

	if popo then
		return popo
    else
        return npc:GetPlayerTarget()
    end
end

function mod:oopsWrongGame(npc)
	local d = npc:GetData()
	local sprite = npc:GetSprite()
	local target = GetFishTarget(npc)
	local path = npc.Pathfinder
	local targetpos = target.Position
    local room = game:GetRoom()

	if not d.init then
		d.init = true
		d.state = "idle"

		npc:PlaySound(mod.Sounds.FishAppearVA,1,0,false,1)

		local gun = Isaac.Spawn(1000, 1741, 0, npc.Position, nilvector, npc):ToEffect()
		npc.Child = gun
		gun.Parent = npc
		gun:Update()
	else
		npc.StateFrame = npc.StateFrame + 1
		d.count = d.count or 0
		d.count2 = d.count2 or 0
		d.count = d.count + 1
		d.count2 = d.count2 + 1
	end

	if npc.HitPoints < npc.MaxHitPoints * 0.4 and not d.screamed then
		npc:PlaySound(mod.Sounds.FishHurtVA,1,0,false,1)
		d.screamed = true
	end

	if d.state == "idle" then
		if not sprite:IsPlaying("Hurt") then
			if npc.Velocity:Length() > 0.1 then
				mod:spritePlay(sprite, "Walk")
			else
				mod:spritePlay(sprite, "Idle")
			end
		end

		local closeTear = nil
		for _, tear in pairs(Isaac.FindByType(2, -1, -1, false, false)) do
			if tear.Position:Distance(npc.Position) < 60 then
				closeTear = true
			end
		end
		for _, proj in pairs(Isaac.FindByType(9, -1, -1, false, false)) do
			if proj:ToProjectile():HasProjectileFlags(ProjectileFlags.HIT_ENEMIES) and proj.Position:Distance(npc.Position) < 60 then
				closeTear = true
			end
		end
		d.count2 = d.count2 or 0
		if closeTear and d.count2 > 20 then
			d.state = "roll"
			npc.Velocity = RandomVector() * 11
			npc:PlaySound(mod.Sounds.FishRoll,1,0,false,math.random(90,110)/100)
			if math.random(3) == 1 then
				npc:PlaySound(mod.Sounds.FishRollVA,1,0,false,math.random(90,110)/100)
			end
		end

		if mod:isScare(npc) or (room:CheckLine(npc.Position,targetpos,3,1,false,false) and npc.Position:Distance(targetpos) > 250 and not npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION)) then
			npc.StateFrame = 0
			d.walktarg = npc.Position
			local targetvel = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(3.5))
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)

		else
			if npc.StateFrame > 160 or not d.walktarg then
				d.walktarg = mod:FindRandomValidPathPosition(npc)
				npc.StateFrame = 0
			end
			if npc.Position:Distance(d.walktarg) > 30 then
				if room:CheckLine(npc.Position,d.walktarg,0,1,false,false) then
					local targetvel = (d.walktarg - npc.Position):Resized(3)
					npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
				else
					path:FindGridPath(d.walktarg, 0.5, 900, true)
				end
			else
				npc.Velocity = npc.Velocity * 0.9
				npc.StateFrame = npc.StateFrame + 2
			end
		end
	elseif d.state == "roll" then
		mod:spritePlay(sprite, "Roll")
		npc.SpriteRotation = npc.SpriteRotation + 30
		local extravel = (npc.Velocity * -1):Rotated(-20 + math.random(40))
		local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 960, npc.Position, extravel, npc)
		--smoke.SpriteScale = Vector(1.3,1.3)
		--smoke.SpriteOffset = Vector(0, -20)
		smoke.SpriteRotation = math.random(360)
		smoke.Color = Color(1,1,1,1,75 / 255,70 / 255,50 / 255)
		smoke:Update()

		if npc.SpriteRotation > 359 then
			npc.SpriteRotation = 0
			d.state = "idle"
			d.count2 = 0
		end
	end

	if npc.Child then
		local g = npc.Child
		local gs = g:GetSprite()
		local gd = g:GetData()

		if room:CheckLine(npc.Position,targetpos,2,1,false,true) and not mod:isScareOrConfuse(npc) then
			gd.tpos = targetpos
			d.count = d.count or 0
			if d.count > 9 and math.random(15) then
				npc:PlaySound(mod.Sounds.ShotgunBlast,1,0,false,math.random(12,14)/10)
				local params = ProjectileParams()
				params.Variant = mod.FF.FrogProjectile.Var
				params.BulletFlags = ProjectileFlags.HIT_ENEMIES
				params.Scale = 0.3
				params.HeightModifier = 15
				params.FallingAccelModifier = -0.1
				params.FallingSpeedModifier = 0
				npc:FireProjectiles(g.Position, (g.Position - npc.Position):Resized(11), 0, params)
				--game:ShakeScreen(5)
				d.count = 0
			end
		else
			gd.tpos = nil
		end
	else
		local gun = Isaac.Spawn(1000, 1741, 0, npc.Position, nilvector, npc):ToEffect()
		npc.Child = gun
		gun.Parent = npc
		gun:Update()
	end
end

function mod:fishNuclearThroneHurt(npc, damage, flag, source)
	local sprite = npc:GetSprite()
	if not sprite:IsPlaying("Roll") then
		mod:spritePlay(sprite, "Hurt")
	end
end

function mod:theRevolverAI(npc)
	local d = npc:GetData()
	local sprite = npc:GetSprite()

	if npc.Parent then
		npc.SpriteOffset = Vector(0,-7)
		mod:spritePlay(sprite, "Gun")
		local p = npc.Parent
		d.pPos = p.Position
		local target
		if d.tpos then
			target = p.Position + (d.tpos - p.Position):Resized(15)
		else
			target = p.Position + p.Velocity:Resized(15)
		end
		if target.X < p.Position.X then
			p:GetSprite().FlipX = true
			sprite.FlipX = true
		else
			p:GetSprite().FlipX = false
			sprite.FlipX = false
		end
		local targPos = target - npc.Position
		npc.Velocity = mod:Lerp(npc.Velocity, targPos, 0.3	)
		local realAng = (npc.Position - p.Position):GetAngleDegrees()
		if sprite.FlipX then
			npc.SpriteRotation = (realAng * -1) + 180
		else
			npc.SpriteRotation = realAng
		end
	else
		npc.SpriteRotation = 0
		mod:spritePlay(sprite, "Dead")
		npc.SpriteOffset = Vector(0,0)
		npc.Velocity = nilvector
		if d.pPos and not d.moved then
			npc.Position = d.pPos
			d.moved = true
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.theRevolverAI, 1741)
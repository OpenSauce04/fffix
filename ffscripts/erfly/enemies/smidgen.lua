local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:smidgenAI(npc, subt, var)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not d.init then
		d.init = true
		d.invincible = true
		if not d.ShootInit then
			d.state = "idle"
		end
		npc.SpriteOffset = Vector(0,-1)
		if subt == 1 then
			d.skullhealth = 5
			mod:ReplaceEnemySpritesheet(npc, "gfx/enemies/baby host/tinyErodedBroken", 0)
		end
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.invincible then
		if npc.Variant == mod.FF.Tittle.Var then
			local vec = mod:diagonalMove(npc, 4, true)
			npc.Velocity = mod:Lerp(npc.Velocity, vec, 0.15)
		else
			npc.Velocity = npc.Velocity * 0.9
		end
		if var ~= 862 and not npc:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
			npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
		end
	else
		if npc.Variant == mod.FF.Tittle.Var then
			local vec = mod:diagonalMove(npc, 2, true)
			npc.Velocity = mod:Lerp(npc.Velocity, vec, 0.15)
		else
			npc.Velocity = npc.Velocity * 0.75
		end
		if npc:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
		end
	end

	if subt ~= 1 and d.skullhealth and d.skullhealth < 0 then
		npc:PlaySound(SoundEffect.SOUND_ROCK_CRUMBLE, 0.7, 0, false, 1.3)
		for i = 1, 5 do
			local Vec = RandomVector()
			local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position + Vec:Resized(math.random(5)), Vec:Resized(math.random(3)), npc):ToEffect()
			smoke.SpriteScale = smoke.SpriteScale * (math.random(1,5)/10)
			smoke.SpriteOffset = Vector(0, 0 - math.random(5))
			smoke.Color = Color(0,0,0,1, 169 / 255, 144 / 255, 117 / 255)
			smoke:Update()
		end
		mod:ReplaceEnemySpritesheet(npc, "gfx/enemies/baby host/tinyErodedBroken", 0)
		sprite:LoadGraphics()
		npc.SubType = 1
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		if npc.StateFrame > 5 and math.random(10) == 1 and (npc.Velocity:Length() < 1.5 or npc.Variant == mod.FF.Tittle.Var) and target.Position:Distance(npc.Position) < 150 then
			d.state = "shoot"
			d.shootMulti = 0.5
		end
	elseif d.state == "shoot" then
		if sprite:IsFinished("Shoot") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") and not mod:isScareOrConfuse(npc) then
			local params = ProjectileParams()
			params.HeightModifier = 15
			params.Scale = 0.5
			local shootVar = 30
			local shootVar2 = 60
			if var == 862 then
				npc:PlaySound(SoundEffect.SOUND_LITTLE_SPIT,1,2,false,2.5)
			else
				npc:PlaySound(SoundEffect.SOUND_LITTLE_SPIT,1,2,false,1.3)
			end
			if var == 861 then
				shootVar = 60
				shootVar2 = 40
			elseif var == 862 then
				params.FallingSpeedModifier = -5 - math.random(10)
				params.FallingAccelModifier = 1.1 + math.random(5)/10
				params.Color = mod.ColorLemonYellow
				shootVar = shootVar * d.shootMulti
				shootVar2 = shootVar2 * d.shootMulti
				if subt == 1 then
					shootVar2 = shootVar
				end
				d.shootMulti = d.shootMulti + 0.3
			end
			for i = -shootVar, shootVar, shootVar2 do
				npc:FireProjectiles(npc.Position, (target.Position - npc.Position):Resized(5):Rotated(i), 0, params)
			end
		else
			mod:spritePlay(sprite, "Shoot")
		end
	end

	if sprite:IsEventTriggered("DMG") then
		d.invincible = false
	elseif sprite:IsEventTriggered("NoDMG") then
		d.invincible = true
	end
end

function mod:smidgenHurt(npc, damage, flag, source)
    local d = npc:GetData()
    if flag & (DamageFlag.DAMAGE_SPIKES | DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_TNT | DamageFlag.DAMAGE_FIRE) ~= 0 then
        if d.invincible then
            sfx:Play(SoundEffect.SOUND_BONE_SNAP, 0.6, 0, false, math.random(13, 15)/10)
        end
        npc:Kill()
    elseif d.invincible then
        if npc.Variant == mod.FF.ErodedSmidgen.Var then
            if npc.SubType ~= mod.FF.ErodedSmidgenNaked.Sub then
                d.skullhealth = d.skullhealth or 5
                d.skullhealth = d.skullhealth - damage
                return false
            end
        else
            return false
        end
    end
end
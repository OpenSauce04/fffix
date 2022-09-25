local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:erodedHostBreakEffect(npc)
	npc:PlaySound(SoundEffect.SOUND_ROCK_CRUMBLE, 0.7, 0, false, 1.3)
	for i = 1, 10 do
		local Vec = RandomVector()
		local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position + Vec:Resized(math.random(5,25)), Vec:Resized(math.random(2,7)), npc):ToEffect()
		smoke.SpriteScale = smoke.SpriteScale * (math.random(5,15)/10)
		smoke.SpriteOffset = Vector(0, 0 - math.random(5,25))
		smoke.Color = Color(0,0,0,1, 169 / 255, 144 / 255, 117 / 255)
		smoke:Update()
	end
end

function mod:erodedHostAI(npc, subt)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not d.init then
		d.init = true
		d.shielded = true
		if subt == 1 then
			d.skullhealth = 10
			mod:ReplaceEnemySpritesheet(npc, "gfx/enemies/erodedhost/eroded_host2", 0)
		elseif subt ~= 2 then
			d.skullhealth = 15
		elseif subt == 2 then
			d.skullhealth = 0
			mod:ReplaceEnemySpritesheet(npc, "gfx/enemies/erodedhost/eroded_host3", 0)
		end
		d.state = "idle"
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	npc.Velocity = npc.Velocity * 0.7

	if d.skullhealth < 0 then
		if subt == 1 then
			mod:erodedHostBreakEffect(npc)
			mod:ReplaceEnemySpritesheet(npc, "gfx/enemies/erodedhost/eroded_host3", 0)
			npc.SubType = 2
		elseif subt ~= 2 then
			mod:erodedHostBreakEffect(npc)
			mod:ReplaceEnemySpritesheet(npc, "gfx/enemies/erodedhost/eroded_host2", 0)
			d.skullhealth = 10
			npc.SubType = 1
		end
	end

	local statewait = 30
	local shootwait = 3
	if subt == 1 then
		statewait = 15
		shootwait = 2
	elseif subt == 2 then
		statewait = 0
		shootwait = 1
	end

	if sprite:IsEventTriggered("Popup") then
		d.shielded = false
		npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH,1,2,false,1)
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		if (not mod:isScareOrConfuse(npc)) and npc.StateFrame > statewait and math.random(10) == 1 and target.Position:Distance(npc.Position) < 200 then
			d.state = "shoot"
		end
	elseif d.state == "shoot" then
		if sprite:IsFinished("Shoot") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			d.shooting = true
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Stop") then
			d.shooting = false
			if subt == 2 then
				local params = ProjectileParams()
				params.Color = mod.ColorLemonYellow
				for i = 1, math.random(7,12) do
					params.Scale = math.random(2, 10) / 10
					params.FallingSpeedModifier = -10 - math.random(20)
					params.FallingAccelModifier = 1 + (math.random() * 0.5)
					npc:FireProjectiles(npc.Position, (target.Position - npc.Position):Rotated(-30 + math.random(60)):Resized(7) + (RandomVector() * math.random() * 3.5), 0, params)
				end
			end
			d.shielded = true
			npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH,1,2,false,0.9)
		else
			mod:spritePlay(sprite, "Shoot")
		end
	elseif d.state == "quickstop" then
		if sprite:IsFinished("QuickShut") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Stop") then
			d.shooting = false
			d.shielded = true
			npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH,1,2,false,1.3)
		else
			mod:spritePlay(sprite, "QuickShut")
		end
	end

	if d.shooting then
		if mod:isScareOrConfuse(npc) then
			d.state = "quickstop"
		end
		if npc.FrameCount % shootwait == 0 then
			npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1.3)
			local params = ProjectileParams()
			local shotspeed = ((target.Position - npc.Position)*0.03):Rotated(-10+math.random(20))
			params.Scale = math.random(2, 10) / 10
			params.FallingSpeedModifier = -30 + math.random(10) - (npc.StateFrame * 0.7);
			params.FallingAccelModifier = 1.4 + math.random(2)/10;
			--params.Color = Color(0, 0, 0, 1, 80 / 255, 80 / 255, 20 / 255)
			params.Color = mod.ColorLemonYellow
			params.HeightModifier = 20
			if subt == 2 then
				shotspeed = shotspeed + RandomVector()*math.random(1,3)
			end
			npc:FireProjectiles(npc.Position, shotspeed, 0, params)
		end
	end
end

function mod:erodedHostHurt(npc, damage, flag, source)
    local subt = npc.SubType
    if subt ~= 2 then
        local d = npc:GetData()
        if d.shielded then
            d.skullhealth = d.skullhealth - damage
            npc:ToNPC().StateFrame = math.max(0, npc:ToNPC().StateFrame - 10)
            return false
        else
            if d.shooting then
                d.state = "quickstop"
            end
        end
    end
end
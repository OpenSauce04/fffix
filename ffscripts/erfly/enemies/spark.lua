local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:sparkAI(npc)
	local d = npc:GetData()
	local r = npc:GetDropRNG()
	local sprite = npc:GetSprite()
	local path = npc.Pathfinder

	--npc.SpriteOffset = Vector(0, -1)

	if not d.init then
		npc.SplatColor = mod.ColorCharred
		d.state = "Idle"
		d.randwait = r:RandomInt(5)
		d.init = true
	elseif d.init then
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "Idle" then
		if npc.Velocity.X > 0 then
			sprite.FlipX = false
		else
			sprite.FlipX = true
		end
		mod:spritePlay(sprite, "Idle")
		npc.Velocity = npc.Velocity * 0.92
		if npc.StateFrame > 20 + d.randwait then
			d.state = "Squidge"
		end
	elseif d.state == "Squidge" then
		npc.Velocity = npc.Velocity * 0.99
		if sprite:IsFinished("Move") then
			d.state = "Idle"
			d.randwait = r:RandomInt(5)
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Move it babie") then
			--Gimme a fire
			local fire = Isaac.Spawn(1000,7005, 0, npc.Position, nilvector, npc):ToEffect()
			fire:GetData().timer = 100
			fire:Update()
			npc:PlaySound(mod.Sounds.FireLight, 1, 0, false, 2)
			d.flaming = true

			--Gimme a move
			local targetpos = mod:FindRandomValidPathPosition(npc, 10)
			if mod:isScare(npc) then
				npc.Velocity = (npc:GetPlayerTarget().Position - npc.Position):Resized(-6)
			elseif targetpos and math.random(4) == 1 then
				if game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) and npc.Position:Distance(targetpos) < 100 then
					npc.Velocity = (targetpos - npc.Position):Resized(4)
				else
					path:FindGridPath(targetpos, 2, 900, false)
				end
			else
				npc.Velocity = RandomVector():Resized(4)
			end

			--Gimme a flip
			if npc.Velocity.X > 0 then
				sprite.FlipX = false
			else
				sprite.FlipX = true
			end
		elseif sprite:IsEventTriggered("Done") then
			d.flaming = false
		else
			mod:spritePlay(sprite, "Move")
		end
	end
end

function mod:sparkAIOld(npc)
	npc.SplatColor = mod.ColorCharred
	npc.SpriteOffset = Vector(0,-5)
	local d = npc:GetData()
	--Isaac.ConsoleOutput(npc.State .. "\n")
	if npc.State == 3 then
		d.leavefire = true
	elseif npc.State == 4 and d.leavefire then
		local fire = Isaac.Spawn(1000,7005, 0, npc.Position, nilvector, npc):ToEffect()
		fire:GetData().timer = 100
		fire:Update()
		d.leavefire = false
	end

	if npc:HasMortalDamage() then
		npc.SplatColor = mod.ColorFireJuicy
	end

	--[[if npc.FrameCount % 3 == 1 then
		local blood = Isaac.Spawn(1000, 18, 0, npc.Position, nilvector, npc)
		blood.SpriteScale = Vector(0.2,0.2)
		blood:Update()
	end]]
end

function mod:sparkHurt(npc, damage, flag, source)
    if flag & DamageFlag.DAMAGE_FIRE ~= 0 and source.Type ~= 1 then
        return false
    end
    if math.random(5) == 1 then
        npc:ToNPC():PlaySound(SoundEffect.SOUND_BABY_HURT,1,0,false,1)
    end
end
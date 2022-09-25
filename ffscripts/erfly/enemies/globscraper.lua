local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:globscraperAI(npc, subt)
	local d = npc:GetData()
	local sprite = npc:GetSprite();
	local target = npc:GetPlayerTarget()

	if not d.init then
		if subt == 10 then
			d.state = "slide"
		elseif subt == 3 then
			npc:Morph(24, 1, 0, -1)
		else
			d.base = 0
			d.hats = 3 - subt
			d.state = "idle"
		end
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Base" .. d.base .. " " .. d.hats .. "Hat")
		if sprite:GetFrame() == 13 then
			local moveVec = RandomVector() * 4
			if (math.random(2) == 1 or mod:isScare(npc)) and (not mod:isConfuse(npc)) then
				moveVec = mod:reverseIfFear(npc, (target.Position - npc.Position):Resized(4))
			end
			npc.Velocity = mod:Lerp(npc.Velocity, moveVec, 0.4)
		else
			npc.Velocity = npc.Velocity * 0.97
		end
		--[[if npc.Velocity:Length() < 0.1 then
			npc.Velocity = RandomVector() * 0.1
		end
		npc.Velocity = mod:Lerp(npc.Velocity, npc.Velocity:Resized(2), 0.03):Rotated(-9 + math.random(16))
		]]

		if npc.FrameCount % 3 == 1 then
			local blood = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc)
			blood.SpriteScale = Vector(0.6,0.6)
			blood:Update()
		end

	elseif d.state == "fall" then
		npc.Velocity = npc.Velocity * 0.8
		local anim
		if d.hats > 0 then
			local anim = "Fall" .. d.base .. " " .. d.hats .. "Hat"
			if sprite:IsFinished(anim) then
				d.state = "idle"
			else
				mod:spritePlay(sprite, anim)
			end
		else
			local anim = "Fall" .. d.base
			if sprite:IsFinished(anim) then
				d.state = "regen"
				FiendFolio:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, npc, 1, 1)
			else
				mod:spritePlay(sprite, anim)
			end
		end
		if sprite:IsEventTriggered("Land") then
			npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, 0.7, 0, false, 1)
		end
	elseif d.state == "regen" then
		npc.Velocity = npc.Velocity * 0.9
		if sprite:IsFinished("Regenerate" .. d.base) then
			if d.base > 0 then
				npc:Morph(24, 1, 0, -1)
			else
				npc:Morph(24, 0, 0, -1)
			end
		else
			mod:spritePlay(sprite, "Regenerate" .. d.base)
		end
	elseif d.state == "slide" then
		if npc.FrameCount % 2 == 1 then
			local blood = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc)
			blood:Update()
		end
		mod:spritePlay(sprite, "Base" .. d.base)
		npc.Velocity = npc.Velocity * 0.95
		if npc.StateFrame > 10 then
			d.state = "regen"
			FiendFolio:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, npc, 1, 1)
		end
	end
end

function mod:globscraperHurt(npc, damage, flag, source)
    local d = npc:GetData()
    if d.state == "idle" then
        d.state = "fall"
        d.hats = d.hats - 1
        d.base = d.base + 1
        npc:ToNPC().SubType = math.min(npc:ToNPC().SubType + 1, 3)

        --npc:ToNPC():PlaySound(mod.Sounds.BatBaseballHit,0.7,0,false,math.random(110,130)/100)
        npc:ToNPC():PlaySound(SoundEffect.SOUND_MEATY_DEATHS,0.7,0,false,math.random(110,130)/100)
        local vec = (npc.Position - npc:ToNPC():GetPlayerTarget().Position):Resized(7)
        local child = Isaac.Spawn(mod.FF.Globscraper.ID, mod.FF.Globscraper.Var, mod.FF.GlobscraperSlide.Sub, npc.Position, vec, npc):ToNPC()
        child:GetData().base = d.base - 1
        child:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        child:Update()
    end
    if not (d.state == "regen" or d.state == "slide") then
        return false
    end
end
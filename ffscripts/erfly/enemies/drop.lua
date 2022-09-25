local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:dripAI(npc, subt)
	local d = npc:GetData()
	local sprite = npc:GetSprite();
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()
	local path = npc.Pathfinder

	if not d.init then
		if mod.isBackdrop("Scarred Womb") then
			npc.SplatColor = mod.ColorNormal
		elseif mod.isBackdrop("Dross") then
			npc.SplatColor = mod.ColorPoopyPeople
		else
			npc.SplatColor = mod.ColorWaterPeople
		end
		if d.waited then
			d.state = "Fall"
			sprite:Play("Fall", true)
			d.dmg = false
			npc.Visible = true

			local effect = Isaac.Spawn(1000,1743,0,npc.Position,nilvector,nil)
			mod:spritePlay(effect:GetSprite(), "Appear")
			effect.Parent = npc
			npc.Child = effect
			effect:Update()
		elseif subt == 2 then
			mod.makeWaitFerr(npc, npc.Type, npc.Variant, npc.SubType, 50, false)
		elseif subt == 1 then
			d.state = "Fall"
			d.dmg = false

			local effect = Isaac.Spawn(1000,1743,0,npc.Position,nilvector,nil)
			mod:spritePlay(effect:GetSprite(), "Appear")
			effect.Parent = npc
			npc.Child = effect
			effect:Update()
		else
			d.state = "Idle"
			d.dmg = true
		end
		d.randwait = r:RandomInt(5)
		d.squidgecount = 5
		d.init = true
	elseif d.init then
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "Idle" then
		mod:spritePlay(sprite, "Idle")
		npc.Velocity = npc.Velocity * 0.95
		if npc.StateFrame > 10 + d.randwait then
			if r:RandomInt(d.squidgecount) == 0 and not (mod:isScare(npc) or mod:isConfuse(npc)) and game:GetRoom():HasWater() then
				npc.Velocity = nilvector
				d.state = "Submerge"
				npc:PlaySound(mod.Sounds.DripSuck,0.4,0,false,1)
			else
				local targetpos = mod:runIfFear(npc, mod:FindRandomValidPathPosition(npc, 10), nil, true)
				if targetpos then
					if game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
						npc.Velocity = (targetpos - npc.Position):Resized(4)
					else
						path:FindGridPath(targetpos, 2, 900, false)
					end
					d.state = "Squidge"
				elseif game:GetRoom():HasWater() then
					d.state = "Submerge"
					npc:PlaySound(mod.Sounds.DripSuck,0.4,0,false,1)
				end
			end
		end
	elseif d.state == "Squidge" then
		npc.Velocity = npc.Velocity * 0.99
		if npc.Velocity.X > 0 then
			sprite.FlipX = false
		else
			sprite.FlipX = true
		end
		if sprite:IsFinished("Move") then
			d.state = "Idle"
			d.randwait = r:RandomInt(5)
			d.squidgecount = math.max(1,d.squidgecount - 1)
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "Move")
		end
	elseif d.state == "Submerge" then
		npc.Velocity = nilvector
		if sprite:IsFinished("Submerge") then
			npc.Velocity = nilvector
			d.state = "Fall"
			npc.StateFrame = 0
			npc.Position = game:GetRoom():FindFreeTilePosition(target.Position, 40) + RandomVector()*5

			local effect = Isaac.Spawn(1000,1743,0,npc.Position,nilvector,nil)
			mod:spritePlay(effect:GetSprite(), "Appear")
			effect.Parent = npc
			npc.Child = effect
			effect:Update()
		elseif sprite:IsEventTriggered("NoDMG") then
			d.dmg = false
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		else
			mod:spritePlay(sprite, "Submerge")
		end
	elseif d.state == "Fall" then
		npc.Velocity = nilvector
		mod:spritePlay(sprite, "Fall")
		if npc.StateFrame < 12 then
			npc.SpriteOffset = Vector(0, -300 + npc.StateFrame * 25)
		else
			npc.SpriteOffset = Vector(0, 0)
			d.state = "Land"
			d.dmg = true
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc:PlaySound(mod.Sounds.SplashSmall,1,0,false,1)
			if npc.Child and npc.Child:Exists() then
				npc.Child.Parent = nil
				npc.Child = nil
			end
			--npc:PlaySound(mod.Sounds.LandSoft,1,2,false,1.5)
		end
	elseif d.state == "Land" then
		npc.Velocity = nilvector
		if sprite:IsFinished("Land") then
			d.state = "Idle"
			d.randwait = r:RandomInt(5)
			d.squidgecount = 5
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "Land")
		end
	end
end

function mod:dripReticle(e)
	local sprite = e:GetSprite()
	if e.FrameCount < 1 then
		if mod.isBackdrop("Scarred Womb") then
			sprite:Load("gfx/enemies/drip/target_scarred_womb.anm2", true)
		elseif mod.isBackdrop("Dross") then
			sprite:Load("gfx/enemies/drip/target_dross.anm2", true)
		end
	end
	if not e.Parent then
		if sprite:IsFinished("Disappear") then
			e:Remove()
		else
			mod:spritePlay(sprite, "Disappear")
		end
	else
		if not sprite:IsPlaying("Appear") then
			mod:spritePlay(sprite, "Blink")
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.dripReticle, 1743)

function mod:dripHurt(npc, damage, flag, source)
    if not npc:GetData().dmg then
        return false
    else
        if math.random(5) == 1 then
            npc:ToNPC():PlaySound(SoundEffect.SOUND_BABY_HURT,1,0,false,1)
        end
    end
end
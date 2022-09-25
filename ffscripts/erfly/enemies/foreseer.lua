local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:foreseerAI(npc)
	local d = npc:GetData()
	local r = npc:GetDropRNG()
	local target = npc:GetPlayerTarget()
	local targetpos = target.Position
	local sprite = npc:GetSprite()

	if not d.init then
		d.init = true
		d.state = "idle"
		local gridtarget = mod:FindRandomFreePosAir(target.Position, 120)
		d.targetvel = (gridtarget - npc.Position):Resized(5)
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Move")
		local psihunter = mod.FindClosestEntity(npc.Position, 150, mod.FF.Psihunter.ID, mod.FF.Psihunter.Var)
		if psihunter then
			d.targetvel = (psihunter.Position - npc.Position):Resized(-15)
		elseif npc.Position:Distance(targetpos) < 120 or mod:isScare(npc) then
			d.targetvel = (targetpos - npc.Position):Resized(-10)
			d.running = true
		else
			if npc.StateFrame % 30 == 0 or d.running or mod:isConfuse(npc) then
				local gridtarget = mod:FindRandomFreePosAir(target.Position, 120)
				d.targetvel = (gridtarget - npc.Position):Resized(5)
				d.running = false
			end
		end
		npc.Velocity = mod:Lerp(npc.Velocity, d.targetvel, 0.05)

		if npc.StateFrame > 15 and r:RandomInt(10) == 0 and not (mod:isScareOrConfuse(npc) or psihunter) then
			d.state = "Reveal"
			npc.StateFrame = 1
			d.targets = {}
			d.effects = {}
		end

	elseif d.state == "Reveal" then
		npc.Velocity = npc.Velocity * 0.8
		if sprite:IsFinished("Reveal") then
			d.state = "SpinStart"
			d.shootloop = true
		else
			mod:spritePlay(sprite, "Reveal")
		end
	elseif d.state == "SpinStart" then
		npc.Velocity = npc.Velocity * 0.8
		if sprite:IsFinished("SpinStart") then
			d.state = "SpinLoop"
			npc.StateFrame = -1
		else
			mod:spritePlay(sprite, "SpinStart")
		end
	elseif d.state == "SpinLoop" then
		npc.Velocity = npc.Velocity * 0.8
		mod:spritePlay(sprite, "SpinLoop")
		if npc.StateFrame < 11 then
			if npc.StateFrame % 5 == 0 then
				local targ = target.Position + (target.Velocity * 30) + RandomVector()*30
				table.insert(d.targets, targ)
				local crosshair = Isaac.Spawn(1000, 7013, 0, targ, nilvector, npc)
				crosshair.Parent = npc
				crosshair:Update()
				table.insert(d.effects, crosshair)
			end
		elseif npc.StateFrame > 14 then
			d.state = "Explode"
		end
	elseif d.state == "Explode" then
		npc.Velocity = npc.Velocity * 0.8
		if sprite:IsFinished("Explode") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:GetFrame() == 10 then
			sfx:Stop(mod.Sounds.CrosseyeShootLoop)
			d.shootloop = false
		elseif sprite:IsEventTriggered("Explode") then
			npc:PlaySound(mod.Sounds.ForeseerClap,1,0,false,math.random(9,11)/10)
			for i = 1, #d.effects do
				if d.effects[i] then
					d.effects[i]:Remove()
				end
			end
			for i = 1, #d.targets do
				local explosion = Isaac.Spawn(1000, 7012, 0, d.targets[i], nilvector, npc)
			end
		else
			mod:spritePlay(sprite, "Explode")
		end
	end

	if d.shootloop then
		if not sfx:IsPlaying(mod.Sounds.CrosseyeShootLoop) then
			sfx:Play(mod.Sounds.CrosseyeShootLoop, 1, 0, true, 1)
		end
	end

	if npc:IsDead() or mod:isLeavingStatusCorpse(npc) then
		sfx:Stop(mod.Sounds.CrosseyeShootLoop)
	end
end

function mod:checkEvilExplosion(e)
	local damage = e:GetData().damage or 15
	if e.FrameCount == 1 then
		--[[sfx:Play(SoundEffect.SOUND_BOSS1_EXPLOSIONS,1,0,false,1)
		mod:DestroyNearbyGrid(e, radius)
		for _, entity in ipairs(Isaac.GetRoomEntities()) do
			if entity.Position:Distance(e.Position) < radius then
				if (entity:IsActiveEnemy() and entity.EntityCollisionClass > 2) then
					entity:TakeDamage(damage, DamageFlag.DAMAGE_EXPLOSION, EntityRef(e), 0)
				elseif entity.Type == 1 then
					entity:TakeDamage(1, DamageFlag.DAMAGE_EXPLOSION, EntityRef(e), 0)
				end
			end
		end]]
		--Oh my god I didn't realise it was this simple
		game:BombExplosionEffects(e.Position, damage, 0, mod.ColorInvisible, e, 0.8, false, true)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.checkEvilExplosion, 7012)

function mod:checkPsionicCrosshair(e)
	local d = e:GetData()
	local sprite = e:GetSprite()
	e.RenderZOffset = -1000

	if e.SubType == 3 then
		if e:GetSprite():IsFinished("Remove") then
			e:Remove()
		end
		if not e:GetSprite():IsPlaying("Remove") then
			if e.FrameCount < 7 then
				mod:spritePlay(e:GetSprite(), "Appear")
			else
				mod:spritePlay(e:GetSprite(), "Blink")
			end
		end
		
		if not e.Parent or e.Parent:IsDead() or mod:isStatusCorpse(e.Parent) then
			mod:spritePlay(e:GetSprite(), "Remove")
		end
	elseif e.SubType == 1 then
		if e.FrameCount < 24 then
			mod:spritePlay(e:GetSprite(), "Appear")
		else
			mod:spritePlay(e:GetSprite(), "Blink")
		end
	elseif e.SubType == 0 then
		d.Delay = d.Delay or 0
		if e.FrameCount <= d.Delay then
			if e.FrameCount == d.Delay then
				sfx:Play(mod.Sounds.Foresee,0.3,0,false,math.random(8,18)/10)
				sprite:Play("Appear")
				e.Visible = true
			else
				e.Visible = false
			end
		end

		if sprite:IsFinished("Appear") then
			sprite:Play("Idle")
		end
		if e.Parent then
			if e.Parent:IsDead() or mod:isStatusCorpse(e.Parent) then
				e:Remove()
			elseif d.ExplodeTimer then
				d.ExplodeTimer = d.ExplodeTimer - 1
				if d.ExplodeTimer <= 0 then
					if d.ProjBurst then
						local params = ProjectileParams()
						params.Color = mod.ColorMausPurple
						e.Parent:ToNPC():FireProjectiles(e.Position, Vector(10,0), 6, params)
					end
					Isaac.Spawn(1000, 7012, 0, e.Position, Vector.Zero, e.Parent)
					e:Remove()
				end
			end
		else
			e:Remove()
		end
	else
		if e.FrameCount > 70 then
			e:Remove()
		else
			if e.FrameCount == 50 then
				local proj = Isaac.Spawn(9, 4, 0, e.Position - Vector(0, 0), Vector(0,0), e):ToProjectile()
				proj:GetData().projType = "cursed rain"
				proj.FallingAccel = 1.2
				proj.Height = -120
				proj.Scale = math.random(8, 15)/10
				proj.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				proj:SetColor(Color(1, 1, 1, 0.5, 0.75, 0.75, 0.75), 0, 0, false, false)
				proj:Update()
			end
			if e.FrameCount < 10 then
				mod:spritePlay(e:GetSprite(), "Appear")
			else
				mod:spritePlay(e:GetSprite(), "Blink")
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.checkPsionicCrosshair, 7013)
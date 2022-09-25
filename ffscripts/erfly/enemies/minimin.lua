local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--MiniMinAI
function mod:miniMinMinAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not d.init then
		d.state = "idle"
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	local targetpos = target.Position
	npc.Velocity = npc.Velocity * 0.8
	if npc.State == 11 then
		if sprite:IsPlaying("Death") and sprite:GetFrame() == 4 then
			local willo = Isaac.Spawn(EntityType.ENTITY_WILLO_L2, 0, 0, npc.Position, Vector.Zero, npc)
			willo:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			willo:Update()
			willo.Position = npc.Position

			local dmm = Isaac.Spawn(1000, mod.FF.DyingMiniMin.Var, mod.FF.DyingMiniMin.Sub, willo.Position, Vector.Zero, npc):ToEffect()
			dmm:FollowParent(willo)
			dmm:GetSprite():Play("DeathFace", true)
			dmm:Update()
			npc:Remove()
		else
			mod:spritePlay(sprite, "Death")
		end
	elseif d.state == "idle" then
		mod:spritePlay(sprite, "Bounce")
		if npc.StateFrame > 30 then
			if game:GetRoom():CheckLine(npc.Position,targetpos,3,1,false,false) and npc.Position:Distance(targetpos) < 200 then
				d.state = "shoot"
			else
				if npc.StateFrame > 50 and math.random(10) == 1 then
					d.state = "tele"
					mod:spritePlay(sprite, "Submerge")
				end
			end
		end
	elseif d.state == "shoot" then
		if sprite:IsFinished("Spit") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			if target.Position.X < npc.Position.X then
				sprite.FlipX = true
			else
				sprite.FlipX = false
			end
			local params = ProjectileParams()
			params.Color = FiendFolio.ColorMinMinFire
			params.Variant = 4
			npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(11), 0, params)
			npc:PlaySound(SoundEffect.SOUND_FLAMETHROWER_END, 1, 0, false, math.random(90,110)/100)
		else
			mod:spritePlay(sprite, "Spit")
		end
	elseif d.state == "tele" then
		if sprite:IsFinished("Submerge") then
			npc.Position = game:GetRoom():FindFreePickupSpawnPosition(targetpos, 80, true)
			d.state = "reappear"
			npc.StateFrame = 0
			npc.Visible = false
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		elseif sprite:IsEventTriggered("Splash") then
			Isaac.Spawn(1000, mod.FF.BigMegaSplash.Var, mod.FF.BigMegaSplash.Sub, npc.Position, Vector.Zero, npc)
			npc:PlaySound(SoundEffect.SOUND_BOSS2_DIVE, 0.3, 0, false, math.random(190,210)/100)
		else
			mod:spritePlay(sprite, "Submerge")
		end
	elseif d.state == "reappear" then
		if npc.StateFrame > 10 then
			if not npc.Visible then
				if mod.farFromAllPlayers(npc.Position, 60) then
					npc.Visible = true
					mod:spritePlay(sprite, "Appear")
					local telin = Isaac.Spawn(1000, 157, 960, npc.Position, Vector.Zero, npc)
				else
					npc.Position = game:GetRoom():FindFreePickupSpawnPosition(targetpos, 80, true)
				end
				if target.Position.X < npc.Position.X then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end
			else
				npc.Visible = true
				if sprite:IsFinished("Appear") then
					d.state = "idle"
					npc.StateFrame = 0
				elseif sprite:IsEventTriggered("Splash") then
					npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
					npc:PlaySound(SoundEffect.SOUND_BOSS2_DIVE, 0.3, 0, false, math.random(240,260)/100)
				else
					mod:spritePlay(sprite, "Appear")
				end
			end
		end
	end
end

function mod:miniMinHurt(npc, damage, flag, source)
    if npc:ToNPC().State == 11 then
        return false
    end
end

function mod.miniMinDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
		deathAnim.State = 11
	end
	
	mod.genericCustomDeathAnim(npc, nil, nil, onCustomDeath, true, true)
end

function mod.miniMinDeathEffect(npc)
	local willo = Isaac.Spawn(EntityType.ENTITY_WILLO_L2, 0, 0, npc.Position + Vector(1,1), Vector.Zero, npc)
	willo:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	willo:Update()
	--willo.Position = npc.Position
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
	if eff.SubType == 960 then
		if eff.FrameCount >= 15 then
			eff:Remove()
		elseif eff.FrameCount >= 10 then
			eff.Color = Color(eff.Color.R,eff.Color.G,eff.Color.B,1 - (eff.FrameCount - 9)/5, eff.Color.RO, eff.Color.GO, eff.Color.BO )
		end
	end
end, EffectVariant.WILLO_SPAWNER)

function mod:dyingMiniMinAI(e)
	e.RenderZOffset = 50
	local sprite = e:GetSprite()
	if sprite:IsFinished("DeathFace") then
		e:Remove()
	else
		mod:spritePlay(sprite, "DeathFace")
	end
end
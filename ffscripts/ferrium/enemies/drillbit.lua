local mod = FiendFolio
local sfx = SFXManager()

function mod:drillbitAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local rand = npc:GetDropRNG()

	if not data.init then
		data.finding = false
		if npc.SubType == 0 then
			npc.StateFrame = rand:RandomInt(16)
			data.state = "Idle"
		elseif data.waited then
			data.state = "Move"
			sprite:Play("land", true)
			npc.Visible = true
		else
			mod.makeWaitFerr(npc, npc.Type, npc.Variant, npc.SubType, 50, false)
		end
		data.drilled = false
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end

	if data.state == "Idle" then
		npc.Velocity = npc.Velocity*0.6
		if data.drilled == false then
			mod:spritePlay(sprite, "Idle")
			if npc.StateFrame > 10 and not mod:isScare(npc) then
				npc.StateFrame = 0
				data.drillState = 0
				data.rangle = rand:RandomInt(360)
				data.state = "Drilling"
				--mod:PlaySound(mod.Sounds.DrillStart, npc, 1, 1)
				mod:PlaySound(mod.Sounds.DrillLoop, npc, 1, 1, true)
			end
		else
			mod:spritePlay(sprite, "Idle02")
			if npc.StateFrame > 120 and not mod:isScare(npc) then
				npc.StateFrame = 0
				data.drilled = false
				npc:PlaySound(SoundEffect.SOUND_MAGGOT_BURST_OUT, 0.6, 0, false, 1)
				sprite:Play("Jump")
				data.state = "Move"
			end
		end
	elseif data.state == "Drilling" then
		npc.Velocity = npc.Velocity*0.6
		if data.drilled == false then
			if not sfx:IsPlaying(mod.Sounds.DrillLoop) then
				mod:PlaySound(mod.Sounds.DrillLoop, npc, 1, 1, true)
			end
			mod:spritePlay(sprite, "Drill0" .. data.drillState)
			if npc.StateFrame % 16 == 0 then
				if data.drillState < 7 then
					--[[local smoke = Isaac.Spawn(1000, 88, 0, npc.Position+Vector(0,2), Vector(0,2):Rotated(180*math.random(2), npc):ToEffect()
					smoke.Scale = 0.2
					smoke:Update()]]
					data.drillState = data.drillState+1
					if data.drillState == 6 then
						--mod:PlaySound(mod.Sounds.DrillStop, npc)
					end
				else
					sprite:Play("DrillFinish")
					sfx:Stop(mod.Sounds.DrillLoop)
					data.drilled = true
				end
			end
			if npc.StateFrame % 4 == 0 then
				--npc:PlaySound(SoundEffect.SOUND_ROCK_CRUMBLE, 0.03, 0, false, math.random(8,12)/10)
				local params = ProjectileParams()
				params.Variant = 8
				params.FallingSpeedModifier = -1
				params.FallingAccelModifier = 0.05
				params.HeightModifier = 18
				params.Scale = 0.5
				npc:FireProjectiles(npc.Position, Vector(7,0):Rotated(data.rangle+npc.StateFrame*5), 0, params)
				for _, proj in pairs(Isaac.FindByType(9, 8, 0)) do
					if proj.FrameCount < 1 and proj.SpawnerType == npc.Type and proj.SpawnerVariant == npc.Variant then
						local pSprite = proj:GetSprite()
						pSprite:Load("gfx/009.009_rock projectile.anm2", true)
						pSprite:Play("Rotate2", true)
						--pSprite:ReplaceSpritesheet(0, "gfx/projectiles/rock_tears.png")
						pSprite:LoadGraphics()
						proj:GetData().makeSplat = 145
						proj:GetData().customProjSound = {SoundEffect.SOUND_ROCK_CRUMBLE, 0.3, math.random(8,12)/10}
						proj:GetData().toothParticles = mod.ColorRockGibs
						--proj:Update()
					end
				end

				--[[local projectile = Isaac.Spawn(9, 9, 0, npc.Position, Vector(7,0):Rotated(data.rangle+npc.StateFrame*3), npc):ToProjectile()
				projectile.Height = -10
				projectile.FallingSpeed = -1
				projectile.FallingAccel = 0.005]]
				local gibs = Isaac.Spawn(1000, 35, 0, npc.Position+Vector(0,5), RandomVector():Resized(math.random(10,20)/6), npc):ToEffect()
				gibs.Color = Color(0.2, 0.17, 0.13, 1, 0, 0, 0)
				gibs:Update()
				local smoke = Isaac.Spawn(1000, EffectVariant.DUST_CLOUD, 0, npc.Position+Vector(math.random(-5,5),10), Vector(0,-4.5):Rotated(math.random(-45,45)), npc):ToEffect()
				smoke:SetTimeout(15)
				smoke.SpriteScale = Vector(0.05,0.05)
				smoke:Update()
				smoke:Update()
			end
		else
			if sprite:IsFinished("DrillFinish") then
				data.StateFrame = 0
				data.state = "Idle"
			end
		end
	elseif data.state == "Move" then
		npc.Velocity = npc.Velocity*0.6
		if data.finding == true then
			local helpme = false
			for _,enemy in ipairs(Isaac.GetRoomEntities()) do
				if enemy.Type == 1000 and enemy.Variant == 30 then
					if (enemy.Position:Distance(data.targetPos)) < 25 then
						data.targetPos = mod:FindRandomFreePos(npc, 120, false, true)
						helpme = true
					end
				elseif enemy.Type == 114 and enemy.Variant == 10 then
					if (enemy.Position:Distance(data.targetPos)) < 25 then
						data.targetPos = mod:FindRandomFreePos(npc, 120, false, true)
						helpme = true
					end
				end
			end
			if helpme == false then
				data.finding = false
				local effect = Isaac.Spawn(1000, 30, 0, data.targetPos, Vector.Zero, nil)
				effect.Parent = npc
				npc.Child = effect
				effect.SpriteScale = effect.SpriteScale*0.85
				effect:Update()
				effect:GetData().drillbit = true
				npc.StateFrame = 0
			end
		elseif sprite:IsFinished("Jump") then
			data.targetPos = mod:FindRandomFreePos(npc, 120, false, true)
			for _,enemy in ipairs(Isaac.GetRoomEntities()) do
				if enemy.Type == 1000 and enemy.Variant == 30 then
					if (enemy.Position:Distance(data.targetPos)) < 25 then
						data.targetPos = mod:FindRandomFreePos(npc, 120, false, true)
					end
				elseif enemy.Type == 114 and enemy.Variant == 10 then
					if (enemy.Position:Distance(data.targetPos)) < 25 then
						data.targetPos = mod:FindRandomFreePos(npc, 120, false, true)
					end
				end
			end
			--[[for _,enemy in ipairs(Isaac.FindInRadius(data.targetPos, 25, EntityPartition.ENEMY)) do
				if enemy.Type == 1000 and enemy.Variant == 30 then
					data.targetPos = mod:FindRandomFreePos(npc, 120, false, true)
					Isaac.ConsoleOutput("target here")
				elseif enemy.Type == 114 and enemy.Variant == 10 then
					data.targetPos = mod:FindRandomFreePos(npc, 120, false, true)
					Isaac.ConsoleOutput("drill here")
				end
			end]]
			if not data.finding then
				local effect = Isaac.Spawn(1000, 30, 0, data.targetPos, Vector.Zero, nil)
				effect.Parent = npc
				npc.Child = effect
				effect.SpriteScale = effect.SpriteScale*0.85
				effect:Update()
				effect:GetData().drillbit = true
				npc.StateFrame = 0
			end
			sprite:Play("InAir")
		elseif sprite:IsPlaying("InAir") then
			if npc.StateFrame > 100 then
				if npc.Child and npc.Child:Exists() then
					npc.Child.Position = npc.Position
				end
				if npc.StateFrame > 120 then
					sprite:Play("land")
					data.falling = nil
				end
			end

			if (data.targetPos-npc.Position):Length() < 5 then
				if not data.falling then
					npc.Position = data.targetPos
					npc.StateFrame = 0
					data.falling = true
				end
				if npc.StateFrame >= 20 then
					sprite:Play("land")
					data.falling = nil
				end
			else
				npc.Velocity = mod:Lerp(npc.Velocity, (data.targetPos-npc.Position)/2, 0.3)
			end
		elseif sprite:IsFinished("land") then
			npc.StateFrame = 0
			data.state = "Idle"
		elseif sprite:IsEventTriggered("Land") then
			if npc.Child and npc.Child:Exists() then
				npc.Child:Remove()
			end
			npc:PlaySound(SoundEffect.SOUND_MAGGOT_ENTER_GROUND, 1, 0, false, 1)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
		elseif sprite:IsEventTriggered("Shoot") then
			local params = ProjectileParams()
			params.Variant = 9
			npc:FireProjectiles(npc.Position, Vector(7,0), 6, params)

			--[[for i=0,3 do
				Isaac.Spawn(9, 9, 0, npc.Position, Vector(7,0):Rotated(90*i), npc)
			end]]
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc.GridCollisionClass = GridCollisionClass.COLLISION_NONE
		end
	end
	if npc:IsDead() or mod:isLeavingStatusCorpse(npc) or mod:isStatusCorpse(npc) then
		sfx:Stop(mod.Sounds.DrillLoop)
	end
end

function mod:drillbitTarget(npc)
	local data = npc:GetData()
	local sprite = npc:GetSprite()
	if data.drillbit == true then
		if not data.blinkState then
			data.blinkState = false
		end
		if npc.FrameCount % 3 == 0 then --Do I seriously have to do this manually
			if data.blinkState == false then
				data.blinkState = true
			else
				data.blinkState = false
			end
		end
		if data.blinkState == true then
			sprite:SetFrame("Blink", 1)
		else
			sprite:SetFrame("Blink", 0)
		end

		if not npc.Parent or not npc.Parent:Exists() then
			npc:Remove()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.drillbitTarget, 30)
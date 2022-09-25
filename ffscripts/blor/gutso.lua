local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero


function mod:gutsoAI(npc, sprite, data)
	if not data.init then
		-- INITIALIZATION --
		npc.Position = npc.Position + Vector(0, -20)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS

		data.spit  = 0
		data.init  = true
		data.state = "Phase 1"
	end

	npc.Velocity = nilvector

	local gutCount = Isaac.FindByType(EntityType.ENTITY_GUTS, -1, 0, false, false)
	local heartCount = Isaac.FindByType(EntityType.ENTITY_HEART, 0, 0, false, false)

	if data.state == "Phase 1" then

		if sprite:IsFinished("Appear") or sprite:IsFinished("Bubble") or sprite:IsFinished("Spit") or sprite:IsFinished("Jump") then
			sprite:Play("Idle")
			data.last = npc.FrameCount

			data.noise = true
		end

		if sprite:IsPlaying("Idle") then
			if data.last + 20 < npc.FrameCount and math.random(15) == math.random(15) and data.spit <= 1 then
				sprite:Play("Spit")

				data.spit = data.spit + 1

			elseif data.last + 30 < npc.FrameCount and data.spit > 1 then
				sprite:Play("Bubble")

				data.spit = 0

			elseif #gutCount >= 3 and math.random(5) == math.random(5) then
				sprite:Play("Jump")
			end
		end

		if sprite:IsEventTriggered("Shoot") and sprite:IsPlaying("Spit") then
			local p = Isaac.Spawn(9, 0, 0, npc.Position, (npc:GetPlayerTarget().Position - npc.Position):Resized(5), npc):ToProjectile()
			p.Height       = -124
			p.FallingSpeed = -12
			p.FallingAccel = 1.5
			p.Scale        = 3
			p:GetData().gutsotype = "guts"

			local s = p:GetSprite()
			s:Load("gfx/bosses/gutso/guts_tear.anm2", true)
			s:ReplaceSpritesheet(0, "gfx/bosses/gutso/guts.png")
			s:LoadGraphics()

			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, npc.Position + Vector(0,-124), Vector(math.random(-5,5),-3), npc)
			sfx:Play(SoundEffect.SOUND_DERP, 0.6, 0, false, math.random(9,10)/10)
			sfx:Play(SoundEffect.SOUND_MEATHEADSHOOT, 0.6, 0, false, math.random(9,11)/10)

		end

		if sprite:IsPlaying("Bubble") then

			if sprite:WasEventTriggered("Shoot") and not sprite:WasEventTriggered("Stop") then

				if data.noise then
					sfx:Play(SoundEffect.SOUND_DERP, 0.6, 0, false, math.random(8,10)/10)
					data.noise = false
				end

				data.EveryOther = npc.FrameCount % 4

				if data.EveryOther == 1 then
					local p = Isaac.Spawn(9, 3, 0, npc.Position, RandomVector():Resized(math.random(4,8)), npc):ToProjectile()
					p.Height       = -124
					p.FallingSpeed = -12
					p.FallingAccel = 1.5
					p.Scale        = 0.5 + math.random(5)/5

				elseif data.EveryOther == 0 then
					local p = Isaac.Spawn(9, 0, 0, npc.Position, RandomVector():Resized(math.random(4,8)), npc):ToProjectile()
					p.FallingSpeed = 1
					p.FallingAccel = -0.1
					p.Height       = -124
					p.Scale        = 1 + math.random(10)/5
					p:GetData().gutsotype = "floaty"

					sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 0, false, math.random(9, 11)/10)

					local c = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, math.random(1,2), npc.Position + Vector(0,-124), Vector(math.random(-5,5),-3), npc)

				end

			elseif sprite:IsEventTriggered("Stop") then

			end
		end


		if sprite:IsPlaying("Jump") then
			if sprite:IsEventTriggered("Jump") then
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

			elseif sprite:IsEventTriggered("Land") then
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
				game:ShakeScreen(15)
				SFXManager():Play(48, 0.9, 0, false, 1)

				for j=1, 10 do
					local p = Isaac.Spawn(9,0,0,npc.Position,Vector.FromAngle(j*(360/10)):Resized(10),npc):ToProjectile()
					p.Height       = -5
					p.FallingSpeed = -5
					p.FallingAccel = 0.1
					p.Scale        = 1.75

				end

				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, npc.Position, nilvector, npc)

				for i, entity in pairs(Isaac.GetRoomEntities()) do
					if entity:IsVulnerableEnemy() and entity.Type == EntityType.ENTITY_GUTS then
						entity:Kill()

						local p = Isaac.Spawn(9,0,0,entity.Position,nilvector,entity):ToProjectile()
						p.Height       = -5
						p.FallingSpeed = -40 - math.random(10)
						p.FallingAccel = 1.5
						p.Scale        = 3
						p:GetData().gutsotype = "plus"

					end
				end
			end
		end

		if sprite:IsPlaying("Idle") and npc.HitPoints < 400 then
			sprite:Play("Burst")
			data.heartHealth = 0
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL

		else
			if sprite:IsEventTriggered("Spawn") then
				local fl = Isaac.Spawn(EntityType.ENTITY_MEMBRAIN, 1, 0, npc.Position, Vector(0,180):Resized(8), npc)
				fl:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				fl.MaxHitPoints = fl.MaxHitPoints / 2
				fl.HitPoints = fl.MaxHitPoints
				data.phase2Began = true

				for i = 1, 8 do
					local p = Isaac.Spawn(9, 0, 0, npc.Position, Vector(0,180):Resized(5 + math.random(2)) + RandomVector():Resized(5 + math.random(2)), npc):ToProjectile()
					p.Height       = -12
					p.FallingSpeed = -15 - math.random(5)
					p.FallingAccel = 1 + math.random(4)/6
					p.Scale        = 1 + math.random(4)/8
					p:GetData().gutsotype = "creep"

				end

				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 5, npc.Position - Vector(0,-2), nilvector, npc)

				sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.7, 0, false, 1)
				game:ShakeScreen(10)

			end

			if sprite:IsFinished("Burst") then
				data.state = "Phase 2"
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS

			end
		end


	elseif data.state == "Phase 2" then

		if sprite:IsFinished("Burst") or sprite:IsFinished("Spit2") or sprite:IsFinished("HeartSpit") or sprite:IsFinished("Jump2") or sprite:IsFinished("HeartEat") or sprite:IsFinished("Bubble2") then
			sprite:Play("Idle2")
			data.last = npc.FrameCount

			data.noise = true
		end

		if sprite:IsPlaying("Idle2") then
			if data.heartHealth > 0 then
				sprite:Play("HeartEat")

			elseif data.last + 20 < npc.FrameCount and math.random(15) == math.random(15) and data.spit <= 1 then
				if math.random(5) <= 3 then
				sprite:Play("Spit2")
				data.spit = data.spit + 1

				else
				sprite:Play("HeartSpit")
				data.spit = data.spit + 1

				end
			elseif data.last + 30 < npc.FrameCount and data.spit > 1 then
				sprite:Play("Bubble2")

				data.spit = 0

			elseif #gutCount + #heartCount >= 3 and math.random(5) == math.random(5) then
				sprite:Play("Jump2")
			end
		end

		if sprite:IsEventTriggered("Shoot") and sprite:IsPlaying("Spit2") then
			local p = Isaac.Spawn(9, 0, 0, npc.Position, (npc:GetPlayerTarget().Position - npc.Position):Resized(6), npc):ToProjectile()
			p.Height       = -100
			p.FallingSpeed = -12
			p.FallingAccel = 1.5
			p.Scale        = 3
			p:GetData().gutsotype = "guts"

			local s = p:GetSprite()
			s:Load("gfx/bosses/gutso/guts_tear.anm2", true)
			s:ReplaceSpritesheet(0, "gfx/bosses/gutso/guts.png")
			s:LoadGraphics()


			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, npc.Position + Vector(0,-100), Vector(math.random(-5,5),-3), npc)
			sfx:Play(SoundEffect.SOUND_DERP, 0.6, 0, false, math.random(9,10)/10)
			sfx:Play(SoundEffect.SOUND_MEATHEADSHOOT, 0.6, 0, false, math.random(9,11)/10)

		end

		if sprite:IsEventTriggered("Shoot") and sprite:IsPlaying("HeartSpit") then
			local p = Isaac.Spawn(9, 0, 0, npc.Position, (npc:GetPlayerTarget().Position - npc.Position):Resized(7), npc):ToProjectile()
			p.Height       = -24
			p.FallingSpeed = -18
			p.FallingAccel = 1.5
			p.Scale        = 3
			p:GetData().gutsotype = "hearts"

			local s = p:GetSprite()
			s:Load("gfx/bosses/gutso/guts_tear.anm2", true)
			s:ReplaceSpritesheet(0, "gfx/bosses/gutso/hearts.png")
			s:LoadGraphics()

			for j = 2, 3 do
				local p = Isaac.Spawn(9, 0, 0, npc.Position, ((npc:GetPlayerTarget().Position - npc.Position):Resized(6) + RandomVector():Resized(2)), npc):ToProjectile()
				p.Height       = -24
				p.FallingSpeed = -24 + j
				p.FallingAccel = 1.5
				p.Scale        = ( 1 + ( math.random(0, 5) / 10 ) )
				p:AddScale(0.5 - j/10)
				p:GetData().gutsotype = "creep"
				p:GetData().creepsize   = 1

			end

			for j = 0, 3 do
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, math.random(2,3), npc.Position + Vector(0,-24), ((npc:GetPlayerTarget().Position - npc.Position):Resized(5) + RandomVector():Resized(5)), npc)

			end

			sfx:Play(SoundEffect.SOUND_MEATHEADSHOOT, 0.6, 0, false, math.random(9,11)/10)

		end

		if sprite:IsPlaying("Bubble2") then

			if sprite:WasEventTriggered("Shoot") and not sprite:WasEventTriggered("Stop") then

				if data.noise then
					sfx:Play(SoundEffect.SOUND_DERP, 0.6, 0, false, math.random(8,10)/10)
					data.noise = false
				end

				data.EveryOther = npc.FrameCount % 4

				if data.EveryOther == 1 or data.EveryOther == 2 then
					local p = Isaac.Spawn(9, 3, 0, npc.Position, ((npc:GetPlayerTarget().Position - npc.Position):Resized(math.random(6,8)) + RandomVector():Resized(2)), npc):ToProjectile()
					p.Height       = -24
					p.FallingSpeed = -24
					p.FallingAccel = 1.4
					p.Scale        = 0.5 + math.random(5)/5

				elseif data.EveryOther == 0 then
					local p = Isaac.Spawn(9, 0, 0, npc.Position, RandomVector():Resized(math.random(4,8)), npc):ToProjectile()
					p.FallingSpeed = 1
					p.FallingAccel = -0.1
					p.Height       = -100
					p.Scale        = 1 + math.random(10)/5
					p:GetData().gutsotype = "floaty"

					sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 0, false, math.random(9, 11)/10)

					local c = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, math.random(1,2), npc.Position + Vector(0,-100), Vector(math.random(-5,5),-3), npc)

				end

			elseif sprite:IsEventTriggered("Stop") then

			end
		end


		if sprite:IsPlaying("Jump2") then
			if sprite:IsEventTriggered("Jump") then
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

			elseif sprite:IsEventTriggered("Land") then
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
				game:ShakeScreen(15)
				SFXManager():Play(48, 0.9, 0, false, 1)

				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, npc.Position, nilvector, npc)

				data.heartHealth = #heartCount

				for j=1, 10 do
					local p = Isaac.Spawn(9,0,0,npc.Position,Vector.FromAngle(j*(360/10)):Resized(10),npc):ToProjectile()
					p.Height       = -5
					p.FallingSpeed = -5
					p.FallingAccel = 0.1
					p.Scale        = 1.75

				end

				for i, entity in pairs(Isaac.GetRoomEntities()) do
					if entity:IsVulnerableEnemy() and entity.Type == EntityType.ENTITY_GUTS then
						entity:Kill()

						local p = Isaac.Spawn(9,0,0,entity.Position,nilvector,entity):ToProjectile()
						p.Height       = -5
						p.FallingSpeed = -40 - math.random(10)
						p.FallingAccel = 1.5
						p.Scale        = 3
						p:GetData().gutsotype = "plus"

					elseif entity:IsVulnerableEnemy() and entity.Type == EntityType.ENTITY_HEART then
						entity:Kill()

						local p = Isaac.Spawn(9,0,0,entity.Position,nilvector,entity):ToProjectile()
						p.Height       = -5
						p.FallingSpeed = -55 - math.random(10)
						p.FallingAccel = 0
						p.Scale        = 3
						p:GetData().gutsotype = "dead"

						local s = p:GetSprite()
						s:Load("gfx/bosses/gutso/guts_tear.anm2", true)
						s:ReplaceSpritesheet(0, "gfx/bosses/gutso/hearts.png")
						s:LoadGraphics()

					end
				end
			end
		end

		if sprite:IsFinished("Jump2") and data.heartHealth > 0 then
			sprite:Play("HeartEat")
		end

		if sprite:IsPlaying("HeartEat") then
			if sprite:IsEventTriggered("Eat") then
				npc.HitPoints = npc.HitPoints + 15
				sfx:Play(SoundEffect.SOUND_VAMP_GULP, 0.7, 0, false, 1)
				sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)

				data.heartHealth = data.heartHealth - 1

				for i = 0, 6 do
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, math.random(1,2), npc.Position, Vector(0, 5):Rotated(i):Resized(math.random(6, 10)), nil)

					local p = Isaac.Spawn(9, 0, 0, npc.Position, RandomVector():Resized(5 + math.random(3)), npc):ToProjectile()

					p.Height = -24
					p.FallingSpeed = (-15 - math.random(10))
					p.FallingAccel = 1.2
					p.Scale        = 0.5 + math.random(5)/5
				end
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, proj)
	local data = proj:GetData()
	if not data.gutsotype then return end

	----------
	-- DEAD --
	----------
	if data.gutsotype == "dead" then
		if proj.FrameCount > 30 then
			proj:Remove()

		end
	end

	------------------
	-- VISUAL TRAIL --
	------------------
	if data.gutsotype == "guts" or data.gutsotype == "hearts" or data.gutsotype == "dead" then

		local height = proj.Height

		if proj.FrameCount % 3 == 0 then
			local t = Isaac.Spawn(1000, 111, 0, proj.Position, proj.Velocity:Rotated(math.random(-45, 45)) * math.random(-10, 20)/100, proj)
			local s = t:GetSprite()
			s.Offset = Vector(0, height + 32)
			s.Scale = s.Scale * math.random(10, 13)/10

			for i = 1, math.random(3) do
				s:Update()
			end
		end
	end

	-----------
	-- CREEP --
	-----------
	if proj:IsDead() or not proj:Exists() then
		if data.gutsotype == "creep" then
			local c = Isaac.Spawn(1000, 22, 0, proj.Position, nilvector, nil):ToEffect()
			c.Scale = data.creepsize or 1

			proj:Update()
		end
	end

	-------------------
	-- GUTS & HEARTS --
	-------------------

	if proj:IsDead() or not proj:Exists() then
		if data.gutsotype == "guts" or data.gutsotype == "hearts" then

			sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)

			if data.gutsotype == "guts" then
				local fl = Isaac.Spawn(EntityType.ENTITY_GUTS, 0, 0, proj.Position, nilvector, nil)
				fl:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			else
				local fl = Isaac.Spawn(EntityType.ENTITY_HEART, 0, 0, proj.Position, nilvector, nil)
			  	fl:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

				Isaac.Spawn(1000, 22, 0, proj.Position, nilvector, nil)
			end

			for j=1, 4 do
				local p = Isaac.Spawn(9,0,0,proj.Position,Vector.FromAngle(j * 90 + 45):Resized(10),proj):ToProjectile()
				p:ToProjectile().Height       = -5
				p:ToProjectile().FallingSpeed = -5
				p:ToProjectile().FallingAccel = 0.2
				p:ToProjectile().Scale        = 1.2
			end

			proj:Update()
		end
	end

	-----------
	-- FLOAT --
	-----------
	if data.gutsotype == "floaty" then
		data.speed = proj.Velocity
		proj.Velocity = data.speed * 0.95

		if proj.Velocity:Length() < 0.4 then
			proj:Remove()
			sfx:Play(SoundEffect.SOUND_PLOP, 1, 0, false, math.random(9, 11)/10)

		end

	end


	if proj:IsDead() or not proj:Exists() then
		if data.gutsotype == "floaty" then
			local height = proj.Height
			local p = Isaac.Spawn(9, 0, 0, proj.Position, nilvector, proj):ToProjectile()
			p.Height       = height
			p.FallingSpeed = -15
			p.FallingAccel = 1.5
			p.Scale        = 1
			p:GetData().gutsotype = "creep"
			p:GetData().creepsize   = 1.2

			proj:Update()
		end
	end

	----------
	-- PLUS --
	----------
	if proj:IsDead() or not proj:Exists() then
		if data.gutsotype == "plus" then
			for j=1, 4 do
				local p = Isaac.Spawn(9,0,0,proj.Position,Vector.FromAngle(j * 90):Resized(10),proj):ToProjectile()
				p.Height       = -5
				p.FallingSpeed = -5
				p.FallingAccel = 0.2
				p.Scale        = 1.2

			end

			proj:Update()
		end
	end

	-----------
	-- DECEL --
	-----------
	if data.gutsotype == "decel" then
		data.speed = proj.Velocity
		proj.Velocity = data.speed * 0.95
	end
end
)

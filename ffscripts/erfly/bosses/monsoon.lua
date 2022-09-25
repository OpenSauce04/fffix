local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.MoistroScales = {0.7, 1, 1.5}
mod.MoistroWideScales = {0.6, 0.8, 1}

--Moistro, Jack the Dripper, Water Monstro, MonsoonAI
function mod:MoistroAKAJackTheDripperAI(npc, sprite, d)
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder
	local r = npc:GetDropRNG()
    local room = game:GetRoom()

	if not d.init then
		d.state = "idle"
		if mod.isBackdrop("Scarred Womb") then
			npc.SplatColor = mod.ColorNormal
		else
			npc.SplatColor = mod.ColorWaterPeople
		end
		d.ad = {
		{"monstroblast", -1},
		{"jump", 0},
		{"fart", 0},
		{"biglob", 0},
		{"fall", 0},
		{"biggify", 1}, --1 default
		{"itstimetosplit", 1},
		}
		d.cooldown = 0
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if npc.State == 11 then
		local bosssize
		if d.smallstate then
			bosssize = "Small"
		else
			bosssize = "Big"
		end
		npc.Velocity = nilvector
		if sprite:IsFinished(bosssize .. "Death") then
			npc:PlaySound(mod.Sounds.SplashLargePlonkless,1,0,false,0.8)
			local drip = mod.spawnent(npc, npc.Position, nilvector, mod.FF.Drop.ID, mod.FF.Drop.Var)
			npc:Kill()
		else
			mod:spritePlay(sprite, bosssize .. "Death")
		end
	else
		if sprite:IsEventTriggered("NoDMG") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		end

		if d.state == "idle" then
			npc.Velocity = npc.Velocity * 0.8
			mod:spritePlay(sprite, "Idle")
			if npc.StateFrame > d.cooldown then

				local nextchoice = d.nextchoice or mod.ChooseNextAttack(d.ad, r)
				d.state = nextchoice
				d.nextchoice = nil
				d.fallstate = 0
				d.bigstate = 0
				d.cooldown = 0
				if target.Position.X > npc.Position.X then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end
			end
		elseif d.state == "monstroblast" then
			npc.Velocity = npc.Velocity * 0.8
			if sprite:IsFinished("Shoot") then
				d.ad[1][2] = d.ad[1][2] + 1
				npc.StateFrame = 0
				d.state = "idle"
			elseif sprite:IsEventTriggered("Shoot") then
				if target.Position.X > npc.Position.X then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end
				npc:PlaySound(mod.Sounds.WateryBarf,1,0,false,1)
				local params = ProjectileParams()
				local vec = ((target.Position) - (npc.Position)):Resized(8)
				if not mod.isBackdrop("Scarred Womb") then
					params.Variant = 4
				end
				--npc:FireBossProjectiles(10, target.Position, 15, params)
				--Close
				for i = 1, 7 do
					params.FallingSpeedModifier = -10 - math.random(20)
					params.FallingAccelModifier = 1 + (math.random() * 0.5)
					--params.Scale = 0.8 + math.random() * 0.4
					params.Scale = mod.MoistroScales[math.random(3)]
					npc:FireProjectiles(npc.Position, vec + (RandomVector() * math.random() * 5.5), 0, params)
				end
				--Wide
				for i = 1, 8 do
					params.FallingSpeedModifier = -10 - math.random(20)
					params.FallingAccelModifier = 1 + (math.random() * 0.5)
					--params.Scale = 0.8 + math.random() * 0.4
					params.Scale = mod.MoistroWideScales[math.random(3)]
					npc:FireProjectiles(npc.Position, vec + (RandomVector() * (0.5 + (math.random() * 0.5)) * 6.5), 0, params)
				end
			else
				mod:spritePlay(sprite, "Shoot")
			end
		elseif d.state == "biglob" then
			npc.Velocity = npc.Velocity * 0.8
			if sprite:IsFinished("Shoot") then
				d.ad[4][2] = d.ad[4][2] + 1
				d.cooldown = 60
				npc.StateFrame = 0
				d.state = "idle"
			elseif sprite:IsEventTriggered("Shoot") then
				if target.Position.X > npc.Position.X then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end
				npc:PlaySound(mod.Sounds.WateryBurble,1,0,false,1)
				local vec = ((target.Position) - (npc.Position)):Resized(10)
				local projvar
				if mod.isBackdrop("Scarred Womb") then
					projvar = 0
				else
					projvar = 4
				end
				local projectile = Isaac.Spawn(9, projvar, 0, npc.Position, vec, npc):ToProjectile();
				local projdata = projectile:GetData();
				projectile.FallingSpeed = -70
				projectile.FallingAccel = -1
				projectile.Scale = 3
				projdata.projType = "moistrotrack"
				projdata.target = target
			else
				mod:spritePlay(sprite, "Shoot")
			end
		elseif d.state == "jump" then
			if sprite:IsFinished("Jump") then
				d.ad[2][2] = d.ad[2][2] + 0.5
				npc.StateFrame = 0
				local rand = r:RandomInt(3)
				if rand == 0 then
					sprite:Play("Idle")
				elseif rand == 1 then
					d.state = "monstroblast"
				else
					d.state = "idle"
				end
			elseif sprite:IsEventTriggered("Jump") then
				if target.Position.X > npc.Position.X then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end
				d.jumping = true
				local dist = (target.Position - npc.Position)
				d.jumptarg = npc.Position + dist:Resized(math.min(100, dist:Length()))
				d.targetvel = (d.jumptarg - npc.Position):Resized(10)
			elseif sprite:IsEventTriggered("Land") then
				npc:PlaySound(mod.Sounds.SplashSmall,1,0,false,0.8)
				d.jumping = false
				npc.Velocity = npc.Velocity * 0.5
			--[[local params = ProjectileParams()
				params.Variant = 4
				for i = 30, 360, 30 do
					params.FallingSpeedModifier = -15 - math.random(10)
					params.FallingAccelModifier = 1.5 + math.random()
					params.HeightModifier = 30
					local therand = -6 + math.random(10)
					npc:FireProjectiles(npc.Position + Vector(0,10):Rotated(i + therand), Vector(0,6):Rotated(i + therand), 0, params)
				end]]
			else
				mod:spritePlay(sprite, "Jump")
			end
			if d.jumping then
				npc.Velocity = mod:Lerp(npc.Velocity, d.targetvel, 0.3)
			else
				npc.Velocity = npc.Velocity * 0.8
			end
		elseif d.state == "fart" then
			npc.Velocity = npc.Velocity * 0.8
			if sprite:IsFinished("Fart") then
				d.ad[3][2] = d.ad[3][2] + 2
				npc.StateFrame = 0
				d.state = "idle"
				d.cooldown = 15
				d.farting = false
			elseif sprite:IsEventTriggered("Fart") then
				npc:PlaySound(mod.Sounds.BathtubFart,1.3,0,false,math.random(9,11)/10)
				d.farting = true
			else
				mod:spritePlay(sprite, "Fart")
			end

			if d.farting then
				if npc.StateFrame % 5 == 0 then
					local pos = mod:FindRandomValidPathPosition(npc, 2, 120)
					--mod.ShootBubble(npc, math.random(2,3), pos, RandomVector()*(0.5 + math.random()*2.5))
					local bubble = Isaac.Spawn(mod.FF.Bubble.ID, mod.FF.Bubble.Var, math.random(1,3), pos, nilvector, npc)
					bubble:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					bubble:GetData().spawning = true
					bubble:Update()
				end
			end

		elseif d.state == "fall" then
			npc.Velocity = nilvector
			if d.fallstate == 0 then
				if sprite:IsFinished("FallStart") then
					d.fallsdone = 0

					d.fallstate = 1
					d.falling = true
					d.fallheight = 600
					d.fallstop = 10
					npc.Position = target.Position
					if target.Position.X > npc.Position.X then
						sprite.FlipX = true
					else
						sprite.FlipX = false
					end
				elseif sprite:IsEventTriggered("NoDMG") then
					npc:PlaySound(mod.Sounds.SplashLargePlonkless,0.6,0,false,1)
				else
					mod:spritePlay(sprite, "FallStart")
				end

			elseif d.fallstate == 1 then
				mod:spritePlay(sprite, "FallLoop")
				if not d.falling then
					d.fallsdone = d.fallsdone + 1
					if d.roundtwo or d.fallsdone > 4 or (d.fallsdone > 2 and r:RandomInt(7 - d.fallsdone) == 0) then
						d.fallstate = 3
					else
						d.fallstate = 2
					end
				end

			elseif d.fallstate == 2 then
				if sprite:IsFinished("FallRestart") then
					d.fallstate = 1
					d.falling = true
					d.fallheight = 600
					d.fallstop = 10
					npc.Position = target.Position
					if target.Position.X > npc.Position.X then
						sprite.FlipX = true
					else
						sprite.FlipX = false
					end
				elseif sprite:IsEventTriggered("Land") then
					npc:PlaySound(mod.Sounds.SplashLarge,1,0,false,0.8)
					local params = ProjectileParams()
					if not mod.isBackdrop("Scarred Womb") then
						params.Variant = 4
					end
					for i = 45, 360, 45 do
						params.FallingSpeedModifier = -15 - math.random(5)
						params.FallingAccelModifier = 1.5 + (math.random() * 0.5)
						params.HeightModifier = 30
						params.Scale = 2
						npc:FireProjectiles(npc.Position + Vector(0,20):Rotated(i), Vector(0,10):Rotated(i), 0, params)
					end
				else
					mod:spritePlay(sprite, "FallRestart")
				end

			elseif d.fallstate == 3 then
				if sprite:IsFinished("FallEnd") then
					d.fallstate = 0
					if d.roundtwo then
						d.ad[7][2] = d.ad[7][2] + 3
						d.cooldown = 50
						d.roundtwo = nil
					else
						d.ad[5][2] = d.ad[5][2] + 2
					end
					local rand = r:RandomInt(3)
					if rand == 0 then
						d.state = "idle"
					else
						d.state = "monstroblast"
					end
				elseif sprite:IsEventTriggered("Land") then

					if target.Position.X > npc.Position.X then
						sprite.FlipX = true
					else
						sprite.FlipX = false
					end


					npc:PlaySound(mod.Sounds.LandSoft,1,0,false,0.7)
					local params = ProjectileParams()
					if not mod.isBackdrop("Scarred Womb") then
						params.Variant = 4
					end
					for i = 22.5, 360, 22.5 do
						params.FallingSpeedModifier = -15 - math.random(10)
						params.FallingAccelModifier = 1.5 + math.random()
						params.HeightModifier = 30
						local therand = -6 + math.random(10)
						npc:FireProjectiles(npc.Position + Vector(0,20):Rotated(i + therand), Vector(0,10):Rotated(i + therand), 0, params)
					end
				else
					mod:spritePlay(sprite, "FallEnd")
				end
			end

		elseif d.state == "biggify" then
			if d.bigstate == 1 then
				if npc.Position:Distance(room:GetCenterPos()) > 40 then
					npc.Velocity = npc.Velocity * 0.95
				else
					npc.Velocity = npc.Velocity * 0.8
				end
			else
				npc.Velocity = npc.Velocity * 0.7
			end
			if d.rampage == 1 then
				--Old Version
				--[[if npc.StateFrame % 2 == 0 then
					npc:PlaySound(SoundEffect.SOUND_BOSS2_BUBBLES,1,2,false,1)
					local params = ProjectileParams()
					params.Variant = 4
					params.FallingSpeedModifier = -15 - math.random(5)
					params.FallingAccelModifier = 1.5 + (math.random() * 0.5)
					--params.HeightModifier = 30
					local vec = RandomVector() * math.random(8,11)
					npc:FireProjectiles(npc.Position + vec:Resized(30), vec, 0, params)
				end
				if npc.StateFrame % 5 == 0 then
					local params = ProjectileParams()
					params.Variant = 4
					params.Scale = 1.5
					params.FallingSpeedModifier = -5 - math.random(5)
					params.FallingAccelModifier = 0.3 + (math.random() * 0.3)
					--params.HeightModifier = 30
					local vec = RandomVector() * math.random(9,12)
					npc:FireProjectiles(npc.Position + vec:Resized(20), vec, 0, params)
				end]]

				--New version
				d.biggifyrotval = d.biggifyrotval or (target.Position - npc.Position):GetAngleDegrees()
				if npc.StateFrame % 3 == 1 then
					npc:PlaySound(SoundEffect.SOUND_BOSS2_BUBBLES,1,2,false,1.3)
				end
				if npc.StateFrame % 5 == 1 then
					local extraval = 0
					if npc.StateFrame % 10 == 1 then
						extraval = -45
					end
					for i = 90, 360, 90 do
						local params = ProjectileParams()
						if not mod.isBackdrop("Scarred Womb") then
							params.Variant = 4
						end
						params.Scale = 1.5
						params.FallingSpeedModifier = -5
						params.FallingAccelModifier = 0.3
						--params.HeightModifier = 30
						local vec = Vector(1,0):Rotated(d.biggifyrotval + i + extraval) * math.random(7,10)
						npc:FireProjectiles(npc.Position + vec:Resized(20), vec, 0, params)
					end
					d.biggifyrotval = d.biggifyrotval + 15
				end
			elseif d.rampage == 2 then
				--old version
				--[[npc:PlaySound(SoundEffect.SOUND_BOSS2_BUBBLES,1,2,false,1.3)
				local params = ProjectileParams()
				params.Variant = 4
				params.FallingSpeedModifier = -25 - math.random(15)
				params.FallingAccelModifier = 2 + (math.random() * 0.5)
				--params.HeightModifier = 30
				local vec = RandomVector() * 8
				npc:FireProjectiles(npc.Position + vec:Resized(30), vec, 0, params)
				if npc.StateFrame % 2 == 0 then
					local params = ProjectileParams()
					params.Variant = 4
					params.Scale = 2
					params.FallingSpeedModifier = -5 - math.random(5)
					params.FallingAccelModifier = 0.3 + (math.random() * 0.3)
					--params.HeightModifier = 30
					local vec = RandomVector() * math.random(9,12)
					npc:FireProjectiles(npc.Position + vec:Resized(20), vec, 0, params)
				end]]

				--new version
				if npc.StateFrame % 2 == 1 then
					npc:PlaySound(SoundEffect.SOUND_BOSS2_BUBBLES,1,2,false,1.3)
				end
				if npc.StateFrame % 5 == 1 then
					npc:PlaySound(SoundEffect.SOUND_BOSS2_BUBBLES,1,2,false,1.3)
					local extraval = 0
					if npc.StateFrame % 10 == 1 then
						extraval = -45
					end
					for i = 90, 360, 90 do
						local params = ProjectileParams()
						if not mod.isBackdrop("Scarred Womb") then
							params.Variant = 4
						end
						params.Scale = 1.5
						params.FallingSpeedModifier = -5
						params.FallingAccelModifier = 0.3
						--params.HeightModifier = 30
						local vec = Vector(1,0):Rotated(d.biggifyrotval + i + extraval) * math.random(7,10)
						npc:FireProjectiles(npc.Position + vec:Resized(20), vec, 0, params)
					end
					if npc.StateFrame % 15 == 1 then
						for i = 45, 315, 90 do
							local vec = Vector(1,0):Rotated(d.biggifyrotval + i) * math.random(7,9)
							local projvar
							if mod.isBackdrop("Scarred Womb") then
								projvar = 0
							else
								projvar = 4
							end
							local projectile = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, projvar, 0, npc.Position + vec:Resized(20), vec, npc):ToProjectile();
							local projdata = projectile:GetData();
							projdata.projType = "orbRound"
							projectile.Scale = 1.5
							projectile.FallingAccel = -0.08
							projectile.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
						end
					end
					d.biggifyrotval = d.biggifyrotval + 5
				end
			end

			if d.bigstate == 0 then
				if sprite:IsFinished("Grow") then
					d.bigstate = 1
					npc.StateFrame = 0
				elseif sprite:IsEventTriggered("Fart") then
					npc:PlaySound(mod.Sounds.BaloonShort, 1.5, 0, false, 1.5);
					npc:SetSize(55, Vector(1,1), 12)
				else
					mod:spritePlay(sprite, "Grow")
				end
			elseif d.bigstate == 1 then
				mod:spritePlay(sprite, "BigIdle")
				if sprite:IsEventTriggered("Shudder") then
					if npc.Position:Distance(room:GetCenterPos()) > 20 then
						local targetpos = room:GetCenterPos()
							if room:CheckLine(npc.Position,targetpos,0,1,false,false) and npc.Position:Distance(targetpos) then
							npc.Velocity = (targetpos - npc.Position):Resized(math.random(4,6))
						else
							path:FindGridPath(targetpos, 5, 900, false)
						end
					end
				end
				if npc.StateFrame > 60 then
					d.bigstate = 2
					mod:spritePlay(sprite, "BigShootStart")
				end
			elseif d.bigstate == 2 then
				if sprite:IsPlaying("BigShoot01") and npc.StateFrame > 40 then
					d.bigstate = 3
					mod:spritePlay(sprite, "BigShootTransition01")
				elseif sprite:IsFinished("BigShootStart") then
					mod:spritePlay(sprite, "BigShoot01")
					npc.StateFrame = 0
				elseif sprite:IsEventTriggered("Shoot") then
					d.rampage = 1
				end
			elseif d.bigstate == 3 then
				if sprite:IsPlaying("BigShoot02") and npc.StateFrame > 80 then
					d.bigstate = 4
					mod:spritePlay(sprite, "BigShootTransition02")
				elseif sprite:IsFinished("BigShootTransition01") then
					mod:spritePlay(sprite, "BigShoot02")
				elseif sprite:IsEventTriggered("Shoot") then
					sfx:Play(mod.Sounds.SplashLargePlonkless,1,0,false,1.5)
					npc:SetSize(40, Vector(1,1), 12)
					d.rampage = 2
					local params = ProjectileParams()
					if not mod.isBackdrop("Scarred Womb") then
						params.Variant = 4
					end
					for i = 45, 360, 45 do
						npc:FireProjectiles(npc.Position + Vector(0,20):Rotated(i), Vector(0,8):Rotated(i), 0, params)
					end
				end
			elseif d.bigstate == 4 then
				if sprite:IsFinished("BigShootTransition02") then
					d.state = "idle"
					d.biggifyrotval = nil
					d.ad[6][2] = d.ad[6][2] + 2
					d.cooldown = 45
					npc.StateFrame = 0
				elseif sprite:IsEventTriggered("ShootEnd") then
					sfx:Play(mod.Sounds.SplashLargePlonkless,1,0,false,1.5)
					local params = ProjectileParams()
					if not mod.isBackdrop("Scarred Womb") then
						params.Variant = 4
					end
					for i = 22.5, 360, 22.5 do
						--params.FallingSpeedModifier = 3
						--params.FallingAccelModifier = 1.5 + math.random()
						--local therand = -6 + math.random(10)
						npc:FireProjectiles(npc.Position + Vector(0,20):Rotated(i), Vector(0,10):Rotated(i), 0, params)
					end
					d.rampage = false
				end
			end


		elseif d.state == "itstimetosplit" then
			if not d.smallstate then
				if sprite:IsFinished("SplitApart") then
					d.smallstate = "idle"
					d.littleshoots = 0
					d.roundtwo = false
					npc.StateFrame = 0
				elseif sprite:IsEventTriggered("Shudder") then
					npc:PlaySound(mod.Sounds.WateryBarf,1,0,false,0.8)
				elseif sprite:IsEventTriggered("Spawn") then
					npc:PlaySound(mod.Sounds.SplashLargePlonkless,1,0,false,1.3)
					npc:SetSize(26, Vector(1,1), 12)
					d.IsATinyBoy = true
					if mod.GetEntityCount(mod.FF.Dribble.ID, mod.FF.Dribble.Var) < 1 then
						local vec = (target.Position - npc.Position):Resized(12)
						for i = -45, 45, 90 do
							local dribble = mod.spawnent(npc, npc.Position + vec:Rotated(i), vec:Rotated(i), mod.FF.Dribble.ID, mod.FF.Dribble.Var)
							dribble.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
							mod:spritePlay(dribble:GetSprite(), "ChargeLoop")
							dribble.HitPoints = dribble.HitPoints * 0.6
							local ddat = dribble:GetData()
							ddat.state = "charge"
							ddat.charging = 1
							ddat.moist = true
							dribble:Update()
						end
					else
						local params = ProjectileParams()
						if not mod.isBackdrop("Scarred Womb") then
							params.Variant = 4
						end
						local vec = (target.Position - npc.Position):Resized(10)
						for i = -45, 45, 22.5 do
							params.FallingSpeedModifier = -20 - math.random(10)
							params.FallingAccelModifier = 1.5 + (math.random() * 0.5)
							params.HeightModifier = 30
							params.Scale = 2
							npc:FireProjectiles(npc.Position + vec:Rotated(i), vec:Rotated(i), 0, params)
						end
					end
				else
					mod:spritePlay(sprite, "SplitApart")
				end
			elseif d.smallstate == "idle" then
				npc.Velocity = npc.Velocity * 0.9
				mod:spritePlay(sprite, "SmallIdle")
				if npc.StateFrame > 45 then
					if not d.roundtwo then
						d.smallstate = "jump"
					elseif d.roundtwo then
						d.smallstate = "jump"
					end
				end
			elseif d.smallstate == "jump" then
				if sprite:IsFinished("SmallJump") then
					d.littleshoots = d.littleshoots + 1
					if d.roundtwo or d.littleshoots > 2 or (d.littleshoots > 1 and r:RandomInt(3) == 0) then
						d.smallstate = "fall"
						d.fallstate = 0
						d.littleshoots = 0
					else
						sprite:Play("SmallIdle")
					end
				elseif sprite:IsEventTriggered("Jump") then
					if target.Position.X > npc.Position.X then
						sprite.FlipX = true
					else
						sprite.FlipX = false
					end
					d.jumping = true
					local dist = (target.Position - npc.Position)
					d.jumptarg = npc.Position + dist:Resized(math.min(60, dist:Length()))
					d.targetvel = (d.jumptarg - npc.Position):Resized(6)
				elseif sprite:IsEventTriggered("Shoot") then
					npc:PlaySound(mod.Sounds.WateryBurble,1,0,false,math.random(12,14)/10)
					local params = ProjectileParams()
					if not mod.isBackdrop("Scarred Womb") then
						params.Variant = 4
					end
					local vec = ((target.Position) - (npc.Position)):Resized(6)
					for i = 1, 8 do
						params.FallingSpeedModifier = -10 - math.random(10)
						params.FallingAccelModifier = 1 + (math.random() * 0.5)
						params.Scale = 0.5 + math.random() * 0.5
						--params.Scale = mod.MoistroScales[math.random(3)]
						params.HeightModifier = -50
						npc:FireProjectiles(npc.Position + vec, vec + (RandomVector() * math.random() * 5.5), 0, params)
					end
				elseif sprite:IsEventTriggered("Land") then
					npc:PlaySound(mod.Sounds.SplashSmall,1,0,false,1.2)
					d.jumping = false
					npc.Velocity = npc.Velocity * 0.5
				else
					mod:spritePlay(sprite, "SmallJump")
				end

				if d.jumping then
					npc.Velocity = mod:Lerp(npc.Velocity, d.targetvel, 0.3)
				else
					npc.Velocity = npc.Velocity * 0.8
				end

			elseif d.smallstate == "fall" then
				npc.Velocity = nilvector
				if d.fallstate == 0 then
					if sprite:IsFinished("SmallFallStart") then
						d.fallsdone = 0
						d.fallstate = 1
						d.fallstop = 10
						d.falling = true
						if d.roundtwo then
							d.state = "fall"
							d.smallstate = nil
							d.fallheight = 600
							npc:SetSize(40, Vector(1,1), 12)
							d.IsATinyBoy = false
						else
							d.fallheight = 550
						end
						npc.Position = target.Position
						if target.Position.X > npc.Position.X then
							sprite.FlipX = true
						else
							sprite.FlipX = false
						end
					elseif sprite:IsEventTriggered("NoDMG") then
						npc:PlaySound(mod.Sounds.SplashLargePlonkless,0.6,0,false,1.3)
					else
						mod:spritePlay(sprite, "SmallFallStart")
					end

				elseif d.fallstate == 1 then
					mod:spritePlay(sprite, "SmallFallLoop")
					if not d.falling then
						d.fallsdone = d.fallsdone + 1
						if d.fallsdone > 4 or (d.fallsdone > 2 and r:RandomInt(7 - d.fallsdone) == 0) then
							d.fallstate = 3
						else
							d.fallstate = 2
						end
					end

				elseif d.fallstate == 2 then
					if sprite:IsFinished("SmallFallRestart") then
						d.fallstate = 1
						d.falling = true
						d.fallheight = 550
						d.fallstop = 10
						npc.Position = target.Position
						if target.Position.X > npc.Position.X then
							sprite.FlipX = true
						else
							sprite.FlipX = false
						end
					elseif sprite:IsEventTriggered("Land") then
						npc:PlaySound(mod.Sounds.SplashLarge,1,0,false,0.8)
						local params = ProjectileParams()
						params.Variant = 4
						--[[for i = 45, 360, 45 do
							params.FallingSpeedModifier = -25 - math.random(5)
							params.FallingAccelModifier = 1.5 + (math.random() * 0.5)
							params.HeightModifier = 30
							npc:FireProjectiles(npc.Position + Vector(0,20):Rotated(i), Vector(0,7):Rotated(i), 0, params)
						end]]
					else
						mod:spritePlay(sprite, "SmallFallRestart")
					end

				elseif d.fallstate == 3 then
					if sprite:IsFinished("SmallFallEnd") then
						d.fallstate = 0
						d.smallstate = "idle"
						d.roundtwo = true
						npc.StateFrame = 0
					elseif sprite:IsEventTriggered("Land") then

						if target.Position.X > npc.Position.X then
							sprite.FlipX = true
						else
							sprite.FlipX = false
						end


						npc:PlaySound(mod.Sounds.LandSoft,1,0,false,0.7)
					else
						mod:spritePlay(sprite, "SmallFallEnd")
					end
				end
			end
		end

		if d.falling then
			d.fallheight = d.fallheight - 30
			--[[if d.fallheight > 300 then
				local projectile = Isaac.Spawn(9, 4, 0, npc.Position + RandomVector()*math.random(10,35), nilvector, npc):ToProjectile()
				projectile.FallingSpeed = 30
				projectile.FallingAccel = 4
				projectile:AddHeight(-300)
				projectile:Update()
			end]]
			if d.fallheight < 40 then
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			end
			if d.fallheight < d.fallstop + 1 then
				d.falling = false
				d.fallheight = 0
			end
			npc.SpriteOffset = Vector(0, -d.fallheight)
		end
	end
end

function mod.moistroprojupdate(v, d)
	if d.projType == "moistrotrack" then
		--v.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		if v.FrameCount > 50 then
			v.FallingAccel = 3
			v.Color = mod.ColorNormal
			--v.SpriteOffset = Vector(0, -40)
		else
			local targetvel = (d.target.Position - v.Position):Resized(4)
			v.Velocity = mod:Lerp(v.Velocity, targetvel, 0.2)
			if v.FrameCount > 10 then
				v.Color = mod.ColorInvisible
				v.FallingSpeed = 0
				v.FallingAccel = -0.1
				if v.FrameCount % 2 == 0 then
					local projvar
					if mod.isBackdrop("Scarred Womb") then
						projvar = 0
					else
						projvar = 4
					end
					local projectile = Isaac.Spawn(9, projvar, 0, v.Position + RandomVector()*math.random(10,35), nilvector, v):ToProjectile()
					projectile.FallingSpeed = 4
					projectile.FallingAccel = 2
					projectile:AddHeight(-350)
					projectile:Update()
				end
				if v.FrameCount % 20 == 0 and mod.GetEntityCount(mod.FF.Drop.ID, mod.FF.Drop.Var) < 3 then
					local drip = mod.spawnent(v, v.Position + RandomVector()*math.random(10,35), nilvector, mod.FF.Drop.ID, mod.FF.Drop.Var, 1)
					--drip.MaxHitPoints = drip.MaxHitPoints / 2.2
					drip.HitPoints = drip.MaxHitPoints
					drip:Update()
				end
			end
		end
	elseif d.projType == "orbRound" then
		v.Velocity = v.Velocity:Rotated(5 - (v.FrameCount / 20))
	end
end
local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:duskFogOfWarAI(e)
	local sprite = e:GetSprite()
	local d = e:GetData()

	if not d.init then
		mod:spritePlay(sprite, "FadeIn")
		e.Color = Color(1,1,1,math.random(100,200)/255,0,0,0)
		d.init = true
	end
	if sprite:IsFinished("FadeIn") then
		mod:spritePlay(sprite, "Idle")
	end

	d.speed = d.speed or math.random(100, 150) / 10
	e.Velocity = Vector(0, d.speed)

	if e.FrameCount > 70 then
		if sprite:IsFinished("FadeOut") then
			e:Remove()
		else
			mod:spritePlay(sprite, "FadeOut")
		end
	end
end

function mod:duskRenderAI(npc)
	local sprite, d = npc:GetSprite(), npc:GetData()
	if sprite:IsPlaying("Death") then
		npc.Visible = true
		if sprite:IsEventTriggered("Scream") and not d.doneRenderScream then
			npc:PlaySound(mod.Sounds.DuskDeath, 1, 0, false, 1)
			d.doneRenderScream = true
			game:Darken(1, 250)
		end
		if d.elbows then
			for i = 1, #d.weirdoArms do
				if d.weirdoArms[i] and d.weirdoArms[i]:Exists() then
					d.weirdoArms[i]:GetData().dying = true
				end
				d.elbows = nil
			end
			for i = 1, #d.hands do
				if d.hands[i] and d.hands[i]:Exists() then
					d.hands[i]:Kill()
				end
			end
		end
	elseif sprite:IsPlaying("Appear") then
		if sprite:IsEventTriggered("Scream") and not d.doneRenderAppearScream then
			npc:PlaySound(mod.Sounds.DuskIntroScream, 1, 0, false, 1)
			d.doneRenderAppearScream = true
		end
	end
	if d.elbows and not game:IsPaused() then
		mod:handleDuskElbows(npc, d)
	end
end

function mod:duskHandAfterimageAI(e)
	e.Color = Color(1,1,1,1 / (e.FrameCount + 2),0,0,0)
	e.SpriteScale = Vector(1,1) * (0.9 - (e.FrameCount / 10))
	if e.FrameCount > 4 then
		e:Remove()
	end
end

local duskDirs = {
	[0] = "Left",
	[1] = "Up",
	[2] = "Right",
	[3] = "Down",
}

function mod:duskBossAI(npc, sprite, d)
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()

	local enableArmsTest = true

	if target.Parent and target.Parent.InitSeed == npc.InitSeed then
		target = Isaac.GetPlayer(0)
	end

	if not d.init then
		d.init = true
		d.state = "idle"
		d.S1Order = 0
		npc.SplatColor = mod.ColorInvisible
		if math.random(2) == 1 then
			d.firedFogBefore = true
		end

		d.hands = {}
		d.weirdoArms = {}
		d.elbows = {}
		for i = 1, 2 do
			local hand = Isaac.Spawn(mod.FF.DuskHand.ID, mod.FF.DuskHand.Var, i, npc.Position + Vector(100,0):Rotated(180 * i) + Vector(0, 20), nilvector, npc):ToNPC()
			hand.Parent = npc
			hand:Update()

			d.hands[i] = hand
			if enableArmsTest then
				local upperarm = Isaac.Spawn(mod.FF.DuskArm.ID, mod.FF.DuskArm.Var, mod.FF.DuskArm.Sub, npc.Position, nilvector, npc)
				local forearm = Isaac.Spawn(mod.FF.DuskArm.ID, mod.FF.DuskArm.Var, mod.FF.DuskArm.Sub, npc.Position, nilvector, npc)			
				upperarm.Parent = npc
				upperarm.Child = forearm
				forearm.Parent = upperarm
				forearm.Child = hand
				if i == 2 then
					upperarm:GetSprite().FlipX = true
					forearm:GetSprite().FlipX = true
				end

				d.elbows[i] = {}
				d.elbows[i].Position = npc.Position + Vector(200,0):Rotated(180 * i) + Vector(0, -140)
				d.elbows[i].Arm = upperarm
				d.elbows[i].Side = i

				table.insert(d.weirdoArms, upperarm)
				upperarm:Update()
				forearm:Update()
			end
			
		end
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	npc.SpriteOffset = Vector(0, -5)

	if npc.HitPoints <= npc.MaxHitPoints / 2 and d.S1Order then
		for i = 1, #d.hands do
			if d.hands[i] and d.hands[i]:Exists() then
				d.hands[i].Parent = nil
				d.hands[i]:Die()
				d.hands[i]:Update()
			end
		end
		d.S1Order = nil
		d.moving = nil
		d.fogging = nil
		d.state = "transition"
		npc.StateFrame = 0
		d.sState = nil
		sfx:Stop(mod.Sounds.PunchBuildup)
	elseif npc.HitPoints > npc.MaxHitPoints / 2 then
		if d.hands then
			local handDying
			for i = 1, #d.hands do
				if d.hands[i] and d.hands[i]:Exists() then
					if d.hands[i]:IsDead() then
						handDying = true
					end
				else
					handDying = true
				end
			end
			if handDying then
				npc:Kill()
			end
		end
	end

	if d.moving == "slow" then
		npc.Velocity = npc.Velocity * 0.7
	elseif d.moving then
		local topLeft = game:GetRoom():GetTopLeftPos()
		--Offset value used to be 150
		local capOffset = 10
		local cappedPosX = math.max(topLeft.X + capOffset, target.Position.X)
			  cappedPosX = math.min(game:GetRoom():GetBottomRightPos().X - capOffset, cappedPosX)
		local targPos = Vector(cappedPosX, topLeft.Y + 30)
		local vec = (targPos - npc.Position)
		local lerpy = 0.03
		if d.state == "punched" then
			lerpy = 0.01
		end
		npc.Velocity = mod:Lerp(npc.Velocity, vec * 0.1, lerpy)
		if npc.Velocity:Length() > 5 and d.state ~= "punched" then
			npc.Velocity = npc.Velocity:Resized(5)
		end
	end

	if d.fogging then
		local topLeft, bottomRight = game:GetRoom():GetTopLeftPos(), game:GetRoom():GetBottomRightPos()
		local length = (bottomRight.X - 10) - (topLeft.X + 10)
		local fow = Isaac.Spawn(mod.FF.DuskFog.ID, mod.FF.DuskFog.Var, mod.FF.DuskFog.Sub, Vector(topLeft.X + 10 + math.random(length), topLeft.Y - 100), nilvector, npc)
		fow:Update()
		--d.fogging = d.fogging + 1
		--if d.fogging > 120 then

		--end
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle01")
		d.moving = true
		if d.S1Order == 0 then
			d.fogging = nil
		end
		if npc.StateFrame > 5 and math.random(5) == 1 then
			if d.S1Order == 0 then
				d.state = "shootWacky"
				d.S1Order = 1
			elseif d.S1Order < 3 then
				local RANDCHOICE = math.random(4)
				local PREVCHOICE
				if d.hands[1]:GetData().state == "idle" and d.hands[2]:GetData().state == "idle" then
					if d.handWait and d.handWait > 0 then
						d.handWait = d.handWait - 1
						--print(d.handWait)
					else
						for i = 1, 2 do
							if PREVCHOICE then
								while PREVCHOICE == RANDCHOICE do
									RANDCHOICE = math.random(4)
								end
							end
							local hd = d.hands[i]:GetData()
							hd.state = mod.duskHandAttacks[RANDCHOICE]
							--hd.state = "smash"
							hd.sState = nil
							PREVCHOICE = RANDCHOICE
						end
						if d.S1Order == 2 then
							if not d.firedFogBefore then
								d.state = "fogOfWar"
								d.firedFogBefore = true
							else
								d.firedFogBefore = false
							end
						end
						d.S1Order = d.S1Order + 1
					end
				else
					d.handWait = 5
				end
			elseif d.S1Order == 3 then
				if d.hands[1]:GetData().state == "idle" and d.hands[2]:GetData().state == "idle" then
					for i = 1, 2 do
						local hd = d.hands[i]:GetData()
						hd.state = "clap"
						hd.sState = nil
					end
					d.S1Order = 4
				end
			end
		end
	elseif d.state == "punched" then
		npc.Velocity = npc.Velocity * 0.9
		if sprite:IsFinished("DizzyStart") then
			sprite:Play("Recover")
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(mod.Sounds.WingFlap,1,0,false,math.random(70,100)/100)
		elseif sprite:IsFinished("Recover") then
			d.state = "idle"
		end
	elseif d.state == "shootWacky" then
		if sprite:IsFinished("ShootOne01") then
			npc.StateFrame = 0
			d.state = "idle"
        elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(mod.Sounds.DuskScream, 1, 0, false, 0.9)
            local pattern = 2
			while d.lastpattern == pattern do
				pattern = r:RandomInt(3)
			end
			if pattern == 0 then
				for i = -60, 60, 15 do
					local proj = Isaac.Spawn(mod.FF.DebuffProjectile.ID, mod.FF.DebuffProjectile.Var, 0, npc.Position, Vector(0, 7):Rotated(i), npc)
					--[[proj:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					proj.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
					proj:Update()]]
				end
			elseif pattern == 1 then
				for i = -60, 60, 30 do
					local proj = Isaac.Spawn(mod.FF.DebuffProjectile.ID, mod.FF.DebuffProjectile.Var, 0, npc.Position, Vector(0, 6):Rotated(i), npc)
					--[[proj:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					proj.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
					proj:Update()]]
				end
				for i = -50, 50, 20 do
					local proj = Isaac.Spawn(mod.FF.DebuffProjectile.ID, mod.FF.DebuffProjectile.Var, 0, npc.Position, Vector(0, 12):Rotated(i), npc)
					--[[proj:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					proj.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
					proj:Update()]]
				end
			elseif pattern == 2 then
				local flippedness = 1
				if r:RandomInt(2) == 1 then
					flippedness = flippedness * -1
				end
				for i = -50 * flippedness, 10 * flippedness, 20 * flippedness do
					local proj = Isaac.Spawn(mod.FF.DebuffProjectile.ID, mod.FF.DebuffProjectile.Var, 0, npc.Position, Vector(0, 6):Rotated(i), npc)
					--[[proj:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					proj.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
					proj:Update()]]
				end
				for i = 50 * flippedness, -10 * flippedness, -20 * flippedness do
					local proj = Isaac.Spawn(mod.FF.DebuffProjectile.ID, mod.FF.DebuffProjectile.Var, 0, npc.Position, Vector(0, 12):Rotated(i), npc)
					--[[proj:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					proj.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
					proj:Update()]]
				end
			end
			d.lastpattern = pattern
		else
			mod:spritePlay(sprite, "ShootOne01")
		end
	elseif d.state == "fogOfWar" then
		d.moving = "slow"
		if sprite:IsFinished("FogOfWar") then
			npc.StateFrame = 0
			d.state = "idle"
		elseif sprite:IsEventTriggered("Summon") then
			d.fogging = 0
			npc:PlaySound(mod.Sounds["Dusk" .. (r:RandomInt(2) + 1)], 1, 0, false, 1)
		else
			mod:spritePlay(sprite, "FogOfWar")
		end
	elseif d.state == "transition" then
		npc.Velocity = npc.Velocity * 0.3
		if sprite:IsFinished("Transition") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc.Visible = false
		elseif sprite:IsEventTriggered("Leave") then
			local smoke = Isaac.Spawn(1000,16,1,npc.Position, nilvector,nil)
			smoke.Color = Color(0.1,0.1,0.1,0.7)
			sfx:Play(SoundEffect.SOUND_BLACK_POOF, 0.3, 0, false, math.random(70,80)/100)
			for i = 1, #d.weirdoArms do
				if d.weirdoArms[i] and d.weirdoArms[i]:Exists() then
					d.weirdoArms[i]:GetData().dying = true
				end
				d.elbows = nil
			end
		else
			mod:spritePlay(sprite, "Transition")
		end
		if npc.StateFrame > 40 then
			--d.state = "phase2Idle"

			d.state = "shootToKill"
			d.phase2Attacks = {1,3}

			d.sState = nil
			npc.StateFrame = 0
			d.elbows = nil
			npc.Visible = false
		end
	elseif d.state == "phase2Idle" then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.Visible = false
		if npc.StateFrame > 30 then
			d.phase2Attacks = d.phase2Attacks or {}
			if #d.phase2Attacks <= 0 then
				d.phase2Attacks = {1,2,3}
				for i = #d.phase2Attacks, 2, -1 do
					local j = math.random(i)
					d.phase2Attacks[i], d.phase2Attacks[j] = d.phase2Attacks[j], d.phase2Attacks[i]
				end
				while d.lastDoneAttack == d.phase2Attacks[1] do
					for i = #d.phase2Attacks, 2, -1 do
						local j = math.random(i)
						d.phase2Attacks[i], d.phase2Attacks[j] = d.phase2Attacks[j], d.phase2Attacks[i]
					end
				end
				--print(d.phase2Attacks[1], d.phase2Attacks[2], d.phase2Attacks[3])
			end
			if d.phase2Attacks[1] == 1 then
				d.state = "fakeoutCharge"
			elseif d.phase2Attacks[1] == 2 then
				d.state = "shootToKill"
			else
				d.state = "trickOrbit"
			end
			--d.state = "fakeoutCharge"
			d.lastDoneAttack = d.phase2Attacks[1]
			table.remove(d.phase2Attacks, 1)
			npc.StateFrame = 0
			d.charging = nil
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		end
	elseif d.state == "fakeoutCharge" then
		if d.fakingOut then
			if npc.StateFrame % 3 == 0 then
				local pos = Isaac.GetRandomPosition()
				local fakeDusk = Isaac.Spawn(mod.FF.FakeDusk.ID, mod.FF.FakeDusk.Var, mod.FF.FakeDusk.Sub, pos, nilvector, npc)
				fakeDusk:GetData().type = "TeleportDust"
				fakeDusk.Color = Color(1,1,1,math.random(70,100)/100)
				fakeDusk:Update()
				local smoke = Isaac.Spawn(1000,16,1,fakeDusk.Position, nilvector,nil)
				smoke.Color = Color(0.3,0.3,0.3,0.7)
				sfx:Play(SoundEffect.SOUND_BLACK_POOF, 0.3, 0, false, math.random(150,180)/100)
			end
		end
		if not d.sState then
			npc.Velocity = npc.Velocity * 0.9
			d.fakingOut = true
			if npc.StateFrame >= 30 then
				npc.Visible = true
				npc.Position = mod:FindRandomFreePosAir(target.Position, 100)
				d.sState = "charge"
				d.prepCharging = true
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				npc.StateFrame = -1
				mod.scheduleForUpdate(function()
					Isaac.Spawn(20, 0, 150, npc.Position+Vector(0,-45), Vector.Zero, nil)
					sfx:Stop(SoundEffect.SOUND_FORESTBOSS_STOMPS)
				end, 0)
				sfx:Play(mod.Sounds.AnchorCrash, 0.4, 0, false, math.random(60,80)/100)
			end
		elseif d.sState == "charge" then
			if d.prepCharging then
				d.chargePos = target.Position
				d.chargeVec = target.Position - npc.Position
				if math.abs(d.chargeVec.X) > math.abs(d.chargeVec.Y) then
					if d.chargeVec.X > 0 then
						d.chargeDir = "Right"
					else
						d.chargeDir = "Left"
					end
				else
					if d.chargeVec.Y > 0 then
						d.chargeDir = "Down"
					else
						d.chargeDir = "Up"
					end
				end
			end
			--[[if sprite:IsFinished("Charge" .. d.chargeDir .. "Start") then
				mod:spritePlay(sprite, "Charge" .. d.chargeDir .. "Loop")
			elseif sprite:IsEventTriggered("Charge") then
				d.charging = true
				d.fakingOut = false
			elseif not sprite:IsPlaying(mod:spritePlay(sprite, "Charge" .. d.chargeDir .. "Start")) then
				mod:spritePlay(sprite, "Charge" .. d.chargeDir .. "Start")
			end]]
			if npc.StateFrame > 27 then
				mod:spritePlay(sprite, "Charge" .. d.chargeDir .. "Loop")
			else
				sprite:SetFrame("Charge" .. d.chargeDir .. "Start", npc.StateFrame)
			end
			if npc.StateFrame == 24 then
				--sfx:Stop(mod.Sounds.AnchorCrash)
				d.charging = true
				d.fakingOut = false
				d.prepCharging = false
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
				npc:PlaySound(mod.Sounds.DuskScream, 1, 0, false, 0.7)
			end
			if d.charging then
				local vec = d.chargeVec
				npc.Velocity = mod:Lerp(npc.Velocity, vec:Resized(30), 0.3)
				if npc.Position:Distance(d.chargePos) < 40 then
					npc.StateFrame = npc.StateFrame + 5
				end
				if npc.StateFrame >= 50 or (npc.StateFrame > 28 and npc:CollidesWithGrid()) then
					d.charging = false
					d.sState = "chargeEnd"
					npc.StateFrame = 0
				end
			else
				npc.Velocity = npc.Velocity * 0.9
			end
		elseif d.sState == "chargeEnd" then
			npc.Velocity = npc.Velocity * 0.8
			if sprite:IsFinished("Chomp" .. d.chargeDir) then
				mod:spritePlay(sprite, "Chomp" .. d.chargeDir .. "Loop")
			elseif sprite:IsEventTriggered("Shoot") then
				npc.Velocity = npc.Velocity * 0.4
				npc:PlaySound(mod.Sounds.CrunchyEddy, 1, 0, false, math.random(80,90)/100)
			elseif not sprite:IsPlaying("Chomp" .. d.chargeDir .. "Loop") then
				mod:spritePlay(sprite, "Chomp" .. d.chargeDir)
			end
			if npc.StateFrame > 30 then
				d.sState = "Leave"
			end
		elseif d.sState == "Leave" then
			npc.Velocity = npc.Velocity * 0.9
			if sprite:IsFinished("ChompTeleport" .. d.chargeDir) then
				d.state = "phase2Idle"
				d.sState = nil
				npc.Visible = false
			elseif sprite:IsEventTriggered("Leave") then
				local smoke = Isaac.Spawn(1000,16,1,npc.Position, nilvector,nil)
				smoke.Color = Color(0.1,0.1,0.1,0.7)
				sfx:Play(SoundEffect.SOUND_BLACK_POOF, 0.3, 0, false, math.random(70,80)/100)
			else
				mod:spritePlay(sprite, "ChompTeleport" .. d.chargeDir)
			end
		end
	elseif d.state == "trickOrbit" then
		npc.Visible = true
		if not d.sState then
			npc.StateFrame = 0
			d.sState = "appear"
			d.orboff = 90 * r:RandomInt(4)
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			d.currentOrbit = target
			npc.Position = target.Position --[[+ Vector(90, 0):Rotated(d.orboff)]]
			for i = 1, 3 do
				local pos = target.Position --[[+ Vector(90, 0):Rotated(d.orboff + (90 * i))]]
				local fakeDusk = Isaac.Spawn(mod.FF.FakeDusk.ID, mod.FF.FakeDusk.Var, mod.FF.FakeDusk.Sub, pos, nilvector, npc)
				fakeDusk:GetData().currentOrbit = target
				fakeDusk:GetData().type = "Faker"
				fakeDusk:GetData().offsetorb = i
				fakeDusk.Parent = npc
				fakeDusk:Update()
				local spriteChoice = "boss_duskg"
				if i == 2 then
					spriteChoice = "boss_duskr"
				elseif i == 3 then
					spriteChoice = "boss_duskb"
				end
				fakeDusk:GetSprite():ReplaceSpritesheet(0, "gfx/bosses/dusk/" .. spriteChoice .. ".png")
				fakeDusk:GetSprite():LoadGraphics()
			end
			sfx:Play(SoundEffect.SOUND_BLACK_POOF, 0.3, 0, false, math.random(100,120)/100)
			local smoke = Isaac.Spawn(1000,16,1,d.currentOrbit.Position, nilvector,nil)
			smoke.Color = Color(0.1,0.1,0.1,0.7)
		--[[elseif d.sState == "preappear" then
			d.orboff = d.orboff + (npc.StateFrame / 3.5)
			mod:spritePlay(sprite, "Fake03")
			local wait = 20
			d.orbitDist = (90/wait) * npc.StateFrame
			local targ = d.currentOrbit.Position + Vector(d.orbitDist, 0):Rotated(d.orboff)
			npc.Velocity = mod:Lerp(npc.Velocity, (targ - npc.Position) * 0.3, 0.6)
			if npc.StateFrame >= wait then
				npc.StateFrame = 0
				d.sState = "appear"
				local smoke = Isaac.Spawn(1000,16,1,d.currentOrbit.Position, nilvector,nil)
				smoke.Color = Color(0.5,0.5,0.5,0.7)
			end]]
		elseif d.sState == "appear" then
			local orbIncreaseSpeed = 5 + (npc.StateFrame / 10)
			d.orboff = d.orboff + orbIncreaseSpeed
			d.orbitDist = 90 + npc.StateFrame * 1.2
			local targ = d.currentOrbit.Position + Vector(d.orbitDist, 0):Rotated(d.orboff)
			npc.Velocity = mod:Lerp(npc.Velocity, (targ - npc.Position) * 0.3, 0.6)

			if sprite:IsFinished("Attack02") then
				mod:spritePlay(sprite, "Attack02Loop")
			elseif not sprite:IsPlaying("Attack02Loop") then
				mod:spritePlay(sprite, "Attack02")
			end
			if npc.StateFrame > 5 then
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			end

			if npc.StateFrame % 30 == 10 then
				d.spinNum = d.spinNum or 0
				npc:PlaySound(mod.Sounds["DuskSpin" .. d.spinNum + 1], 1, 0, false, math.random(90,110)/100)
				d.spinNum = (d.spinNum + 1) % 3
			end

			if npc.StateFrame >= 90 then
				d.sState = "attack"
				d.newtargOff = math.ceil(d.orboff / 90) * 90
				d.attackPos = (d.newtargOff / 90) % 4
				npc.StateFrame = 0
			end
		elseif d.sState == "attack" then
			d.orboff = mod:Lerp(d.orboff, d.newtargOff, 0.2)
			d.orbitDist = 200
			local targ = d.currentOrbit.Position + Vector(d.orbitDist, 0):Rotated(d.orboff)
			npc.Velocity = mod:Lerp(npc.Velocity, (targ - npc.Position) * 0.3, 0.6)
			d.attackPos = d.attackPos or (d.newtargOff / 90) % 4
			if npc.StateFrame < 20 then
				mod:spritePlay(sprite, "Attack02Loop")
			else
				d.ShootingTrick = true
				if sprite:IsFinished("Attack02" .. duskDirs[d.attackPos]) then
					d.sState = "Leave"
					d.ShootingTrick = nil
				elseif sprite:IsEventTriggered("Shoot") then
					sfx:Stop(mod.Sounds.Dusk3)
					npc:PlaySound(mod.Sounds.DuskShoot, 1, 0, false, math.random(65,90)/100)
					local params = ProjectileParams()
					params.FallingAccelModifier = -0.1
					params.BulletFlags = ProjectileFlags.CONTINUUM | ProjectileFlags.NO_WALL_COLLIDE
					params.Scale = 2
					for i = -50, 50, 25 do
						local vec = (Vector(-20, 0)):Rotated(i + (90 * d.attackPos))
						npc:FireProjectiles(npc.Position + vec:Resized(10), vec, 0, params)
					end
				else
					mod:spritePlay(sprite, "Attack02" .. duskDirs[d.attackPos])
				end
			end
		elseif d.sState == "caught" then
			d.beenCaught = true
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			npc.Velocity = npc.Velocity * 0.8

			if npc.StateFrame > 30 then
				if sprite:IsFinished("Recover") then
					d.sState = "Leave"
				elseif sprite:IsEventTriggered("Shoot") then
					npc:PlaySound(mod.Sounds.WingFlap,1,0,false,math.random(70,100)/100)
				else
					mod:spritePlay(sprite, "Recover")
				end
			else
				if sprite:IsFinished("DizzyStart") then
					mod:spritePlay(sprite, "Dizzyloop")
				end
			end
		elseif d.sState == "Leave" then
			if d.beenCaught then
				npc.Velocity = npc.Velocity * 0.8
			else
				local targ = d.currentOrbit.Position + Vector(d.orbitDist, 0):Rotated(d.orboff)
				npc.Velocity = mod:Lerp(npc.Velocity, (targ - npc.Position) * 0.3, 0.6)
			end
			if sprite:IsFinished("TeleportDown") then
				d.state = "phase2Idle"
				d.sState = nil
				npc.Visible = false
				d.beenCaught = nil
				d.orbitDist = nil
				d.spinNum = nil
				d.UpdatedByGhost = nil
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				npc.CollisionDamage = 1
			elseif sprite:IsEventTriggered("Leave") then
				local smoke = Isaac.Spawn(1000,16,1,npc.Position, nilvector,nil)
				smoke.Color = Color(0.1,0.1,0.1,0.7)
				sfx:Play(SoundEffect.SOUND_BLACK_POOF, 0.3, 0, false, math.random(70,80)/100)
			else
				mod:spritePlay(sprite, "TeleportDown")
			end
		end
	elseif d.state == "shootToKill" then
		if not d.sState then
			d.sState = "appear"
			npc.Visible = true
			d.currentTarget = target
			npc.Position = d.currentTarget.Position
			d.shootKillMoving = true
			--[[local closestwall = mod:GetClosestWall(npc.Position, true)
			d.attackDir = (closestwall[2] + 2 + r:RandomInt(3)) % 4]]
			local roomCenter = game:GetRoom():GetCenterPos()
			local validAttacks = {}
			if npc.Position.Y > (roomCenter.Y - 30) then
				table.insert(validAttacks, 3)
			end
			if npc.Position.X > roomCenter.X then
				table.insert(validAttacks, 2)
			else
				table.insert(validAttacks, 0)
			end
			d.attackDir = validAttacks[r:RandomInt(#validAttacks) + 1]
			sfx:Play(SoundEffect.SOUND_BLACK_POOF, 0.3, 0, false, math.random(100,120)/100)
			local smoke = Isaac.Spawn(1000,16,1,d.currentTarget.Position, nilvector,nil):ToEffect()
			smoke.Color = Color(0.1,0.1,0.1,0.7)
			smoke:Update()
		elseif d.sState == "appear" then
			if sprite:IsFinished("Back" .. duskDirs[d.attackDir]) then
				d.sState = "shoot"
				npc.StateFrame = 0
			else
				mod:spritePlay(sprite, "Back" .. duskDirs[d.attackDir])
			end
			if npc.StateFrame > 5 then
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			end
			if npc.StateFrame < 15 and npc.StateFrame % 3 == 0 then
				local smoke = Isaac.Spawn(1000,16,1,npc.Position, nilvector,nil):ToEffect()
				smoke.Color = Color(0.1,0.1,0.1,0.7 * (1 - (npc.StateFrame / 16)))
				smoke.SpriteScale = smoke.SpriteScale * (1 - (npc.StateFrame / 16))
				smoke:Update()
			end
		elseif d.sState == "transitional" then
			mod:spritePlay(sprite, "Idle0" .. ((d.attackDir + 1) % 4) + 1)
			if npc.StateFrame >= 20 then
				d.sState = "shoot"
			end
		elseif d.sState == "shoot" then
			npc.Velocity = npc.Velocity * 0.8
			if sprite:IsFinished("Shoot" .. duskDirs[d.attackDir]) then
				d.sState = "waitAMoment"
				d.waitTime = math.random(30)
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("Shoot") then
				npc:PlaySound(mod.Sounds.DuskShoot, 1, 0, false, math.random(65,75)/100)
				d.shootKillMoving = nil
				for i = -50, 50, 25 do
					local shootvec = (Vector(-15, 0)):Rotated(i + (90 * d.attackDir))
					local proj = Isaac.Spawn(mod.FF.DebuffProjectile.ID, mod.FF.DebuffProjectile.Var, mod:RandomInt(2,4), npc.Position + shootvec:Resized(10), shootvec, npc)
					proj:GetData().isSpiked = true
					proj:GetData().EffectTime = 120 --Default to 120 if this isn't there
					--[[proj:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					proj.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
					proj:Update()]]
				end
			else
				mod:spritePlay(sprite, "Shoot" .. duskDirs[d.attackDir])
			end
		elseif d.sState == "waitAMoment" then
			mod:spritePlay(sprite, "Idle0" .. ((d.attackDir + 1) % 4) + 1)
			if npc.StateFrame >= d.waitTime then
				d.sState = "leave"
			end
		elseif d.sState == "leave" then
			npc.Velocity = npc.Velocity * 0.8
			if sprite:IsFinished("Teleport" .. duskDirs[d.attackDir]) then
				d.state = "phase2Idle"
				d.sState = nil
				d.attackDir = nil
				d.shootKillMoving = nil
				npc.Visible = false
			elseif sprite:IsEventTriggered("Leave") then
				local smoke = Isaac.Spawn(1000,16,1,npc.Position, nilvector,nil)
				smoke.Color = Color(0.1,0.1,0.1,0.7)
				sfx:Play(SoundEffect.SOUND_BLACK_POOF, 0.3, 0, false, math.random(70,80)/100)
			else
				mod:spritePlay(sprite, "Teleport" .. duskDirs[d.attackDir])
			end
		end

		if d.shootKillMoving then
			local pos = d.currentTarget.Position + Vector(150, 0):Rotated(d.attackDir * 90)
			local topLeft = game:GetRoom():GetTopLeftPos()
			local bottomRight = game:GetRoom():GetBottomRightPos()
			local offset = 10
			if d.attackDir == 0 then
				pos = Vector(bottomRight.X - offset, d.currentTarget.Position.Y)
			elseif d.attackDir == 1 then
				pos = Vector(d.currentTarget.Position.X, bottomRight.Y - offset)
			elseif d.attackDir == 2 then
				pos = Vector(topLeft.X + offset, d.currentTarget.Position.Y)
			else
				pos = Vector(d.currentTarget.Position.X, topLeft.Y + offset)
			end
			npc.Velocity = mod:Lerp(npc.Velocity, (pos - npc.Position) * 0.2, 0.6)
		else
			local pos
			local topLeft = game:GetRoom():GetTopLeftPos()
			local bottomRight = game:GetRoom():GetBottomRightPos()
			local offset = 10
			if d.attackDir == 0 then
				pos = Vector(bottomRight.X - offset, npc.Position.Y)
			elseif d.attackDir == 1 then
				pos = Vector(npc.Position.X, bottomRight.Y - offset)
			elseif d.attackDir == 2 then
				pos = Vector(topLeft.X + offset, npc.Position.Y)
			else
				pos = Vector(npc.Position.X, topLeft.Y + offset)
			end
			npc.Velocity = mod:Lerp(npc.Velocity, (pos - npc.Position) * 0.2, 0.6)
		end
	end
end

function mod:duskHurt(npc, damage, flag, source, cooldown)
	local d = npc:GetData()
	if d.state == "trickOrbit" then
		if d.sState == "appear" then
			if source.Type ~= 3 then
				d.sState = "caught"
				npc.CollisionDamage = 0
				npc:ToNPC().StateFrame = 0
				npc:ToNPC():PlaySound(mod.Sounds.Kalu, 1, 0, false, math.random(90,110)/100)
				npc:GetSprite():Play("DizzyStart", true)
			end
		end
	end
	mod.scheduleForUpdate(function()
		if d.hands then
			for i = 1, #d.hands do
				mod:applyFakeDamageFlash(d.hands[i])
			end
		end
		if d.weirdoArms then
			for i = 1, #d.weirdoArms do
				mod:applyFakeDamageFlash(d.weirdoArms[i])
				if d.weirdoArms[i].Child then
					mod:applyFakeDamageFlash(d.weirdoArms[i].Child)
				end
			end
		end
	end, 2, ModCallbacks.MC_POST_UPDATE)
end

function mod:duskColl(boss, entity)
	if entity.Parent and entity.Parent.InitSeed == boss.InitSeed then -- Prevent charm/bait selfdamage (i have to do this on both sides of the equation whyyyyyyyyyy)
		return true
	--[[elseif entity.Type == EntityType.ENTITY_PROJECTILE and entity.SpawnerEntity then
		if entity.SpawnerEntity and entity.SpawnerEntity.Parent and entity.SpawnerEntity.Parent.InitSeed == boss.InitSeed then
			return true
		end]]--
	elseif entity.Type == 1 then
		local d = boss:GetData()
		if d.state == "fakeoutCharge" and d.charging then
			d.charging = false
			d.sState = "chargeEnd"
			boss:ToNPC().StateFrame = 0
		end
	end
end

function mod:duskHandColl(boss, entity)
	if boss.SubType == 1 and (entity.Type == mod.FF.DuskHand.ID and entity.Variant == mod.FF.DuskHand.Var) then
		if (boss:GetData().moving and boss:GetData().moving == "clap") and (entity:GetData().moving and entity:GetData().moving == "clap") then
			boss:GetData().sState = "clapImpact"
			boss:GetData().moving = "clapColl"
			boss:GetData().clapPartner = entity
			boss.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			mod:spritePlay(boss:GetSprite(), "ClapImpact")
			entity:GetData().sState = "clapImpact"
			entity:GetData().moving = "clapColl"
			entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			mod:spritePlay(entity:GetSprite(), "ClapImpact")
			boss:ToNPC():PlaySound(mod.Sounds.ForeseerClap,1,0,false,1)
			if boss.Parent then
				boss.Parent:GetData().S1Order = 0
				boss.Parent:ToNPC().StateFrame = 0
			end
		end
	elseif entity.Type == mod.FF.Dusk.ID and entity.Variant == mod.FF.Dusk.Var then
		if boss:GetData().moving == "punch" or boss:GetData().moving == "punchslow" then
			if entity:GetData().state ~= "punched" then
				entity:TakeDamage(entity.MaxHitPoints / 40, 0, EntityRef(boss), 0)
				entity.Velocity = boss.Velocity
				entity:GetData().state = "punched"
				entity:GetSprite():Play("DizzyStart")
				boss:ToNPC():PlaySound(mod.Sounds.EpicPunch,1,0,false,1)
				boss:ToNPC():PlaySound(mod.Sounds.DuskDumbass,1,0,false,1)
				entity:Update()
			end
		end
	end

	if boss.Parent and entity.InitSeed == boss.Parent.InitSeed then -- Prevent charm/bait selfdamage
		return true
	elseif boss.Parent and entity.Parent and entity.Parent.InitSeed == boss.Parent.InitSeed then
		return true
	--[[elseif boss.Parent and entity.Type == EntityType.ENTITY_PROJECTILE then
		if entity.SpawnerEntity and entity.SpawnerEntity.Parent and entity.SpawnerEntity.Parent.InitSeed == boss.Parent.InitSeed then
			return true
		end]]--
	end
end

mod.duskHandAttacks = {
	"shoot",
	"continuum",
	"smash",
	"charge"
}

function mod:duskHandAI(npc, sprite, d)
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()
	if npc.Parent and target.InitSeed == npc.Parent.InitSeed then
		target = Isaac.GetPlayer(0)
	elseif npc.Parent and target.Parent and target.Parent.InitSeed == npc.Parent.InitSeed then
		target = Isaac.GetPlayer(0)
	end
	
	if not d.init then
		npc.SplatColor = mod.ColorInvisible
		d.init = true
		d.moving = true
		d.state = "idle"
		npc.SpriteOffset = Vector(0, -20)
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	local vecM = 1
	if npc.SubType == 1 then
		sprite.FlipX = true
		vecM = -1
	end

	if not npc.Parent then
		npc:Kill()
	end

	if d.moving == "slow" then
		--npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(0, -20), 0.2)
		npc.Velocity = npc.Velocity * 0.7
		if d.smashHesitation then
			d.smashHesitation = d.smashHesitation - 1
			if d.smashHesitation <= 0 then
				d.sState = "smashStart"
				d.smashHesitation = nil
			end
		end
	elseif d.moving == "smash" then
		npc.Velocity = npc.Velocity * 0.7
		npc.SpriteOffset = npc.SpriteOffset + Vector(0, 20)
		if npc.SpriteOffset.Y >= -5 then
			npc.SpriteOffset = Vector(0, -5)
			d.moving = "slow"
			d.sState = "smash"
			mod:spritePlay(sprite, "SmashLand")
		end
	elseif d.moving == "smashprep" then
		local lerpness = 0.09
		if d.smashCount and d.smashCount == 1 then
			lerpness = 0.2
		end
		npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(0, -70), lerpness)
		local vec = (target.Position - npc.Position)
		npc.Velocity = mod:Lerp(npc.Velocity, vec * math.min(npc.StateFrame / 80, 0.5), math.min(npc.StateFrame / 20, 0.5))
		if npc.SpriteOffset.Y < -60 and npc.Position:Distance(target.Position) < 50 then	
			if target.Type == 1 and target:ToPlayer().MoveSpeed <= 0.5 then
				if target:GetData().CustomDuskDebuffSlow then
					d.smashHesitation = 13
				else
					d.smashHesitation = 5
				end
			elseif target:GetData().CustomDuskDebuffSlow then
				d.smashHesitation = 7
			else
				d.sState = "smashStart"
			end
			d.moving = "slow"
		end
	elseif d.moving == "punch" then
		npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(0, -20), 0.2)
		npc.Velocity = mod:Lerp(npc.Velocity, Vector(-40, 0) * vecM, 0.15)
		if npc.StateFrame > 15 then
			d.moving = "punchslow"
			npc.StateFrame = 0
		end
	elseif d.moving == "punchslow" then
		npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(0, -20), 0.05)
		npc.Velocity = npc.Velocity * 0.82
		if npc.StateFrame > 15 then
			d.moving = true
			d.intangibleMovement = true
			d.sState = "end"
		end
	elseif d.moving == "clap" then
		npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(0, -20), 0.2)
		npc.Velocity = mod:Lerp(npc.Velocity, Vector(-50, 0) * vecM, 0.15)
		if npc.SubType == 2 then
			if npc.Parent and npc.Parent:GetData().hands[1] and npc.Parent:GetData().hands[1]:Exists() then
				npc.Position = Vector(npc.Position.X, npc.Parent:GetData().hands[1].Position.Y)
			end
		end
		if npc:CollidesWithGrid() and npc.StateFrame > 20 then
			d.moving = "clapColl"
			d.sState = "clapColl"
		end
	elseif d.moving == "clapColl" then
		npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(0, -20), 0.05)
		npc.Velocity = nilvector
		d.sState = "clapColl"
		if d.clapPartner then
			npc.Position = d.clapPartner.Position + Vector(19, 0) * vecM
		end
	elseif d.moving then
		--npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(0, -20), 0.05)
		local wallX = game:GetRoom():GetTopLeftPos()
		if npc.SubType == 2 then
			wallX = game:GetRoom():GetBottomRightPos()
		end
		local topPos = -50
		if npc.Parent then
			topPos = npc.Parent.Position.Y + 20
		end
		local targPos = Vector(wallX.X, math.max(target.Position.Y, topPos))
		if d.sState == "end" then
			targPos = Vector(wallX.X, npc.Position.Y)
		end
		if npc:CollidesWithGrid() then
			d.intangibleMovement = false
		end
		local vec = (targPos - npc.Position)
		if d.state == "clap" or d.state == "charge" or (d.state == "shoot" and d.shootCount and d.shootCount > 0) or d.sState == "end" then
			npc.Velocity = mod:Lerp(npc.Velocity, vec * 0.2, 0.3)
		else
			npc.Velocity = mod:Lerp(npc.Velocity, vec * 0.1, 0.1)
		end
		if npc.Velocity:Length() > 15 then
			npc.Velocity = npc.Velocity:Resized(15)
		end
		if d.intangibleMovement then
			npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(0, -80), 0.05)
			if npc.SpriteOffset.Y < -40 then
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			end
		else
			npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(0, -20), 0.05)
			if npc.SpriteOffset.Y > -40 then
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			end
		end
	end

	--[[if npc.EntityCollisionClass == EntityCollisionClass.ENTCOLL_ALL then
		npc.Color = Color(1,1,1,1)
	else
		npc.Color = Color(3,3,3,0.2)
	end]]

	if d.state == "idle" then
		d.moving = true
		d.sState = nil

		if not sprite:IsPlaying("FingerWiggle") then
			mod:spritePlay(sprite, "Idle")
		end

		if math.random(60) == 1 then
			mod:spritePlay(sprite, "FingerWiggle")
		end

		if npc.StateFrame > 30 and math.random(10) == 1 and not npc.Parent then
			d.state = mod.duskHandAttacks[math.random(4)]
			d.state = "charge"
			d.sState = nil
		end
	elseif d.state == "shoot" then
		if not d.sState then
			d.sState = "start"
			d.shootCount = 0
		elseif d.sState == "start" then
			if sprite:IsFinished("ShootStart") then
				d.sState = "idle"
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("Clench") then
				npc:PlaySound(mod.Sounds.WormsReload, 1.5, 0, false, math.random(120,130)/100)
			else
				mod:spritePlay(sprite, "ShootStart")
			end
		elseif d.sState == "idle" then
			mod:spritePlay(sprite, "ShootIdle")
			if npc.StateFrame > 6 then
				d.sState = "fire"
				d.moving = "slow"
			end
		elseif d.sState == "fire" then
			if sprite:IsFinished("Shoot") then
				if d.shootCount >= 3 then
					d.sState = "end"
					d.shootCount = nil
				else
					d.sState = "idle"
					npc.StateFrame = 0 - math.random(5)
				end
			elseif sprite:IsEventTriggered("Shoot") then
				d.moving = true
				d.shootCount = d.shootCount or 0
				d.shootCount = d.shootCount + 1
				npc:PlaySound(mod.Sounds.ShotgunBlast,1,0,false,math.random(160,180)/100)

				local params = ProjectileParams()
				params.FallingAccelModifier = -0.1
				params.Variant = 1
				params.Color = Color(0.2,0.1,0.1,1,0.1,0,0)
				for i = -30, 30, 30 do
					local vec = (Vector(-15, 0) * vecM):Rotated(i)
					npc:FireProjectiles(npc.Position + vec:Resized(25), vec, 0, params)
				end
			else
				mod:spritePlay(sprite, "Shoot")
			end
		elseif d.sState == "end" then
			if sprite:IsFinished("ShootEnd") then
				d.state = "idle"
				npc.StateFrame = 0
			else
				mod:spritePlay(sprite, "ShootEnd")
			end
		end
	elseif d.state == "continuum" then
		if not d.sState then
			d.sState = "start"
		elseif d.sState == "start" then
			if sprite:IsFinished("ContinuumStart") then
				d.sState = "idle"
				npc.StateFrame = math.random(20)
				d.moving = "slow"
			elseif sprite:IsEventTriggered("Clench") then
				npc:PlaySound(SoundEffect.SOUND_BONE_SNAP, 0.5, 0, false, math.random(125,140)/100)
			else
				mod:spritePlay(sprite, "ContinuumStart")
			end

		elseif d.sState == "idle" then
			mod:spritePlay(sprite, "ContinuumIdle")

			if npc.StateFrame > 20 then
				d.sState = "shoot"
			end

		elseif d.sState == "shoot" then
			if sprite:IsFinished("Continuum") then
				d.state = "idle"
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("Shoot") then
				npc:PlaySound(mod.Sounds.MarioWarp, 1.5, 0, false, math.random(60,70)/100)
				local poof = Isaac.Spawn(1000, 16, 0, npc.Position, nilvector, npc):ToEffect()
				if sprite.FlipX then
					poof:GetSprite().FlipX = true
				end
				poof.Color = Color(1,1,1,0.4,0,0,1)
				poof.RenderZOffset = 100
				poof.SpriteOffset = Vector(0, -30)
				poof.SpriteScale = Vector(0.5,0.7)
				poof:FollowParent(npc)
				poof:Update()

				local params = ProjectileParams()
				params.BulletFlags = ProjectileFlags.CONTINUUM | ProjectileFlags.NO_WALL_COLLIDE
				params.Scale = 2
				params.FallingAccelModifier = -0.1
				for i = 45, 360, 45 do
					npc:FireProjectiles(npc.Position, Vector(11, 0):Rotated(i), 0, params)
				end
			elseif sprite:GetFrame() == 60 then
				d.moving = true
			else
				mod:spritePlay(sprite, "Continuum")
			end
		end
	elseif d.state == "smash" then
		if not d.sState then
			d.sState = "start"
			d.smashCount = 0
		elseif d.sState == "start" then
			if sprite:IsFinished("SmashStart") then
				d.sState = "idle"
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("Clench") then
				d.moving = "slow"
				npc:PlaySound(mod.Sounds.CronchyWorms, 1.5, 0, false, math.random(70,80)/100)
			else
				mod:spritePlay(sprite, "SmashStart")
			end
		elseif d.sState == "idle" then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			if not d.smashHesitation then
				d.moving = "smashprep"
			end
			mod:spritePlay(sprite, "SmashIdle")
		elseif d.sState == "smashStart" then
			if sprite:IsFinished("SmashFallStart") then
				mod:spritePlay(sprite, "SmashFallLoop")
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("StartFalling") then
				d.moving = "smash"
			elseif not sprite:IsPlaying("SmashFallLoop") then
				mod:spritePlay(sprite, "SmashFallStart")
			end
		elseif d.sState == "smash" then
			if sprite:IsFinished("SmashLand") then
				d.smashCount = d.smashCount or 0
				if d.smashCount >= 2 then
					d.sState = "end"
					d.intangibleMovement = true
					d.moving = true
				else
					d.sState = "idle"
					npc.StateFrame = 20
				end
			elseif sprite:IsEventTriggered("RockWave") then
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				d.smashCount = d.smashCount or 0
				d.smashCount = d.smashCount + 1
				game:ShakeScreen(10)
				npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS,1,0,false,math.random(95,105)/100)

				local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, npc.Position, nilvector, npc):ToEffect()
				wave.Parent = npc
				wave.MinRadius = 20
				wave.MaxRadius = 40
				wave.Timeout = 2

				local poof = Isaac.Spawn(1000, 15, 0, npc.Position, nilvector, npc):ToEffect()
				poof.Color = Color(1,1,1,0.8,0,0,0)
				poof:Update()
				poof:Update()
			else
				mod:spritePlay(sprite, "SmashLand")
			end
		elseif d.sState == "end" then
			if sprite:IsFinished("SmashEnd") then
				d.state = "idle"
				npc.StateFrame = 0
			else
				mod:spritePlay(sprite, "SmashEnd")
			end
		end
	elseif d.state == "charge" then
		if not d.sState then
			d.sState = "start"
			sfx:Play(mod.Sounds.PunchBuildup, 1, 0, false, 0.6)
		elseif d.sState == "start" then
			if sprite:IsFinished("Dash") then
				mod:spritePlay(sprite, "DashLoop")
			elseif sprite:IsEventTriggered("Dash") then
				sfx:Stop(mod.Sounds.PunchBuildup)
				d.moving = "punch"
				npc.StateFrame = 0
				npc:PlaySound(mod.Sounds.CleaverThrow, 1, 0, false, math.random(60,70)/100)
			elseif not sprite:IsPlaying("DashLoop") then
				mod:spritePlay(sprite, "Dash")
			end
			if d.moving == "punch" or d.moving == "punchslow" and npc.Velocity:Length() > 5 then
				local afterimage = Isaac.Spawn(mod.FF.DuskHandAfterimage.ID, mod.FF.DuskHandAfterimage.Var, mod.FF.DuskHandAfterimage.Sub, npc.Position, nilvector, npc)
				afterimage.SpriteOffset = npc.SpriteOffset
				local asprite = afterimage:GetSprite()
				if sprite.FlipX then
					asprite.FlipX = true
				end
				local spritePlaying = "DashLoop"
				if sprite:IsPlaying("Dash") then
					spritePlaying = "Dash"
				end
				asprite:SetFrame(spritePlaying, sprite:GetFrame())
				afterimage:Update()
			end
		elseif d.sState == "end" then
			if sprite:IsFinished("DashEnd") then
				d.state = "idle"
			else
				mod:spritePlay(sprite, "DashEnd")
			end
		end
	elseif d.state == "clap" then
		if not d.sState then
			d.sState = "start"
		elseif d.sState == "start" then
			if sprite:IsFinished("ClapStart") then
				d.sState = "idle"
			elseif sprite:IsPlaying("ClapStart") and sprite:GetFrame() == 10 then
				if not sfx:IsPlaying(mod.Sounds.WingFlap) then
					sfx:Play(mod.Sounds.WingFlap, 1, 0, false, 1)
				end
			else
				mod:spritePlay(sprite, "ClapStart")
			end
		elseif d.sState == "idle" then
			mod:spritePlay(sprite, "ClapIdle")

			if npc.StateFrame > 10 then
				d.sState = "launch"
			end
		elseif d.sState == "launch" then
			if sprite:IsFinished("ClapDashStart") then
				mod:spritePlay(sprite, "ClapDashLoop")
			elseif sprite:IsEventTriggered("Dash") then
				d.moving = "clap"
				npc.StateFrame = 0
			elseif sprite:GetFrame() == 10 then
				if not sfx:IsPlaying(mod.Sounds.MurasaFire) then
					sfx:Play(mod.Sounds.MurasaFire, 0.3, 0, false, 0.7)
				end
			elseif not sprite:IsPlaying("ClapDashLoop") then
				mod:spritePlay(sprite, "ClapDashStart")
			end
		elseif d.sState == "clapColl" then
			if sprite:IsFinished("ClapImpact") then
				d.state = "idle"
				d.moving = true
				d.clapPartner = nil
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				if npc.Parent then
					npc.Parent:GetData().S1Order = 0
					npc.Parent:ToNPC().StateFrame = 0
				end
			elseif sprite:GetFrame() == 15 then
				d.moving = true
				d.intangibleMovement = true
			else
				mod:spritePlay(sprite, "ClapImpact")
			end
		end
	end
end

function mod:handleDuskElbows(npc, d)
	--[[for i = 1, #d.elbows do
		local safePosition = npc.Position + Vector(200,0):Rotated(180 * i) + Vector(0, -140)
		d.elbowLerpness = d.elbowLerpness or 0
		d.elbowLerpness = math.min(d.elbowLerpness + 0.01, 0.07)

		if d.weirdoArms[i].Child.SpriteScale.X > 1 then
			d.elbows[i] = mod:Lerp(d.elbows[i], d.elbows[i] + (d.hands[i].Position - d.elbows[i]), d.elbowLerpness)
			if
		else
			d.elbows[i] = mod:Lerp(d.elbows[i], safePosition, d.elbowLerpness)
		end
	end]]
	if d.elbows then
		for _, elbow in pairs(d.elbows) do
			if elbow.Arm and elbow.Arm.Child and elbow.Arm.Child.Child then
				local method = 2
				-- Method 1 is a quick hacky implementation
				-- Method 2 tries to bend more between the fore and upper arm
				if method == 2 then
					local flippedness = 1
					if elbow.Arm:GetSprite().FlipX then
						flippedness = -1
					end
					local startpos = npc.Position + Vector(-30 * flippedness, -30)
					local endpos = elbow.Arm.Child.Child.Position
					local vec = (endpos - startpos) / 2
					elbow.Pointyness = elbow.Pointyness or 40

					if elbow.Arm.SpriteScale.X < 1 then
						elbow.Pointyness = elbow.Pointyness + ((1 - elbow.Arm.SpriteScale.X) * 10)
					else
						elbow.Pointyness = math.max(40, elbow.Pointyness - ((elbow.Arm.SpriteScale.X - 1)) * 10)
					end

					elbow.Position = startpos + vec + vec:Rotated(90 * flippedness):Resized(elbow.Pointyness)

				elseif method == 1 then
					local safePosition = npc.Position + Vector(200,0):Rotated(180 * elbow.Side) + Vector(0, -140)
					elbow.elbowLerpness = elbow.elbowLerpness or 0.01
					elbow.elbowLerpness = math.min(elbow.elbowLerpness + 0.005, 0.05)

					if elbow.Arm.Child.SpriteScale.X > 1 then
						elbow.movingHand = true
						if elbow.movingSafe then
							elbow.movingSafe = nil
							elbow.elbowLerpness = 0.001
						end
						elbow.Position = mod:Lerp(elbow.Position, elbow.Position + (elbow.Arm.Child.Child.Position - elbow.Position), elbow.elbowLerpness)
					else
						elbow.movingSafe = true
						if elbow.movingHand then
							elbow.movingHand = nil
							elbow.elbowLerpness = 0.001
						end
						elbow.Position = mod:Lerp(elbow.Position, elbow.Position + (safePosition - elbow.Position), elbow.elbowLerpness)
					end
				end
			end
		end
	end
end

function mod:duskArmAI(e)
	local sprite = e:GetSprite()
	local d = e:GetData()
	local useElbows = true
	
	local flippedness = 1
	e.SpriteOffset = Vector(0, -20)
	if sprite.FlipX then
		flippedness = -1
	end
	if d.dying then
		if sprite:IsFinished("ArmDeath") then
			e:Remove()
		else
			mod:spritePlay(sprite, "ArmDeath")
		end
		return
	end

	if e.Parent.Type == 180 then
		d.Bone = 2
	else
		d.Bone = 1
	end
	if e.FrameCount <= 10 then
		local alphaness = math.min(1, e.FrameCount / 10)
		e.Color = Color(1,1,1,alphaness)
	end
	mod:spritePlay(sprite, "Arm0" .. d.Bone)
	if e.Parent and e.Parent:Exists() and e.Child and e.Child:Exists() then
		if useElbows then
			local elbow
			if e.SpawnerEntity:GetData().elbows then
				if e.SpawnerEntity:GetData().elbows[flippedness] then
					elbow = e.SpawnerEntity:GetData().elbows[flippedness].Position
				else
					elbow = e.SpawnerEntity:GetData().elbows[2].Position
				end
			end
			if elbow then
				--New system
				if d.Bone == 1 then
					--Lower Arm
					d.startpoint = elbow
					d.endpoint = e.Child.Position + e.Child.SpriteOffset + Vector(-20 * flippedness, 10)
					e.Position = (d.startpoint + d.endpoint) / 2
					sprite.Rotation = (d.endpoint - d.startpoint):GetAngleDegrees() * flippedness
				else
					--Upper arm
					e.DepthOffset = -1000
					d.startpoint = e.Parent.Position + Vector(-30 * flippedness, -30)
					d.endpoint = elbow
					e.Position = (d.startpoint + d.endpoint) / 2
					sprite.Rotation = (d.endpoint - d.startpoint):GetAngleDegrees() * flippedness
				end
				local dist = d.startpoint:Distance(d.endpoint)
				--print(dist)
				e.SpriteScale = Vector(dist/200, 1)
			else
				d.dying = true
			end
		else
			--Old system
			if d.Bone == 1 then
				--Lower Arm
				d.startpoint = e.Parent.Position + Vector(-100 * flippedness, 0):Rotated(e.Parent:GetSprite().Rotation * flippedness)
				d.endpoint = e.Child.Position + e.Child.SpriteOffset + Vector(-20 * flippedness, 10)
				e.Position = (d.startpoint + d.endpoint) / 2
				sprite.Rotation = (d.endpoint - d.startpoint):GetAngleDegrees() * flippedness
			else
				e.DepthOffset = -50
				--Upper Arm
				d.startpoint = e.Parent.Position + Vector(-30 * flippedness, -30)
				e.Position = d.startpoint + Vector(-100 * flippedness, 0):Rotated(sprite.Rotation * flippedness)
				--Nah
				--e.Position = Vector(e.Position.X, math.min(e.Parent.Position.Y + 10, e.Position.Y))
				d.endpoint = e.Position + Vector(-100 * flippedness, 0):Rotated(sprite.Rotation * flippedness)
				d.posnegmovement = d.posnegmovement or 1
				if e.Parent.Position:Distance(e.Child.Child.Position) < 100 then
					d.posnegmovement = 1
					d.raising = true
				elseif e.Child.SpriteScale.X > 1 then
					d.posnegmovement = -1
					--[[if d.raising then
						d.posnegmovement = -1
						d.raising = false
					else
						d.prevChildSpritescale = d.prevChildSpritescale or e.Child.SpriteScale.X
						if e.Child.SpriteScale.X > d.prevChildSpritescale then
							d.posnegmovement = d.posnegmovement * -1
						end
					end]]
				else
					d.posnegmovement = 1
					d.raising = true
				end
				d.prevChildSpritescale = e.Child.SpriteScale.X
				d.changedness = d.changedness or d.posnegmovement
				if d.changedness ~= d.posnegmovement then
					d.moveVal = 0.5
					d.changedness = d.posnegmovement
				end
				d.moveVal = d.moveVal or 0.5
				d.moveVal = math.min(20, d.moveVal * 1.2)
				d.lerpMove = d.lerpMove or 0
				d.lerpMove = mod:Lerp(d.lerpMove, d.moveVal * d.posnegmovement, 0.1)
				sprite.Rotation = mod:Lerp(sprite.Rotation, sprite.Rotation + d.lerpMove, 0.1)
				if flippedness then
					sprite.Rotation = math.max(-50, sprite.Rotation)
					sprite.Rotation = math.min(80, sprite.Rotation)
				else
					sprite.Rotation = math.max(-80, sprite.Rotation)
					sprite.Rotation = math.min(50, sprite.Rotation)
				end
				--print(sprite.Rotation, flippedness)
			end
			local dist = d.startpoint:Distance(d.endpoint)
			--print(dist)
			e.SpriteScale = Vector(dist/200, 1)
		end
	else
		e:Remove()
	end
end

local fakeDuskTypesChecked = {
	[EntityType.ENTITY_TEAR] = true,
	[EntityType.ENTITY_KNIFE] = true,
	["1000" .. " " .. "1"] = true,

}

function mod:fakeDuskAI(e)
	local sprite = e:GetSprite()
	local d = e:GetData()

	if d.type == "TeleportDust" then
		d.faker = d.faker or math.random(3)
		if sprite:IsFinished("Fake0" .. d.faker) then
			e:Remove()
		else
			mod:spritePlay(sprite, "Fake0" .. d.faker)
		end
	elseif d.type == "Faker" then
		e.Color = Color(1,1,1,0.5)
		e.SpriteOffset = Vector(0, -5)
		if e.Parent and e.Parent:Exists() and not e.Parent:GetSprite():IsPlaying("Death") then
			local p = e.Parent
			if p:GetData().beenCaught == true then
				e.Velocity = e.Velocity * 0.8
				if sprite:IsFinished("TeleportDown") then
					e:Remove()
				elseif sprite:IsEventTriggered("Leave") then
					local smoke = Isaac.Spawn(1000,16,1,e.Position, nilvector,nil)
					smoke.Color = Color(0.3,0.3,0.3,0.7)
				else
					mod:spritePlay(sprite, "TeleportDown")
				end
			else
				d.orboff = p:GetData().orboff + (90 * d.offsetorb)
				local targ = d.currentOrbit.Position + Vector(p:GetData().orbitDist or 90, 0):Rotated(d.orboff)
				e.Velocity = mod:Lerp(e.Velocity, (targ - e.Position) * 0.3, 0.6)	
				
				if sprite:IsFinished("TeleportDown") then
					e:Remove()
				elseif sprite:IsEventTriggered("Leave") then
					local smoke = Isaac.Spawn(1000,16,1,e.Position, nilvector,nil)
					smoke.Color = Color(0.3,0.3,0.3,0.7)
				elseif p:GetData().sState == "Leave" then
					mod:spritePlay(sprite, "TeleportDown")
				elseif p:GetData().sState == "preappear" then
					mod:spritePlay(sprite, "Fake03")
				elseif not sprite:IsPlaying("TeleportDown") then
					if p:GetData().sState == "attack" and p:GetData().ShootingTrick then
						if sprite:IsFinished("Attack02" .. duskDirs[(p:GetData().attackPos + d.offsetorb) % 4]) then
							sprite:Play("TeleportDown")
						else
							mod:spritePlay(sprite, "Attack02" .. duskDirs[(p:GetData().attackPos + d.offsetorb) % 4])
						end
					else
						if sprite:IsFinished("Attack02") then
							mod:spritePlay(sprite, "Attack02Loop")
						elseif not sprite:IsPlaying("Attack02Loop") then
							mod:spritePlay(sprite, "Attack02")
						end
					end
				end

				if p:GetData().sState == "appear" and p:ToNPC().StateFrame > 20 then
					local accidentallyShot
					for _, entity in pairs(Isaac.GetRoomEntities()) do
						if fakeDuskTypesChecked[entity.Type] or fakeDuskTypesChecked[entity.Type .. " " .. entity.Variant] then
							if entity.Type ~= EntityType.ENTITY_TEAR or entity.EntityCollisionClass > 2 then
								local coll = entity.Size + p.Size
								if entity.Position:Distance(e.Position) <= coll then
									accidentallyShot = true
								end
							end
						end
					end
					if accidentallyShot then
						local pd = p:GetData()
						if not pd.UpdatedByGhost then
							pd.sState = "attack"
							pd.newtargOff = math.ceil(pd.orboff / 90) * 90
							pd.attackPos = (pd.newtargOff / 90) % 4
							pd.UpdatedByGhost = true
							p:ToNPC().StateFrame = 0
							sfx:Play(mod.Sounds.Dusk3, 1, 0, false, math.random(90,110)/100)
						end
					end
				end
			end
		else
			e.Velocity = nilvector
			if sprite:IsFinished("TeleportDown") then
				e:Remove()
			elseif sprite:IsEventTriggered("Leave") then
				local smoke = Isaac.Spawn(1000,16,1,e.Position, nilvector,nil)
				smoke.Color = Color(0.3,0.3,0.3,0.7)
			else
				mod:spritePlay(sprite, "TeleportDown")
			end
		end
	end
end

function mod:fakeBloodpoofAI(e)
	local sprite = e:GetSprite()
	if sprite:IsFinished("Poof") then
		e:Remove()
	else
		mod:spritePlay(sprite, "Poof")
	end
end

function mod:duskDebuffProjectileSplat(npc)
	sfx:Play(SoundEffect.SOUND_TEARIMPACTS, 1, 0, false, 1)
	local blood = Isaac.Spawn(1000, mod.FF.FakeBloodpoof.Var, mod.FF.FakeBloodpoof.Sub, npc.Position, nilvector, npc):ToEffect()
	blood.Color = mod.duskDebuffCols[npc.SubType]
	blood.SpriteOffset = Vector(0, -10)
	blood.SpriteScale = Vector(0.6,0.6)
	blood:Update()
end

function mod:duskDebuffProjectile(npc)
    local sprite = npc:GetSprite()
    local d = npc:GetData()

    if not d.init then
        d.init = true
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_DEATH_TRIGGER | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_FLASH_ON_DAMAGE)
        if npc.SubType == 0 or npc.SubType > 4 then
            npc.SubType = math.random(3) + 1
        end
		local anim = "Projectile0" .. npc.SubType
		if d.isSpiked then
			anim = anim.."_S"
			npc.CollisionDamage = 1
		end
        sprite:Play(anim)
    end

	--Cosmetic Trail
	if npc.FrameCount % 3 == 1 then
		local trail = Isaac.Spawn(1000,111,0,npc.Position,nilvector,npc)
		trail:GetSprite():ReplaceSpritesheet(0, "gfx/effects/tear_bloodytrail_white.png")
		trail:GetSprite():LoadGraphics()
		trail.SpriteScale = Vector(0.3,0.3) + (Vector.One * (math.random(4) / 10))
		trail.SpriteOffset = Vector(0, -10)
		trail.Color = mod.duskDebuffCols[npc.SubType]
		trail:Update()
	end

	if not d.isSpiked then
		npc.CollisionDamage = 0
	end
	npc.FallingAccel = -0.1
end

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, mod.duskDebuffProjectile, mod.FF.DebuffProjectile.Var)

function mod:duskDebuffProjectileColl(npc1, npc2)
	local player = npc2:ToPlayer()
	if player then
		--inflict status effect
		local d = npc1:GetData()
		if npc1.SubType == mod.FF.DebuffProjectileDark.Sub then
			--THIS IS NOT HOW I ACTUALLY WANT IT TO BE DON'T WORRY (its ok erf i just made it last twice as long :haphpteead:)
			--On second thought it's not actually that bad heh
			sfx:Play(mod.Sounds.StatusProjectile1, 2, 0, false, math.random(90,110)/100)
			local duration = 300
			if d.EffectTime then
				duration = math.floor(d.EffectTime * 2.5)
			end
			game:Darken(1, duration)
			--mod.DuskDarkenDebuff = {Timer = duration, Data = {}}
		elseif npc1.SubType == mod.FF.DebuffProjectileFear.Sub then
			sfx:Play(mod.Sounds.StatusProjectile3, 2, 0, false, math.random(90,110)/100)
			player:AddFear(EntityRef(npc1.SpawnerEntity or npc1), d.EffectTime or 120)
		elseif npc1.SubType == mod.FF.DebuffProjectileSlow.Sub then
			sfx:Play(mod.Sounds.StatusProjectile2, 2, 0, false, math.random(90,110)/100)
			local slowColor = Color(1.5, 1.5, 1.5, 1, 0, 0, 0)
			player:AddSlowing(EntityRef(npc1.SpawnerEntity or npc1), d.EffectTime or 120, 0.8, mod.ColorNormal)
			player:GetData().CustomDuskDebuffSlow = true
		end
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, mod.duskDebuffProjectileColl, mod.FF.DebuffProjectile.Var)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, proj)
	if proj.Variant == mod.FF.DebuffProjectile.Var then
		mod:duskDebuffProjectileSplat(proj)
	end
end, mod.FF.DebuffProjectile.ID)

function mod.duskDarkenShit()
	if mod.DuskDarkenDebuff then
		mod.DuskDarkenDebuff.Timer = mod.DuskDarkenDebuff.Timer - 1
		if mod.DuskDarkenDebuff.Timer <= 0 then
			mod.DuskDarkenDebuff = nil
		end
	end
end

function mod:handlePlayerCustomSlow(player, data)
	if data.CustomDuskDebuffSlow then
		if player:HasEntityFlags(EntityFlag.FLAG_SLOW) then
			if player.FrameCount % 4 == 0 then
				player:SetColor(Color(1.5,1.5,1.5,1),2,99,true,false)
			end
		else
			data.CustomDuskDebuffSlow = nil
		end
	end
end
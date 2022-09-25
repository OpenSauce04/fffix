local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--A large chunk of this was done by minichibis too!

mod.heiressaddtable = {
	{mod.FF.Hover.ID, mod.FF.Hover.Var},
	{mod.FF.Hover.ID, mod.FF.Hover.Var},
	{mod.FF.Hover.ID, mod.FF.Hover.Var},
	{mod.FF.Stingler.ID, mod.FF.Stingler.Var},
	{mod.FF.Stingler.ID, mod.FF.Stingler.Var},
	{mod.FF.HoneyEye.ID, mod.FF.HoneyEye.Var},
	{mod.FF.HoneyEye.ID, mod.FF.HoneyEye.Var},
	--{mod.FF.Honeydrip.ID, mod.FF.Honeydrip.Var},
	{mod.FF.Homer.ID, mod.FF.Homer.Var},
	{mod.FF.Homer.ID, mod.FF.Homer.Var},
}

mod.heiressaddtableii = {
	"milkteeth",
	"moters",
	"moters",
	"spooters",
	"spooters",
	"suckers",
	"suckers",
	"pooters",
	"pooters",
	"pooters",
	"boom",
	"maggot",
	"maggot",
	"maggot",
	"onetooth"
}

--THE HEIRESS: posthumous honeydrop, with complex ai that will be a pain in the ass to code comparatively. Happy birthday Erfly you cuckold.
function mod:heiressai(npc, sprite, npcdata)
	local honeycolor = Color(1,1,1,1,0,0,0)
	honeycolor:SetColorize(5, 5, 5, 1)
	local target = npc:GetPlayerTarget()
	local targetpos = target.Position
	local anglebetween = (npc.Position - target.Position):GetAngleDegrees()

	if not npcdata.init then
		npcdata.phase = "fullbody"
		npcdata.state = "tracking"
		npcdata.laststate = "slam"
		npcdata.staterepeats = 99
		npcdata.stateframe = 0
		npcdata.changetimer = math.random(150, 180)
		npcdata.init = true
		npcdata.spitskull = false
	end

	if npcdata.phase == "fullbody" then
		npcdata.changetimer = npcdata.changetimer - 1
		--creep
		if npcdata.stateframe % 3 == 0 then
			local creep = Isaac.Spawn(1000, EffectVariant.CREEP_BROWN, 0, npc.Position, Vector(0,0), npc):ToEffect();
			creep.SpriteScale = Vector(0.75, 0.5)
			--creep:SetTimeout(math.floor(creep.Timeout * 0.33))
			creep:Update()
			creep:GetSprite().Color = honeycolor
		end
		if npcdata.state == "tracking" then
			--movement
			npcdata.stateframe = npcdata.stateframe + 1
			local wantdist = 100 + (math.sin(npcdata.stateframe * 0.075) * 30)
			local wantpos = targetpos + Vector(wantdist, 0):Rotated(anglebetween + 3)
			local wantangle = (wantpos - npc.Position):GetAngleDegrees()
			npc.Velocity = mod:Lerp(npc.Velocity, Vector(3.5, 0):Rotated(wantangle), 0.1)
			--sprite shit
			mod:spritePlay(sprite, "Idle")
			local anglehead = math.floor(anglebetween / 30) + 7
			anglehead = ((anglehead + 8) % 12) + 1
			anglehead = math.abs(anglehead - 12) + 1
			sprite:SetOverlayFrame("IdleHead"..anglehead, sprite:GetFrame())
			--change state
			if npcdata.changetimer <= 0 and sprite:GetFrame() == 0 then
				if npc.HitPoints <= npc.MaxHitPoints * 0.4 then
					npcdata.phase = "thequeenhaslostherhead"
					npcdata.state = "eating"
					mod:spritePlay(sprite, "SummonHeadSwallow")
					npcdata.staterepeats = 99
					npcdata.laststate = "summon"
					sprite:RemoveOverlay()
				elseif npcdata.laststate == "slam" then
					--slamming streak
					if math.random(npcdata.staterepeats, npcdata.staterepeats + 1) >= 3 then
						npcdata.staterepeats = 1
						npcdata.state = "summon"
						npcdata.laststate = "summon"
						mod:spritePlay(sprite, "Summon")
						sprite:RemoveOverlay()
					else
						npcdata.state = "slam"
						npcdata.staterepeats = npcdata.staterepeats + 1
						mod:spritePlay(sprite, "Slam")
						sprite:RemoveOverlay()
					end
				else
					--summon streak
					if math.random(npcdata.staterepeats, 2) >= 2 then
						npcdata.staterepeats = 1 - npcdata.staterepeats
						npcdata.state = "slam"
						mod:spritePlay(sprite, "Slam")
						sprite:RemoveOverlay()
					else
						npcdata.state = "summon"
						npcdata.staterepeats = npcdata.staterepeats + 1
						mod:spritePlay(sprite, "Summon")
						sprite:RemoveOverlay()
					end
				end
			end
		elseif npcdata.state == "slam" then
			npc.Velocity = mod:Lerp(npc.Velocity, Vector(0, 0), 0.35)
			if sprite:GetFrame() == 24 then
				--creep
				local creep = Isaac.Spawn(1000, EffectVariant.CREEP_BROWN, 0, npc.Position, Vector(0,0), npc):ToEffect();
				creep.SpriteScale = Vector(2, 1)
				creep:SetTimeout(math.floor(creep.Timeout * 3))
				creep:Update()
				creep:GetSprite().Color = honeycolor
				-- bullets
				local shootyangle = 0
				for i = 1, 12, 1 do
					local projectile = Isaac.Spawn(9, 0, 0, npc.Position, (Vector(4,0):Rotated(shootyangle)), npc):ToProjectile();
					projectile.FallingAccel = -0.1
					projectile.Scale = 1.5
					shootyangle = shootyangle + 30
				end
				shootyangle = 15
				for i = 1, 12, 1 do
					local projectile = Isaac.Spawn(9, 1, 0, npc.Position, (Vector(5.5,0):Rotated(shootyangle)), npc):ToProjectile();
					projectile.FallingAccel = -0.1
					projectile.Scale = 1
					shootyangle = shootyangle + 30
				end
				--sounds
				game:ShakeScreen(10)
				npc:PlaySound(48, 2, 0, false, 0.5);
				npc:PlaySound(SoundEffect.SOUND_ROCK_CRUMBLE, 0.66, 0, false, 1)
			elseif sprite:GetFrame() == 40 then
				--bullets
				local shootyangle = 15
				for i = 1, 12, 1 do
					local projectile = Isaac.Spawn(9, (i % 2), 0, npc.Position, (Vector(4.5,0):Rotated(shootyangle)), npc):ToProjectile();
					projectile.FallingAccel = -0.1
					projectile.Scale = 1
					shootyangle = shootyangle + 30
				end
				--sound
				npc:PlaySound(SoundEffect.SOUND_BIRD_FLAP, 2, 0, false, 1.5)
				sfx:Play(SoundEffect.SOUND_BONE_HEART, 0.75, 0, false, 1)
			elseif sprite:GetFrame() == 58 then
				npc:PlaySound(SoundEffect.SOUND_BIRD_FLAP, 2, 0, false, 2.25)
				sfx:Play(SoundEffect.SOUND_BONE_HEART, 0.75, 0, false, 1.5)
			elseif sprite:IsFinished("Slam") then
				npcdata.state = "tracking"
				npcdata.changetimer = math.random(80, 120)
				npcdata.stateframe = 0
			end
		elseif npcdata.state == "summon" then
			npc.Velocity = mod:Lerp(npc.Velocity, Vector(0, 0), 0.35)
			if sprite:GetFrame() == 27 then
				--enemy
				local add = mod.heiressaddtable[math.random(1, #mod.heiressaddtable)]
				local enemy = Isaac.Spawn(add[1], add[2], 0, npc.Position, Vector(7, 0):Rotated(anglebetween), npc):ToNPC()
				enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				--corn
				for i = 1, 3, 1 do
					local corn = Isaac.Spawn(256, 0, 0, npc.Position, RandomVector() * 3, npc);
					corn:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					corn.MaxHitPoints = corn.MaxHitPoints * 0.5
					corn.HitPoints = corn.MaxHitPoints
					corn:Update()
				end
				--sound
				npc:PlaySound(SoundEffect.SOUND_SUMMONSOUND, 0.6, 0, false, 0.75)
				npc:PlaySound(SoundEffect.SOUND_SPIDER_COUGH, 1, 0, false, 1)
			elseif sprite:GetFrame() == 40 then
				npc:PlaySound(SoundEffect.SOUND_BIRD_FLAP, 2, 0, false, 1.3)
				sfx:Play(SoundEffect.SOUND_BONE_HEART, 0.75, 0, false, 0.8)
			elseif sprite:GetFrame() == 52 then
				npc:PlaySound(SoundEffect.SOUND_BIRD_FLAP, 2, 0, false, 1.8)
				sfx:Play(SoundEffect.SOUND_BONE_HEART, 0.75, 0, false, 1.3)
			elseif sprite:IsFinished("Summon") then
				npcdata.state = "tracking"
				npcdata.changetimer = math.random(120, 150)
				npcdata.stateframe = 0
			end
		end
	elseif npcdata.phase == "thequeenhaslostherhead" then
		npcdata.changetimer = npcdata.changetimer - 1
		--creep
		if npcdata.stateframe % 3 == 0 then
			local creep = Isaac.Spawn(1000, EffectVariant.CREEP_RED, 0, npc.Position, Vector(0,0), npc):ToEffect();
			creep.SpriteScale = Vector(0.75, 0.5)
			--creep:SetTimeout(math.floor(creep.Timeout * 0.33))
			creep:Update()
			--creep:GetSprite().Color = honeycolor
		end
		if npcdata.state == "eating" then
			npcdata.stateframe = 1
			npc.Velocity = mod:Lerp(npc.Velocity, Vector(0, 0), 0.35)
			if sprite:GetFrame() == 27 then
				--corn
				for i = 1, 3, 1 do
					local corn = Isaac.Spawn(256, 0, 0, npc.Position, RandomVector() * 3, npc);
					corn:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					corn.MaxHitPoints = corn.MaxHitPoints * 0.5
					corn.HitPoints = corn.MaxHitPoints
					corn:Update()
				end
				--somethings wrong...
				for i = 1, 2, 1 do
					EntityNPC.ThrowSpider(npc.Position, npc, mod:chooserandomlocationforskuzz(npc, 100, 50), false, 0)
				end
				--sound
				npc:PlaySound(SoundEffect.SOUND_SUMMONSOUND, 0.6, 0, false, 0.7)
				npc:PlaySound(SoundEffect.SOUND_SPIDER_COUGH, 1, 0, false, 0.95)
			elseif sprite:GetFrame() == 43 then
				--BONES
				local bonesnumber = math.random(7, 15)
				local params = ProjectileParams()
				for i = 1, bonesnumber, 1 do
					params.Variant = math.min(math.random(0, 3), 1)
					params.FallingSpeedModifier = math.random(5, 25) * - 1
					params.FallingAccelModifier = 0.5
					npc:FireProjectiles(npc.Position, Vector(math.random(8,50) * 0.1,0):Rotated(math.random(1,360)), 0, params)
				end
				--sound
				game:ShakeScreen(10)
				npc:PlaySound(48, 2, 0, false, 0.9);
				sfx:Play(SoundEffect.SOUND_BONE_SNAP, 2, 0, false, math.random() + 0.5)
			elseif sprite:IsFinished("SummonHeadSwallow") then
				npcdata.state = "tracking"
				npcdata.changetimer = math.random(150, 180)
				npcdata.stateframe = 0
			end
		elseif npcdata.state == "tracking" then
			npcdata.stateframe = npcdata.stateframe + 1
			--movement
			npcdata.stateframe = npcdata.stateframe + 1
			local wantdist = 100 + (math.sin(npcdata.stateframe * 0.075) * 30)
			local wantpos = targetpos + Vector(wantdist, 0):Rotated(anglebetween - 4.5)
			local wantangle = (wantpos - npc.Position):GetAngleDegrees()
			npc.Velocity = mod:Lerp(npc.Velocity, Vector(3.5, 0):Rotated(wantangle), 0.1)
			--sprite shit
			mod:spritePlay(sprite, "Idle")
			--state machine
			if npcdata.changetimer <= 0 and sprite:GetFrame() == 0 then
				if npcdata.laststate == "slam" then
					--slam
					npcdata.state = "summon"
					npcdata.laststate = "summon"
					mod:spritePlay(sprite, "SummonHeadless")
				else
					--summon streak
					npcdata.state = "slam"
					npcdata.laststate = "slam"
					mod:spritePlay(sprite, "SlamHeadless")
				end
			end
		elseif npcdata.state == "slam" then
			npc.Velocity = mod:Lerp(npc.Velocity, Vector(0, 0), 0.35)
			if sprite:GetFrame() == 24 then
				--creep
				local creep = Isaac.Spawn(1000, EffectVariant.CREEP_RED, 0, npc.Position, Vector(0,0), npc):ToEffect();
				creep.SpriteScale = Vector(2, 1)
				creep:SetTimeout(math.floor(creep.Timeout * 3))
				creep:Update()
				--creep:GetSprite().Color = honeycolor
				-- bullets
				local microoffset = 10
				local shootyangle = 0 - microoffset
				for i = 1, 6, 1 do
					for j = 1, 3, 1 do
						local projectile = Isaac.Spawn(9, ((j + 1) % 2), 0, npc.Position, (Vector(4,0):Rotated(shootyangle)), npc):ToProjectile();
						projectile.FallingAccel = -0.1
						projectile.Scale = 1
						shootyangle = shootyangle + microoffset
					end
					shootyangle = shootyangle - (microoffset * 3) + 40
					for j = 1, 3, 1 do
						local projectile = Isaac.Spawn(9, 0, 0, npc.Position, (Vector(6 - j,0):Rotated(shootyangle)), npc):ToProjectile();
						projectile.FallingAccel = -0.1
						if j == 1 then
							projectile.Scale = 2
						else
							projectile.Scale = 0.75
						end
					end
					shootyangle = shootyangle + 20
				end
				--sounds
				game:ShakeScreen(10)
				npc:PlaySound(48, 2, 0, false, 0.5);
				npc:PlaySound(SoundEffect.SOUND_ROCK_CRUMBLE, 0.66, 0, false, 1)
			elseif sprite:IsFinished("SlamHeadless") then
				npcdata.state = "tracking"
				npcdata.changetimer = math.random(80, 120)
				npcdata.stateframe = 0
			end
		elseif npcdata.state == "summon" then
			npc.Velocity = mod:Lerp(npc.Velocity, Vector(0, 0), 0.35)
			if sprite:GetFrame() == 18 then
				--enemy
				local add = mod.heiressaddtableii[math.random(1, #mod.heiressaddtableii)]
				print(add)
				if add == "milkteeth" then
					for i = 1, 2, 1 do
						local enemy = Isaac.Spawn(mod.FF.MilkTooth.ID, mod.FF.MilkTooth.Var, 0, npc.Position, Vector(4, 0):Rotated(math.random(360)), npc):ToNPC()
						enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					end
				elseif add == "moters" then
					for i = 1, 2, 1 do
						local enemy = Isaac.Spawn(80, 0, 0, npc.Position, Vector(4, 0):Rotated(math.random(360)), npc):ToNPC()
						enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					end
				elseif add == "suckers" then
					for i = 1, 3, 1 do
						local enemy = Isaac.Spawn(61, math.max(math.random(-3, 1), 0), 0, npc.Position, Vector(4, 0):Rotated(math.random(360)), npc):ToNPC()
						enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					end
				elseif add == "pooters" then
					for i = 1, 3, 1 do
						local enemy = Isaac.Spawn(14, math.max(math.random(-2, 1), 0), 0, npc.Position, Vector(4, 0):Rotated(math.random(360)), npc):ToNPC()
						enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					end
				elseif add == "boom" then
					local enemy = Isaac.Spawn(25, math.min(math.random(0, 2), 1), 0, npc.Position, Vector(4, 0):Rotated(math.random(360)), npc):ToNPC()
					enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				elseif add == "onetooth" then
					local enemy = Isaac.Spawn(234, 0, 0, npc.Position, Vector(4, 0):Rotated(math.random(360)), npc):ToNPC()
					enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				elseif add == "spooters" then
					for i = 1, 2, 1 do
						EntityNPC.ThrowSpider(npc.Position, npc, mod:chooserandomlocationforskuzz(npc, 100, 50), false, 0)
					end
					--throwspider doesnt return shit so i gotta do this
					for _, spidermaybe in ipairs(Isaac.GetRoomEntities()) do
						if spidermaybe.Type == 85 and spidermaybe.SpawnerType == 666 and spidermaybe.FrameCount == 0 then
							spidermaybe:ToNPC():Morph(mod.FF.Spooter.ID, mod.FF.Spooter.Var, 0, -1)
						end
					end
				elseif add == "maggot" then
					for i = 1, 2, 1 do
						mod:shootMaggot(npc, mod:chooserandomlocationforskuzz(npc, 150, 75), 1)
					end
				end
				--spiders
				for i = 1, 2, 1 do
					EntityNPC.ThrowSpider(npc.Position, npc, mod:chooserandomlocationforskuzz(npc, 100, 50), false, 0)
				end
				--sound
				npc:PlaySound(SoundEffect.SOUND_SUMMONSOUND, 0.6, 0, false, 0.75)
				npc:PlaySound(SoundEffect.SOUND_SPIDER_COUGH, 1, 0, false, 1)
			elseif sprite:IsFinished("SummonHeadless") then
				npcdata.state = "tracking"
				npcdata.changetimer = math.random(120, 150)
				npcdata.stateframe = 0
			end
		end
	end
end
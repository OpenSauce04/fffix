local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

local function GetFruitMulti(fruit)
	return math.max(0.5, mod:GetHealthPercent(fruit))
end

local function GetFruitHealMulti(fruit)
	return mod:GetHealthPercent(fruit, true)
end

function mod:bascoAI(npc, sprite, data)
	local target = npc:GetPlayerTarget()
	local targetpos = mod:confusePos(npc, target.Position)
	local room = game:GetRoom()
	local r = npc:GetDropRNG()

	if not data.init then
		data.init = true
		data.attacksincefruits = 2
		npc.SpriteOffset = Vector(0,5)
		npc:SetSize(npc.Size, Vector(1,0.75), 16)
		data.canChomp = true
		data.creeping = 0
		data.spiced = 0
		data.haemos = 0
		data.ragetimer = 0
		data.patooies = 0
		data.state = "idle"
	else
		npc.StateFrame = npc.StateFrame + 1
		data.ragetimer = data.ragetimer - 1
	end
	if data.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		local interval = 15
		if data.enraged then
			interval = 10
		end
		if npc.StateFrame % interval == 1 then
			if data.canChomp and npc.StateFrame > 0 then
				data.targetfruit = mod:GetNearestThing(npc.Position, mod.FF.BascoFood.ID, mod.FF.BascoFood.Var)
			end
			if data.targetfruit --[[and data.targetfruit.Position:Distance(npc.Position) < 500]] then
				npc.TargetPosition = data.targetfruit.Position
				local speed = 5 + (5 * (1 - (mod:GetHealthPercent(npc))))
				data.vel = (npc.TargetPosition - npc.Position):Resized(speed)
			else
				data.targetfruit = nil
				data.vel = RandomVector()*5
			end
			npc.Velocity = data.vel
		else
			npc.Velocity = npc.Velocity * 0.9
		end
		if data.patooies > 0 then
			data.state = "spicyPatooie"
		elseif data.haemos > 0 then
			data.state = "spew"
		elseif data.enraged and data.ragetimer <= 0 then
			data.state = "rageend"
		else
			if npc.StateFrame > 50 or (data.targetfruit and npc.TargetPosition:Distance(npc.Position) < 50) then
				if data.targetfruit and npc.TargetPosition:Distance(npc.Position) < 100 then
					if math.abs(npc.TargetPosition.Y - npc.Position.Y) > math.abs(npc.TargetPosition.X - npc.Position.X) then
						if npc.TargetPosition.Y < npc.Position.Y then
							data.suffix = "Up"
							data.chomppos = Vector(0,-30)
						else
							data.suffix = "Down"
							data.chomppos = Vector(0,30)
						end
					else
						data.suffix = "Hori"
						if npc.TargetPosition.X < npc.Position.X then
							sprite.FlipX = true
							data.chomppos = Vector(-30,0)
						else
							data.chomppos = Vector(30,0)
						end
					end
					data.state = "chomp"
					if mod:RandomInt(1,2) == 1 then
						data.canChomp = false
					end
					data.attacksincefruits = data.attacksincefruits + 1
				else
					local nextchoice = data.nextchoice or mod:ChooseNextBascoAttack(npc, data)
					if nextchoice == "stomp" then
						data.attacksincefruits = 0
					else
						data.attacksincefruits = data.attacksincefruits + 1
					end
					data.state = nextchoice
					data.canChomp = true
				end
				data.targetfruit = nil
				data.nextchoice = nil
			end
		end
	elseif data.state == "stomp" then
		npc.Velocity = npc.Velocity * 0.1
		if sprite:IsFinished("Stomp") then
			data.state = "idle"
            data.attacksincefruits = 0
			npc.StateFrame = -50
		elseif sprite:IsEventTriggered("Jump") then
			npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,1,0,false,0.6)
			mod:PlaySound(SoundEffect.SOUND_BOSS_LITE_ROAR, npc, 0.8, 1)
		elseif sprite:IsEventTriggered("Land") then
			npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS,1,0,false,1)
			game:ShakeScreen(5)
			--Projectiles
			local params = ProjectileParams()
			params.Scale = 1.5
			params.FallingAccelModifier = -0.08
			if data.enraged then
				params.BulletFlags = ProjectileFlags.EXPLODE
				params.Color = mod.ColorCrackleOrange
				mod:SetGatheredProjectiles()
				npc:FireProjectiles(npc.Position, Vector(14,0), 6, params)
				params.Scale = 2
				params.BulletFlags = ProjectileFlags.BOUNCE
				npc:FireProjectiles(npc.Position, Vector(10,0), 7, params)
				for _, proj in pairs(mod:GetGatheredProjectiles()) do
					if data.enraged then
						proj:GetData().projType = "Basco"
						proj:GetData().bascoSpecial = "fireball"
					end
				end
			else
				params.Variant = 4
				params.Color = mod.ColorRedPoop
				npc:FireProjectiles(npc.Position, Vector(12,0), 6, params)
				params.Scale = 2
				params.BulletFlags = ProjectileFlags.BOUNCE
				npc:FireProjectiles(npc.Position, Vector(8,0), 7, params)
			end
			--Creep
			local creeps = {}
			local creep = Isaac.Spawn(1000, EffectVariant.CREEP_RED, 0, npc.Position, Vector.Zero, npc):ToEffect();
			table.insert(creeps,creep)
			local rand = mod:RandomInt(360)
			for i = 120, 360, 120 do
				local creep = Isaac.Spawn(1000, EffectVariant.CREEP_RED, 0, npc.Position + Vector(mod:RandomInt(25,30), 0):Rotated(i + rand) , Vector.Zero, npc):ToEffect();
				table.insert(creeps,creep)
			end
			for _, creep in pairs(creeps) do
				if data.enraged then
					creep.Color = mod.ColorGreyscaleLight
					creep:SetColor(mod.ColorFireJuicy, 135, 0, true, false)
				else
					creep.Color = Color(1,1,1,1,0.1,0.1,0.1)
				end
				creep.SpriteScale = Vector(4, 3.5)
				creep:SetTimeout(90)
				creep:Update()
			end
			local effect = Isaac.Spawn(1000,16,3,npc.Position,Vector.Zero,npc)
			effect.Color = npc.SplatColor
			--Fruits
			local spicy1
			local spicy2 
			if npc.HitPoints < npc.MaxHitPoints * 0.33 then
				spicy1 = mod:RandomInt(1,3)
				spicy2 = mod:RandomInt(1,3)
				if spicy2 == spicy1 then
					spicy2 = spicy2 + 1
					if spicy2 > 3 then
						spicy2 = 1
					end
				end
			elseif npc.HitPoints < npc.MaxHitPoints * 0.66 then
				spicy1 = mod:RandomInt(1,3)
			end
			for i = 1, 3 do
				local sub = i
				if (spicy1 and spicy1 == i) or (spicy2 and spicy2 == i) then
					sub = sub + 10
				end
				local pos = mod:FindRandomValidPathPosition(npc, 2, 80)
				local fruit = Isaac.Spawn(mod.FF.BascoFood.ID, mod.FF.BascoFood.Var, sub, pos, Vector.Zero, npc)
				fruit.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				fruit:Update()
			end
		else
			mod:spritePlay(sprite, "Stomp")
		end
	elseif data.state == "summon" then
		npc.Velocity = npc.Velocity * 0.1
		if sprite:IsFinished("Summon") then
			data.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Summon") then
			npc:PlaySound(SoundEffect.SOUND_SUMMONSOUND, 1, 0, false, 1)
			mod:PlaySound(mod.Sounds.Burpie, npc, 0.6, 1.3)
			for i = 1, 2 do
				local spawnpos = mod:FindRandomValidPathPosition(npc, 2, 30)
				local dip = Isaac.Spawn(mod.FF.FlyingSpicyDip.ID, mod.FF.FlyingSpicyDip.Var, mod.FF.FlyingSpicyDip.Sub, npc.Position, (spawnpos - npc.Position)/18, npc)
				if data.enraged then
					dip:GetSprite():ReplaceSpritesheet(0, "gfx/enemies/berry/spicydip_extraspicy.png")
					dip:GetSprite():LoadGraphics()
					dip:GetData().extraspicy = true
				end
			end
			local effect = Isaac.Spawn(1000,16,4,npc.Position,Vector.Zero,npc)
			effect.Color = npc.SplatColor
		else
			mod:spritePlay(sprite, "Summon")
		end
	elseif data.state == "roll" then
		if data.rollstate == nil then
			npc.Velocity = npc.Velocity * 0.1
			if sprite:IsFinished("RollStart") then
				data.rollstate = 1
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("Jump") then
				npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,1,0,false,0.6)
				mod:PlaySound(SoundEffect.SOUND_BOSS_LITE_ROAR, npc, 0.8, 1)
			elseif sprite:IsEventTriggered("Land") then
				npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS,0.8,0,false,1)
				npc:SetSize(npc.Size, Vector(0.75,0.75), 16)
			else
				mod:spritePlay(sprite, "RollStart")
			end
		elseif data.rollstate == 1 then
			local rolltarget = targetpos
			local targetfruit = mod:GetNearestThing(npc.Position, mod.FF.BascoFood.ID, mod.FF.BascoFood.Var)
			local isFruit
			if targetfruit and targetfruit.Position:Distance(npc.Position) < 150 then
				rolltarget = targetfruit.Position
				isFruit = true
			end
			local speed = 16.5
			if data.enraged then
				speed = 18
			end
			mod:CatheryPathFinding(npc, rolltarget, {
				Speed = speed,
				Accel = 0.05,
			})
			mod:DestroyNearbyGrid(npc, 70)
			data.extradir = ""
			if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
				data.dir = "Hori"
				if npc.Velocity.X > 0 then
					sprite.FlipX = false
				else
					sprite.FlipX = true
				end
			else
				if npc.Velocity.Y > 0 then
					data.dir = "Vert"
				else
					data.dir = "Vert"
					data.extradir = "Backwards"
				end
			end
			mod:spritePlay(sprite, "Roll" .. data.dir .. data.extradir)
			if npc.StateFrame > 90 and not isFruit then
				data.rollstate = 2
				data.lastdir = data.dir
			end
			if data.enraged and npc.FrameCount % 5 == 0 then
				local fire = Isaac.Spawn(1000,7005, 0, npc.Position, npc.Velocity:Rotated(180) / 5, npc)
				fire.SpriteScale = Vector(0.9,0.9)
				fire:GetData().timer = 30
				fire:Update()
			end
		elseif data.rollstate == 2 then
			if sprite:WasEventTriggered("SlowDown") then
				npc.Velocity = npc.Velocity * 0.8
			end
			if sprite:IsFinished("RollEnd" .. data.lastdir) then
				if data.patooies > 0 then
					data.state = "spicyPatooie"
				elseif data.spiced > 0 then
					data.state = "ragebegin"
				else
					data.state = "idle"
				end
				npc.StateFrame = 30
				data.rollstate = nil
			elseif sprite:IsEventTriggered("StopFlip") then
				sprite.FlipX = false
				npc:SetSize(npc.Size, Vector(1,0.75), 16)
			else
				mod:spritePlay(sprite, "RollEnd" .. data.lastdir)
			end
		end
	elseif data.state == "chomp" then
		if sprite:IsFinished("Eat"..data.suffix) then
			data.suffix = nil
			sprite.FlipX = false
			if data.haemos > 0 then
				data.state = "spew"
			else
				npc.StateFrame = 0
				data.targetfruit = nil
				data.state = "idle"
			end
		elseif sprite:IsEventTriggered("Shoot") then
			data.fruitmults = {}
			local chomppos = npc.Position + data.chomppos
			for _, fruit in pairs(Isaac.FindInRadius(chomppos, 60)) do
				if fruit.Type == mod.FF.BascoFood.ID and fruit.Variant == mod.FF.BascoFood.Var then
					if fruit:GetData().IsSpicy then
						if data.enraged then
							data.ragetimer = data.ragetimer + 450
							data.patooies = data.patooies + 1
						else
							data.spiced = data.spiced + 450
						end
					else
						table.insert(data.fruitmults, GetFruitMulti(fruit))
						data.haemos = data.haemos + 1
						mod:DoBascoHeal(npc, fruit, 40)
					end
					fruit:Kill()
				elseif fruit:ToNPC() or fruit:ToPlayer() then
					if fruit.InitSeed ~= npc.InitSeed then
						fruit:TakeDamage(30, 0, EntityRef(npc), 0)
					end
				end
			end
			for i = 1, mod:RandomInt(3,5) do
				local rubble = Isaac.Spawn(1000, 4, 0, chomppos, (chomppos - npc.Position):Resized(mod:RandomInt(5,10)):Rotated(mod:RandomInt(-60,60)), npc)
				rubble:Update()
			end
			mod:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, npc, 1.5, 1)
		elseif sprite:IsEventTriggered("Chomp") then
			if data.patooies > 0 then
				sprite.FlipX = false
				data.state = "spicyPatooie"
			elseif data.spiced > 0 then
				sprite.FlipX = false
				data.state = "ragebegin"
			end
			mod:PlaySound(mod.Sounds.LipSmack, npc, 0.8, 2)
		else
			mod:spritePlay(sprite, "Eat"..data.suffix)
		end
		npc.Velocity = npc.Velocity * 0.1
	elseif data.state == "spew" then
		if sprite:IsFinished("Summon") then
			data.state = "idle"
			npc.StateFrame = 30
			data.targetfruit = nil
		elseif sprite:IsEventTriggered("Summon") then
			mod:SetGatheredProjectiles()
			local params = ProjectileParams()
			params.FallingAccelModifier = 1
			local mult = (mod:SumTable(data.fruitmults) / data.haemos)
			params.Scale = 2.5 * mult
			for i = 1, (data.haemos * 3) do
				params.FallingSpeedModifier = mod:RandomInt(-15,-30)
				if data.enraged then
					params.Color = mod.ColorCrackleOrange
				end
				local offset = mod:RandomInt(120)
				local projtarget = targetpos + (RandomVector() * offset)
				local iterlimit = 0
				while (iterlimit < 10 and not room:IsPositionInRoom(projtarget, 15)) do
					projtarget = projtarget + (targetpos - projtarget):Resized(offset/mod:RandomInt(5,10)):Rotated(mod:RandomInt(-45,45))
					iterlimit = iterlimit + 1
				end
				npc:FireProjectiles(npc.Position, (projtarget - npc.Position) / 30, 0, params)
			end
			data.haemos = 0
			for _, projectile in pairs(mod:GetGatheredProjectiles()) do
				local projdata = projectile:GetData()
				projdata.projType = "Basco"
				if data.enraged then
					projdata.bascoSpecial = "spicyhaemo"
				else
					projdata.bascoSpecial = "haemo"
				end
				projdata.mult = mult
				local projsprite = projectile:GetSprite()
				projsprite:Load("gfx/projectiles/002.035_balloon tear.anm2",true)
				projsprite:Play(mod:GetTearProjScale(projectile, "RegularTear"), true)
			end
			npc:PlaySound(mod.Sounds.WateryBarf,1.5,0,false,0.8)
			local effect = Isaac.Spawn(1000,16,4,npc.Position,Vector.Zero,npc)
			effect.Color = npc.SplatColor
		else
			mod:spritePlay(sprite, "Summon")
		end
		npc.Velocity = npc.Velocity * 0.1
	elseif data.state == "ragebegin" then
		data.smokin = true
		if not sfx:IsPlaying(mod.Sounds.KettleWhistle) then
			mod:PlaySound(mod.Sounds.KettleWhistle, npc)
		end
		if sprite:IsFinished("RageStart") then
			sprite:Load("gfx/bosses/basco/basco2.anm2", true)
			sprite:Play("Idle")
			npc.SplatColor = mod.ColorFireJuicy
			data.state = "idle"
			data.ragetimer = data.spiced
			data.patooies = math.max(0, (data.spiced - 450)/450)
			data.spiced = 0
			sfx:Stop(mod.Sounds.KettleWhistle)
			npc.StateFrame = 30
		elseif sprite:IsEventTriggered("Shoot") then
			data.enraged = true
			data.flamin = true
			mod:PlaySound(mod.Sounds.SteamTrainWhistle, npc)
			mod:MakeFireWaveCross(npc.Position, false, npc)
		elseif sprite:IsEventTriggered("SlowDown") then
			data.flamin = false
		else
			mod:spritePlay(sprite, "RageStart")
		end
		if data.flamin and npc.StateFrame % 2 == 0 then --Stolen from Phoenix
			local dir = mod:RandomInt(0, 3)
            local angle = 0

            if dir == 0 then
                angle = mod:RandomInt(35, 55)
            elseif dir == 1 then
                angle = mod:RandomInt(125, 145)
            elseif dir == 2 then
                angle = mod:RandomInt(215, 235)
            else
                angle = mod:RandomInt(305, 325)
            end
            local vel = Vector(mod:RandomInt(7,8) * math.sin(math.rad(angle)), mod:RandomInt(7,8) * math.cos(math.rad(angle)))
            local fire = Isaac.Spawn(1000, 7005, 0, npc.Position, vel, npc):ToEffect()
            fire:GetData().timer = 5
            fire:Update()
		end
		npc.Velocity = npc.Velocity * 0.1
	elseif data.state == "rageend" then
		if sprite:IsFinished("RevertToNormal") then
			sprite:Load("gfx/bosses/basco/basco.anm2", true)
			sprite:Play("Idle")
			npc.SplatColor = Color.Default
			data.state = "idle"
			npc.StateFrame = 30
		elseif sprite:IsEventTriggered("Land") then
			mod:PlaySound(SoundEffect.SOUND_CANDLE_LIGHT, npc)
		elseif sprite:IsEventTriggered("Shoot") then
			mod:PlaySound(SoundEffect.SOUND_CANDLE_LIGHT, npc)
			mod:PlaySound(mod.Sounds.SizzleExtinguish, npc)
		elseif sprite:IsEventTriggered("SlowDown") then
			data.enraged = false
			data.smokin = false
		else
			mod:spritePlay(sprite, "RevertToNormal")
		end
		if data.flamin and npc.StateFrame % 2 == 0 then --Stolen from Phoenix
			local dir = mod:RandomInt(0, 3)
            local angle = 0

            if dir == 0 then
                angle = mod:RandomInt(35, 55)
            elseif dir == 1 then
                angle = mod:RandomInt(125, 145)
            elseif dir == 2 then
                angle = mod:RandomInt(215, 235)
            else
                angle = mod:RandomInt(305, 325)
            end
            local vel = Vector(mod:RandomInt(7,8) * math.sin(math.rad(angle)), mod:RandomInt(7,8) * math.cos(math.rad(angle)))
            local fire = Isaac.Spawn(1000, 7005, 0, npc.Position, vel, npc):ToEffect()
            fire:GetData().timer = 5
            fire:Update()
		end
		npc.Velocity = npc.Velocity * 0.1
	elseif data.state == "spicyPatooie" then
		if sprite:IsFinished("Spit") then
			npc.StateFrame = 0
			data.targetfruit = nil
			data.state = "idle"
		elseif sprite:IsEventTriggered("Summon") then
			mod:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, npc, 0.8, 0.8)
		elseif sprite:IsEventTriggered("Shoot") then
			local params = ProjectileParams()
			params.Scale = 3
			params.FallingAccelModifier = -0.08
			params.Color = mod.ColorCrackleOrange
			params.BulletFlags = ProjectileFlags.EXPLODE
			local anglevariation = 15 * (data.patooies - 1)
			mod:SetGatheredProjectiles()
			for i = 1, data.patooies do
				local vec = (targetpos - npc.Position):Resized(20):Rotated(mod:RandomInt(-anglevariation,anglevariation))
				npc:FireProjectiles(npc.Position, vec, 0, params)
			end
			for _, proj in pairs(mod:GetGatheredProjectiles()) do
				proj:GetData().projType = "Basco"
				proj:GetData().bascoSpecial = "SUPERFIREBALL"
			end
			data.patooies = 0
			local effect = Isaac.Spawn(1000,16,5,npc.Position + Vector(0,-20),Vector.Zero,npc)
			effect.SpriteScale = Vector(0.5,0.5)
			effect.Color = npc.SplatColor
			mod:PlaySound(SoundEffect.SOUND_BEAST_LAVABALL_RISE, npc, 1, 2)
		else
			mod:spritePlay(sprite, "Spit")
		end
		npc.Velocity = npc.Velocity * 0.1
	end

	if npc.FrameCount % 3 == 1 then
		local blood = Isaac.Spawn(1000, 7, 0, npc.Position, Vector.Zero, npc)
		blood.SpriteScale = Vector(2,2)
		if data.enraged then
			blood.Color = Color(0,0,0,1,0.8,0.2,0)
		end
		blood:Update()
	end

	if data.smokin and npc.FrameCount % 3 == 0 then
		local smoke = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, npc.Position + Vector(0,-10), Vector(0,mod:RandomInt(4,7)):Rotated(-35 + mod:RandomInt(0,70) + 180), npc):ToEffect()
		smoke:GetData().longonly = true
		smoke.SpriteRotation = mod:RandomInt(360)
		smoke.Color = Color(0.8,0.8,0.8,0.6)
		smoke.SpriteOffset = Vector(0,3)
		smoke.RenderZOffset = 300
		smoke:Update()
	end

	if data.creeping > 0 then
		if npc.FrameCount % 5 == 0 then
			local creep = Isaac.Spawn(1000, EffectVariant.CREEP_RED, 0, npc.Position, Vector.Zero, npc):ToEffect()
			if data.enraged then
				creep.Color = mod.ColorGreyscaleLight
        		creep:SetColor(mod.ColorFireJuicy, 45, 0, true, false)
			else
				creep.Color = Color(1,1,1,1,0.1,0.1,0.1)
			end
			creep.SpriteScale = Vector(2, 2)
			creep:SetTimeout(30)
			creep:Update()
		end
		data.creeping = data.creeping - 1
	end
end

function mod:BascoProjectile(projectile, data)
	local special = data.bascoSpecial
	if special == "haemo" then
		if projectile.FrameCount % 5 == 0 then
			local trail = Isaac.Spawn(1000, 111, 0, projectile.Position, Vector(0,0), projectile):ToEffect()
			trail:GetSprite().Offset = Vector(0, projectile.Height * 0.75)
			trail.SpriteScale = Vector(0.5,0.5)
		end
	elseif special == "spicyhaemo" then
		if projectile.FrameCount % 5 == 0 then
			local trail = Isaac.Spawn(1000, 111, 0, projectile.Position, Vector(0,0), projectile):ToEffect()
			trail:GetSprite().Offset = Vector(0, projectile.Height * 0.75)
			trail.SpriteScale = Vector(0.5,0.5)
			trail.Color = mod.ColorFireJuicy
		end
		if projectile.FrameCount % 3 == 0 then
			local spark = Isaac.Spawn(1000, 66, 0, projectile.Position + RandomVector()*5, projectile.Velocity / 4, projectile):ToEffect()
			spark.PositionOffset = Vector(0, projectile.Height)
		end
	elseif special == "fireball" or special == "SUPERFIREBALL" then
		if projectile.FrameCount % 3 == 0 then
			local spark = Isaac.Spawn(1000, 66, 0, projectile.Position + RandomVector()*5, projectile.Velocity / 4, projectile):ToEffect()
			spark.PositionOffset = Vector(0, projectile.Height)
		end
	end
end

function mod:BascoProjectileDeath(projectile, data)
	local special = data.bascoSpecial
	if special == "haemo" or special == "spicyhaemo" then
		if special == "haemo" then
			local creep = Isaac.Spawn(1000, 22, 0, projectile.Position, Vector.Zero, projectile):ToEffect()
			creep:SetTimeout(300)
			creep.SpriteScale = Vector(2 * data.mult, 2 * data.mult)
			creep:Update()
			creep.Color = Color(1,1,1,1,0.1,0.1,0.1)
		end
		local vec = RandomVector():Resized(8)
		local shots = math.floor(6 * data.mult)
		for i = 1, shots do
			local proj = Isaac.Spawn(9,0,0,projectile.Position, vec:Rotated((360/shots)*i), projectile)
			if special == "spicyhaemo" then
				proj.Color = mod.ColorCrackleOrange
			end
		end
		if special == "spicyhaemo" then
			game:BombExplosionEffects(projectile.Position, 10, 0, projectile.Color, projectile, 0.5 * data.mult, false, true)
			for i = 1.5, shots + 0.5 do
				local fire = Isaac.Spawn(1000,7005, 0, projectile.Position, vec:Resized(12):Rotated((360/shots)*i), npc):ToEffect()
				fire:GetData().timer = 150
				fire:GetData().Friction = 0.9
				fire.SpriteScale = Vector(0.8,0.8)
				fire:Update()
			end
		end
		sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS, 1, 0, false, 1.5)
	elseif special == "fireball" then
		Isaac.Spawn(1000,147,0,projectile.Position,Vector.Zero,projectile)
	elseif special == "SUPERFIREBALL" then
		local room = game:GetRoom()
		local flametarget = projectile.Position
		local iterlimit = 0
		while (iterlimit < 10 and not room:IsPositionInRoom(flametarget, 0)) do
			flametarget = flametarget - projectile.Velocity:Resized(10)
			iterlimit = iterlimit + 1
		end
		for i = -35, 35, 35 do
			local wave = Isaac.Spawn(1000, 148, 0, flametarget, Vector.Zero, projectile):ToEffect()
			wave.Rotation = projectile.Velocity:GetAngleDegrees() + i + 180
		end
	end
end

function mod:bascoHurt(npc, amount, damageFlags, source)
	local data = npc:GetData()
	if (data.state == "ragebegin" or data.state == "rageend") and not mod:HasDamageFlag(DamageFlag.DAMAGE_CLONES, damageFlags) then
		npc:TakeDamage(amount * 0.2, damageFlags | DamageFlag.DAMAGE_CLONES, source, 0)
		return false
	elseif mod:HasDamageFlag(DamageFlag.DAMAGE_POOP, damageFlags) then
        return false
	elseif mod:HasDamageFlag(DamageFlag.DAMAGE_FIRE, damageFlags) or mod:HasDamageFlag(DamageFlag.DAMAGE_EXPLOSION, damageFlags) then
		return mod:IsPlayerDamage(source)
    end
end

function mod:bascoCollision(npc, collider)
	local data = npc:GetData()
	if data.state == "roll" and data.rollstate == 1 then
		if collider.Type == mod.FF.BascoFood.ID and collider.Variant == mod.FF.BascoFood.Var then
			if collider:GetData().IsSpicy then
				if data.enraged then
					data.ragetimer = data.ragetimer + 450
					data.patooies = data.patooies + 1
				else
					data.spiced = data.spiced + 450
				end
				npc.StateFrame = 900 --Stop rolling!!!
			else
				data.creeping = data.creeping + math.floor(200 * GetFruitMulti(collider))
				npc.StateFrame = npc.StateFrame - math.floor(60 * GetFruitMulti(collider))
				mod:DoBascoHeal(npc, collider, 25)
			end
			collider:Kill()
		elseif collider.Type == mod.FF.SpicyDip.ID and collider.Variant == mod.FF.SpicyDip.Var then
			collider:Kill()
		end
	end
end

function mod:DoBascoHeal(npc, food, amount)
	local heal = (amount * GetFruitHealMulti(food)) 
	if npc.HitPoints < npc.MaxHitPoints and heal > 0 then
		mod:PlaySound(SoundEffect.SOUND_VAMP_GULP, npc, 1)
		local poof = Isaac.Spawn(1000, 49, 0, npc.Position, Vector.Zero, npc):ToEffect()
		poof.SpriteOffset = Vector(0,-50)
		poof:FollowParent(npc)
		poof:Update()
	end
	if food:GetData().expired then
		npc:AddPoison(EntityRef(food), 150, 3.5)
	end
	npc.HitPoints = math.min(npc.HitPoints + heal, npc.MaxHitPoints)
	mod:PlaySound(SoundEffect.SOUND_SMB_LARGE_CHEWS_4, npc, 0.8)
end

function mod:GetHealthPercent(npc, onlyTopHalf)
	local hp = npc.HitPoints
	local maxhp = npc.MaxHitPoints
	if onlyTopHalf then
		maxhp = maxhp - (maxhp * 0.5)
		hp = math.max(0, -(maxhp - hp))
	end
	return hp / maxhp
end

function mod:SumTable(table)
	local sum = 0
	for _, num in pairs(table) do
		sum = sum + num
	end
	return sum
end

function mod:ChooseNextBascoAttack(npc, data)
	local debugoverride = nil
    local bascomoves = {}
    if data.attacksincefruits > 2 then
        for i = 1, data.attacksincefruits - 2 do
            table.insert(bascomoves, "stomp")
        end
	elseif data.attacksincefruits > 4 then
		return "stomp"
    end
    if mod.GetEntityCount(mod.FF.SpicyDip.ID, mod.FF.SpicyDip.Var) <= 0 then
        table.insert(bascomoves, "summon")
    end
	if mod.GetEntityCount(mod.FF.BascoFood.ID, mod.FF.BascoFood.Var) > 0 or data.creeping > 75 then
		table.insert(bascomoves, "roll")
	elseif not data.justrolled then
		table.insert(bascomoves, "roll")
	end
	local choice = debugoverride or mod:GetRandomElem(bascomoves) or "stomp"
	if choice == "roll" then
		data.justrolled = true
	else
		data.justrolled = false
	end
	return choice
end

function mod:bascoFruitAI(npc, sprite, data)
	if not data.Init then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		if npc.SubType == 0 then
			npc.SubType = mod:RandomInt(1,3)
		elseif npc.Subtype == 10 then
			npc.SubType = mod:RandomInt(11,13)
		end
		if npc.SubType >= 10 then
			data.IsSpicy = true
			npc.SplatColor = mod.ColorFireJuicy
			npc.CollisionDamage = 1
		end
		npc.StateFrame = mod:RandomInt(0,15)
		data.state = "waiting"
		npc.Visible = false
		data.Init = true
	end
	if data.state == "waiting" then
		npc.StateFrame = npc.StateFrame - 1
		if npc.StateFrame <= 0 then
			npc.Visible = true
			Isaac.Spawn(1000,146,0,npc.Position,Vector.Zero,npc)
			for i = 1, mod:RandomInt(1,2) do
				local rubble = Isaac.Spawn(1000, 4, 0, npc.Position, RandomVector()*(mod:RandomInt(1,3)), npc)
				rubble:Update()
			end
			sfx:Play(mod.Sounds.GravediggerDig, 0.5, 0, false, mod:RandomInt(14,16)/10)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			data.state = "appear"
		end
	elseif data.state == "appear" then
		if sprite:IsFinished("Appear"..npc.SubType) then
			data.state = "idle"
		else
			mod:spritePlay(sprite, "Appear"..npc.SubType)
		end
	elseif data.state == "idle" then
		mod:spritePlay(sprite, "Idle"..npc.SubType)
		if game:GetRoom():IsClear() then
			npc:Kill()
		end
	end
	npc.Velocity = npc.Velocity * 0.8
	local saturation = GetFruitMulti(npc)
	npc.Color = Color(saturation, math.min(1, saturation + 0.3), saturation)
	if npc.HitPoints < npc.MaxHitPoints / 2 and not data.expired then
		local effect = Isaac.Spawn(1000,34,0,npc.Position,Vector.Zero,npc)
		effect:GetSprite().Scale = Vector(0.8,0.8)
		sfx:Stop(SoundEffect.SOUND_FART)
		mod:PlaySound(SoundEffect.SOUND_FART, npc, 1.5, 0.8)
		data.expired = true
	end
end

function mod:bascoFruitHurt(npc, amount, damageFlags, source)
	local data = npc:GetData()
	if data.IsSpicy then
		return false
	elseif mod:HasDamageFlag(DamageFlag.DAMAGE_POOP, damageFlags) then
		return false
	else
		return mod:IgnoreFireDamage(npc, amount, damageFlags, source)
    end
end

function mod:FlyingSpicyDipRender(effect, sprite, data, isPaused, isReflected)
    if not (isPaused or isReflected) then
        data.StateFrame = data.StateFrame or 2
        mod:spritePlay(sprite, "Roll")
        mod:FlipSprite(sprite, effect.Position, effect.Position + effect.Velocity)
        local curve = math.sin(math.rad(9 * data.StateFrame))
        local height = 0 - curve * 40
        sprite.Offset = Vector(0, height)
        if height >= 0 then
            effect.Visible = false
            effect:Remove()
            local dip = Isaac.Spawn(mod.FF.SpicyDip.ID,mod.FF.SpicyDip.Var,0,effect.Position,effect.Velocity,effect)
            dip:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			if data.extraspicy then
				dip:GetSprite():ReplaceSpritesheet(0, "gfx/enemies/berry/spicydip_extraspicy.png")
				dip:GetSprite():LoadGraphics()
				dip:GetData().extraspicy = true
			end
        else
            data.StateFrame = data.StateFrame + 0.5
        end
    end
end

function mod:GetTearProjScale(projectile, prefix)
	local scale = projectile.Scale
	local anim
	if scale <= 0.3 then
		anim = prefix .. "1"
	elseif scale <= 0.55 then
		anim = prefix .. "2"
	elseif scale <= 0.675 then
		anim = prefix .. "3"
	elseif scale <= 0.8 then
		anim = prefix .. "4"
	elseif scale <= 0.925 then
		anim = prefix .. "5"
	elseif scale <= 1.05 then
		anim = prefix .. "6"
	elseif scale <= 1.175 then
		anim = prefix .. "7"
	elseif scale <= 1.425 then
		anim = prefix .. "8"
	elseif scale <= 1.675 then
		anim = prefix .. "9"
	elseif scale <= 1.925 then
		anim = prefix .. "10"
	elseif scale <= 2.175 then
		anim = prefix .. "11"
	elseif scale <= 2.55 then
		anim = prefix .. "12"
	else
		anim = prefix .. "13"
	end
	return anim
end
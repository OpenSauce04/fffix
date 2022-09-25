local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:theHorseAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder

	if not d.init then
		npc.SpriteOffset = Vector(0,-5)
		d.state = "idle"
		d.init = true
		local champSheet
		if mod.IsDeliriumRoom then
			champSheet = "gfx/enemies/horse/horse_real_delirium.png"
		elseif (game:GetSeeds():HasSeedEffect(SeedEffect.SEED_CHRISTMAS)) or (REVEL and REVEL.STAGE and REVEL.STAGE.Glacier and REVEL.STAGE.Glacier:IsStage()) then
			champSheet = "gfx/enemies/horse/horse_real_glacier.png"
        end
		if champSheet then
               sprite:ReplaceSpritesheet(0, champSheet)
            sprite:LoadGraphics()
        end
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		if npc.StateFrame > 160 or not d.walktarg then
			d.walktarg = mod:FindRandomValidPathPosition(npc)
			npc.StateFrame = 0
		end
		if npc.Position:Distance(d.walktarg) > 30 then
			if game:GetRoom():CheckLine(npc.Position,d.walktarg,0,1,false,false) or mod:isScare(npc) then
				local targetvel = mod:runIfFear(npc, (d.walktarg - npc.Position):Resized(2))
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.2)
			else
				path:FindGridPath(d.walktarg, 0.25, 900, true)
			end
		else
			npc.Velocity = npc.Velocity * 0.8
			npc.StateFrame = npc.StateFrame + 2
		end
	end
	if npc.Velocity:Length() > 0.5 then
		mod:spritePlay(sprite, "Walk")
		 mod:flipX(npc, npc.Velocity)
	else
		mod:spritePlay(sprite, "Idle")
	end

	if npc:IsDead() and d.glueFactory then
		for i = 60, 360, 60 do
			local creep = Isaac.Spawn(1000, 25, 0, npc.Position+Vector(25,0):Rotated(i), nilvector, npc):ToEffect()
			creep.SpriteScale = Vector(2, 2);
			creep:Update()
		end
	end

end

function mod:theHorseColl(npc1, npc2)
	if npc2.Type == 1 and npc2:ToPlayer():GetPlayerType() == mod.PLAYER.CHINA then
		npc1:GetData().glueFactory = true
		npc1:Kill()
		sfx:Play(SoundEffect.SOUND_VAMP_DOUBLE, 1, 0, false, 1)
		return true
	end
    if npc2.Type == 877 then
        npc1:GetData().glueFactory = true
    end
end

-------------------PORTED STABLE VERSION STUFF------------------------
local HorseVar = {
	Horse = 1005,
	Pony = 1006,
	Tainted = 1007,
}

local HorseSub = {
	Default = 0,
	Mines = 1,
	Chest = 2,
	Dark = 3,
	Cursed = 4,
	Holy = 5,
	Forgotten = 6,
	Sour = 7,
	Drowned = 8,
	Foetal = 9,
	Ashen = 10,
	Stitched = 11,
	Miner = 12,
	Spider = 13,
	Dank = 14,

	Secret = 100,
	Golden = 101,
	Missing = 102,
	False = 103,
	Minecraft = 104,
}

local HorseStageColors = {
	[LevelStage.STAGE1_1] = {
		[StageType.STAGETYPE_AFTERBIRTH] = Color(1,0.75,0.75,1,0.2,0,0), --Burning
		[StageType.STAGETYPE_REPENTANCE] = Color(0.75,0.75,1,1,0,0,0.5), --Downpour
		[StageType.STAGETYPE_REPENTANCE_B] = Color(0.75,1,0.75,1,0,0.2,0), --Dross
	},
	[LevelStage.STAGE2_1] = {
		--[StageType.STAGETYPE_AFTERBIRTH] = Color(0.75,0.75,1,1,0,0,0.5), --Flooded
	},
	[LevelStage.STAGE3_1] = {
		[StageType.STAGETYPE_AFTERBIRTH] = Color(0.5,0.5,0.5,1,0.05,0,0.05), --Dank
		[StageType.STAGETYPE_REPENTANCE_B] = Color(1,0.75,0.75,1,0.3,0,0), --Gehenna
	},
	[LevelStage.STAGE4_1] = {
		[StageType.STAGETYPE_REPENTANCE] = Color(0.5,1,0.2,1), --Corpse
	},
}

function mod:stableHorseAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder

	if not d.init then
		npc.SpriteOffset = Vector(0,-5)
		d.state = "idle"
		d.init = true
		local champSheet
		if mod.IsDeliriumRoom then
			champSheet = "gfx/enemies/horse/horse_real_delirium.png"
		elseif npc.SubType == HorseSub.Default and ((game:GetSeeds():HasSeedEffect(SeedEffect.SEED_CHRISTMAS)) or (REVEL and REVEL.STAGE and REVEL.STAGE.Glacier and REVEL.STAGE.Glacier:IsStage())) then
			champSheet = "gfx/enemies/horse/horse_real_glacier.png"
        end
		if champSheet then
               sprite:ReplaceSpritesheet(0, champSheet)
            sprite:LoadGraphics()
        end
		local level = game:GetLevel()
		local stageNum = level:GetAbsoluteStage()
		local stageType = level:GetStageType()
		if npc.SubType == HorseSub.Chest then
			if stageType == StageType.STAGETYPE_REPENTANCE and (stageNum == LevelStage.STAGE4_1 or stageNum == LevelStage.STAGE4_2) then
				npc.Color = Color(0.5,1,0.2,1)
			end
		elseif npc.SubType == 0 then
			for i = 0, 1 do
				if HorseStageColors[stageNum - i] then
					if HorseStageColors[stageNum - i][stageType] then
						npc.Color = HorseStageColors[stageNum - i][stageType]
						break
					end
				end
			end
		end
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL

	if npc.SubType == HorseSub.Holy or npc.SubType == HorseSub.Secret then
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
	end
	if npc.SubType == HorseSub.Dank or npc.Variant == HorseVar.Tainted then
		if npc.FrameCount % 5 == 1 then
			local creep = Isaac.Spawn(1000, 26, 0, npc.Position, nilvector, npc):ToEffect()
			if npc.Variant == HorseVar.Pony then
				creep.SpriteScale = creep.SpriteScale * 1
			else
				creep.SpriteScale = creep.SpriteScale * 2
			end
			creep:Update()
		end
	end

	if d.state == "idle" then
		if npc.StateFrame > 160 or not d.walktarg then
			if npc.SubType == HorseSub.Holy or npc.SubType == HorseSub.Secret then
				d.walktarg = game:GetRoom():GetRandomPosition(10)
			else
				d.walktarg = mod:FindRandomValidPathPosition(npc)
			end
			npc.StateFrame = 0
		end
		if npc.Position:Distance(d.walktarg) > 30 then
			if game:GetRoom():CheckLine(npc.Position,d.walktarg,0,1,false,false) or mod:isScare(npc) or npc.SubType == HorseSub.Holy or npc.SubType == HorseSub.Secret then
				local targetvel = mod:runIfFear(npc, (d.walktarg - npc.Position):Resized(2))
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.2)
			else
				path:FindGridPath(d.walktarg, 0.25, 900, true)
			end
		else
			npc.Velocity = npc.Velocity * 0.8
			npc.StateFrame = npc.StateFrame + 2
		end
		if npc.Velocity:Length() > 0.5 then
			mod:spritePlay(sprite, "Walk")
			 mod:flipX(npc, npc.Velocity)
		else
			mod:spritePlay(sprite, "Idle")
		end
		if (npc.SubType == HorseSub.Dark or npc.Variant == HorseVar.Tainted) and math.random(100) == 1 then
			d.state = "tele"
			sprite:Play("TeleUp", true)
			sfx:Play(SoundEffect.SOUND_HELL_PORTAL1, 0.6, 0, false, 0.8)
		elseif (npc.SubType == HorseSub.Cursed or npc.SubType == HorseSub.Foetal or npc.SubType == HorseSub.Ashen or npc.Variant == HorseVar.Tainted) and math.random(100) == 1 then
			d.state = "attack"
		elseif (npc.SubType == HorseSub.Spider or npc.Variant == HorseVar.Tainted) and math.random(500) == 1 then
			d.state = "attack"
		end
	elseif d.state == "tele" then
		if sprite:IsFinished("TeleUp") then
			sprite:Play("TeleDown")
			sfx:Play(SoundEffect.SOUND_HELL_PORTAL2, 0.3, 0, false, 0.8)
			if (npc.Variant == HorseVar.Horse or npc.Variant == HorseVar.Tainted) then
				Isaac.Spawn(1000,144,1,npc.Position,Vector.Zero,npc)
				sfx:Play(SoundEffect.SOUND_DEMON_HIT)
				local params = ProjectileParams()
				params.Color = Color(-1,-1,-1,1,1,0,0)
				params.Scale = 1.5
				params.FallingAccelModifier = -0.06
				params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
				npc:FireProjectiles(npc.Position, Vector(10,10), 9, params)
			end
			npc.Position = target.Position + RandomVector()*math.random(150,250)
		elseif sprite:IsFinished("TeleDown") then
			d.state = "idle"
		end
	elseif d.state == "attack" then
		if sprite:IsFinished("Attack") then
			d.state = "idle"
		elseif sprite:IsEventTriggered("Shoot") then
			if (npc.SubType == HorseSub.Cursed or npc.Variant == HorseVar.Tainted) then
				sfx:Play(SoundEffect.SOUND_BOSS1_EXPLOSIONS, 0.65, 0, false, math.random(230,250)/100);
				sfx:Play(SoundEffect.SOUND_HEARTIN, 1.5, 0, false, 1.5);
				local vec = RandomVector()
				local projSpeed = 3
				if (npc.Variant == HorseVar.Horse or npc.Variant == HorseVar.Tainted) then
					projSpeed = 7
				end
				for i = 60, 360, 60 do
					local projectile = Isaac.Spawn(9, 4, 0, npc.Position, vec:Rotated(i):Resized(projSpeed), npc):ToProjectile();
					projectile.Height = -10
					projectile.FallingSpeed = -10
					projectile.FallingAccel = 0.4
					projectile.HomingStrength = 0.5
					projectile.Color = Color(0.35,0.35,0.35,1,66 / 255,13 / 255,102 / 255)
					projectile:AddProjectileFlags(ProjectileFlags.SMART)
					projectile.SpawnerEntity = npc
					projectile:Update()
				end
				for i = 30, 360, 30 do
					local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position, Vector(math.random(40,70)/10,0):Rotated(i), npc):ToEffect()
					smoke.SpriteRotation = math.random(360)
					smoke.Color = Color(0.35,0.35,0.35,1,66 / 255,13 / 255,102 / 255)
					smoke.SpriteOffset = Vector(0, -10)
					smoke.RenderZOffset = 300
					smoke:Update()
				end
			end
			if (npc.SubType == HorseSub.Foetal or npc.Variant == HorseVar.Tainted) then
				local params = ProjectileParams()
				npc:PlaySound(SoundEffect.SOUND_MEATY_DEATHS,1,2,false,1)
				npc:FireBossProjectiles(10, target.Position, 10, params)
			end
			if (npc.SubType == HorseSub.Ashen or npc.Variant == HorseVar.Tainted) then
				local rotval = 30
				local dist = 120
				if npc.Variant == HorseVar.Pony then
					rotval = 60
					dist = 80
				end
				for i = rotval, 360, rotval do
					local fire = Isaac.Spawn(1000, 147, 0, npc.Position+Vector(dist, 0):Rotated(i), nilvector, npc):ToEffect()
					fire.SpawnerEntity = npc
					fire:Update()
				end
			end
			if (npc.SubType == HorseSub.Spider or npc.Variant == HorseVar.Tainted) then
				npc:PlaySound(SoundEffect.SOUND_MEATY_DEATHS,1,2,false,1)
				local numSpiders = 3
				if npc.Variant == HorseVar.Pony then
					numSpiders = 1
				end
				for i = 1, numSpiders do
					local spider = EntityNPC.ThrowSpider(npc.Position, nil, npc.Position + Vector(math.random(-40,40), math.random(-40,40)), false, 0):ToNPC()
				end
			end
		else
			mod:spritePlay(sprite, "Attack")
		end
	end

	if npc:IsDead() then
		if d.glueFactory then
			for i = 60, 360, 60 do
				local creep = Isaac.Spawn(1000, 25, 0, npc.Position+Vector(25,0):Rotated(i), nilvector, npc):ToEffect()
				creep.SpriteScale = Vector(2, 2);
				creep:Update()
			end
		end
		if (npc.SubType == HorseSub.Mines or npc.Variant == HorseVar.Tainted) then
			sfx:Play(SoundEffect.SOUND_FLAME_BURST, 1, 0, false, math.random(90,110)/100)
			sfx:Play(SoundEffect.SOUND_FLAMETHROWER_END, 1, 0, false, math.random(90,110)/100)
			if (npc.Variant == HorseVar.Horse or npc.Variant == HorseVar.Tainted) then
				for i = 90, 360, 90 do
					local wave = Isaac.Spawn(1000, 148, 0, npc.Position, nilvector, npc):ToEffect()
					wave.Rotation = i
					wave.SpawnerEntity = npc
					wave:Update()
				end
			else
				local wave = Isaac.Spawn(1000, 148, 0, npc.Position, nilvector, npc):ToEffect()
				wave.Rotation = (target.Position - npc.Position):GetAngleDegrees()
				wave.SpawnerEntity = npc
				wave:Update()
			end
		end
		if (npc.SubType == HorseSub.Chest or npc.Variant == HorseVar.Tainted) then
			for i = 1, 5 + math.random(5) do
				mod.ThrowMaggot(npc.Position, RandomVector()*math.random(10), -5, -10 -math.random(10), npc)
			end
		end
		if (npc.SubType == HorseSub.Holy or npc.Variant == HorseVar.Tainted) then
			local crack = Isaac.Spawn(1000, 19, 0, target.Position + RandomVector():Resized(math.random(50,100)), nilvector, npc):ToEffect()
			crack.SpawnerEntity = npc
			crack:Update()
		end
		if (npc.SubType == HorseSub.Forgotten or npc.Variant == HorseVar.Tainted) then
			local projectileParams = ProjectileParams()
			projectileParams.Variant = 1
			local projSpeed = 9
			local rotVal = 30
			if npc.Variant == 1006 then
				projSpeed = 5
				rotVal = 60
			end
			for i = rotVal, 360, rotVal do
				npc:FireProjectiles(npc.Position, Vector(projSpeed,0):Rotated(i), 0, projectileParams)
			end
		end
		if (npc.SubType == HorseSub.Sour or npc.Variant == HorseVar.Tainted) then
			if npc.Variant ~= HorseVar.Pony then
				local params = ProjectileParams()
				local LemonYellow = Color(1,1,1,1,0.235,0.235,0)
				LemonYellow:SetColorize(3,2,1,1)
				params.Color = LemonYellow
				for i = 45, 360, 45 do
					npc:FireProjectiles(npc.Position, Vector(0,10):Rotated(i), 0, params)
				end
			end
			local creep = Isaac.Spawn(1000, 24, 0, npc.Position, nilvector, npc):ToEffect()
			if npc.Variant == HorseVar.Pony then
				creep.SpriteScale = creep.SpriteScale * 1.5
			else
				creep.SpriteScale = creep.SpriteScale * 2.5
			end
			creep:Update()
		end
		if (npc.SubType == HorseSub.Miner or npc.Variant == HorseVar.Tainted) then
			npc:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND,0.6,2,false,1.7)
			local rad = 100
			if npc.Variant == HorseVar.Pony then
				rad = 50
			end
			local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, npc.Position, nilvector, g):ToEffect()
			wave.Parent = npc
			wave.MaxRadius = rad
		end
		if (npc.SubType == HorseSub.Drowned or npc.Variant == HorseVar.Tainted) then
			if npc.Variant ~= HorseVar.Pony then
				local maggot = Isaac.Spawn(23, 1, 0, npc.Position, Vector(0,0), npc)
			end
			local params = ProjectileParams()
			for i = 45, 405, 90 do
				npc:FireProjectiles(npc.Position, Vector(8,0):Rotated(i), 0, params)
			end
		end
		if (npc.SubType == HorseSub.Stitched or npc.Variant == HorseVar.Stitched) then
			for i = 1, math.random(2,3) do
				local chunk = Isaac.Spawn(310, 1, 0, npc.Position, RandomVector():Resized(math.random(3,6)), npc)
				chunk:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				chunk:Update()
			end
		end
		if npc.SubType == HorseSub.Golden then
			game:ShakeScreen(20)
			sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY ,1.5,0,false,1)
			game:GetRoom():TurnGold()
			for i = 1, 20 do
			Isaac.Spawn(5, 20, 0, npc.Position, RandomVector()*math.random(10,30), npc)
			end
			for _, entity in ipairs(Isaac.GetRoomEntities()) do
				if entity.Type == EntityType.ENTITY_PROJECTILE
				and entity.Variant == 0
				and	entity.SpawnerType == npc.Type
				and	entity.SpawnerVariant == npc.Variant
				and entity.FrameCount < 2 then
					entity:Remove()
				end
				if entity:IsEnemy() then
					entity:AddMidasFreeze(EntityRef(npc), 1200)
				end
			end
		end
		if npc.SubType == HorseSub.False then
			for i = 1, 2 do
				Isaac.Spawn(10, math.random(2) - 1, 0, npc.Position + RandomVector(), nilvector, npc)
			end
		end
		if npc.SubType == HorseSub.Minecraft then
			local rock = Isaac.GridSpawn(GridEntityType.GRID_ROCK, 0, npc.Position, true)
		end
	end
end

function mod:stableHorseColl(npc1, npc2)
	if npc2.Type == 1 and npc2:ToPlayer():GetPlayerType() == mod.PLAYER.CHINA then
		npc1:GetData().glueFactory = true
		npc1:Kill()
		sfx:Play(SoundEffect.SOUND_VAMP_DOUBLE, 1, 0, false, 1)
		return true
	end
	if npc2.Type == 877 then
		npc1:GetData().glueFactory = true
	end
	if npc2.Type == 1 and npc1.SubType == HorseSub.Missing then
		npc2:ToPlayer():ChangePlayerType(math.random(41) - 1)
	end
end

local horseVars = {
	[mod.FF.StableHorse.Var] = true,
	[mod.FF.StablePony.Var] = true,
	[mod.FF.StableTainted.Var] = true,
}

local HorseStageSubs = {
	[LevelStage.STAGE1_1] = {
		[StageType.STAGETYPE_WOTL] = HorseSub.Spider,
	},
	[LevelStage.STAGE2_1] = {
		[StageType.STAGETYPE_ORIGINAL] = HorseSub.Miner,
		[StageType.STAGETYPE_WOTL] = HorseSub.Sour,
		[StageType.STAGETYPE_AFTERBIRTH] = HorseSub.Drowned,
		[StageType.STAGETYPE_REPENTANCE] = HorseSub.Mines,
		[StageType.STAGETYPE_REPENTANCE_B] = HorseSub.Ashen,
	},
	[LevelStage.STAGE3_1] = {
		[StageType.STAGETYPE_ORIGINAL] = HorseSub.Forgotten,
		[StageType.STAGETYPE_WOTL] = HorseSub.Forgotten,
		[StageType.STAGETYPE_AFTERBIRTH] = HorseSub.Dank,
		[StageType.STAGETYPE_REPENTANCE] = HorseSub.Cursed,
	},
	[LevelStage.STAGE4_1] = {
		[StageType.STAGETYPE_ORIGINAL] = HorseSub.Foetal,
		[StageType.STAGETYPE_WOTL] = HorseSub.Foetal,
		[StageType.STAGETYPE_AFTERBIRTH] = HorseSub.Stitched,
		[StageType.STAGETYPE_REPENTANCE] = HorseSub.Chest,
	},
	[LevelStage.STAGE5] = {
		[StageType.STAGETYPE_ORIGINAL] = HorseSub.Cursed,
		[StageType.STAGETYPE_WOTL] = HorseSub.Holy,
	},
	[LevelStage.STAGE6] = {
		[StageType.STAGETYPE_ORIGINAL] = HorseSub.Dark,
		[StageType.STAGETYPE_WOTL] = HorseSub.Chest,
	},
}

function mod:enemyReplceHorse(npc)
	if mod.ModeEnabled == 3 then
		if not (npc.Type == 160 and horseVars[npc.Variant]) and math.random(5) == 1 then
			local level = game:GetLevel()
			local stageNum = level:GetAbsoluteStage()
			local stageType = level:GetStageType()
			local sub = 0
			if math.random(2) == 1 then
				for i = 0, 1 do
					if HorseStageSubs[stageNum - i] then
						if HorseStageSubs[stageNum - i][stageType] then
							sub = HorseStageSubs[stageNum - i][stageType]
							break
						end
					end
				end
			end

			if npc:IsBoss() or math.random(3) == 1 then
				--can become crazy ones
				if math.random(100) == 1 then
					sub = 100 + math.random(4)
				end
				npc:Morph(160, 1005, sub, -1)
				
			else
				npc:Morph(160, 1006, sub, -1)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.enemyReplceHorse)

function mod:horseRoomInit(id, variant, subtype, gridindex, seed, stageAPIFirstLoad)
	if mod.ModeEnabled == 3 then
		if id == 160 and variant == 1005 then
			local rng = RNG()
			rng:SetSeed(seed, 0)
			local horsem = 100
			if rng:RandomInt(horsem) == 0 then
				--1/100 chance of becoming golden horse :)
				return {160, 1005, 101}
			end
		--Shopkeepers become secret horses
		elseif id == 17 then
			local rng = RNG()
			rng:SetSeed(seed, 0)
			local horsem = 5
			if rng:RandomInt(horsem) == 0 then
				--20% chance of becoming secret horse :)
				return {160, 1005, 100}
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, mod.horseRoomInit)	
local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

if not _G["c" .. "a" .. "n" .. "t" .. "h" .. "r" .. "o" .. "w" .. "b" .. "a" .. "l" .. "l"] then --Slightly obfuscated
    --makes this important global a loadbearing variable
    FiendFolio = false
end

--Run Widow AI
function mod:checkWidow(npc)
	local subt = npc.SubType
	if subt == mod.FF.BabyWidowChampion.Sub then
		mod:widowFFChampionAI(npc)
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.checkWidow, 100)

--Champion bosses, get em out the way first
function mod:widowFFChampionAI(npc)
	local d = npc:GetData()
	local sprite = npc:GetSprite()
	if not d.init then
		--[[npc.MaxHitPoints = npc.MaxHitPoints * 0.8
		npc.HitPoints = npc.MaxHitPoints
		npc.Scale = 0.8
		sprite:ReplaceSpritesheet(0, "gfx/bosses/champions/boss_widow_albino.png")
		sprite:ReplaceSpritesheet(1, "gfx/bosses/champions/boss_widow_albino.png")
		sprite:LoadGraphics()]]
		--npc.Color = mod.ColorSoy
		d.init = true
	end
	if npc.State == 4 then
		if math.random(3) == 1 and not d.justpooted then
			local rand = math.random(3)
			if rand == 1 then
				npc.State = 9
			else
				npc.State = 8
			end

			d.justpooted = true
        else
            npc.State = 10
            npc.StateFrame = 0
		end
	elseif npc.State == 8 then
		if npc.StateFrame > 19 and npc.StateFrame < 31 then
			if npc.StateFrame % 2 == 0 then
				mod.spawnent(npc, npc.Position, RandomVector()*math.random(20), 85, 962)
			end
		end
    elseif npc.State == 10 then
        npc.StateFrame = npc.StateFrame + 1
        local waitTimer = 5 + (mod.GetEntityCount(mod.FF.Spooter.ID, mod.FF.Spooter.Var) * 5) + (mod.GetEntityCount(mod.FF.StickySack.ID, mod.FF.StickySack.Var) * 5)
        if npc.StateFrame >= waitTimer then
            npc.State = 4
        end
        mod:spritePlay(sprite, "Idle")
	end
    if npc.State ~= (8 or 9) then
		d.justpooted = false
    end
end

function mod:checkLarry(npc)
	local var = npc.Variant
	local subt = npc.SubType
	--Isaac.ConsoleOutput(npc.StateFrame .. "\n")
	if var == mod.FF.LarryGhost.Var then
		if subt == mod.FF.LarryGhost.Sub then
			mod:hauntedLarryChampionAI(npc)
		end
	elseif var == mod.FF.HollowFuckedUpAndEvil.Var then
		if subt == mod.FF.HollowFuckedUpAndEvil.Sub then
			mod:fuckedUpAndEvilHollowChampionAI(npc)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.checkLarry, 19)

--Haunted Larry
function mod:hauntedLarryChampionAI(npc)
    local d = npc:GetData()
    local sprite = npc:GetSprite()
    if not d.init then
        --sprite:ReplaceSpritesheet(0, "gfx/bosses/champions/boss_larryjr_ghost.png")
        --sprite:LoadGraphics()
        d.init = true
    end
    if npc:IsDead() then
        mod.ghostLarriesKilled = mod.ghostLarriesKilled or 0
        mod.ghostLarriesKilled = mod.ghostLarriesKilled + 1
        if math.random(3) == 1 or mod.ghostLarriesKilled % 3 == 1 then
            Isaac.Spawn(mod.FF.Yawner.ID, mod.FF.Yawner.Var, 0, npc.Position, nilvector, npc)
        end
    end
    if not npc.Child and npc.FrameCount % 15 == 1 then
        local params = ProjectileParams()
        params.BulletFlags = params.BulletFlags | ProjectileFlags.GHOST
        params.FallingAccelModifier = 0.13
        params.FallingSpeedModifier = 0
        params.Variant = 4
        npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1)
        npc:FireProjectiles(npc.Position, nilvector, 0, params)

    end
    --[[if npc.V1.X < 1 or npc.V1.X > 20 then
        npc.V1 = Vector(30,0)
    end]]
end

--Evil Hollow
function mod:fuckedUpAndEvilHollowChampionAI(npc)
    local d = npc:GetData()
    local sprite = npc:GetSprite()
    if not d.init then
        --[[sprite:ReplaceSpritesheet(0, "gfx/bosses/champions/boss_thehollow_black.png")
        sprite:LoadGraphics()
        d.init = true
        npc.MaxHitPoints = npc.MaxHitPoints * 0.85
        npc.HitPoints = npc.MaxHitPoints]]
    end
    if npc:IsDead() then
        mod.ghostLarriesKilled = mod.ghostLarriesKilled or 0
        mod.ghostLarriesKilled = mod.ghostLarriesKilled + 1
        if math.random(3) == 1 then
            if mod.GetEntityCount(mod.FF.PossessedCorpse.ID, mod.FF.PossessedCorpse.Var) + mod.GetEntityCount(mod.FF.Possessed.ID, mod.FF.Possessed.Var) >= 2 then
                Isaac.Spawn(mod.FF.Moaner.ID, mod.FF.Moaner.Var, 0, npc.Position, nilvector, npc)
            else
                Isaac.Spawn(mod.FF.PossessedCorpse.ID, mod.FF.PossessedCorpse.Var, 0, npc.Position, nilvector, npc)
            end
        elseif mod.ghostLarriesKilled % 3 == 1 then
            Isaac.Spawn(mod.FF.Moaner.ID, mod.FF.Moaner.Var, 0, npc.Position, nilvector, npc)
        end
    end
    if npc.V1.X >= 30 then
        --[[local spoop = Isaac.Spawn(mod.FF.Spoop.ID, mod.FF.Spoop.Var, 3, npc.Position, nilvector, npc)
        spoop:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        spoop.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        spoop.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS]]
        local params = ProjectileParams()
        params.BulletFlags = params.BulletFlags | ProjectileFlags.GHOST | ProjectileFlags.SMART
        params.FallingAccelModifier = -0.05
        params.FallingSpeedModifier = 0
        npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1)
        npc:FireProjectiles(npc.Position, nilvector, 0, params)
    end
end

--Wine husk
function mod:checkDuke(npc)
	local var = npc.Variant
	local subt = npc.SubType
	if var == mod.FF.WineHusk.Var then
        --[[if subt == 0 then
            npc.SubType = mod.FF.WineHusk.Sub
            subt = npc.SubType
        end]]
		if subt == mod.FF.WineHusk.Sub then
			mod:wineHusk(npc)
		end
    end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.checkDuke, 67)

function mod:wineHusk(npc)
    local d = npc:GetData()
    local sprite = npc:GetSprite()
    local target = npc:GetPlayerTarget()
    if not d.init then
        --sprite:ReplaceSpritesheet(0, "gfx/bosses/champions/boss_thehusk_grape.png")
        --sprite:ReplaceSpritesheet(3, "gfx/bosses/champions/boss_thehusk_grape.png")
        --sprite:ReplaceSpritesheet(2, "gfx/bosses/champions/boss_thehusk_grape.png")
        --sprite:Load("gfx/bosses/champions/winehusk.anm2",true)
        d.init = true
        --npc.Scale = npc.Scale * 0.75
    end
    --print(npc.State, npc.StateFrame)
    if sprite:IsPlaying("Attack01") then
        if npc.StateFrame == 20 then
            npc.StateFrame = 21
        end
        if npc.StateFrame == 1 and mod.GetEntityCount(mod.FF.Grape.ID, mod.FF.Grape.Var, mod.FF.Grape.Sub) >= 4 then
            if math.random(2) == 1 then
                npc.State = 14
                mod:spritePlay(sprite, "Attack02")
            else
                npc.State = 8
                mod:spritePlay(sprite, "Attack03")
            end
        end
        if sprite:IsEventTriggered("Shoot") then
            npc:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_2, 1, 0, false, 1)
            for i = -90, 90, 180 do
                local sploshe = Isaac.Spawn(1000,7000,0,npc.Position,nilvector,npc):ToEffect()
                local sSprite = sploshe:GetSprite()
                sSprite:Load("gfx/1000.001_bomb explosion.anm2", true)
                sploshe:FollowParent(npc)
                sploshe.SpriteRotation = i
                sploshe.SpriteScale = Vector.One * npc.Scale
                sploshe.SpriteOffset = Vector(0, -20)
                sploshe.Color = Color(0.1,0.1,0.1,0.5,0.15,0,0.15)
                sploshe.DepthOffset = 10
                sSprite:Play("Explosion", true)
                sploshe:Update()
            end
            local grape = Isaac.Spawn(mod.FF.Grape.ID, mod.FF.Grape.Var, mod.FF.Grape.Sub, npc.Position + Vector(0,1), Vector(0,3), npc)
            grape:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            grape.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            grape:Update()
        end
    elseif sprite:IsPlaying("Attack02") then
        if npc.StateFrame == 18 then
            npc.StateFrame = 19
        end
        if sprite:IsEventTriggered("Shoot") then
            npc:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, 1, 0, false, 1)
            d.shooting = 0
            --Funky shoot
            for i = -1, 3 do
            local vec = (target.Position - npc.Position):Resized(6)
            local pos = npc.Position
            local proj = Isaac.Spawn(9, 0, 0, npc.Position, vec, npc):ToProjectile()
            proj.Color = mod.ColorKickDrumsAndRedWine
            proj.FallingSpeed = 0
            proj.FallingAccel = -0.1
            local projD = proj:GetData()
            projD.projType = "wineHuskFunny"
            projD.startpos = pos
            projD.targvel = vec
            projD.Timer = i * 2
            proj:Update()
            end
        end
    elseif sprite:IsPlaying("Attack03") then
        if npc.StateFrame == 17 then
            npc.StateFrame = 18
        end
        if sprite:IsEventTriggered("Shoot") then
            npc:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, 1, 0, false, 1)
            local params = ProjectileParams()
            if npc:GetDropRNG():RandomFloat() <= 0.5 then
				params.BulletFlags = params.BulletFlags | ProjectileFlags.CURVE_RIGHT
			else
				params.BulletFlags = params.BulletFlags | ProjectileFlags.CURVE_LEFT
			end
			params.CurvingStrength = 0.01
            params.FallingAccelModifier = -0.09
            params.Color = mod.ColorKickDrumsAndRedWine
            local vec = RandomVector():Resized(9)
            for i = 60, 360, 60 do
                npc:FireProjectiles(npc.Position, vec:Rotated(i), 0, params)
            end
        end
    end

    if npc:HasMortalDamage() then
        local grape = Isaac.Spawn(mod.FF.Bunch.ID, mod.FF.Bunch.Var, 0, npc.Position, nilvector, npc)
        npc:Die() --This prevents the default death spawns, if there's a better way feel free to change it
    end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, damage, flags, source, iframes)
    if ent.Variant == 1 and ent.SubType == mod.FF.WineHusk.Sub then
        if flags == flags | DamageFlag.DAMAGE_EXPLOSION then
            if source then
                if source.Type == mod.FF.Grape.ID and source.Variant == mod.FF.Grape.Var then
                    return false
                end
            end
        end
    end
end, 67)

function mod.wineDukeProj(v,d)
    if d.projType == "wineHuskFunny" then
        d.Timer = d.Timer or 0
        d.Timer = d.Timer + 1
        local targpos = d.startpos + d.targvel:Resized(d.Timer * 6)
        targpos = targpos + d.targvel:Rotated(90):Resized(math.sin(d.Timer / 5) * (30 + d.Timer/3))
        local targvec = targpos - v.Position
        v.Velocity = mod:Lerp(v.Velocity, targvec, 0.2)
    end
end

function mod:technopinFFChampion(v)
	local d = v:GetData()
	local s = v:GetSprite()
	local child = v.ChildNPC
	local state = v.State
	--[[if child and child.SubType ~= 2 then
		child:Morph(62,0,2,-1)
	end]]
	--[[if not d.loadedsprite then
		s:Load('gfx/bosses/champions/technopin.anm2', true)
		d.loadedsprite = true
	end]]
	if s:IsEventTriggered("Chargesound") then
		v:PlaySound(mod.Sounds.EpicTwinkle,2,0,false,1.8)
	end
	if s:IsEventTriggered("Prepare") then
		s:Play("Attack1",false)
		local vpos = v.Position + Vector(8,-67)
		local ppos = v:GetPlayerTarget().Position
		d.angle = (ppos - vpos):GetAngleDegrees()
		v.State = 7
	end
	if s:IsEventTriggered("Attack") then
		local laser = Isaac.Spawn(7,2,0,v.Position + Vector(8,-67),nilvector,v):ToLaser()
		laser.Angle = d.angle
		laser.DepthOffset = -500
		laser:SetTimeout(4)
		laser:Update()
	end
	if s:IsFinished("Attack1") then
		v.State = 4
	end
	if s:IsPlaying("Attack1") then
		v.Velocity = Vector.Zero
	end
	if not v.Parent then
		for _, proj in ipairs(Isaac.FindByType(9, 0, 0, false, false)) do
		    if proj.SpawnerEntity then
			    if proj.SpawnerEntity.Type == 62 and proj.SpawnerEntity.Variant == 0 and proj.SpawnerEntity.SubType == mod.FF.TechnoPin.Sub and not proj:GetData().affectedByPin then
				  proj:GetData().affectedByPin = true
			    end
		    end
		end
	end
end

function mod.technoPinAnnoyance(v,d)
	if d.affectedByPin then
		local laser = Isaac.Spawn(1000, 1737, 0, v.Position, v.Velocity, v):ToEffect()
		laser:Update()
		laser:GetData().offSetSpawn = Vector(0,-30)
		laser.Parent = v
		--laser.SpriteScale = laser.SpriteScale * 0.75
		laser:Update()
		v:Remove()
	end
end

function mod:checkTechnoPinnyLaser(e)
	if e.SubType == 0 then
		local sprite = e:GetSprite()
		local d = e:GetData()
		d.vec = d.vec or e.Velocity

		e.Velocity = e.Velocity * 0.9
		if not d.firing then
			mod:spritePlay(sprite, "Idle")
			if e.FrameCount == 15 then
				d.firing = true
				d.offSetSpawn = d.offSetSpawn or Vector(0, -30)
				local spawnref = e
				if e.Parent then spawnref = e.Parent end
				--local laser = EntityLaser.ShootAngle(2, e.Position, d.vec:GetAngleDegrees(), 5, nilvector, spawnref)
				local laser = Isaac.Spawn(7,2,0,e.Position + d.offSetSpawn, d.vec,spawnref):ToLaser()
				laser.Angle = d.vec:GetAngleDegrees()
				laser.CollisionDamage = 0.1
				laser.DepthOffset = -500
				laser:SetTimeout(5)
				laser:Update()
				laser.Velocity = e.Velocity
				mod:spritePlay(sprite, "Shoot")
			end
		else
			if sprite:IsFinished("Shoot") then
				e:Remove()
			else
				mod:spritePlay(sprite, "Shoot")
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.checkTechnoPinnyLaser, 1737)


--Run Pin AI
function mod:checkPin(npc)
	local var = npc.Variant
	local subt = npc.SubType
	if var == 0 then
		if subt == mod.FF.TechnoPin.Sub then
			mod:technopinFFChampion(npc)
		end
	end
	if not npc.Parent and npc:GetData().wasWaitingWorm then
		npc.State = 8
		npc:GetData().wasWaitingWorm = nil
		npc.Visible = true
		npc:GetSprite():Play("Attack1", true)
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.checkPin, 62)

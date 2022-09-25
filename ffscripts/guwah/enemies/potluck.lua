local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local rng = RNG()

local function GetPotluckPot(npc, data, getClosest)
    data.FirstAttempt = nil
    data.ForceSearch = nil
    local newindex
    if getClosest then
        newindex = mod:GetUnoccupiedPot(data.Index, npc.Position)
    else
        newindex = mod:GetUnoccupiedPot(data.Index)
    end
    if newindex then
        if data.Index then
            mod.OccupiedGrids[data.Index] = "Open"
        end
        data.Index = newindex
        mod.OccupiedGrids[data.Index] = "Closed"
        return newindex
    end
end

local function VerifyPot(index)
    if index then
        local room = game:GetRoom()
        local grid = room:GetGridEntity(index)
        if grid and grid:GetType() == GridEntityType.GRID_ROCK_ALT and room:GetGridCollision(index) == GridCollisionClass.COLLISION_SOLID then
            return true
        end
    end
end

function mod:PotluckAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()

    if not data.Init then
        local params = ProjectileParams()
        params.Variant = mod.FF.BetterCoinProjectile.Var
        params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
        data.Params = params

        data.FirstAttempt = true
        data.State = "Search"
        data.Init = true
    end

    if data.State == "Search" then
        mod:spritePlay(sprite, "Idle01")
        if data.Index and VerifyPot(data.Index) and not data.ForceSearch then
            npc.TargetPosition = room:GetGridPosition(data.Index) - Vector(0,4)
            npc.Velocity = mod:Lerp(npc.Velocity, (npc.TargetPosition - npc.Position):Resized(8), 0.1)
            if npc.Position:Distance(npc.TargetPosition) <= 5 then
                npc.Position = npc.TargetPosition
                npc.Velocity = Vector.Zero
                data.Anim = "EnterPot"
                data.State = "SmackDown"
            end
        else
            GetPotluckPot(npc, data, data.FirstAttempt)
            if not VerifyPot(data.Index) then
                npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position - targetpos):Resized(8), 0.1)
                if npc.Position:Distance(target.Position) > 500 then
                    npc:Remove()
                end
            end
        end
    
    elseif data.State == "SmackDown" then
        npc.Velocity = npc.Velocity * 0.6
        if sprite:IsFinished(data.Anim) then
            if data.Anim == "EnterPotWhiff" then
                data.State = "Search"
                data.ForceSearch = true
            else
                data.State = "Pancaked"
                npc.StateFrame = mod:RandomInt(15,30,rng)
            end
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, npc)
            if VerifyPot(data.Index) then
                npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                npc:SetSize(20, Vector(1,1), 12)
                data.StuckInPlace = true
            end
        else
            mod:spritePlay(sprite, data.Anim)
        end

        if not data.StuckInPlace then
            if not VerifyPot(data.Index) then
                sprite:SetAnimation("EnterPotWhiff", false)
                data.Anim = "EnterPotWhiff"
            end
        end

    elseif data.State == "Pancaked" then
        mod:spritePlay(sprite, "PotIdle01")
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            data.State = "SqueezeIn"
        end

    elseif data.State == "SqueezeIn" then
        if sprite:IsFinished("EnterPotReal") then
            npc.Visible = false
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                data.State = "PokeOut"
                npc.Visible = true
                npc.StateFrame = mod:RandomInt(15,30,rng)
            end
        elseif sprite:IsEventTriggered("Collision") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
        else
            mod:spritePlay(sprite, "EnterPotReal")
        end

    elseif data.State == "PokeOut" then
        if sprite:IsFinished("ExitPot") then
            data.State = "PreAttack"
            npc.StateFrame = 20
        elseif sprite:IsEventTriggered("Collision") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
        else
            mod:spritePlay(sprite, "ExitPot")
        end

    elseif data.State == "PreAttack" then
        mod:spritePlay(sprite, "PotIdle02")
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if rng:RandomFloat() <= 0.5 and mod.GetEntityCount(85,0) < mod.GetEntityCount(mod.FF.Potluck.ID,mod.FF.Potluck.Var) * 2 then
                data.SpawnPos = mod:FindSafeSpawnSpot(npc.Position, 80, 160) 
                --print(data.SpawnPos)
                if data.SpawnPos then
                    data.SpawnPos = data.SpawnPos + (RandomVector() * mod:RandomInt(0,20,rng))
                    data.State = "Spawn"
                else
                    data.State = "Shoot"
                end
            else
                data.State = "Shoot"
            end
        end
    
    elseif data.State == "Spawn" then
        if sprite:IsFinished("Spawn") then
            data.State = "Chillin"
            data.SpawnPos = nil
            npc.StateFrame = mod:RandomInt(8,16,rng)
        elseif sprite:IsEventTriggered("Shoot") then
            data.SpawnPos = data.SpawnPos + (RandomVector() * mod:RandomInt(0,20,rng))
            local spider = EntityNPC.ThrowSpider(npc.Position,npc,data.SpawnPos,false,-20)
            spider.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            spider:GetData().RestoreGroundCollision = true
            mod:PlaySound(SoundEffect.SOUND_SPIDER_COUGH, npc, 1.5)
            mod:FlipSprite(sprite, data.SpawnPos, npc.Position)
        else
            mod:spritePlay(sprite, "Spawn")
        end
    
    elseif data.State == "Shoot" then
        if sprite:IsFinished("Shoot") then
            data.State = "Chillin"
            npc.StateFrame = mod:RandomInt(8,16,rng)
        elseif sprite:IsEventTriggered("Shoot") then
            npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(10), 0, data.Params)
            mod:PlaySound(SoundEffect.SOUND_LITTLE_SPIT, npc)
            mod:FlipSprite(sprite, targetpos, npc.Position)
        else
            mod:spritePlay(sprite, "Shoot")
        end

    elseif data.State == "Chillin" then
        mod:spritePlay(sprite, "PotIdle03")
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            data.State = "SqueezeOut"
        end

    elseif data.State == "SqueezeOut" then
        npc.Velocity = npc.Velocity * 0.6
        if sprite:IsFinished("ExitPotReal") then
            data.State = "Search"
            data.ForceSearch = true
        elseif sprite:IsEventTriggered("Sound") then
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            npc:SetSize(13, Vector(1,1), 12)
            data.StuckInPlace = false
        else
            mod:spritePlay(sprite, "ExitPotReal")
        end

    elseif data.State == "KickedOut" then
        npc.Velocity = npc.Velocity * 0.6
        if sprite:IsFinished("Appear") then
            data.State = "Search"
            data.ForceSearch = true
        else
            mod:spritePlay(sprite, "Appear")
        end
    end

    if data.StuckInPlace then
        if VerifyPot(data.Index) then
            npc.Position = npc.TargetPosition
            npc.Velocity = Vector.Zero
            mod.NegateKnockoutDrops(npc)
        else
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            npc:SetSize(13, Vector(1,1), 12)
            data.StuckInPlace = nil
            data.State = "KickedOut"
        end
    end
end

function mod:GetUnoccupiedPot(fallback, closePos)
    local opens = {}
    local pots = mod:GetAllGridIndexOfType(GridEntityType.GRID_ROCK_ALT, GridCollisionClass.COLLISION_SOLID)
    for _, index in pairs(pots) do
        if mod.OccupiedGrids[index] ~= "Closed" then
            table.insert(opens, index)
        end
    end
    local new
    if closePos then
        local dist = 99999
        for _, index in pairs(opens) do
            local newdist = room:GetGridPosition(index):Distance(closePos)
            if newdist < dist then
                new = index
                dist = newdist
            end
        end
    else
        new = mod:GetRandomElem(opens)
    end
    if new then
        return new
    else
        return fallback
    end
end

function mod:BetterCoinProjectile(projectile, sprite, data)
    local scale = projectile.Scale
    local prefix = "Rotate"
	
	local anim
	if scale <= 0.5 then
		anim = prefix .. "1"
	elseif scale <= 0.8 then
		anim = prefix .. "2"
	elseif scale <= 1.2 then
		anim = prefix .. "3"
	elseif scale <= 1.5 then
		anim = prefix .. "4"
	elseif scale <= 1.8 then
		anim = prefix .. "5"
	elseif scale <= 2.1 then
		anim = prefix .. "6"
	end

    mod:spritePlay(sprite, anim)

    projectile.SpriteRotation = projectile.Velocity:GetAngleDegrees()
end

function mod:BetterCoinDeath(projectile, sprite)
    local poof = Isaac.Spawn(1000, 97, 0, projectile.Position, Vector.Zero, projectile)
    poof.PositionOffset = projectile.PositionOffset
    poof.Color = Color(1,1,0.7)
    sfx:Play(SoundEffect.SOUND_POT_BREAK, 0.3, 0, false, 3)
    for i = 1, 3 do
        local shard = Isaac.Spawn(1000, 98, 1, projectile.Position, RandomVector():Resized(rng:RandomFloat()*4), projectile)
    end
end
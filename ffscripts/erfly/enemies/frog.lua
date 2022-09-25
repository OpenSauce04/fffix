local mod = FiendFolio
local nilvector = Vector.Zero

function mod:frogAI(npc)
    local d = npc:GetData()
    local sprite = npc:GetSprite();
    local target = npc:GetPlayerTarget()

    npc.SpriteOffset = Vector(0, 7)
    
    if not d.init then
        d.init = true
		if d.waited then
            d.npcState = "GoUp"
            d.InitialWait = 0
			npc.Visible = true
			sprite:Play("Emerge", true)
		elseif npc.SubType == 1 then
			mod.makeWaitFerr(npc, npc.Type, npc.Variant, npc.SubType, 50, false)
		else
			d.npcState = "GoDown"
			d.InitialWait = math.random(10) + 10
		end
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        --local pit = room:SpawnGridEntity(room:GetGridIndex(npc.Position), GridEntityType.GRID_PIT, 0, 1, 0)
		if not d.waited then
            if (not mod:isFriend(npc)) and Game():GetRoom():GetFrameCount() < 5 then 
                local pit = Isaac.GridSpawn(7, 0, npc.Position, true)
                --[[local pits = pit.Sprite
                pits:ReplaceSpritesheet(0, "gfx/grid/grid_floodedcaves_pit.png");
                pits:LoadGraphics()
                pit.Sprite = pits]]
                --room:HasWaterPits() = true
                mod:UpdatePits()
            end
		end
    elseif d.init then
        npc.StateFrame = npc.StateFrame + 1
        npc.Velocity = nilvector
        if not mod:IsCurrentPitSafe(npc) then
            npc:Kill()
        end
    end

    if sprite:IsEventTriggered("DMG") then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
    elseif sprite:IsEventTriggered("NoDMG") then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    elseif sprite:IsEventTriggered("Hurgle") then
        npc:PlaySound(mod.Sounds.FrogHurgle,1.6,0,false,math.random(90,110)/100)
    elseif sprite:IsEventTriggered("shoot") then
        local targpos = mod:randomConfuse(npc, target.Position)
        local shotspeed = (targpos - npc.Position)*0.05
        npc:PlaySound(mod.Sounds.FrogShoot,1.6,0,false,math.random(90,110)/100)
        --npc:PlaySound(SoundEffect.SOUND_LITTLE_SPIT,1,0,false,1)
        local extraheight = 0
        if shotspeed:Length() > 13 then
            --[[extraheight = shotspeed:Length() - 13
            if extraheight > 3 then
                extraheight = 3
            end]]
            shotspeed = shotspeed:Resized(13)
        end
        local projectile = Isaac.Spawn(9, 0, 0, npc.Position, shotspeed, npc):ToProjectile();
        projectile.FallingSpeed = -25;
        projectile.FallingAccel = 1.5 - extraheight / 10;
        projectile.Scale = 2
        projectile:GetData().projType = "CricBod"
        projectile.SpawnerEntity = npc
        mod:makeProjectileConsiderFriend(npc, projectile)
    end

    if d.npcState == "GoDown" then
        if sprite:IsFinished("Submerge") and npc.StateFrame > d.InitialWait then
            local pos = mod:FindRandomPit(npc)
            npc.Position = pos
            sprite:Play("Emerge", true)
            d.npcState = "GoUp"
            d.InitialWait = 0
        elseif sprite:IsEventTriggered("Splash") then
        npc:PlaySound(mod.Sounds.SplashLarge,0.6,0,false,1.2)
        else
            mod:spritePlay(sprite, "Submerge")
        end
    elseif d.npcState == "GoUp" then
        if sprite:IsFinished("Emerge") then
            if mod:isScare(npc) then
                d.npcState = "Idle"
                mod:spritePlay(sprite, "Idle")
            else
                d.npcState = "Shoot"
                mod:spritePlay(sprite, "Shoot")
            end
        elseif sprite:IsEventTriggered("Splash") then
            npc:PlaySound(mod.Sounds.SplashLargePlonkless,0.6,0,false,1.5)
        end
    elseif d.npcState == "Shoot" then
        if sprite:IsFinished("Shoot") then
            d.npcState = "Idle"
            npc.StateFrame = 0
        else
            mod:spritePlay(sprite, "Shoot")
        end
    elseif d.npcState == "Idle" then
        mod:spritePlay(sprite, "Idle")
        if npc.StateFrame > 20 and (math.random(20) == 1 or mod:isScare(npc)) then
            d.npcState = "GoDown"
        end
    end
end
local mod = FiendFolio
local game = Game()

local function getTarPuddlesExceptOwn(npc, accuracy) --accuracy: how far away a puddle can be to still be considered the npc's own (default 30)
    accuracy = accuracy or 30

    local puddles = Isaac.FindByType(1000, EffectVariant.CREEP_BLACK)
    local truePuddles = {}
    for _, p in pairs(puddles) do
        if p.Position:Distance(npc.Position) > accuracy and p.Position:Distance(npc.Position) < 220 and not p:GetData().taken then --also makes it so they cant leap across the entire room
            table.insert(truePuddles, p)
        end
    end

    return truePuddles
end

local function findBestTarPuddle(npc, player) --find the puddle where the player is closest to the midpoint between it and the current puddle
    local puddles = getTarPuddlesExceptOwn(npc)

    local angleDif = -1
    local bestPuddle = -1

    for _, p in pairs(puddles) do
        local pd = player.Position - npc.Position

        if player.Position.Y < npc.Position.Y then pd = pd:GetAngleDegrees() + 360
        else pd = pd:GetAngleDegrees() end

        local pud = p.Position - npc.Position

        if p.Position.Y < npc.Position.Y then pud = pud:GetAngleDegrees() + 360
        else pud = pud:GetAngleDegrees() end

        local dif = math.min(360 - math.abs(pud - pd), math.abs(pud - pd))

        if angleDif == -1 then
            angleDif = dif
            bestPuddle = p
        elseif dif < angleDif then
            angleDif = dif
            bestPuddle = p
        end
    end

    return bestPuddle
end

local function nearOtherGob(npc)
    local gobs = Isaac.FindByType(29, 1, 170)

    for _, g in pairs(gobs) do
        if g.Index ~= npc.Index then
            if g.Position:Distance(npc.Position) < 60 then return true end
        end
    end

    return false
end

local function findEmergePos(npc, player, room)
    local puddles = {}
    for _, puddle in pairs(getTarPuddlesExceptOwn(npc)) do
        if game:GetNearestPlayer(puddle.Position).Position:Distance(puddle.Position) > 40 then
            table.insert(puddles, puddle)
        end
    end
    if #puddles > 0 --[[and npc.Position:Distance(player.Position) < 70]] then
        return room:FindFreeTilePosition(puddles[math.random(1, #puddles)].Position, 0)
    end

    local pos = room:FindFreeTilePosition(npc.Position + (player.Position - npc.Position) * 2, 0)
    if pos:Distance(player.Position) < 60 or nearOtherGob(npc) then --if youre too close to the player or another gobhopper, go somewhere slightly else
        pos = room:FindFreeTilePosition(pos:Rotated(90), 0)
    end
    return pos
end

local function gobhopperLeapToPuddle(npc, player, room, fromPuddle) --fromPuddle: is coming from underground (default false, unused, doesnt work)
    fromPuddle = fromPuddle or false
    local puddle = findBestTarPuddle(npc, player)

    if puddle ~= -1 then
        npc.Target = puddle
        puddle:GetData().taken = true
        npc.TargetPosition = room:FindFreeTilePosition(npc.Target.Position, 0)

        npc.State = 4
        npc.StateFrame = 0
        if fromPuddle then
            npc:GetSprite():Play("Emerge2InAir", true)
        else
            npc:GetSprite():Play("Hop", true)
        end

        return true
    else return false end
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.Variant == 1 and npc.SubType == mod.FF.Gobhopper.Sub then
        local room = game:GetRoom()
        local sprite = npc:GetSprite()
        local data = npc:GetData()
        local player = npc:GetPlayerTarget() --this does not seem to work the way i thought it did 
        --local player = Isaac.GetPlayer(0) (hi Guwah here idk why they did this so im undoing it)
        npc.SplatColor = mod.ColorDankBlackReal
        if (npc.State == 3 and npc.StateFrame == 1) or (npc.State == 8 and sprite:GetFrame() == 3) or (npc.State == 10 and npc.StateFrame == 1) or npc.FrameCount == 0 then --continous black creep spawning
            local puddle = Isaac.Spawn(1000, EffectVariant.CREEP_BLACK, 0, npc.Position + RandomVector() * 10, Vector(0,0), npc):ToEffect()
            puddle.SpriteScale = puddle.SpriteScale * 2
            puddle:SetTimeout(150)
            puddle:Update()
        end

        if npc.State == 3 and npc.StateFrame == 10 then --leap to puddle
            data.JumpCount = data.JumpCount or 0
            if math.random(1, 10) < 5 and not npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION) and data.JumpCount >= 1 then --determine if it will do a big dive leap, if confused only hop around
                data.bigLeap = true
            else
                data.JumpCount = data.JumpCount + 1
                data.bigLeap = false
            end

            if data.bigLeap then --lets gooo              
                if gobhopperLeapToPuddle(npc, player, room) then --but only if you can find a puddle
                    npc:PlaySound(SoundEffect.SOUND_FETUS_JUMP,1,0,false,1) 
                else
                    data.bigLeap = false
                end
            end
        end

        if npc.State == 4 then
            if data.bigLeap then --big dive leap
                if npc.Position:Distance(npc.TargetPosition) < 40 then --and if over a puddle
                    npc:PlaySound(SoundEffect.SOUND_WAR_LAVA_SPLASH,0.7,0,false,1.5)
                    npc.State = 8 --submerge
                    npc.StateFrame = 0
                    data.JumpCount = 0
                    sprite:Play("Submerge", true)
                elseif sprite:GetFrame() > 7 then
                    sprite:SetFrame(8)
                end
            elseif npc.StateFrame == 1 then
                npc.TargetPosition = room:FindFreeTilePosition(npc.TargetPosition - (npc.TargetPosition - npc.Position) / 2, 0) --smaller hops
            end
            --otherwise just let their natural hardcoded trite instincts take over
        end

        if npc.State == 8 then
            if sprite:GetFrame() == 15 then
                npc.State = 9 --underground
                npc.StateFrame = 0
                sprite:Play("Underground", true)
                npc.Visible = false
            elseif sprite:GetFrame() == 10 then --so you cant damage them when only tar ripples are still visible
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
            end
            
        end

        if npc.State == 9 and sprite:GetFrame() == 19 then 
            --if npc.StateFrame >= 20 then
                --local puddles = getTarPuddlesExceptOwn(npc) --teleport to different puddle if possible

                local pos = findEmergePos(npc, player, room)
                npc.Position = pos

                npc.State = 10 --emerge
                npc.StateFrame = 0
                sprite:Play("Emerge", true)

                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
                npc:PlaySound(SoundEffect.SOUND_WAR_LAVA_SPLASH,0.7,0,false,1.5)
                npc.Visible = true
            --else
            --   sprite:Play("Underground", true)
            --end
        end

        if npc.State == 10 then
            if sprite:GetFrame() == 15 then   
                npc:PlaySound(SoundEffect.SOUND_FETUS_LAND,1,0,false,1)         
                npc.State = 3 --go back to idle
                npc.StateFrame = 0
            elseif sprite:GetFrame() == 1 then
                npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 0.5, 0, false, 1)
            end
        end

        --possible todos/totweaks: cap their velocity so they dont do the dumb trite mega fast jumping thing? dont think this is necessary because theyre already prevented from crossing really big distances
        --maybe make them hop around a bit instead of always doing the big leap (done)
    end
end, 29)
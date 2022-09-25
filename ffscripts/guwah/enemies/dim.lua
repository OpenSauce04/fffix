local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:DimAI(npc, sprite, data)
    local room = game:GetRoom()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)

    mod.QuickSetEntityGridPath(npc)
    npc:AnimWalkFrame("WalkHori", "WalkVert", 0.1)
    mod:spriteOverlayPlay(sprite, "Head")
    if game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) or mod:isScare(npc) then
        npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(4)), 0.25)
    else
        npc.Pathfinder:FindGridPath(targetpos, 0.6, 900, true)
    end

    if npc:IsDead() then
        local ghost = Isaac.Spawn(mod.FF.DimGhost.ID, mod.FF.DimGhost.Var, 0, npc.Position, Vector.Zero, npc):ToNPC()
        if npc:IsChampion() then
            ghost:MakeChampion(69, npc:GetChampionColorIdx(), true)
            ghost.HitPoints = ghost.MaxHitPoints
        end
    end
end

function mod:DimGhostAI(npc, sprite, data)
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)

    if not data.Init then
        npc.SplatColor = mod.ColorGhostly
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        data.State = "Chase"
        data.Alpha = 1
        data.Init = true
    end

    if data.State == "Chase" then
        mod:spritePlay(sprite, "Move")
        data.Alpha = data.Alpha - 0.008
        npc:SetColor(Color(1,1,1,data.Alpha), 60, 1, false, false)

        if data.Alpha <= 0.25 then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            data.State = "Die"
        else --Yawner movement
            if mod:isScare(npc) then
                mod:UnscareWhenOutOfRoom(npc)
                if npc.Position:Distance(target.Position) < 300 then
                    local targetvel = (targetpos - npc.Position):Resized(-9)
                    npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.1)
                else
                    npc.Velocity = npc.Velocity * 0.9
                end
            else
                local targetvel = (targetpos - npc.Position):Resized(9)
                npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.1)
            end
        end
    elseif data.State == "Die" then
        npc.Velocity = npc.Velocity * 0.5
        if sprite:IsFinished("Die") then
            npc:Remove()
        else
            mod:spritePlay(sprite, "Die")
        end
    end
end
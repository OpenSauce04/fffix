local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:nerveRelay(npc, subType)
    if subType == mod.FF.NerveTent.Sub then
        mod:nerveTentacleAI(npc)
    else
        mod:nerveAI(npc)
    end
end

function mod:nerveAI(npc)
    local sprite  = npc:GetSprite()
    local target = npc:GetPlayerTarget()
    local d = npc:GetData()
    npc.Velocity = nilvector

    if not d.init then
        d.init = true
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc.State = 4
    elseif d.init then
        npc.StateFrame = npc.StateFrame + 1
    end

    if npc.State == 4 then
        mod:spritePlay(sprite,"idle")
        if npc.StateFrame > 40 then
        npc.State = 8
        end
    elseif npc.State == 8 then
        if sprite:IsFinished("fire") then
            npc.State = 4
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("SpawnNerves") then
            local room = game:GetRoom()
            --Based on centre
            local vec1 = RandomVector()*100
            for i = 180, 360, 180 do
                local pos = room:FindFreeTilePosition(room:GetCenterPos() + vec1:Rotated(i - 50+math.random(100)), 999)
                Isaac.Spawn(mod.FF.NerveTent.ID, mod.FF.NerveTent.Var, mod.FF.NerveTent.Sub, pos, nilvector, npc)
            end
            --Based on target
            local vec2 = RandomVector()*60
            for i = 180, 360, 180 do
                local pos = room:FindFreeTilePosition(target.Position + vec2:Rotated(i), 999)
                Isaac.Spawn(mod.FF.NerveTent.ID, mod.FF.NerveTent.Var, mod.FF.NerveTent.Sub, pos, nilvector, npc)
            end
            --Based on random
            local asdg = math.random(3)
            for i = 1, asdg do
                local pos = room:FindFreeTilePosition(room:GetRandomPosition(1), 999)
                Isaac.Spawn(mod.FF.NerveTent.ID, mod.FF.NerveTent.Var, mod.FF.NerveTent.Sub, pos, nilvector, npc)
            end
        else
        mod:spritePlay(sprite, "fire")
        end
    end

end

function mod:nerveTentacleAI(npc)
    local sprite  = npc:GetSprite()
    local d = npc:GetData()
    npc.Velocity = nilvector

    if sprite:IsFinished("Appear") then
    npc:Remove()
    end

    if sprite:IsEventTriggered("Appear") then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
    elseif sprite:IsEventTriggered("Disappear") then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    end
end

function mod:nerveInit(npc)
    if npc.SubType == mod.FF.NerveTent.Sub then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc:GetSprite():Play("Appear",true)
    end
end

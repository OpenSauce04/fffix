local mod = FiendFolio

--Compeltely unused
function mod:laserTowerAI(npc)
    local d = npc:GetData()
    local sprite = npc:GetSprite();
    local target = npc:GetPlayerTarget()
    
    if not d.init then
        d.init = true
        d.npcstate = 1
    end

    if d.npcstate == 1 then
        if npc.FrameCount % 10 == 1 then
        local allfriends = mod.GetAllEntities(npc, npc.Type)
            if #allfriends > 0 then
                local bestfriend = math.random(#allfriends)
                local vec1 = -(npc.Position - allfriends[bestfriend].Position)
                local lazer = Isaac.Spawn(7,2,0,npc.Position, nilvector, npc):ToLaser()
                lazer.SpawnerEntity = npc
                lazer.Parent = npc
                lazer.Angle = vec1:GetAngleDegrees()
                lazer:SetTimeout(10)
                lazer.DepthOffset = 500
                lazer.MaxDistance = vec1:Length()+50
                lazer:Update()
            end
        end


    end

end
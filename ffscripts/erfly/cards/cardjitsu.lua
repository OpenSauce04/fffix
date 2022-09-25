local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player)
    local ball = Isaac.Spawn(915, 1, mod.FF.RockBallFootball.Sub + 5, player.Position, nilvector, player)
    ball.Parent = npc
    ball.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    ball:Update()
end, mod.ITEM.CARD.CARDJITSU_SOCCER)

local FlooringTimer = 150

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player)
    local room = game:GetRoom()
    --print(room:GetGridHeight(), room:GetGridWidth())
    local topLeft = room:GetTopLeftPos()
    mod.FlooringUpgrades = mod.FlooringUpgrades or {}
    local creepVar = 46
    local creepColor = mod.ColorNormal
    local rand = math.random(6)
    if rand == 1 then
        creepVar = 44
    elseif rand == 2 then
        creepVar = 45
    elseif rand == 3 then
        creepColor = Color(1,1,1,1,-0.5,1,0)
    elseif rand == 4 then
        creepColor = Color(1,1,1,1,1,1,0)
    elseif rand == 5 then
        creepVar = 94
    end
    table.insert(mod.FlooringUpgrades, {Variant = creepVar, Color = creepColor, Position = topLeft, Frame = 0})
    local creep = Isaac.Spawn(1000, creepVar, 0, topLeft, nilvector, player):ToEffect()
    creep.Scale = 2
    creep:SetTimeout(FlooringTimer)
    creep:Update()
end, mod.ITEM.CARD.CARDJITSU_FLOORING_UPGRADE)

function mod.flooringUpgrade()
    if mod.FlooringUpgrades and #mod.FlooringUpgrades > 0 then
        local room = game:GetRoom()
        for k, v in pairs(mod.FlooringUpgrades) do
            v.Frame = v.Frame + 1
            if v.Frame % 1 == 0 then
                local foundPos
                for i = 1, 10 do
                    v.Position = v.Position + Vector(0, 40)
                    if room:IsPositionInRoom(v.Position, 0) then
                        foundPos = true
                        break
                    end
                end
                if not foundPos then
                    local topLeft = room:GetTopLeftPos()
                    v.Position = Vector(v.Position.X + 40, topLeft.Y - 40)
                    for i = 1, 10 do
                        v.Position = v.Position + Vector(0, 40)
                        if room:IsPositionInRoom(v.Position, 0) then
                            foundPos = true
                            break
                        end
                    end
                end
                if foundPos then
                    local creep = Isaac.Spawn(1000, v.Variant, 0, v.Position, nilvector, Isaac.GetPlayer()):ToEffect()
                    if v.Color then
                        creep.Color = v.Color
                    end
                    creep:SetTimeout(FlooringTimer)
                    creep.Scale = 2
                    creep:Update()
                else
                    v = nil
                end
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player)
    --local secondHandMultiplier = player:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND) + 1
    for i, v in ipairs(Isaac.GetRoomEntities()) do
        if v:IsVulnerableEnemy() and not v:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
			v:AddSlowing(EntityRef(player), 600, 0.5, Color(1.2,1.2,1.2,1,0,0,0.1))
			v:AddEntityFlags(EntityFlag.FLAG_ICE)
			v:GetData().PeppermintSlowed = true
        end
    end
    sfx:Play(SoundEffect.SOUND_DEVILROOM_DEAL, 1, 0, false, 0.8)
    for i = 1, 100 do
        local vecX = math.random(50,100)
        if math.random(2) == 1 then
            vecX = vecX * -1
        end

        local side = -400 + math.random(room:GetGridWidth()*40 + 650)

        local eff = Isaac.Spawn(1000, 138, 961, Vector(side, 30 + math.random(room:GetGridHeight() * 40 + 120)), Vector(vecX, 0), nil):ToEffect()
        eff.Color = Color(0.5,1,1,0.1,0,1,1)
        eff:GetData().opacity = 0.1
        eff:GetSprite():Stop()
        eff:GetSprite():SetFrame(math.random(4)-1)
        eff.Timeout = 50
        eff:Update()
    end
end, mod.ITEM.CARD.CARDJITSU_AC_3000)
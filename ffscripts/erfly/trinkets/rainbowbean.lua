local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:rainbowBeanPeffectUpdate(player, data)
    if player:HasTrinket(mod.ITEM.TRINKET.RAINBOW_BEAN) then
        if player.FrameCount % 10 == 1 then
            local mult = player:GetTrinketMultiplier(mod.ITEM.TRINKET.RAINBOW_BEAN)
            local n = mod.FindClosestEnemy(player.Position, math.floor(30 + (50 * mult)), true, true)
            if n then
                data.RainbowBeanAttempts = data.RainbowBeanAttempts or 0
                data.RainbowBeanAttempts = data.RainbowBeanAttempts + 1

                local rng = player:GetTrinketRNG(mod.ITEM.TRINKET.RAINBOW_BEAN)
                local rand = rng:RandomInt(100)
                local luckChance = math.max((player.Luck * 2 + 5), 1)

                local WorstLuck = 30
                if player.Luck < 0 then
                    WorstLuck = WorstLuck - (player.Luck * 5)
                end
                --print(rand, luckChance, data.RainbowBeanAttempts, WorstLuck)
                if rand <= luckChance or data.RainbowBeanAttempts > WorstLuck then
                    data.RainbowBeanAttempts = 0
                    rand = rng:RandomInt(100)
                    if rand == 0 then
                        --Rares
                        rand = rng:RandomInt(2)
                        if rand == 1 then
                            player:UseActiveItem(CollectibleType.COLLECTIBLE_MEGA_BEAN, UseFlag.USE_NOANIM)
                        else
                            player:UseActiveItem(CollectibleType.COLLECTIBLE_WAIT_WHAT, UseFlag.USE_NOANIM)
                        end
                    else
                        rand = rng:RandomInt(23)
                        if rand < 10 then
                            player:UseActiveItem(CollectibleType.COLLECTIBLE_BUTTER_BEAN, UseFlag.USE_NOANIM)
                        elseif rand < 17 then
                            player:UseActiveItem(CollectibleType.COLLECTIBLE_BEAN, UseFlag.USE_NOANIM)
                        elseif rand < 20 then
                            local lingerBean = Isaac.Spawn(1000, 105, 0, player.Position, nilvector, player)
                            lingerBean.Parent = player
                            lingerBean:Update()
                            sfx:Play(mod.Sounds.FartFrog1,0.2,0,false,math.random(80,120)/100)
                        else
                            player:UseActiveItem(CollectibleType.COLLECTIBLE_KIDNEY_BEAN, UseFlag.USE_NOANIM)
                        end
                    end
                end
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    if FiendFolio.savedata and FiendFolio.savedata.run then
        FiendFolio.savedata.run.ComposBarrelBeanFloor = nil
    end
end)
local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:yourEternalRewardPlayerUpdate(player, data)
    if not data.GivenEternalReward then
        local missingAny
        for i = 1, #FiendFolio.RewardBadges do
            if not player:HasCollectible(FiendFolio.RewardBadges[i]) then
                missingAny = true
                break
            end
        end
        if not missingAny then
            if game:GetRoom():GetFrameCount() > 10 and not data.GivenEternalReward then
                local sd = data.ffsavedata
                if not sd.SpawnedEternalReward then
                    sd.SpawnedEternalReward = true
                    local pos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true)
                    local awesomeReward = Isaac.Spawn(5, 100, mod.ITEM.COLLECTIBLE.YOUR_ETERNAL_REWARD, pos, nilvector, nil)
                    sfx:Play(mod.Sounds.Tada,1,0,false,1)

                    if game.Challenge == mod.challenges.theGauntlet then
                        if not mod.ACHIEVEMENT.ETERNAL_REWARD_OBTAINED:IsUnlocked(true) then
                            mod.ACHIEVEMENT.ETERNAL_REWARD_OBTAINED:Unlock()
                        end
                    end
                else
                    data.GivenEternalReward = true
                end
            end
        end
    end
end
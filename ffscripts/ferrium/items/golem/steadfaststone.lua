local mod = FiendFolio
local game = Game()

function mod:steadfastStoneHurt(player, damage)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.STEADFAST_STONE) then
        local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.STEADFAST_STONE)
        local room = game:GetRoom()
        local heartTotal = player:GetBoneHearts()+player:GetHearts()+player:GetSoulHearts()
        if damage >= heartTotal then
            local t0 = player:GetTrinket(0)
            local t1 = player:GetTrinket(1)
            if t0 > 0 then
                local holdingSteadfast = -1
                if t0 % 32768 == FiendFolio.ITEM.ROCK.STEADFAST_STONE then
                    holdingSteadfast = 0
                elseif t1 % 32768 == FiendFolio.ITEM.ROCK.STEADFAST_STONE then
                    holdingSteadfast = 1
                end

                if holdingSteadfast > -1 then
                    if holdingSteadfast == 0 and t1 > 0 then
                        print("t1")
                        mod.CrushRockTrinket(player, t1, player)
                        player:TryRemoveTrinket(t1)
                    else
                        print("t0")
                        mod.CrushRockTrinket(player, t0, player)
                        player:TryRemoveTrinket(t0)
                    end
                else
                    if t0 > 0 then
                        mod.CrushRockTrinket(player, t0, player)
                        player:TryRemoveTrinket(t0)
                    end
                end

                for i=1,math.max(mult, 1) do
                    Isaac.Spawn(5, 10, 3, room:FindFreePickupSpawnPosition(player.Position, 40, true, false), Vector.Zero, player)
                end
                return false
            end
        end
    end
end
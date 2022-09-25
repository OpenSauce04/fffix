local mod = FiendFolio
local sfx = SFXManager()

function mod:grossularUpdate(player, data)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.GROSSULAR) then
        local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.GROSSULAR)
        local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.GROSSULAR)

        if not data.grossularTimer then
            data.grossularTimer = 100
        end

        if mod.IsActiveRoom() then
            if data.grossularTimer > 0 then
                data.grossularTimer = data.grossularTimer-1
            end

            if data.grossularTimer == 0 then
                sfx:Play(SoundEffect.SOUND_FART, 1, 0, false, 1)
                data.grossularTimer = 300
                local aura = Isaac.Spawn(1000, 123, 8, player.Position, Vector.Zero, player):ToEffect()
                local color = Color(0.5, 0.5, 0.5, 0.7, 0.7, 1, 0.3)
                color:SetColorize(0.6, 1, 0.1, 0.35)
                aura.Color = color
                --aura.SpriteScale = Vector(0.85,0.85)

                for _,enemy in ipairs(Isaac.FindInRadius(player.Position, 100, EntityPartition.ENEMY)) do
                    if enemy:IsActiveEnemy() and (not mod:isFriend(enemy)) and (not enemy:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)) then
                        local num = math.min(3, math.ceil(mult))
                        local nums = mod:getSeveralDifferentNumbers(num, 3, rng)
                        for _,chosen in ipairs(nums) do
                            if chosen == 1 then
                                enemy:AddConfusion(EntityRef(player), 120, false)
                            elseif chosen == 2 then
                                enemy:AddFear(EntityRef(player), 120)
                            else
                                enemy:AddPoison(EntityRef(player), 120, player.Damage*1.5)
                            end
                        end
                    end
                end

                --[[for i=0,360,30 do
                    Isaac.Spawn(9, 0, 0, player.Position+Vector(0,100):Rotated(i), Vector.Zero, player)
                end]]
            elseif data.grossularTimer % 21 == 0 and data.grossularTimer < 50 then
                player:SetColor(Color(0.6, 0.6, 0.6, 1.0, 0.4, 0.6, 0.2), 5, 0, true, false)
                sfx:Play(SoundEffect.SOUND_FART, 0.35, 0, false, math.random(180,230)/100)
            end
        end
    end
end
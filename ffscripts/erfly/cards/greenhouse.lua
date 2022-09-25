local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player)
    FiendFolio.savedata.dadsHomeGreenHouseTable = FiendFolio.savedata.dadsHomeGreenHouseTable or {}
    for _,entity in ipairs(Isaac.GetRoomEntities()) do
        if (entity:IsEnemy() and not entity:IsBoss()) or (entity.Type == 5 and not entity:ToPickup():IsShopItem()) then
            local blacklisted
            if entity.Type == 33 then
                blacklisted = true
            elseif entity.Type == 62 and entity.Parent then
                blacklisted = true
            elseif entity.Type == 13 and entity.SubType == 250 then
                blacklisted = true
            elseif entity.Type == 79 and entity.Variant == 20 then
                blacklisted = true
            elseif entity.Type == 281 and entity.Parent then
                blacklisted = true
            end
            if not blacklisted then
                table.insert(FiendFolio.savedata.dadsHomeGreenHouseTable, {entity.Type, entity.Variant, entity.SubType})
                Isaac.Spawn(1000, 15, 0, entity.Position, nilvector, player)
                entity:Remove()
            end
        end
    end
    if #FiendFolio.savedata.dadsHomeGreenHouseTable > 0 then
        sfx:Play(mod.Sounds.CarIgnition, 1, 0, false, 1)
    else
        sfx:Play(mod.Sounds.FunnyFart, 1, 0, false, 1)
    end
end, Card.GREEN_HOUSE)

function mod:greenHouseDadsHome()
    if FiendFolio.savedata.dadsHomeGreenHouseTable then
        mod.scheduleForUpdate(function()
            sfx:Play(SoundEffect.SOUND_SUMMONSOUND,1,0,false,1)
            for i = 1, #FiendFolio.savedata.dadsHomeGreenHouseTable do
                local room = game:GetRoom()
                local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 1, true)
                if FiendFolio.savedata.dadsHomeGreenHouseTable[i][1] > 9 then
                    if FiendFolio.savedata.dadsHomeGreenHouseTable[i][1] == 281 then
                        mod.cheekyspawn(pos, Isaac.GetPlayer(), pos, FiendFolio.savedata.dadsHomeGreenHouseTable[i][1],FiendFolio.savedata.dadsHomeGreenHouseTable[i][2],FiendFolio.savedata.dadsHomeGreenHouseTable[i][3])
                    else
                        local enemy = Isaac.Spawn(FiendFolio.savedata.dadsHomeGreenHouseTable[i][1],FiendFolio.savedata.dadsHomeGreenHouseTable[i][2],FiendFolio.savedata.dadsHomeGreenHouseTable[i][3], pos, nilvector, nil):ToNPC()
                        local newpos = mod:FindRandomValidPathPosition(enemy, 2, 80)
                        enemy.Position = newpos
                        enemy:Update()
                    end
                else
                    Isaac.Spawn(FiendFolio.savedata.dadsHomeGreenHouseTable[i][1],FiendFolio.savedata.dadsHomeGreenHouseTable[i][2],FiendFolio.savedata.dadsHomeGreenHouseTable[i][3], pos, nilvector, nil)
                end
                for i = 0, 7 do
					local door = room:GetDoor(i)
                    if door then
                        door:Close()
                    end
				end
            end
            FiendFolio.savedata.dadsHomeGreenHouseTable = nil
        end, 1, ModCallbacks.MC_POST_UPDATE, true)
    end
end
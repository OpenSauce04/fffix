local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:thankYouFossilPeffectUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.THANK_YOU_FOSSIL) then
		local thankMult = math.ceil(FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.THANK_YOU_FOSSIL))
		--print(thankMult)
        for _, slot in pairs(Isaac.FindByType(6, -1, -1)) do
			local s = slot:GetSprite()
            if slot.Variant == 4 then
                if s:IsEventTriggered("Prize") then
                    if not slot:GetData().paidOutThankYouFossil then
                        for i = 1, thankMult do
                            local vec = Vector(0, 4):Rotated(-30 + math.random(60))
                            Isaac.Spawn(5, math.random(4) * 10, 0, slot.Position, vec, slot)
                        end
                    end
                else 
                    slot:GetData().paidOutThankYouFossil = nil
                end
            elseif slot.Variant == 5 then
                if s:IsEventTriggered("Prize") then
                    if not slot:GetData().paidOutThankYouFossil then
                        for i = 1, thankMult do
                            local vec = Vector(0, 4):Rotated(-30 + math.random(60))
                            local devilPayouts = {70, 300, 350}
                            Isaac.Spawn(5, devilPayouts[math.random(#devilPayouts)], 0, slot.Position, vec, slot)
                        end
                    end
                else 
                    slot:GetData().paidOutThankYouFossil = nil
                end
            elseif slot.Variant == 7 then
                if s:IsEventTriggered("Prize") then
                    if not slot:GetData().paidOutThankYouFossil then
                        for i = 1, thankMult do
                            local vec = Vector(0,math.random(20,30)):Rotated(-30 + math.random(60))
                            local keypayouts = {50, 60, 360}
                            Isaac.Spawn(5, keypayouts[math.random(#keypayouts)], 0, slot.Position, vec, slot)
                        end
                    end
                else 
                    slot:GetData().paidOutThankYouFossil = nil
                end
            elseif slot.Variant == 9 then
                if s:IsEventTriggered("Prize") then
                    if not slot:GetData().paidOutThankYouFossil then
                        for i = 1, thankMult do
                            if math.random(2) == 1 then
                                for i = 1, math.random(3) do
                                    local vec = Vector(0,math.random(2,5)):Rotated(-30 + math.random(60))
                                    Isaac.Spawn(5, 20, 0, slot.Position, vec, slot)
                                end
                            else
                                local vec = Vector(0,math.random(4,5)):Rotated(-30 + math.random(60))
                                Isaac.Spawn(5, 10, 0, slot.Position, vec, slot)
                            end
                        end
                    end
                else 
                    slot:GetData().paidOutThankYouFossil = nil
                end
            elseif slot.Variant == 13 then
                if s:IsEventTriggered("Prize") then
                    if not slot:GetData().paidOutThankYouFossil then
                        for i = 1, thankMult do
                            mod:addOneChargeToFirstAvailableItem(player)
                        end
                    end
                else 
                    slot:GetData().paidOutThankYouFossil = nil
                end
            elseif slot.Variant == 18 then
                if s:IsEventTriggered("Prize") then
                    if not slot:GetData().paidOutThankYouFossil then
                        for i = 1, thankMult do
                            if math.random(2) == 1 then
                                local count = math.random(2,5)
                                if math.random(2) == 1 then
                                    for i = 1, count do
                                        local afly = Isaac.Spawn(3, 43, 0, slot.Position, nilvector, slot)
                                        afly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                                        afly:Update()
                                    end
                                else
                                    for i = 1, count do
                                        Isaac.GetPlayer(0):ThrowBlueSpider(slot.Position, slot.Position+RandomVector()*25)
                                    end
                                end
                            else
                                local heartpayouts = {11, 12}
                                local vec = Vector(0,math.random(4,5)):Rotated(-30 + math.random(60))
                                Isaac.Spawn(5, 10, heartpayouts[math.random(#heartpayouts)], slot.Position, vec, slot)
                            end
                        end
                    end
                else 
                    slot:GetData().paidOutThankYouFossil = nil
                end
            end
		end
	end
end
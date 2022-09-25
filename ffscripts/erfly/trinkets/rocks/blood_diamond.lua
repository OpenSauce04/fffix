local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:bloodDiamondFire(player, tear, rng, pdata, tdata)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.BLOOD_DIAMOND) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.BLOOD_DIAMOND)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        if rng:RandomInt(50) < chance then
            tear.Color = Color(1.5, 0.6, 0.6, 1, 0.3, -0.1, -0.1)
            tdata.bloodDiamond = true
        end
    end
end

function mod:bloodDiamondPostFireBomb(player, bomb, rng, pdata, bdata)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.BLOOD_DIAMOND) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.BLOOD_DIAMOND)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        if rng:RandomInt(50) < chance then
            bomb.Color = Color(1.5, 0.6, 0.6, 1, 0.3, -0.1, -0.1)
            bdata.bloodDiamond = true
        end
    end
end
function mod:bloodDiamondOnFireAquarius(player, creep)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.BLOOD_DIAMOND) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.BLOOD_DIAMOND)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.BLOOD_DIAMOND)
        if rng:RandomInt(50) < chance then
            local data = creep:GetData()
			data.bloodDiamond = true
			local color = Color(1,0,0,1)
			data.FFAquariusColor = color
        end
    end
end
function mod:bloodDiamondOnRocketFire(player, target)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.BLOOD_DIAMOND) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.BLOOD_DIAMOND)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.BLOOD_DIAMOND)
        if rng:RandomInt(50) < chance then
            local data = creep:GetData()
			data.bloodDiamond = true
			local color = Color(1,0,0,1)
			data.FFAquariusColor = color
        end
    end
end

function mod:BloodDiamondTBARDamage(source, entity, data)
    if data.bloodDiamond then
        if entity:IsEnemy() and not (entity:IsBoss() or entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) or entity:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT)) then
            entity:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
            entity:SetColor(Color(10,0,0,1,0,0,0),10,2,true,false)
            entity:BloodExplode()
        end
    end
end

function mod:bloodDiamondOnGenericDamage(player, entity)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.BLOOD_DIAMOND) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.BLOOD_DIAMOND)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.BLOOD_DIAMOND)
        if rng:RandomInt(50) < chance then
            if entity:IsEnemy() and not (entity:IsBoss() or entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) or entity:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT)) then
                entity:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
                entity:SetColor(Color(10,0,0,1,0,0,0),10,2,true,false)
                entity:BloodExplode()
            end
        end
    end
end

function mod:bloodDiamondPlayerHurt(player)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.BLOOD_DIAMOND) then
        local creep = Isaac.Spawn(1000, 46, 0, player.Position, nilvector, player):ToEffect()
        creep.SpriteScale = creep.SpriteScale * 2
        creep:SetTimeout(120)
        creep:Update()
    end
end
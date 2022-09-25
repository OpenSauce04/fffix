local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:sapphicSapphireFire(player, tear, rng, pdata, tdata)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        if rng:RandomInt(60) < chance then
            tear.Color = Color(0.7, 0.7, 1, 1, -0.1, -0.1, 0.1)
            tear.TearFlags = tear.TearFlags | TearFlags.TEAR_ICE | TearFlags.TEAR_SLOW
        end
    end
end

function mod:sapphicSapphirePostFireBomb(player, bomb, rng, pdata, bdata)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        if rng:RandomInt(60) < chance then
            bomb.Color = Color(0.7, 0.7, 1, 1, -0.1, -0.1, 0.1)
            bomb.Flags = bomb.Flags | TearFlags.TEAR_ICE | TearFlags.TEAR_SLOW
        end
    end
end

function mod:sapphicSapphireOnRocketFire(player, target)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        if player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE):RandomInt(60) < chance then
			local data = target:GetData()

			data.ApplySapphicSapphireFreeze = true
        end
    end
end

function mod:sapphicSapphireOnFireAquarius(player, creep, secondHandMultiplier)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        if player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE):RandomInt(60) < chance then
			local data = creep:GetData()

			data.ApplySapphicSapphireFreeze = true

			local color = Color(0.3, 0.7, 1, 1, -0.2, -0.1, 0.3)
			data.FFAquariusColor = color
        end
    end
end

function mod:sapphicSapphireFireRocketAquariusDamage(source, entity, data)
    if data.ApplySapphicSapphireFreeze then
        entity:AddSlowing(EntityRef(Isaac.GetPlayer()), 60, 0.5, Color(1.2,1.2,1.2,1,0,0,0.1))
        entity:AddEntityFlags(EntityFlag.FLAG_ICE)
        entity:GetData().PeppermintSlowed = true
    end
end

function mod:sapphicSapphireOnGenericDamage(player, entity)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        if player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE):RandomInt(60) < chance then
            entity:AddSlowing(EntityRef(player), 60, 0.5, Color(1.2,1.2,1.2,1,0,0,0.1))
			entity:AddEntityFlags(EntityFlag.FLAG_ICE)
			entity:GetData().PeppermintSlowed = true
        end
    end
end

function mod:tryMakeLaserSapphic(laser)
    if laser.Variant == 1 then
        local sprite = laser:GetSprite()
        sprite:Load("gfx/effects/sapphicsapphire/effect_lesbeam.anm2")
        sprite:Play("LargeRedLaser", true)
        laser:GetData().SapphicSapphireLesbianBeam = true
        return true
    elseif laser.Variant == 9 then
        local sprite = laser:GetSprite()
        sprite:Load("gfx/effects/sapphicsapphire/effect_lestech.anm2")
        sprite:Play("LargeRedLaser", true)
        laser:GetData().SapphicSapphireLesbianBeam = true
        return true
    end
end

--Here for ease/consistency ig
function mod:tryMakeLaserTrans(laser)
    if laser.Variant == 1 then
        local sprite = laser:GetSprite()
        sprite:Load("gfx/effects/sapphicsapphire/effect_transbeam.anm2")
        sprite:Play("LargeRedLaser", true)
        laser:GetData().TransRightsAreHumanRightsBeam = true
        return true
    elseif laser.Variant == 11 then
        local sprite = laser:GetSprite()
        sprite:Load("gfx/effects/sapphicsapphire/effect_transbeam_big.anm2")
        sprite:Play("LargeRedLaser", true)
        laser:GetData().TransRightsAreHumanRightsBeamBig = true
        return true
    end
end
function mod:tryMakeLaserEmoji(laser)
    if laser.Variant == 1 then
        local sprite = laser:GetSprite()
        sprite:Load("gfx/effects/sapphicsapphire/effect_emojibeam.anm2")
        sprite:Play("LargeRedLaser", true)
        laser:GetData().EmojisAreInTheBeam = true
        return true
    end
end

function mod:sapphicSapphireFireLaser(player, laser, rng)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE) then
        mod:tryMakeLaserSapphic(laser)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, npc)
    if npc.FrameCount == 0 then
        if npc.Parent:GetData().SapphicSapphireLesbianBeam then
            local sprite = npc:GetSprite()
            sprite:Load("gfx/effects/sapphicsapphire/effect_lesbeam_impact.anm2")
            sprite:Play("Start", true)
        elseif npc.Parent:GetData().TransRightsAreHumanRightsBeam then
            local sprite = npc:GetSprite()
            sprite:Load("gfx/effects/sapphicsapphire/effect_transbeam_impact.anm2")
            sprite:Play("Start", true)
        elseif npc.Parent:GetData().TransRightsAreHumanRightsBeamBig then
            local sprite = npc:GetSprite()
            sprite:Load("gfx/effects/sapphicsapphire/effect_transbeam_impact_big.anm2")
            sprite:Play("Start", true)
        elseif npc.Parent:GetData().EmojisAreInTheBeam then
            local sprite = npc:GetSprite()
            sprite:Load("gfx/effects/sapphicsapphire/effect_emojibeam_impact.anm2")
            sprite:Play("Start", true)
        end
    end
end, EffectVariant.LASER_IMPACT)

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
    local isWoman
    if mod.anyPlayerHas(FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE, true) then
        for i = 1, #FiendFolio.Nonmale do
            if FiendFolio.Nonmale[i].ID
            and (npc.Type == FiendFolio.Nonmale[i].ID[1]) 
            and ((not FiendFolio.Nonmale[i].ID[2]) or npc.Variant == FiendFolio.Nonmale[i].ID[2]) 
            and ((not FiendFolio.Nonmale[i].ID[3]) or npc.SubType == FiendFolio.Nonmale[i].ID[3]) 
            and FiendFolio.Nonmale[i].Affliction == "Woman"
            then
                isWoman = true
                break
            end
        end
    end

    if isWoman then
        npc:AddCharmed(EntityRef(Isaac.GetPlayer()), 300)
    end
end)
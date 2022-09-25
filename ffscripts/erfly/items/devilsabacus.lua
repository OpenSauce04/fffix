local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero
local sfx = SFXManager()

local function failAbacus(player, data, saveData)
    sfx:Play(mod.Sounds.DevilsAbacusCount, math.min(-0.1 + saveData.AbacusBuff/10, 1), 0, false, 0.2)
    --Data shenanigans
    saveData.AbacusTracker = 0
    saveData.AbacusRequirement = 1
    saveData.AbacusBuff = 0
    data.cantRetryAbacus = true
    data.tryingToFireAbacus = false
    --Visuals
    player:SetColor(Color(0.5,0.5,0.5,1,0,0,0), 5, 1, true, true)
    --Stats
    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE)
    player:EvaluateItems()
end

function mod:devilsAbacusPlayerUpdate(player, data)
    local saveData = data.ffsavedata.RunEffects
    if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.DEVILS_ABACUS) then
        saveData.AbacusTracker = saveData.AbacusTracker or 0
        saveData.AbacusRequirement = saveData.AbacusRequirement or 1
        saveData.AbacusBuff = saveData.AbacusBuff or 0
        --print(saveData.AbacusTracker, saveData.AbacusRequirement, saveData.AbacusBuff)

        if saveData.AbacusTracker > saveData.AbacusRequirement then
            failAbacus(player, data, saveData)
        elseif saveData.AbacusTracker == saveData.AbacusRequirement and (saveData.AbacusBuff < saveData.AbacusRequirement) then
            saveData.AbacusBuff = saveData.AbacusRequirement
            --Visual level up effect
            player:SetColor(Color(1,1,1,1,0,0,0.3), 5, 1, true, true)
            local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_ATTRACT, 10, player.Position, nilvector, player):ToEffect()
            eff.MinRadius = 1
            eff.MaxRadius = 10
            eff.LifeSpan = 10
            eff.Timeout = 10
            eff.SpriteOffset = Vector(0, -15)
            eff.Color = Color(1,1,1,1,0,0,1)
            eff.Visible = false
            eff:FollowParent(player)
            eff:Update()
            eff.Visible = true
            sfx:Play(mod.Sounds.DevilsAbacusCount, math.min(-0.1 + saveData.AbacusBuff/10, 1), 0, false, math.log(1.1 + saveData.AbacusBuff/5))

            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()

            local str = saveData.AbacusBuff
            local AbacusFont = Font()
            AbacusFont:Load("font/pftempestasevencondensed.fnt")
            for i = 1, 60 do
                mod.scheduleForUpdate(function()
                    local pos = game:GetRoom():WorldToScreenPosition(player.Position) + Vector(AbacusFont:GetStringWidth(str) * -0.5, -(player.SpriteScale.Y * 35) - i/3)
                    local opacity
                    if i >= 30 then
                        opacity = 1 - ((i-30)/30)
                    else
                        opacity = i/30
                    end
                    AbacusFont:DrawString(str, pos.X, pos.Y, KColor(1,1,1,opacity), 0, false)
                end, i, ModCallbacks.MC_POST_RENDER)
            end
        end
        --local aim = player:GetAimDirection()
        local aim = mod.GetGoodShootingJoystick(player)
        if aim:Length() >= 0.5 then
            if data.cantRetryAbacus then
                data.tryingToFireAbacus = false
            else
                data.tryingToFireAbacus = true
            end
        else
            data.tryingToFireAbacus = false
            data.cantRetryAbacus = false
            if saveData.AbacusTracker == saveData.AbacusRequirement then
                saveData.AbacusRequirement = saveData.AbacusRequirement + 1
                saveData.AbacusTracker = 0
            elseif saveData.AbacusTracker > 0 then
                failAbacus(player, data, saveData)
            end
        end
        if data.abacusCooldown then
            data.abacusCooldown = nil
        end
    end
end

function mod:devilsAbacusPostFireTear(player, tear, rng, pdata, tdata, ignorePlayerEffects, isLudo)
    if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.DEVILS_ABACUS) then
        local aim = player:GetAimDirection()
        if not (pdata.cantRetryAbacus or pdata.abacusCooldown) then
            pdata.abacusCooldown = true
            local saveData = pdata.ffsavedata.RunEffects
            saveData.AbacusTracker = saveData.AbacusTracker or 0
            saveData.AbacusRequirement = saveData.AbacusRequirement or 1
            saveData.AbacusTracker = saveData.AbacusTracker + 1
        end
    end
end
local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

FiendFolio.AddItemPickupCallback(function(player, added)
    local pos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 1, true)
    local pill = Isaac.Spawn(5, 70, 960, pos, nilvector, nil)
end, nil, mod.ITEM.COLLECTIBLE.CYANIDE_DEADLY_DOSE)

mod:AddCallback(ModCallbacks.MC_GET_PILL_EFFECT, function(_, pillEffect, pillColor)
    if pillColor % 2048 == 960 or pillColor % 2048 == 961 then
        return PillEffect.PILLEFFECT_CYANIDE
    elseif pillEffect == PillEffect.PILLEFFECT_CYANIDE and not (pillColor % 2048 == 960 or pillColor % 2048 == 961) then
        return PillEffect.PILLEFFECT_BAD_GAS
    end
end)

local cyanideTimer = 60 * 60 --Former is how many seconds, latter is the frames

mod:AddCallback(ModCallbacks.MC_USE_PILL, function(_, pillEffect, player, flags)
    local pdata = player:GetData()
    if not pdata.ffsavedata then return end
    local sdata = pdata.ffsavedata
    if pillEffect == PillEffect.PILLEFFECT_CYANIDE then
        if math.random(10) == 1 then
            game:GetHUD():ShowItemText("Thanks doc!", "Cure with a pill!")
        end
        sdata.Cyanide = sdata.Cyanide or {}
        sdata.Cyanide.Strength = sdata.Cyanide.Strength or 0
        local doHorseEffect = mod.XalumIsPlayerUsingHorsePill(player, flags)
        if doHorseEffect then
            FiendFolio:trySayAnnouncerLine(mod.Sounds.VAPillHorseCyanide, flags, 20)
            sdata.Cyanide.Strength = sdata.Cyanide.Strength + 2
        else
            FiendFolio:trySayAnnouncerLine(mod.Sounds.VAPillCyanide, flags, 20)
            sdata.Cyanide.Strength = sdata.Cyanide.Strength + 1
        end
        sdata.Cyanide.Strength = math.min(sdata.Cyanide.Strength, 10)
        sdata.Cyanide.Timer = sdata.Cyanide.Timer or 99999
        sdata.Cyanide.Timer = math.min(sdata.Cyanide.Timer, math.ceil(cyanideTimer * ((2/3)^(sdata.Cyanide.Strength - 1))))
        if (player:GetPill(0) == 961 or player:GetPill(0) == 3009) and not (flags & UseFlag.USE_NOHUD > 0 or flags & UseFlag.USE_MIMIC > 0) then
            if math.random(10) ~= 1 then
                mod.scheduleForUpdate(function()
                    if doHorseEffect then
                        player:AddPill(3009)
                    else
                        player:AddPill(961)
                    end
                end, 0)
            end
        end
        if not (flags & UseFlag.USE_NOHUD > 0 or flags & UseFlag.USE_MIMIC > 0) then
            --player:AnimatePill(player:GetPill(0))
            player:AnimateHappy()
        end
        if mod.savedata.run then
            if not mod.savedata.run.TryingToSpawnCyanide then
                mod.savedata.run.TryingToSpawnCyanide = mod.savedata.run.TryingToSpawnCyanide or 0
                mod.savedata.run.CyanidePillsTaken = mod.savedata.run.CyanidePillsTaken or 0
                mod.savedata.run.CyanidePillsTaken = mod.savedata.run.CyanidePillsTaken + 1
            end
        end
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    else
        if sdata.Cyanide then
            sdata.Cyanide = nil
            player:AddCacheFlags(CacheFlag.CACHE_ALL)
            player:EvaluateItems()
            if mod.savedata.run then
                mod.savedata.run.TryingToSpawnCyanide = nil
            end
        end
    end
end)

function mod:cyanidePillSet(player, pill, slot, data)
    --[[if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.CYANIDE_DEADLY_DOSE) then
        if pill == 14 then
            player:SetPill(slot, 961)
        elseif pill == 2062 then
            player:SetPill(slot, 3009)
        elseif pill > 2048 then
            player:SetPill(slot, 3008)
        elseif pill > 0 then
            player:SetPill(slot, 960)
        end
    end]]
end

function mod:deadlyDosePlayerUpdate(player, data)
    local sdata = data.ffsavedata
    if sdata and sdata.Cyanide then
        if sdata.Cyanide.Timer and sdata.Cyanide.Strength then
            if player.ControlsEnabled then
                sdata.Cyanide.Timer = sdata.Cyanide.Timer - 1
                --print(sdata.Cyanide.Timer / 60)
                if (sdata.Cyanide.Timer / 60) <= 20 then
                    sdata.Cyanide.LastTime = sdata.Cyanide.LastTime or math.ceil(sdata.Cyanide.Timer / 60)
                    if sdata.Cyanide.Timer / 60 < sdata.Cyanide.LastTime then
                        sdata.Cyanide.LastTime = math.floor(sdata.Cyanide.Timer / 60)
                        local beepVol = math.min((0.1 + (0.1 * (20 - sdata.Cyanide.Timer / 60))), 1)
                        if sdata.Cyanide.LastTime % 2 == 1 then
                            sfx:Play(SoundEffect.SOUND_BEEP, beepVol, 0, false, 0.7)
                        else
                            sfx:Play(SoundEffect.SOUND_BEEP, beepVol, 0, false, 0.8)
                        end
                        local soundVol = (0.02 * (20 - sdata.Cyanide.Timer / 60))
                        sfx:Play(SoundEffect.SOUND_EXPLOSION_WEAK, soundVol, 0, false, 0.4)
                        if (sdata.Cyanide.Timer / 60) <= 10 then
                            sfx:Play(SoundEffect.SOUND_HEARTBEAT, soundVol * 2, 0, false, 1)
                            local darkAmount = (0.1 * (20 - sdata.Cyanide.Timer / 60))
                            game:Darken(1, 10)
                        end
                    end
                end
            end
            if sdata.Cyanide.Timer <= 0 then
                sdata.Cyanide = nil
                mod:removeAllHearts(player)
                mod.scheduleForUpdate(function()
                    player:Kill()
                end, 0, nil, true)
            end
        end
    end
end

function mod:cyanidePlayerRender(player, offset, data)
    if data.ffsavedata and data.ffsavedata.Cyanide then
        --[[local str = math.ceil(data.ffsavedata.Cyanide.Timer / 60)
        local pos = game:GetRoom():WorldToScreenPosition(player.Position) + Vector(string.len(str) * -3, 5)
        local opacity = 1
        Isaac.RenderText(str, pos.X, pos.Y, 1, 1, 1, opacity)]]

        local num = math.ceil(data.ffsavedata.Cyanide.Timer / 60)
        local ten = string.sub(num, 1, 1)
        local digit = string.sub(num, 2, 2)
        if num < 10 then
            digit = ten
            ten = 0
        end
        --print(ten, digit)

        local icon = Sprite()
        icon.Color = Color(1,1,1,1)
        icon:Load("gfx/ui/cyanide_timer.anm2", true)
        icon:Play("SevenSegmentDisplay", true)
        icon:SetLayerFrame(1, digit)
        icon:SetLayerFrame(2, ten or 0)
        local pos = Isaac.WorldToRenderPosition(player.Position + Vector(-3, 15)) + game:GetRoom():GetRenderScrollOffset()
        icon:Render(pos, nilvector, nilvector)
    end
end

function mod:cyanideRoomClear(spawnPos, dropRNG)
    --Cyanide Pill (prioritise this or else the player might die)
    if mod.savedata.run and mod.savedata.run.TryingToSpawnCyanide then
        mod.savedata.run.TryingToSpawnCyanide = mod.savedata.run.TryingToSpawnCyanide + 1
        local randChance = 2 + mod.savedata.run.CyanidePillsTaken
        --print(randChance)
        local rand = dropRNG:RandomInt(randChance)
        if rand < mod.savedata.run.TryingToSpawnCyanide then
            local pill = Isaac.Spawn(5, 70, 0, spawnPos, nilvector, nil)
            mod.savedata.run.TryingToSpawnCyanide = 0
        end
    elseif mod.anyPlayerHas(mod.ITEM.COLLECTIBLE.CYANIDE_DEADLY_DOSE) then
        local rand = dropRNG:RandomInt(6)
        if rand == 0 then
            local pill = Isaac.Spawn(5, 70, 0, spawnPos, nilvector, nil)
        end
    end
end
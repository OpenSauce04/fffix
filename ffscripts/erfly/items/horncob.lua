local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--[[
YOU WERE ALL FREAKING PLAYED
SO FREAKIND HARD HAHAHAH AHAH AH AHAH AHA
WE GOT U GOOOOOOOOOOOOOOOOOOOOOOOOOOOOD!!!!!

This was never an active item!
Nor was that biend ever real!
He was a joke from the start!

BUT! Hey, the sprites were nice right? I wanted to
make sure they were still used in the MOD somewhere...

So enjoy Horncob!
It's kinda like tainted GMO Corn I suppose.
The ULTIMATE corn!
]]

FiendFolio.AddItemPickupCallback(function(player, added)
    if player:GetPlayerType() == FiendFolio.PLAYER.FIEND then
        local str = "The Unscrupulous"
        local wingedFont = Font()
        wingedFont:Load("font/pftempestasevencondensed.fnt")
        for i = 1, 60 do
            mod.scheduleForUpdate(function()
                --wingedFont:GetStringWidth(str) * -3
                local pos = game:GetRoom():WorldToScreenPosition(player.Position) + Vector(wingedFont:GetStringWidth(str) * -0.5, -(player.SpriteScale.Y * 35) - i/3)
                local opacity
                if i >= 30 then
                    opacity = 1 - ((i-30)/30)
                else
                    opacity = i/30
                end
                --Isaac.RenderText(str, pos.X, pos.Y, 1, 1, 1, opacity)
                wingedFont:DrawString(str, pos.X, pos.Y, KColor(1,1,1,opacity), 0, false)
            end, i, ModCallbacks.MC_POST_RENDER)
        end
    end
end, nil, mod.ITEM.COLLECTIBLE.HORNCOB)

function mod:horncobPostFire(player, tear, rng, pdata, tdata)
	if player:HasCollectible(mod.ITEM.COLLECTIBLE.HORNCOB) then
        mod:changeTearVariant(tear, TearVariant.HORNCOB_PILL)
        tdata.HorncobInflicting = true
	end
end

function mod:horncoblocustAI(locust, subtype)
    locust:GetData().HorncobInflicting = true
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, damage, flags, source, countdown)
    local player
    if entity:IsEnemy() then
        if source then
            if source.Entity then
                if (source.Entity.Type == 1) or (source.Entity.Type == EntityType.ENTITY_EFFECT and source.Entity.Variant == EffectVariant.DARK_SNARE) then
                    local checkEnt = source.Entity
                    if source.Entity.Type == 1000 then
                        checkEnt = source.Entity.SpawnerEntity
                    end
                    checkEnt = checkEnt:ToPlayer()
                    if checkEnt and checkEnt:HasCollectible(mod.ITEM.COLLECTIBLE.HORNCOB) then
                        player = checkEnt
                    end
                else
                    if source.Entity:GetData().HorncobInflicting then
                        if source.Entity.SpawnerEntity then
                            if source.Entity.SpawnerEntity.Type == 1 then
                                player = source.Entity.SpawnerEntity
                            elseif source.Entity.SpawnerEntity.Type == 3 then
                                if source.Entity.SpawnerEntity:ToFamiliar().Player then
                                    player = source.Entity.SpawnerEntity:ToFamiliar().Player
                                end
                            end
                        end
                    end
                end
            end
        end
        if player then
            player = player:ToPlayer()
            --if player:HasCollectible(mod.ITEM.COLLECTIBLE.HORNCOB) then
                for i = 1, 2 do
                    mod.scheduleForUpdate(function()
                        --safety check
                        if player and player:Exists() then
                            if math.random() * 8 <= 2 + player.Luck * 0.4 then
                                if entity and entity:Exists() and entity:IsEnemy() and entity:IsDead() and not (entity:GetData().checkedHornCob or (entity.Type == mod.FFID.Tech and entity.Variant > 999)) then
                                    FiendFolio.QueuePills(player, 1)
                                    sfx:Play(SoundEffect.SOUND_PORTAL_SPAWN, 0.5, 0, false, math.random(130,170)/100)
                                    sfx:Play(SoundEffect.SOUND_BAND_AID_PICK_UP, 0.7, 0, false, math.random(70,80)/100)
                                    entity:GetData().checkedHornCob = true
                                end
                            end
                        end
                    end, i)
                end
            --end
        end
    end
end)
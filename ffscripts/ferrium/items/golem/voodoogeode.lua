local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:voodooGeodeUpdate(player, data)
    if player:HasTrinket(mod.ITEM.ROCK.VOODOO_GEODE) then
        local level = game:GetLevel()
        if level:GetCurses() > 0 or (player:HasCollectible(mod.ITEM.COLLECTIBLE.BLACK_LANTERN) and not mod.anyPlayerHas(CollectibleType.COLLECTIBLE_BLACK_CANDLE)) then
            if not data.voodooGeodeCurse then
                data.voodooGeodeCurse = true
                sfx:Play(SoundEffect.SOUND_DEATH_CARD, 1, 0, false, 1)
                for i=1,3 do
                    local smoke = Isaac.Spawn(1000, EffectVariant.DUST_CLOUD, 0, player.Position+Vector(math.random(-5,5),10), Vector(0,-4.5):Rotated(math.random(-45,45)), player):ToEffect()
				    smoke:SetTimeout(50)
				    smoke.SpriteScale = Vector(0.5,0.5)
                    smoke.Color = Color(0.2, 0.2, 0.2, 0.5, 0, 0, 0)
				    smoke:Update()
				    smoke:Update()
                end
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:EvaluateItems()
            end
        else
            if data.voodooGeodeCurse == true then
                data.voodooGeodeCurse = false
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:EvaluateItems()
            end
        end
    end
end

function mod:voodooGeodeNewRoom(player, data)
    if player:HasTrinket(mod.ITEM.ROCK.VOODOO_GEODE) then
        local room = game:GetRoom()
        local savedata = data.ffsavedata
        if room:GetType() == RoomType.ROOM_CURSE and room:IsFirstVisit() then
            savedata.voodooGeodeCurseRooms = (savedata.voodooGeodeCurseRooms or 0)+1
            sfx:Play(SoundEffect.SOUND_DEATH_CARD, 1, 0, false, 1)
            for i=1,3 do
                local smoke = Isaac.Spawn(1000, EffectVariant.DUST_CLOUD, 0, player.Position+Vector(math.random(-5,5),10), Vector(0,-4.5):Rotated(math.random(-45,45)), player):ToEffect()
			    smoke:SetTimeout(50)
			    smoke.SpriteScale = Vector(0.5,0.5)
                smoke.Color = Color(0.2, 0.2, 0.2, 0.5, 0, 0, 0)
			    smoke:Update()
			    smoke:Update()
            end
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
        end
    end
end

function mod:voodooGeodeNewLevel(player, data)
    local savedata = data.ffsavedata
    if savedata.voodooGeodeCurseRooms then
        savedata.voodooGeodeCurseRooms = 0
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
    end
end
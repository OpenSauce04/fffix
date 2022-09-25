local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:crazyJackpotPlayerHurt(player)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.CRAZY_JACKPOT) then
        if player:GetData().crazyJackpotRolling then
            player:GetData().crazyJackpotRolling.Queue = player:GetData().crazyJackpotRolling.Queue or 0
            player:GetData().crazyJackpotRolling.Queue = player:GetData().crazyJackpotRolling.Queue + 1
        else
            player:GetData().crazyJackpotRolling = {}
        end
    end
end

function mod:crazyJackpotPlayerUpdate(player, data)
    if data.crazyJackpotRolling then
        data.crazyJackpotRolling.Timer = data.crazyJackpotRolling.Timer or 0
        data.crazyJackpotRolling.Timer = data.crazyJackpotRolling.Timer + 1
        data.crazyJackpotRolling.Rolls = {math.random(6,11),math.random(6,11),math.random(6,11)}
        if not data.crazyJackpotRolling.FinalResults then
            sfx:Play(SoundEffect.SOUND_ULTRA_GREED_PULL_SLOT, 1, 0, false, 1.5)
            data.crazyJackpotRolling.FinalResults = {}
            local rng = player:GetCollectibleRNG(mod.ITEM.COLLECTIBLE.CRAZY_JACKPOT)
            local rand = rng:RandomInt(10)
            local luckrand = rng:RandomInt(100) / 10
            --local rand = 2
            if rand < 3 or player.Luck > luckrand then
                local rolls = rng:RandomInt(6)
                --local rolls = 4
                data.crazyJackpotRolling.Winner = rolls
                for i = 1, 3 do
                    table.insert(data.crazyJackpotRolling.FinalResults, rolls)
                end
            elseif rand < 6 then
                local rolls = rng:RandomInt(6)
                for i = 1, 2 do
                    table.insert(data.crazyJackpotRolling.FinalResults, rolls)
                end
                while rolls == data.crazyJackpotRolling.FinalResults[2] do
                    rolls = rng:RandomInt(6)
                end
                table.insert(data.crazyJackpotRolling.FinalResults, rolls)
            else
                table.insert(data.crazyJackpotRolling.FinalResults, rng:RandomInt(6))
                for i = 2, 3 do
                    local rolls = rng:RandomInt(6)
                    while rolls == data.crazyJackpotRolling.FinalResults[i- 1] do
                        rolls = rng:RandomInt(6)
                    end
                    table.insert(data.crazyJackpotRolling.FinalResults, rolls)
                end
            end
        end
        if data.crazyJackpotRolling.Timer == 60 or data.crazyJackpotRolling.Timer == 90 or data.crazyJackpotRolling.Timer == 120 then
            sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SLOT_WIN_LOOP_END, 1, 0, false, 0.8)
        end
        if data.crazyJackpotRolling.Timer == 120 and data.crazyJackpotRolling.Winner then
            sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SLOT_WIN_LOOP, 0.5, 0, true, 1)
            local rng = player:GetCollectibleRNG(mod.ITEM.COLLECTIBLE.CRAZY_JACKPOT)
            if data.crazyJackpotRolling.Winner == 0 or data.crazyJackpotRolling.Winner == 5 then
                local rotAng = -45 + math.random(25)
                if rng:RandomInt(2) == 1 then
                    for i = -1, 1, 2 do
                        local penny = Isaac.Spawn(5, 20, 0, player.Position, Vector(0, math.random(30,50)/10):Rotated(rotAng * i), player)
                    end
                else
                    local penny = Isaac.Spawn(5, 20, 0, player.Position, Vector(0, math.random(30,50)/10):Rotated(-45 + math.random(90)), player)
                end
            end
            if data.crazyJackpotRolling.Winner == 1 or data.crazyJackpotRolling.Winner == 5 then
                local heart = Isaac.Spawn(5, 10, 0, player.Position, Vector(0, math.random(30,50)/10):Rotated(-45 + math.random(90)), player):ToPickup()
                heart.Timeout = 60
                heart:Update()
            end
            if data.crazyJackpotRolling.Winner == 2 or data.crazyJackpotRolling.Winner == 5 then
                sfx:Play(mod.Sounds.LookerShoot,1,0,false,0.5)
                local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_ATTRACT, 10, player.Position, nilvector, player):ToEffect()
                eff.MinRadius = 1
                eff.MaxRadius = 30
                eff.LifeSpan = 10
                eff.Timeout = 10
                eff.SpriteOffset = Vector(0, -15)
                eff.Color = Color(1,0.2,0.2,1,1,0,0)
                eff.Visible = false
                eff:FollowParent(player)
                eff:Update()
                eff.Visible = true

                for _, enemy in pairs(Isaac.FindInRadius(player.Position, 250, EntityPartition.ENEMY)) do
                    local vec = (enemy.Position - player.Position)
                    local dist = vec:Length()
                    if dist < 100 + enemy.Size + player.Size then
                        if not enemy:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK) then
                            enemy.Velocity = vec:Resized(10)
                        end
                        enemy:TakeDamage(player.Damage * 5, 0, EntityRef(Isaac.GetPlayer(0)), 0)
                    end
                end
            end
            if data.crazyJackpotRolling.Winner == 3 or data.crazyJackpotRolling.Winner == 5 then
                player:AnimateHappy()
                local rand = rng:RandomInt(3)
                data.crazyJackpotStats = data.crazyJackpotStats or {}
                if rand == 0 then
                    data.crazyJackpotStats.Damage = data.crazyJackpotStats.Damage or 0
                    data.crazyJackpotStats.Damage = data.crazyJackpotStats.Damage + 1
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                elseif rand == 1 then
                    data.crazyJackpotStats.Tears = data.crazyJackpotStats.Tears or 0
                    data.crazyJackpotStats.Tears = data.crazyJackpotStats.Tears + 1
                    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                elseif rand == 2 then
                    data.crazyJackpotStats.Luck = data.crazyJackpotStats.Luck or 0
                    data.crazyJackpotStats.Luck = data.crazyJackpotStats.Luck + 1
                    player:AddCacheFlags(CacheFlag.CACHE_LUCK)
                end
                player:EvaluateItems()
            end
            if data.crazyJackpotRolling.Winner == 4 or data.crazyJackpotRolling.Winner == 5 then
                sfx:Play(SoundEffect.SOUND_GASCAN_POUR, 1, 0, false, 1)
                local creep = Isaac.Spawn(1000, 32, 0, player.Position, nilvector, player):ToEffect()
                creep.Scale = creep.Scale * 1.25
                creep:Update()
            end
        end
        if data.crazyJackpotRolling.Timer >= 180 or (not data.crazyJackpotRolling.Winner and data.crazyJackpotRolling.Timer >= 150) then
            if sfx:IsPlaying(SoundEffect.SOUND_ULTRA_GREED_SLOT_WIN_LOOP) then
                sfx:Stop(SoundEffect.SOUND_ULTRA_GREED_SLOT_WIN_LOOP)
                sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SLOT_WIN_LOOP_END, 0.5, 0, false, 1)
            end
            
            if data.crazyJackpotRolling.Queue then
                data.crazyJackpotRolling.Queue = data.crazyJackpotRolling.Queue - 1
                if data.crazyJackpotRolling.Queue <= 0 then
                    data.crazyJackpotRolling.Queue = nil
                end
                data.crazyJackpotRolling = {Queue = data.crazyJackpotRolling.Queue}
            else
                data.crazyJackpotRolling = nil
            end            
        end
    end
end

function mod:crazyJackpotPlayerNewRoom(player, data, savedata)
    if data.crazyJackpotStats then
        data.crazyJackpotStats = nil
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    end
end

function mod:crazyJackpotPlayerRender(player, offset, data)
    if data.crazyJackpotRolling and data.crazyJackpotRolling.Timer then
        local icon = Sprite()
        if data.crazyJackpotRolling.Winner and data.crazyJackpotRolling.Timer > 120 and data.crazyJackpotRolling.Timer % 6 >= 3 then
            icon.Color = Color(1,1,1,0)
        elseif not data.crazyJackpotRolling.Winner and not data.crazyJackpotRolling.Queue and data.crazyJackpotRolling.Timer > 120 then
            icon.Color = Color(1,1,1,1 - ((data.crazyJackpotRolling.Timer - 120)/30))
        else
            icon.Color = Color(1,1,1,1)
        end
        icon:Load("gfx/ui/ui_crazy_jackpot.anm2", true)
        icon:Play("Idle", true)
        if data.crazyJackpotRolling.Timer < 10 then
            icon:SetLayerFrame(0, 2)
        elseif data.crazyJackpotRolling.Timer < 20 then
            icon:SetLayerFrame(0, 1)
        else
            icon:SetLayerFrame(0, 0)
        end
        for i = 1, 3 do
            icon:SetLayerFrame(i, data.crazyJackpotRolling.Rolls[i])
        end
        if data.crazyJackpotRolling.Timer >= 60 then
            if data.crazyJackpotRolling.Timer >= 120 then
                icon:SetLayerFrame(3, data.crazyJackpotRolling.FinalResults[3])
            end
            if data.crazyJackpotRolling.Timer >= 90 then
                icon:SetLayerFrame(2, data.crazyJackpotRolling.FinalResults[2])
            end
            icon:SetLayerFrame(1, data.crazyJackpotRolling.FinalResults[1])
        end
        local pos = Isaac.WorldToRenderPosition(player.Position + Vector(4, -65 * player.SpriteScale.Y)) + game:GetRoom():GetRenderScrollOffset()
        icon:Render(pos, nilvector, nilvector)
    end
end
local mod = FiendFolio
local game = Game()

local peat = Isaac.GetPlayerTypeByName("Peat")

StageAPI.AddPlayerGraphicsInfo(peat, {
    Name = "gfx/enemies/peat/bossname_peat.png",
    Portrait = "gfx/enemies/peat/portraitgiffin_player.png",
    NoShake = false
})

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    for i = 0, game:GetNumPlayers() do
        local player = Isaac.GetPlayer(i)
        if player:GetPlayerType() == peat then
            player:GetSprite():Load("gfx/characters/player_pete.anm2", true)
        	player:GetSprite():Play(player:GetSprite():GetDefaultAnimationName(), true)
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
    if player:GetSprite():GetFilename() ~= "gfx/characters/player_pete.anm2" then
        player:GetSprite():Load("gfx/characters/player_pete.anm2", true)
        player:GetSprite():Play(player:GetSprite():GetDefaultAnimationName(), true)
    end

    local data = player:GetData()

    if not data.Horsemode then
        local horses = Isaac.FindByType(mod.FF.Horse.ID, mod.FF.Horse.Var, -1, false, false)
        local stableHorses = Isaac.FindByType(mod.FF.StableHorse.ID, mod.FF.StableHorse.Var, -1, false, false)
        local ponies = Isaac.FindByType(mod.FF.StablePony.ID, mod.FF.StablePony.Var, -1, false, false)
        local taintedHorses = Isaac.FindByType(mod.FF.StableTainted.ID, mod.FF.StableTainted.Var, -1, false, false)

        for _, h in ipairs(stableHorses) do horses[#horses+1] = h end
        for _, h in ipairs(ponies) do horses[#horses+1] = h end
        for _, h in ipairs(taintedHorses) do horses[#horses+1] = h end

        for _, horse in ipairs(horses) do
            if horse.Position:DistanceSquared(player.Position) <= (player.Size + horse.Size) ^ 2 then
                data.Horsemode = true
                data.HorseSprite = Sprite()
                local hsprite = horse:GetSprite()
                data.HorseSprite.Scale = hsprite.Scale
                data.HorseSprite:Load(hsprite:GetFilename(), true)
                data.Pony = horse.Variant == mod.FF.StablePony.Var
                data.Tainted = horse.Variant == mod.FF.StableTainted.Var
                horse:Remove()
                break
            end
        end

        player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
    else
        player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS

        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            if entity:IsActiveEnemy(false) and entity:IsVulnerableEnemy() and not mod:isFriend(entity) and entity.Position:DistanceSquared(player.Position) < (entity.Size + player.Size + 30) ^ 2 then
                entity:TakeDamage(100, 0, EntityRef(player), 0)
            end
        end
    end

    if player.Velocity:Length() > 1 then
        data.WalkFrame = data.WalkFrame or 0
        data.WalkFrame = data.WalkFrame + 1
    else
        data.WalkFrame = nil
    end

    local sprite = player:GetSprite()
    if sprite:IsPlaying("WalkUp") then
        sprite.FlipX = player.Velocity.X > 0
    elseif sprite:GetAnimation() == "WalkDown" then
        sprite.FlipX = player.Velocity.X < 0
    else
        sprite.FlipX = false
    end
end, peat)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
    if collider and collider:ToPlayer() and collider:ToPlayer():GetPlayerType() == peat then
        if pickup.Variant ~= PickupVariant.PICKUP_HEART or pickup:IsShopItem() then
            return true
        end
    end
end)

local horsemodePeat = Sprite()
horsemodePeat:Load("gfx/characters/player_pete.anm2", true)
horsemodePeat:ReplaceSpritesheet(12, "gfx/enemies/peat/family_guy__peter_griffin_sprites_by_fatchrisb-d4kkfha_horsemode.png")
horsemodePeat:ReplaceSpritesheet(1, "gfx/enemies/peat/family_guy__peter_griffin_sprites_by_fatchrisb-d4kkfha_horsemode.png")
horsemodePeat:LoadGraphics()

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function(_, player)
    if player:GetPlayerType() == peat then
        local data = player:GetData()

        if data.Horsemode then
            local offset = Vector(0, -27)
            if data.Pony then
                offset = Vector(0, -5)
            elseif data.Tainted then
                offset = Vector(0, -50)
            end

            player:GetSprite().Offset = offset
            local pos = Game():GetRoom():WorldToScreenPosition(player.Position)

            local horsemodePeatHorse = data.HorseSprite
            if data.WalkFrame then
                horsemodePeatHorse:SetFrame("Walk", data.WalkFrame % 6)
            else
                horsemodePeatHorse:SetFrame("Idle", 0)
            end

            horsemodePeatHorse.FlipX = player.Velocity.X > 0
            horsemodePeatHorse:Render(pos, Vector.Zero, Vector.Zero)
            
            horsemodePeat:SetFrame(player:GetSprite():GetAnimation(), player:GetSprite():GetFrame())
            horsemodePeat.FlipX = player:GetSprite().FlipX
            horsemodePeat.Offset = player:GetSprite().Offset
            horsemodePeat:Render(pos, Vector.Zero, Vector.Zero)
        else
            player:GetSprite().Offset = Vector.Zero
        end
    end
end)
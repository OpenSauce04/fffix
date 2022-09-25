local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:erflyCommandShit(cmd, params)
    if cmd == "fortune" then
        mod:fortuneCommand(cmd, params)
    elseif cmd == "rule" then
        mod:ShowRule()
    elseif cmd == "championall" then
        for _,entity in ipairs(Isaac.GetRoomEntities()) do
            local enemy = entity:ToNPC()
            if enemy then
                enemy:Morph(enemy.Type, enemy.Variant, enemy.SubType, math.random(10))
            end
        end
    elseif cmd == "gimmeall" then
        Isaac.GetPlayer():GetData().giveAllItems = true
        --[[local player = Isaac.GetPlayer()
        local itempool = game:GetItemPool()
        for i = 1, 1000 do
            local itemChoice = itempool:GetCollectible(math.random(ItemPoolType.NUM_ITEMPOOLS) - 1, true)
            player:AddCollectible(itemChoice)
        end]]
    elseif cmd == "taintme" then
        local player = Isaac.GetPlayer()
        player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/fiends_horn_tainted.anm2"))
        local sprite = player:GetSprite()
        sprite:ReplaceSpritesheet(1, "gfx/characters/costumes/player_tainted_fiend.png")
        sprite:ReplaceSpritesheet(4, "gfx/characters/costumes/player_tainted_fiend.png")
        sprite:ReplaceSpritesheet(12, "gfx/characters/costumes/player_tainted_fiend.png")
        sprite:LoadGraphics()
        player:SetPocketActiveItem(FiendFolio.ITEM.COLLECTIBLE.HORNCOB, ActiveSlot.SLOT_POCKET)
        player:GetData().TheRealTaintedFiend = true
    end
end

function mod:erflyCustomCommandsPlayerUpdate(player, data)
    if data.giveAllItems then
        if player.FrameCount % 1 == 0 then
            local itempool = game:GetItemPool()
            local itemChoice = itempool:GetCollectible(math.random(ItemPoolType.NUM_ITEMPOOLS) - 1, true)
            player:AddCollectible(itemChoice)
        end
    end
end
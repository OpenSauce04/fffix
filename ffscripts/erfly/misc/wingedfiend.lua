local mod = FiendFolio
local game = Game()
FiendFolio.AddItemPickupCallback(function(player, added)
    if player:GetPlayerType() == FiendFolio.PLAYER.FIEND then
        local str = "The Winged Fiend"
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
end, nil, CollectibleType.COLLECTIBLE_MERCURIUS)
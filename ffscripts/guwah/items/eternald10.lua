local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

mod.RerollDummies = {
    {EntityType.ENTITY_GAPER, 0},
    {EntityType.ENTITY_FATTY, 0},
    {mod.FF.Sixth.ID, mod.FF.Sixth.Var},
    {EntityType.ENTITY_GURGLE, 0},
    {mod.FF.Skulltist.ID, mod.FF.Skulltist.Var},
    {mod.FF.CancerBoy.ID, mod.FF.CancerBoy.Var},
    {mod.FF.Dizzy.ID, mod.FF.Dizzy.Var},
    {mod.FF.Lurch.ID, mod.FF.Lurch.Var},
}

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, itemID, itemRNG, player, useFlags, useSlot, varData)
    local eternalD10Filter = function (_, candidate)
        if candidate:CanReroll() then
            return true
        end
    end
    local enemies = mod:GetAllEnemies(eternalD10Filter)
    if #enemies > 0 then
        for _, enemy in pairs(enemies) do
            if mod:RandomInt(1,3) == 1 then
                local poof = Isaac.Spawn(1000,15,0,enemy.Position,Vector.Zero,player)
                poof.Color = Color(1,1,1,1,0.5,0.5,0.5)
                enemy:Remove()
            else
                local hp = enemy.MaxHitPoints
                local i1 = math.floor(hp / 10)
                i1 = i1 + 1
                i1 = math.max(i1, 1)
                i1 = math.min(i1, 8)
                local champion = -1
                if enemy:IsChampion() then
                    champion = enemy:GetChampionColorIdx()
                end
                local entry = mod.RerollDummies[i1]
                enemy:Morph(entry[1], entry[2], 0, champion)
                game:RerollEnemy(enemy)
            end
        end
        sfx:Play(SoundEffect.SOUND_BLACK_POOF)
    end
    return true
end, CollectibleType.COLLECTIBLE_ETERNAL_D10)
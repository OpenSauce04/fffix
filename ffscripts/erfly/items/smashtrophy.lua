local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local smashVol = 0.3

function mod:trySmashPush(pos, entity)
    if entity.Type == 33 or not (entity:HasEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK) or entity:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)) then
        local smashvec = (entity.Position - pos)
        entity:GetData().smashedByTrophy = {Timer = 5, Vec = (entity.Position - pos)}
        if entity.HitPoints < entity.MaxHitPoints / 8 then
            sfx:Play(mod.Sounds.SmashHitShocking, smashVol, 0, false, math.random(80,120)/100)
        elseif entity.HitPoints < entity.MaxHitPoints / 2 then
            sfx:Play(mod.Sounds.SmashHitHeavy, smashVol, 0, false, math.random(80,120)/100)
        else
            sfx:Play(mod.Sounds.SmashHitWeak, smashVol, 0, false, math.random(80,120)/100)
        end
    end
end

function mod:smashTrophyGenericDamage(player, entity)
    if mod.anyPlayerHas(mod.ITEM.COLLECTIBLE.SMASH_TROPHY) then
        mod:trySmashPush(player.Position, entity)
    end
end

function mod:smashTrophyDarkArtsDamage(source, entity)
    if mod.anyPlayerHas(mod.ITEM.COLLECTIBLE.SMASH_TROPHY) then
        mod:trySmashPush(entity.Position+RandomVector(), entity)
    end
end

function mod:smashTrophyAwayFromPlayerDamage(player, entity)
    if mod.anyPlayerHas(mod.ITEM.COLLECTIBLE.SMASH_TROPHY) then
        mod:trySmashPush(entity.Position - (entity.Position - player.Position), entity)
    end
end

function mod:smashTrophyOnLocustDamage(player, locust, entity)
    mod:trySmashPush(entity.Position - (entity.Position - locust.Position), entity)
end

function mod:smashTrophyEntityUpdate(npc, data)
    if data.smashedByTrophy then
        if data.smashedByTrophy.Vec then
            local smashvec = data.smashedByTrophy.Vec:Resized(10 * data.smashedByTrophy.Timer * (1 - (math.max(npc.HitPoints,1)/math.max(npc.MaxHitPoints,1))))
            npc.Velocity = mod:Lerp(npc.Velocity, smashvec, 0.5)
        end
        data.smashedByTrophy.Timer = data.smashedByTrophy.Timer - 1
        if npc:CollidesWithGrid() and npc:IsDead() then
            sfx:Play(mod.Sounds.SmashHitFatal, smashVol, 0, false, math.random(80,120)/100)
        end
        if data.smashedByTrophy.Timer <= 0 then
            data.smashedByTrophy = nil
        end
    end
end
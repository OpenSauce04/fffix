local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:BlastedAI(npc, sprite, data)
    if not data.Init then
        npc.SplatColor = mod.ColorDullGray
        data.Init = true
    end
    if sprite:IsEventTriggered("Shoot") and not (sprite:IsPlaying("DigOut") or sprite:IsPlaying("DigOut2")) then
        local room = game:GetRoom()
        local index = room:GetGridIndex(npc.Position)
        local poop = room:GetGridEntity(index)
        if poop and poop:GetType() == GridEntityType.GRID_POOP then
            room:RemoveGridEntity(index, 0, false)
        end
        Isaac.Spawn(mod.FF.BlastedMine.ID, mod.FF.BlastedMine.Var, 0, npc.Position + Vector(0,5), Vector.Zero, npc):ToNPC()
        npc:PlaySound(SoundEffect.SOUND_PLOP, 1, 0, false, 0.5)
    elseif sprite:IsEventTriggered("BombShoot") then
        local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
        local vel = (targetpos - npc.Position):Resized(10)
        local bomb = Isaac.Spawn(4,14,0, npc.Position + vel:Resized(30), vel, npc):ToBomb()
        bomb:GetData().DontTouchBlasted = true
        bomb.RadiusMultiplier = 0.65
        bomb.ExplosionDamage = 10
        mod:FlipSprite(sprite, npc.Position, targetpos)
        npc:PlaySound(SoundEffect.SOUND_WHEEZY_COUGH, 1, 0, false, 1)
        local effect = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, npc.Position - Vector(0,25), Vector.Zero, nil):ToEffect()
        effect:GetData().longonly = true
        effect.Color = Color(0.5, 0.5, 0.5, 1)
        effect.DepthOffset = npc.Position.Y * 1.25
    end
end

function mod:BlastedColl(npc, collider)
    if collider:GetData().DontTouchBlasted then
        return true
    end
end

function mod:BlastedHurt(npc, amount, damageFlags, source)
    if mod:HasDamageFlag(DamageFlag.DAMAGE_EXPLOSION, damageFlags) and not mod:IsPlayerDamage(source) then
        return false
    end
end

function mod:BlastedMineAI(npc, sprite, data)
    if not data.Init then
        sprite:Play("Appear")
        npc.SplatColor = mod.ColorInvisible
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS + EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK + EntityFlag.FLAG_NO_KNOCKBACK)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_DEATH_TRIGGER + EntityFlag.FLAG_HIDE_HP_BAR + EntityFlag.FLAG_NO_FLASH_ON_DAMAGE + EntityFlag.FLAG_NO_REWARD)
        npc.Velocity = Vector.Zero
        if rng:RandomFloat() <= 0.5 then
            sprite.FlipX = true
        end
        data.DontTouchBlasted = true
        data.Init = true
    end
    if game:GetNearestPlayer(npc.Position).Position:Distance(npc.Position) < 80 and not sprite:IsPlaying("Pulse") then
        sprite:Play("Pulse")
        sfx:Play(SoundEffect.SOUND_BEEP, 2, 0, false, 1.3, 0)
    end
    if data.ExplodeSoon then
        npc.StateFrame = npc.StateFrame + 1
    end
    if sprite:IsFinished("Pulse") or npc.StateFrame >= 2 then
        npc:Kill()
    end
    if npc:IsDead() then
        sfx:Stop(SoundEffect.SOUND_DEATH_BURST_SMALL)
        game:BombExplosionEffects(npc.Position, 10, 0, Color.Default, npc, 0.65, false, true)
    end
end

function mod:BlastedMineHurt(npc, amount, damageFlags, source)
    local sprite = npc:GetSprite()
    if mod:HasDamageFlag(DamageFlag.DAMAGE_EXPLOSION, damageFlags) then
        npc:GetData().ExplodeSoon = true
    elseif not sprite:IsPlaying("Pulse") then
        sprite:Play("Pulse")
        sfx:Play(SoundEffect.SOUND_BEEP, 2, 0, false, 1.3, 0)
    end
    return false
end
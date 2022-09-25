local mod = FiendFolio
local nilvector = Vector.Zero

function mod:wartyAI(npc)
    local d = npc:GetData()
    local sprite = npc:GetSprite();
    local target = npc:GetPlayerTarget()

    npc.Velocity = nilvector

    if npc.State == 4 then
        mod:spritePlay(sprite, "Idle")
        d.Explodable = true
        if not mod:isScare(npc) then
            npc.StateFrame = npc.StateFrame + 1
        end
        if (npc.StateFrame > 50 + d.waittime) and (math.random(20) == 1) and not mod:isScare(npc) then
            d.Explodable = false
            npc.State = 8
        end
    elseif npc.State == 8 then
        if sprite:IsFinished("Attack") then
            npc.State = 4
            npc.StateFrame = 0
            d.waittime = math.random(20)
        elseif sprite:IsEventTriggered("Shoot") then
            npc:PlaySound(SoundEffect.SOUND_BLOBBY_WIGGLE,1,2,false,1)
            mod.ShootBubble(npc, 6, npc.Position,mod:randomVecConfuse(npc,(target.Position-npc.Position):Resized(3)))
            d.Explodable = true
        else
            mod:spritePlay(sprite, "Attack")
        end
    elseif npc.State == 9 then
        if sprite:IsFinished("Stunned") then
            npc.State = 4
        else
            mod:spritePlay(sprite, "Stunned")
        end
    else
        npc.State = 4
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        d.waittime = math.random(20)
        npc.StateFrame = 100
    end
end

function mod:wartyHurt(npc, damage, flag, source)
    if source.Type == mod.FFID.Tech and flag & DamageFlag.DAMAGE_EXPLOSION ~= 0 then
        if npc:GetData().Explodable then
            npc:ToNPC().State = 9
        end
        return false
    end
end
local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:FleshSisternAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    if sprite:IsEventTriggered("Test") then
        npc.TargetPosition = npc.TargetPosition + RandomVector():Resized(mod:RandomInt(40,60))
        data.TriedShoot = false
    elseif sprite:IsEventTriggered("CheckShoot") then
        if not data.TriedShoot then
            data.ShitTheShat = true
            sprite:Play("Shoot")
        end
    end
    if data.ShitTheShat then
        npc.Velocity = npc.Velocity * 0.9
        if sprite:IsEventTriggered("Shoot") then
            local params = ProjectileParams()
            params.Spread = 1
            npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(10), 1, params)
            mod:PlaySound(SoundEffect.SOUND_WHEEZY_COUGH, npc, 0.9)
            local effect = Isaac.Spawn(1000,2,2,npc.Position,npc.Velocity,npc)
            effect.DepthOffset = npc.Position.Y * 1.25
            effect.Color = Color(1,1,1,0.8)
            effect.SpriteOffset = Vector(0,-20)
        end
        if sprite:IsFinished("Shoot") then
            npc.State = 3
            data.ShitTheShat = false
            data.TriedShoot = true
        end
        return true
    end
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc) --Debugging/documentation
    --local sprite = npc:GetSprite()
    --print(npc.TargetPosition.X.." "..npc.TargetPosition.Y.." "..npc.State)
end, EntityType.ENTITY_FLESH_MAIDEN)
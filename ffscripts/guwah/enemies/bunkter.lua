local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:BunkterAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    if not data.Init then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        sprite:Play("Idle closed")
        npc.SplatColor = mod.ColorDankBlackReal
        if npc.SubType == 0 then
            npc.StateFrame = 15
        elseif npc.SubType == 1 then
            npc.StateFrame = mod:RandomInt(90,150)
        elseif npc.SubType == 2 then
            npc.StateFrame = mod:RandomInt(180,240)
        else 
            npc.StateFrame = 1000
            data.DontCount = true
            if npc.SubType == 4 then
                npc.CanShutDoors = false
            end
        end
        npc.FlipX = (mod:RandomInt(0,1) == 1)
        data.Init = true
    end
    if npc.I1 == 1 then
        if not sprite:IsPlaying("Hop") then
            npc.Velocity = npc.Velocity * 0.75
        else
            npc.Velocity = npc.Velocity * 0.95
        end
        if sprite:IsFinished("Open") then
            sprite:Play("Idle open")
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            npc.StateFrame = mod:RandomInt(20,40)
            mod:SpawnBunkterTrash(npc)
        elseif sprite:IsFinished("Vomit") then
            sprite:Play("Idle open")
        elseif sprite:IsFinished("Hop begin") then
            data.HopCount = mod:RandomInt(2,6)
            sprite:Play("Hop")
        end
        if sprite:IsPlaying("Idle open") then
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                sprite:Play("Hop begin")
            end
        end
        if sprite:IsEventTriggered("hop") then
            npc:PlaySound(SoundEffect.SOUND_FETUS_LAND,1,0,false,0.8)
            if npc.Pathfinder:HasPathToPos(targetpos) then
                npc.Pathfinder:FindGridPath(targetpos, 2, 900, true)
            else
                npc.Velocity = RandomVector() * 3
            end
            mod:FlipSprite(sprite, npc.Position + npc.Velocity, npc.Position)
        elseif sprite:IsEventTriggered("check") then
            data.HopCount = data.HopCount - 1
            if data.HopCount <= 0 or (targetpos:Distance(npc.Position) < 100 and data.HopCount <= 2) then
                mod:FlipSprite(sprite, targetpos, npc.Position)
                sprite:Play("Vomit")
            end
        elseif sprite:IsEventTriggered("patoo") then
            data.Shooting = true
            mod:FlipSprite(sprite, targetpos, npc.Position)
            npc:PlaySound(SoundEffect.SOUND_GOODEATH,1,0,false,0.6)
            npc.V1 = (targetpos - npc.Position):Resized(3)
            npc.V2 = (targetpos - npc.Position):Resized(20)
            npc.StateFrame = 0
            local effect = Isaac.Spawn(1000,2,2,npc.Position,Vector.Zero,npc) 
            effect.Color = mod.ColorDankBlackReal
            if npc.FlipX then
                effect.SpriteOffset = Vector(10,-50)
            else
                effect.SpriteOffset = Vector(-10,-50)
            end
            effect.DepthOffset = npc.DepthOffset + 1
        elseif sprite:IsEventTriggered("stop") then
            --data.Shooting = false
        end
        if data.Shooting then
            if npc.StateFrame <= 8 then
                npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,0,false,1)
                for i = 1, 3 do
                    local params = ProjectileParams()
                    if rng:RandomFloat() <= 0.6 then
                        params.Color = mod.ColorDankBlackReal
                    else
                        params.Variant = mod:GetRandomElem(mod.TrashbaggerTable)
                    end
                    params.FallingSpeedModifier = mod:RandomInt(-10,-5) * (npc.StateFrame/2.5)
                    params.FallingAccelModifier = 2
                    params.HeightModifier = -50
                    npc:FireProjectiles(npc.Position + npc.V1:Resized(20), npc.V1:Rotated(mod:RandomInt(-20,20)), 0, params)
                end
            end
            local creep = Isaac.Spawn(1000, 26, 0, npc.Position + npc.V2, Vector.Zero, npc):ToEffect()
            creep:SetTimeout(200)
            creep.SpriteScale = creep.SpriteScale * 2
            creep:Update()
            local effect = Isaac.Spawn(1000, 2, 3, creep.Position, Vector.Zero, npc) 
            effect.Color = mod.ColorDankBlackReal
            npc.V1 = npc.V1:Resized(npc.V1:Length() + 1.2)
            npc.V2 = npc.V2:Resized(npc.V2:Length() + 20)
            npc.StateFrame = npc.StateFrame + 1
            if npc.StateFrame > 10 then
                data.Shooting = false
                npc.StateFrame = mod:RandomInt(15,35)
            end
        end
    else
        mod.QuickSetEntityGridPath(npc)
        mod.NegateKnockoutDrops(npc)
        if not data.DontCount then
            npc.StateFrame = npc.StateFrame - 1
        end
        if (npc.StateFrame <= 0 or mod.CanIComeOutYet()) and npc.SubType ~= 4 then
            sprite:Play("Open")
        end
        if sprite:IsEventTriggered("emerge") then
            npc.I1 = 1
            npc.CollisionDamage = 1
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR) 
            npc:PlaySound(SoundEffect.SOUND_FETUS_JUMP, 1, 0, false, 0.8)
        end
    end
    if npc:IsDead() then
        sfx:Play(SoundEffect.SOUND_MUSHROOM_POOF, 1.5, 0, false, 1.5)
        mod:SpawnBunkterTrash(npc)
    end
end

function mod:BunkterHurt(npc, amount, damageFlags, source)
    if npc.I1 ~= 1 and not mod:HasDamageFlag(DamageFlag.DAMAGE_EXPLOSION, damageFlags) then
        return false
    end
end

function mod:SpawnBunkterTrash(npc)
    if not npc:GetData().SpawnedTrash then
        local trash = Isaac.Spawn(mod.FF.BunkterTrash.ID, mod.FF.BunkterTrash.Var, mod.FF.BunkterTrash.Sub, npc.Position, Vector.Zero, npc) 
        trash:GetSprite():Play("Front Garbage")
        trash.DepthOffset = npc.DepthOffset + 1
        trash.FlipX = npc.FlipX
        trash = Isaac.Spawn(mod.FF.BunkterTrash.ID, mod.FF.BunkterTrash.Var, mod.FF.BunkterTrash.Sub, npc.Position, Vector.Zero, npc) 
        trash:GetSprite():Play("Back Garbage")
        trash.DepthOffset = npc.DepthOffset - 5
        trash.FlipX = npc.FlipX
        npc:GetData().SpawnedTrash = true
    end
end
local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:BubAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    mod.QuickSetEntityGridPath(npc)
    if not data.Init then
        if npc.SubType >= 5 then
            data.Head = mod:RandomInt(0,4)
        else
            data.Head = npc.SubType
        end
        if data.Head < 2 then
            npc.StateFrame = mod:RandomInt(100,150)
        end
        sprite:SetOverlayFrame("Head", data.Head)
        data.Init = true
    end
    if data.Head < 2 then
        if npc.StateFrame <= 0 and not sprite:IsPlaying("Shoot") then
            if data.Head == 0 then
                sprite:RemoveOverlay()
                sprite:Play("Shoot")
            elseif data.Head == 1 then
                EntityNPC.ThrowSpider(npc.Position, npc, npc.Position + Vector(mod:RandomInt(13, 17), 0):Rotated(mod:RandomAngle()), false, 0)
                mod:PlaySound(SoundEffect.SOUND_BOIL_HATCH, npc, mod:RandomInt(9,12) * 0.1, 0.45)
                npc.StateFrame = mod:RandomInt(100,150)
            end
        else
            npc.StateFrame = npc.StateFrame - 1
        end
        if sprite:IsEventTriggered("Shoot") then
            mod:FlipSprite(sprite, npc.Position, targetpos)
            local shootoffset
            if sprite.FlipX then
                shootoffset = Vector(-15,0)
            else
                shootoffset = Vector(15,0)
            end
            local params = ProjectileParams()
            params.Variant = 1
            params.FallingSpeedModifier = -25
            params.FallingAccelModifier = 1.2
            params.HeightModifier = -40
            npc:FireProjectiles(npc.Position + shootoffset, (targetpos - npc.Position):Resized(5), 0, params)
            mod:PlaySound(SoundEffect.SOUND_WHEEZY_COUGH, npc, mod:RandomInt(9,12) * 0.1)
            local effect = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, npc.Position + Vector(shootoffset.X, -40), Vector.Zero, nil):ToEffect()
            effect:GetData().longonly = true
            effect.Color = Color(0.5, 0.5, 0.5, 1)
            effect.DepthOffset = npc.Position.Y * 1.25
        elseif sprite:IsFinished("Shoot") then
            sprite:SetOverlayFrame("Head", data.Head)
            npc.StateFrame = mod:RandomInt(100,150)
        end
    end
    if not sprite:IsPlaying("Shoot") then
        local speed = 4
        local vel 
        if data.Head == 0 then
            if npc.Velocity:Length() > 1 then
                sprite:Play("WalkHori")
            else
                sprite:SetFrame("WalkHori", 0)
            end
            if mod:isScare(npc) then
                mod:FlipSprite(sprite, targetpos, npc.Position)
            else
                mod:FlipSprite(sprite, npc.Position, targetpos)
            end
        else
            if data.Head == 1 then
                speed = 3
            elseif data.Head == 3 then
                speed = 5
            end
            npc:AnimWalkFrame("WalkHori","WalkVert",1)
        end
        if mod:isScare(npc) then
            vel = (targetpos - npc.Position):Resized(-speed)
        elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
            vel = (targetpos - npc.Position):Resized(speed)
        else
            npc.Pathfinder:FindGridPath(targetpos, (speed * 0.1) + 0.2, 900, true)
        end
        if vel then
            npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.25)
        end
    else
        npc.Velocity = Vector.Zero
    end
    if npc:IsDead() then
        FiendFolio.BubDeathEffect(npc)
    end
end

function FiendFolio.BubDeathEffect(npc)
    if npc:GetData().Head == 2 then
        local target = npc:GetPlayerTarget()
        local targetpos = mod:confusePos(npc, target.Position)
        local chunk = Isaac.Spawn(mod.FF.TomaChunk.ID,mod.FF.TomaChunk.Var,mod.FF.TomaChunk.Sub,npc.Position,(targetpos - npc.Position):Resized(8),npc)
        chunk:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    elseif npc:GetData().Head == 3 then
        local params = ProjectileParams()
        params.FallingAccelModifier = 2
        for i = 1, mod:RandomInt(6, 10) do
            params.FallingSpeedModifier = mod:RandomInt(-30, -10) * 1.5
            params.Variant = mod:RandomInt(0,1)
            npc:FireProjectiles(npc.Position, Vector(30, 0):Rotated(mod:RandomAngle()):Resized(0.5 * mod:RandomInt(1,5)), 0, params)
        end
        EntityNPC.ThrowSpider(npc.Position, npc, npc.Position + Vector(mod:RandomInt(13, 17), 0):Rotated(mod:RandomAngle()), false, 0)
    elseif npc:GetData().Head == 4 then
        local body = Isaac.Spawn(280,0,0,npc.Position,npc.Velocity,npc):ToNPC()
        body:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        if npc:IsChampion() then
            body:MakeChampion(npc.InitSeed, npc:GetChampionColorIdx(), true)
            body.HitPoints = body.MaxHitPoints
        end
        body:GetSprite():LoadGraphics()
    end
end
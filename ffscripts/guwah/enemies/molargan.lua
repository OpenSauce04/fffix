local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:MolarganAI(npc, sprite, data)
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    if not data.Init then
        npc.SplatColor = mod.ColorDullGray
        data.Init = true
    end
    if sprite:IsOverlayPlaying("HeadAttack") then
        npc.Velocity = Vector.Zero
        sprite:SetFrame("WalkVert", 0)
        if sprite:GetOverlayFrame() == 15 and not data.Shooted then
            local bingo = (targetpos - npc.Position):Normalized() * math.min(250, (npc.Position - targetpos):Length())
            local target = mod:GetNearestPosOfCollisionClassOrLess(npc.Position + bingo, GridCollisionClass.COLLISION_NONE) + (RandomVector())
            local vec = (target - npc.Position) / 18
            Isaac.Spawn(mod.FF.FlyingOralid.ID,mod.FF.FlyingOralid.Var,mod.FF.FlyingOralid.Sub,npc.Position,vec,npc)
            mod:PlaySound(SoundEffect.SOUND_WHEEZY_COUGH, npc)
            local effect = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, npc.Position - Vector(0,25), Vector.Zero, nil):ToEffect()
            effect:GetData().longonly = true
            effect.Color = Color(0.5, 0.5, 0.5, 1)
            effect.DepthOffset = npc.Position.Y * 1.25
            data.Shooted = true
        end
    elseif sprite:IsOverlayFinished("HeadAttack") then
        data.Shooted = false
    end
    if npc:IsDead() then
        local params = ProjectileParams()
        params.Variant = 1
        npc:FireProjectiles(npc.Position, Vector(8,6), 9, params)
        params.FallingAccelModifier = 2
        for i = 1, mod:RandomInt(3, 6) do
            params.FallingSpeedModifier = mod:RandomInt(-30, -10) * 1.5
            npc:FireProjectiles(npc.Position, RandomVector():Resized(0.5 * mod:RandomInt(1,5)), 0, params)
        end
        for i = 1, mod:RandomInt(1,2) do
            local spider = EntityNPC.ThrowSpider(npc.Position, npc, npc.Position + RandomVector():Resized(mod:RandomInt(13, 17)), false, 0)
            spider:Morph(mod.FF.ThrownOralid.ID, mod.FF.ThrownOralid.Var, 0, spider:GetChampionColorIdx())
        end
        table.insert(mod.JamDeletions, {["Position"] = npc.Position, ["Duration"] = 1})
    end
end

function mod:FlyingOralidRender(effect, sprite, data, isPaused, isReflected)
    if not (isPaused or isReflected) then
        data.StateFrame = data.StateFrame or 2
        mod:spritePlay(sprite, "Fly")
        mod:FlipSprite(sprite, effect.Position, effect.Position + effect.Velocity)
        local curve = math.sin(math.rad(9 * data.StateFrame))
        local height = 0 - curve * 40
        sprite.Offset = Vector(0, height)
        if height >= 0 then
            effect.Visible = false
            effect:Remove()
            local oralid = Isaac.Spawn(mod.FF.Oralid.ID, mod.FF.Oralid.Var, 1, effect.Position, Vector.Zero, effect):ToNPC()
            oralid:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            oralid:GetSprite():Play("Appear")
            oralid:FireProjectiles(oralid.Position, Vector(10,0), 6, ProjectileParams())
            mod:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, npc, 1.5, 0.6)
            Isaac.Spawn(1000,2,0,oralid.Position + Vector(0,-1),Vector.Zero,oralid)
        else
            data.StateFrame = data.StateFrame + 0.5
        end
    end
end
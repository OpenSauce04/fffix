local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:CathyAI(npc, sprite, data)
    local room = game:GetRoom()
    if not data.Init then
        npc.SplatColor = mod.ColorLemonYellow
        data.Init = true
    end
    if sprite:IsFinished("Appear") then
        data.ICanWalk = true
    end
    if data.ICanWalk then
        data.newhome = data.newhome or mod:GetNewPosAligned(npc.Position)
        if npc.Position:Distance(data.newhome) < 20 or npc.Velocity:Length() < 0.3 or (not room:CheckLine(data.newhome,npc.Position,0,900,false,false)) or (mod:isConfuse(npc) and npc.StateFrame % 10 == 0) then
            data.newhome = mod:GetNewPosAligned(npc.Position)
        end
        local targvel = (data.newhome - npc.Position):Resized(3)
        npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.3)
        local shootvel = Vector(0, 0)
        local v = 7
        if npc.Velocity:Length() <= 0.1 then
            sprite:SetFrame("WalkDown", 0)
            shootvel = Vector(0,-v)
        else
            if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
                if npc.Velocity.X > 0 then
                    mod:spritePlay(sprite, "WalkRight")
                    shootvel = Vector(-v,0)
                else
                    mod:spritePlay(sprite, "WalkLeft")
                    shootvel = Vector(v,0)
                end
            else
                if npc.Velocity.Y > 0 then
                    mod:spritePlay(sprite, "WalkDown")
                    shootvel = Vector(0,-v)
                else
                    mod:spritePlay(sprite, "WalkUp")
                    shootvel = Vector(0,v)
                end
            end
            mod:spritePlay(sprite, anim)
        end
        if npc.FrameCount % 8 == 0 then
            local projectile = Isaac.Spawn(9,0,0,npc.Position,shootvel:Rotated(mod:RandomInt(-20,20)),npc):ToProjectile()
            projectile.FallingAccel = 0.3
            projectile.Color = mod.ColorPeepPiss
            local d = projectile:GetData()
            d.projType = "Peepisser"
            d.detail = "Pee"
            d.creepTimeout = 90
            d.water = room:HasWater()
            projectile:Update()
            local effect = Isaac.Spawn(1000,2,1,npc.Position,Vector.Zero,npc) 
            effect.Color = mod.ColorPeepPiss
            mod:PlaySound(SoundEffect.SOUND_TEARS_FIRE, npc, 1.3, 0.5)
        end
    end
    if npc:IsDead() then
        sfx:Stop(SoundEffect.SOUND_DEATH_BURST_SMALL)
		sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL, 1.5, 0, false, 1.5)
    end
end
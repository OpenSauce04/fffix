local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:AleyaFirePlaceInit(npc)
    npc:GetData().IsAleyaFire = true
end

function mod:AleyaFirePlaceAI(npc, sprite, data)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()
    npc.SubType = mod.FF.AleyaFirePlace.Sub
    if not data.Init then
        if not data.AnimSuffix then
            rng:SetSeed(npc.InitSeed, 0)
            data.AnimSuffix = mod:RandomInt(1,3,rng)
            if data.AnimSuffix == 1 then
                data.AnimSuffix = ""
            end
        end
        local anim = "Flickering"..data.AnimSuffix
        mod:spritePlay(sprite, anim)
        data.clearpoofs = 0
        data.Init = true
    end  
    if sprite:GetOverlayAnimation() == "Shoot" then
        if not data.shooting and sprite:GetOverlayFrame() > 0 then
            sprite:RemoveOverlay()
        elseif sprite:IsOverlayFinished("Shoot") then
            sprite:RemoveOverlay()
            data.shooting = false
        end
    end
    if data.tookhit then
        local rng = npc:GetDropRNG()
        local dmg = 1
        if rng:RandomFloat() <= 0.33 then
            dmg = 2
        end
        npc.HitPoints = npc.HitPoints - dmg
        if npc.HitPoints <= 1 then
            mod:ExtinguishAleyaFire(npc)
        else
            npc:GetSprite():PlayOverlay("Shoot") --Only way to update the scaling of the fire lol!
        end
        data.tookhit = false
    end
    if npc.State == 8 then
        if npc.Variant == mod.FF.AleyaFirePlace.Var then
            local anim = "Flickering"..data.AnimSuffix
            mod:spritePlay(sprite, anim)
            if data.shootdelay then
                data.shootdelay = data.shootdelay - 1
                if data.shootdelay <= 0 then
                    sprite:PlayOverlay("Shoot")
                    data.shooting = true
                    data.shootdelay = nil
                elseif data.shootdelay == 19 then
                    local effect = Isaac.Spawn(mod.FF.ReverseBloodPoof.ID, mod.FF.ReverseBloodPoof.Var, mod.FF.ReverseBloodPoof.Sub, npc.Position, Vector.Zero, npc)
                    effect:GetData().NoShooting = true
                    effect.SpriteOffset = Vector(0,-10)
                    effect.DepthOffset = npc.Position.Y * 1.25
                    effect.Color = mod.ColorMinMinFireJuicier
                end
            end
        else
            mod:ConvertToAleyaFire(npc)
            mod:ExtinguishAleyaFire(npc)
        end
    elseif npc.State == 3 then
        if not data.deathinit then
            if room:GetFrameCount() > 1 then
                sfx:Play(SoundEffect.SOUND_STEAM_HALFSEC)
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                data.finishedextinguish = false
            else
                data.finishedextinguish = true
            end
            data.deathinit = true
        end
        if data.finishedextinguish then
            mod:spritePlay(sprite, "NoFire"..data.AnimSuffix)
        else
            if sprite:IsFinished("Dissapear"..data.AnimSuffix) then
                data.finishedextinguish = true
            else
                mod:spritePlay(sprite, "Dissapear"..data.AnimSuffix)
            end
        end
    end
end

function mod:AleyaFirePlaceHurt(npc, amount, damageFlags, source)
    local data = npc:GetData()
    local sprite = npc:GetSprite()
    if mod:HasDamageFlag(damageFlags, DamageFlag.DAMAGE_EXPLOSION) then
        npc.State = 3
    else
        data.tookhit = true
    end
end

function mod:ExtinguishAleyaFire(npc)
    npc = npc:ToNPC()
    local data = npc:GetData()
    npc.State = 3
    npc.HitPoints = 1
    data.shooting = false
    data.shootdelay = nil
end
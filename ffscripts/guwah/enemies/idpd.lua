local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

--they turned the police into a gender
local function GetGender(npc)
    return (npc.InitSeed % 2 == 0 and "Male" or "Female")
end

local function GetIDPDTarget(npc)
    local fishe = mod:GetNearestThing(npc.Position, mod.FF.FishNuclearThrone.ID, mod.FF.FishNuclearThrone.Var)
    if fishe then
        return fishe
    else
        return npc:GetPlayerTarget()
    end
end

----The POPO----
function mod:IDPDGruntAI(npc, sprite, data)
    local targetpos = mod:confusePos(npc, GetIDPDTarget(npc).Position)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()

    if not data.Init then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
        npc.SpriteOffset = Vector(0,-2)
        npc.StateFrame = mod:RandomInt(30,60,rng)

        data.GunAngle = 0
        data.GunKickback = 0.1
        local gun = Isaac.Spawn(mod.FF.IDPDGun.ID, mod.FF.IDPDGun.Var, mod.FF.IDPDGun.Sub, npc.Position, Vector.Zero, npc)
        gun:GetSprite():Play("Grunt")
        gun.Parent = npc
        gun:Update()

        mod:PlaySound(mod.Sounds["IDPDGruntAppear"..GetGender(npc)],npc)

        data.ShootCooldown = mod:RandomInt(30,75,rng)
        data.GrenadeCooldown = 30
        data.BulletsToShoot = 0
        data.State = data.State or "Idle"
        data.Init = true
    end

    if data.State == "Idle" then
        if not sprite:IsPlaying("Hurt") then
            mod:spritePlay(sprite, "Idle")
        end
        npc.Velocity = npc.Velocity * 0.7
        if room:CheckLine(npc.Position,npc.TargetPosition,3,1,false,false) and npc.Position:Distance(targetpos) <= 250 then
            npc.StateFrame = npc.StateFrame - 2
        else
            npc.StateFrame = npc.StateFrame - 1
        end

        if npc.StateFrame <= 0 then
            local tear = mod:GetNearestThing(npc.Position, 2)
            local boolet = mod:GetNearestThing(npc.Position, 9, -1, -1, function(_, boolet, position) return boolet:ToProjectile():HasProjectileFlags(ProjectileFlags.HIT_ENEMIES) end)
            npc.TargetPosition = mod:FindRandomValidPathPosition(npc, 3, 40, 200)
            mod:FlipSprite(sprite, npc.Position, npc.TargetPosition)
            if data.BulletsToShoot <= 0 then
                data.GunAngle = (npc.TargetPosition - npc.Position):GetAngleDegrees()
            end
            if npc.Position:Distance(targetpos) <= 100 
            or (boolet and npc.Position:Distance(boolet.Position) <= 100)
            or (room:CheckLine(npc.Position,npc.TargetPosition,3,1,false,false) and rng:RandomFloat() <= 0.5) then
                mod:PlaySound(mod.Sounds.FishRoll,npc)
                npc.Velocity = (npc.TargetPosition - npc.Position):Resized(10)
                data.State = "Roll"
            else
                data.State = "Walk"
            end
        end
    elseif data.State == "Walk" then
        if not sprite:IsPlaying("Hurt") then
            mod:spritePlay(sprite, "Walk")
        end

        if mod:isScare(npc) and npc.Position:Distance(targetpos) <= 200 then
            npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position - targetpos):Resized(4), 0.5)
        elseif room:CheckLine(npc.Position,npc.TargetPosition,0,1,false,false) then
            npc.Velocity = mod:Lerp(npc.Velocity, (npc.TargetPosition - npc.Position):Resized(4), 0.3)
        else
            npc.Pathfinder:FindGridPath(npc.TargetPosition, 0.7, 900, true)
        end 

        if npc.Position:Distance(npc.TargetPosition) <= 15 then
            npc.StateFrame = mod:RandomInt(30,60,rng)
            data.State = "Idle"
        end
    elseif data.State == "Roll" then
        mod:spritePlay(sprite, "Roll")

        if npc.FrameCount % 3 == 0 then
            local effect = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, npc.Position, npc.Velocity:Rotated(mod:RandomInt(160,200,rng)):Resized(4), npc)
            effect.SpriteScale = Vector(0.7,0.7)
            effect.Color = Color(1,1,0.8,0.4)
            effect:GetData().longonly = true
            effect:Update()
        end

        npc.SpriteRotation = npc.SpriteRotation + 30
        if npc.SpriteRotation > 359 then
            npc.StateFrame = mod:RandomInt(30,60,rng)
			npc.SpriteRotation = 0
            data.State = "Idle"
		end
    end

    data.GunKickback = mod:Lerp(data.GunKickback, 0.1, 0.5)
    data.ShootCooldown = data.ShootCooldown - 1
    data.GrenadeCooldown = data.GrenadeCooldown - 1
    if data.ShootCooldown <= 0 then
        if room:CheckLine(npc.Position,targetpos,3,1,false,false) then
            data.ShootCooldown = mod:RandomInt(30,75,rng)
            data.GunAngle = (targetpos - npc.Position):GetAngleDegrees()
            data.BulletsToShoot = mod:RandomInt(1,4,rng)
        elseif data.GrenadeCooldown <= 0 and npc.Position:Distance(targetpos) <= 300 and rng:RandomFloat() <= 0.065 then
            local grenade = Isaac.Spawn(mod.FF.IDPDGrenade.ID, mod.FF.IDPDGrenade.Var, 0, npc.Position, (targetpos - npc.Position):Resized(20), npc)
            grenade:Update()
            data.GunAngle = (targetpos - npc.Position):GetAngleDegrees()
            data.GunKickback = -5
            data.ShootCooldown = mod:RandomInt(30,75,rng)
            data.GrenadeCooldown = mod:RandomInt(90,150,rng)
            if data.State ~= "Roll" then
                mod:FlipSprite(sprite, npc.Position, targetpos)
            end
            mod:PlaySound(mod.Sounds.IDPDThrowGrenade,npc)
        else
            data.ShootCooldown = mod:RandomInt(5,15,rng)
        end
    end

    if data.BulletsToShoot > 0 then
        data.GunAngle = mod:LerpAngleDegrees(Vector(1,0):Rotated(data.GunAngle), (targetpos - npc.Position), 0.25)
        if npc.FrameCount % 3 == 0 then
            if room:CheckLine(npc.Position,targetpos,3,1,false,false) then
                local params = ProjectileParams()
                params.Variant = mod.FF.IDPDProjectile.Var
                params.BulletFlags = ProjectileFlags.HIT_ENEMIES
                params.HeightModifier = 20
                local vec = Vector(12,0):Rotated(data.GunAngle + mod:RandomInt(-2,2,rng))
                npc:FireProjectiles(npc.Position + npc.Velocity + vec:Resized(3), vec, 0, params)
                data.GunKickback = -5
                data.BulletsToShoot = data.BulletsToShoot - 1
                if data.State ~= "Roll" then
                    mod:FlipSprite(sprite, npc.Position, targetpos)
                end
                mod:PlaySound(mod.Sounds.IDPDGunFire,npc)
            else
                data.BulletsToShoot = 0
            end
        end
    end
end

function mod:IDPDInspectorAI(npc, sprite, data)
    local targetpos = mod:confusePos(npc, GetIDPDTarget(npc).Position)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()

    if not data.Init then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
        npc.SpriteOffset = Vector(0,-2)
        npc.StateFrame = mod:RandomInt(30,60,rng)
        sprite:SetOverlayRenderPriority(true)

        data.GunAngle = 0
        data.GunKickback = 0.1
        local gun = Isaac.Spawn(mod.FF.IDPDGun.ID, mod.FF.IDPDGun.Var, mod.FF.IDPDGun.Sub, npc.Position, Vector.Zero, npc)
        gun:GetSprite():Play("Inspector")
        gun.Parent = npc
        gun:Update()

        mod:PlaySound(mod.Sounds["IDPDInspectorAppear"..GetGender(npc)],npc)

        data.ShootCooldown = mod:RandomInt(30,75,rng)
        data.GrenadeCooldown = 30
        data.Telekinesis = 0
        data.State = "Idle"
        data.Init = true
    end

    if data.State == "Idle" then
        if not sprite:IsPlaying("Hurt") then
            mod:spritePlay(sprite, "Idle")
        end
        npc.Velocity = npc.Velocity * 0.7
        npc.StateFrame = npc.StateFrame - 1

        if (npc.StateFrame <= 0 and not sprite:IsOverlayPlaying("Telekinesis")) or npc.StateFrame <= -60 then
            npc.TargetPosition = mod:FindRandomValidPathPosition(npc, 3, 40, 200)
            mod:FlipSprite(sprite, npc.Position, npc.TargetPosition)
            data.GunAngle = (npc.TargetPosition - npc.Position):GetAngleDegrees()
            data.State = "Walk"
        end
    elseif data.State == "Walk" then
        if not sprite:IsPlaying("Hurt") then
            mod:spritePlay(sprite, "Walk")
        end

        if mod:isScare(npc) and npc.Position:Distance(targetpos) <= 200 then
            npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position - targetpos):Resized(4), 0.5)
        elseif room:CheckLine(npc.Position,npc.TargetPosition,0,1,false,false) then
            npc.Velocity = mod:Lerp(npc.Velocity, (npc.TargetPosition - npc.Position):Resized(4), 0.3)
        else
            npc.Pathfinder:FindGridPath(npc.TargetPosition, 0.7, 900, true)
        end 

        if npc.Position:Distance(npc.TargetPosition) <= 15 then
            npc.StateFrame = mod:RandomInt(30,60,rng)
            data.State = "Idle"
        end
    end

    data.GunKickback = mod:Lerp(data.GunKickback, 0.1, 0.5)
    data.ShootCooldown = data.ShootCooldown - 1
    data.GrenadeCooldown = data.GrenadeCooldown - 1
    if data.ShootCooldown <= 0 then
        if room:CheckLine(npc.Position,targetpos,3,1,false,false) and targetpos:Distance(npc.Position) <= 250 then
            data.ShootCooldown = mod:RandomInt(30,75,rng)
            data.GunAngle = (targetpos - npc.Position):GetAngleDegrees()
            local params = ProjectileParams() 
            params.BulletFlags = ProjectileFlags.HIT_ENEMIES | ProjectileFlags.BOUNCE
            params.Variant = mod.FF.IDPDSlugProjectile.Var
            params.HeightModifier = 20
            local vec = Vector(20,0):Rotated(data.GunAngle + mod:RandomInt(-2,2,rng))
            npc:FireProjectiles(npc.Position + npc.Velocity + vec:Resized(3), vec, 0, params)
            data.GunKickback = -10
            mod:FlipSprite(sprite, npc.Position, targetpos)
            mod:PlaySound(mod.Sounds.IDPDGunFire,npc)
        elseif data.GrenadeCooldown <= 0 and npc.Position:Distance(targetpos) <= 300 and rng:RandomFloat() <= 0.065 then
            local grenade = Isaac.Spawn(mod.FF.IDPDGrenade.ID, mod.FF.IDPDGrenade.Var, 0, npc.Position, (targetpos - npc.Position):Resized(20), npc)
            grenade:Update()
            data.GunAngle = (targetpos - npc.Position):GetAngleDegrees()
            data.GunKickback = -10
            data.ShootCooldown = mod:RandomInt(30,75,rng)
            data.GrenadeCooldown = mod:RandomInt(90,150,rng)
            mod:FlipSprite(sprite, npc.Position, targetpos)
            mod:PlaySound(mod.Sounds.IDPDThrowGrenade,npc)
        else
            data.ShootCooldown = mod:RandomInt(5,15,rng)
        end
    end

    if npc.FrameCount > 30 and (targetpos:Distance(npc.Position) > 250 or not room:CheckLine(npc.Position,targetpos,3,1,false,false)) then
        if data.State == "Idle" then
            if data.Telekinesis <= 0 then
                mod:PlaySound(mod.Sounds["IDPDInspectorTeleStart"..GetGender(npc)],npc)
            end
            data.Telekinesis = 15
        end
    else
        data.Telekinesis = data.Telekinesis - 1
        if data.Telekinesis == 0 then
            mod:PlaySound(mod.Sounds["IDPDInspectorTeleEnd"..GetGender(npc)],npc)
        end
    end

    if data.Telekinesis > 0 then
        mod:spriteOverlayPlay(sprite, "Telekinesis")
    
        for _, player in pairs(Isaac.FindInRadius(npc.Position, 400, EntityPartition.PLAYER)) do
            player.Velocity = mod:Lerp(player.Velocity, (npc.Position - player.Position):Resized(8), 0.05)
        end
        for _, tear in pairs(Isaac.FindInRadius(npc.Position, 100, EntityPartition.TEAR)) do
            tear.Velocity = mod:Lerp(tear.Velocity, (tear.Position - npc.Position):Resized(5), 0.05)
        end
    else
        sprite:RemoveOverlay()
    end
end

function mod:IDPDShielderAI(npc, sprite, data)
    local targetpos = mod:confusePos(npc, GetIDPDTarget(npc).Position)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()

    if not data.Init then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
        npc.SpriteOffset = Vector(0,-2)
        npc.StateFrame = mod:RandomInt(30,60,rng)

        data.GunAngle = 0
        data.GunKickback = 0.1
        local gun = Isaac.Spawn(mod.FF.IDPDGun.ID, mod.FF.IDPDGun.Var, mod.FF.IDPDGun.Sub, npc.Position, Vector.Zero, npc)
        gun:GetSprite():Play("Shielder")
        gun.Parent = npc
        gun:Update()

        mod:PlaySound(mod.Sounds["IDPDShielderAppear"..GetGender(npc)],npc)

        data.ShootCooldown = mod:RandomInt(30,75,rng)
        data.ShieldCooldown = 60
        data.BulletsToShoot = 0
        data.State = "Idle"
        data.Init = true
    end

    if data.State == "Idle" then
        if not sprite:IsPlaying("Hurt") then
            mod:spritePlay(sprite, "Idle")
        end
        npc.Velocity = npc.Velocity * 0.7
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 and data.BulletsToShoot <= 0 then
            npc.TargetPosition = mod:FindRandomValidPathPosition(npc, 3, 40, 200)
            mod:FlipSprite(sprite, npc.Position, npc.TargetPosition)
            data.GunAngle = (npc.TargetPosition - npc.Position):GetAngleDegrees()
            data.State = "Walk"
        end
    elseif data.State == "Walk" then
        if not sprite:IsPlaying("Hurt") then
            mod:spritePlay(sprite, "Walk")
        end

        if mod:isScare(npc) and npc.Position:Distance(targetpos) <= 200 then
            npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position - targetpos):Resized(4), 0.5)
        elseif room:CheckLine(npc.Position,npc.TargetPosition,0,1,false,false) then
            npc.Velocity = mod:Lerp(npc.Velocity, (npc.TargetPosition - npc.Position):Resized(4), 0.3)
        else
            npc.Pathfinder:FindGridPath(npc.TargetPosition, 0.7, 900, true)
        end 

        if npc.Position:Distance(npc.TargetPosition) <= 15 then
            npc.StateFrame = mod:RandomInt(30,60,rng)
            data.State = "Idle"
        end
    elseif data.State == "ShieldStart" then
        if sprite:IsOverlayFinished("ShieldAppear") then
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                data.State = "ShieldEnd"
                data.ShieldActive = false
                npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            end
        elseif sprite:GetOverlayFrame() == 27 then
            data.ShieldActive = true
            npc.StateFrame = 90
            npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        else
            mod:spriteOverlayPlay(sprite, "ShieldAppear")
        end
    elseif data.State == "ShieldEnd" then
        npc.Velocity = npc.Velocity * 0.7
        if sprite:IsOverlayFinished("ShieldEnd") then
            sprite:RemoveOverlay()
            npc.StateFrame = mod:RandomInt(30,60,rng)
            data.Shielding = false
            data.State = "Idle"
        else
            mod:spriteOverlayPlay(sprite, "ShieldEnd")
        end
    end

    data.GunKickback = mod:Lerp(data.GunKickback, 0.1, 0.5)
    data.ShootCooldown = data.ShootCooldown - 1
    if data.ShootCooldown <= 0 and not data.Shielding then
        if room:CheckLine(npc.Position,targetpos,3,1,false,false) then
            data.ShootCooldown = mod:RandomInt(60,120,rng)
            data.GunAngle = (targetpos - npc.Position):GetAngleDegrees()
            data.BulletsToShoot = 8
        else
            data.ShootCooldown = mod:RandomInt(5,15,rng)
        end
    end

    if data.BulletsToShoot > 0 then
        if npc.FrameCount % 3 == 0 then
            local params = ProjectileParams()
            params.Variant = mod.FF.IDPDProjectile.Var
            params.BulletFlags = ProjectileFlags.HIT_ENEMIES
            params.HeightModifier = 20
            local vec = Vector(12,0):Rotated(data.GunAngle + mod:RandomInt(-7,7,rng))
            npc:FireProjectiles(npc.Position + npc.Velocity + vec:Resized(3), vec, 0, params)
            data.GunKickback = -5
            data.BulletsToShoot = data.BulletsToShoot - 1
            mod:FlipSprite(sprite, npc.Position, targetpos)
            mod:PlaySound(mod.Sounds.IDPDGunFire,npc)
        end
    end

    if data.Shielding then
        npc.Velocity = npc.Velocity * 0.7
        if not sprite:IsPlaying("Hurt") then
            mod:spritePlay(sprite, "Idle")
        end
        npc.Velocity = Vector.Zero
    else
        data.ShieldCooldown = data.ShieldCooldown - 1
    end
end

function mod:IDPDColl(npc, collider)
    if npc:GetData().ShieldActive then
        if collider:ToTear() then
            mod:PlaySound(mod.Sounds.IDPDShieldDeflect,npc)
            local tear = collider:ToTear()
            local proj = Isaac.Spawn(9, 0, 0, tear.Position, tear.Velocity:Rotated(180), npc):ToProjectile()
            collider:Remove()
            return true
        end
    end
end

function mod:IDPDHurt(npc, amount, damageFlags, source)
    local data = npc:GetData()

    if npc.Variant == mod.FF.IDPDGrunt.Var then
        if npc.HitPoints - amount > 0 then
            mod:PlaySound(mod.Sounds["IDPDGruntHurt"..GetGender(npc)],npc)
            if data.State ~= "Roll" then
                npc:GetSprite():Play("Hurt", true)
            end
        end
    elseif npc.Variant == mod.FF.IDPDInspector.Var then
        if npc.HitPoints - amount > 0 then
            mod:PlaySound(mod.Sounds["IDPDInspectorHurt"..GetGender(npc)],npc)
            npc:GetSprite():Play("Hurt", true)
        end
    elseif npc.Variant == mod.FF.IDPDShielder.Var then
        if data.ShieldActive and (source.Type == 2 or source.Type == 9) then
            return false
        elseif npc.HitPoints - amount > 0 then
            npc:GetSprite():Play("Hurt", true)
            if data.ShieldCooldown <= 0 and data.BulletsToShoot <= 0 and not data.Shielding then
                data.State = "ShieldStart"
                data.Shielding = true
                data.ShieldCooldown = 210
                mod:PlaySound(mod.Sounds["IDPDShielderShield"..GetGender(npc)],npc)
            else
                mod:PlaySound(mod.Sounds["IDPDShielderHurt"..GetGender(npc)],npc)
            end
        end
    end
end

function mod:IDPDDeath(npc)
    if npc.Variant == mod.FF.IDPDGrunt.Var then
        mod:PlaySound(mod.Sounds["IDPDGruntDeath"..GetGender(npc)],npc)
    elseif npc.Variant == mod.FF.IDPDInspector.Var then
        mod:PlaySound(mod.Sounds["IDPDInspectorDeath"..GetGender(npc)],npc)
    elseif npc.Variant == mod.FF.IDPDShielder.Var then
        mod:PlaySound(mod.Sounds["IDPDShielderDeath"..GetGender(npc)],npc)
    end

    local effect = Isaac.Spawn(mod.FF.IDPDCorpse.ID, mod.FF.IDPDCorpse.Var, mod.FF.IDPDCorpse.Sub, npc.Position, Vector.Zero, npc)
    effect:GetSprite().FlipX = npc:GetSprite().FlipX
    effect:GetSprite():Load(npc:GetSprite():GetFilename(), true)
    effect:GetSprite():Play("Death", true)
end

----Projectiles----
function mod:IDPDGrenade(npc, sprite, data)
    local rng = npc:GetDropRNG()

    if not data.Init then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_REWARD)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        npc.StateFrame = 90
        data.Init = true
    end

    npc.SpriteRotation = npc.Velocity:GetAngleDegrees()
    npc.StateFrame = npc.StateFrame - 1
    if npc.StateFrame <= 0 then
        Isaac.Spawn(mod.FF.IDPDExplosion.ID,mod.FF.IDPDExplosion.Var,mod.FF.IDPDExplosion.Sub,npc.Position,Vector.Zero,npc.SpawnerEntity)
        npc:Remove()
    end

    if npc:CollidesWithGrid() then
        data.SlowDown = true
    end
    if data.SlowDown then
        npc.Velocity = npc.Velocity * 0.8
    else
        npc.Velocity = npc.Velocity * 0.95
    end

    if npc.StateFrame <= 30 then
        mod:spritePlay(sprite, "Blink")
        if npc.StateFrame == 10 then
            mod:PlaySound(mod.Sounds.IDPDGrenadeBeep)
        end
    else
        mod:spritePlay(sprite, "Idle")
    end

    if data.Primed then
        if npc.FrameCount % 2 == 0 then
            local vec = RandomVector() * 60
            Isaac.Spawn(mod.FF.IDPDParticle.ID, mod.FF.IDPDParticle.Var, mod.FF.IDPDParticle.Sub, npc.Position + vec, vec / -9, npc) 
        end

        for _, player in pairs(Isaac.FindInRadius(npc.Position, 300, EntityPartition.PLAYER)) do
            player.Velocity = mod:Lerp(player.Velocity, (npc.Position - player.Position):Resized(8), 0.05)
        end
    elseif npc.Velocity:Length() <= 0.1 then
        data.Primed = true
        mod:PlaySound(mod.Sounds.IDPDGrenadePrime)
    end
end

function mod:IDPDProjectile(projectile, sprite, data)
    projectile.FallingSpeed = 0
    projectile.FallingAccel = -0.1
    projectile.SpriteRotation = projectile.Velocity:GetAngleDegrees()
    mod:spritePlay(sprite, "Shoot")
end

function mod:IDPDProjectileDeath(projectile, sprite)
    local vec = RandomVector()
    for i = 0, 240, 120 do
        local particle = Isaac.Spawn(mod.FF.IDPDParticle.ID, mod.FF.IDPDParticle.Var, mod.FF.IDPDParticle.Sub, projectile.Position, vec:Rotated(i + mod:RandomInt(-30,30)) * mod:RandomInt(1,3), projectile) 
        particle.SpriteOffset = projectile.PositionOffset
        particle:GetData().AltAnim = true
        particle:Update()
    end
end

function mod:IDPDSlugProjectile(projectile, sprite, data)
    projectile.FallingSpeed = 0
    projectile.FallingAccel = -0.1
    projectile.SpriteRotation = projectile.Velocity:GetAngleDegrees()
    mod:spritePlay(sprite, "Shoot")

    projectile.CollisionDamage = 2
    projectile.Velocity = projectile.Velocity:Resized(projectile.Velocity:Length() - 1)
    if projectile.Velocity:Length() <= 2 then
        projectile:Die()
    end
end

function mod:IDPDSlugDeath(projectile, sprite)
    local poof = Isaac.Spawn(mod.FF.IDPDSlugPoof.ID, mod.FF.IDPDSlugPoof.Var, mod.FF.IDPDSlugPoof.Sub, projectile.Position, Vector.Zero, projectile) 
    poof.PositionOffset = projectile.PositionOffset
    poof.SpriteRotation = projectile.SpriteRotation
    poof:Update()
end

----Effects----
function mod:IDPDPortal(effect, sprite, data)
    if not data.Init then
        mod:PlaySound(mod.Sounds.IDPDPortal)
        effect.Visible = false
        effect.DepthOffset = -5000
        data.State = "Warn"
        data.Timer = 60
        data.Init = true
    end

    if data.State == "Warn" then
        if effect.FrameCount % 2 == 0 then
            local vec = RandomVector() * 60
            Isaac.Spawn(mod.FF.IDPDParticle.ID, mod.FF.IDPDParticle.Var, mod.FF.IDPDParticle.Sub, effect.Position + vec, vec / -9, effect) 
        end

        data.Timer = data.Timer - 1
        if data.Timer <= 0 then
            effect.Visible = true
            sprite:Play("Appear", true)
            data.State = "Appear"
        end
    elseif data.State == "Appear" then
        if sprite:IsFinished("Appear") then
            data.Timer = 30
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Spawn") then --SPAWN THE POPO
            local level = game:GetLevel()
            local choices = {mod.FF.IDPDGrunt.Var}

            if level:IsAscent() or level:GetStage() >= 3 then
                table.insert(choices, mod.FF.IDPDInspector.Var)
            end
            if level:IsAscent() or level:GetStage() >= 5 then
                table.insert(choices, mod.FF.IDPDShielder.Var)
            end

            local var = mod:GetRandomElem(choices)
            if var == mod.FF.IDPDGrunt.Var then
                local vec = RandomVector() * 10
                for i = 0, 180, 180 do
                    local angle = i + mod:RandomInt(-30,30)
                    local popo = Isaac.Spawn(mod.FFID.GuwahJoke, var, 0, effect.Position + vec:Rotated(angle):Resized(15), vec:Rotated(angle), effect):ToNPC()
                    mod:FlipSprite(popo:GetSprite(), popo.Position, popo.Position + popo.Velocity)
                    popo:GetData().State = "Roll"
                    popo:GetData().GunAngle = popo.Velocity:GetAngleDegrees()
                    mod:PlaySound(mod.Sounds.FishRoll,popo)
                end
            else
                local popo = Isaac.Spawn(mod.FFID.GuwahJoke, var, 0, effect.Position, RandomVector() * 5, effect)
            end
        else
            mod:spritePlay(sprite, "Appear")
        end
    elseif data.State == "Idle" then
        mod:spritePlay(sprite, "Idle")
        data.Timer = data.Timer - 1
        if data.Timer <= 0 then
            data.State = "Disappear"
        end
    elseif data.State == "Disappear" then
        if sprite:IsFinished("Disappear") then
            effect:Remove()
        else
            mod:spritePlay(sprite, "Disappear")
        end
    end
end

function mod:IDPDGun(effect, sprite, data)
    if not data.Init then
        effect.SpriteOffset = Vector(0,-5)
        data.Init = true
    end

    if mod:IsReallyDead(effect.Parent) then
        effect:Remove()
    else
        if effect.Parent:GetData().ShieldActive then
            effect.Visible = false
        else
            effect.Visible = true
        end
        local angle = mod:NormalizeDegreesTo360(effect.Parent:GetData().GunAngle) 
        if angle > 90 and angle < 270 then
            if angle < 180 then
                angle = 270 - (angle - 270)
            else
                angle = 90 - (angle - 90)
            end
            sprite.FlipX = true
        else
            sprite.FlipX = false
        end
        effect.SpriteRotation = angle
        effect.TargetPosition = effect.Parent.Position + effect.Parent.Velocity + Vector(effect.Parent:GetData().GunKickback,0):Rotated(effect.Parent:GetData().GunAngle)
        effect.Velocity = effect.TargetPosition - effect.Position
    end
end

function mod:IDPDParticle(effect, sprite, data)
    local anim = "Grow"
    if data.AltAnim then
        anim = "Shrink"
    end

    if sprite:IsFinished(anim) then
        effect:Remove()
    else
        mod:spritePlay(sprite, anim)
    end
end

function mod:IDPDSlugPoof(effect, sprite, data)
    if sprite:IsFinished("Die") then
        effect:Remove()
    else
        mod:spritePlay(sprite, "Die")
    end
end

function mod:IDPDExplosion(effect, sprite, data)
    if not data.Init then
        mod:DestroyNearbyGrid(effect, 80)
        mod:DamagePlayersInRadius(effect.Position, 80, 2, effect.SpawnerEntity, DamageFlag.DAMAGE_EXPLOSION)
        mod:PlaySound(mod.Sounds.IDPDExplosion)

        for i = 1, 6 do 
            local effect = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, effect.Position, RandomVector() * mod:RandomInt(4,10), effect)
            effect.SpriteScale = Vector(0.7,0.7)
            effect.Color = Color(0.7,0.7,1,1)
            effect:GetData().longonly = true
            effect:Update()
        end
        data.Init = true
    end

    if sprite:IsFinished("Explode") then
        effect:Remove()
    else
        mod:spritePlay(sprite, "Explode")
    end
end
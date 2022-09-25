local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local rapidFireOpalOffsets = {
[1] = {0,0},
[2] = {-10,20},
[3] = {-15,15},
[4] = {-15,10},
[5] = {-20,10},
[6] = {-25,10},
[7] = {-30,10},
[8] = {-35,10},
[9] = {-40,10},
[10] = {-45,10},
}

function mod:friendlyRapidFireOpalDrawn(player, d)
	if d.rapidFireOpalAmmo then
        local gunCount = 1
        gunCount = gunCount + (1 * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20)) + (1 * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_THE_WIZ)) + (2 * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_INNER_EYE)) + (3 * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MUTANT_SPIDER))
        gunCount = math.min(gunCount, 10)
        if (not d.rapidFireOpalGun) then
            sfx:Play(mod.Sounds.GunDraw,0.7,0,false,math.random(90,110)/100)
        end
        d.rapidFireOpalGun = d.rapidFireOpalGun or {}
        if (#d.rapidFireOpalGun == 0) or (d.rapidFireOpalGun and (not d.rapidFireOpalGun[1]:Exists())) then
            for i = 1, math.max(gunCount, #d.rapidFireOpalGun) do
                if not d.rapidFireOpalGun[i] or (d.rapidFireOpalGun[i] and not d.rapidFireOpalGun[i]:Exists()) then
                    local gun = Isaac.Spawn(1000, mod.FF.GolemsAssaultRifle.Var, mod.FF.GolemsAssaultRifle.Sub, player.Position, nilvector, player)
                    d.rapidFireOpalGun[i] = gun
                    d.rapidFireOpalGun[i]:GetData().PosOffset = rapidFireOpalOffsets[gunCount][1] + (rapidFireOpalOffsets[gunCount][2] * (i-1))
                    gun.Parent = player
                end
            end
        end
        player.FireDelay = player.MaxFireDelay
        local aim = player:GetAimDirection()
        if mod:canUseDrawnItem(player, mod.DrawnItemTypes.RapidFireOpal, aim) then
            for i = 1, math.max(gunCount, #d.rapidFireOpalGun) do
                d.FFdrawnItemCooldown = player.MaxFireDelay
                local tear = player:FireTear(player.Position + aim:Resized(10), Vector(player.ShotSpeed * 10,0):Rotated(aim:GetAngleDegrees()):Rotated(rapidFireOpalOffsets[gunCount][1] + (rapidFireOpalOffsets[gunCount][2] * (i-1))))
                local smoke = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, tear.Position, tear.Velocity:Resized(3), npc)
                --smoke.SpriteScale = Vector(1,1)
                smoke:GetData().longonly = true
                smoke.SpriteOffset = Vector(0, -10)
                smoke.Color = Color(0.15,0.15,0.15,1)
                smoke:Update()
                --What the gun doin
                if d.rapidFireOpalGun[i] then
                    sfx:Play(mod.Sounds.ShootRifle, 1, 0, false, 1 / tear.Scale)
                    d.rapidFireOpalGun[i]:GetData().firingDir = tear.Velocity
                    d.rapidFireOpalGun[i]:GetSprite():Play("Shoot", true)
                end
                local case = Isaac.Spawn(1000, mod.FF.GolemsARBulletCase.Var, mod.FF.GolemsARBulletCase.Sub, player.Position, tear.Velocity:Resized(-math.random(10,50)/10):Rotated(-50 + math.random(100)), player)
                case.Color = tear.Color
                case.SpriteScale = tear.SpriteScale
                local anim
                local scale = tear.Scale
                if scale <= 0.3 then
                    anim = "RegularTear1"
                elseif scale <= 0.55 then
                    anim = "RegularTear2"
                elseif scale <= 0.675 then
                    anim = "RegularTear3"
                elseif scale <= 0.8 then
                    anim = "RegularTear4"
                elseif scale <= 0.925 then
                    anim = "RegularTear5"
                elseif scale <= 1.05 then
                    anim = "RegularTear6"
                elseif scale <= 1.175 then
                    anim = "RegularTear7"
                elseif scale <= 1.425 then
                    anim = "RegularTear8"
                elseif scale <= 1.675 then
                    anim = "RegularTear9"
                elseif scale <= 1.925 then
                    anim = "RegularTear10"
                elseif scale <= 2.175 then
                    anim = "RegularTear11"
                elseif scale <= 2.55 then
                    anim = "RegularTear12"
                else
                    anim = "RegularTear13"
                end
                case:GetData().Scale = scale
                case:GetSprite():Play(anim)
                if tear.Velocity.X < 0 then
                    case:GetSprite().FlipX = true
                else
                    case:GetSprite().FlipX = false
                end
                case:Update()
            end
            d.rapidFireOpalAmmo = d.rapidFireOpalAmmo - 1
            if d.rapidFireOpalAmmo <= 0 then
                d.rapidFireOpalAmmo = nil
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_TEARFLAG)
                player:EvaluateItems()
            end
        end
	end
end

function mod:rapidFireOpalPostFireTear(player, tear, rng, pdata, tdata, secondHandMultiplier)
    if pdata.rapidFireOpalAmmo then
        mod:changeTearVariant(tear, TearVariant.GOLEMS_AR_BULLET)
        if player:HasCollectible(mod.ITEM.COLLECTIBLE.RUBBER_BULLETS) then
            tdata.ApplyBruise = true
            tdata.ApplyBruiseDuration = 120 * secondHandMultiplier
            tdata.ApplyBruiseStacks = 1
            tdata.ApplyBruiseDamagePerStack = 1
            
            tear.Color = Color(0.5, 0.3, 0.5, 1.0, 40/255, 0/255, 40/255)
        end
    end
end

function mod:friendlyRapidFireOpalNewRoom(player, d, savedata)
    if player:HasTrinket(mod.ITEM.ROCK.FRIENDLY_RAPID_FIRE_OPAL) then
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_TEARFLAG)
        player:EvaluateItems()
        local strength = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.FRIENDLY_RAPID_FIRE_OPAL)
        local baseBullets = 12
        if player:HasTrinket(mod.ITEM.ROCK.FIENDISH_AMETHYST) then
            baseBullets = 18
        end
        d.rapidFireOpalAmmo = math.ceil(baseBullets * strength)
    end
end

function mod:friendlyRapidFireOpalGunAI(e)
	local player = e.Parent
	local sprite = e:GetSprite()
	local d = e:GetData()

    if player:GetData().drawnSwallowedM90 then
        e.Visible = false
    else
        if not e.Visible then
            e.Visible = true
            sfx:Play(mod.Sounds.GunDraw,0.2,0,false,math.random(90,110)/100)
        end
    end

	local rot = player.Velocity
    if player.Velocity:Length() == 0 then
        rot = Vector(1,-1)
    end
    --print(d.rotCooldown)
    if d.rotCooldown then
        d.rotCooldown = d.rotCooldown - 1
        if d.rotCooldown <= 0 then
            d.firingDir = nil
            d.rotCooldown = nil
        end
    end
	if d.firingDir then
		rot = d.firingDir
	end
    if d.PosOffset then
        rot = rot:Rotated(d.PosOffset)
    end
	if rot.X < 0 then
		sprite.FlipX = true
		e.RenderZOffset = 5100
	else
		sprite.FlipX = false
		e.RenderZOffset = -5100
	end
	rot = math.floor(rot:GetAngleDegrees())
	if sprite.FlipX then
		rot = (rot * -1) + 180
	end
	e.SpriteRotation = rot

	local vec = (player.Position + Vector(0, -10) - e.Position)
	e.Velocity = mod:Lerp(e.Velocity, vec, 0.6)
	if sprite:IsFinished("Shoot") then
        if not player:GetData().rapidFireOpalAmmo then
            sprite:Play("Disappear", true)
        else
            sprite:Play("Idle", true)
        end
        d.rotCooldown = 5
	end
    if sprite:IsFinished("Disappear") then
        e:Remove()
    end
end

function mod:friendlyRapidFireOpalGunBulletCaseAI(e)
    local d, sprite = e:GetData(), e:GetSprite()
    if not d.init then
        d.init = true
        d.anim = math.random(3)
        d.FallAccel = 1
        d.FallSpeed = -math.random(80,100)/10
        d.Falling = true
    end
    if d.Falling then
        d.FallOffset = d.FallOffset or 0
        if d.FallOffset + d.FallSpeed >=1 then
            if d.FallSpeed <= 2 then
                d.Falling = nil
            end
            sfx:Play(mod.Sounds.D2Toss,d.FallSpeed/40,0,false, (math.random(100,110)/100 + d.FallSpeed/50)/(d.Scale or 1))
            d.FallSpeed = d.FallSpeed * -0.5
        end
        d.FallOffset = d.FallOffset + d.FallSpeed
        d.FallSpeed = d.FallSpeed + d.FallAccel
    else
        d.FallOffset = 0
        e.Color = Color(e.Color.R, e.Color.G, e.Color.B, e.Color.A - 0.05, e.Color.RO, e.Color.GO, e.Color.BO)
        if e.Color.A <= 0 then
            e:Remove()
        end
    end
    e.SpriteOffset = Vector(0, -10 + d.FallOffset)
    if sprite.FlipX then
        e.SpriteRotation = e.SpriteRotation - e.Velocity.X * 5
    else
        e.SpriteRotation = e.SpriteRotation + e.Velocity.X * 5
    end
    e.Velocity = e.Velocity * 0.9
end
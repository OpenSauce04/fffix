local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:swallowedM90Drawn(player, d)
	if d.drawnSwallowedM90 then
		if d.drawnSwallowedM90 == "Remove" then
			d.drawnSwallowedM90 = nil
		else
			if (not d.M90Gun) or (d.M90Gun and (not d.M90Gun:Exists())) then
				local gun = Isaac.Spawn(1000, mod.FF.SwallowedM90Gun.Var, mod.FF.SwallowedM90Gun.Sub, player.Position, nilvector, player)
				d.M90Gun = gun
				gun.SpawnerEntity = player
				gun.Parent = player
				if game:GetRoom():GetFrameCount() > 0 then
					sfx:Play(mod.Sounds.GunDraw,0.7,0,false,math.random(90,110)/100)
				end
			end
            player.FireDelay = player.MaxFireDelay
            local aim = player:GetAimDirection()
            if mod:canUseDrawnItem(player, mod.DrawnItemTypes.SwallowedM90, aim) then
				d.FFdrawnItemCooldown = player.MaxFireDelay
                --Actual tear
                local vec = player:GetAimDirection():Resized(20) + player:GetTearMovementInheritance(aim)
                local tear = Isaac.Spawn(2, TearVariant.M90_BULLET, 0, player.Position, vec, player):ToTear()
                tear.SpawnerEntity = player
                --tear:GetSprite():Load("gfx/projectiles/projectile_m90.anm2", true)
                --tear:GetSprite():Play("RegularTear", true)
                tear.TearFlags = tear.TearFlags | TearFlags.TEAR_PIERCING
                --tear:GetData().customtype = "M90Bullet"
                tear.CollisionDamage = math.max(player.Damage, 3.5) * (d.swallowedM90Multi or 3.5)
				
				-- Synergy babyyyyyyyyyy
				if player:HasCollectible(CollectibleType.COLLECTIBLE_RUBBER_BULLETS) then
					local secondHandMultiplier = player:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND) + 1
					local teardata = tear:GetData()

					teardata.ApplyBruise = true
					teardata.ApplyBruiseDuration = 120 * secondHandMultiplier
					teardata.ApplyBruiseStacks = 1
					teardata.ApplyBruiseDamagePerStack = 1
					
					tear.Color = Color(0.5, 0.3, 0.5, 1.0, 40/255, 0/255, 40/255)
				end
				
                tear:Update()
                --Fancy smoke
                for i = -30, 30, 30 do
                    local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, tear.Position, tear.Velocity:Resized(20):Rotated(i), npc)
                    --smoke.SpriteScale = Vector(1,1)
                    smoke.SpriteOffset = Vector(0, -10)
                    smoke:Update()
                end
                --What the gun doin
                if d.M90Gun then
                    d.M90Gun:GetData().firingDir = tear.Velocity
                    d.M90Gun:GetSprite():Play("Shoot", true)
                end
                sfx:Play(mod.Sounds.SniperRifleFire,0.37,0,false,math.random(90,110)/100)
                game:ShakeScreen(15)
                player.Velocity = player.Velocity + tear.Velocity:Resized(-10)
				local case = Isaac.Spawn(1000, mod.FF.GolemsARBulletCase.Var, mod.FF.GolemsARBulletCase.Sub, player.Position, (player.Velocity * 1.2):Rotated(-50 + math.random(100)), player)
				case:GetSprite():ReplaceSpritesheet(0, "gfx/effects/effect_bulletcase_m90.png")
                case:GetSprite():LoadGraphics()
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
				case:GetSprite():Play(anim)
                if tear.Velocity.X < 0 then
                    case:GetSprite().FlipX = true
                end
                case:Update()
                d.drawnSwallowedM90 = "Remove"
            end
		end
	end
end

function mod:swallowedM90PlayerHurt(player)
	if player:HasTrinket(TrinketType.TRINKET_SWALLOWED_M90) then
		player:GetData().drawnSwallowedM90 = true
		player:GetData().swallowedM90Multi = 2.5 + player:GetTrinketMultiplier(TrinketType.TRINKET_SWALLOWED_M90)
	end
end

--Currently unused
--[[function mod:swallowedm90(player, tear, rng, pdata, tdata)
    if player:GetData().drawnSwallowedM90 then
		for i = -30, 30, 30 do
			local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, tear.Position, tear.Velocity:Resized(20):Rotated(i), npc)
			--smoke.SpriteScale = Vector(1,1)
			smoke.SpriteOffset = Vector(0, -10)
			smoke:Update()
		end
		local replaced = false
		if (not haemoTears[tear.Variant]) and tear.Variant ~= 13 then
			tear.Variant = 13
		end
		if tear.Variant == 13 then
			tear:GetSprite():Load("gfx/projectiles/projectile_m90.anm2", true)
			tear:GetSprite():Play("RegularTear", true)
		end
		tear.TearFlags = tear.TearFlags | TearFlags.TEAR_PIERCING
		tear:GetData().customtype = "M90Bullet"
		tear.CollisionDamage = math.max(tear.CollisionDamage, 3.5)
		tear.CollisionDamage = tear.CollisionDamage * 3.5
		tear.Velocity = tear.Velocity:Resized(20)
		tear:Update()
	end
end]]

--Cool effect
function mod:m90GunAI(e)
	local player = e.Parent
	local sprite = e:GetSprite()
	local d = e:GetData()

	local rot = player.Velocity
	if d.firingDir then
		rot = d.firingDir
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
		e:Remove()
	end
end
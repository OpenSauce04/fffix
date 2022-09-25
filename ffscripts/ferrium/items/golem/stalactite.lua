local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, explosion)
	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i - 1)
		if player:HasTrinket(FiendFolio.ITEM.ROCK.STALACTITE) and not player:GetData().stalactiteFallCooldown then
			local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.STALACTITE)
			local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.STALACTITE)
			player:GetData().stalactiteFallCooldown = 45
			for i=1,math.min(12,4+rng:RandomInt(3)+mult) do --Doing projectiles instead of tears since tears can instantly hit enemies from 5 billion meters up.
				--[[local rock = Isaac.Spawn(2, 42, 0, mod:FindRandomPos(player.Position), Vector(0,rng:RandomInt(5)/4):Rotated(rng:RandomInt(360)), player):ToTear()
				rock.Height = -500-rng:RandomInt(100)
				rock.FallingSpeed = rng:RandomInt(50)-25
				rock.FallingAcceleration = 2
				rock.Scale = rng:RandomInt(40)/100+0.8
				rock.CollisionDamage = player.Damage
				rock:Update()]]
				
				sfx:Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND,0.5,0,false,math.random(110,120)/100)
				--[[mod.scheduleForUpdate(function()
					local rock = Isaac.Spawn(9, 8, 0, mod:FindRandomPos(player.Position), Vector(0,rng:RandomInt(5)/4):Rotated(rng:RandomInt(360)), player):ToProjectile()
					rock.ProjectileFlags = rock.ProjectileFlags | ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.HIT_ENEMIES
					rock.Height = -500-rng:RandomInt(100)
					rock.FallingSpeed = rng:RandomInt(50)-25
					rock.FallingAccel = 2
					rock.Scale = 1
					--rock.Damage = math.min(30,player.Damage)
					rock:Update()
					local pSprite = rock:GetSprite()
					pSprite:Load("gfx/009.009_rock projectile.anm2", true)
					pSprite:Play("Rotate4", true)
					pSprite:LoadGraphics()
					rock:GetData().makeSplat = 145
					rock:GetData().customProjSound = {SoundEffect.SOUND_STONE_IMPACT, 0.8, math.random(8,12)/10}
					rock:GetData().toothParticles = mod.ColorRockGibs
				end, rng:RandomInt(10))]]
				mod.scheduleForUpdate(function()
					local rock = Isaac.Spawn(2, 40, 0, mod:FindRandomPosSnowGlobe(player.Position, rng), Vector(0,rng:RandomInt(5)/4):Rotated(rng:RandomInt(360)), player):ToTear()
					rock.Height = -500-rng:RandomInt(100)
					rock.FallingSpeed = rng:RandomInt(50)-25
					rock.FallingAcceleration = 2
					rock.Scale = 1
					rock:GetData().dontHitAbove = true
					rock.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					rock:Update()
					local pSprite = rock:GetSprite()
					pSprite:Load("gfx/009.009_rock projectile.anm2", true)
					pSprite:Play("Rotate4", true)
					pSprite:LoadGraphics()
					rock:GetData().makeSplat = 145
					rock:GetData().customTearSound = {SoundEffect.SOUND_STONE_IMPACT, 0.8, math.random(8,12)/10}
					rock:GetData().toothParticles = mod.ColorRockGibs
					rock.CollisionDamage = player.Damage*2
				end, rng:RandomInt(10))
			end
			
			local enemies = {}
			for _, enemy in ipairs(Isaac.FindInRadius(game:GetRoom():GetCenterPos(), 1000, EntityPartition.ENEMY)) do
				if enemy:IsActiveEnemy() and (not mod:isFriend(enemy)) then
					table.insert(enemies, enemy)
				end
			end
			if #enemies > 0 then
				local numb = math.ceil(#enemies/2)
				local chosen = mod:getSeveralDifferentNumbers(numb, #enemies, rng)
				for i=1,#chosen do
					local pos = enemies[chosen[i]].Position
					local vel = enemies[chosen[i]].Velocity
					for i=1,math.ceil(mult)+2 do
						mod.scheduleForUpdate(function()
							local rock = Isaac.Spawn(2, 40, 0, mod:FindRandomPosSnowGlobe(player.Position, rng), Vector(0,rng:RandomInt(5)/4):Rotated(rng:RandomInt(360)), player):ToTear()
							if i == 1 then
								rock:GetData().justMakeThisOneHit = enemies[chosen[i]]
								rock.Position = pos
							end
							rock.Height = -500-rng:RandomInt(100)
							rock.FallingSpeed = rng:RandomInt(50)-25
							rock.FallingAcceleration = 2
							rock.Scale = 1
							rock:GetData().dontHitAbove = true
							rock.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
							rock:Update()
							local pSprite = rock:GetSprite()
							pSprite:Load("gfx/009.009_rock projectile.anm2", true)
							pSprite:Play("Rotate4", true)
							pSprite:LoadGraphics()
							rock:GetData().makeSplat = 145
							rock:GetData().customTearSound = {SoundEffect.SOUND_STONE_IMPACT, 0.5, math.random(8,12)/10}
							rock:GetData().toothParticles = mod.ColorRockGibs
							rock.CollisionDamage = player.Damage*2
						end, rng:RandomInt(10))
					end
				end
			end
		end
	end
end, EffectVariant.BOMB_EXPLOSION)

function mod:stalactiteItemUpdate(player, data)
	if data.stalactiteFallCooldown then
		if data.stalactiteFallCooldown > 0 then
			data.stalactiteFallCooldown = data.stalactiteFallCooldown-1
		else
			data.stalactiteFallCooldown = nil
		end
	end
	if player:HasTrinket(FiendFolio.ITEM.ROCK.STALACTITE) then
		for _,proj1 in ipairs(Isaac.FindByType(9,9,-1, false, true)) do
			local proj = proj1:ToProjectile()
			if proj.Height < -200 then
				local rock = Isaac.Spawn(2, 42, 0, proj.Position, proj.Velocity, player):ToTear()
				rock.Height = proj.Height
				rock.FallingSpeed = proj.FallingSpeed
				rock.FallingAcceleration = proj.FallingAccel
				rock.CollisionDamage = player.Damage*2
				rock:GetData().dontHitAbove = true
				rock.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				rock.Scale = proj.Scale
				rock:Update()
				proj:Remove()
				sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, proj)
	local data = proj:GetData()
	if data.justMakeThisOneHit then
		if data.justMakeThisOneHit:Exists() then
			proj.Velocity = data.justMakeThisOneHit.Position-proj.Position
		else
			proj.Velocity = proj.Velocity*0.8
		end
	end
end, 40)

function mod.dontHitAbove(v, d)
	if d.dontHitAbove then
		if v.Height < -40 then
			v.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		else
			v.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		end
	end
end
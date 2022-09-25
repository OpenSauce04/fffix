-- Lil Minx --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local sprite = familiar:GetSprite()
	local d = familiar:GetData()
	local player = familiar.Player
	local isSuperpositioned = mod:isSuperpositionedPlayer(player)
	familiar.SpriteOffset = Vector(0,-15)
	
	local wasSirenCharmed = d.IsSirenCharmed or false
	local isSirenCharmed = mod:isSirenCharmed(familiar)

	if not d.init then
		d.state = "idle"
		d.StateFrame = 0
		d.possesscooldown = 0
		familiar.Velocity = RandomVector() * 7.5
		d.init = true
	else
		d.StateFrame = d.StateFrame + 1
	end

	d.damagedEnemies = d.damagedEnemies or {}
	d.firecooldown = d.firecooldown or 10
	d.doubletaptimer = d.doubletaptimer or -1
	d.hasreleased = d.hasreleased or false

	local hasdoubletapped = false

	if sprite:IsEventTriggered("Shoot") and d.nexttearpossessor then
		local multiplier = 1
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
			multiplier = 2
		end

		for i = 1, 7 do
			if isSirenCharmed then
				local proj = Isaac.Spawn(9, 0, 0, familiar.Position, familiar.Velocity, familiar):ToProjectile()

				proj.Velocity = proj.Velocity:Resized(7) + (RandomVector() * math.random() * 3.5)
				proj.FallingSpeed = proj.FallingSpeed + -10 - math.random(20)
				proj.FallingAccel = proj.FallingAccel + 1 + (math.random() * 0.5)
				proj.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			else
				local tear = familiar:FireProjectile(familiar.Velocity):ToTear()

				tear.Velocity = tear.Velocity:Resized(7) + (RandomVector() * math.random() * 3.5)
				tear.CollisionDamage = 3.5 * multiplier
				tear:ResetSpriteScale()

				tear.FallingSpeed = tear.FallingSpeed + -10 - math.random(20)
				tear.FallingAcceleration = tear.FallingAcceleration + 1 + (math.random() * 0.5)

				tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
				tear.Color = Color(2.0, 1.2, 1.2, 0.5, 0/255, 0/255, 0/255)

				local teardata = tear:GetData()
				teardata.FFMinxTear = true
				teardata.FFMinxPossessed = d.nexttearpossessor
				
				if isSuperpositioned then
					local tearcolor = Color.Lerp(tear.Color, Color(1,1,1,1,0,0,0), 0)
					tearcolor.A = tearcolor.A / 4
					tear.Color = tearcolor
				end
			end
		end
	end

	if wasSirenCharmed ~= isSirenCharmed then
		d.firecooldown = 10
		d.doubletaptimer = -1
		d.hasreleased = false
	elseif player:GetFireDirection() == Direction.NO_DIRECTION then
		d.firecooldown = 10

		d.hasreleased = true
		if d.doubletaptimer <= 0 then
			d.doubletaptimer = -1
		end
	else
		d.firecooldown = d.firecooldown - 1

		if d.doubletaptimer <= -1 then
			d.doubletaptimer = 10
		elseif d.hasreleased and d.doubletaptimer > 0 then
			hasdoubletapped = true
		end
		d.hasreleased = false
	end

	if d.doubletaptimer > 0 then
		d.doubletaptimer = d.doubletaptimer - 1
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Move")
		familiar.Visible = true
		familiar.Velocity = familiar.Velocity * 0.93
		if familiar.Velocity.X > 0 then
			sprite.FlipX = false
		else
			sprite.FlipX = true
		end

		if d.StateFrame % 25 == 24 then
			if (player.Position - familiar.Position):Length() >= 80 then
				familiar.Velocity = familiar.Velocity + Vector.FromAngle((player.Position - familiar.Position):GetAngleDegrees() + math.random() * 30 - 15) * 7.5
			else
				familiar.Velocity = familiar.Velocity + Vector.FromAngle((player.Position - familiar.Position):GetAngleDegrees() + math.random() * 30 - 15) * 2.5
			end
		end

		if d.StateFrame > 40 and d.firecooldown <= 0 then
			local newtarg
			if isSirenCharmed then
				newtarg = mod:getClosestPlayer(familiar.Position, 1000)
			else
				newtarg = mod.FindClosestEnemy(familiar.Position, 1000, true, false, false, false, false, true)
			end
			if newtarg then
				d.state = "enemycharge"
				d.chargetarget = newtarg
				d.chargestate = 0
				d.chargetime = 0
			end
		elseif not isSirenCharmed and hasdoubletapped and d.possesscooldown <= 0 then
			local newtarg = mod.FindClosestEnemy(familiar.Position, 1000, true, false, false, false, false, true, true)
			if newtarg then
				d.state = "possessiontime"
				d.target = newtarg
				d.chargestate = 0
				d.possesscharging = false
			end
		end
	elseif d.state == "enemycharge" then
		if familiar.Velocity.X > 0 then
			sprite.FlipX = false
		else
			sprite.FlipX = true
		end

		if sprite:IsFinished("ChargeStart") then
			if d.chargestate == 0 or d.chargestate == 1 then
				mod:spritePlay(sprite, "ChargeLoop")
			else
				mod:spritePlay(sprite, "ChargeEnd")
			end
		elseif sprite:IsPlaying("ChargeLoop") and d.chargestate == 2 then
			mod:spritePlay(sprite, "ChargeEnd")
		end

		if d.chargestate == 0 then
			if sprite:IsEventTriggered("CHAAARGE") then
				d.enemycharging = true
				d.chargestate = 1
				d.chargetargetdirection = Vector.FromAngle((d.chargetarget.Position - familiar.Position):GetAngleDegrees()):Resized(12)
				sfx:Play(SoundEffect.SOUND_SPEWER, 1, 0, false, math.random(130,150)/100)
			else
				mod:spritePlay(sprite, "ChargeStart")
			end
		end

		if d.chargestate == 1 then
			d.chargetime = d.chargetime + 1
			if familiar.Position:Distance(d.chargetarget.Position) < 50 or 
			   d.chargetime >= 30 or 
			   (isSirenCharmed and d.chargetime >= 20) or 
			   (not d.chargetarget:Exists()) or 
			   mod:isStatusCorpse(d.chargetarget) 
			then
				d.chargestate = 2
				if not isSirenCharmed then 
					d.chargetargetdirection = Vector.FromAngle((d.chargetarget.Position - familiar.Position):GetAngleDegrees()):Resized(12)
				end
				d.chargetarget = nil
			end
		end

		if d.chargestate == 2 then
			if sprite:IsFinished("ChargeEnd") then
				d.state = "idle"
				d.StateFrame = 0
			elseif sprite:IsEventTriggered("Chomp") then
				d.enemycharging = false
				d.chargetargetdirection = nil
				d.damagedEnemies = {}
				sfx:Play(mod.Sounds.GnawfulBite, 0.6, 0, false, math.random(130,150)/100)
			end
			if not d.enemycharging then
				familiar.Velocity = familiar.Velocity * 0.95
			end
		end

		if d.enemycharging and not isSirenCharmed then
			local multiplier = 1
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
				multiplier = 2
			end

			local enemies = Isaac.FindInRadius(familiar.Position, 800, EntityPartition.ENEMY)
			for _, enemy in ipairs(enemies) do
				if mod:isFriend(enemy) or enemy:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) or d.damagedEnemies[enemy.Index .. " " .. enemy.InitSeed] then
					-- do nothing
				elseif familiar.Position:Distance(enemy.Position) <= enemy.Size + familiar.Size then
					enemy:TakeDamage(3.5 * multiplier, 0, EntityRef(familiar), 0)
					d.damagedEnemies[enemy.Index .. " " .. enemy.InitSeed] = true
				end
			end
		end
	elseif d.state == "possessiontime" then
		if familiar.Velocity.X > 0 then
			sprite.FlipX = false
		else
			sprite.FlipX = true
		end
		if d.chargestate == 0 then
			if sprite:IsFinished("PossessStart") then
				d.chargestate = 1
			elseif sprite:IsEventTriggered("CHAAARGE") then
				d.possesscharging = true
			else
				mod:spritePlay(sprite, "PossessStart")
			end
		elseif d.chargestate == 1 then
			mod:spritePlay(sprite, "PossessLoop")
			if familiar.Position:Distance(d.target.Position) < 25 then
				d.state = "possess"
				mod:spritePlay(sprite, "Enter")
			end
		elseif d.chargestate == 2 then
			if sprite:IsFinished("Exit") then
				d.chargestate = 1
			else
				mod:spritePlay(sprite, "Exit")
			end
		end

		if d.possesscharging then
			if d.target and not (d.target:IsDead() or mod:isStatusCorpse(d.target)) then
				local targvel = (d.target.Position - familiar.Position):Resized(9)
				familiar.Velocity = mod:Lerp(familiar.Velocity, targvel, 0.3)
			else
				d.state = "idle"
				d.StateFrame = 0
			end
		end
	elseif d.state == "possess" then
		if d.target and not (d.target:IsDead() or mod:isStatusCorpse(d.target) or d.target:GetData().FFBerserkKickOutLilMinx) then
			familiar.Position = d.target.Position + Vector(0, 3)
			familiar.Velocity = d.target.Velocity
			if sprite:IsFinished("Enter") then
				d.state = "insideman"
				d.StateFrame = 0
				familiar.Visible = false
				d.target:GetData().numminxpossessed = (d.target:GetData().numminxpossessed or 0) + 1
			elseif sprite:IsEventTriggered("Gone") then
				d.isinside = true
				sfx:Play(mod.Sounds.FishRoll,1.5,0,false,math.random(110,130)/100)
			end
		else
			d.isinside = nil
			d.state = "idle"
			d.StateFrame = 0
		end
	elseif d.state == "insideman" then
		familiar.Visible = false
		if (d.target and (d.target:IsDead() or mod:isStatusCorpse(d.target) or d.target:GetData().FFBerserkKickOutLilMinx)) or (not d.target) or hasdoubletapped then
			d.state = "escape"
			mod:spritePlay(sprite, "Exit")
			sfx:Play(mod.Sounds.FireballLaunch,0.6,0,false,math.random(90,110)/100)
			local Flash = Isaac.Spawn(1000, 1726, 0, familiar.Position, nilvector, v):ToEffect()
			if d.target and (d.target:IsDead() or mod:isStatusCorpse(d.target)) then
				Flash:FollowParent(d.target)
			end
			if isSuperpositioned then
				local flashcolor = Color.Lerp(Flash.Color, Color(1,1,1,1,0,0,0), 0)
				flashcolor.A = flashcolor.A / 4
				Flash.Color = flashcolor
			end
			Flash:Update()
			d.StateFrame = 0
			d.isinside = nil
			if d.target and d.target:Exists() then
				d.target:GetData().numminxpossessed = math.max(0, (d.target:GetData().numminxpossessed or 0) - 1)
				if d.target:GetData().numminxpossessed <= 0 then
					FiendFolio.RemoveBerserk(d.target)
				end
			end
			local nextfiredirection = RandomVector():GetAngleDegrees()
			d.nexttearpossessor = nil
			if hasdoubletapped then
				nextfiredirection = player:GetShootingInput():GetAngleDegrees()
				d.nexttearpossessor = d.target.Index .. " " .. d.target.InitSeed
			end
			familiar.Velocity = Vector.FromAngle(nextfiredirection):Resized(7)
		else
			familiar.Position = d.target.Position + Vector(0, 3)
			familiar.Velocity = d.target.Velocity
		end
	elseif d.state == "escape" then
		familiar.Visible = true
		familiar.Velocity = familiar.Velocity * 0.93
		if familiar.Velocity.X > 0 then
			sprite.FlipX = false
		else
			sprite.FlipX = true
		end
		if sprite:IsFinished("Exit") then
			mod:spritePlay(sprite, "PossessLoop")
		end
		if d.StateFrame > 10 then
			d.state = "idle"
			d.StateFrame = 0
			d.possesscooldown = 40
		end
	end

	d.possesscooldown = d.possesscooldown - 1

	if d.enemycharging then
		local targvel
		if d.chargetarget and not isSirenCharmed then
			targvel = (d.chargetarget.Position - familiar.Position):Resized(12)
		else
			targvel = d.chargetargetdirection
		end
		familiar.Velocity = mod:Lerp(familiar.Velocity, targvel, 0.3)
	end

	if d.isinside and d.target and d.target:Exists() then
		FiendFolio.AddBerserk(d.target, player, 99999, false, true)
	end
	
	d.IsSirenCharmed = isSirenCharmed
end, FiendFolio.ITEM.FAMILIAR.LIL_MINX)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, entity)
	if entity.Variant == FiendFolio.ITEM.FAMILIAR.LIL_MINX then
		local d = entity:GetData()
		if d.isinside and d.target and d.target:Exists() then
			d.target:GetData().numminxpossessed = math.max(0, (d.target:GetData().numminxpossessed or 0) - 1)
			if d.target:GetData().numminxpossessed <= 0 then
				FiendFolio.RemoveBerserk(d.target)
			end
		end
	end
end, EntityType.ENTITY_FAMILIAR)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function(_)
	local minxs = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FiendFolio.ITEM.FAMILIAR.LIL_MINX)
	for _, familiar in ipairs(minxs) do
		local d = familiar:GetData()
		local player = familiar.Player

		d.state = "idle"
		d.StateFrame = 0
		d.possesscooldown = 0
		d.init = nil

		d.isinside = nil
		d.target = nil
		d.chargetargetdirection = nil
		d.chargetarget = nil
		d.chargestate = nil
		d.enemycharging = nil
		d.possesscharging = nil
		d.damagedEnemies = nil
		d.firecooldown = nil
		d.doubletaptimer = nil
		d.hasreleased = nil
		d.nexttearpossessor = nil
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function(_, tear, entity, mysteryBoolean)
	local data = tear:GetData()
	if data.FFMinxTear then
		if data.FFMinxPossessed == entity.Index .. " " .. entity.InitSeed then
			return true
		end
	end
end)

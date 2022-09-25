local mod = FiendFolio
local sfx = SFXManager()

local hatred = mod.ITEM.TRINKET.HATRED
local hatredFamiliar = mod.ITEM.FAMILIAR.HATRED

local RECOVER_COOLDOWN = 90
local REFORM_COOLDOWN = 9

local function RecalcThresholds(familiar)
	local data = familiar:GetData()
	data.fireCooldown = math.floor(familiar.Player.MaxFireDelay)
	data.fireFrameThreshold = data.fireCooldown - 2
	data.lookFrameThreshold = data.fireCooldown - 12
end

function mod.TryLaunchHatredFamiliars(player)
	if player.ControlsEnabled and not DeadSeaScrollsMenu.IsOpen() then
		for _, familiar in pairs(Isaac.FindByType(3, maliceFamiliar)) do
			local data = familiar:GetData()
			if not data.isFlying and not data.recovering and not data.reforming and GetPtrHash(familiar.SpawnerEntity) == GetPtrHash(player) then
				data.isFlying = mod.GetCorrectedFiringInput(player):Normalized()
				sfx:Play(mod.Sounds.FireballLaunch, 0.4, 0, false, math.random(90, 110)/100)
				familiar.Velocity = data.isFlying * 9
				familiar.CollisionDamage = 7
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	if player.Variant == 0 then
		player:CheckFamiliar(hatredFamiliar, player:GetTrinketMultiplier(hatred) + player:GetEffects():GetTrinketEffectNum(hatred), player:GetTrinketRNG(hatred), Isaac.GetItemConfig():GetTrinket(hatred))
	end
end, CacheFlag.CACHE_FAMILIAR)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)
	familiar:GetSprite():Play("IdleDown")

	local data = familiar:GetData()
	data.cachedFiringDirection = "Down"
	data.cachedMovementDirection = "Down"

	RecalcThresholds(familiar)
end, hatredFamiliar)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local data = familiar:GetData()
	local sprite = familiar:GetSprite()
	local player = familiar.Player

	familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
	familiar.FireCooldown = familiar.FireCooldown - 1
	familiar.SpriteOffset = Vector(0, -7)

	if not data.recovering and not data.reforming then
		if data.isFlying --[[or familiar.FrameCount % 3 == 1]] then
			local creep = Isaac.Spawn(1000, 45, 0, familiar.Position, Vector.Zero, familiar):ToEffect()
			creep.Scale = 0.65
			creep:SetTimeout(15)
			creep:Update()
		end
	end

	if data.isFlying then
		familiar.Velocity = familiar.Velocity + data.isFlying

		local flightDirection = mod.GetStringDirectionFromVector(familiar.Velocity)
		sprite:Play("Fly" .. flightDirection)

		if familiar:CollidesWithGrid() then
			data.recovering = true
			data.isFlying = nil
			familiar.Visible = false
			familiar.FireCooldown = RECOVER_COOLDOWN
			familiar.CollisionDamage = 0

			local creep = Isaac.Spawn(1000, 45, 0, familiar.Position, Vector.Zero, familiar):ToEffect()
			creep.SpriteScale = creep.SpriteScale * 1.5
			creep:SetTimeout(45)
			creep:Update()

			local malicePoof = Isaac.Spawn(mod.FF.BallOfMalice.ID, mod.FF.BallOfMalice.Var, mod.FF.BallOfMalice.Sub, familiar.Position, Vector.Zero, familiar)
			malicePoof:GetData().HatredHijacked = true
			malicePoof:GetSprite():Play("Poof")
			malicePoof.SpriteScale = malicePoof.SpriteScale / 2
			malicePoof.SpriteOffset = familiar.SpriteOffset + Vector(0, -8)

			sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.6, 0, false, 0.8)
		end
	elseif data.recovering or data.reforming then
		familiar.Visible = false
		familiar:FollowParent()

		sprite:Play("IdleDown")

		if data.malicePoof then
			data.malicePoof.Velocity = familiar.Position - data.malicePoof.Position
		end

		if familiar.FireCooldown < 0 then
			if data.recovering then
				data.recovering = false
				data.reforming = true
				familiar.FireCooldown = REFORM_COOLDOWN

				local malicePoof = Isaac.Spawn(mod.FF.BallOfMalice.ID, mod.FF.BallOfMalice.Var, mod.FF.BallOfMalice.Sub, familiar.Position, Vector.Zero, familiar):ToEffect()
				malicePoof:GetData().HatredHijacked = true
				malicePoof:GetSprite():Play("PoofReverse")
				malicePoof.SpriteScale = malicePoof.SpriteScale / 2
				malicePoof.SpriteOffset = familiar.SpriteOffset + Vector(0, -8)

				data.malicePoof = malicePoof
			elseif data.reforming then
				data.reforming = false
				data.malicePoof = nil
				familiar.Visible = true
			end
		end
	else
		local movement = player:GetMovementVector():Normalized()
		local shooting = player:GetShootingJoystick():Normalized()
		local movementAnimDirection = mod.GetStringDirectionFromVector(movement)
		local shootingAnimDirection = mod.GetStringDirectionFromVector(shooting)

		local myAnimation = "Idle"
		local myAnimationDirection = "Down"

		if shooting:Length() > 0 and player.ControlsEnabled and not DeadSeaScrollsMenu.IsOpen() then
			myAnimationDirection = shootingAnimDirection
			if shootingAnimDirection ~= data.cachedFiringDirection then
				data.cachedFiringDirection = shootingAnimDirection
			end

			if familiar.FireCooldown < 0 then
				RecalcThresholds(familiar)
				familiar.FireCooldown = data.fireCooldown

				local tear = familiar:FireProjectile(shooting * player.ShotSpeed)
				tear:ChangeVariant(TearVariant.BLOOD)
				tear.Color = mod.ColorDankBlackReal
				tear.CollisionDamage = player.Damage * (player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 0.70 or 0.35)

				data.cachedFiringDirection = myAnimationDirection
			end
		end

		familiar.Velocity = familiar.Velocity * 0.8
		if movement:Length() > 0 and not Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
			myAnimation = "Walk"
			myAnimationDirection = movementAnimDirection

			familiar.Velocity = familiar.Velocity + movement * 1.75 * player.MoveSpeed
		end

		for _, other in pairs(Isaac.FindByType(3, hatredFamiliar)) do
			if other.Position:Distance(familiar.Position) < familiar.Size + other.Size then
				local push = (familiar.Position - other.Position):Normalized()
				familiar.Velocity = familiar.Velocity + push
				other.Velocity = other.Velocity + push
			end
		end

		local oldAnim = sprite:GetAnimation()
		local oldFrame = sprite:GetFrame()
		local myAnim = myAnimation

		if familiar.FireCooldown > data.lookFrameThreshold then
			myAnim = myAnim .. data.cachedFiringDirection
		else
			myAnim = myAnim .. myAnimationDirection
		end

		if familiar.FireCooldown > data.fireFrameThreshold then
			myAnim = myAnim .. "Shoot"
		end

		sprite:Play(myAnim)
		if myAnim ~= oldAnim then
			sprite:SetFrame(oldFrame)
		end
	end
end, hatredFamiliar)
local mod = FiendFolio

function mod:fetalStoneUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.FETAL_STONE) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.FETAL_STONE)
		
		if not data.fetalStone or not data.fetalStone:Exists() then
			local rock = Isaac.Spawn(3, 1039, 0, player.Position, Vector.Zero, player):ToFamiliar()
			rock.Player = player
			data.fetalStone = rock
		end
	end
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local data = familiar:GetData()
	local sprite = familiar:GetSprite()
	local player = familiar.Player
	local isSuperpositioned = mod:isSuperpositionedPlayer(familiar.Player)
	local isSirenCharmed = mod:isSirenCharmed(familiar)
	local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.FETAL_STONE)
	local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.FETAL_STONE)
	
	if not player:HasTrinket(FiendFolio.ITEM.ROCK.FETAL_STONE) then
		familiar:Remove()
	end
	
	if not data.state then
		familiar:AddToFollowers()
		familiar.FireCooldown = 40-math.min(12, math.floor(mult*2))
		data.state = "Float"
		data.stateframe = 0
	else
		familiar.FireCooldown = familiar.FireCooldown - ((player and player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) and 2) or 1)
		familiar.FireCooldown = math.max(0, familiar.FireCooldown)
		
		data.stateframe = data.stateframe + 1
	end
	
	local direction = player:GetFireDirection()
	data.lastdirection = (data.lastdirection ~= nil and data.lastdirection) or direction
	data.lastdirection = (direction ~= Direction.NO_DIRECTION and direction) or data.lastdirection
	
	if familiar.FireCooldown == 0 and direction ~= Direction.NO_DIRECTION then
		data.stateframe = 0
		data.state = "Shoot"
		familiar.FireCooldown = 40-math.min(20, math.floor(mult*2))
		
		local velocity
		if direction == Direction.LEFT then
			velocity = Vector(-10, 0)
		elseif direction == Direction.RIGHT then
			velocity = Vector(10, 0)
		elseif direction == Direction.UP then
			velocity = Vector(0, -10)
		else
			velocity = Vector(0, 10)
		end
		velocity = velocity + player:GetTearMovementInheritance(velocity)
				
		if isSirenCharmed then
			local proj = Isaac.Spawn(9, 9, 0, familiar.Position, velocity, familiar):ToProjectile()
			local projcolor = Color(1.0, 1.0, 1.0, 1, 0/255, 0/255, 0/255)
			projcolor:SetColorize(0.4, 1, 0.5, 1)
			proj.Color = projcolor
		else
			local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.ROCK, 0, familiar.Position, velocity, familiar):ToTear()
			tear.Height = -23
			tear.FallingSpeed = 0.1 + (math.random() * 2 - 1) * 0.1
			tear.FallingAcceleration = 0
			local damage = 5*mult
			tear.CollisionDamage = damage
			tear.Scale = 1
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
				tear.CollisionDamage = damage*2
			end
			tear:ResetSpriteScale()
			tear.KnockbackMultiplier = 1.8
			if rng:RandomInt(5) == 0 then
				tear:AddTearFlags(TearFlags.TEAR_CONFUSION)
			end
			if player:HasTrinket(TrinketType.TRINKET_BABY_BENDER) then
				tear:AddTearFlags(TearFlags.TEAR_HOMING)
				local tearcolor = Color(0.4, 0.15, 0.38, 1, 55/255, 5/255, 95/255)
				tear.Color = tearcolor
			end
			if isSuperpositioned then
				local tearcolor = Color.Lerp(tear.Color, Color(1,1,1,1,0,0,0), 0)
				tearcolor.A = tearcolor.A / 4
				tear.Color = tearcolor
			end
		end
	end
	
	if data.state == "Float" then
		if direction == Direction.LEFT and not (sprite:IsPlaying("FloatSide") and sprite.FlipX == true) then
			local frame = sprite:GetFrame()
			sprite:Play("FloatSide", true)
			sprite:SetFrame(frame)
			sprite.FlipX = true
		elseif direction == Direction.RIGHT and not (sprite:IsPlaying("FloatSide") and sprite.FlipX == false) then
			local frame = sprite:GetFrame()
			sprite:Play("FloatSide", true)
			sprite:SetFrame(frame)
			sprite.FlipX = false
		elseif direction == Direction.UP and not sprite:IsPlaying("FloatUp") then
			local frame = sprite:GetFrame()
			sprite:Play("FloatUp", true)
			sprite:SetFrame(frame)
			sprite.FlipX = false
		elseif (direction == Direction.DOWN or direction == Direction.NO_DIRECTION) and not sprite:IsPlaying("FloatDown") then
			local frame = sprite:GetFrame()
			sprite:Play("FloatDown", true)
			sprite:SetFrame(frame)
			sprite.FlipX = false
		end
	elseif data.state == "Shoot" then
		if data.lastdirection == Direction.LEFT and not (sprite:IsPlaying("FloatShootSide") and sprite.FlipX == true) then
			local frame = sprite:GetFrame()
			sprite:Play("FloatShootSide", true)
			sprite:SetFrame(frame)
			sprite.FlipX = true
		elseif data.lastdirection == Direction.RIGHT and not (sprite:IsPlaying("FloatShootSide") and sprite.FlipX == false) then
			local frame = sprite:GetFrame()
			sprite:Play("FloatShootSide", true)
			sprite:SetFrame(frame)
			sprite.FlipX = false
		elseif data.lastdirection == Direction.UP and not sprite:IsPlaying("FloatShootUp") then
			local frame = sprite:GetFrame()
			sprite:Play("FloatShootUp", true)
			sprite:SetFrame(frame)
			sprite.FlipX = false
		elseif (data.lastdirection == Direction.DOWN or data.lastdirection == Direction.NO_DIRECTION) and not sprite:IsPlaying("FloatShootDown") then
			local frame = sprite:GetFrame()
			sprite:Play("FloatShootDown", true)
			sprite:SetFrame(frame)
			sprite.FlipX = false
		end
		
		if (direction ~= Direction.NO_DIRECTION and data.stateframe >= 9) or data.stateframe >= 17 then
			data.state = "Float"
			data.stateframe = 0
		end
	end
	
	familiar:FollowParent()
end, FamiliarVariant.RELATIVE_ROCK)
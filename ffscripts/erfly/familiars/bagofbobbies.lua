local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)
	familiar.IsFollower = true
	familiar:GetData().rooms = 0
end, mod.ITEM.FAMILIAR.BAG_OF_BOBBIES)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local data = familiar:GetData()
	local sprite = familiar:GetSprite()
	data.rooms = data.rooms or 0
	if not data.init then

	end
    --data.payoutNum = data.payoutNum or 2 + familiar.Player:GetCollectibleRNG(mod.ITEM.COLLECTIBLE.BAG_OF_BOBBIES):RandomInt(3)
	--[[if Sewn_API then
		if Sewn_API:IsUltra(data) then
			payoutNum = 2
		elseif Sewn_API:IsSuper(data) then
			payoutNum = 3
		end
	end]]
    --local payoutNum = data.payoutNum
	--if familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
	--	payoutNum = math.ceil(data.payoutNum / 2)
	--end
	if data.CheckRoomClear then
        data.CheckRoomClear = nil
        local bobbies = mod.GetEntityCount(3, mod.ITEM.FAMILIAR.FRAGILE_BOBBY, -1)
		local randchance = 1 + bobbies
		if familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
			randchance = math.ceil(randchance/2)
		end
        if familiar.Player:GetCollectibleRNG(mod.ITEM.COLLECTIBLE.BAG_OF_BOBBIES):RandomInt(randchance) == 0 then
            local spawncount = 1
			if Sewn_API then
				if Sewn_API:IsUltra(data) then
					spawncount = 3
				elseif Sewn_API:IsSuper(data) then
					spawncount = 2
				end
			end
			for i = 1, spawncount do
				sprite:Play("Spawn", false)
				--[[local sd = familiar.Player:GetData().ffsavedata
				sd.bobbyBagSpawnCount = sd.bobbyBagSpawnCount or 0
				sd.bobbyBagSpawnCount = sd.bobbyBagSpawnCount + 1
				familiar.Player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
				familiar.Player:EvaluateItems()]]
				local bobby = Isaac.Spawn(3, mod.ITEM.FAMILIAR.FRAGILE_BOBBY, 0, familiar.Position, nilvector, familiar.Player)
				--bobby:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				sfx:Play(SoundEffect.SOUND_DERP, 1, 0, false, math.random(140,160)/100)
				bobby:Update()
			end
            mod.scheduleForUpdate(function()
                familiar:RemoveFromFollowers()
                familiar:AddToFollowers()
            end, 10, ModCallbacks.MC_POST_UPDATE, true)
        end
    end
	if sprite:IsFinished("Spawn") then
		sprite:Play("FloatDown", false)
	end
	familiar:FollowParent()
end, mod.ITEM.FAMILIAR.BAG_OF_BOBBIES)

function mod:bobbyBagRoomClear()
	for _, d in pairs(Isaac.FindByType(3, mod.ITEM.FAMILIAR.BAG_OF_BOBBIES, -1, false, false)) do
		local data = d:GetData()
		data.CheckRoomClear = true
	end
end

local bobbyLetters = {"a","b","c","d","e","f","g","h","i","j"}

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local player = familiar.Player
	local data = familiar:GetData()
	local sprite = familiar:GetSprite()
	local isSuperpositioned = mod:isSuperpositionedPlayer(familiar.Player)
	local isSirenCharmed = mod:isSirenCharmed(familiar)

    data.MaxFireCooldown = data.MaxFireCooldown or math.random(15,25)
    data.TearDamageMult = data.TearDamageMult or math.random(80,120)/100
    data.TearColorOffs = data.TearColorOffs or {(-11 + math.random(21))/50, (-11 + math.random(21))/50, (-11 + math.random(21))/50}
	
	if not data.state then
		familiar:AddToFollowers()
		familiar.FireCooldown = data.MaxFireCooldown
		data.state = "Float"
		data.stateframe = 0
        local rand = math.random(3)
        sprite:ReplaceSpritesheet(0, "gfx/familiar/bagofbobbies/familiar_lil_bobby_" .. bobbyLetters[math.random(#bobbyLetters)] .. ".png")
        sprite:LoadGraphics()
	else
		familiar.FireCooldown = familiar.FireCooldown - ((player and player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) and 2) or 1)
		familiar.FireCooldown = math.max(0, familiar.FireCooldown)
		
		data.stateframe = data.stateframe + 1
	end

    if data.iFrames then
        data.iFrames = data.iFrames - 1
        if data.iFrames % 4 == 0 then
            familiar:SetColor(mod.ColorInvisible, 2, 0, false, false)
        end
        if data.iFrames <= 0 then
            data.iFrames = nil
        end
    end
	
	local direction = player:GetFireDirection()
	data.lastdirection = (data.lastdirection ~= nil and data.lastdirection) or direction
	data.lastdirection = (direction ~= Direction.NO_DIRECTION and direction) or data.lastdirection
	if familiar.FireCooldown == 0 and direction ~= Direction.NO_DIRECTION then
		data.stateframe = 0
		data.state = "Shoot"
		familiar.FireCooldown = data.MaxFireCooldown
		
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
			local proj = Isaac.Spawn(9, 0, 0, familiar.Position, velocity, familiar):ToProjectile()
			local projcolor = Color(1.0, 1.0, 1.0, 1, 0/255, 0/255, 0/255)
			projcolor:SetColorize(0.4, 1, 0.5, 1)
			proj.Color = projcolor
		else
			local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, familiar.Position, velocity, familiar):ToTear()
			tear.Height = -23
			tear.FallingSpeed = 0.1 + (math.random() * 2 - 1) * 0.1
			tear.FallingAcceleration = 0
			tear.CollisionDamage = 3.5 * data.TearDamageMult
			tear.Scale = 0.8 * data.TearDamageMult
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
				tear.CollisionDamage = tear.CollisionDamage * 2
				tear.Scale = 1.0 * data.TearDamageMult
			end
			tear:ResetSpriteScale()
			if player:HasTrinket(TrinketType.TRINKET_BABY_BENDER) then
				tear:AddTearFlags(TearFlags.TEAR_HOMING)
				local tearcolor = Color(0.4, 0.15, 0.38, 1, 55/255, 5/255, 95/255)
				tear.Color = tearcolor
			else
				local tearcolor = Color(1 + data.TearColorOffs[1], 1 + data.TearColorOffs[2], 1 + data.TearColorOffs[3], 1, 0, 0, 0)
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
end, FiendFolio.ITEM.FAMILIAR.FRAGILE_BOBBY)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, familiar, collider)
    if collider.Type == EntityType.ENTITY_SIREN_HELPER and 
        collider.Target and 
        collider.Target.Index == familiar.Index and 
        collider.Target.InitSeed == familiar.InitSeed 
    then
        return true
    end

    if collider.Type >= 9 then
        if collider.CollisionDamage > 0 and not (collider:ToNPC() and mod:isFriend(collider:ToNPC())) then
            --print(familiar.HitPoints)
            if familiar.HitPoints > 0 then
                if collider.Type == 9 then
                    collider:Die()
                end
                if not familiar:GetData().iFrames then
                    sfx:Play(SoundEffect.SOUND_BABY_HURT, 1, 0, false, 1)
                    mod:applyFakeDamageFlash(familiar)
                    familiar:GetData().iFrames = 20
                    familiar.HitPoints = familiar.HitPoints - 1
                end
            end
            if familiar.HitPoints <= 0 then
                local sd = familiar.Player:GetData().ffsavedata
                if sd.bobbyBagSpawnCount then
                    sd.bobbyBagSpawnCount = sd.bobbyBagSpawnCount - 1
                    familiar.Player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
                    familiar.Player:EvaluateItems()
                end
                familiar:BloodExplode()
                familiar:Die()
            end
        end
    end
end, mod.ITEM.FAMILIAR.FRAGILE_BOBBY)

function mod:bobbyBaglocustAI(locust, sub)
	if locust.Velocity.X > 0 then
		locust:GetSprite().FlipX = true
	else
		locust:GetSprite().FlipX = false
	end
end
local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, f)
	local d = f:GetData()
	
	d.rng = f.Player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LIL_FIEND)
end, FamiliarVariant.LIL_FIEND)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local data = familiar:GetData()
	local sprite = familiar:GetSprite()

	if sprite:IsFinished("Hit") then
		sprite:Play("Idle", false)
	end

    data.speed = data.speed or 1

    familiar.CollisionDamage = 1

	if sprite:IsPlaying("Idle") then
        local maxSpeed = 1
        local closestDist
        for index,player in ipairs(Isaac.FindInRadius(familiar.Position, 150, EntityPartition.PLAYER)) do
            local dist = player.Position:Distance(familiar.Position)
            if closestDist then
                if dist < closestDist then
                    closestDist = dist
                end
            else
                closestDist = dist
            end
        end
        if closestDist then
            maxSpeed = math.max(0.5, (closestDist * 2/3) / 100)
        end
        data.speed = math.min(maxSpeed, data.speed * 1.2) 
    elseif sprite:IsPlaying("Hit") then 
        data.speed = data.speed * 0.9
    end

	if sprite:IsEventTriggered("Spawn") then
		local spawnNum = 1
		if Sewn_API then
			if Sewn_API:IsUltra(data) then
				spawnNum = 3
			elseif Sewn_API:IsSuper(data) then
				spawnNum = 2
			end
		end

		for i = 1, spawnNum do
			local spood = Isaac.Spawn(1000, EffectVariant.PICKUP_FIEND_MINION, 0, familiar.Position, nilvector, familiar.Player)
			spood:GetData().canreroll = false
			spood.EntityCollisionClass = 4
			spood.Parent = familiar.Player
			spood:GetData().hollow = true
		end

        sfx:Play(SoundEffect.SOUND_MONSTER_ROAR_0, 0.6, 0, false, 1.5)
	end

	familiar:MoveDiagonally(data.speed)
end, FamiliarVariant.LIL_FIEND)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, f, c)
    if c:ToProjectile() or (c:IsEnemy() and not c:HasEntityFlags(EntityFlag.FLAG_NO_TARGET)) then
    	if c:ToProjectile() then
            c:Die()
        end

    	local s = f:GetSprite()
    	local rng = f:GetData().rng or f.Player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LIL_FIEND)

		local babs = mod.GetEntityCount(1000, EffectVariant.PICKUP_FIEND_MINION)
        local procChance, procChanceBFF = babs * 20, babs * 10
    	if s:IsPlaying("Idle") and ((f.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and rng:RandomInt(procChanceBFF) == 0) or rng:RandomInt(procChance) == 0) then
			s:Play("Hit", false)
		end
    end
end, FamiliarVariant.LIL_FIEND)
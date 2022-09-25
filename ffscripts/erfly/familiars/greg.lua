local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.gregPickupPayouts = {
	{Weight = 8, Output = {PickupVariant.PICKUP_COIN, 0}},
	{Weight = 3, Output = {PickupVariant.PICKUP_KEY, 0}},
	{Weight = 5, Output = {PickupVariant.PICKUP_BOMB, 0}},
	{Weight = 2, Output = {PickupVariant.PICKUP_LIL_BATTERY, 2}},
	{Weight = 2, Output = {PickupVariant.PICKUP_PILL, 0}},
	{Weight = 2, Output = {PickupVariant.PICKUP_TAROTCARD, 0}},
}

function mod.randomArrayWeightBased(chosenArray)
	local totalWeight = 0
	for i = 1, #chosenArray do
		totalWeight = totalWeight + chosenArray[i].Weight
	end

	local rand = math.random() * totalWeight
	local chosenEffect = nil
	for i = 1, #chosenArray do
		if rand <= chosenArray[i].Weight then
			chosenEffect = chosenArray[i]
			break
		end
		rand = rand - chosenArray[i].Weight
	end
	if chosenEffect == nil then
		chosenEffect = chosenArray[#chosenArray]
	end
	return chosenEffect.Output
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local d = fam:GetData()
	local sprite = fam:GetSprite()

    fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
	fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND

	if d.hatching and not sprite:IsPlaying("Spawn") then
		d.targvel = nilvector
		fam.Velocity = mod:Lerp(fam.Velocity, d.targvel, 0.3)
		if not d.playedHatchSound then
			sfx:Play(SoundEffect.SOUND_BONE_SNAP, 1, 0, false, math.random(130,150)/100)
			d.playedHatchSound = true
		end
		if sprite:IsFinished("Crack") or d.hatchedOut --[[safety check]] then
			for i = 1, 40 do
				local gib = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TOOTH_PARTICLE, 0, fam.Position, RandomVector() * math.random(5,30)/10, nil)
				gib:Update()
			end
			for i = 1, 10 do
				local gib = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TOOTH_PARTICLE, 0, fam.Position, RandomVector() * math.random(50,150)/10, nil)
				gib:Update()
			end
			local yolk = Isaac.Spawn(1000, 32, 0, fam.Position, nilvector, fam):ToEffect()
			yolk.Scale = 0.8
			yolk.Color = Color(1,1,1,1,1,1,1)
			yolk.CollisionDamage = 0
			for i = 1, 7 do
				yolk:Update()
			end
			fam:Die()
			fam.Player:RemoveCollectible(CollectibleType.COLLECTIBLE_GREG_THE_EGG)
		elseif sprite:IsEventTriggered("Spawn") then
			sfx:Play(SoundEffect.SOUND_BOIL_HATCH,1,1,false,1)
			local ItemPool = game:GetItemPool()
			local babyChoice = ItemPool:GetCollectible(ItemPoolType.POOL_BABY_SHOP, true, fam.InitSeed)

			if not FiendFolio.ACHIEVEMENT.DEVILLED_EGG:IsUnlocked(true) and mod.CanRunUnlockAchievements() then
				FiendFolio.ACHIEVEMENT.DEVILLED_EGG:Unlock()
				babyChoice = CollectibleType.COLLECTIBLE_DEVILLED_EGG
			end

			local pick = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, babyChoice, fam.Position, nilvector, nil)
			pick:GetSprite():ReplaceSpritesheet(5, "gfx/familiar/greg/yolk_pedestal.png")
			pick:GetSprite():LoadGraphics()
			pick:Update()
			pick:Update()
			pick:Update()
			d.hatchedOut = true
		else
			mod:spritePlay(sprite, "Crack")
		end
	elseif d.payout then
		d.targvel = nilvector
		fam.Velocity = mod:Lerp(fam.Velocity, d.targvel, 0.3)
		if sprite:IsFinished("Spawn") then
			d.payout = nil
		elseif sprite:IsEventTriggered("Spawn") then
			local pickout = mod.randomArrayWeightBased(mod.gregPickupPayouts)
			local pickup = Isaac.Spawn(5, pickout[1], pickout[2], fam.Position, nilvector, fam)
		elseif sprite:IsEventTriggered("Sound") then
			sfx:Play(SoundEffect.SOUND_FART, 0.5, 0, false, math.random(130,140)/100)
		else
			mod:spritePlay(sprite, "Spawn")
		end
	else --Idle state
		if fam.FrameCount % 30 == 0 or (not d.targvel) then
			if math.random(2) == 1 then
				d.targvel = nilvector
			else
				d.targvel = Vector(math.random(-2, 2), math.random(-2,2))
			end
		end
		if d.targvel then
			fam.Velocity = mod:Lerp(fam.Velocity, d.targvel, 0.3)
			if fam.Velocity:Length() > 0.1 then
				if fam.Velocity.X < 0 then
					mod:spritePlay(sprite, "WalkingLeft")
				else
					mod:spritePlay(sprite, "Walking")
				end
			else
				mod:spritePlay(sprite, "Idle")
			end
			
		end
	end

end, FamiliarVariant.GREG)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, fam, collider)
    if collider:ToProjectile() then
    	collider:Die()
		local d = fam:GetData()
		d.gregHits = d.gregHits or 0
		d.gregHits = d.gregHits + 1
		if d.gregHits > 5 then
			local rng = fam:GetDropRNG()
			if rng:RandomInt(100) + 1 <= 2 * (d.gregHits - 5) then
				d.hatching = true
			end
		end
    end
end, FamiliarVariant.GREG)

function mod:gregRoomClear()
    for _, fam in pairs(Isaac.FindByType(3, FamiliarVariant.GREG, -1, false, false)) do
		local rng = fam:GetDropRNG()
		if rng:RandomInt(100) + 1 <= 35 then
			local d = fam:GetData()
			d.payout = true
			--print("payout")
		end
	end
end
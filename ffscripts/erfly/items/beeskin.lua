local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local function temptearflagthing(x) -- because the one in enums.lua is broke
	return x >= 64 and BitSet128(0,1<<(x - 64)) or BitSet128(1<<x,0)
end

function mod:beeSkinPostFire(player, tear, rng, pdata, tdata, ignorePlayerEffects, isLudo)
	--Bee Skin
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BEE_SKIN) and
	   not ignorePlayerEffects and
	   not pdata.bertranwashere
	then
		local isFiring = false
		local height = nil
		local fallingspeed = nil
		local fallingaccel = nil
		local flags = nil
		if isLudo and not game:GetRoom():IsClear() then
			isFiring = true
			fallingspeed = player.TearFallingSpeed
			height = player.TearHeight
			fallingaccel = player.TearFallingAcceleration
			flags = tear.TearFlags & ~temptearflagthing(127)
		elseif not isLudo and tear.CanTriggerStreakEnd then
			isFiring = true
			fallingspeed = tear.FallingSpeed
			height = tear.Height
			fallingaccel = tear.FallingAcceleration
			flags = tear.TearFlags
		end

		if isFiring then
			pdata.BeeSkinAngle = (pdata.BeeSkinAngle or -110) + 20
			local vel = Vector.FromAngle(pdata.BeeSkinAngle) * 8 * player.ShotSpeed
			local numberOfBees = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BEE_SKIN)
			local numshots = math.min(2 + numberOfBees, 8)

			for i = 1, numshots do
				local shotvel = vel:Rotated((360 / numshots) * i) + player.Velocity
				local beeskintear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0,player.Position, shotvel, player):ToTear()
				beeskintear.FallingSpeed = fallingspeed
				beeskintear.Height = height
				beeskintear.FallingAcceleration = fallingaccel
				beeskintear.TearFlags = flags
				beeskintear.CollisionDamage = tear.CollisionDamage * 0.3
				beeskintear.Parent = player
				beeskintear.Scale = tear.Scale * 0.8
			end
		end
	end
end

function mod:beeSkinPostFireBomb(player, bomb, rng, pdata, bdata)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BEE_SKIN) and
	   not pdata.bertranwashere and
       not bdata.beeSkinBomb and
       math.random(7) == 1
	then
        pdata.BeeSkinAngle = (pdata.BeeSkinAngle or -110) + 20
        local vel = Vector.FromAngle(pdata.BeeSkinAngle) * 8 * player.ShotSpeed
        local numberOfBees = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BEE_SKIN)
        local numshots = math.min(2 + numberOfBees, 8)

        for i = 1, numshots do
            local shotvel = vel:Rotated((360 / numshots) * i) + player.Velocity
            local beebomb = player:FireBomb(bomb.Position + shotvel:Resized(bomb.Size + 5), shotvel, player)
            beebomb:GetData().beeSkinBomb = true
        end
    end
end

--[[function mod:beeSkinPostBombUpdate(bomb, data)

end]]

function mod:beeSkinPostFireKnife(player, knife, rng)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BEE_SKIN) then
		local pdata = player:GetData()
		if not pdata.bertranwashere then
			pdata.BeeSkinAngle = (pdata.BeeSkinAngle or -110) + 20
			local numberOfBees = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BEE_SKIN)
			local numshots = math.min(2 + numberOfBees, 8)
			for i = 1, numshots do
				local ang = (360/numshots) * i
				local newknife = player:FireKnife(player, pdata.BeeSkinAngle + ang, false, 0, 0):ToKnife()
				newknife.CollisionDamage = knife.CollisionDamage * 0.3
				newknife.Rotation = pdata.BeeSkinAngle + ang
				newknife:Shoot(knife.Charge, player.TearRange)
				newknife:GetData().RemoveOnReturn = true
				newknife:GetData().WasFlying = true
				newknife.Scale = knife.Scale * 0.5
				newknife.SpriteScale = knife.SpriteScale * 0.5
				newknife:Update()
			end
		end
	end
end

function mod:beeskinPostFireLaser(player, laser)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BEE_SKIN) then
		if laser.TearFlags ~= laser.TearFlags | TearFlags.TEAR_LASERSHOT then
			if laser.Parent and laser.Parent.InitSeed == player.InitSeed then
				if (laser.Timeout == 1 or laser.OneHit) then
					local pdata = player:GetData()
					if not laser:GetData().noMoreBeeSkin and not laser:GetData().FFMultiEuclideanTearSpawner then
						pdata.BeeSkinAngle = (pdata.BeeSkinAngle or -110) + 20
						local numberOfBees = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BEE_SKIN)
						local numshots = math.min(2 + numberOfBees, 8)
						for i = 1, numshots do
							angle = pdata.BeeSkinAngle + ((360/numshots) * i)
							local newlaser = player:FireTechLaser(player.Position, LaserOffset.LASER_TECH5_OFFSET, Vector.FromAngle(angle), false, true, player, 0.3)
							newlaser:GetData().noMoreBeeSkin = true
							newlaser.OneHit = true
							newlaser.Timeout = 1
						end
					end
				end
			end
		end
	end
end

local brimLasers = {
	[1] = true,
	[3] = true,
	[4] = true,
	[5] = true,
	[9] = true,
	[11] = true,
	[12] = true,
	[14] = true,
}

function mod:beeSkinLaserUpdate(player, laser, data, rng)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BEE_SKIN) then
		if laser.TearFlags ~= laser.TearFlags | TearFlags.TEAR_LASERSHOT then
			if brimLasers[laser.Variant] then
				if laser.FrameCount % 3 == 2 then
					local pdata = player:GetData()
					pdata.BeeSkinAngle = (pdata.BeeSkinAngle or -110) + 20
					local vel = Vector.FromAngle(pdata.BeeSkinAngle) * 8 * player.ShotSpeed
					local numberOfBees = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BEE_SKIN)
					local numshots = math.min(2 + numberOfBees, 8)

					for i = 1, numshots do
						local shotvel = Vector(player.ShotSpeed * 10, 0):Rotated((360 / numshots) * i):Rotated(pdata.BeeSkinAngle)
						local beeskintear = player:FireTear(player.Position, shotvel, true, true, false, player, 0.3):ToTear()
						beeskintear.Scale = beeskintear.Scale * 0.8
					end
				end
			end
		end
	end
end

function mod:beeSkinlocustAI(fam, sub)
	if fam.FireCooldown == -1 then
		local d = fam:GetData()
		local p = fam.Player or Isaac.GetPlayer()
		if fam.FrameCount % 5 == 1 then
			d.BeeSkinAngle = (d.BeeSkinAngle or -110) + 20
			local vel = Vector.FromAngle(d.BeeSkinAngle):Resized(8) + (fam.Velocity)
			local beeskintear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, fam.Position + fam.Velocity, vel, fam):ToTear()
			--print(fam.FireCooldown)
			beeskintear.CollisionDamage = mod:getLocustDamage(fam) * 0.1
			beeskintear.Scale = beeskintear.Scale * 0.3
			beeskintear:Update()
		end
	end
end
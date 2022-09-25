local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:firePiss(player, fireVec)
	sfx:Play(mod.Sounds.Plorp, 0.3, 0, false, math.random(130,150)/100)
	local splat = Isaac.Spawn(1000, 1960, 33, player.Position, nilvector, player):ToEffect()
	splat.Color = mod.ColorPissGood
	--print(player.Size)
	splat.SpriteOffset = Vector(0, (-35 * player.SpriteScale.Y))
	splat.SpriteScale = (Vector.One * (player.Size/2)) / 10
	splat:FollowParent(player)
	splat:Update()
	local spurts = 10
	for i = 1, spurts do
		--local newtear = player:FireTear(player.Position, tear.Velocity:Rotated(math.random(60) - 30):Resized(math.random(20,100)/10), false, true, false):ToTear()
		local newtear = Isaac.Spawn(2, 0, 0, player.Position, fireVec:Rotated(math.random(60) - 30):Resized(math.random(20,100)/10), player):ToTear()
		local scalecalc = math.random(30,60) / 100
		newtear.Scale = scalecalc
		newtear.FallingSpeed = -25 - math.random(5)
		newtear.FallingAcceleration = 1.5 + (math.random() * 0.5)
		newtear.Height = -15
		newtear.CanTriggerStreakEnd = false
		newtear.Color = mod.ColorPissGood
		newtear:GetData().DMG = player.Damage * 0.3
		newtear.CollisionDamage = mod:LuaRound(scalecalc, 1)
		newtear:GetData().PissPuddler = true
        newtear.TearFlags = newtear.TearFlags | TearFlags.TEAR_PIERCING
		newtear:Update()
	end
end

function mod:devilsUmbrellaPostFire(player, tear, rng, pdata, tdata, ignorePlayerEffects, isLudo)
	--Devil's Umbrella
	if player:HasCollectible(CollectibleType.COLLECTIBLE_DEVILS_UMBRELLA) and
	   not ignorePlayerEffects and
	   math.random(5) == 1 and
	   not pdata.bertranwashere
	then
		local dir = nil
		if isLudo and not game:GetRoom():IsClear() then
			dir = tear.Position - player.Position
		elseif not isLudo and tear.CanTriggerStreakEnd then
			dir = tear.Velocity
		end

		if dir ~= nil then mod:firePiss(player, dir) end
	end
end

function mod:devilsUmbrellaPostFireBomb(player, bomb, rng)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_DEVILS_UMBRELLA) and
	   math.random(5) == 1 and
	   not player:GetData().bertranwashere
	then
        mod:firePiss(player, bomb.Velocity)
    end
end

function mod:devilsUmbrellaPostFireLaser(player, laser, rng)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_DEVILS_UMBRELLA) and
	   math.random(5) == 1 and
	   not player:GetData().bertranwashere
	then
        mod:firePiss(player, Vector(1,0):Rotated(laser.AngleDegrees))
    end
end

function mod:devilsUmbrellaPostFireKnife(player, knife, rng)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_DEVILS_UMBRELLA) and
	   math.random(5) == 1 and
	   not player:GetData().bertranwashere
	then
        mod:firePiss(player, Vector(1,0):Rotated(knife.Rotation))
    end
end

function mod:devilsUmbrellaLocustAI(fam)
	if fam.FireCooldown == -1 then
		local piss = Isaac.Spawn(1000, 46, 0, fam.Position, nilvector, fam):ToEffect()
		local pisscolor = Color(1,1,1,1,0,0,0)
		pisscolor:SetColorize(7, 7, 1, 1)
		piss.Color = pisscolor
		piss.CollisionDamage = mod:getLocustDamage(fam, 0.1)
		piss.Timeout = 60
		piss.Scale = 0.5
		piss:Update()
	end
end
local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local LambDirs = {
	[Direction.NO_DIRECTION] = {Anim = "Down", FlipX = false},
	[Direction.LEFT] = {Anim = "Side", FlipX = true},
	[Direction.RIGHT] = {Anim = "Side", FlipX = false},
	[Direction.UP] = {Anim = "Up", FlipX = false},
	[Direction.DOWN] = {Anim = "Down", FlipX = false},
}

function mod:lilLambAI(familiar)
	local player = familiar.Player
	local d = familiar:GetData()
	local sprite = familiar:GetSprite()
	local isSuperpositioned = mod:isSuperpositionedPlayer(familiar.Player)
	local isSirenCharmed = mod:isSirenCharmed(familiar)
	local isKingBabyTarget = mod:isKingBabyAParent(familiar, true)
	
	if not d.state then
		mod:spritePlay(sprite, "FloatDown")
		d.state = "idle"
		familiar.FireCooldown = 0
	else
		--d.stateframe = d.stateframe + 1
		familiar.FireCooldown = math.max(0, familiar.FireCooldown - 1)
	end

	d.chargeTimer = 30
	if player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) then
		d.chargeTimer = 15
	end

	local headString = ""
	local deadTarget
	if d.isDead then
		headString = "Head"
		if not d.AppearedDead then
			d.AppearedDead = true
			sfx:Play(SoundEffect.SOUND_MEATHEADSHOOT,1,0,false,1.3)
			mod:spritePlay(sprite, "HeadAppear")
		end
		deadTarget = mod.FindClosestEnemy(familiar.Position, 250, true)
	end

	local targetPos
	if isSirenCharmed then
		local Targplayer = mod:getClosestPlayer(familiar.Position, 800)
		if Targplayer then
			targetPos = Targplayer.Position
		end
	elseif isKingBabyTarget then
		targetPos = isKingBabyTarget.Position
	elseif deadTarget then
		targetPos = deadTarget.Position
	end

	local aimDir = player:GetFireDirection()
	local moveDir = player:GetHeadDirection()
	local calcDir
	if targetPos then
		local realDir = (targetPos - familiar.Position)
		if math.abs(realDir.X) < math.abs(realDir.Y) then
			if realDir.Y > 0 then
				calcDir = 3
			else
				calcDir = 1
			end
		else
			if realDir.X > 0 then
				calcDir = 2
			else
				calcDir = 0
			end
		end
	end
	if calcDir then
		if aimDir and aimDir ~= Direction.NO_DIRECTION then
			aimDir = calcDir
		end
	end
	if d.isDead then
		if calcDir then
			aimDir = calcDir
			moveDir = calcDir
		else
			aimDir = -1
			moveDir = -1
		end
	end

	if sprite:IsPlaying("HeadAppear") then
		--a
	elseif d.isDead and game:GetRoom():IsClear() then
		game:Darken(1, 2)
		d.isCharging = false
		d.chargeCount = 0
		if sprite:IsFinished("HeadSleepStart") then
			mod:spritePlay(sprite, "HeadSleepIdle")
		elseif not (sprite:IsPlaying("HeadSleepStart") or sprite:IsPlaying("HeadSleepIdle")) then
			mod:spritePlay(sprite, "HeadSleepStart")
		end
	elseif d.state == "idle" then
		d.chargeCount = d.chargeCount or 0
		local shouldCharge
		if targetPos and d.chargeCount > d.chargeTimer then
			shouldCharge = false
		elseif (aimDir and aimDir ~= Direction.NO_DIRECTION) 
		or (d.isCharging and not player:IsExtraAnimationFinished()) 
		or (d.isDead or isSirenCharmed) 
		or (d.isCharging and player:IsDead()) then
			shouldCharge = true
		end
		if shouldCharge then
			if deadTarget or player:IsExtraAnimationFinished() or d.chargeCount > d.chargeTimer then
				d.chargeCount = d.chargeCount + 1
			end
			d.fireDirection = aimDir
			d.isCharging = true
			sprite:SetFrame(headString .. "FloatCharge" .. LambDirs[moveDir].Anim, math.min(d.chargeCount * (30/d.chargeTimer), 30) - 1)
			sprite.FlipX = LambDirs[moveDir].FlipX
			if d.chargeCount > d.chargeTimer then
				if d.chargeCount % 4 == 1 then
					familiar:SetColor(Color(1,1,1,1,0.1,0,0), 2, 1, false, false)
				end
			end
		elseif d.chargeCount and d.chargeCount > d.chargeTimer then
			d.isCharging = false
			d.state = "postFire"
			mod:spritePlay(sprite, headString .. "FloatShoot" .. LambDirs[d.fireDirection].Anim)
			sprite.FlipX = LambDirs[d.fireDirection].FlipX
			familiar.FireCooldown = 21
			d.chargeCount = 0
			sfx:Play(SoundEffect.SOUND_MONSTER_GRUNT_0,1,0,false,1.6)
			local vec = Vector(-1,0):Rotated(d.fireDirection * 90)
			if isSirenCharmed then
				local proj = Isaac.Spawn(9, 0, 0, familiar.Position, vec:Resized(10), familiar):ToProjectile()
				proj:AddProjectileFlags (ProjectileFlags.EXPLODE)
				proj:AddScale(0.5)
				proj.FallingAccel = 0.5
				proj.FallingSpeed = -8
				local MetalColor = Color(1,1,1,1)
				MetalColor:SetColorize(0.7, 0.7, 1, 1)
				proj.Color = MetalColor
				proj:Update()
			else
				local tear = familiar:FireProjectile(vec)
				if targetPos then
					tear.Velocity = (targetPos - familiar.Position):Resized(10)
				end
				
				tear.TearFlags = tear.TearFlags | TearFlags.TEAR_EXPLOSIVE
				if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
					tear.CollisionDamage = 50
					tear.Scale = 1.2
				else
					tear.CollisionDamage = 25
					tear.Scale = 1.1
				end
				tear.FallingAcceleration = 0.5
				tear.FallingSpeed = -8
				--tear:ChangeVariant(19)
				--local MetalColor = Color(1.1,1.1,1.1,1,0,-0.03,0.07)
				--local MetalColor = Color(400/255,375/255,425/255,1,-0.2,-0.2,-0.2)
				tear:ChangeVariant(1)
				local alpha = 1
				if isSuperpositioned then
					tear.CollisionDamage = tear.CollisionDamage/4
					alpha = alpha/4
				end
				local MetalColor = Color(1,1,1,alpha)
				if player:HasTrinket(TrinketType.TRINKET_BABY_BENDER) then
					MetalColor = Color(1,1,1,alpha,0.26, 0.05, 0.4)
				end
				MetalColor:SetColorize(0.7, 0.7, 1, 1)
				tear.Color = MetalColor
			end

		else
			d.isCharging = false
			d.chargeCount = 0
			mod:spritePlay(sprite, headString .. "Float" .. LambDirs[moveDir].Anim)
			sprite.FlipX = LambDirs[moveDir].FlipX
		end
	elseif d.state == "postFire" then
		d.isCharging = false
		mod:spritePlay(sprite, headString .. "FloatShoot" .. LambDirs[d.fireDirection].Anim)
		sprite.FlipX = LambDirs[d.fireDirection].FlipX
		if familiar.FireCooldown < 1 then
			d.state = "idle"
		end
	end

	if d.chargeCount and d.chargeCount > 1 then
		d.chargebarCanDisappear = true
	elseif d.chargebarCanDisappear then
		d.chargeDisappearTimer = d.chargeDisappearTimer or 0
		if d.chargeDisappearTimer >= 9 then
			d.chargeDisappearTimer = nil
			d.chargebarCanDisappear = nil
		else
			d.chargeDisappearTimer = d.chargeDisappearTimer + 1
		end		
	end
	
	if d.isDead then
		familiar.Mass = 30
		if familiar.IsFollower then
			familiar:RemoveFromFollowers()
		end
		if not familiar.Child then
			local body = Isaac.Spawn(3, FamiliarVariant.LIL_LAMB, 1, familiar.Position, nilvector, player)
			familiar.Child = body
			body.Parent = familiar
			body:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			body:Update()
			d.orbitVec =  ((familiar.Position + familiar.Velocity) - body.Position):Normalized()
			if familiar.Velocity.X < 0 then
				d.orbitDir = -1
				body:GetSprite().FlipX = true
			else
				d.orbitDir = 1
			end
		end
		if familiar.Child then
			d.orbitVec = d.orbitVec or ((familiar.Position + familiar.Velocity) - familiar.Child.Position):Normalized()
			if d.orbitVec:Length() < 0.1 then
				d.orbitVec = RandomVector()
			end
			if not d.orbitDir then
				if familiar.Velocity.X < 0 then
					d.orbitDir = -1
				else
					d.orbitDir = 1
				end
			end
			local orbitDist = 50
			local orbitSpeed = 3
			if game:GetRoom():IsClear() then
				orbitDist = 0
				orbitSpeed = 1.5
				familiar.SpriteOffset = mod:Lerp(familiar.SpriteOffset, Vector(0, 9), 0.1)
			end
			d.orbitVec = d.orbitVec:Rotated(d.orbitDir * orbitSpeed)
			local targetpos = familiar.Child.Position + d.orbitVec:Resized(orbitDist)
			local targetvec = targetpos - familiar.Position
			if targetvec:Length() > 5 then
				targetvec = targetvec:Resized(5)
			end
			familiar.Velocity = mod:Lerp(familiar.Velocity, targetvec, 0.1)
		else
			familiar.Velocity = familiar.Velocity * 0.9
		end
	else
		if not familiar.IsFollower then
			familiar:AddToFollowers()
		end
		familiar:FollowParent()
	end
end

function mod:lilLambBodyAI(familiar)
	local player = familiar.Player
	local d = familiar:GetData()
	local sprite = familiar:GetSprite()
	local isSuperpositioned = mod:isSuperpositionedPlayer(familiar.Player)
	local isSirenCharmed = mod:isSirenCharmed(familiar)

	familiar.Mass = 30
	familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
	familiar.Velocity = familiar.Velocity * 0.7
	familiar.DepthOffset = -5

	if not d.init then
		if game:GetRoom():IsClear() then
			mod:spritePlay(sprite, "BodySleepIdle")
		else
			mod:spritePlay(sprite, "BodyAppear")
		end
		d.init = true
	end
	if not sprite:IsPlaying("BodyAppear") then
		if game:GetRoom():IsClear() then
			if sprite:IsFinished("BodySleepStart") then
				mod:spritePlay(sprite, "BodySleepIdle")
			elseif not (sprite:IsPlaying("BodySleepStart") or sprite:IsPlaying("BodySleepIdle")) then
				mod:spritePlay(sprite, "BodySleepStart")
				if not d.playedDyingSound then
					d.playedDyingSound = true
					sfx:Play(SoundEffect.SOUND_FIREDEATH_HISS, 0.5, 0, false, 1.5)
				end
			end
		else
			if sprite:IsFinished("BodyAppear") then
				mod:spritePlay(sprite, "BodyLying")
			elseif not (sprite:IsPlaying("BodyAppear") or sprite:IsPlaying("BodyLying")) then
				mod:spritePlay(sprite, "BodyAppear")
			end
		end
	end
		
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	if familiar.SubType == 1 then
		mod:lilLambBodyAI(familiar)
	else
		mod:lilLambAI(familiar)
	end
end, FamiliarVariant.LIL_LAMB)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, familiar, collider)
	if familiar.SubType == 1 then
		local isSirenCharmed = mod:isSirenCharmed(familiar)
		if (collider.Type > 9 or (isSirenCharmed and collider.Type == 1)) and collider.EntityCollisionClass > 0 then
			if not game:GetRoom():IsClear() then
				if not collider:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
					collider:TakeDamage(1, DamageFlag.DAMAGE_FIRE, EntityRef(familiar), 0)
				end
			end
		end
	end
end, FamiliarVariant.LIL_LAMB)

function mod.updateLilLambOnNewRoom()
	local lambsRemoved
	for _, lamb in pairs(Isaac.FindByType(3, FamiliarVariant.LIL_LAMB, -1, false, false)) do
		if lamb.SubType == 1 then
			lamb:Remove()
		else
			lamb = lamb:ToFamiliar()
			local d = lamb:GetData()
			d.deadHits = 0
			if d.isDead then
				lambsRemoved = lamb.Player
				lamb:Remove()
			end
		end
	end
	if lambsRemoved then
		lambsRemoved:RespawnFamiliars()
	end
end

mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, function(_, familiar, offset)
	if not Options.ChargeBars then return end

	local d = familiar:GetData()
	if not d.chargeTimer then return end

	local sprite = Sprite()
	sprite:Load("gfx/chargebar.anm2", true)
	if d.chargeCount and d.chargeCount > 1 then
		d.chargeDisappearTimer = 0
		if d.chargeCount > d.chargeTimer + 12 then
			sprite:SetFrame("Charged", (d.chargeCount - (d.chargeTimer + 13)) % 6)
		elseif d.chargeCount > d.chargeTimer then
			sprite:SetFrame("StartCharged", (d.chargeCount - (d.chargeTimer + 1)))
		else
			sprite:SetFrame("Charging", math.floor(((d.chargeCount - 1)/d.chargeTimer) * 100))
		end
	elseif d.chargeDisappearTimer then
		sprite:SetFrame("Disappear", math.floor(d.chargeDisappearTimer - 1))
	end
	--print(game:GetRoom():GetRenderScrollOffset(), offset)
	local famOffset = Vector(18.5, -54)
	local pos = Isaac.WorldToRenderPosition(familiar.Position + famOffset) + offset
	sprite:Render(pos, nilvector, nilvector)
end, FamiliarVariant.LIL_LAMB)

function mod:lilLambPlayerHurt(player)
	if game:GetRoom():IsClear() then return end
	for _, lamb in pairs(Isaac.FindByType(3, FamiliarVariant.LIL_LAMB, -1, false, false)) do
		local d = lamb:GetData()
		d.deadHits = d.deadHits or 0
		d.deadHits = d.deadHits + 1
		if math.random(3) <= d.deadHits then
			d.isDead = true
		end
	end
end
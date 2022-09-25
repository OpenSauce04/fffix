local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:grabberItemQueueCheck(player, data)
	local queueItemData = player.QueuedItem
	if queueItemData.Item and queueItemData.Item.ID == CollectibleType.COLLECTIBLE_GRABBER then
		if sfx:IsPlaying(SoundEffect.SOUND_CHOIR_UNLOCK) then
			sfx:Stop(SoundEffect.SOUND_CHOIR_UNLOCK)
			sfx:Play(mod.Sounds.ClapPickup, 1, 0, false, 1)
		end
	end
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, fam)
	fam.Color = Color(1,1,1,0)
end, mod.ITEM.FAMILIAR.GRABBER)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local d = fam:GetData()
	local sprite = fam:GetSprite()
	local isSirenCharmed, charmer = mod:isSirenCharmed(fam)
	
	if charmer then
		charmer.CollisionDamage = 0
	end

	local room = Game():GetRoom()
	if room:GetFrameCount() <= 5 or fam.FrameCount <= 10 then
		fam.Color = Color(fam.Color.R,fam.Color.G,fam.Color.B,math.min(room:GetFrameCount()/5, 1), fam.Color.RO, fam.Color.GO, fam.Color.BO)
	end
	--Hand
	if fam.SubType == 1 or fam.SubType == 2 then
		if Sewn_API then
			d.Sewn_noUpgrade = Sewn_API.Enums.NoUpgrade.ANY
		end
		
		if not isSirenCharmed and fam.Parent then
			fam.Player = fam.Parent:ToFamiliar().Player
		end
		
		local p = fam.Player
		if p:HasTrinket(TrinketType.TRINKET_BABY_BENDER) then
			fam.Color = Color(2,1,2,fam.Color.A,100 / 255,-100 / 255,100 / 255)
		elseif not isSirenCharmed then
			fam.Color = Color(1,1,1,fam.Color.A)
		end
		if fam.Parent then
			fam.RenderZOffset = 100
			if not d.init then
				fam.SpriteOffset = Vector(0, -10)
				d.state = "idle"
				d.StateFrame = 0
				d.init = true
			else
				d.StateFrame = d.StateFrame or 0
				d.StateFrame = d.StateFrame + 1
			end

			local offVec = (fam.Player.Position - fam.Parent.Position):Resized(20)
			if d.upgradeOffset then
				offVec = offVec:Rotated(d.upgradeOffset)
			end
			fam.Velocity = fam.Parent.Velocity

			if d.state == "idle" then
				mod:spritePlay(sprite, "HandRetract")
				fam.CollisionDamage = 0
				d.lerpness = d.lerpness or 1
				if d.lerpness < 0.5 then
					if Sewn_API and (Sewn_API:IsSuper(fam.Parent:GetData(), true)) then
						d.lerpness = d.lerpness + 0.2
					else
						d.lerpness = d.lerpness + 0.02
					end
				end
				local targpos = fam.Player
				if fam.Player:HasTrinket(TrinketType.TRINKET_BABY_BENDER) then
					targpos = mod.FindClosestEnemy(fam.Position, 500) or targpos
				end
				targpos = targpos.Position
				local offVec = (targpos - fam.Parent.Position):Resized(20)
				if d.upgradeOffset then
					offVec = offVec:Rotated(d.upgradeOffset)
				end
				fam.Position = mod:Lerp(fam.Position, fam.Parent.Position + offVec, d.lerpness)
				if d.StateFrame > 30 or (Sewn_API and Sewn_API:IsSuper(fam.Parent:GetData()) and d.StateFrame > 4) then
					d.state = "shoot"
					mod:spritePlay(sprite, "HandShoot")
					if d.upgradeOffset then
						offVec = offVec:Rotated(d.upgradeOffset * -0.8)
					end
					d.shootvec = offVec
					d.shootspeed = 18
					d.parentoffset = 18
				end
			elseif d.state == "shoot" then
				offVec = d.shootvec
				d.shootspeed = d.shootspeed or 18
				d.parentoffset = d.parentoffset or 18

				d.shootspeed = d.shootspeed - 1
				d.parentoffset = d.parentoffset + d.shootspeed

				if d.shootspeed <= -15 then
					d.state = "idle"
					d.StateFrame = 0
					d.lerpness = 0.05
				else
					if d.shootspeed < -5 then
						mod:spritePlay(sprite, "HandRetract")
					end
				end

				fam.Position = mod:Lerp(fam.Position, fam.Parent.Position + d.shootvec:Resized(d.parentoffset), 0.2)
			elseif d.state == "grab" then
				mod:spritePlay(sprite, "HandGrab")
				
				--fam.CollisionDamage = 1
				if d.target and d.target:Exists() and d.target.Type > 9 then
					if fam.FrameCount % 7 == 0 then
						if (isSirenCharmed and mod:isFriend(d.target)) or (not isSirenCharmed and not mod:isFriend(d.target)) then
							d.target:TakeDamage(1, 0, EntityRef(nil), 0)
						end
					end
				end
				
				if d.target and (d.target.Type == 1 or d.target.Type == 3) and fam.Parent.Position:Distance(fam.Position) < 15 then
					d.StateFrame = 30
				end
				if d.target and d.target:Exists() and d.StateFrame < 30 and d.target.EntityCollisionClass > 0 then
					offVec = (d.target.Position - fam.Parent.Position):Resized(20)
					if d.target.Type == 3 then
						d.target.Velocity = d.target.Velocity + (fam.Parent.Position - d.target.Position):Resized(15)
					else
						d.target.Velocity = d.target.Velocity + (fam.Parent.Position - d.target.Position):Resized(d.StateFrame / 5)
					end
					fam.Position = d.target.Position
				else
					d.state = "idle"
					d.StateFrame = 0
					d.lerpness = 0.05
				end
			elseif d.state == "pet" then
				if sprite:IsFinished("HandPat") or d.target.Velocity:Length() > 0.1 then
					d.target = nil
				else
					mod:spritePlay(sprite, "HandPat")
				end
				if sprite:GetFrame() > 40 or sprite:GetFrame() < 15 then
					fam.RenderZOffset = -100
				end
				if d.target and d.target:Exists() then
					if sprite.FlipX then
						offVec = Vector(-1,0)
					else
						offVec = Vector(1,0)
					end
					fam.Position = d.target.Position
				else
					d.state = "idle"
					d.StateFrame = 0
					d.lerpness = 0.05
				end
			end

			if d.state == "idle" then
				offVec = (fam.Position - fam.Parent.Position)
				if d.upgradeOffset then
					offVec = offVec:Rotated(d.upgradeOffset * -0.8)
				end
			end
			local realAng = offVec:GetAngleDegrees()
			if d.upgradeOffset then
				if fam.SubType ~= 2 then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end
			else
				if offVec.X > 0 then
					sprite.FlipX = false
				else
					sprite.FlipX = true
				end
			end
			if sprite.FlipX then
				fam.SpriteRotation = (realAng * -1) + 180
			else
				fam.SpriteRotation = realAng
			end
		else
			fam:Remove()
		end

	--Main body
	else
		fam.CollisionDamage = 0
		local room = Game():GetRoom()
		if not fam.Child then
			fam.SpriteOffset = Vector(0, -5)
			mod.scheduleForUpdate(function()
				if Sewn_API and Sewn_API:IsUltra(d) then
					for i = 1, 2 do
						local hand = Isaac.Spawn(3, FamiliarVariant.GRABBER, i, fam.Position, nilvector, fam):ToFamiliar()
						fam.Child = hand
						hand.Parent = fam
						hand.Player = fam.Player
						hand:GetData().upgradeOffset = 30
						if i == 2 then
							hand:GetData().upgradeOffset = -30
						end
						hand:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
						hand:Update()
						
						d.Hands = d.Hands or {}
						table.insert(d.Hands, hand)
					end
				else
					local hand = Isaac.Spawn(3, FamiliarVariant.GRABBER, 1, fam.Position, nilvector, fam):ToFamiliar()
					fam.Child = hand
					hand.Parent = fam
					hand.Player = fam.Player
					hand:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					hand:Update()
					
					d.Hands = d.Hands or {}
					table.insert(d.Hands, hand)
				end
			end, 1)
		end

		-- this is already handled in MC_EVALUATE_CACHE in main.lua
		-- also it can cause grabber to duplicate
		-- still leaving this here cause why not
		--[[local grabbers = Isaac.FindByType(3, FamiliarVariant.GRABBER, -1)
		local lowerSeedGrabbers = {}
		for i = 1, #grabbers do
			if grabbers[i].SubType ~= 10 and grabbers[i].SubType ~= 11 then
				if grabbers[i].InitSeed ~= fam.InitSeed then
					if grabbers[i].InitSeed < fam.InitSeed then
						table.insert(lowerSeedGrabbers, grabbers[i])
					end
				end
			end
		end
		if #lowerSeedGrabbers == 1 then
			fam.SubType = 10
		elseif #lowerSeedGrabbers > 1 then
			fam.SubType = 11
		else
			fam.SubType = 0
		end]]--

		if math.random(100) == 1 then
			mod:spritePlay(sprite, "Blink")
		end
		if not sprite:IsPlaying("Blink") then
			mod:spritePlay(sprite, "Walk")
		end

		d.lerpness = d.lerpness or 0.3

		if fam.Child and fam.Child:GetData().state == "grab" then
			fam.Velocity = fam.Velocity * 0.8
			d.lerpness = 0.04
		else
			local roomVec = fam.Player.Position - room:GetCenterPos()
			local targpos = room:GetCenterPos() + (roomVec * -1)
			if fam.SubType == 10 then
				targpos = room:GetCenterPos() + Vector(roomVec.X, roomVec.Y * -1)
			elseif fam.SubType == 11 then
				targpos = room:GetCenterPos() + Vector(roomVec.X * -1, roomVec.Y)
			end
			local targvec = targpos - fam.Position
			if d.lerpness < 0.3 then
				d.lerpness = d.lerpness + 0.002
			end
			local lerpOverride
			if room:GetFrameCount() < 2 then
				lerpOverride = 1
			end
			fam.Velocity = mod:Lerp(fam.Velocity, targvec, lerpOverride or d.lerpness)
			if (not lerpOverride) and fam.Velocity:Length() > targvec:Length() / 3 then
				fam.Velocity = fam.Velocity:Resized(targvec:Length() / 3)
			end
		end
	end

end, FamiliarVariant.GRABBER)

local function grabCollider(familiar, collider)
	--sfx:Play(mod.Sounds.CrowdCheer, 1, 0, false, 1)
	familiar:GetData().state = "grab"
	familiar:GetData().target = collider
	familiar:GetData().StateFrame = 0
	if collider.Type > 9 then
		collider:BloodExplode()
		collider:TakeDamage(1, 0, EntityRef(nil), 0)
	end
end

local function petCollider(familiar, collider)
	familiar:GetData().state = "pet"
	familiar:GetData().target = collider
	familiar:GetData().StateFrame = 0
end

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, familiar, collider)
	if collider.Type > 9 or (collider.Type == 4 and (collider.Variant == 3 or collider.Variant == 4)) or collider.Type == 1  and collider.EntityCollisionClass > 0 then
		if not collider:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
			if (familiar.SubType == 1 or familiar.SubType == 2) and familiar:GetData().state == "shoot" then
				local isSirenCharmed = mod:isSirenCharmed(familiar)
				
				if collider.Type == EntityType.ENTITY_PLAYER then
					if isSirenCharmed or Isaac.GetChallenge() == mod.challenges.handsOn then
						grabCollider(familiar, collider)
					elseif collider.Velocity:Length() < 0.1 then
						petCollider(familiar, collider)
					end
				elseif collider.Type == 4 then
					grabCollider(familiar, collider)
				elseif collider.Type > 9 and ((isSirenCharmed and mod:isFriend(collider)) or (not isSirenCharmed and not mod:isFriend(collider))) then
					grabCollider(familiar, collider)
				end
			end
		end
	end
end, FamiliarVariant.GRABBER)

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, helper)
	if helper.FrameCount == 0 then
		if helper.Target and 
		   helper.Target.Type == EntityType.ENTITY_FAMILIAR and 
		   helper.Target.Variant == FamiliarVariant.GRABBER and 
		   helper.Target.SubType ~= 1 and 
		   helper.Target.SubType ~= 2 
		then
			for _,hand in ipairs(helper.Target:GetData().Hands) do
				if hand:Exists() and not mod:isSirenCharmed(hand) and helper.Parent and helper.Parent:Exists() then
					local handhelper = Isaac.Spawn(EntityType.ENTITY_SIREN_HELPER, 0, 0, hand.Position, nilvector, nil):ToNPC()
					handhelper.Parent = helper.Parent
					handhelper.Target = hand
					handhelper:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					handhelper:AddEntityFlags(EntityFlag.FLAG_HIDE_HP_BAR)
					handhelper:Update()
					
					handhelper.CollisionDamage = 0
					hand.Player = helper.Target:ToFamiliar().Player
				end
			end
		end
	end
end, EntityType.ENTITY_SIREN_HELPER)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, amount, flags, source, countdown)
	if flags ~= flags | DamageFlag.DAMAGE_CLONES and 
	   ent.Target and 
	   ent.Target.Type == EntityType.ENTITY_FAMILIAR and 
	   ent.Target.Variant == FamiliarVariant.GRABBER 
	then
		local grabber = ent.Target
		
		local body
		if grabber.SubType == 1 or grabber.SubType == 2 then
			body = grabber.Parent
		else
			body = grabber
		end
		
		if body then
			local _, bodycharmer = mod:isSirenCharmed(body)
			if bodycharmer and (bodycharmer.Index ~= ent.Index or bodycharmer.InitSeed ~= ent.InitSeed) then
				bodycharmer:TakeDamage(amount, flags | DamageFlag.DAMAGE_CLONES, source, countdown)
			end
			
			local hands = body:GetData().Hands
			for _,hand in ipairs(hands) do
				local _, handcharmer = mod:isSirenCharmed(hand)
				if handcharmer and (handcharmer.Index ~= ent.Index or handcharmer.InitSeed ~= ent.InitSeed) then
					handcharmer:TakeDamage(amount, flags | DamageFlag.DAMAGE_CLONES, source, countdown)
				end
			end
		end
	end
end, EntityType.ENTITY_SIREN_HELPER)

mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, function(_, helper, collider)
	if helper.Target and helper.Target.Type == EntityType.ENTITY_FAMILIAR and helper.Target.Variant == FamiliarVariant.GRABBER then
		if collider.Type == EntityType.ENTITY_PLAYER or collider.Type == 4 or collider.Type > 9 then
			return true
		end
	end
end, EntityType.ENTITY_SIREN_HELPER)

--Red hand included due to similarities

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	if player.Variant == 0 then
		local trinketCount = (player:GetTrinketMultiplier(mod.ITEM.TRINKET.REDHAND) + player:GetEffects():GetTrinketEffectNum(mod.ITEM.TRINKET.REDHAND))
		if trinketCount > 0 then
			trinketCount = trinketCount + 1
		end
		player:CheckFamiliar(mod.ITEM.FAMILIAR.REDHAND, trinketCount, player:GetTrinketRNG(mod.ITEM.TRINKET.REDHAND), Isaac.GetItemConfig():GetTrinket(mod.ITEM.TRINKET.REDHAND))
	end
end, CacheFlag.CACHE_FAMILIAR)

local function setRedHandPosition(fam, d)
	local room = game:GetRoom()
	local topleft = room:GetTopLeftPos()
	local bottomright = room:GetBottomRightPos()

	local width = math.floor(math.abs(bottomright.X - topleft.X))
	local height = math.floor(math.abs(bottomright.Y - topleft.Y))
	--print(width, height)
	
	d.direction = math.random(4) - 1
	local xPos
	local yPos
	if d.direction % 2 == 0 then
		yPos = topleft.Y + math.random(height - 20) + 10
		if d.direction == 0 then
			xPos = topleft.X - 100
		else
			xPos = bottomright.X + 100
		end
	else
		xPos = topleft.X + math.random(width - 20) + 10
		if d.direction == 1 then
			yPos = bottomright.Y + 100
		else
			yPos = topleft.Y - 100
		end
	end
	fam.Position = Vector(xPos, yPos)
	fam.Velocity = nilvector
end

local function isHandOutOfRoom(fam, d)
	local room = game:GetRoom()
	local topleft = room:GetTopLeftPos()
	local bottomright = room:GetBottomRightPos()

	local width = bottomright.X - topleft.X
	local height = bottomright.Y - topleft.Y

	if d.direction == 0 then
		if fam.Position.X > bottomright.X + 100 then
			return true
		end
	elseif d.direction == 1 then
		if fam.Position.Y < topleft.Y - 100 then
			return true
		end
	elseif d.direction == 2 then
		if fam.Position.X < topleft.X - 100 then
			return true
		end
	elseif d.direction == 3 then
		if fam.Position.Y > bottomright.Y + 100 then
			return true
		end
	end
end

mod.redHandPickupBlacklist = {
	[380] = true, --Bed
}

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, fam)
	fam.Color = Color(1,1,1,0)
	fam:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
end, mod.ITEM.FAMILIAR.REDHAND)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local d = fam:GetData()
	local sprite = fam:GetSprite()
	local isSirenCharmed, charmer = mod:isSirenCharmed(fam)
	
	if charmer then
		charmer.CollisionDamage = 0
	end

	local p = fam.Player
	fam.RenderZOffset = 100
	if not d.init then
		fam.SpriteOffset = Vector(0, -10)
		d.state = "idle"
		d.StateFrame = 0
		d.init = true
		setRedHandPosition(fam, d)
		fam.Color = Color(1,1,1,1)
	else
		d.StateFrame = d.StateFrame or 0
		d.StateFrame = d.StateFrame + 1
	end

	local speed, homingSpeed = 5, 5
	if p:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) then
		speed = speed * 2
		homingSpeed = homingSpeed * 2
	end

	d.direction = d.direction or math.random(4)
	fam.Velocity = mod:Lerp(fam.Velocity, Vector(speed, 0):Rotated(d.direction * -90), 0.3)
	if d.target and d.target:Exists() then
		fam.Velocity = mod:Lerp(fam.Velocity, (d.target.Position - fam.Position), 0.1)
	end

	if isHandOutOfRoom(fam, d) then
		setRedHandPosition(fam, d)
	end

	if d.direction == 2 then
		sprite.FlipX = true
	else
		sprite.FlipX = false
	end

	if d.direction == 1 then
		sprite.Rotation = -90
	else
		sprite.Rotation = 0
	end

	if p:HasTrinket(TrinketType.TRINKET_BABY_BENDER) then
		fam.Color = Color(2,1,2,fam.Color.A,100 / 255,-100 / 255,100 / 255)
	elseif not isSirenCharmed then
		fam.Color = Color(1,1,1,fam.Color.A)
	end

	if d.state == "idle" then
		if math.abs(fam.Velocity.Y) > math.abs(fam.Velocity.X) and fam.Velocity.Y > 0 then
			mod:spritePlay(sprite, "HandDown")
		else
			mod:spritePlay(sprite, "HandShoot")
		end
		fam.CollisionDamage = 0

		if d.StateFrame > 10 then
			local pickups = Isaac.FindInRadius(fam.Position, 30, EntityPartition.PICKUP)
			for _, pickup in ipairs(pickups) do
				if not mod.redHandPickupBlacklist[pickup.Variant] then
					if pickup.Position:Distance(fam.Position) < fam.Size + pickup.Size then
						grabCollider(fam, pickup)
						break
					end
				end
			end

			
			local targ = mod.FindClosestEnemy(fam.Position, 500)
			if targ then 
				local targvec = (targ.Position - fam.Position)
				if p:HasTrinket(TrinketType.TRINKET_BABY_BENDER) then
					homingSpeed = 10
				end
				if d.direction % 2 == 0 then
					targvec.X = fam.Velocity.X
				else
					targvec.Y = fam.Velocity.Y
				end
				targvec = targvec:Resized(math.min(targvec:Length(), homingSpeed))
				fam.Velocity = mod:Lerp(fam.Velocity, targvec, 0.1)
			end
		end
	elseif d.state == "grab" then
		mod:spritePlay(sprite, "HandGrab")
		
		--fam.CollisionDamage = 1
		if d.target and d.target:Exists() and d.target.Type > 9 then
			if fam.FrameCount % 7 == 0 then
				if (isSirenCharmed and mod:isFriend(d.target)) or (not isSirenCharmed and not mod:isFriend(d.target)) then
					local damageAmount = 1
					if p:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
						damageAmount = damageAmount * 2
					end
					d.target:TakeDamage(damageAmount, 0, EntityRef(nil), 0)
				end
			end
		end

		if d.target and d.target:Exists() and d.target.EntityCollisionClass > 0 and d.StateFrame < 150 and not ((d.target:CollidesWithGrid() and d.StateFrame > 10 and d.target.Type < 10) or (d.target.Type == 1 and d.StateFrame > 30)) then
			if d.target.Type == 5 and d.target.GridCollisionClass == EntityGridCollisionClass.GRIDCOLL_GROUND then
				d.target.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
			end
			local vec = (fam.Position - d.target.Position)
			d.target.Velocity = d.target.Velocity + vec:Resized(math.min(vec:Length() / 5, 15))
		else
			d.state = "idle"
			d.StateFrame = 0
			d.lerpness = 0.05
			if d.target.Type == 5 and d.target.GridCollisionClass == EntityGridCollisionClass.GRIDCOLL_NOPITS then
				d.target.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			end
			d.target = nil
		end
	end

end, mod.ITEM.FAMILIAR.REDHAND)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, familiar, collider)
	if (collider.Type > 9 or collider.Type == 4 or collider.Type == 1) and collider.EntityCollisionClass > 0 then
		if not collider:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
			if familiar:GetData().state == "idle" and familiar:GetData().StateFrame > 10 then
				local isSirenCharmed = mod:isSirenCharmed(familiar)
				
				if collider.Type == EntityType.ENTITY_PLAYER then
					grabCollider(familiar, collider)
					--Isaac.ExecuteCommand('restart')
				elseif collider.Type == 4 then
					grabCollider(familiar, collider)
				elseif collider.Type > 9 and ((isSirenCharmed and mod:isFriend(collider)) or (not isSirenCharmed and not mod:isFriend(collider))) then
					grabCollider(familiar, collider)
				end
			end
		end
	end
end, mod.ITEM.FAMILIAR.REDHAND)
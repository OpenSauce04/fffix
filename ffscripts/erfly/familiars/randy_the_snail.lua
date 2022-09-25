local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local d = familiar:GetData()
	local sprite = familiar:GetSprite()

	--print(familiar.FrameCount)

	if not d.init then
		d.newhome = nil
        familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
		familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		familiar.SpriteOffset = Vector(0,-5)
		d.randyTimer = 0
		familiar.Velocity = (game:GetRoom():GetCenterPos() - familiar.Position):Resized(3)
		familiar.Position = familiar.Position + familiar.Velocity:Resized(15)
		if familiar.Velocity.X > 0 then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end
		if math.abs(familiar.Velocity.X) > math.abs(familiar.Velocity.Y) then
			d.dir = "Side"
		else
			sprite.FlipX = false
			if familiar.Velocity.Y < 0 then
				d.dir = "Bottom"
			else
				d.dir = "Front"
			end
		end
        d.init = true
		d.state = "normal"

		if Sewn_API then
			Sewn_API:AddCrownOffset(familiar, Vector(0, -10))
		end
	else
		d.randyTimer = d.randyTimer or 0
		d.randyTimer = d.randyTimer + 1
    end

	local p = familiar.Player:ToPlayer()
	if p and p:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
		familiar.Size = 20
		d.randyIsFriend = true
	else
		familiar.Size = 13
		d.randyIsFriend = false
	end

	if d.randyTimer > 5 then
		for _, proj in pairs(Isaac.FindByType(9, -1, -1, false, false)) do
			if proj.Position:Distance(familiar.Position) - proj.Size - familiar.Size <= 0 then
				d.state = "spin"
				familiar.Velocity = familiar.Velocity + (proj.Velocity) * 5
				sfx:Play(mod.Sounds.PinballFlipper,2,0,false, math.random(110,120)/100)
				proj:Die()
			end
		end
		for _, proj in pairs(Isaac.FindByType(2, -1, -1, false, false)) do
			if (not proj:GetData().hitRandySnail) and proj.Position:Distance(familiar.Position) - proj.Size - familiar.Size <= 0 and proj:ToTear().Height > -30 then
				d.state = "spin"
				familiar.Velocity = familiar.Velocity + (proj.Velocity) * 5
				sfx:Play(mod.Sounds.PinballFlipper,2,0,false, math.random(110,120)/100)
				local tearflags = proj:ToTear().TearFlags
				if (tearflags == tearflags | TearFlags.TEAR_SPECTRAL or tearflags == tearflags | TearFlags.TEAR_PIERCING) then
					proj:GetData().hitRandySnail = true
				else
					proj:Die()
				end
			end
		end
		for _, proj in pairs(Isaac.FindByType(1000, 1, -1, false, false)) do
			if (not proj:GetData().didit) and proj.Position:Distance(familiar.Position) < 50 then
				d.state = "spin"
				familiar.Velocity = familiar.Velocity + (familiar.Position - proj.Position):Resized(25)
				sfx:Play(mod.Sounds.PinballFlipper,2,0,false, math.random(110,120)/100)
				proj:GetData().didit = true
				--print("yeah")
			end
		end

		if d.AwesomeCooldown then
			d.AwesomeCooldown = d.AwesomeCooldown - 1
		end
		if not d.AwesomeCooldown or d.AwesomeCooldown and d.AwesomeCooldown < 1 then
			for _, proj in pairs(Isaac.FindByType(8, 0, -1, false, false)) do
				if proj.Position:Distance(familiar.Position) < 25 then
					d.state = "spin"
					familiar.Velocity = familiar.Velocity + (familiar.Position - proj.Position):Resized(20)
					sfx:Play(mod.Sounds.PinballFlipper,2,0,false, math.random(110,120)/100)
					d.AwesomeCooldown = 10
				end
			end
			for _, proj in pairs(Isaac.FindByType(1000, 3532, -1, false, false)) do
				if proj.Position:Distance(familiar.Position) < 25 then
					d.state = "spin"
					familiar.Velocity = familiar.Velocity + (familiar.Position - proj.Position):Resized(20)
					sfx:Play(mod.Sounds.PinballFlipper,2,0,false, math.random(110,120)/100)
					d.AwesomeCooldown = 10
				end
			end
			for _, randy in pairs(Isaac.FindByType(3, FamiliarVariant.RANDY_THE_SNAIL, -1, false, false)) do
				local dist = randy.Position:Distance(familiar.Position)
				if dist < 40 and dist > 1 then
					if d.state == "spin" then
						familiar.Velocity = (familiar.Velocity + (familiar.Position - randy.Position) * 5):Resized(familiar.Velocity:Length())
						randy.Velocity = (familiar.Velocity + (familiar.Position - randy.Position) * -5):Resized(familiar.Velocity:Length())
						randy:GetData().state = "spin"
						sfx:Play(mod.Sounds.PinballHit,1.5,0,false, math.random(90,110)/100)
						d.AwesomeCooldown = 10
					end
				end
			end
			for _, grabber in pairs(Isaac.FindByType(3, FamiliarVariant.GRABBER, -1, false, false)) do
				local dist = grabber.Position:Distance(familiar.Position)
				if dist < 40 and dist > 1 then
					if (grabber.SubType == 1 or grabber.SubType == 2) and grabber:GetData().state == "shoot" then
						grabber:GetData().state = "grab"
						grabber:GetData().target = familiar
						grabber:GetData().StateFrame = 0
					end
				end
			end
		end
	end

	if d.state == "normal" then
		familiar.CollisionDamage = 0
		--Movement
		d.newhome = d.newhome or mod:GetNewPosAligned(familiar.Position)
		if familiar:CollidesWithGrid() or familiar.Position:Distance(d.newhome) < 3 --[[or familiar.Velocity:Length() < 0.3]] or (not game:GetRoom():CheckLine(d.newhome,familiar.Position,0,900,false,false)) then
			d.newhome = mod:GetNewPosAligned(familiar.Position)
		end
		if sprite:GetFrame() == 12 or sprite:GetFrame() == 30 then
			local targvel = (d.newhome - familiar.Position):Resized(5)
			familiar.Velocity = mod:Lerp(familiar.Velocity, targvel, 0.3)
			if familiar.Velocity.X > 0 then
				sprite.FlipX = true
			else
				sprite.FlipX = false
			end
			if math.abs(familiar.Velocity.X) > math.abs(familiar.Velocity.Y) then
				d.dir = "Side"
			else
				sprite.FlipX = false
				if familiar.Velocity.Y < 0 then
					d.dir = "Bottom"
				else
					d.dir = "Front"
				end
			end
		end
		familiar.Velocity = familiar.Velocity * 0.9
		d.dir = d.dir or "Side"
		if not sprite:IsPlaying("HideEnd") then
			sprite:SetFrame(d.dir, d.randyTimer % 36)
		end

		if familiar.Velocity:Length() > 10 and d.randyTimer > 5 then
			familiar:GetData().state = "spin"
		end

		if d.randyTimer % 6 == 0 then
			local blood = Isaac.Spawn(1000, 7, 0, familiar.Position, nilvector, npc)
			blood.SpriteScale = Vector(0.4,0.4)
			blood.Color = Color(0.1,0.1,0.1,0.1,0,0,0)
			blood:Update()
		end
	elseif d.state == "owie" then
		familiar.CollisionDamage = 0
		d.newhome = nil
		familiar.Velocity = familiar.Velocity * 0.8
		d.counter = d.counter or 0
		if d.counter > 0 then
			d.counter = d.counter - 1
		else
			d.state = "normal"
			sprite:Play("HideEnd", true)
		end
	elseif d.state == "spin" then
		d.newhome = nil
		local dps = 1
		local p = familiar.Player
		if p then
			dps = (p.Damage * 0.25 / p.MaxFireDelay * 2)+0.10
		end
		--familiar.CollisionDamage = math.ceil(familiar.Velocity:Length() * dps * 0.25)
		local multi = 10
		if d.randyIsFriend then
			multi = 15
		end
		familiar.CollisionDamage = dps * multi
		--print(familiar.CollisionDamage .. " / " .. familiar.Size)
		mod:spritePlay(sprite, "Spin")
		if familiar.Velocity:Length() > 25 then
			familiar.Velocity = familiar.Velocity:Resized(25)
		elseif familiar.Velocity:Length() < 5 then
			d.state = "owie"
			sprite:Play("SpinEnd", true)
			d.counter = 30
		end
		if familiar:CollidesWithGrid() then
			if not d.touched then
				sfx:Play(mod.Sounds.PinballFlipper,0.3,0,false, math.random(90,110)/100)
				d.touched = true
			end
		else
			d.touched = false
			d.vel = familiar.Velocity:Length() * 0.98
		end
		familiar.Velocity = familiar.Velocity * 0.97
		if d.vel and familiar.Velocity:Length() < d.vel then
			familiar.Velocity = familiar.Velocity:Resized(d.vel)
		end

		--[[for _,enemy in ipairs(Isaac.FindInRadius(familiar.Position, familiar.Size, EntityPartition.ENEMY)) do
			familiar.Velocity = (enemy.Position - familiar.Position):Resized(familiar.Velocity:Length())
		end]]
		if sprite:IsEventTriggered("Sound") then
			sfx:Play(mod.Sounds.WingFlap,1,0,false, (50 + familiar.Velocity:Length() * 5)/100)
		end
		if familiar.Velocity.X > 0 then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end
	end

end, FamiliarVariant.RANDY_THE_SNAIL)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, familiar, collider)
	if collider.Type == 966 and collider.Target and collider.Target.Index == familiar.Index and collider.Target.InitSeed == familiar.InitSeed then
		return true
	elseif collider.Type == 1 or collider.Type > 9 --[[and familiar:GetData().state == "spin"]] then
		if familiar:GetData().state == "spin" then
			familiar.Velocity = (familiar.Velocity + (familiar.Position - collider.Position) * 5):Resized(familiar.Velocity:Length())
			if collider:ToNPC() and not (collider.Type == 33 or collider.Type == 42 or collider.Type == 44) then
				sfx:Play(mod.Sounds.PinballHit,1.5,0,false, math.random(90,110)/100)
				collider:BloodExplode()
				if Sewn_API then
					local sewGo
					local DMGdivider = 1
					local tearvar = 0
					local rot = 30
					if Sewn_API:IsUltra(familiar:GetData()) then
						sewGo = true
						tearvar = 1
						rot = 60
					elseif Sewn_API:IsSuper(familiar:GetData()) then
						sewGo = true
						DMGdivider = 2
					end

					if sewGo then
						local vec = (familiar.Position - collider.Position):Resized(-9)
						for i = -rot, rot, 30 do
							local tear = Isaac.Spawn(2, tearvar, 0, familiar.Position + vec:Rotated(i):Resized(familiar.Size + collider.Size + 5), vec:Rotated(i), familiar):ToTear()
							tear.CollisionDamage = familiar.CollisionDamage / DMGdivider
						end
					end
				end
			end
		else
			familiar.Velocity = (familiar.Velocity + (familiar.Position - collider.Position) * 0.3)
			if familiar.Velocity:Length() > 10 then
				familiar:GetData().state = "spin"
				if collider:ToNPC() then
					sfx:Play(mod.Sounds.PinballHit,1.5,0,false, math.random(90,110)/100)
				else
					sfx:Play(mod.Sounds.PinballFlipper,2,0,false, math.random(110,120)/100)
				end
			end
		end
	end
end, FamiliarVariant.RANDY_THE_SNAIL)
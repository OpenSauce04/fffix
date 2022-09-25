local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)
	familiar.IsFollower = true
end, FamiliarVariant.BABY_CRATER)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local d = familiar:GetData()
	local sprite = familiar:GetSprite()
	local isSuperpositioned = mod:isSuperpositionedPlayer(familiar.Player)
	
	local wasSirenCharmed = d.IsSirenCharmed or false
	local isSirenCharmed = mod:isSirenCharmed(familiar)

	d.stateframe = d.stateframe or 0
	d.tears = d.tears or 0
	d.stateframe = d.stateframe + 1
	d.trackedTears = d.trackedTears or {}
	if Sewn_API and not d.offsetHandled then
		Sewn_API:AddCrownOffset(familiar, Vector(-2, 5))
		d.offsetHandled = true
	end

	d.state = d.state or "idle"

	if d.state == "idle" then
		d.attacking = false
		d.tears = 0
		d.trackedTears = {}
		if not sprite:IsPlaying("AttackRelease") or sprite:IsFinished("AttackRelease") then
			mod:spritePlay(sprite, "Walk")
		end
		if familiar.Player:GetFireDirection() ~= Direction.NO_DIRECTION then
			d.state = "attackstart"
			mod:spritePlay(sprite, "AttackStart")
		end
	else
		if d.state == "attackstart" then
			if sprite:IsFinished("AttackStart") then
				d.state = "attackloop"
			else
				mod:spritePlay(sprite, "AttackStart")
			end
			if sprite:IsEventTriggered("attackstart") then
				d.attacking = true
				d.stateframe = 0
			end
		elseif d.state == "attackloop" then
			mod:spritePlay(sprite, "AttackLoop")
		end
		if familiar.Player:GetFireDirection() == Direction.NO_DIRECTION or wasSirenCharmed ~= isSirenCharmed then
			if d.attacking then
				d.attacking = false
				mod:spritePlay(sprite, "AttackRelease")
			end
			d.state = "idle"
		end
	end

	d.orbit = math.sin((familiar.FrameCount) / 4)

	if d.attacking then
		if d.tears < 9 and d.stateframe % 6 == 5 then
			d.tears = d.tears + 1
			if isSirenCharmed then
				local proj = Isaac.Spawn(9, 0, 0, familiar.Position + Vector(2,-15), Vector(0, 4), familiar):ToProjectile()
				local pdata = proj:GetData()
				proj.FallingSpeed = 0
				proj.FallingAccel = -0.1
				proj.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
				pdata.projType = "babycraterorbital"
				sfx:Play(SoundEffect.SOUND_BLOODSHOOT, 0.8, 1, false, 1)
				pdata.frameOffset = 32
				pdata.direction = 1
				proj.Parent = familiar
				table.insert(d.trackedTears, proj)
				proj:Update()
			else
				local tear = Isaac.Spawn(2, 0, 0, familiar.Position + Vector(2,-15), Vector(0, 4), familiar):ToTear()
				local tdata = tear:GetData()
				tear.FallingSpeed = 0
				tear.FallingAcceleration = -0.1
				tear.TearFlags = tear.TearFlags | TearFlags.TEAR_SPECTRAL
				if Sewn_API then
					if Sewn_API:IsUltra(d) then
						tear.TearFlags = tear.TearFlags | TearFlags.TEAR_PIERCING
						tear:ChangeVariant(TearVariant.CUPID_BLOOD)
						tear.CollisionDamage = tear.CollisionDamage * 1.5
					elseif Sewn_API:IsSuper(d) then
						tear.TearFlags = tear.TearFlags | TearFlags.TEAR_PIERCING
						tear:ChangeVariant(TearVariant.CUPID_BLUE)
					end
				end
				if familiar.Player:HasTrinket(TrinketType.TRINKET_BABY_BENDER) then
					tear:AddTearFlags(TearFlags.TEAR_HOMING)
					--tear:GetData().YinYangOrb = true
					--tear:GetData().yinyangstrength = 0.05
					tear.Color = FiendFolio.ColorPsy
				end
				if familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
					tear.Scale = 1.1
					tear.CollisionDamage = tear.CollisionDamage * 2
				end
				tdata.projType = "babycraterorbital"
				sfx:Play(SoundEffect.SOUND_BLOODSHOOT, 0.8, 1, false, 1)
				tdata.frameOffset = 32
				tdata.direction = 1
				tear.Parent = familiar
				if isSuperpositioned then
					local tearcolor = Color.Lerp(tear.Color, Color(1,1,1,1,0,0,0), 0)
					tearcolor.A = tearcolor.A / 4
					tear.Color = tearcolor
				end
				table.insert(d.trackedTears, tear)
				tear:Update()
			end
		elseif d.tears > 8 then
			local anyalive
			for i = 1, #d.trackedTears do
				if d.trackedTears[i]:Exists() and not d.trackedTears[i]:IsDead() then
					anyalive = true
				end
			end
			if not anyalive then
				d.state = "idle"
			end
		end
	end

	familiar:FollowParent()
	d.IsSirenCharmed = isSirenCharmed
end, FamiliarVariant.BABY_CRATER)

function mod.babyCraterTears(tear, d)
	if d.projType == "babycraterorbital" then
		tear.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		if tear.Parent then
			local pd = tear.Parent:GetData()
			if pd.attacking then
				local target = tear.Parent.Position
				local frame = tear.FrameCount + d.frameOffset

				local xvel = math.cos(((frame * d.direction) / 8.5) + math.pi) * (35 + pd.orbit * 9)
				local yvel = math.sin(((frame * d.direction) / 8.5) + math.pi) * (35 + pd.orbit * 9)

				local direction = Vector(target.X - xvel, target.Y - yvel) - tear.Position

				if direction:Length() > 50 then
					direction:Resize(50)
				end

				tear.Velocity = direction
			else
				local parentpos = d.previousParentPosition or tear.Parent.Position
				local parentvel = d.previousParentVelocity or tear.Parent.Velocity
				tear.Velocity = ((tear.Position - parentpos)+ parentvel):Resized(math.max(12, parentvel:Length()))
				d.projType = "babycraterorbital2"
			end
			d.previousParentPosition = tear.Parent.Position
			d.previousParentVelocity = tear.Parent.Velocity
		end
	elseif d.projType == "babycraterorbital2" then
		if tear.Type == EntityType.ENTITY_PROJECTILE then
			tear.FallingAccel = 0.01
		else 
			tear.FallingAcceleration = 0.01
		end
		
		if not d.FrameCount then
			d.FrameCount = 0
		else
			d.FrameCount = d.FrameCount + 1
			if d.FrameCount > 300 then
				tear:Remove()
			end
		end
	end
end

function mod:babyCraterLocustAI(fam)
	local d = fam:GetData()
	local player = fam.Player
	if fam.FireCooldown == -1 then
		if not d.startAng then
			d.startAng = (fam.Velocity):GetAngleDegrees()
		end
		d.additionalAng = d.additionalAng or 0
		d.additionalAng = d.additionalAng + 5
		local targetPos = player.Position + (Vector(50,0):Rotated(d.startAng + d.additionalAng))
		local vec = (targetPos - fam.Position):Resized(10)
		
		fam.Velocity = mod:Lerp(fam.Velocity, vec, 0.1)
		if d.additionalAng >= 360 then
			fam.FireCooldown = -2
		end
	else
		d.startAng = nil
		d.additionalAng = nil
	end
end

--Old Xal implementation, kept for "just in case" reasons

--[[mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local data = familiar:GetData()
	local sprite = familiar:GetSprite()

	if not data.framecount then data.framecount = -1 end
	if not data.tears then data.tears = 0 end
	data.framecount = data.framecount + 1

	if sprite:IsFinished("Appear") or sprite:IsFinished("AttackRelease") then
		sprite:Play("Walk", false)
	elseif sprite:IsFinished("AttackStart") then
		data.framecount = 0
		sprite:Play("AttackLoop")
	end

	if familiar.Player:GetFireDirection() ~= Direction.NO_DIRECTION then
		if sprite:IsPlaying("Walk") then
			sprite:Play("AttackStart")
		end
	elseif sprite:WasEventTriggered("attackstart") or sprite:IsPlaying("AttackLoop") then
		sprite:Play("AttackRelease")
		data.tears = 0
	end

	data.orbit = math.sin((data.framecount) / 4)

	if sprite:WasEventTriggered("attackstart") or sprite:IsPlaying("AttackLoop") then
		if data.tears < 9 and data.framecount % 6 == 1 then
			data.tears = data.tears + 1
			data.state = "orbit"
			local tear = Isaac.Spawn(2, 0, 0, familiar.Position + Vector(2,-15), Vector(0, 4), familiar):ToTear()
			local tdata = tear:GetData()
			tear.FallingSpeed = 0
			tear.FallingAcceleration = -0.1
			tear.TearFlags = tear.TearFlags | TearFlags.TEAR_SPECTRAL
			tdata.projType = "babycraterorbital"
			sfx:Play(SoundEffect.SOUND_BLOODSHOOT, 0.8, 1, false, 1)
			tdata.frameOffset = 32
			tdata.direction = 1
			tear.Parent = familiar
		end
	elseif sprite:IsEventTriggered("Shoot") then
		data.state = nil
	end

	familiar:FollowParent()
end, FamiliarVariant.BABY_CRATER)]]
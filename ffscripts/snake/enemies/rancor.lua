local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

local rancorLookDir = {
	"D",
	"DR",
	"R",
	"UR",
	"U",
	"UL",
	"L",
	"DL"
}
local grudgeVecs = {
	["RIGHT"] = Vector(1, 0),
	["LEFT"] = Vector(-1, 0),
	["DOWN"] = Vector(0, 1),
	["UP"] = Vector(0, -1)
}
function mod:RancorUpdate(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local r = npc:GetDropRNG()
	local room = game:GetRoom()

	local entitynpc = npc:ToNPC()
	local target = npc:GetPlayerTarget()
	entitynpc.Target = target

	-- initialize
	if not d.init then
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		if d.waited then
			d.state = "land"
			d.slamTarget = mod:RancorSnapToTile(room, npc.Position)
			mod:spritePlay(sprite, "Fall")
			npc.Visible = true
		elseif npc.SubType == 1 then
			mod.makeWaitFerr(npc, npc.Type, npc.Variant, npc.SubType, 80, false)
		else
			d.state = "start"
		end
		d.counter = 0

		d.targetVelocity = nilvector

		d.init = true
	end


	-- frame counter
	d.counter = d.counter + 1


	-- start (won't have grudge behaviour here but will take a moment to jump)
	if d.state == "start" then
		mod:RancorLook("Idle", npc, target)

		local jumpDelay = 10
		if d.counter > jumpDelay then
			d.state = "jump"
		end

	-- idle
	elseif d.state == "idle" then
		mod:RancorLook("Idle", npc, target)

		local jumpDelay = 30
		if d.counter >= jumpDelay then
			d.state = "jump"
		end

		-- check to cardinals for player for grudge attack
		local col = mod:CheckLineCollision(room, npc.Position, target.Position)
		if col == GridCollisionClass.COLLISION_NONE then
			if math.abs(npc.Position.Y - target.Position.Y) < 20 then
				local check = npc.Position.X < target.Position.X
				d.grudgeDir = check and "LEFT" or "RIGHT"

				d.state = "grudgestart"
			end
			if math.abs(npc.Position.X - target.Position.X) < 20 then
				local check = npc.Position.Y < target.Position.Y
				d.grudgeDir = check and "UP" or "DOWN"

				d.state = "grudgestart"
			end
		end


	-- jump
	elseif d.state == "jump" then
		mod:spritePlay(sprite, "Jump")

		-- sound/tangibility
		if sprite:IsEventTriggered("Sound") then -- play sound/become intangible
			npc:PlaySound(SoundEffect.SOUND_STONE_IMPACT,0.35,2,false,0.8)

			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		end

		-- pick position

		-- only one should precisely try to land on the player
		if d.isPrecise == nil then
			for _, ent in ipairs(Isaac.GetRoomEntities()) do
				if ent.Type == npc.Type and ent.Variant == npc.Variant then
					local entd = ent:GetData()

					-- land precisely?.
					if entd.isPrecise == nil then
						entd.isPrecise = ent.InitSeed == npc.InitSeed
					end
				end
			end
		end

		if sprite:IsEventTriggered("GetPlayer") then -- capture player position
			local randomMaxTiles = 3
			local checkPos = nilvector

			-- should land precisely on player or not
			if d.isPrecise then
				checkPos = room:FindFreeTilePosition(target.Position, 0)
				checkPos = mod:RancorSnapToTile(room, checkPos)
			else
				local grid = nil

				-- try to get a position that isn't on a pressure plate or on spikes
				local maxim = 50
				for i = 0, maxim, 1 do
					local randOffs = RandomVector() * (randomMaxTiles * 40)

					checkPos = room:FindFreeTilePosition(target.Position + randOffs, 0)
					checkPos = mod:RancorSnapToTile(room, checkPos)
					grid = room:GetGridEntityFromPos(checkPos)

					if checkPos == mod:RancorSnapToTile(room, npc.Position) then
						break
					end

					if (not grid) or (grid and
						(grid.Desc.Type ~= GridEntityType.GRID_PRESSURE_PLATE and
						 grid.Desc.Type ~= GridEntityType.GRID_SPIKES and
						 grid.Desc.Type ~= GridEntityType.GRID_SPIKES_ONOFF)) then
						break
					end
				end
			end

			d.slamTarget = checkPos

			-- spawn reticle
			if not d.crosshair then
				d.crosshair = Isaac.Spawn(1000, 7013, 3, d.slamTarget, nilvector, npc)
				d.crosshair.Parent = npc
				d.crosshair:Update()
			end
		end

		-- now in air
		if sprite:IsFinished("Jump") and d.slamTarget ~= nil then
			d.targetVelocity = nilvector

			d.state = "move"
			d.counter = 0
			d.isPrecise = nil
		end


	-- move in air
	elseif d.state == "move" then
		local vec = (d.slamTarget - npc.Position)
		local dist = vec:Length()

		if dist < 15 then -- start landing
			d.targetVelocity = nilvector
			d.state = "land"

		elseif dist < 25 then -- slow down
			d.targetVelocity = vec:Resized(2)

		else -- move
			d.targetVelocity = d.targetVelocity + (vec:Normalized() * (dist / 65))

			local arcvel = d.targetVelocity
			if arcvel:Length() >= dist then
				d.targetVelocity = arcvel:Resized(dist)
			end
		end


	-- land
	elseif d.state == "land" then
		mod:spritePlay(sprite, "Fall")

		local snappedPosition = mod:RancorSnapToTile(room, d.slamTarget)
		local vec = snappedPosition - npc.Position
		local dist = vec:Length()

		if dist < 5 then
			d.targetVelocity = nilvector
			npc.Position = snappedPosition

		elseif dist < 8 then
			d.targetVelocity = vec:Resized(1)

		else
			d.targetVelocity = vec
		end

		if sprite:IsEventTriggered("Land") then -- on land
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND

			game:ShakeScreen(8)
			npc:PlaySound(SoundEffect.SOUND_STONE_IMPACT,1,2,false,1)

			for i = 1, 10 do -- spawn smoke
				local Vec = RandomVector()
				local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position + Vec:Resized(math.random(5,25)), Vec:Resized(math.random(2,7)), npc):ToEffect()
				smoke.SpriteScale = smoke.SpriteScale * (math.random(8,18)/10)
				smoke.SpriteOffset = Vector(0, 0 - math.random(5,25))
				smoke.Color = Color(1.8, 2, 1.8, 0.4)
				smoke:Update()
			end

			if d.crosshair then
				d.crosshair:Remove()
				d.crosshair = nil
			end
		end

		if sprite:IsFinished("Fall") then -- now idle
			d.state = "idle"
			d.counter = 0
		end


	-- grudge start
	elseif d.state == "grudgestart" then
		if sprite:IsFinished() then -- start animation finished
			d.state = "grudge"
			npc:PlaySound(SoundEffect.SOUND_STONE_IMPACT,0.32,2,false,0.8)
		end

		mod:RancorLook("AttackStart", npc, target)


	-- grudge
	elseif d.state == "grudge" then
		mod:RancorLook("Attack", npc, target)

		-- move
		local vec = grudgeVecs[d.grudgeDir]
		local speed = 16

		d.targetVelocity = -vec:Resized(speed)

		-- spawn smoke
		local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position, npc.Velocity:Resized(3), npc)
		smoke.SpriteScale = smoke.SpriteScale * 1.2
		smoke.SpriteOffset = Vector(0, -5)
		smoke.SpriteRotation = math.random(360)
		smoke.Color = Color(1.8, 2, 1.8, 0.4)
		smoke:Update()

		-- on collide
		if npc:CollidesWithGrid() then
			game:ShakeScreen(6)

			if d.grudgeDir == "LEFT" or d.grudgeDir == "RIGHT" then
				mod:spritePlay(sprite, "HitHori")
			else
				mod:spritePlay(sprite, "HitVert")
			end

			npc:PlaySound(SoundEffect.SOUND_STONE_IMPACT,1,2,false,1)

			d.targetVelocity = nilvector
			d.state = "grudgeend"
		end


	-- end grudge
	elseif d.state == "grudgeend" then
		if sprite:IsFinished() then
			d.state = "idle"
			d.counter = 30
		end
	end


	-- push buttons
	if npc.GridCollisionClass == EntityGridCollisionClass.GRIDCOLL_GROUND then
		local player = Isaac.GetPlayer(0)
		local plate = room:GetGridEntityFromPos(npc.Position)

		if plate and plate.Desc.Type == GridEntityType.GRID_PRESSURE_PLATE then
			plate = plate:ToPressurePlate()

			local oldPos = player.Position

			player.Position = plate.Position
			plate:Update()
			player.Position = oldPos
		end
	end


	-- make  move :)
	local lerpAmount = 0.6
	if d.state == "grudge" then
		lerpAmount = 0.2
	end
	npc.Velocity = mod:Lerp(npc.Velocity, d.targetVelocity, lerpAmount)
end

function mod:RancorHurt(npc, damage, flag, source, countdown)
	local d = npc:GetData()
	local sprite = npc:GetSprite()
	
	if flag == flag | DamageFlag.DAMAGE_SPIKES then
		return false
	end
end

function mod:RancorLook(animName, npc, target)
	local sprite = npc:GetSprite()

	local vec = (target.Position - npc.Position):Resized(6)
	local dirIndex = mod:calcPeepeeDir(vec)

	-- get animation and play it, but keep frame (idk if there's a better way to do this)
	local anim = animName .. rancorLookDir[dirIndex + 1]

	if not sprite:IsPlaying(anim) then
		local curFrame = sprite:GetFrame()
		mod:spritePlay(sprite, anim)
		sprite:SetFrame(curFrame)
	end
end

function mod:RancorSnapToTile(room, vec)
	vec = vec / 40
	vec = Vector(math.floor(vec.X), math.floor(vec.Y))
	vec = vec * 40

	return room:FindFreeTilePosition(vec, 120)
end

function mod:CheckLineCollision(room, pos, target, steps)
	local vec = (target - pos)
	local vecn = vec:Normalized()

	steps = steps or 20
	local maximum = math.floor(vec:Length() / steps)

	local col = GridCollisionClass.COLLISION_NONE
	for i = 0, maximum, 1 do
		local step = vecn * steps
		pos = pos + step

		col = room:GetGridCollisionAtPos(pos)

		if col ~= GridCollisionClass.COLLISION_NONE then
			break
		end
	end

	return col
end
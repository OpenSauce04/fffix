local mod = FiendFolio
local game = Game()

function mod:sleeperAI(npc, sprite, data)
	local room = game:GetRoom()

	local isNightmare = npc.SubType == 1

	if not data.Init then
		npc.SplatColor = FiendFolio.ColorGhostly
		data.State = "Idle"
		data.Init = true
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)

		if room:GetFrameCount() > 0 and room:IsClear() then -- testing convenience so it works in cleared rooms w/ the spawn command
			data.IgnoreRoomClear = true
		end

		return
	end

	if data.State ~= "Idle" and not data.Horror then
		data.Horror = {Strength = 0}
		data.Horror.CircleSizes = {
			1000,
			1000,
			1000,
			1000
		}
	end

	local closestPlayer, closestDist
	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i - 1)
		local dist = player.Position:Distance(npc.Position)
		if not closestDist or dist < closestDist then
			closestPlayer = player
			closestDist = dist
		end
	end

	if data.Horror then
		local clampDist = math.min(closestDist, 320)
		data.Horror.Redness = mod:Lerp(0.1, 0.5, (320 - clampDist) / 320)
		data.Horror.Positions = {closestPlayer.Position + Vector(0, -16)}
		local vOffset = -55
		local hOffset = 14
		if sprite.FlipX then
			hOffset = -hOffset
		end

		data.Horror.Positions[2] = npc.Position + Vector(hOffset, vOffset)
	end

	if data.HorrorLerp then
		data.HorrorLerp = data.HorrorLerp + 1
		local percent = data.HorrorLerp / data.HorrorLerpMax


		local pow = 2
		if data.State == "Dead" then
			percent = 1 - percent
			pow = 3
		end

		percent = 1 - ((1 - percent) ^ pow)

		local playerSize, playerBorderSize = 90, 140
		if isNightmare then
			playerSize, playerBorderSize = 120, 170
		end

		data.Horror.Strength = mod:Lerp(0, 1, percent)
		data.Horror.CircleSizes = {
			mod:Lerp(1000, playerBorderSize, percent),
			mod:Lerp(1000, 100, percent),
			mod:Lerp(1000, playerSize, percent),
			mod:Lerp(1000, 70, percent),
		}
		
		if data.HorrorLerp >= data.HorrorLerpMax then
			data.HorrorLerp = nil
		end
	end

	if data.State == "Idle" then
        if npc.FrameCount % 20 == 0 and npc.Velocity:Length() < 1 then
			npc.Velocity = Vector(math.random() - 0.5, math.random() - 0.5)
		elseif npc.Velocity:Length() > 0.5 then
			npc.Velocity = npc.Velocity * 0.9
		end

        sprite:Play("Idle")

		local isDead = room:IsClear() and not data.IgnoreRoomClear
		if not isDead then
			for _, sleeper in ipairs(Isaac.FindByType(130, 80)) do
				if sleeper:GetData().State ~= "Idle" then
					isDead = true
					break
				end
			end
		end

		local transform = data.Hurt
		if not transform and not isDead then
			for i = 1, game:GetNumPlayers() do
				local player = Isaac.GetPlayer(i - 1)
				if player.Position:DistanceSquared(npc.Position) < 80 ^ 2 then
					transform = true
					break
				end
			end
		end

		if isDead then
			sprite:Play("Death Bab", true)
			data.State = "Dead"
		elseif transform then
            sprite:Play("Transform", true)
			sprite.FlipX = closestPlayer.Position.X > npc.Position.X
            data.State = "Transform"
		end
	elseif data.State == "Transform" then
		if sprite:IsFinished("Transform") then
			data.State = "Chase"
		elseif sprite:IsEventTriggered("Yip") then
			npc:PlaySound(SoundEffect.SOUND_SKIN_PULL, 1, 0, false, 1)
		elseif sprite:IsEventTriggered("Whip") then
			npc:PlaySound(mod.Sounds.MeatyBurst, 0.6, 0, false, 1)
			game:Darken(1, 45)
		elseif sprite:IsEventTriggered("Stretch") then
			data.HorrorLerp = 0
			data.HorrorLerpMax = 30
			npc:PlaySound(mod.Sounds.StretchEye, 1, 0, false, 1.5)
		else
			mod:spritePlay(sprite, "Transform")
		end

		npc.Velocity = npc.Velocity * 0.9
	elseif data.State == "Chase" then
        data.UseFFPlayerFlyingMap = true
        if data.Path then
            local index = room:GetGridIndex(npc.Position)
            if room:GetGridPath(index) < 900 then
                room:SetGridPath(index, 900)
            end

			local speed = 0.35
			if isNightmare then
				speed = mod:Sway(0.35, 0.55, 150, 2, 2, npc.FrameCount)
			end

            FiendFolio.FollowPath(npc, speed, data.Path, true, 0.75, 500)
        end

		sprite:Play("Idle Scare")

		if isNightmare then
			data.AttackCooldown = data.AttackCooldown or (math.random(45, 55))
			data.AttackCooldown = data.AttackCooldown - 1
			if data.AttackCooldown <= 0 then
				data.AttackCooldown = nil

				local terror = Isaac.Spawn(mod.FF.NightTerrors.ID, mod.FF.NightTerrors.Var, 0, closestPlayer.Position, closestPlayer.Velocity, npc)
				local tdata = terror:GetData()
				terror.Parent = closestPlayer
				tdata.NumTentacles = 3
				tdata.Spread = 45
				tdata.Distance = 35
				tdata.AttackFrame = 60
				tdata.Timeout = 70
			end
		end

		local die = room:IsClear() and not data.IgnoreRoomClear
		local scream = false
		if not die then
			for i = 1, game:GetNumPlayers() do
				local player = Isaac.GetPlayer(i - 1)
				if player.Position:DistanceSquared(npc.Position) < (npc.Size + player.Size + 20) ^ 2 then
					scream = true
					break
				end
			end
		end

		if scream and not die and isNightmare then
			npc.Velocity = npc.Velocity * 0.5
			sprite:Play("Scream", true)
			data.State = "Scream"
		end

		data.ChaseFrame = (data.ChaseFrame or 0) + 1
		if die or (scream and data.ChaseFrame > 30 and not isNightmare) then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			if scream then
				npc.Velocity = npc.Velocity * 0.5
				sprite:Play("Death Scream", true)
			else
				data.HorrorLerp = 0
				data.HorrorLerpMax = 11
				sprite:Play("Death Scare", true)
			end

			data.State = "Dead"
		end
	elseif data.State == "Scream" then
		if sprite:IsEventTriggered("ScreamAttack") then
			npc.Velocity = (npc.Position - closestPlayer.Position):Resized(12)
		end

		npc.Velocity = npc.Velocity * 0.9
		if sprite:IsFinished() then
			npc.Velocity = Vector.Zero
			data.State = "Chase"
		end
	elseif data.State == "Dead" then
		if sprite:IsEventTriggered("Scream") then
			data.HorrorLerp = 0
			data.HorrorLerpMax = 21
		end

		npc.Velocity = npc.Velocity * 0.5
		if sprite:IsFinished() then
			npc:Remove()
		end
	end

	if sprite:IsEventTriggered("Scream") then
		npc:PlaySound(mod.Sounds.FemurBreaker, 0.1, 0, false, 0.7)
	end

	if sprite:IsEventTriggered("ScreamAttack") then
		for i = 1, game:GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			if player.Position:DistanceSquared(npc.Position) < (npc.Size + player.Size + 120) ^ 2 then
				player.Velocity = (player.Position - npc.Position):Resized(12)
				player.Velocity = Vector(player.Velocity.X * 1.2, player.Velocity.Y * 0.8) -- rooms are bigger horizontally than vertically so pushing the player more horizontally looks better
				player:TakeDamage(2, 0, EntityRef(npc), 0)
				player:SetColor(Color(1, 1, 1, 1, 0.3, 0.3, 0.3), 90, 999, true, false)
				player.ControlsCooldown = 90

				local terrorCount = 3
				if isNightmare then
					terrorCount = 1
				end

				for i2 = 1, terrorCount do
					local terror = Isaac.Spawn(mod.FF.NightTerrors.ID, mod.FF.NightTerrors.Var, 0, player.Position, player.Velocity, npc)
					local tdata = terror:GetData()
					terror.Parent = player
					tdata.Speed = i2 * 0.1
					tdata.Size = 0.4 + (i2 * 0.2)
					tdata.Distance = 25 + i2 * 35
					tdata.Timeout = 90
					tdata.Alpha = 0.4 + (i2 * 0.1)
				end
			end
		end

		game:Darken(1, 100)
	end

	if data.State ~= "Transform" and data.State ~= "Scream" and math.abs(npc.Velocity.X) > 0.05 then
		sprite.FlipX = npc.Velocity.X < 0
	end
end

function mod:sleeperHurt(npc, sprite, data)
	data.Hurt = true
	return false
end

local nightTerrorSprite = Sprite()
nightTerrorSprite:Load("gfx/enemies/sleeper/night_terrors.anm2", true)
nightTerrorSprite:Play("Idle", true)

function mod:nightTerrorsAI(npc, sprite, data)
	npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

	if not npc.Parent then
		npc.Parent = Isaac.GetPlayer()
	end

	if not data.Tentacles then
		data.FadeIn = 0
		data.Tentacles = {}
		
		local count = (data.NumTentacles or math.random(6, 8))
		local initialAngle = (data.InitialAngle or math.random(1, 360))
		local spread = data.Spread
		local anglePerCount = 360 / count
		for i = 1, count do
			local offset = (math.random() - 0.5) * 0.8
			local angle, angleOffset
			if spread then
				if count == 1 then -- dividing by zero is bad i hear
					angle = initialAngle
				else
					angle = initialAngle + mod:Lerp(-spread / 2, spread / 2, (i - 1) / (count - 1))
				end

				angleOffset = (spread / count) * offset
			else
				angle = anglePerCount * i
				angleOffset = anglePerCount * offset
			end
			
			data.Tentacles[i] = {
				Angle = angle + angleOffset,
				SwayTime = math.random(1, 150),
				DistanceSwayTime = math.random(1, 150),
				DistanceOffset = math.random(-5, 5),
				FlipY = math.random(1, 2) == 1
			}
		end
	end

	if not data.Timeout then
		data.Timeout = 120
	end

	data.Size = data.Size or 0.5
	data.Distance = data.Distance or 60
	data.Speed = data.Speed or 0.3
	data.Alpha = data.Alpha or 0.5
	data.NoInterpolation = true

	if data.AttackFrame then
		if not data.BaseDistance then
			data.BaseDistance = data.Distance
			data.BaseAlpha = data.Alpha
		end

		if npc.FrameCount > data.AttackFrame then
			if npc.FrameCount < data.AttackFrame + 10 then
				local percent = ((npc.FrameCount - data.AttackFrame) / 10) ^ 2
				data.Distance = mod:Lerp(data.BaseDistance + 15, -150, percent)
				data.Alpha = mod:Lerp(data.BaseAlpha, 1, percent)
			end

			for _, tentacle in ipairs(data.Tentacles) do
				if data.FadeOut then
					if tentacle.Hitbox then
						tentacle.Hitbox:Remove()
					end
				else
					local hitboxPos = npc.Position - (Vector.FromAngle(tentacle.Angle) * (data.Distance + 512))
					if not tentacle.Hitbox then
						tentacle.Hitbox = Isaac.Spawn(mod.FF.Hitbox.ID, mod.FF.Hitbox.Var, 0, hitboxPos, npc.Velocity, npc)
						tentacle.Hitbox.CollisionDamage = 2
						tentacle.Hitbox:GetData().Rotation = tentacle.Angle
						tentacle.Hitbox:GetData().Width = 512
						tentacle.Hitbox.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
						tentacle.Hitbox.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
					end

					tentacle.Hitbox.Position = hitboxPos
					tentacle.Hitbox.Velocity = npc.Velocity
				end
			end
		elseif (npc.FrameCount > data.AttackFrame - 10) then
			local percent = ((npc.FrameCount - (data.AttackFrame - 10)) / 10) ^ 2
			data.Distance = mod:Lerp(data.BaseDistance, data.BaseDistance + 30, percent)
			data.NoTrackParent = true
			npc.Velocity = Vector.Zero
		end 
	end

	if data.FadeIn then
		data.FadeIn = data.FadeIn + 1
		if data.FadeIn > 15 then
			data.FadeIn = nil
		end
	end

	if data.FadeOut then
		data.FadeOut = data.FadeOut + 1
		if data.FadeOut > 30 then
			data.FadeOut = nil
			npc:Remove()
			return
		end
	else
		if data.Timeout == -1 then
			if not npc.SpawnerEntity or not npc.SpawnerEntity:Exists() then
				data.FadeOut = 0
			end
		elseif npc.FrameCount > data.Timeout then
			data.FadeOut = 0
		end
	end

	if not data.NoTrackParent then
		npc.Velocity = (mod:Lerp(npc.Position, npc.Parent.Position + Vector(0, -20), data.Speed) - npc.Position) / 2
	end
end

function mod:nightTerrorsRender(npc, sprite, data)
	if not npc.Parent or not data.Tentacles then
		return
	end

	local frameOffset = npc.FrameCount + ((data.NoInterpolation and 0) or 0.5)
	local useDistance = data.Distance
	if data.FadeIn or data.FadeOut then
		local percent
		if data.FadeIn then
			percent = (1 - (data.FadeIn / 15)) ^ 2
		else
			percent = (data.FadeOut / 30) ^ 2
		end

		useDistance = mod:Lerp(data.Distance, 1000, percent)
		nightTerrorSprite.Color = Color(1, 1, 1, mod:Lerp(data.Alpha, 0, percent), 0, 0, 0)
	else
		nightTerrorSprite.Color = Color(1, 1, 1, data.Alpha, 0, 0, 0)
	end

	for _, tentacle in ipairs(data.Tentacles) do
		if nightTerrorSprite.FlipY then
			nightTerrorSprite.Scale = Vector(1, -1) * data.Size
		else
			nightTerrorSprite.Scale = Vector.One * data.Size
		end

		local angle = mod:Sway(tentacle.Angle - 5, tentacle.Angle + 5, 150, 2, 2, frameOffset + tentacle.SwayTime)
		if data.NoRotationSway then
			angle = tentacle.Angle
		end

		nightTerrorSprite.Rotation = angle


		local dist = mod:Sway(useDistance + tentacle.DistanceOffset - 8, useDistance + tentacle.DistanceOffset + 8, 150, 2, 2, frameOffset + tentacle.DistanceSwayTime)
		if data.NoDistanceSway then
			dist = useDistance + tentacle.DistanceOffset
		end


		local renderOffset = -(Vector(1000 * data.Size, 0):Rotated(angle))
		local distRotated = -(Vector(dist, 0):Rotated(angle))
		renderOffset = renderOffset + Vector(distRotated.X, distRotated.Y * 0.75)

		tentacle.LastRenderOffset = renderOffset

		local pos = Isaac.WorldToRenderPosition(npc.Position) + renderOffset

		nightTerrorSprite:Render(pos, Vector.Zero, Vector.Zero)
	end


	if data.NoInterpolation then
		data.NoInterpolation = false
	end
end
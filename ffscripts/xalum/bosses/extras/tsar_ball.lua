local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

return {
	Init = function(npc)
		local data = npc:GetData()

		data.variant = math.random(3)
		data.lastGridCollision = -40

		npc.SpriteOffset = Vector(0, -14)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	end,
	AI = function(npc)
		local dat = npc:GetData()
		local spr = npc:GetSprite()

		mod.QuickSetEntityGridPath(npc)

		npc.HitPoints = npc.MaxHitPoints
		if dat.tsar and dat.tsar:IsDead() then npc:Die() end

		if npc.SubType == 0 then
			if spr:IsFinished("Poof") then
				npc:Remove()
			elseif spr:IsFinished("GlobAppear01") or spr:IsFinished("GlobAppear0" .. dat.variant) then
				spr:Play("Idle0" .. dat.variant)
			elseif spr:IsFinished("Merge0" .. dat.variant) then
				if (dat.combining and dat.combining.SubType <= npc.SubType) then
					local new = Isaac.Spawn(npc.Type, npc.Variant, npc.SubType + 1, (npc.Position + dat.combining.Position) / 2, Vector.Zero, dat.tsar)

					new:GetSprite():Play("BlobCombine0" .. new.SubType)

					local newData = new:GetData()
					newData.tsar = dat.tsar
					newData.form = dat.combining:GetData().form

					mod.tsarChangeForm(new, newData.form, true)

					new:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

					npc:Remove()
					dat.combining:Remove()
				end
			end

			if dat.combiner or dat.combining then
				spr:Play("Merge0" .. dat.variant)
			end

			if npc.FrameCount > 45 and not dat.setcombine then
				dat.setcombine = true
				dat.cancombine = true
			end
		else
			if spr:IsFinished("BlobCombine0" .. npc.SubType) then
				spr:Play("BlobIdle0" .. npc.SubType)
				dat.cancombine = true
			end

			if dat.combiner or dat.combining then
				npc:Remove()
				if (dat.combining and dat.combining.SubType <= npc.SubType) or (dat.combiner and npc.SubType > dat.combiner.SubType) then
					local other = dat.combiner or dat.combining

					local new = Isaac.Spawn(npc.Type, npc.Variant, npc.SubType + 1, (npc.Position + other.Position) / 2, Vector.Zero, dat.tsar)
					local newData = new:GetData()

					new:GetSprite():Play("BlobCombine0" .. new.SubType)
					newData.tsar = dat.tsar
					newData.form = other:GetData().form

					mod.tsarChangeForm(new, newData.form, true)

					new:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

					other:Remove()
				end
			end
		end

		if not game:GetRoom():IsPositionInRoom(npc.Position, 0) then npc.Position = game:GetRoom():GetCenterPos() end

		if spr:IsPlaying("Poof") then
			npc.Velocity = Vector.Zero
		elseif npc.FrameCount >= 5 then
			local tsarBalls = Isaac.FindByType(npc.Type, npc.Variant, -1)
			local combinables = {}

			for _, ball in pairs(tsarBalls) do
				if ball:GetData().cancombine then table.insert(combinables, ball) end
			end

			local targetPosition
			local targetVelocity

			if #tsarBalls == 1 or #combinables == 1 then
				targetPosition = npc:GetPlayerTarget().Position
				targetVelocity = targetPosition - npc.Position
				targetVelocity:Resize(math.min(4, targetVelocity:Length()))
			elseif #combinables ~= 0 then
				local averagePosition = Vector.Zero

				for _, ball in pairs(combinables) do
					averagePosition = averagePosition + ball.Position
				end
				averagePosition = averagePosition / #combinables

				targetPosition = averagePosition
				targetVelocity = averagePosition - npc.Position
				targetVelocity:Resize(math.min(4, targetVelocity:Length()))
			else
				npc.Velocity = npc.Velocity * 0.9
			end

			if targetVelocity then
				local room = game:GetRoom()
				local hasLineOfSight = room:CheckLine(npc.Position, targetPosition, 1)

				if npc:CollidesWithGrid() then
					dat.lastGridCollision = npc.FrameCount
				end

				if hasLineOfSight and dat.lastGridCollision + 24 < npc.FrameCount then
					npc.Velocity = mod.XalumLerp(npc.Velocity, targetVelocity, 0.1)
				else
					npc.Pathfinder:FindGridPath(targetPosition, 0.5, 0, true) -- Why is this so fucking fast ??????
				end
			end
		end
	end,

	Collision = function(npc, collider)
		if collider.Type == mod.FFID.Boss and collider.Variant == npc.Variant then
			local bdat = npc:GetData()
			local edat = collider:GetData()

			local dist = npc.Position:Distance(collider.Position)

			if dist < npc.Size + collider.Size - 15 and ((bdat.cancombine and edat.cancombine) or (not (bdat.combining or bdat.combiner) and dist <= 15)) then
				bdat.combining = collider
				bdat.cancombine = false

				edat.combiner = npc
				edat.cancombine = false
			end

			return true
		end
	end,

	Damage = function(npc, amount, flags, source, cooldown)
		local data = npc:GetData()
		if data.tsar then
			data.tsar:TakeDamage(amount / 2, flags, source, cooldown)
		end
	end,
}
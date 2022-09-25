local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

-- Deprecated
--[[ function mod.GetNextOssularryTarget(npc)
	local pos = npc.Position
	local room = game:GetRoom()

	local i = npc.FrameCount + npc.InitSeed + Random()

	repeat
		pos = Isaac.GetFreeNearPosition(room:GetGridPosition(room:GetRandomTileIndex(i)), 40)
		i = i + 1
	until npc.Pathfinder:HasPathToPos(pos, false) and pos:Distance(npc.Position) > 80
	return pos
end]]

-- New
local function getNewTarget(npc)
	local position = npc.Position
	local room = game:GetRoom()
	local data = npc:GetData()

	mod.XalumInitNpcRNG(npc)

	local i = 0
	repeat
		position = Isaac.GetFreeNearPosition(room:GetGridPosition(room:GetRandomTileIndex(data.rng:RandomInt(5000))), 40)
		i = i + 1
	until i >= 32 or (npc.Pathfinder:HasPathToPos(position, false) and position:Distance(npc.Position) >= 80)

	local failed = i >= 32
	if failed then
		position = npc.Position
	end

	return position, failed
end
mod.GetNextOssularryTarget = getNewTarget

return {
	Init = function(npc)
		mod.XalumInitNpcRNG(npc)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	end,
	PreUpdate = function(npc)
		mod.NegateKnockoutDrops(npc)
	end,
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		

		if npc.SubType == 0 then
			if not npc.Child or FiendFolio:isStatusCorpse(npc.Child) then
				data.ossuhead = true
				--data.target = Isaac.Spawn(1000, 153, 0, Vector.Zero, Vector.Zero, nil)

				local curr = npc

				while curr do
					local did

					local closest
					local dist = 60

					for _, ent in pairs (Isaac.FindByType(npc.Type, npc.Variant, 0)) do
						if ent.Position:Distance(curr.Position) < dist and not ent:GetData().ossuhead then
							closest = ent
							dist = ent.Position:Distance(curr.Position)
						end
					end

					if closest then
						did = true

						curr.Child = closest
						closest.Parent = curr
						closest.SubType = curr.SubType + 1
						curr = closest
					end

					if not did then curr = nil end
				end
			end

			if game:GetRoom():GetGridCollisionAtPos(npc.Position) == GridCollisionClass.COLLISION_NONE then
				data.targetpos = data.targetpos or getNewTarget(npc)
				if npc.Position:Distance(data.targetpos) < 10 or not npc.Pathfinder:HasPathToPos(data.targetpos, false) then
					data.targetpos = getNewTarget(npc)
				end

				mod.XalumGridPathfind(npc, data.targetpos, 6)
			else
				local gridPosition = mod.XalumAlignPositionToGrid(npc.Position)
				local targetVelocity = (npc.Position - gridPosition):Resized(8)

				npc.Velocity = mod.XalumLerp(npc.Velocity, targetVelocity, 0.3)
			end

			--FiendFolio.Xalum_gridpathfind(npc, 6, data.targetpos)
			--data.target.Position = data.targetpos

			if not npc.Child or npc.Child:IsDead() or not npc.Child:Exists() or FiendFolio:isStatusCorpse(npc.Child) then
				npc:Die()
			end

			if npc.Child then
				if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
					sprite:Play("WalkHeadHori")
					sprite.FlipX = npc.Velocity.X < 0

					npc.RenderZOffset = npc.Child.RenderZOffset + math.max(0, math.ceil(npc.Child.Position.Y - npc.Position.Y) + 1)
				else
					npc.RenderZOffset = npc.Child.RenderZOffset
					if npc.Velocity.Y < 0 then
						sprite:Play("WalkHeadUp")
					else
						sprite:Play("WalkHeadDown")
					end
					sprite.FlipX = false
				end
			end
		else -- Butts
			if npc.Parent then
				if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
					sprite:Play("WalkBodyHori")
					sprite.FlipX = npc.Velocity.X < 0
				else
					sprite:Play("WalkBodyVert")
					sprite.FlipX = false
				end

				local dist = npc.Position:Distance(npc.Parent.Position)
				local speed = 6
				if dist > 45 then speed = 7.5 end
				if dist < 35 then speed = 4.5 end

				

				if game:GetRoom():GetGridCollisionAtPos(npc.Position) == GridCollisionClass.COLLISION_NONE then
					mod.XalumGridPathfind(npc, npc.Parent.Position, speed)
				else
					local targetPosition = npc.Parent.Position + (npc.Position - npc.Parent.Position):Resized(30)
					local targetVelocity = (targetPosition - npc.Position):Resized(speed)

					npc.Velocity = mod.XalumLerp(npc.Velocity, targetVelocity, 0.3)
				end

				--FiendFolio.Xalum_gridpathfind(npc, speed, npc.Parent.Position)
				--npc.Velocity = (npc.Parent.Position - npc.Parent.Velocity:Resized(40) - npc.Position)
				--npc.Velocity = npc.Velocity:Resized(math.min(npc.Velocity:Length() * 0.9, 8))

				if npc.Parent:IsDead() or FiendFolio:isStatusCorpse(npc.Parent) then
					npc.SubType = 0
					data.ossuhead = true
					--data.target = Isaac.Spawn(1000, 153, 0, Vector.Zero, Vector.Zero, nil)
					npc.Parent = nil
				end
			else
				npc.SubType = 0
				data.ossuhead = true
				--data.target = Isaac.Spawn(1000, 153, 0, Vector.Zero, Vector.Zero, nil)
				npc.Parent = nil
			end
		end

		if npc:IsDead() and not FiendFolio:isLeavingStatusCorpse(npc) then
			--if data.target then data.target:Remove() end

			local off = math.random(360)
			for i = 1, 3 do
				local projectile = Isaac.Spawn(9, 1, 0, npc.Position, Vector(12, 0):Rotated(off + 120*i), npc):ToProjectile();
				projectile.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
				local s = projectile:GetSprite()
				s:Load("gfx/projectiles/boomerang rib big.anm2",true)
				s:Play("spin",false)
				projectile.Parent = npc
				projectile.FallingSpeed = 0
				projectile.FallingAccel = -0.066
				projectile.ProjectileFlags = ProjectileFlags.NO_WALL_COLLIDE

				local pd = projectile:GetData()
				pd.projType = "boomerang"
				pd.origpos = npc.Position
				pd.rot = 0
			end
		end
	end,
	Collision = function(npc, collider)
		if collider.Type == npc.Type and collider.Variant == npc.Variant then
			return true
		end
	end,
}
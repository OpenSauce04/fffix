local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local d = fam:GetData()
	local sprite = fam:GetSprite()
	local room = game:GetRoom()
	local isSuperpositioned = mod:isSuperpositionedPlayer(fam.Player)
	local isSirenCharmed = mod:isSirenCharmed(fam)

	if not d.init then
		fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		local pos = mod:GetClosestWall(fam.Position, true)
		fam.Position = pos[1]
		d.clampPos = fam.Position
		d.Alignment = pos[2]
		if Sewn_API then
			if pos[2] == 1 then
				--Facing Right
				Sewn_API:AddCrownOffset(fam, Vector(-5, -10))
			elseif pos[2] == 3 then
				--Facing Left
				Sewn_API:AddCrownOffset(fam, Vector(5, -10))
			elseif pos[2] == 2 then
				--Facing Down
				Sewn_API:AddCrownOffset(fam, Vector(0, -20))
			elseif pos[2] == 4 then
				--Facing Up
				Sewn_API:AddCrownOffset(fam, Vector(0, -5))
			end
			print(pos[2])
		end
		fam.SpriteRotation = (pos[2] * 90) + 180
		fam.SpriteOffset = Vector(0, 16):Rotated(fam.SpriteRotation)

		d.StateFrame = 0
		d.shooting = nil
		d.state = "walk"
		d.init = true
	else
		d.StateFrame = d.StateFrame or 0
		d.StateFrame = d.StateFrame + 1
	end
	
	if d.state == "walk" then
		local clamp = 1
		if d.Alignment % 2 == 0 then
			clamp = 2
		end
		local target 
		if isSirenCharmed then
			target = mod:getClosestPlayer(fam.Position, 800)
		else
			target = mod.FindClosestEnemy(fam.Position, 800, true)
		end
		target = target or fam.Player
		local pos = {target.Position.X, target.Position.Y - 25}
		local fampos = {d.clampPos.X, d.clampPos.Y}
		pos[clamp] = fampos[clamp]
		local targvec = (Vector(pos[1], pos[2]) - fam.Position) * 0.6
		local moveMax = 5
		if (Sewn_API and Sewn_API:IsSuper(d, true)) then
			moveMax = 10
		end
		if targvec:Length() > moveMax then
			targvec = targvec:Resized(moveMax)
		end

		local grident = room:GetGridEntityFromPos(room:GetGridPosition(room:GetGridIndex(fam.Position)) + targvec:Resized(20))
		if (grident and (grident.Desc.Type == GridEntityType.GRID_WALL or grident.Desc.Type == GridEntityType.GRID_DOOR)) then
			fam.Velocity = mod:Lerp(fam.Velocity, targvec, 0.3)
		else
			fam.Velocity = nilvector
		end

		if fam.Velocity:Length() > 0.2 then
			mod:spritePlay(sprite, "Walk")
			d.spriteFrame = sprite:GetFrame()
		else
			d.spriteFrame = d.spriteFrame or 0
			sprite:SetFrame("Walk", d.spriteFrame)
		end

		if ((target.Type ~= 1 and not isSirenCharmed) or (target.Type == 1 and isSirenCharmed)) and 
		   d.StateFrame and 
		   (d.StateFrame > 50 or (Sewn_API and Sewn_API:IsSuper(d, true) and d.StateFrame > 10)) 
		then
			d.state = "shoot"
		elseif (target.Type == 1 and not isSirenCharmed) or (target.Type ~= 1 and isSirenCharmed) then
			if d.StateFrame and d.StateFrame > 5 then
				d.StateFrame = d.StateFrame - 1
			end
		end
	elseif d.state == "shoot" then
		fam.Velocity = nilvector
		if sprite:IsFinished("Attack") then
			d.state = "walk"
			d.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			d.shooting = 0
		else
			mod:spritePlay(sprite, "Attack")
		end
	else
		d.init = nil
	end

	if d.shooting then
		d.shooting = d.shooting + 1
		local shoot1, shoot2 = 2, 1
		if fam.Player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) then
			shoot1, shoot2 = 1, 0
		end
		if d.shooting % shoot1 == shoot2 then
			local shootRots = {0, 0, 1}
			if Sewn_API and Sewn_API:IsUltra(d) then
				shootRots = {-20, 20, 20}
			end
			for i = shootRots[1], shootRots[2], shootRots[3] do
				local vec = Vector(0, -12):Rotated((d.Alignment or 0) * 90):Rotated(i)
				if isSirenCharmed then
					local proj = Isaac.Spawn(9, 0, 0, fam.Position + vec:Resized(25) + Vector(0, 25), vec, fam):ToProjectile()
					proj.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
					proj.FallingAccel = -0.05
					proj:Update()
				else
					local tear = Isaac.Spawn(2, 0, 0, fam.Position + vec:Resized(25) + Vector(0, 25), vec, fam):ToTear()
					if fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
						tear.Scale = 1.1
						tear.CollisionDamage = 4
					else
						tear.Scale = 0.9
						tear.CollisionDamage = 2
					end
					tear.TearFlags = tear.TearFlags | TearFlags.TEAR_SPECTRAL
					if fam.Player:HasTrinket(TrinketType.TRINKET_BABY_BENDER) then
						tear.TearFlags = tear.TearFlags | TearFlags.TEAR_HOMING
						tear:GetData().customtype = "makeyinyangorb"
						tear:GetData().yinyangstrength = 0.05
						tear.Color = FiendFolio.ColorPsy
					end
					tear.FallingAcceleration = -0.05
					if isSuperpositioned then
						local tearcolor = Color.Lerp(tear.Color, Color(1,1,1,1,0,0,0), 0)
						tearcolor.A = tearcolor.A / 4
						tear.Color = tearcolor
					end
					tear:Update()
				end
			end
		end
		if d.shooting >= 8 then
			d.shooting = nil
		end
	end
end, FamiliarVariant.PEACH_CREEP)
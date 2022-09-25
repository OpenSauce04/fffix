local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:madclawAI(npc, subt)
	local sprite = npc:GetSprite()
	local path = npc.Pathfinder
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = target.Position

	if not d.init then
		d.count = 100
		d.walktarg = mod:FindRandomValidPathPosition(npc)
		if subt == 1 then
			d.state = "waiting"
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
			npc.Visible = false
		else
			d.state = "idle"
		end
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if sprite:IsEventTriggered("DMG") then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		--npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
	elseif sprite:IsEventTriggered("NoDMG") then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
	end

	if d.state == "idle" then
		d.count = d.count + 1
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		sprite.FlipX = false
		if npc.Velocity:Length() > 1 then
			if npc.Velocity.X > 0 then
				mod:spritePlay(sprite, "WalkRight")
			else
				mod:spritePlay(sprite, "WalkLeft")
			end
		else
			sprite:SetFrame("WalkLeft", 0)
		end

		npc.StateFrame = npc.StateFrame + math.random(3) - 1

		if mod:isScare(npc) then
			d.considering = false
			npc.StateFrame = 0
			local targetvel = (targetpos - npc.Position):Resized(-3.5)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
		elseif game:GetRoom():CheckLine(npc.Position,targetpos,3,1,false,false) and not npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION)  then
			npc.StateFrame = 0
			d.walktarg = npc.Position
			d.considering = true
			local targetvel = (targetpos - npc.Position):Resized(3.5)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
		else
			if npc.StateFrame > 160 or not d.walktarg then
				d.walktarg = mod:FindRandomValidPathPosition(npc)
				d.considering = false
				npc.StateFrame = 0
			end
			if npc.Position:Distance(d.walktarg) > 30 then
				if game:GetRoom():CheckLine(npc.Position,d.walktarg,0,1,false,false) then
					local targetvel = (d.walktarg - npc.Position):Resized(3)
					npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
				else
					path:FindGridPath(d.walktarg, 0.5, 900, true)
				end
			else
				npc.Velocity = npc.Velocity * 0.9
				npc.StateFrame = npc.StateFrame + 2
			end
		end

		if d.considering and not mod:isScareOrConfuse(npc) then
			if math.random(25) and d.count > 100 then
				d.state = "submerge"
				npc:PlaySound(mod.Sounds.SplashLarge,0.6,0,false,1.2)
			end
		end

		if not path:HasPathToPos(targetpos, false) and d.count > 150 then
			d.state = "submerge"
			npc:PlaySound(mod.Sounds.SplashLarge,0.6,0,false,1.2)
		end
	elseif d.state == "submerge" then
		npc.Velocity = nilvector
		if sprite:IsFinished("Submerge") then
			npc.StateFrame = 0
			d.state = "submerged"
			if math.random(2) == 1 then
				d.attack = "snipsnap"
				d.snaps = 0
			else
				d.attack = "swipey"
				d.targ = mod:FindRandomFreePos(target, 120)
			end
		else
			mod:spritePlay(sprite, "Submerge")
		end

	elseif d.state == "submerged" then
		mod:spritePlay(sprite, "SubmergeShadow")
		if d.attack == "snipsnap" then

			local attacktarget = targetpos
			local baby = mod.FindClosestEntity(npc.Position, 99999, mod.FF.BubbleBaby.ID, mod.FF.BubbleBaby.Var, 0)
			if baby then
				if baby.Position:Distance(npc.Position) < targetpos:Distance(npc.Position) then
					attacktarget = baby.Position
				end
			end

			local targetvel = (attacktarget - npc.Position):Resized(9)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.15)

			if npc.Position:Distance(attacktarget) < 15 or npc.StateFrame > 120 then
				mod:DestroyNearbyGrid(npc)
				d.state = "clawemerge"
				npc:PlaySound(mod.Sounds.SplashLargePlonkless,0.6,0,false,1.5)
				npc.Velocity = nilvector
				npc.CollisionDamage = 0
			end
		elseif d.attack == "swipey" then
			local targetvel = (d.targ - npc.Position):Resized(9)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.15)
			if npc.Position:Distance(d.targ) < 15 or npc.StateFrame > 120 then
				d.state = "clawemerge"
				npc:PlaySound(mod.Sounds.SplashLargePlonkless,0.6,0,false,1.5)
				npc.CollisionDamage = 0
				npc.Velocity = nilvector
			end

		elseif d.attack == "safety" then
			local targetvel = (d.home - npc.Position):Resized(9)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.15)
			if npc.Position:Distance(d.home) < 15 then
				d.state = "emerge"
			end
		end

	elseif d.state == "clawemerge" then
		npc.Velocity = nilvector
		if sprite:IsFinished("ClawEmerge") then
			d.state = "clawattack"
			npc.StateFrame = 0
			if d.attack == "swipey" then
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
				d.attackstate = 1
				d.targetvel = (targetpos - npc.Position):Resized(9)
				if targetpos.Y > npc.Position.Y then
					d.dir = "Down"
				else
					d.dir = "Up"
				end
				if targetpos.X > npc.Position.X then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end
			else
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
			end
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		else
			mod:spritePlay(sprite, "ClawEmerge")
		end
	elseif d.state == "clawattack" then
		if d.attack == "snipsnap" then
			npc.Velocity = nilvector
			if sprite:IsFinished("Snap") then
				d.state = "clawsubmerge"
				d.snaps = d.snaps + 1
			elseif sprite:GetFrame() == 2 then
				npc:PlaySound(SoundEffect.SOUND_BONE_SNAP,1,0,false,1.5)
				local baby = mod.FindClosestEntity(npc.Position, 99999, mod.FF.BubbleBaby.ID, mod.FF.BubbleBaby.Var, 0)
				if baby then
					if baby.Position:Distance(npc.Position) < 40 then
						local bubblenumber = math.random (5,9)
						local randangle = 0
						for i=1, bubblenumber, 1 do
							randangle = math.random(0,359)
							mod.ShootBubble(npc, -1, baby.Position + Vector(5,0):Rotated(randangle),Vector((math.random(20,40)/20),0):Rotated(randangle))
						end
						baby:Kill()
					end
				end
				if targetpos:Distance(npc.Position) < 50 then
					target:TakeDamage(2, 0, EntityRef(npc), 0)
					target.Velocity = target.Velocity + (target.Position - npc.Position):Resized(9)
				end
			elseif sprite:GetFrame() == 3 then
				npc.CollisionDamage = 1
			else
				mod:spritePlay(sprite, "Snap")
			end
		elseif d.attack == "swipey" then
			npc.CollisionDamage = 1
			if npc.StateFrame % 3 == 0 then
				local params = ProjectileParams()
				params.FallingSpeedModifier = -15 + math.random(10);
				params.FallingAccelModifier = 2
				params.HeightModifier = 20
				params.Scale = math.random(80,100)/100
				params.Variant = 4
				for i = -90, 90, 180 do
					local vec = npc.Velocity:Resized(9):Rotated(i - 20 + math.random(40))
					npc:FireProjectiles(npc.Position + vec, vec, 0, params)
				end
			end
			if d.attackstate == 1 then
				npc.Velocity = mod:Lerp(npc.Velocity, d.targetvel, 0.15)
				mod:DestroyNearbyGrid(npc, 50)
				if sprite:IsFinished("DragStart" .. d.dir) then
					d.attackstate = 2
				else
					mod:spritePlay(sprite, "DragStart" .. d.dir)
				end
				if mod:isScareOrConfuse(npc) then
					d.state = "clawsubmerge"
					d.snaps = 3
				end
			elseif d.attackstate == 2 then
				local targetvel = (targetpos - npc.Position):Resized(9)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.05)
				local dir
				if npc.Velocity.Y < 0 then
					dir = "Up"
				else
					dir = "Down"
				end
				if npc.Velocity.X > 0 then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end
				mod:spritePlay(sprite, "Drag" .. dir)
				if npc:CollidesWithGrid() or mod:isScareOrConfuse(npc) then
					d.state = "clawsubmerge"
					d.snaps = 3
				end
			end
		end
	elseif d.state == "clawsubmerge" then
		npc.Velocity = nilvector
		if sprite:IsFinished("ClawSubmerge") then
			d.state = "submerged"
			npc.StateFrame = 0
			if mod:isScareOrConfuse(npc) or d.snaps == 3 or (d.snaps == 2 and math.random(2) == 1) or (d.snaps == 1 and math.random(3) == 1) then
				d.attack = "safety"
				d.home = mod:FindRandomFreePos(npc, 80)
			end
		else
			mod:spritePlay(sprite, "ClawSubmerge")
		end
	elseif d.state == "emerge" then
		if not d.splashed then
			npc:PlaySound(mod.Sounds.SplashLargePlonkless,0.6,0,false,0.8)
			d.splashed = true
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
		end
		npc.Velocity = nilvector
		if sprite:IsFinished("Emerge") then
			d.state = "idle"
			d.count = 0
			d.splashed = nil
		else
			mod:spritePlay(sprite, "Emerge")
		end
	elseif d.state == "waiting" then
		if mod.CanIComeOutYet() then
			if npc.StateFrame > 15 then
				if mod.farFromAllPlayers(npc.Position, 60) then
					d.state = "emerge"
					npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
					mod:spritePlay(sprite, "Emerge")
					npc.Visible = true
				end
			end
		else
			npc.StateFrame = 0
		end
	end
end

function mod:madclawColl(npc1, npc2)
    if npc2.Type == mod.FF.Bubble.ID and npc2.Variant == mod.FF.Bubble.Var then
        local d = npc1:GetData()
        if d.state == "clawattack" and d.attack == "swipey" then
            npc2:Kill()
        end
    end
end
local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:fishfaceAI(npc, subt, var)
	local sprite = npc:GetSprite()
	local path = npc.Pathfinder
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)

	if not d.init then
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
	elseif d.init then
		npc.StateFrame = npc.StateFrame + 1
	end

	--Shiny
	if var == 241 then
		if npc:IsDead() then
			for i = 30, 360, 30 do
				local expvec = Vector(0,math.random(10,35)):Rotated(i)
				local sparkle = Isaac.Spawn(1000, 1727, 0, npc.Position + expvec * 0.1, expvec * 0.3, npc):ToEffect()
				sparkle.SpriteOffset = Vector(0,-25)
				sparkle:GetSprite().Rotation = math.random(360)
				sparkle:Update()
			end
			 Isaac.Spawn(23, 1, 0, npc.Position, nilvector, npc)
		end
		if npc.FrameCount % 3 == 0 then
			local sparkle = Isaac.Spawn(1000, 7003, 0, npc.Position, nilvector, npc):ToEffect()
			sparkle.RenderZOffset = -5
			sparkle.SpriteOffset = Vector(-20 + math.random(40), -50 + math.random(40))
			--sparkle.SpriteScale = Vector(0.3,0.3)
		end

	end

	if sprite:IsEventTriggered("DMG") then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
	elseif sprite:IsEventTriggered("NoDMG") then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	end

	if d.state == "idle" then
		if npc.Velocity:Length() > 0.1 then
			npc:AnimWalkFrame("WalkHori","WalkVert",0)
		else
			sprite:SetFrame("WalkVert", 0)
		end

		sprite:PlayOverlay("HeadIdle",true)

		if mod:isScare(npc) then
			local targetvel = (targetpos - npc.Position):Resized(-6)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
		elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
			local targetvel = (targetpos - npc.Position):Resized(4)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
		else
			path:FindGridPath(targetpos, 0.6, 900, true)
			d.currentvelocity = npc.Velocity
		end

		if npc.StateFrame > 30 and (npc.Position:Distance(targetpos) > 120 or path:HasPathToPos(targetpos, false) == false) and not mod:isScareOrConfuse(npc) then
			d.state = "submerge"
			mod:spritePlay(sprite, "Submerge")
			sprite:RemoveOverlay()
			npc.Velocity = nilvector
		end

	elseif d.state == "submerge" then
		npc.Velocity = nilvector
		if sprite:IsFinished("Submerge") then
			d.state = "emerge"
			npc:PlaySound(mod.Sounds.SplashLargePlonkless,0.6,0,false,1.5)
			local roompos = game:GetRoom():FindFreePickupSpawnPosition(targetpos, 80, true)
			npc.Position = roompos
		elseif sprite:IsEventTriggered("Splash") then
			npc:PlaySound(mod.Sounds.SplashLarge,0.6,0,false,1.2)
		else
			mod:spritePlay(sprite, "Submerge")
		end

	elseif d.state == "emerge" then
		npc.Velocity = nilvector
		if sprite:IsFinished("Emerge") then
			d.state = "idle"
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "Emerge")
		end
	elseif d.state == "waiting" then
		--sprite:SetFrame("Emerge", 0)
		if mod.CanIComeOutYet() then
			if npc.StateFrame > 15 then
				if mod.farFromAllPlayers(npc.Position, 60) then
					d.state = "emerge"
					npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
					mod:spritePlay(sprite, "Emerge")
					npc.Visible = true
					npc:PlaySound(mod.Sounds.SplashLargePlonkless,0.6,0,false,1.5)
				end
			end
		else
			npc.StateFrame = 0
		end
	end
end
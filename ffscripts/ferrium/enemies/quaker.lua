local mod = FiendFolio
local game = Game()

function mod:quakerAI(npc)
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	local data = npc:GetData()
	local room = game:GetRoom()
	local rand = npc:GetDropRNG()
	
	if not data.init then
		if npc.SubType > 0 and not data.waited then
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
			npc.Visible = false
			if npc.SubType == 2 and room:GetFrameCount() < 5 then
				local rock = Isaac.GridSpawn(2, 0, npc.Position, true)
				mod:UpdateRocks()
			end
			mod.makeWaitFerr(npc, mod.FFID.Ferrium, npc.Variant, npc.SubType, 60, false)
		elseif data.waited then
			data.state = "Waiting"
			npc.Visible = false
		end
		if npc.SubType > 0 then
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		end
		if npc.SubType == 0 then
			data.state = "Idle"
		end
		data.init = true
		npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
		npc.StateFrame = rand:RandomInt(10)+5
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	if data.isJumping == 1 then
		npc.Friction = 1
		local dist = (npc.Position-data.playerPos):Length()
		if dist < 20 then
			data.state = "JumpDown"
			data.isJumping = 0
			data.targetVel = Vector.Zero
		elseif dist < 40 then
			data.targetVel = (data.playerPos-npc.Position):Resized(2)
		else
			--data.targetVel = npcd.targetVel + -(npc.Position - npcd.PlayerPos):Normalized() * (dist / 65)
			data.targetVel = data.targetVel+ -(npc.Position-data.playerPos):Resized(dist/65)
			local arcVel = data.targetVel
			if arcVel:Length() >= dist then
				data.targetVel = arcVel:Resized(dist)
			end
		end
	else
		data.targetVel = Vector.Zero
	end
	
	if data.state == "Idle" then
		if npc.StateFrame > 45 and not mod:isScareOrConfuse(npc) then
			data.state = "JumpUp"
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "Idle")
		end
	elseif data.state == "JumpUp" then
		if sprite:IsFinished("Jump") then
			--[[data.state = "JumpDown"
			data.IsJumping = 0
			data.targetVel = Vector.Zero]]
		elseif sprite:IsEventTriggered("GetPlayer") then
			local dist = (npc.Position - target.Position):Length()
			local fgkhj = (target.Position - npc.Position):Normalized() * math.min(300,dist)
			local checkSpot = npc.Position+fgkhj
			local gridEnt = room:GetGridEntityFromPos(target.Position)
			if gridEnt ~= nil and gridEnt ~= (GridEntityType.GRID_LOCK or GridEntityType.GRID_SPIKES or GridEntityType.GRID_PIT or GridEntityType.GRID_WALL or GridEntityType.GRID_PILLAR) then
				data.playerPos = (npc.Position+fgkhj) + (RandomVector())
			else
				data.playerPos = room:FindFreeTilePosition(npc.Position + fgkhj, 40) + (RandomVector())
			end
			
			data.isJumping = 1
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		elseif sprite:IsEventTriggered("Sound") then
			npc:PlaySound(SoundEffect.SOUND_SHELLGAME,1,2,false,0.7)
		else
			mod:spritePlay(sprite, "Jump")
		end
	elseif data.state == "JumpDown" then
		if sprite:IsFinished("Fall") then
			data.state = "Idle"
			npc.StateFrame = -rand:RandomInt(15)
		elseif sprite:IsEventTriggered("Land") then
			for _,grid in ipairs(mod.GetGridEntities()) do
				if grid.Position:Distance(npc.Position) < 65 then
					grid:Destroy()
					--[[if v:Destroy() then
						local r = npc:GetDropRNG()
						local params = ProjectileParams()
						params.Variant = 9
						params.FallingAccelModifier = 1.5
						params.Scale = 0.9
						for i = 60, 360, 60 do
							params.FallingSpeedModifier = -30 + math.random(10)
							local rand = r:RandomFloat()
							npc:FireProjectiles(v.Position, Vector(0,2):Rotated(i-40+rand*80), 0, params)
						end
					end]]
				end
			end
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			
			local params = ProjectileParams()
			params.Variant = 9
			for i=90,360,90 do
				npc:FireProjectiles(npc.Position, Vector(0,8):Rotated(i), 0, params)
			end
			
			--[[for _,player in ipairs(Isaac.FindInRadius(npc.Position, 90, EntityPartition.PLAYER)) do
				if player.CanFly ~= true and player.PositionOffset.Y > -2 and not player:GetData().KnockbackByEnemyThing then
					table.insert(mod.playerKnockbackByMinesEnemies, {["player"] = player, ["zVel"] = 60, ["frame"] = 1, ["vel"] = (player.Position-npc.Position):Resized(10)})
					player:GetData().KnockbackByEnemyThing = true
				end
			end]]
			
			local quakey = Isaac.Spawn(823, 0, 0, npc.Position, Vector.Zero, npc):ToNPC()
			quakey:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			quakey.State = 8
			quakey:GetSprite():Play("Jump", true)
			quakey:GetSprite():SetFrame(19)
			quakey:GetData().quakerSpawned = true
			quakey:Update()
			quakey:Remove()
			for _, proj in ipairs(Isaac.FindByType(9, 9, -1, false, false)) do
				if proj.SpawnerType == 823 and proj.Position:Distance(npc.Position) < 2 and proj.FrameCount < 1 then
					proj:Remove()
				end
			end
		else
			mod:spritePlay(sprite, "Fall")
		end
	elseif data.state == "Waiting" then
		npc.Velocity = Vector.Zero
		sprite:Play("Fall", true)
		data.state = "JumpDown"
		npc:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
		npc.Visible = true
		npc.Position = npc.Position+RandomVector()*5
	end
	
	if data.state == "JumpUp" or data.state == "JumpDown" then
		npc.Velocity = (data.targetVel * 0.3) + (npc.Velocity * 0.6)
	else
		npc.Velocity = Vector.Zero
	end
end
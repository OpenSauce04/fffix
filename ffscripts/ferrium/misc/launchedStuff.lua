local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:flyingFuck(npc)
	local data = npc:GetData()
	if data.launchedEnemyInfo then
		local tab = data.launchedEnemyInfo
		local room = game:GetRoom()
		local isPaused = game:IsPaused()
		local isReflected = (room:GetRenderMode() == RenderMode.RENDER_WATER_REFLECT)
		if not (isPaused or isReflected or mod.IsCoalscoopSecondRender) then
			tab.zVel = tab.zVel or 0
			tab.frames = tab.frames or 0
			tab.accel = tab.accel or 0.3
			if tab.extraFunc then
				tab.extraFunc(npc, tab)
			end
			if tab.vel then
				npc.Velocity = tab.vel
			end
			if tab.additional then --wait why did I make two of these, god damn it, and I don't want to break anything by deleting it
				tab.additional(tab)
			end

			if tab.pos then
				--Position Offset, not position.
				if tab.custom then
					tab.custom(npc, tab)
				else
					tab.height = tab.height or npc.PositionOffset.Y
					local offset = tab.height+tab.zVel+tab.accel/2
					npc.PositionOffset = Vector(0, offset)
					tab.height = offset
					tab.zVel = tab.zVel + tab.accel
					
					if npc.PositionOffset.Y > 0 then
						data.launchedEnemyInfo = nil
						data.launchedEnemyLanded = true
						if tab.landFunc then
							tab.landFunc(npc, tab)
						end
						npc.PositionOffset = Vector(npc.PositionOffset.X, 0)
					end
					if tab.collision then
						if npc.PositionOffset.Y < tab.collision then
							npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
							npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
						else
							npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
							if data.playerobjectscoll then
								npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
							else
								npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
							end
						end
					end
				end
			else
				if tab.custom then
					tab.custom(npc, tab)
				else
					tab.height = tab.height or npc.SpriteOffset.Y
					local offset = tab.height+tab.zVel+tab.accel/2
					npc.SpriteOffset = Vector(0, offset)
					tab.height = offset
					tab.zVel = tab.zVel + tab.accel
					
					if npc.SpriteOffset.Y > 0 then
						data.launchedEnemyInfo = nil
						data.launchedEnemyLanded = true
						if tab.landFunc then
							tab.landFunc(npc, tab)
						end
						npc.SpriteOffset = Vector(npc.SpriteOffset.X, 0)
					end
					if tab.collision then
						if npc.SpriteOffset.Y < tab.collision then
							npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
							npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
						else
							npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
							if data.playerobjectscoll then
								npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
							else
								npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
							end
						end
					end
				end
			end
		end
	end
	if data.followParentInfo then
		local tab = data.followParentInfo
		local room = game:GetRoom()
		local isPaused = game:IsPaused()
		local isReflected = (room:GetRenderMode() == RenderMode.RENDER_WATER_REFLECT)
		if not (isPaused or isReflected) then
			if not tab.init then
				tab.init = true
				tab.recordParent = {}
			end
			tab.max = tab.max or 10
			tab.min = tab.min or 2
			tab.parent = tab.parent or npc.Parent
			
			if tab.specialFunc then
				tab.specialFunc(npc, tab)
			end
			
			if tab.parent and tab.parent:Exists() then
				table.insert(tab.recordParent, {position = tab.parent.Position, velocity = tab.parent.Velocity})
				if #tab.recordParent > tab.max then
					table.remove(tab.recordParent, 1)
				end

				if #tab.recordParent > tab.min then
					npc.Position = tab.recordParent[tab.min-1].position
					npc.Velocity = tab.recordParent[tab.min-1].velocity
				end
			else
				data.followParentInfo = nil
				data.followParentStopped = true
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, mod.flyingFuck)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function(_, npc)
	local data = npc:GetData()
	if data.launchedEnemyInfo then
		local tab = data.launchedEnemyInfo
		local room = game:GetRoom()
		local isPaused = game:IsPaused()
		local isReflected = (room:GetRenderMode() == RenderMode.RENDER_WATER_REFLECT)
		if not (isPaused or isReflected) then
			tab.zVel = tab.zVel or 0
			tab.frames = tab.frames or 0
			tab.accel = tab.accel or 0.3
			if tab.extraFunc then
				tab.extraFunc(npc, tab)
			end
			if tab.vel then
				npc.Velocity = tab.vel
			end
			if tab.additional then
				tab.additional(tab)
			end
			
			if tab.pos then
				--Position Offset, not position.
				if tab.custom then
					tab.custom(npc, tab)
				else
					tab.height = tab.height or npc.PositionOffset.Y
					local offset = tab.height+tab.zVel+tab.accel/2
					npc.PositionOffset = Vector(0, offset)
					tab.height = offset
					tab.zVel = tab.zVel + tab.accel
					
					if npc.PositionOffset.Y > 0 then
						data.launchedEnemyInfo = nil
						data.launchedEnemyLanded = true
						if tab.landFunc then
							tab.landFunc(npc, tab)
						end
					end
					if tab.collision then
						if npc.PositionOffset.Y < tab.collision then
							npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
							npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
						else
							npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
							npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
						end
					end
				end
			else
				if tab.custom then
					tab.custom(npc, tab)
				else
					tab.height = tab.height or npc.SpriteOffset.Y
					local offset = tab.height+tab.zVel+tab.accel/2
					npc.SpriteOffset = Vector(0, offset)
					tab.height = offset
					tab.zVel = tab.zVel + tab.accel
					
					if npc.SpriteOffset.Y > 0 then
						data.launchedEnemyInfo = nil
						data.launchedEnemyLanded = true
						if tab.landFunc then
							tab.landFunc(npc, tab)
						end
					end
					if tab.collision then
						if npc.SpriteOffset.Y < tab.collision then
							npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
							npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
						else
							npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
							npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
						end
					end
				end
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_, npc)
	mod:flyingFuckEffect(npc)
end, 16)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_, npc)
	if npc.SubType == mod.FF.Dogboard.Sub then
		mod:flyingFuckEffect(npc)
	end
end, mod.FF.Dogboard.Var)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_, npc)
	if npc.SubType == mod.FF.LunksackNeedle.Sub then
		mod:flyingFuckEffect(npc)
	end
end, 1750)

function mod:flyingFuckEffect(npc)
	local data = npc:GetData()
	if data.launchedEnemyInfo then
		local tab = data.launchedEnemyInfo
		local room = game:GetRoom()
		local isPaused = game:IsPaused()
		local isReflected = (room:GetRenderMode() == RenderMode.RENDER_WATER_REFLECT)
		if not (isPaused or isReflected) then
			tab.zVel = tab.zVel or 0
			tab.frames = tab.frames or 0
			tab.accel = tab.accel or 0.3
			if tab.extraFunc then
				tab.extraFunc(npc, tab)
			end

			if tab.vel then
				npc.Velocity = tab.vel
			end
			if tab.additional then
				tab.additional(tab)
			end
			
			if tab.pos then
				--Position Offset, not position.
				if tab.custom then
					tab.custom(npc, tab)
				else
					tab.height = tab.height or npc.PositionOffset.Y
					local offset = tab.height+tab.zVel+tab.accel/2
					npc.PositionOffset = Vector(0, offset)
					tab.height = offset
					tab.zVel = tab.zVel + tab.accel
					
					if npc.PositionOffset.Y > 0 then
						data.launchedEnemyInfo = nil
						data.launchedEnemyLanded = true
						if tab.landFunc then
							tab.landFunc(npc, tab)
						end
					end
					if tab.collision then
						if npc.PositionOffset.Y < tab.collision then
							npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
							npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
						else
							npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
							npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
						end
					end
				end
			else
				if tab.custom then
					tab.custom(npc, tab)
				else
					tab.height = tab.height or npc.SpriteOffset.Y
					local offset = tab.height+tab.zVel+tab.accel/2
					npc.SpriteOffset = Vector(0, offset)
					tab.height = offset
					tab.zVel = tab.zVel + tab.accel
					
					if npc.SpriteOffset.Y > 0 then
						data.launchedEnemyInfo = nil
						data.launchedEnemyLanded = true
						if tab.landFunc then
							tab.landFunc(npc, tab)
						end
					end
					if tab.collision then
						if npc.SpriteOffset.Y < tab.collision then
							npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
							npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
						else
							npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
							npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
						end
					end
				end
			end
		end
	end
end

function mod:marioMode(player)
	local data = player:GetData()
	if player:HasCollectible(CollectibleType.COLLECTIBLE_HOW_TO_JUMP) then
		if not data.launchedEnemyInfo then
			local customFunc = function(npc, tab)
				tab.height = tab.height or npc.SpriteOffset.Y
				local offset = tab.height+tab.zVel+tab.accel/2
				npc.SpriteOffset = Vector(0, offset)
				tab.height = offset
				tab.zVel = tab.zVel + tab.accel
					
				if npc.SpriteOffset.Y > 0 then
					data.launchedEnemyInfo = nil
					data.launchedEnemyLanded = true
				end
				if tab.collision then
					if npc.SpriteOffset.Y > tab.collision-5 then
						local jumpman
						for _,enemy in ipairs(Isaac.FindInRadius(npc.Position, 40, EntityPartition.ENEMY)) do
							if enemy:IsActiveEnemy() and (not mod:isFriend(enemy)) then
								jumpman = true
								enemy:TakeDamage(player.Damage, 0, EntityRef(npc), 0)
							end
						end
						if jumpman == true then
							if not tab.oneup then
								tab.oneup = 0
							end
							tab.oneup = tab.oneup+1
							if tab.oneup == 11 then
								Isaac.Spawn(5, 100, 11, game:GetRoom():FindFreePickupSpawnPosition(npc.Position, 40, true, false), Vector.Zero, nil)
							end
							tab.zVel = -4
							sfx:Play(mod.Sounds.BingBingWahoo, 0.3, 0, false, 1)
						end
					end
				
					if npc.SpriteOffset.Y < tab.collision then
						npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
						npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					else
						npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
						npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
						tab.oneup = 0
					end
				end
			end
		
			data.launchedEnemyInfo = {zVel = -6, collision = -10, custom = customFunc}
			sfx:Play(mod.Sounds.BingBingWahoo, 0.3, 0, false, 1)
		end
	end
end
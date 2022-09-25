local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:gasPocketUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.GAS_POCKET) then
		local room = game:GetRoom()
		local mult = math.ceil(mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.GAS_POCKET))
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.GAS_POCKET)
		local chance = math.min(75, 15+20*mult+player.Luck)
		local queuedItem = player.QueuedItem
		
		if queuedItem.Item ~= nil and queuedItem.Item:IsTrinket() and queuedItem.Item.ID == FiendFolio.ITEM.ROCK.GAS_POCKET then
			if not data.gasPocketUpdate then
				mod.setRockTable()
				data.gasPocketUpdate = true
			end
		else
			data.gasPocketUpdate = nil
		end
		
		for _,grid in ipairs(mod.GetGridEntities()) do
			if mod.gasPocketRocks[grid:GetGridIndex()] ~= nil then
				if grid.CollisionClass == GridCollisionClass.COLLISION_NONE then
					mod.gasPocketRocks[grid:GetGridIndex()] = nil
					if rng:RandomInt(100) < chance then
						--sfx:Play(SoundEffect.SOUND_FART, 0.5, 0, false, 1)
						game:Fart(grid.Position, 85, player, 1, 0)
						local rangle = rng:RandomInt(360)
						for i=72,360,72 do
							local cloud = Isaac.Spawn(1000, 141, 0, grid.Position, Vector(0,3):Rotated(rangle+i), player):ToEffect()
							cloud.Parent = player
							cloud.SpriteScale = Vector(0.1, 0.1)
							cloud:GetData().moveGasInfo = {vel = Vector(0,0.7):Rotated(rangle+i), timeout = 160*mult, grow = 0.01, growLimit = 1.5}
						end
					end
				end
			end
		end
		
		
		if player.FrameCount % 120 == 0 and not room:IsClear() then
			local gasCount = 0
			for _,grid in ipairs(mod.GetGridEntities()) do
				if mod.gasPocketRocks[grid:GetGridIndex()] ~= nil then
					if rng:RandomInt(100) < 10 then
						gasCount = gasCount+1
						local rangle = rng:RandomInt(360)
						local cloud = Isaac.Spawn(1000, 141, 0, grid.Position, Vector(0,1):Rotated(rangle), player):ToEffect()
						cloud.Parent = player
						cloud.SpriteScale = Vector.Zero
						cloud.CollisionDamage = player.Damage/2
						cloud:GetData().moveGasInfo = {vel = Vector(0,0.55):Rotated(rangle), stopMovement = 40, timeout = 70*mult, grow = 0.008, growLimit = 0.66}
					end
					if gasCount > 3 then
						break
					end
				end
			end
		end
	end
end
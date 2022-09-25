local mod = FiendFolio
local game = Game()

function mod:quantumGeodeOnFireTear(player, tear)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.QUANTUM_GEODE) then
		local pData = player:GetData()
		if not pData.quantumTears then
			pData.quantumTears = {}
		end
		local data = tear:GetData()
		local tearLimit = 1
		if mod.HasTwoGeodes(player) then
			tearLimit = 2
		end
		
		local sprite = tear:GetSprite()
		local file = sprite:GetFilename()
		local anim = sprite:GetAnimation()
		
		local tears = {}
		data.quantum = 1
		table.insert(tears, tear)
		for i=-20,20,40 do
			local newTear = Isaac.Spawn(tear.Type, tear.Variant, tear.SubType, tear.Position, tear.Velocity:Rotated(i), player):ToTear()
			for key,entry in pairs(data) do
				newTear:GetData()[key] = entry
			end
			newTear.Color = tear.Color
			newTear.Parent = tear.Parent
			newTear.Child = tear.Child
			newTear.CollisionDamage = tear.CollisionDamage
			newTear.Scale = tear.Scale
			newTear.FallingSpeed = tear.FallingSpeed
			newTear.FallingAcceleration = tear.FallingAcceleration
			newTear.CanTriggerStreakEnd = false
			newTear.TearFlags = tear.TearFlags
			
			local nSprite = newTear:GetSprite()
			nSprite:Load(file, true)
			nSprite:Play(anim)
			
			if data.customTearSpritesheet then
				nSprite:ReplaceSpritesheet(0, data.customTearSpritesheet)
				nSprite:LoadGraphics()
			end
			
			table.insert(tears, newTear)
		end
		table.insert(pData.quantumTears, {tears, tearLimit, 0})
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function(_,tear,coll,low)
	if tear:GetData().quantum then
		if coll:ToNPC() then
			tear:GetData().quantum = 0
		end
	end
end)

function mod:quantumGeodeTearChecks(key, entry, player)
	local tears = entry[1]
	for _,tear in ipairs(tears) do	
		if tear:GetData().quantum == 0 then
			entry[3] = entry[3]+1
			tear:GetData().quantum = -1
		end
	end
	
	if entry[3] >= entry[2] then
		for _,tear in ipairs(tears) do
			if tear ~= nil then
				if tear:Exists() and not tear:IsDead() then
					--tear:Die()
					tear:Remove()
					for i=1,7 do
						local ember = Isaac.Spawn(1000,66,0,tear.Position, RandomVector()*math.random(10,45)/10, nil):ToEffect()
						ember.Color = Color(math.random(255)/255,math.random(255)/255,math.random(255)/255,1,0,0,0)
						ember.Scale = math.random(50,100)/100
						ember:SetTimeout(5)
						ember:Update()
					end
				end
			end
		end
		table.remove(player:GetData().quantumTears, key)
	end
	local exists = 3
	for _,tear in ipairs(tears) do
		if not tear:Exists() then
			exists = exists-1
		end
	end
	
	if exists <= 0 then
		table.remove(player:GetData().quantumTears, key)
	end
end

function mod:quantumGeodeNewRoom()
	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i - 1)
		if player:GetData().quantumTears then
			player:GetData().quantumTears = {}
		end
	end
end
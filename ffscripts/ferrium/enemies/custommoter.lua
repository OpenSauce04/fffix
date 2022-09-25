local mod = FiendFolio
local game = Game()

local moterBodyDist = 6
local moterFloatHeight = Vector(0, -20)
local function isMoter(moterDat, x, y)
	return moterDat[x] and moterDat[x][y]
end

function mod:customMoterRender(npc)
	if npc.Variant ~= 114 then return end

	local data = npc:GetData()
	local sprite = npc:GetSprite()

	local frame = npc.FrameCount % 4

	if data.moter then
		local worldPos = npc.Position + npc.PositionOffset
		local room = game:GetRoom()
		local renderPos = Isaac.WorldToScreen(worldPos) + data.renderoffset + moterFloatHeight
		local moter = data.moter
		local middleX = math.ceil(((data.bottomright.X - data.topleft.X) + 1) / 2)
		for x = data.topleft.X, data.bottomright.X do
			for y = data.topleft.Y, data.bottomright.Y do
				if isMoter(moter, x, y) then
					local atOrigin = Vector(x, y) - data.topleft
					local offset = atOrigin * moterBodyDist

					sprite.FlipX = (atOrigin.X + 1) > middleX
					sprite.FlipY = false

					if sprite.FlipX then
						offset = offset + Vector(-1, 0)
					end

					if y == data.topleft.Y then
						sprite:SetFrame("Body", frame)
					elseif y == data.bottomright.Y then
						sprite:SetFrame("BodyBottom", frame)
					else
						sprite:SetFrame("BodyBothSides", frame)
					end

					local bodyPos = renderPos + offset
					sprite:Render(bodyPos, Vector.Zero, Vector.Zero)

					local left, right = isMoter(moter, x - 1, y), isMoter(moter, x + 1, y)
					local up, down = isMoter(moter, x, y - 1), isMoter(moter, x, y + 1)
					if not (left and right) and not (down and up) then -- render wings only at corners
						local shouldRenderTLWing = not left and not up
						local shouldRenderBLWing = not left and not down
						local shouldRenderTRWing = not right and not up
						local shouldRenderBRWing = not right and not down

						sprite:SetFrame("Wing", frame)

						local leftWingOffset, rightWingOffset = Vector.Zero, Vector.Zero
						if sprite.FlipX then
							leftWingOffset = Vector(1, 0)
						else
							rightWingOffset = Vector(-1, 0)
						end

						if shouldRenderTLWing then
							sprite.FlipX = false
							sprite.FlipY = false
							sprite:Render(bodyPos + leftWingOffset, Vector.Zero, Vector.Zero)
						end

						if shouldRenderBLWing then
							sprite.FlipX = false
							sprite.FlipY = true
							sprite:Render(bodyPos + leftWingOffset - Vector(0, 1), Vector.Zero, Vector.Zero)
						end

						if shouldRenderTRWing then
							sprite.FlipX = true
							sprite.FlipY = false
							sprite:Render(bodyPos + rightWingOffset, Vector.Zero, Vector.Zero)
						end

						if shouldRenderBRWing then
							sprite.FlipX = true
							sprite.FlipY = true
							sprite:Render(bodyPos + rightWingOffset - Vector(0, 1), Vector.Zero, Vector.Zero)
						end
					end
				end
			end
		end
	end

	sprite:SetFrame("Blank", 0)
end

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, mod.customMoterRender, 18)

local function adjustMinMaxXY(x, y, minX, minY, maxX, maxY)
	if not minX or x < minX then minX = x end
	if not minY or y < minY then minY = y end
	if not maxX or x > maxX then maxX = x end
	if not maxY or y > maxY then maxY = y end

	return minX, minY, maxX, maxY
end

local function initMoterData(data, moterDat, moterPositions, minX, minY, maxX, maxY)
	data.topleft = Vector(minX, minY)
	data.bottomright = Vector(maxX, maxY)
	data.motertotalsize = (data.bottomright - data.topleft) * moterBodyDist
	data.renderoffset = -Vector(data.motertotalsize.X / 2, data.motertotalsize.Y)
	data.moter = moterDat
	data.moterPositions = moterPositions
	data.init = true
end

local function spawnCustomMoterWithShape(pos, vel, parent, moterDat, moterPositions, minX, minY, maxX, maxY)
	local spawn
	if minX == maxX and minY == maxY then -- shape is single fly
		spawn = Isaac.Spawn(18, 0, 0, pos, vel, parent)
	elseif minY == maxY and (minX + 1) == maxX then -- shape is horizontal moter
		spawn = Isaac.Spawn(80, 0, 0, pos, vel, parent)
	end

	if not spawn then
		spawn = Isaac.Spawn(18, 114, 0, pos, vel, parent)
		initMoterData(spawn:GetData(), moterDat, moterPositions, minX, minY, maxX, maxY)
	end

	spawn:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
end

local adjacencies = {
	Vector(-1, 0),
	Vector(1, 0),
	Vector(0, -1),
	Vector(0, 1)
}

local function findMoterFromPosInMoter(rand, moter, pos, moterSize, oldMoterPositions) -- if oldMoterPositions is set, will delete positions it adds to the new moter from that table, as well as from the moter table
	local newMoterPositions = {}
	local newMoter = {}

	local adjacentsNotAdded = {pos}
	local checked = {}

	local minX, minY, maxX, maxY

	while (moterSize and #newMoterPositions < moterSize) or (not moterSize and #adjacentsNotAdded > 0) do
		local add
		if moterSize then
			local addInd = rand:RandomInt(#adjacentsNotAdded) + 1
			add = adjacentsNotAdded[addInd]
			table.remove(adjacentsNotAdded, addInd)
		else
			add = adjacentsNotAdded[#adjacentsNotAdded]
			adjacentsNotAdded[#adjacentsNotAdded] = nil
		end

		if not add then -- this can happen if a moter of a size bigger than legally possible is requested, just returning and generating a new moter should solve it.
			return newMoter, newMoterPositions, minX, minY, maxX, maxY
		end

		newMoterPositions[#newMoterPositions + 1] = add
		if not newMoter[add.X] then
			newMoter[add.X] = {}
		end

		newMoter[add.X][add.Y] = true
		if oldMoterPositions then
			for i, pos in StageAPI.ReverseIterate(oldMoterPositions) do
				if pos.X == add.X and pos.Y == add.Y then
					table.remove(oldMoterPositions, i)
					break
				end
			end

			moter[add.X][add.Y] = nil
		end

		minX, minY, maxX, maxY = adjustMinMaxXY(add.X, add.Y, minX, minY, maxX, maxY)

		for _, adj in ipairs(adjacencies) do
			local adjPos = adj + add
			if not checked[adjPos.X] then
				checked[adjPos.X] = {}
			end

			if not checked[adjPos.X][adjPos.Y] then
				checked[adjPos.X][adjPos.Y] = true

				if isMoter(moter, adjPos.X, adjPos.Y) then
					adjacentsNotAdded[#adjacentsNotAdded + 1] = adjPos
				end
			end
		end
	end

	return newMoter, newMoterPositions, minX, minY, maxX, maxY
end

local function readMoterFromSubtype(subtype)
	local moter = {}
	local moterPositions = {}
	local minX, minY, maxX, maxY
	local readBit = 0
	for y = 1, 4 do
		for x = 1, 4 do
			local bit = FiendFolio.GetBits(subtype, readBit, 1)
			if bit == 1 then
				if not moter[x] then
					moter[x] = {}
				end

				moter[x][y] = true

				moterPositions[#moterPositions + 1] = Vector(x, y)

				minX, minY, maxX, maxY = adjustMinMaxXY(x, y, minX, minY, maxX, maxY)
			end

			readBit = readBit + 1
		end
	end

	return moter, moterPositions, minX, minY, maxX, maxY
end

local function motersLineUp(moter1, moter2, moter1Size, moter2Size, xOff, yOff)
	local moter2RelativeOrigin = (moter2.TL - moter1.TL) * 4
	for x, yValues in pairs(moter2.Shape) do
		for y, hasMoter in pairs(yValues) do
			local relX, relY = x + moter2RelativeOrigin.X, y + moter2RelativeOrigin.Y
			if isMoter(moter1.Shape, relX - 1, relY)
			or isMoter(moter1.Shape, relX + 1, relY)
			or isMoter(moter1.Shape, relX, relY - 1)
			or isMoter(moter1.Shape, relX, relY + 1) then
				return true
			end
		end
	end

	return false
end

local function shiftMoterShape(shape, shiftX, shiftY)
	local outShape = {}
	for x, yValues in pairs(shape) do
		for y, hasMoter in pairs(yValues) do
			if hasMoter then
				if not outShape[x + shiftX] then
					outShape[x + shiftX] = {}
				end

				outShape[x + shiftX][y + shiftY] = hasMoter
			end
		end
	end

	return outShape
end

local function tryMoterStitching()
	local room = game:GetRoom()
	local moters = Isaac.FindByType(18, 114)
	local gridToMoter = {}
	local moterGridPositions = {}
	local moterData = {}
	for _, moter in ipairs(moters) do
		local x, y = StageAPI.GridToVector(room:GetGridIndex(moter.Position))
		if not gridToMoter[x] then
			gridToMoter[x] = {}
		end

		local moterDat, moterPositions, minX, minY, maxX, maxY = readMoterFromSubtype(moter.SubType)
		local data = {
			Entity = moter,
			Shape = moterDat,
			Positions = moterPositions,
			MinX = minX,
			MinY = minY,
			MaxX = maxX,
			MaxY = maxY
		}
		moterData[#moterData + 1] = data

		if minX == 1 or minY == 1 or maxX == 4 or maxY == 4 then
			data.TL = Vector(x, y)
			data.BR = Vector(x, y)
			gridToMoter[x][y] = data
			moterGridPositions[#moterGridPositions + 1] = Vector(x, y)
		end
	end

	for _, gridPos in ipairs(moterGridPositions) do
		local moter1 = gridToMoter[gridPos.X][gridPos.Y]
		local m1GridSize = ((moter1.BR - moter1.TL) + Vector.One) * 4
		for _, adj in ipairs(adjacencies) do
			local gridPosOff = gridPos + adj
			local moter2 = gridToMoter[gridPosOff.X] and gridToMoter[gridPosOff.X][gridPosOff.Y]
			if moter2 and moter2 ~= moter1 and not moter2.linked then
				local m2GridSize = ((moter2.BR - moter2.TL) + Vector.One) * 4
				if motersLineUp(moter1, moter2) then
					local shiftX = moter1.TL.X - moter2.TL.X
					local shiftY = moter1.TL.Y - moter2.TL.Y
					if shiftX > 0 or shiftY > 0 then
						moter1.Shape = shiftMoterShape(moter1.Shape, math.max(shiftX * 4, 0), math.max(shiftY * 4, 0))
					end

					moter1.TL = Vector(math.min(moter1.TL.X, moter2.TL.X), math.min(moter1.TL.Y, moter2.TL.Y))
					moter1.BR = Vector(math.max(moter1.BR.X, moter2.BR.X), math.max(moter1.BR.Y, moter2.BR.Y))

					for x = moter2.TL.X, moter2.BR.X do
						for y = moter2.TL.Y, moter2.BR.Y do
							if gridToMoter[x] and gridToMoter[x][y] == moter2 then
								gridToMoter[x][y] = moter1
							end
						end
					end

					local moter2CombinationOrigin = (moter2.TL - moter1.TL) * 4
					for x, yValues in pairs(moter2.Shape) do
						for y, hasMoter in pairs(yValues) do
							if not moter1.Shape[x + moter2CombinationOrigin.X] then
								moter1.Shape[x + moter2CombinationOrigin.X] = {}
							end

							moter1.Shape[x + moter2CombinationOrigin.X][y + moter2CombinationOrigin.Y] = hasMoter
						end
					end

					moter1.iscombinationmoter = true
					moter2.linked = true
				end
			end
		end
	end

	for _, moter in ipairs(moterData) do
		if not moter.linked then
			if moter.iscombinationmoter then
				moter.Positions = {}
				local minX, minY, maxX, maxY
				for x, yValues in pairs(moter.Shape) do
					for y, hasMoter in pairs(yValues) do
						if hasMoter then
							moter.Positions[#moter.Positions + 1] = Vector(x, y)
							minX, minY, maxX, maxY = adjustMinMaxXY(x, y, minX, minY, maxX, maxY)
						end
					end
				end

				moter.MinX, moter.MinY, moter.MaxX, moter.MaxY = minX, minY, maxX, maxY

				local tlIndex = StageAPI.VectorToGrid(moter.TL.X, moter.TL.Y)
				local brIndex = StageAPI.VectorToGrid(moter.BR.X, moter.BR.Y)
				local tl = room:GetGridPosition(tlIndex)
				local br = room:GetGridPosition(brIndex)
				moter.Entity.Position = Vector(mod:Lerp(tl.X, br.X, 0.5), br.Y)
			end

			initMoterData(moter.Entity:GetData(), moter.Shape, moter.Positions, moter.MinX, moter.MinY, moter.MaxX, moter.MaxY)
		else
			moter.Entity:Remove()
		end
	end
end

function mod:customMoterAI(npc)
	local data = npc:GetData()
	local rand = npc:GetDropRNG()
	local sprite = npc:GetSprite()
	local room = game:GetRoom()

	if not data.init and room:GetFrameCount() <= 1 then
		tryMoterStitching()
	end

	if not data.init then
		local subtype = npc.SubType
		local makeLegal
		if subtype == 0 then -- like half of these are illegal moters but w/e it's a joke enemy
			subtype = rand:RandomInt(65535) + 1
			makeLegal = true
		end

		local moter, moterPositions, minX, minY, maxX, maxY = readMoterFromSubtype(subtype)

		if makeLegal then
			local randMoterPos = moterPositions[rand:RandomInt(#moterPositions) + 1]
			moter, moterPositions, minX, minY, maxX, maxY = findMoterFromPosInMoter(rand, moter, randMoterPos)
		end

		if minX then
			initMoterData(data, moter, moterPositions, minX, minY, maxX, maxY)
		else
			npc:Kill()
		end
	end

	if npc:IsDead() and not mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE) then
		local deathSplat = Isaac.Spawn(1000, 2, 2, npc.Position, Vector.Zero, npc)
		local spawnMoters = {}
		while #data.moterPositions > 0 do
			local maxMoters = #data.moterPositions - 1
			local newMoterSize = rand:RandomInt(maxMoters) + 1
			local randMoterPos = data.moterPositions[rand:RandomInt(#data.moterPositions) + 1]
			local newMoter, newMoterPositions, minX, minY, maxX, maxY = findMoterFromPosInMoter(rand, data.moter, randMoterPos, newMoterSize, data.moterPositions)
			spawnMoters[#spawnMoters + 1] = {newMoter, newMoterPositions, minX, minY, maxX, maxY}
		end

		local baseDir = RandomVector()
		local anglePer = 360 / #spawnMoters
		for i, newMoter in ipairs(spawnMoters) do
			local dir = baseDir:Rotated(anglePer * (i - 1))
			spawnCustomMoterWithShape(npc.Position + dir * 5, dir * 5, npc, newMoter[1], newMoter[2], newMoter[3], newMoter[4], newMoter[5], newMoter[6])
		end
	end
end

--[[
function mod:customMoterAI(npc)
	local data = npc:GetData()
	local rand = npc:GetDropRNG()
	local sprite = npc:GetSprite()

	if not data.init then
		local row1 = npc.SubType%16
		local row2 = math.floor((npc.SubType%256)/16)
		local row3 = math.floor((npc.SubType%4096)/256)
		local row4 = math.floor(npc.SubType/4096)
		local bin1 = mod:moterSubTypeThing(row1)
		local bin2 = mod:moterSubTypeThing(row2)
		local bin3 = mod:moterSubTypeThing(row3)
		local bin4 = mod:moterSubTypeThing(row4)
		local binary = bin1 .. bin2 .. bin3 .. bin4
		local _,flies = string.gsub(binary, "1", " ")
		data.flyCount = flies
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		sprite:ReplaceSpritesheet(0, "gfx/enemies/moters/" .. row1 .. "." .. row2 .. "." .. row3 .. "." .. row4 .. ".png")
		sprite:LoadGraphics()
		if not data.deathSpawned then
			Isaac.Spawn(1000, 15, 0, npc.Position, Vector.Zero, npc)
			local pos = npc.Position
			npc.Velocity = Vector.Zero
			for i=0,20 do
				mod.scheduleForUpdate(function()
					npc.Position = pos
					npc.Velocity = Vector.Zero
				end, i)
			end
		end
		data.init = true
	end

	if npc:IsDead() and not mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE) then
		--[[local deathSplat = Isaac.Spawn(1000, 2, 0, npc.Position, Vector.Zero, npc):ToEffect() --Gotta love how these just don't go away no matter what you do
		deathSplat.DepthOffset = 10
		deathSplat:GetData().goAway = true
		deathSplat:Update()]] --[[
		local i = data.flyCount
		while i > 0 do
			local flyNum = rand:RandomInt(i)+1
			local fly = nil
			if flyNum ~= data.flyCount then
				local flyTable = mod.customMoterResults[flyNum]
				local subTable = flyTable[rand:RandomInt(#flyTable)+1]
				local realSub = subTable[1]+(subTable[2]*16)+(subTable[3]*256)+(subTable[4]*4096)
				local dir = RandomVector()
				if flyNum == 2 then
					if rand:RandomInt(2) == 0 then
						fly = Isaac.Spawn(80, 0, 0, npc.Position+dir*5, dir*6, npc)
					else
						fly = Isaac.Spawn(18, 114, realSub, npc.Position+dir*5, dir*6, npc)
					end
				elseif flyNum == 1 then
					fly = Isaac.Spawn(18, 0, 0, npc.Position+dir*5, dir*6, npc)
				else
					fly = Isaac.Spawn(18, 114, realSub, npc.Position+dir*5, dir*6, npc)
				end
				fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				fly:GetData().deathSpawned = true
				fly:Update()
				i = i-flyNum
			end
		end
	end
end

mod.customMoterResults = {
	[1] = {
		{0, 0, 0, 0},
	},
	[2] = {
		{1, 1, 0, 0},
	},
	[3] = {
		{1, 1, 1, 0},
		{7, 0, 0, 0},
		{1, 3, 0, 0},
	},
	[4] = {
		{1, 1, 1, 1},
		{15, 0, 0, 0},
		{3, 3, 0, 0},
	},
	[5] = {
		{1, 3, 1, 1},
	},
	[6] = {
		{4, 4, 4, 7},
		{7, 7, 0, 0},
	},
	[7] = {
		{2, 7, 7, 0},
	},
	[8] = {
		{3, 3, 3, 3},
		{15, 15, 0, 0},
	},
	[9] = {
		{7, 7, 7, 0},
	},
	[10] = {
		{9, 15, 9, 9},
		{2, 7, 7, 7},
	},
	[11] = {
		{15, 9, 15, 8},
	},
	[12] = {
		{15, 9, 9, 15},
		{7, 7, 7, 7},
		{15, 15, 15, 0},
	},
	[13] = {
		{15, 15, 8, 15},
	},
	[14] = {
		{9, 15, 15, 15},
	},
	[15] = {
		{15, 11, 15, 15},
	},
}

function mod:moterSubTypeThing(num)
	local bin = ""
	while num ~= 0 do
		if num%2 == 0 then
			bin = "0" .. bin
		else
			bin = "1" .. bin
		end
		num = math.floor(num/2)
	end
	while string.len(bin) < 4 do
		bin = "0" .. bin
	end
	return bin
end
]]

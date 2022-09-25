local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
	Isaac.Spawn(5, 40, BombSubType.BOMB_GIGA, player.Position + Vector(0, 5), player.Velocity, player)
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingKingClubs, flags, 30)
end, Card.KING_OF_CLUBS)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
	--Blow up
	mod:removeAllHearts(player)
	mod:explodePlayer(player)
	local bomb = Isaac.Spawn(4, 17, BombSubType.BOMB_GIGA, player.Position, nilvector, player):ToBomb()
	bomb:SetExplosionCountdown(0)
	bomb:Update()
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingKingClubsReverse, flags, 30)
end, Card.REVERSE_KING_OF_CLUBS)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
	for _, entity in ipairs(Isaac.GetRoomEntities()) do
		if entity:IsEnemy() then
			entity:AddMidasFreeze(EntityRef(npc), 240)
		end
	end

    local room = game:GetRoom()

	game:ShakeScreen(20)
	sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY ,1.5,0,false,1)
	--Isaac.Spawn(5, 10, 7, npc.Position, RandomVector()*1, npc)
	local flash = Isaac.Spawn(1000, 7004, 0, room:GetCenterPos(), nilvector, npc):ToEffect()
	flash.RenderZOffset = 1000000
	room:TurnGold()

	local newGrids = {}
	for i=0, room:GetGridSize() do
		local gridEntity = room:GetGridEntity(i)
		if gridEntity and gridEntity.Desc.Type == GridEntityType.GRID_ROCK then
			if #newGrids > 1 then
				table.insert(newGrids, math.floor(math.random(#newGrids + 1)), i)
			else
				table.insert(newGrids, i)
			end
		end
	end

	for i = 1, #newGrids do
		local gridEntity = room:GetGridEntity(newGrids[i])
		if i == 1 or (i / #newGrids) <= 0.25 then
			--[[gridEntity:SetType(GridEntityType.GRID_ROCK_GOLD)
			local gs = gridEntity:GetSprite()
			gs:SetFrame("foolsgold", math.random(3) - 1)
			gridEntity:Update()]]
			
			gridEntity:Destroy(true)
			local grid = Isaac.GridSpawn(GridEntityType.GRID_ROCK_GOLD, 0, gridEntity.Position, true)
		end
	end

	--[[for i=0, room:GetGridSize() do
		local gridEntity = room:GetGridEntity(i)
		if gridEntity and gridEntity.Desc.Type == GridEntityType.GRID_ROCK then
			gridRock = gridEntity:ToRock()
			gridRock:SetBigRockFrame(1)
			gridRock:UpdateAnimFrame()
		end
	end]]
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingKingDiamonds, flags, 50)
end, Card.KING_OF_DIAMONDS)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
	local successGround
	local successInv
	for _, pickup in ipairs(Isaac.FindByType(5, 350, -1, false, false)) do
		pickup = pickup:ToPickup()
		if pickup.SubType < 32768 then
			successGround = true
			pickup:Morph(5, 350, pickup.SubType + 32768, false)
			mod.scheduleForUpdate(function()
				if pickup then
					for i = 30, 360, 30 do
						local vec = Vector(0,3):Rotated(i)
						local sparkle = Isaac.Spawn(1000, 1727, 0, pickup.Position + vec:Resized(20), vec, nil):ToEffect()
						sparkle.SpriteOffset = Vector(0,-27)
						sparkle:Update()
					end
				end
			end, 8)
		end
	end

	local t0 = player:GetTrinket(0)
	local t1 = player:GetTrinket(1)


	if t0 > 0 then
		if t0 < 32768 then
			player:TryRemoveTrinket(t0)
			player:AddTrinket(t0 + 32768)
			successInv = true
		end
	end
	if t1 > 0 then
		if t1 < 32768 then
			player:TryRemoveTrinket(t1)
			player:AddTrinket(t1 + 32768)
			successInv = true
		end
	end
	if successGround then
		mod.scheduleForUpdate(function()
			sfx:Play(SoundEffect.SOUND_GOLDENBOMB, 1, 10, false, 1.5)
		end, 8)
	elseif successInv then
		sfx:Play(SoundEffect.SOUND_GOLDENBOMB, 1, 10, false, 1.5)
	end
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingKingPentacles, flags, 50)
end, Card.KING_OF_PENTACLES)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
	local successGround
	local successInv
	for _, pickup in ipairs(Isaac.FindByType(5, 70, -1, false, false)) do
		pickup = pickup:ToPickup()
		if pickup.SubType < 2049 then
			successGround = true
			pickup:Morph(5, 70, pickup.SubType + 2048, false)
			mod.scheduleForUpdate(function()
				if pickup then
					for i = 30, 360, 30 do
						local vec = Vector(0,3):Rotated(i)
						local sparkle = Isaac.Spawn(1000, 1727, 0, pickup.Position + vec:Resized(20), vec, nil):ToEffect()
						sparkle.SpriteOffset = Vector(0,-27)
						sparkle:Update()
					end
				end
			end, 8)
		end
	end

	local t0 = player:GetPill(0)
	local t1 = player:GetPill(1)


	if t0 > 0 then
		if t0 < 2049 then
			player:SetPill(0, t0 + 2048)
			successInv = true
		end
	end
	if t1 > 0 then
		if t1 < 2049 then
			player:SetPill(1, t1 + 2048)
			successInv = true
		end
	end
	if successGround then
		mod.scheduleForUpdate(function()
			sfx:Play(mod.Sounds.HorseGoWhee, 1, 10, false, 1)
		end, 8)
	elseif successInv then
		sfx:Play(mod.Sounds.HorseGoWhee, 1, 10, false, 1)
	end
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingKingCups, flags, 50)
end, Card.KING_OF_CUPS)
local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.SkippableEffects = {
	[1] = true,
	[6] = true,
	[9] = true,
	[22] = true,
	[23] = true,
	[24] = true,
	[25] = true,
	[26] = true,
	[94] = true,
	[96] = true,
	[101] = true,
	[110] = true,
	[150] = true,
	[155] = true,
	[157] = true,
	[160] = true,
	[162] = true,
	[164] = true,
	[165] = true,
	[168] = true,
	[169] = true,
	[171] = true,
	[172] = true,
	[175] = true,
	[182] = true,
	[183] = true,
	[187] = true,
	[1013] = true,
	[1014] = true,
	[1015] = true,
	[1016] = true,
	[1017] = true,
	[1018] = true,
	[1019] = true,
	[1024] = true,
	[1034] = true,
	[1035] = true,

}
mod.skipGridBlaclist = {
	[GridEntityType.GRID_WALL] = true,
	[GridEntityType.GRID_DOOR] = true,
	[GridEntityType.GRID_TRAPDOOR] = true,
	[GridEntityType.GRID_STAIRS] = true,
	[GridEntityType.GRID_GRAVITY] = true,

}

mod.overrideFinalBosses = {
	--[6] = true	--Mom, allowed cos it's funny you get no polaroid/negative
	[8]	= true,		--Mom's Heart
	[24] = true,	--Satan
	[25] = true,	--It Lives
	[39] = true,	--Isaac
	[40] = true,	--???
	[54] = true,	--Lamb
	[55] = true,	--Mega Satan
	[62] = true,	--Ultra Greed
	[63] = true,	--Hush
	[70] = true,	--Delirium
	[88] = true,	--Mother
	--[89] = true,	--Mausoleum Mom, allowed too
	[90] = true,	--Mausoleum Heart
}

mod.skipBossMargins = {
	--84								--Satan, handle this differently in the code
	["102 | 0"] = {0.75, 0.5},			--Isaac
	["102 | 1"] = {2/3, 0.5},			--???
	["102 | 2"] = {0},					--Hush (Blue Bab)
	
	["273 | 0"] = {0.5},				--Lamb

	["274 | 0"] = {0.75, 0.5, 0.25, 0},	--Mega Satan

	["407 | 0"] = {0.8, 0.6, 0.4, 0.2},	--Hush

	["912 | 0"] = {0.5},				--Mother

	["950 | 1"] = {0},					--Dogma (TV)
	["950 | 2"] = {0},					--Dogma (Angel)

	["951 | 0"] = {0.666, 0.333},		--Beast
		--0.333 DOESN'T work on famine
	["951 | 10"] = {0.33, 0},			--Ultra Famine
	["951 | 20"] = {0.4, 0},			--Ultra Pestilence
	["951 | 30"] = {0.5, 0},			--Ultra War
	["951 | 40"] = {0},					--Ultra Death (lol)
}

local unwipeableItems = {
	[CollectibleType.COLLECTIBLE_DADS_NOTE] = true,
	[CollectibleType.COLLECTIBLE_KNIFE_PIECE_2] = true,
	[FiendFolio.ITEM.COLLECTIBLE.RAT_POISON] = true,
}

function mod:skipCardRoom(ignoreEffects)
	local room = game:GetRoom()
	local roomtype = room:GetType()
	local removegrids
	local overrideLogic
	
	local level = game:GetLevel()
	local roomDesc = level:GetCurrentRoomDesc()
	local roomsub = roomDesc.Data.Subtype
	--print(level:GetStage(),roomsub)

	local isHush = level:GetStage() == LevelStage.STAGE4_3 and room:GetType() == RoomType.ROOM_BOSS and roomsub == 63
	local isMother = level:GetStage() == LevelStage.STAGE4_2 and room:GetType() == RoomType.ROOM_BOSS and roomsub == 88
	local isDelirium = level:GetStage() == LevelStage.STAGE7 and room:GetType() == RoomType.ROOM_BOSS and roomsub == 70
	local isHome = level:GetStage() == LevelStage.STAGE8
	local isDadNote = level:GetStage() == LevelStage.STAGE3_2 and roomsub == 89 and game:GetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH_INIT)
	local isMegaSatan = room:GetType() == RoomType.ROOM_BOSS and roomsub == 55
	--Doesn't count for hush boss room????
	if room:IsCurrentRoomLastBoss() or isHush or isMother or isDelirium or isHome or isDadNote or isMegaSatan then
		if mod.overrideFinalBosses[roomsub] or isHome or isDadNote then
			overrideLogic = true
		end
	end

	if overrideLogic then
		for _,entity in ipairs(Isaac.GetRoomEntities()) do
			if mod.skipBossMargins[entity.Type .. " | " .. entity.Variant] then
				for i = 1, #mod.skipBossMargins[entity.Type .. " | " .. entity.Variant] do
					if entity.HitPoints > entity.MaxHitPoints * mod.skipBossMargins[entity.Type .. " | " .. entity.Variant][i] then
						local subtractAmount = entity.HitPoints - (entity.MaxHitPoints * mod.skipBossMargins[entity.Type .. " | " .. entity.Variant][i]) + 1
						entity:TakeDamage(subtractAmount, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(Isaac.GetPlayer(0)), 0)
						--Ultra famine/war act kinda funky
						if entity.Type == 951 and (entity.Variant == 10 or entity.Variant == 30) then
							for j = 1, 20 do
								mod.scheduleForUpdate(function()
									if entity:Exists() then
										entity:TakeDamage(1, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(Isaac.GetPlayer(0)), 0)
									end
								end, j)
							end
						end
						break
					end
				end
			elseif isMegaSatan and entity.Type >= 10 and entity.Type ~= 274 and entity.Type ~= 275 then
				entity:Remove()
			elseif mod.IsDeliriumRoom and (entity:IsEnemy() or entity:IsBoss()) then
				--entity:TakeDamage(entity.HitPoints, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(Isaac.GetPlayer(0)), 0)
				entity:Kill()
			elseif entity.Type == 84 and entity.Variant == 0 then
				--Satan Stuff
				if entity:GetSprite():IsPlaying("SmallIdle") then

				else
					entity.HitPoints = 0
					entity:TakeDamage(1, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(Isaac.GetPlayer(0)), 0)
				end
			elseif entity.Type == 81 then
				entity:Remove()
			elseif entity.Type ~= 950 and entity	.Type ~= 960 then
				if (not entity:IsBoss()) and (entity:IsEnemy() or (entity.Type == 4 and entity.SpawnerEntity.Type ~= 1) or (entity.Type >= 6 and entity.Type <= 7) or (entity.Type == 1000 and mod.SkippableEffects[entity.Variant])) then
					entity:Remove()
				end
			end
		end
		if mod.IsDeliriumRoom then
			game:GetHUD():ShowFortuneText("You can have", "this one!")
		end
	else
		mod.SkipCardUsed = true
		removegrids = true
		for _, ent in ipairs(Isaac.GetRoomEntities()) do
			if (ent.Type >= 4 and ent.Type <= 7) or (ent.Type >= 9 and ent.Type < 1000) or (ent.Type == 1000 and mod.SkippableEffects[ent.Variant]) then
				if not (ent.Type == 5 and ent.Variant == 100 and unwipeableItems[ent.SubType]) then
					if roomtype == RoomType.ROOM_CHALLENGE or roomtype == RoomType.ROOM_BOSSRUSH then
						if (ent.Type ~= 5 and ent.Type ~= 4 ) or (ent.Type == 4 and ent.SpawnerEntity.Type ~= 1) then
							ent:Remove()
						end
					elseif ent.Type ~=4 or (ent.Type == 4 and ((not ent.SpawnerEntity) or (ent.SpawnerEntity and ent.SpawnerEntity.Type ~= 1))) then
						ent:Remove()
					end
				end
			end
		end
	end
	--Rock Removal
	if (roomtype == RoomType.ROOM_CHALLENGE or roomtype == RoomType.ROOM_BOSSRUSH) then
		removegrids = false
		mod.SkipCardUsed = false
	end
	if removegrids then
		local newGrids = {}
		for i=0, room:GetGridSize() do
			local gridEntity = room:GetGridEntity(i)
			if gridEntity then
				local gridpos = room:GetGridPosition(i)
				local desc = gridEntity.Desc.Type
				if not mod.skipGridBlaclist[desc] then
					if desc == GridEntityType.GRID_ROCK_ALT2 then
						--spawn fool
					end
					room:RemoveGridEntity(i, 0, false)
					table.insert(newGrids, i)
				end
			end
		end
		for i = 1, #newGrids do
			for k = 1, 3 do
				mod.scheduleForUpdate(function()
                    local room = game:GetRoom()
					room:SpawnGridEntity(newGrids[i], GridEntityType.GRID_DECORATION, 0, 0, 0)
				end, k)
			end
		end
		if StageAPI then
			for _, customGrid in ipairs(StageAPI.GetCustomGrids()) do
				customGrid:Remove(false)
			end
		end
	end
	--Cool smoke :)
	if not ignoreEffects then
		for i = 1, 100 do
			local vecX = math.random(50,100)
			if math.random(2) == 1 then
				vecX = vecX * -1
			end

			local side = -400 + math.random(room:GetGridWidth()*40 + 650)

			local eff = Isaac.Spawn(1000, 138, 961, Vector(side, 30 + math.random(room:GetGridHeight() * 40 + 120)), Vector(vecX, 0), nil):ToEffect()
			eff:GetData().opacity = 0.5 + math.random()/2
			eff:GetSprite():Stop()
			eff:GetSprite():SetFrame(math.random(4)-1)
			eff.Timeout = 50
			eff:Update()
		end
		sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 1, 0, false, 0.5)
	end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player)
	mod:skipCardRoom()
end, Card.SKIP_CARD)
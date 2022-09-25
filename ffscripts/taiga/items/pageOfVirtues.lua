-- Page of Virtues --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:rollPageOfVitruesEffect()
	local rand = math.random()
	if rand < 0.05 then
		return mod.PageOfVirtuesWisps["Rare"][math.random(#(mod.PageOfVirtuesWisps["Rare"]))]
	elseif rand < 0.50 then
		return mod.PageOfVirtuesWisps["Uncommon"][math.random(#(mod.PageOfVirtuesWisps["Uncommon"]))]
	elseif rand < 0.83 then
		return mod.PageOfVirtuesWisps["Common"][math.random(#(mod.PageOfVirtuesWisps["Common"]))]
	else
		return CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES
	end
end

function mod:spawnPageOfVirtuesWisp(player, data, basedata)
	data.PageOfVirtuesId = mod:rollPageOfVitruesEffect()
	
	local wisp = player:AddWisp(data.PageOfVirtuesId, player.Position, true)
	if wisp then
		wisp:GetData().PageOfVirtuesWisp = true
		basedata.PageOfVirtuesIsSet = true
		sfx:Play(SoundEffect.SOUND_CANDLE_LIGHT, 1, 0, false, 1)
	end
end

function mod:setWispAsPageOfVirtuesWisp(player, data, basedata)
	if data.PageOfVirtuesId ~= nil then
		local wisps = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, data.PageOfVirtuesId)
		for _, wisp in ipairs(wisps) do
			local wisp = wisp:ToFamiliar()
			if wisp.Player and wisp.Player.Index == player.Index and wisp.Player.InitSeed == player.InitSeed then
				wisp:GetData().PageOfVirtuesWisp = true
				basedata.PageOfVirtuesIsSet = true
				return
			end
		end
	end
	mod:spawnPageOfVirtuesWisp(player, data, basedata)
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.PAGE_OF_VIRTUES) then
		local basedata = player:GetData()
		local data = basedata.ffsavedata or basedata
		
		if basedata.PageOfVirtuesTilNextSpawn ~= nil and basedata.PageOfVirtuesTilNextSpawn > 0 then
			basedata.PageOfVirtuesTilNextSpawn = basedata.PageOfVirtuesTilNextSpawn - 1
		elseif not data.PageOfVirtuesId then
			mod:spawnPageOfVirtuesWisp(player, data, basedata)
		elseif not basedata.PageOfVirtuesIsSet then
			mod:setWispAsPageOfVirtuesWisp(player, data, basedata)
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, e)
	if e.Variant == FamiliarVariant.WISP then
		local wisp = e:ToFamiliar()
		local wispdata = e:GetData()
		
		if wispdata.PageOfVirtuesWisp and wisp.Player then
			local player = wisp.Player
			local basedata = player:GetData()
			local data = basedata.ffsavedata or basedata
			
			data.PageOfVirtuesId = nil
			basedata.PageOfVirtuesIsSet = nil
			basedata.PageOfVirtuesTilNextSpawn = 29
		end
	end
end, EntityType.ENTITY_FAMILIAR)

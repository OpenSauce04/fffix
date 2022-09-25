local mod = FiendFolio
local sfx = SFXManager()

mod.autopsyKitDrops = {--Half, Full, Leftover is bone
	[1] = {60, 95},
	[2] = {0, 75},
	[3] = {0, 0},
	[4] = {0, 90},
	[5] = {0, 0},
	[6] = {40, 80},
	[7] = {0, 0},
	[100] = {50, 85}
}

function mod:autopsyKitDeath(npc)
	local extraValue = mod.getTrinketMultiplierAcrossAllPlayers(FiendFolio.ITEM.TRINKET.AUTOPSY_KIT)
	if extraValue > 0 then
		local bloodExplode = false
		local rand = npc:GetDropRNG()
		for _,coin in ipairs(Isaac.FindByType(5, 20, -1, false, false)) do
			if coin.FrameCount < 1 and coin.Position:Distance(npc.Position) < 20 then
				if bloodExplode == false then
					Isaac.Spawn(1000, 2, 160, npc.Position, Vector.Zero, npc)
					Isaac.Spawn(1000, 7, 160, npc.Position, Vector.Zero, npc)
					sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.6, 0, false, math.random(80,120)/100)
					bloodExplode = true
				end
				coin = coin:ToPickup()
				local rolls = mod.autopsyKitDrops[coin.SubType]
				if rolls ~= nil then
					local roll = rand:RandomInt(100)+15*(extraValue-1)
					if roll < rolls[1] then
						coin:Morph(5, 10, 2, true)
					elseif roll < rolls[2] then
						coin:Morph(5, 10, 1, true)
					else
						coin:Morph(5, 10, 11, true)
					end
				else
					rolls = mod.autopsyKitDrops[100]
					local roll = rand:RandomInt(100)+15*(extraValue-1)
					if roll < rolls[1] then
						coin:Morph(5, 10, 2, true)
					elseif roll < rolls[2] then
						coin:Morph(5, 10, 1, true)
					else
						coin:Morph(5, 10, 11, true)
					end
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, mod.autopsyKitDeath, 17)
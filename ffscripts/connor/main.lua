local mod = FiendFolio
local game = Game()

FiendFolio.LoadScripts({
	-- Items
	"ffscripts.connor.items.brown_horn",
	"ffscripts.connor.items.nyx",
	-- Cards Etc
	"ffscripts.connor.cards.discs",
	"ffscripts.connor.cards.blank_letter_tile",
	-- Misc
	"ffscripts.connor.ff_character_pause_screen_marks",
})

-- General callbacks

function mod:connorPostRender()
	mod:discPostRender()
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.connorPostRender)

function mod:connorNewRoom()
	mod:spindleNewRoom()
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.connorNewRoom)

function mod:connorNewFloor()
	mod:resetBlankLetterTileData()
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.connorNewFloor)

-- Player callbacks

function mod:connorPlayerUpdate(player)
	mod:nyxKeepGemsStuck()
	mod:blankLetterTileUpdate(player)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.connorPlayerUpdate)

function mod:connorPEffectUpdate(player)
	mod:nyxPlayerUpdate(player)
	mod:discPlayerUpdate(player)
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.connorPEffectUpdate)

function mod:connorPlayerRender(player)
	mod:blankLetterTileRender(player)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, mod.connorPlayerRender)

-- Generic entity callbacks

function mod:connorPostEntityDeath(entity)
	mod:brownHornEntityDeath(entity)
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mod.connorPostEntityDeath)

function mod:connorPostEntityRemove(entity)
	mod:brownHornEntityRemove(entity)
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, mod.connorPostEntityRemove)

function mod:connorTakeDamage(entity, damage, damageFlags, damageSourceRef, damageCountdown)
	local functions = {
		mod.brownHornDamage,
		mod.nyxDamage,
		mod.discItemWispDamage,
	}
	for _, func in pairs(functions) do
		if func(_, entity, damage, damageFlags, damageSourceRef, damageCountdown) == false then
			return false
		end
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.connorTakeDamage)

-- Misc entity callbacks

function mod:connorEnemyUpdate(entity)
	mod:brownHornEntityUpdate(entity)
	mod:nyxEnemyUpdate(entity)
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.connorEnemyUpdate)

function mod:connorFamiliarUpdate(entity)
	mod:brownHornEntityUpdate(entity)
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.connorFamiliarUpdate)

function mod.connorSlotUpdate(slot)
	mod:brownHornEntityUpdate(slot)
end
mod.onEntityTick(EntityType.ENTITY_SLOT, mod.connorSlotUpdate)

function mod:connorLaserUpdate(laser)
	mod:nyxChainLightningUpdate(laser)
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, mod.connorLaserUpdate)

function mod:connorPostTearInit(tear)
	mod:discItemWispTears(tear)
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, mod.connorPostTearInit)

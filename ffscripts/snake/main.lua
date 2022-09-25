FiendFolio.LoadScripts({
    "ffscripts.snake.enemies.wombpillar",
    "ffscripts.snake.enemies.watcher",
	"ffscripts.snake.enemies.mistmonger",
	"ffscripts.snake.enemies.cordend",
	"ffscripts.snake.enemies.guflush",
	"ffscripts.snake.enemies.rancor",
	"ffscripts.snake.enemies.cancerboy",
	"ffscripts.snake.enemies.eyeofshaggoth",
})

local mod = FiendFolio

mod.SnakeFunctions = {
	[mod.FF.WombPillar.Var] = {
		Update = mod.WombPillarUpdate,
		Hurt = mod.WombPillarHurt,
	},
	[mod.FF.Watcher.Var] = {
		Update = mod.WatcherUpdate,
	},
	[mod.FF.WatcherEye.Var] = {
		Update = mod.WatcherEyeUpdate,
	},
	[mod.FF.Mistmonger.Var] = {
		Update = mod.MistmongerUpdate,
	},
	[mod.FF.Cordend.Var] = {
		Update = mod.CordendUpdate,
		Hurt = mod.CordendHurt,
	},
	[mod.FF.Guflush.Var] = {
		Update = mod.GuflushUpdate,
		Hurt = mod.GuflushHurt,
	},
	[mod.FF.Rancor.Var] = {
		Update = mod.RancorUpdate,
		Hurt = mod.RancorHurt,
	},
	[mod.FF.CancerBoy.Var] = {
		Update = mod.CancerBoyUpdate,
		Death = mod.CancerBoyDeath,
	},
	[mod.FF.EyeOfShaggoth.Var] = {
		Update = mod.EyeOfShaggothUpdate,
		Hurt = mod.EyeOfShaggothHurt,
		Remove = mod.EyeOfShaggothRemove,
		Render = mod.EyeOfShaggothRender,
	},
}

function mod:SnakeEnemyUpdate(npc)
	local variant = npc.Variant
	local subtype = npc.SubType
	
	if mod.SnakeFunctions[variant] and mod.SnakeFunctions[variant].Update then
		mod.SnakeFunctions[variant].Update(_, npc, subtype, variant)
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.SnakeEnemyUpdate, mod.FFID.Snake)

function mod:SnakeEnemyRender(npc)
	local variant = npc.Variant
	
	if mod.SnakeFunctions[variant] and mod.SnakeFunctions[variant].Render then
		mod.SnakeFunctions[variant].Render(_, npc)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, mod.SnakeEnemyRender, mod.FFID.Snake)

function mod:SnakeEnemyHurt(npc, damage, flag, source, countdown)
	local variant = npc.Variant
	
	if mod.SnakeFunctions[variant] and mod.SnakeFunctions[variant].Hurt then
		return mod.SnakeFunctions[variant].Hurt(_, npc, damage, flag, source, countdown)
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.SnakeEnemyHurt, mod.FFID.Snake)

function mod:SnakeEnemyDeath(npc)
	local variant = npc.Variant
	
	if mod.SnakeFunctions[variant] and mod.SnakeFunctions[variant].Death then
		mod.SnakeFunctions[variant].Death(_, npc, variant)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.SnakeEnemyDeath, mod.FFID.Snake)

function mod:SnakeEnemyRemove(npc)
	local variant = npc.Variant
	
	if mod.SnakeFunctions[variant] and mod.SnakeFunctions[variant].Remove then
		mod.SnakeFunctions[variant].Remove(_, npc)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, mod.SnakeEnemyRemove, mod.FFID.Snake)

FiendFolio.LoadScripts({
	-- Enemies
    "ffscripts.taiga.enemies.onlooker",
    "ffscripts.taiga.enemies.punted",
    "ffscripts.taiga.enemies.cuffs",
    "ffscripts.taiga.enemies.empath",
    "ffscripts.taiga.enemies.psychoAndManicFlies",
    "ffscripts.taiga.enemies.warble",
    "ffscripts.taiga.enemies.sensoryGrimace",
    "ffscripts.taiga.enemies.riftwalker",
	"ffscripts.taiga.enemies.fishfreak",
	"ffscripts.taiga.enemies.kingAndPawn",
	"ffscripts.taiga.enemies.foetus",
	"ffscripts.taiga.enemies.anemone",
	"ffscripts.taiga.enemies.oralopede",
	"ffscripts.taiga.enemies.oralid",
	"ffscripts.taiga.enemies.thrall",
	
	-- Bosses
	"ffscripts.taiga.bosses.ghostbuster",
	
	-- Items
	"ffscripts.taiga.items.pinhead",
	"ffscripts.taiga.items.crucifix",
	"ffscripts.taiga.items.bedtimeStory",
	"ffscripts.taiga.items.prankCookie",
	"ffscripts.taiga.items.devilsHarvest",
	"ffscripts.taiga.items.rubberBullets",
	"ffscripts.taiga.items.theDeluxe",
	"ffscripts.taiga.items.lilMinx",
	"ffscripts.taiga.items.purplePutty",
	"ffscripts.taiga.items.fetalFiend",
	"ffscripts.taiga.items.fiendMix",
	"ffscripts.taiga.items.secretStash",
	"ffscripts.taiga.items.fiendHeart",
	"ffscripts.taiga.items.devilledEgg",
	"ffscripts.taiga.items.perfectlyGenericObject",
	"ffscripts.taiga.items.pageOfVirtues",
	"ffscripts.taiga.items.bridgeBombs",
	"ffscripts.taiga.items.lawnDarts",
	"ffscripts.taiga.items.toyPiano",
	"ffscripts.taiga.items.hypnoRing",
	"ffscripts.taiga.items.musca",
	"ffscripts.taiga.items.modelRocket",
	"ffscripts.taiga.items.siblingSyl",
	"ffscripts.taiga.items.wrongWarp",
	"ffscripts.taiga.items.dadsDip",
	"ffscripts.taiga.items.yickHeart",
	
	-- Grids
	"ffscripts.taiga.grids.dogDoo",
	
	-- Pickups
	"ffscripts.taiga.pickups.copperBombs",
})

local mod = FiendFolio
local nilvector = Vector.Zero

-- General (enemies)
function mod:update120(npc)
	local sprite = npc:GetSprite();
	local npcdata = npc:GetData();
	local var = npc.Variant

	if var == mod.FF.Onlooker.Var then
		mod:onlookerAI(npc, sprite, npcdata)
	elseif var == mod.FF.Punted.Var then
		mod:puntedAI(npc, sprite, npcdata)
	elseif var == mod.FF.Cuffs.Var then
		mod:cuffsAI(npc, sprite, npcdata)
	elseif var == mod.FF.Empath.Var then
		mod:empathAI(npc, sprite, npcdata)
	elseif var == mod.FF.ManicFly.Var then
		mod:manicFlyAI(npc, sprite, npcdata)
	elseif var == mod.FF.Warble.Var then
		mod:warbleAI(npc, sprite, npcdata)
	elseif var == mod.FF.RiftWalker.Var then
		mod:riftWalkerAI(npc, sprite, npcdata)
	elseif var == mod.FF.Fishfreak.Var then
		mod:fishfreakAI(npc, sprite, npcdata)
	elseif var == mod.FF.King.Var then
		mod:kingAI(npc, sprite, npcdata)
	elseif var == mod.FF.Pawn.Var then
		mod:pawnAI(npc, sprite, npcdata)
	elseif var == mod.FF.Foetus.Var then
		mod:foetusAI(npc, sprite, npcdata)
	elseif var == mod.FF.Anemone.Var then
		mod:anemoneAI(npc, sprite, npcdata)
	elseif var == mod.FF.Oralopede.Var then
		mod:oralopedeAI(npc, sprite, npcdata)
	elseif var == mod.FF.Oralid.Var then
		mod:oralidAI(npc, sprite, npcdata)
	elseif var == mod.FF.Thrall.Var then
		mod:thrallAI(npc, sprite, npcdata)
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.update120, mod.FFID.Taiga)

function mod:render120(npc, offset)
	local sprite = npc:GetSprite();
	local npcdata = npc:GetData();
	local var = npc.Variant

	if var == mod.FF.RiftWalker.Var then
		mod:riftWalkerRender(npc, sprite, npcdata, offset)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, mod.render120, mod.FFID.Taiga)

function mod:takeDmg120(entity, damage, flags, source, countdown)
	local var = entity.Variant
	
	if var == mod.FF.Onlooker.Var then
		return mod:onlookerTakeDmg(entity, damage, flags, source, countdown)
	elseif var == mod.FF.Punted.Var then
		return mod:puntedTakeDmg(entity, damage, flags, source, countdown)
	elseif var == mod.FF.Cuffs.Var then
		return mod:cuffsTakeDmg(entity, damage, flags, source, countdown)
	elseif var == mod.FF.Warble.Var then
		return mod:warbleTakeDmg(entity, damage, flags, source, countdown)
	elseif var == mod.FF.RiftWalker.Var then
		return mod:riftWalkerTakeDmg(entity, damage, flags, source, countdown)
	elseif var == mod.FF.Fishfreak.Var then
		return mod:fishfreakTakeDmg(entity, damage, flags, source, countdown)
	elseif var == mod.FF.Pawn.Var then
		return mod:pawnTakeDmg(entity, damage, flags, source, countdown)
	elseif var == mod.FF.Oralopede.Var then
		return mod:oralopedeTakeDmg(entity, damage, flags, source, countdown)
	elseif var == mod.FF.Oralid.Var then
		return mod:oralidTakeDmg(entity, damage, flags, source, countdown)
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.takeDmg120, mod.FFID.Taiga)

function mod:kill120(entity)
	local var = entity.Variant

	if var == mod.FF.Warble.Var then
		mod:warbleKill(entity)
	elseif var == mod.FF.Fishfreak.Var then
		mod:fishfreakKill(entity)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mod.kill120, mod.FFID.Taiga)

function mod:collide120(entity, collider, low)
	local var = entity.Variant

	if var == mod.FF.Punted.Var then
		return mod:puntedCollision(entity, collider, low)
	elseif var == mod.FF.Warble.Var then
		return mod:warbleCollision(entity, collider, low)
	elseif var == mod.FF.Pawn.Var then
		return mod:pawnCollision(entity, collider, low)
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, mod.collide120, mod.FFID.Taiga)

-- Misc. helper functions
function mod:swapMinecartContents(npc1, npc2, gridcoll1, gridcoll2)
	local minecart1 = nil
	local minecart2 = nil
	
	local minecarts = Isaac.FindByType(EntityType.ENTITY_MINECART)
	for _, minecart in ipairs(minecarts) do
		if minecart.Child == nil then
			--continue
		elseif minecart.Child.Index == npc1.Index and minecart.Child.InitSeed == npc1.InitSeed then
			minecart1 = minecart:ToNPC()
		elseif minecart.Child.Index == npc2.Index and minecart.Child.InitSeed == npc2.InitSeed then
			minecart2 = minecart:ToNPC()
		end
	end
	
	if minecart1 then 
		local replacement = Isaac.Spawn(minecart1.Type, 1, minecart1.SubType, minecart1.Position, minecart1.Velocity, nil):ToNPC()
		replacement.Child = npc2
		replacement:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		
		npc2.Position = minecart1.Position
		npc2.DepthOffset = 0.01
		npc2.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		
		replacement.I1 = minecart1.I1
		replacement.I2 = minecart1.I2
		replacement.V1 = minecart1.V1
		replacement.V2 = minecart1.V2
		replacement.State = minecart1.State
		replacement.StateFrame = minecart1.StateFrame
		
		npc2:GetData().FFManualMinecart = replacement
		replacement:GetData().FFIsManualMinecart = true
		
		local minecartSprite = minecart1:GetSprite()
		local replacementSprite = replacement:GetSprite()
		
		replacementSprite:Play(minecartSprite:GetAnimation(), true)
		replacementSprite:SetFrame(minecartSprite:GetFrame())
		
		replacementSprite.FlipX = minecartSprite.FlipX
		replacementSprite.FlipY = minecartSprite.FlipY
		replacementSprite.PlaybackSpeed = minecartSprite.PlaybackSpeed
		replacementSprite.Rotation = minecartSprite.Rotation
		replacementSprite.Scale = minecartSprite.Scale
		
		replacement:Update()
		
		minecart1.Child = nil
		minecart1:Remove()
	else
		npc2:GetData().FFManualMinecart = nil
		npc2.SpriteOffset = Vector(0,0)
		npc2.DepthOffset = 0
		npc2.GridCollisionClass = gridcoll2
	end
	
	if minecart2 then 
		local replacement = Isaac.Spawn(minecart2.Type, 1, minecart2.SubType, minecart2.Position, minecart2.Velocity, nil):ToNPC()
		replacement.Child = npc1
		replacement:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		
		npc1.Position = minecart2.Position
		npc1.DepthOffset = 0.01
		npc1.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		
		replacement.I1 = minecart2.I1
		replacement.I2 = minecart2.I2
		replacement.V1 = minecart2.V1
		replacement.V2 = minecart2.V2
		replacement.State = minecart2.State
		replacement.StateFrame = minecart2.StateFrame
		
		npc1:GetData().FFManualMinecart = replacement
		replacement:GetData().FFIsManualMinecart = true
		
		local minecartSprite = minecart2:GetSprite()
		local replacementSprite = replacement:GetSprite()
		
		replacementSprite:Play(minecartSprite:GetAnimation(), true)
		replacementSprite:SetFrame(minecartSprite:GetFrame())
		
		replacementSprite.FlipX = minecartSprite.FlipX
		replacementSprite.FlipY = minecartSprite.FlipY
		replacementSprite.PlaybackSpeed = minecartSprite.PlaybackSpeed
		replacementSprite.Rotation = minecartSprite.Rotation
		replacementSprite.Scale = minecartSprite.Scale
		
		replacement:Update()
		
		minecart2.Child = nil
		minecart2:Remove()
	else
		npc1:GetData().FFManualMinecart = nil
		npc1.SpriteOffset = Vector(0,0)
		npc1.DepthOffset = 0
		npc1.GridCollisionClass = gridcoll1
	end
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, minecart)
	if minecart:GetData().FFIsManualMinecart and minecart.Child then
		minecart.Child.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	end
end, EntityType.ENTITY_MINECART)

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, minecart, offset)
	if minecart:GetData().FFIsManualMinecart then
		minecart:GetData().LastRenderOffset = offset
		
		if minecart.Child then
			local minecartSprite = minecart:GetSprite()
			
			local y
			if minecartSprite:IsPlaying("Move1") or minecartSprite:IsFinished("Move1") then
				y = -5
			elseif  minecartSprite:IsPlaying("Move2") or minecartSprite:IsFinished("Move2") then
				y = -4
			elseif  minecartSprite:IsPlaying("Move3") or minecartSprite:IsFinished("Move3") then
				y = -3
			elseif  minecartSprite:IsPlaying("Move4") or minecartSprite:IsFinished("Move4") then
				y = -1
			elseif  minecartSprite:IsPlaying("Move5") or minecartSprite:IsFinished("Move5") then
				y = 1
			elseif  minecartSprite:IsPlaying("Move6") or minecartSprite:IsFinished("Move6") then
				y = -1
			elseif  minecartSprite:IsPlaying("Move7") or minecartSprite:IsFinished("Move7") then
				y = -3
			elseif  minecartSprite:IsPlaying("Move8") or minecartSprite:IsFinished("Move8") then
				y = -4
			else
				return
			end
			
			if minecartSprite:GetFrame() >= 3 then
				y = y + 1
			end
			
			minecart.Child.SpriteOffset = Vector(0, y)
		end
	end
end, EntityType.ENTITY_MINECART)

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, npc, offset)
	if npc:GetData().FFManualMinecart then
		local minecart = npc:GetData().FFManualMinecart
		
		local minecartSprite = minecart:GetSprite()
		minecartSprite:RenderLayer(1, Isaac.WorldToRenderPosition(minecart.Position + minecart.PositionOffset) + (minecart:GetData().LastRenderOffset or Vector(0,0)))
	end
end)
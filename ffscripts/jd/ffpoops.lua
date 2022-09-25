local mod = CustomPoopAPI
local game = Game()
local rng = RNG()

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
	local data = npc:GetData()
	if data.FFCursedPoop then
		if not data.PoopIsBroken then
			for i, entity in pairs(Isaac.FindInRadius(npc.Position, 70, EntityPartition.ENEMY)) do
				if entity:IsEnemy() and not entity:IsBoss() then
					entity:AddFear(EntityRef(npc), 2)
					if entity.Position:Distance(npc.Position) < 50 then
						entity.Target = npc
					else
						entity.Target = nil
					end
				end
			end
		end
		if not data.FFCursedPoopAura or not data.FFCursedPoopAura:Exists() and npc.PositionOffset:Length() < 10 and not data.PoopIsBroken then
			local halo = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALLOWED_GROUND, 0, npc.Position, Vector.Zero, npc):ToEffect()
			halo.Parent = npc
			halo:FollowParent(npc)
			halo.DepthOffset = 100
			halo.Color = Color(1, 0.2, 1, 1, 0, 0, 0)
			data.FFCursedPoopAura = halo
		end
		if npc.HitPoints == 1 and not data.PoopIsBroken and data.FFCursedPoopAura then
			data.FFCursedPoopAura:Remove()
		end
		data.PoopIsBroken = npc.HitPoints == 1
	end
	
	if data.FFShampoo then
		data.PoopIsBroken = npc.HitPoints == 1
		if not data.PoopIsBroken then
			if npc.PositionOffset:Length() > 1 and npc.Velocity:Length() > 1 then
				data.PoopVelocity = npc.Velocity
			elseif data.PoopVelocity then
				npc.Velocity = data.PoopVelocity + npc.Velocity
				if npc.FrameCount % 4 == 0 then
					local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, -1, npc.Position, Vector.Zero, npc)
					creep.Visible = false
					FiendFolio.scheduleForUpdate(function()
						creep.Visible = true
						creep.Position = npc.Position
					end, 2)
				end
				if npc:CollidesWithGrid() then
					npc.Velocity = npc.Velocity*-1.2
					data.PoopVelocity = nil
				end
			end
		end
	end
	
	if data.FFEvilPoop then
		if npc.PositionOffset:Length() == 0 and npc.Velocity:Length() < 1 then
			for i, entity in pairs(Isaac.FindInRadius(npc.Position, 80, EntityPartition.ENEMY)) do
				if entity.Type ~= EntityType.ENTITY_POOP and entity:IsEnemy() then
					if not data.PoopIsBroken then
						entity:GetData().EvilPoopDistance = entity.Position:Distance(npc.Position)
					elseif entity:GetData().EvilPoopDistance then
						entity:GetData().EvilPoopDistance = nil
					end
				end
			end
			if not data.FFEvilPoopAura or not data.FFEvilPoopAura:Exists() and not data.PoopIsBroken then
				local halo = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALO, 8, npc.Position, Vector.Zero, npc):ToEffect()
				halo.Parent = npc
				halo:FollowParent(npc)
				halo.DepthOffset = 100
				halo:GetSprite().PlaybackSpeed = 0
				halo.SpriteScale = halo.SpriteScale * 1.3
				local color = halo.Color
				halo:SetColor(Color(color.R,color.G,color.B,0,color.RO,color.GO,color.BO),4,1,true,false)
				data.FFEvilPoopAura = halo
			end
		end
		if npc.HitPoints == 1 and not data.PoopIsBroken and data.FFEvilPoopAura then
			data.FFEvilPoopAura:Remove()
		end
		data.PoopIsBroken = npc.HitPoints == 1
	end
end, EntityType.ENTITY_POOP)

mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, function(_, npc, collider)
	local data = npc:GetData()
	if data.FFShampoo and not data.PoopIsBroken then
		if data.PoopVelocity then
			if collider:IsEnemy() and collider.Type ~= EntityType.ENTITY_POOP then
				collider:TakeDamage(15, 0, EntityRef(npc), 5)
				npc:Kill()
			end
		end
		if collider:ToPlayer() then
			local player = collider:ToPlayer()
			player:TryHoldEntity(npc)
			data.PoopVelocity = nil
		end
	end
end, EntityType.ENTITY_POOP)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, damage, flags, source, countdown)
	if not (flags & DamageFlag.DAMAGE_CLONES > 0) and entity:GetData().EvilPoopDistance and entity:GetData().EvilPoopDistance < 78 then
		entity:TakeDamage(damage * 1.5, flags | DamageFlag.DAMAGE_CLONES, source, countdown)
		local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, familiar)
		poof.Color = Color(0.2, 0.2, 0.2, 1, 0, 0, 0)
		SFXManager():Play(SoundEffect.SOUND_TOOTH_AND_NAIL, 0.5)
		return false
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, typ, var, sub, pos, vel, spawner, seed)
	if typ == EntityType.ENTITY_FAMILIAR and var == FamiliarVariant.DIP then
		for i, entity in pairs(Isaac.FindInRadius(pos, 1, EntityPartition.ENEMY)) do
			if entity.Type == EntityType.ENTITY_POOP then
				local data = entity:GetData() 
				if data.FFCursedPoop then
					return {typ, var, 667}
				elseif data.FFShampoo then
					return {typ, var, 666}
				elseif data.FFEvilPoop then
					return {typ, var, 671}
				end
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
	for i, entity in pairs(Isaac.FindInRadius(effect.Position, 1, EntityPartition.ENEMY)) do
		if entity.Type == EntityType.ENTITY_POOP then
			local data = entity:GetData() 
			if data.FFCursedPoop then
				effect:GetSprite():ReplaceSpritesheet(0, "gfx/grid/grid_cursed_poop_gibs.png")
				effect:GetSprite():LoadGraphics()
			elseif data.FFShampoo then
				effect:GetSprite():ReplaceSpritesheet(0, "gfx/grid/grid_shampoo_gibs.png")
				effect:GetSprite():LoadGraphics()
			elseif data.FFEvilPoop then
				effect:GetSprite():ReplaceSpritesheet(0, "gfx/grid/evilpoop/grid_evilpoopgibs.png")
				effect:GetSprite():LoadGraphics()
			end
		end
	end
end, EffectVariant.POOP_PARTICLE)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	local savedata = mod.GetPersistentPlayerData(player)
	local data = player:GetData()
	if savedata.Poops and savedata.Poops[1] == "DIP" or savedata.StoredPoop == "DIP" then
		if not data.DipSpellAura or not data.DipSpellAura:Exists() then
			local halo = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALLOWED_GROUND, 0, player.Position, Vector.Zero, player):ToEffect()
			halo.Parent = player
			halo:FollowParent(player)
			halo.DepthOffset = -100
			halo.Color = Color(1, 0.2, 0.2, 1, 0, 0, 0)
			data.DipSpellAura = halo
		end
	elseif data.DipSpellAura and data.DipSpellAura:Exists() then
		data.DipSpellAura:Remove()
	end
end, PlayerType.PLAYER_BLUEBABY_B)

if FiendFolio.WackyPoopsEnabled then
	mod:AddSpellToPool("CURSED", "Common", 0.5)
	mod:AddSpellToPool("CURSED", "Uncommon", 0.5)
	
	mod:AddSpellToPool("SHAMPOO", "Common", 1)
	mod:AddSpellToPool("SHAMPOO", "Uncommon", 1)
	
	mod:AddSpellToPool("EVIL", "Rare", 1)
	
	mod:AddSpellToPool("DIP", "Special", 0.5)
end


mod.SpellSprites["CURSED"] = {}
for j = 1, 4 do
	mod.SpellSprites["CURSED"][mod.SpellAnimations[j]] = Sprite()
	mod.SpellSprites["CURSED"][mod.SpellAnimations[j]]:Load("gfx/ui/ui_ffpoop.anm2", true)
	mod.SpellSprites["CURSED"][mod.SpellAnimations[j]]:Play(mod.SpellAnimations[j])
end

mod:AddPoopSpellCallback(function(_, spell, player)
	local poop = Isaac.Spawn(EntityType.ENTITY_POOP, -1, -1, player.Position, Vector.Zero, player)
	for i = 1, 20 do
		poop:Update()
	end
	poop:GetData().FFCursedPoop = true
	poop:GetSprite():ReplaceSpritesheet(0, "gfx/grid/grid_cursed_poop.png")
	poop:GetSprite():LoadGraphics()
	player:TryHoldEntity(poop)
	SFXManager():Play(SoundEffect.SOUND_POOPITEM_HOLD)
end, "CURSED")



mod.SpellSprites["SHAMPOO"] = {}
for j = 1, 4 do
	mod.SpellSprites["SHAMPOO"][mod.SpellAnimations[j]] = Sprite()
	mod.SpellSprites["SHAMPOO"][mod.SpellAnimations[j]]:Load("gfx/ui/ui_ffpoop.anm2", true)
	mod.SpellSprites["SHAMPOO"][mod.SpellAnimations[j]]:Play(mod.SpellAnimations[j])
	mod.SpellSprites["SHAMPOO"][mod.SpellAnimations[j]]:SetFrame(1)
end


mod:AddPoopSpellCallback(function(_, spell, player)
	local poop = Isaac.Spawn(245, -1, -1, player.Position, Vector.Zero, player)
	for i = 1, 20 do
		poop:Update()
	end
	poop:GetData().FFShampoo = true
	poop:GetSprite():ReplaceSpritesheet(0, "gfx/grid/grid_shampoo.png")
	poop:GetSprite():LoadGraphics()
	player:TryHoldEntity(poop)
	SFXManager():Play(SoundEffect.SOUND_POOPITEM_HOLD)
end, "SHAMPOO")



mod.SpellSprites["EVIL"] = {}
for j = 1, 4 do
	mod.SpellSprites["EVIL"][mod.SpellAnimations[j]] = Sprite()
	mod.SpellSprites["EVIL"][mod.SpellAnimations[j]]:Load("gfx/ui/ui_ffpoop.anm2", true)
	mod.SpellSprites["EVIL"][mod.SpellAnimations[j]]:Play(mod.SpellAnimations[j])
	mod.SpellSprites["EVIL"][mod.SpellAnimations[j]]:SetFrame(2)
end

mod:AddPoopSpellCallback(function(_, spell, player)
	local poop = Isaac.Spawn(245, -1, -1, player.Position, Vector.Zero, player)
	for i = 1, 20 do
		poop:Update()
	end
	poop:GetData().FFEvilPoop = true
	poop:GetSprite():ReplaceSpritesheet(0, "gfx/grid/evilpoop/grid_evilpoop.png")
	poop:GetSprite():LoadGraphics()
	player:TryHoldEntity(poop)
	SFXManager():Play(SoundEffect.SOUND_POOPITEM_HOLD)
end, "EVIL")


mod.SpellSprites["DIP"] = {}
for j = 1, 4 do
	mod.SpellSprites["DIP"][mod.SpellAnimations[j]] = Sprite()
	mod.SpellSprites["DIP"][mod.SpellAnimations[j]]:Load("gfx/ui/ui_ffpoop.anm2", true)
	mod.SpellSprites["DIP"][mod.SpellAnimations[j]]:Play(mod.SpellAnimations[j])
	mod.SpellSprites["DIP"][mod.SpellAnimations[j]]:SetFrame(3)
end

mod:AddPoopSpellCallback(function(_, spell, player)
	local wisp = player:AddItemWisp(CollectibleType.COLLECTIBLE_DIRTY_MIND, player.Position)
	wisp.Player = player
	wisp:RemoveFromOrbit()
	wisp.Visible = false
	wisp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_DIRTY_MIND, true) then
		player:RemoveCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_DIRTY_MIND))
	end
	for i, entity in pairs(Isaac.FindInRadius(player.Position, 80, EntityPartition.ENEMY)) do
		if entity.Type == EntityType.ENTITY_POOP then
			entity:Die()
		end
	end
	for i, grident in pairs(FiendFolio.GetGridEntities()) do
		if grident:ToPoop() and grident.Position:Distance(player.Position) <= 80 then
			grident:Destroy()
		end
	end
	FiendFolio.scheduleForUpdate(function()
		wisp:Remove()
		wisp:Kill()
	end, 1)
end, "DIP")

-- Copper Bombs --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

-- all this shit because there's no way to tell if a bomb is supposed to be a dr fetus bomb in pre ent spawn weeeeeeeeeeeeeeeeeeeeeeeeee
function mod:copperPostFireBomb(player, bomb)
	local data = bomb:GetData()
	if not data.TriedLoadingFFCopperBomb then
		local var = bomb.Variant
		data.FFCopperBomb = bomb.Variant == FiendFolio.BOMB.COPPER or
		                    bomb.Variant == FiendFolio.BOMB.NUGGET_COPPER or
		                    bomb.Variant == FiendFolio.BOMB.LOCUST_COPPER or
		                    bomb.Variant == FiendFolio.BOMB.SLIPPY_COPPER or
		                    bomb.Variant == FiendFolio.BOMB.BRIDGE_COPPER
		
		if (var == BombVariant.BOMB_NORMAL or
		    var == BombVariant.BOMB_ROCKET or
		    var == FiendFolio.BOMB.NUGGET or
		    var == FiendFolio.BOMB.LOCUST or
		    var == FiendFolio.BOMB.SLIPPY or
		    var == FiendFolio.BOMB.BRIDGE) and
		   bomb.SpawnerEntity and
		   bomb.SpawnerEntity.Type == EntityType.ENTITY_PLAYER and
		   bomb.SpawnerEntity:GetData().ffsavedata ~= nil and
		   bomb.SpawnerEntity:GetData().ffsavedata.FFCopperBombsStored ~= nil and
		   bomb.SpawnerEntity:GetData().ffsavedata.FFCopperBombsStored > 0
		then
			data.FFCopperBomb = true
			bomb.SpawnerEntity:GetData().ffsavedata.FFCopperBombsStored = bomb.SpawnerEntity:GetData().ffsavedata.FFCopperBombsStored - 1
		end
		
		if data.FFCopperBomb then
			if bomb.Variant == BombVariant.BOMB_NORMAL then
				bomb.Variant = FiendFolio.BOMB.COPPER
			elseif bomb.Variant == BombVariant.BOMB_ROCKET then
				-- FUCK YOU IN PARTICULAR NO SUBTYPE BOMBCOSTUMES STINK DUMB
				local sprite = bomb:GetSprite()
				sprite:ReplaceSpritesheet(0, "gfx/items/pick ups/bombs/copper/costumes/rocket.png")
				sprite:LoadGraphics()
			elseif bomb.Variant == FiendFolio.BOMB.NUGGET then
				bomb.Variant = FiendFolio.BOMB.NUGGET_COPPER
			elseif bomb.Variant == FiendFolio.BOMB.LOCUST then
				bomb.Variant = FiendFolio.BOMB.LOCUST_COPPER
			elseif bomb.Variant == FiendFolio.BOMB.SLIPPY then
				bomb.Variant = FiendFolio.BOMB.SLIPPY_COPPER
			elseif bomb.Variant == FiendFolio.BOMB.BRIDGE then
				bomb.Variant = FiendFolio.BOMB.BRIDGE_COPPER
			end
			
			bomb.ExplosionDamage = bomb.ExplosionDamage * 1.85
			
			if bomb.Variant ~= BombVariant.BOMB_ROCKET then
				bomb.Flags = bomb.Flags -- ????????????????????????????????????????????????? WHY DO I NEED TO DO THIS WHY DOES THIS REFRESH THE SPRITE WHY
			end
		end
		
		bomb:GetData().TriedLoadingFFCopperBomb = true
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	if pickup.SubType == FiendFolio.PICKUP.BOMB.COPPER then
		if collider.Type == 1 and collider:GetData().ffsavedata then
			local player = collider:ToPlayer()
			if player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY_B then
				return false
			elseif pickup:IsShopItem() and pickup.Price > player:GetNumCoins() then
				return true
			else
				if pickup:GetSprite():WasEventTriggered("DropSound") or pickup:GetSprite():IsPlaying("Idle") or pickup:GetSprite():IsFinished("Idle") then
					player:AddBombs(1)
					player:GetData().ffsavedata.FFCopperBombsStored = (player:GetData().ffsavedata.FFCopperBombsStored or 0) + 1
					
					pickup:GetSprite():Play("Collect")
					sfx:Play(FiendFolio.Sounds.CopperBombPickup, 0.2, 0, false, 1)
					sfx:Play(SoundEffect.SOUND_FETUS_FEET, 2, 0, false, 1)

					pickup.Velocity = nilvector
					pickup.Touched = true
					pickup.EntityCollisionClass = 0

					if pickup:IsShopItem() then
						player:AddCoins(-1 * pickup.Price)
					end

					if pickup.OptionsPickupIndex ~= 0 then
						local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)
						for _, entity in ipairs(pickups) do
							if entity:ToPickup().OptionsPickupIndex == pickup.OptionsPickupIndex and
							   (entity.Index ~= pickup.Index or entity.InitSeed ~= pickup.InitSeed)
							then
								Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, nilvector, nil)
								entity:Remove()
							end
						end
					end
			
					Game():SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)
					
					pickup:Die()
				end
				return true
			end
		else
			return false
		end
	end
end, PickupVariant.PICKUP_BOMB)

mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, function(_, bomb)
	local var = bomb.Variant
	local data = bomb:GetData()
	if not data.FFCopperBomb and
	   (var == FiendFolio.BOMB.COPPER or 
	    var == FiendFolio.BOMB.NUGGET_COPPER or 
	    var == FiendFolio.BOMB.LOCUST_COPPER or 
	    var == FiendFolio.BOMB.SLIPPY_COPPER or 
	    var == FiendFolio.BOMB.BRIDGE_COPPER)
	then
		data.FFCopperBomb = true
		data.FFCopperBombWasADud = bomb.SubType == 923
	end
	
	if data.FFCopperBomb then
		local sprite = bomb:GetSprite()
		
		if bomb.Child == nil then
			local hitbox = Isaac.Spawn(mod.FF.Hitbox.ID, mod.FF.Hitbox.Var, 0, bomb.Position, Vector.Zero, bomb)
			local hdata = hitbox:GetData()
			hdata.PositionOffset = nilvector
			hdata.FixToSpawner = true
			hdata.AllowKnockback = false
			hdata.FFCopperBombHitbox = true
			hitbox.CollisionDamage = 0
			hitbox.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			hitbox.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
			
			hdata.OnHurt = function(npc, damage, flag, source, countdown)
				if flag & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION then
					if npc.SpawnerEntity ~= nil and 
					   npc.SpawnerEntity:Exists() and
					   npc.SpawnerEntity:ToBomb() and 
					   npc.SpawnerEntity:GetData().FFCopperBomb and 
					   npc.SpawnerEntity:GetSprite():GetAnimation() ~= "Explode" and
					   not (source and 
					        source.Entity and 
					        source.Entity.InitSeed == npc.SpawnerEntity.InitSeed and 
					        source.Entity.Index == npc.SpawnerEntity.Index)
					then
						npc.SpawnerEntity:GetSprite():Play("Pulse", true)
						npc.SpawnerEntity:ToBomb():SetExplosionCountdown(0)
						npc.SpawnerEntity:GetData().FFCopperBombForcingExplosion = true
					end
				end
				return false
			end
			
			hdata.OnCollide = function(npc1, npc2, first)
				return true
			end
			
			bomb.Child = hitbox
		end
		
		if data.FFCopperBombWasADud then
			if not data.FFCopperBombForcingExplosion then
				sprite:Play("Idle", true)
				bomb:SetExplosionCountdown(9999)
			end
		elseif sprite:IsPlaying("Pulse") and sprite:GetFrame() == 58 then
			local rng = RNG()
			rng:SetSeed(bomb.InitSeed, 0)
			if rng:RandomFloat() > 0.5 then
				if rng:RandomFloat() < 0.00001 then
					sfx:Play(FiendFolio.Sounds.CopperBombSuccess, 1.0, 0, false, 1.0)
				end
			else
				data.FFCopperBombWasADud = true
				bomb.SubType = 923
				sprite:Play("Idle", true)
				bomb:SetExplosionCountdown(9999)
				bomb.ExplosionDamage = bomb.ExplosionDamage / 1.85
				
				sfx:Play(FiendFolio.Sounds.CopperBombSizzle, 1.2, 0, false, 1.25 + math.random() * 0.25)
				
				for i = 1, 2 do
					local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, 
					                          bomb.Position, 
					                          RandomVector() * (math.random() / 2 + 0.5) * 3, 
	                                          bomb)
					smoke.SpriteOffset = Vector(0,-20)
					smoke.SpriteScale = Vector(0.7, 0.7)
					smoke.DepthOffset = 10
				end
			end
		end
	end
end)

local dudBombs = {}
function mod:copperBombPreRemoteDeto(item, rng, player, flags, slot, vardata)
	local bombs = Isaac.FindByType(4)
	for _, bomb in ipairs(bombs) do
		local bomb = bomb:ToBomb()
		local var = bomb.Variant
		local data = bomb:GetData()
		if not data.FFCopperBomb and
		   (var == FiendFolio.BOMB.COPPER or 
		    var == FiendFolio.BOMB.NUGGET_COPPER or 
		    var == FiendFolio.BOMB.LOCUST_COPPER or 
		    var == FiendFolio.BOMB.SLIPPY_COPPER or 
		    var == FiendFolio.BOMB.BRIDGE_COPPER)
		then
			data.FFCopperBomb = true
			data.FFCopperBombWasADud = bomb.SubType == 923
		end
		
		if data.FFCopperBomb then
			local rng = RNG()
			rng:SetSeed(bomb.InitSeed, 0)
			if (data.FFCopperBombForcingExplosion or not data.FFCopperBombWasADud) and rng:RandomFloat() > 0.5 then
				--explode
			else
				local sprite = bomb:GetSprite()
				
				if not data.FFCopperBombWasADud then
					sfx:Play(SoundEffect.SOUND_FIREDEATH_HISS, 1, 0, false, 1.5)
					
					for i = 1, 2 do
						local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, 
												  bomb.Position, 
												  RandomVector() * (math.random() / 2 + 0.5) * 3, 
												  bomb)
						smoke.SpriteOffset = Vector(0,-20)
						smoke.SpriteScale = Vector(0.7, 0.7)
						smoke.DepthOffset = 10
					end
				end
				
				data.FFCopperBombWasADud = true
				bomb.SubType = 923
				sprite:Play("Idle", true)
				bomb:SetExplosionCountdown(9999)
				bomb.ExplosionDamage = bomb.ExplosionDamage / 1.85
				
				data.FFCopperOriginalVariant = bomb.SpawnerEntity
				bomb.SpawnerEntity = nil
				table.insert(dudBombs, bomb)
			end
		end
	end
end

function mod:AddCopperBombCallbacks()
	mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, mod.copperBombPreRemoteDeto, CollectibleType.COLLECTIBLE_REMOTE_DETONATOR)
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, item, rng, player, flags, slot, vardata)
	for _, bomb in pairs(dudBombs) do
		if bomb:Exists() then
			bomb.SpawnerEntity = bomb:GetData().FFCopperOriginalSpawnerEntity
			bomb:GetData().FFCopperOriginalSpawnerEntity = nil
		end
	end
	dudBombs = {}
end, CollectibleType.COLLECTIBLE_REMOTE_DETONATOR)

--local bombuisprite = Sprite()
--bombuisprite:Load("gfx/ui/bomb_copper.anm2", true)
--bombuisprite:Play("Full", true)
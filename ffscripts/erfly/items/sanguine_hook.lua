local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, itemID, rng, player, useflags)
	local d = player:GetData()
	if d.myVeryOwnSanfordSanguineHook and d.myVeryOwnSanfordSanguineHook:Exists() then
		local hd = d.myVeryOwnSanfordSanguineHook:GetData()
		if hd.state == "reeling" then
			--[[d.myVeryOwnSanfordSanguineHook:Remove()
			d.holdingFFItem = mod.ITEM.COLLECTIBLE.SANGUINE_HOOK
			player:AnimateCollectible(mod.ITEM.COLLECTIBLE.SANGUINE_HOOK, "LiftItem", "PlayerPickup")
			]]
			hd.StateFrame = 10
		elseif hd.hooktarget and hd.hooktarget:Exists() then
			hd.pullingOut = true
			d.myVeryOwnSanfordSanguineHook:Update()
		else
			hd.state = "reeling"
		end
	else
		if d.holdingFFItem then
			d.holdingFFItem = nil
			d.HoldingFFItemBlankVisual = nil
			player:AnimateCollectible(mod.ITEM.COLLECTIBLE.SANGUINE_HOOK, "HideItem", "PlayerPickup")
		else
			d.holdingFFItem = mod.ITEM.COLLECTIBLE.SANGUINE_HOOK
			d.HoldingFFItemBlankVisual = true
			player:AnimateCollectible(mod.ITEM.COLLECTIBLE.SANGUINE_HOOK, "LiftItem", "PlayerPickup")
			d.sanguineHookSpawnWisps = player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)
		end
	end
end, mod.ITEM.COLLECTIBLE.SANGUINE_HOOK)

function mod:sanguineHookPlayerUpdate(player, data)

	if player:HasCollectible(mod.ITEM.COLLECTIBLE.SANGUINE_HOOK) then
		if not data.hasSanguineHookCostume then
			player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/sanguine_hook.anm2"))
			data.hasSanguineHookCostume = true
		end
	else
		if data.hasSanguineHookCostume then
			player:TryRemoveNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/sanguine_hook.anm2"))
			data.hasSanguineHookCostume = nil
		end
	end

	if FiendFolio.OldIsaacRebuiltMode then
		if player.FrameCount < 1 and Isaac.GetChallenge() == mod.challenges.isaacRebuilt then
			player:SetPocketActiveItem(mod.ITEM.COLLECTIBLE.SANGUINE_HOOK)
		end
	else
		if Isaac.GetChallenge() == mod.challenges.isaacRebuilt then
			if not data.hasSanguineHookCostumeChallenge then
				player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/sanguine_hook_challenge.anm2"))
				data.hasSanguineHookCostumeChallenge = true
			end
			if data.timeSinceLastHitSanguineHookAgainstWall then
				data.timeSinceLastHitSanguineHookAgainstWall = data.timeSinceLastHitSanguineHookAgainstWall + 1
			end
			if not data.holdingFFItem then
				if data.myVeryOwnSanfordSanguineHook and data.myVeryOwnSanfordSanguineHook:Exists() then
					if data.myVeryOwnSanfordSanguineHook.FrameCount > 5 then
						local aim = player:GetAimDirection()
						if aim:Length() < 0.2 then
							local hd = data.myVeryOwnSanfordSanguineHook:GetData()
							if hd.hooktarget and hd.hooktarget:Exists() and hd.state == "hooked" then
								hd.pullingOut = true
								data.myVeryOwnSanfordSanguineHook:Update()
							else
								hd.state = "reeling"
							end
						end
					end
				else
					data.holdingFFItem = mod.ITEM.COLLECTIBLE.SANGUINE_HOOK
					data.firingSanguineHookShot = true
					data.sanguineHookSpawnWisps = false
				end
			end
		end
	end
end

function mod:useHeldSanguineHook(player, data, aim)
	local hook = Isaac.Spawn(mod.FF.SanguineHook.ID, mod.FF.SanguineHook.Var, mod.FF.SanguineHook.Sub, player.Position - player.Velocity, aim * 30 * player.ShotSpeed + player:GetTearMovementInheritance(aim), player)
	hook.GridCollisionClass = GridCollisionClass.COLLISION_WALL
	hook.CollisionDamage = 8
	hook:GetSprite().Rotation = hook.Velocity:GetAngleDegrees()
	--data.holdingFFItem = nil
	hook.Parent = player
	hook.SpawnerEntity = player
	data.myVeryOwnSanfordSanguineHook = hook
	hook:GetData().sanguineHookSpawnWisps = data.sanguineHookSpawnWisps
	hook:Update()
	local sd = FiendFolio.savedata.run
	if (not sd.SanguineHookSpamHits) or (sd.SanguineHookSpamHits and (not (sd.SanguineHookSpamHits > 3600)) or sd.SanguineHookSpamHits >= 5000) then
		sfx:Play(mod.Sounds.CleaverThrow,0.3,0,false, math.random(70,90)/100)
	end
end

function mod.sanguineHookNewRoom()
	if Isaac.GetChallenge() == mod.challenges.isaacRebuilt then
		local sd = FiendFolio.savedata.run
		if sd and sd.SanguineHookSpamHits and sd.SanguineHookSpamHits < 200 then
			sd.SanguineHookSpamHits = 0
		end
		sd.HasLeftStartRoom = true
	end
end

function mod:sanguineHookPlayerColl(player, collider)
	if player:HasCollectible(mod.ITEM.COLLECTIBLE.SANGUINE_HOOK) then
		local d = player:GetData()
		if d.myVeryOwnSanfordSanguineHook and d.myVeryOwnSanfordSanguineHook:Exists() then
			local hd = d.myVeryOwnSanfordSanguineHook:GetData()
			if hd.state == "hooked" and hd.hooktarget:Exists() then
				local ht = hd.hooktarget
				if collider:IsEnemy() and collider.InitSeed == ht.InitSeed then
					--endThing
					hd.pullingOut = true
					d.myVeryOwnSanfordSanguineHook:Update()
				end
			end
		end
	end
end

mod.sanguineHookFamiliarWhitelist = {
	[FamiliarVariant.PETROCK] = true,
	[FamiliarVariant.RANDY_THE_SNAIL] = true,
}

function mod:tryHookingThings(e, sprite, d)
	local pickup = mod.FindClosestEntity(e.Position, 35, 5)
	if not d.IsSirenCharmed and pickup and not pickup:GetSprite():IsPlaying("Collect") and pickup.Variant ~= PickupVariant.PICKUP_FIEND_MINION and pickup.EntityCollisionClass > 0 then
		if (pickup.Variant ~= 100 or (pickup.Variant == 100 and pickup.SubType ~= 0)) and not pickup:ToPickup():IsShopItem() then
			sfx:Play(mod.Sounds.GrappleGrab,1,0,false, math.random(140,160)/100)
			d.state = "hooked"
			d.hooktarget = pickup
			mod:spritePlay(sprite, "Impact")
			e.Velocity = nilvector
			pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			return true
		end
	elseif d.IsSirenCharmed then
		local player = e.SpawnerEntity:ToPlayer()
		local target = mod:getClosestPlayer(e.Position, 30)
		if target and (target.Index ~= player.Index or target.InitSeed ~= player.InitSeed) then
			local sirens = Isaac.FindByType(EntityType.ENTITY_SIREN, 0)
			local ref = EntityRef(nil)
			if #sirens > 0 then ref = EntityRef(sirens[0]) end
			target:TakeDamage(1, 0, ref, 0)
		end
	else
		local player = e.SpawnerEntity:ToPlayer()
		local target = mod.FindClosestEnemy(e.Position, 30, false, nil, nil, EntityCollisionClass.ENTCOLL_PLAYEROBJECTS)
		for _, fire in ipairs(Isaac.FindByType(33, -1, -1, false, false)) do
			if fire.Variant < 2 then
				if fire.Position:Distance(e.Position) < 20 then
					fire:Die()
				end
			end
		end
		for _, barrel in ipairs(Isaac.FindByType(292, -1, -1, false, false)) do
			if barrel.Position:Distance(e.Position) < 20 then
				barrel:TakeDamage(1, 0, EntityRef(e), 0)
			end
		end
		if target then
			target:TakeDamage(player.Damage * 0.5, 0, EntityRef(player), 0)
			if target.HitPoints > player.Damage * 0.5 then
				if target.Type == 114 and target.Variant == 19 and target:GetData().holdingBomb then
					local tData = target:GetData()
					sfx:Play(mod.Sounds.GrappleGrab,1,0,false, math.random(140,160)/100)
					local redBomb = Isaac.Spawn(5, 41, 0, target.Position, target.Velocity, target)
					redBomb.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
					redBomb:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					d.state = "hooked"
					d.hooktarget = redBomb
					mod:spritePlay(sprite, "Impact")
					e.Velocity = nilvector
					tData.holdingBomb:Remove()
					tData.holdingBomb = nil
					target:ToNPC().StateFrame = 0
					tData.state = "Idle"
				else
					sfx:Play(mod.Sounds.CleaverHit,0.5,0,false, math.random(90,110)/100)
					d.state = "hooked"
					d.hooktarget = target
					target:BloodExplode()
					--mod:spritePlay(sprite, "ImpactBloody")
					mod:spritePlay(sprite, "Impact")
					e.Velocity = nilvector
					d.bloody = target.SplatColor
				end
			end
			if d.sanguineHookSpawnWisps then
				for i = 1, 4 do
					local wisp = player:AddWisp(mod.ITEM.COLLECTIBLE.SANGUINE_HOOK, player.Position)
					d.sanguineHookWisps = d.sanguineHookWisps or {}
					table.insert(d.sanguineHookWisps, wisp)
				end
				sfx:Play(SoundEffect.SOUND_CANDLE_LIGHT, 1, 0, false, 1)
			end
			return true
		else
			local familiar = mod.FindClosestEntity(e.Position, 35, 3)
			if familiar and mod.sanguineHookFamiliarWhitelist[familiar.Variant] then
				sfx:Play(mod.Sounds.GrappleGrab,1,0,false, math.random(140,160)/100)
				d.state = "hooked"
				d.hooktarget = familiar
				mod:spritePlay(sprite, "Impact")
				e.Velocity = nilvector
				return true
			end
		end
	end
end



function mod:sanguineHookAI(e)
	local parent = e.Parent
	local player = e.SpawnerEntity:ToPlayer()
	local sprite = e:GetSprite()
	local d = e:GetData()

	if e.SubType == mod.FF.SanguineHook.Sub and not d.checkedGoldSkin then
		if FiendFolio.savedata.goldenSanguineHookUnlocked then
			if Isaac.GetChallenge() == mod.challenges.isaacRebuilt then
				sprite:ReplaceSpritesheet(0, "gfx/effects/effect_sanguinehook_gold.png")
				sprite:LoadGraphics()
			end
		end
	end

	e.SpriteOffset = Vector(0, -15)
	e.RenderZOffset = -300

	if not e.Parent then
		e:Remove()
		return
	end

	if not e.Child then
		local handler = Isaac.Spawn(1000, 1749, 1, e.Position, nilvector, e):ToEffect()
		handler.Parent = e
		handler.Visible = false
		handler:Update()

		local rope = Isaac.Spawn(EntityType.ENTITY_EVIS, 10, 24, e.Parent.Position, nilvector, e)
		e.Child = rope

		rope.Parent = handler
		rope.Target = e.Parent

		rope:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		rope:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		rope.DepthOffset = -20
		
		if d.IsSuperpositioned then
			rope:GetSprite():Load("gfx/effects/rope_sanguine_hook_superpositioned.anm2", true)
		end

		rope:GetSprite():Play("Idle", true)
		rope:GetSprite():SetFrame(100)
		rope:Update()

		rope.SplatColor = Color(1,1,1,0,0,0,0)
	end

	e.Child:Update()
	e.Child:Update()

	if not d.init then
		d.state = "flying"
		d.init = true
	else
		d.StateFrame = d.StateFrame or 0
		d.StateFrame = d.StateFrame + 1
	end

	local animString = ""
	--if d.bloody then
	--	animString = "Bloody"
	--end

	if d.pullingOut then
		local vec = (parent.Position - d.hooktarget.Position):Resized(10)
		d.state = "reeling"
		d.StateFrame = 5
		if not d.hooktarget:HasEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK) then
			d.hooktarget.Velocity = d.hooktarget.Velocity + vec
		end
		d.stopChecking = true
		if d.hooktarget.Type ~= 5 and d.hooktarget.Type ~= 3 then
			d.hooktarget:BloodExplode()
			d.hooktarget:TakeDamage(player.Damage, 0, EntityRef(player), 0)
			if d.hooktarget:HasMortalDamage() then
				sfx:Play(mod.Sounds.MeatySquish, 0.3, 0, false, math.random(80,120)/100)
				game:ShakeScreen(7)
				for i = -25, 25, 5 do
					local tear = Isaac.Spawn(2, 1, 0, d.hooktarget.Position + vec:Resized(d.hooktarget.Size + d.hooktarget.Velocity:Length() + 5):Rotated(i), vec:Resized(math.random(60,150)/10):Rotated(i - 10 + math.random(20)), player):ToTear()
					local val = 0.8 + math.random(4) / 10
					tear.Scale = val
					tear.CollisionDamage = 3.5 * val
					tear.FallingSpeed = -20 + math.random(10)
					tear.FallingAcceleration = 1.5 + (math.random() * 0.5)
					if d.IsSuperpositioned then
						local tearcolor = Color.Lerp(tear.Color, Color(1,1,1,1,0,0,0), 0)
						tearcolor.A = tearcolor.A / 4
						tear.Color = tearcolor
					end
					tear:Update()
				end

				if Isaac.GetChallenge() == mod.challenges.isaacRebuilt then
					for i = 1, 2 do
						local vecuse = RandomVector():Resized(math.random(1,20)/10)
						local heart = Isaac.Spawn(5, 10, 2, d.hooktarget.Position + vecuse:Resized(30), vecuse, player):ToPickup()
						heart.Timeout = 60
						heart:Update()
					end
				end
			else
				local secondHandMultiplier = player:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND) + 1

				sfx:Play(mod.Sounds.MeatyBurst, 0.4, 0, false, math.random(80,120)/100)
				--d.hooktarget:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
				FiendFolio.AddBleed(d.hooktarget, player, 180 * secondHandMultiplier, player.Damage * 0.5, false, true)
				game:ShakeScreen(3)
				for i = -20, 20, 10 do
					local tear = Isaac.Spawn(2, 1, 0, d.hooktarget.Position + vec:Resized(d.hooktarget.Size + d.hooktarget.Velocity:Length() + 5):Rotated(i), vec:Resized(math.random(110,150)/10):Rotated(i - 10 + math.random(20)), player):ToTear()
					local val = 0.8 + math.random(4) / 10
					tear.Scale = val
					tear.CollisionDamage = 3.5 * val
					tear.FallingSpeed = -10 + math.random(10)
					if d.IsSuperpositioned then
						local tearcolor = Color.Lerp(tear.Color, Color(1,1,1,1,0,0,0), 0)
						tearcolor.A = tearcolor.A / 4
						tear.Color = tearcolor
					end
					tear:Update()
				end
			end
		end
		d.pullingOut = nil
	end

	if d.state == "flying" then
		mod:spritePlay(sprite, "Fly" .. animString)
		sprite.Rotation = e.Velocity:GetAngleDegrees()
		--It feels very wrong that this is how I do a function????
		if not mod:tryHookingThings(e, sprite, d) then
			local grident = game:GetRoom():GetGridEntityFromPos(e.Position)
			if (grident and (grident.Desc.Type == GridEntityType.GRID_WALL or grident.Desc.Type == GridEntityType.GRID_DOOR)) then
				if e.SubType == 52 then
					sfx:Play(mod.Sounds.CleaverHitWorld,0.2,0,false, math.random(120,180)/100)
				else
					mod:sanguineHookWorldHitJoke(e, d)
					local sd = FiendFolio.savedata.run
					if sd.SanguineHookSpamHits and sd.SanguineHookSpamHits > 5000 and sd.SanguineHookSpamHits < 5010 then
						sfx:Play(mod.Sounds.CleaverHitWorld,2,0,false, math.random(80,140)/100)
					elseif sd.SanguineHookSpamHits and sd.SanguineHookSpamHits > 4050 and sd.SanguineHookSpamHits < 4100 then
						sfx:Play(mod.Sounds.NitroExpired,1,0,false, math.random(80,140)/100)
					elseif (not sd.SanguineHookSpamHits) or (sd.SanguineHookSpamHits and (not (sd.SanguineHookSpamHits > 3200)) or sd.SanguineHookSpamHits >= 5010) then
						sfx:Play(mod.Sounds.CleaverHitWorld,0.5,0,false, math.random(80,140)/100)
					end
				end
				e.Velocity = e.Velocity * -2
				d.state = "reeling"
				d.StateFrame = 5
			elseif grident then
				if grident.Desc.Type == GridEntityType.GRID_POOP then
					grident:Destroy()
				elseif grident.Desc.Type == GridEntityType.GRID_TNT then
					grident:Hurt(1)
				end
			end
		end
		e.Velocity = e.Velocity * 0.95
		if d.StateFrame and d.StateFrame > 15 then
			d.state = "reeling"
			d.StateFrame = 0
		end
	elseif d.state == "hooked" then
		if not (sprite:IsPlaying("Impact") or sprite:IsPlaying("ImpactBloody")) then
			mod:spritePlay(sprite, "Idle" .. animString)
		end
		if d.hooktarget and d.hooktarget:Exists() and ((d.hooktarget.Type ~= 5 and d.hooktarget.Type ~= 3 and d.hooktarget.EntityCollisionClass >= EntityCollisionClass.ENTCOLL_PLAYEROBJECTS) or ((d.hooktarget.Type == 5 or d.hooktarget.Type == 3) and d.hooktarget.Position:Distance(e.Parent.Position) > e.Parent.Size + d.hooktarget.Size)) then
			local speed = 10
			if d.hooktarget.Type == 5 then
				speed = 20
				d.hooktarget.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			end
			if (not d.hooktarget:HasEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)) or d.hooktarget.Type == 5 then
				d.hooktarget.Velocity = mod:Lerp(d.hooktarget.Velocity, (parent.Position - d.hooktarget.Position):Resized(speed), 0.5)
			end
			if d.hooktarget.Type == 5 then
				if d.hooktarget.TargetPosition then
					d.hooktarget.TargetPosition = d.hooktarget.Position + d.hooktarget.Velocity
				end
				if d.hooktarget.Variant == 100 then
					local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, e.Position, (e.Velocity * -0.3):Rotated(-20 + math.random(40)), e):ToEffect()
					smoke.Color = Color(1,1,1,1,0.3,0.3,0.3)
					smoke:Update()
				end
			elseif d.hooktarget.Type ~= 3 then
				if mod:playerIsBelialMode(player) then
					local tempEffects = player:GetEffects()
					if not tempEffects:HasNullEffect(NullItemID.ID_JUDAS_BIRTHRIGHT) then
						tempEffects:AddNullEffect(NullItemID.ID_JUDAS_BIRTHRIGHT)
						local poof = Isaac.Spawn(1000, 16, 3, player.Position, nilvector, player)
						poof.SpriteScale = Vector(0.5,0.5)
						poof:Update()
						local poof = Isaac.Spawn(1000, 16, 4, player.Position, nilvector, player)
						poof.SpriteScale = Vector(0.5,0.5)
						poof.SpriteOffset = Vector(0, -10)
						poof:Update()
					end
				end
				FiendFolio.AddBruise(d.hooktarget, player, 1, 1, 1, false, true)
			end
			e.Velocity = d.hooktarget.Velocity
			e.Position = d.hooktarget.Position
			sprite.Rotation = (d.hooktarget.Position - e.Parent.Position):GetAngleDegrees()
		else
			d.state = "reeling"
			d.StateFrame = 0
			d.stopChecking = true
		end
	elseif d.state == "reeling" then
		mod:spritePlay(sprite, "Fly" .. animString)
		sprite.Rotation = (e.Position - parent.Position):GetAngleDegrees()
		e.Velocity = mod:Lerp(e.Velocity, (parent.Position - e.Position) * math.min(1, d.StateFrame / 30), math.min(1, d.StateFrame / 10))
		if d.sanguineHookWisps then
			for _, wisp in ipairs(d.sanguineHookWisps) do
				if wisp:Exists() then
					wisp:Kill()
				end
			end
			d.sanguineHookWisps = nil
		end
		if player:GetEffects():HasNullEffect(NullItemID.ID_JUDAS_BIRTHRIGHT) then
			player:GetEffects():RemoveNullEffect(NullItemID.ID_JUDAS_BIRTHRIGHT)
			local poof = Isaac.Spawn(1000, 15, 0, player.Position, nilvector, player)
			poof.Color = Color(1,1,1,0.3)
			poof:Update()
		end
		if e.Position:Distance(e.Parent.Position) < 20 then
			e:Remove()
		end
		if not d.stopChecking then
			mod:tryHookingThings(e, sprite, d)
		end
	end
end

local bloodsprite = Sprite()
local deimosbloodsprite = Sprite()
bloodsprite:Load("gfx/effects/effect_sanguinehook.anm2", true)
deimosbloodsprite:Load("gfx/familiar/deimos/effect_sanguinehook_deimos.anm2", true)
function mod:sanguineHookRender(e, offset)
	local d = e:GetData()
	
	if d.bloody then
		if e.SubType == mod.FF.SanguineHookSmall.Sub then
			local sprite = e:GetSprite()
			deimosbloodsprite:SetFrame(sprite:GetAnimation() .. "Bloody", sprite:GetFrame())
			
			deimosbloodsprite.Color = d.bloody
			deimosbloodsprite.FlipX = sprite.FlipX
			deimosbloodsprite.FlipY = sprite.FlipY
			deimosbloodsprite.Offset = sprite.Offset
			deimosbloodsprite.PlaybackSpeed = sprite.PlaybackSpeed
			deimosbloodsprite.Rotation = sprite.Rotation
			deimosbloodsprite.Scale = sprite.Scale
			
			deimosbloodsprite:Render(Isaac.WorldToRenderPosition(e.Position + e.PositionOffset) + offset, nilvector, nilvector)
		else
			local sprite = e:GetSprite()
			bloodsprite:SetFrame(sprite:GetAnimation() .. "Bloody", sprite:GetFrame())
			
			bloodsprite.Color = d.bloody
			bloodsprite.FlipX = sprite.FlipX
			bloodsprite.FlipY = sprite.FlipY
			bloodsprite.Offset = sprite.Offset
			bloodsprite.PlaybackSpeed = sprite.PlaybackSpeed
			bloodsprite.Rotation = sprite.Rotation
			bloodsprite.Scale = sprite.Scale
			
			bloodsprite:Render(Isaac.WorldToRenderPosition(e.Position + e.PositionOffset) + offset, nilvector, nilvector)
		end
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, familiar, entity, mystery)
	if familiar.Variant == FamiliarVariant.WISP and familiar.SubType == mod.ITEM.COLLECTIBLE.SANGUINE_HOOK then
		familiar.CollisionDamage = 2.5
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, entity)
	if (entity.Variant == mod.FF.SanguineHook.Var and entity.SubType == mod.FF.SanguineHook.Sub) or
	   (entity.Variant == mod.FF.SanguineHookSmall.Var and entity.SubType == mod.FF.SanguineHookSmall.Sub) then
		local data = entity:GetData()
		if data.sanguineHookWisps then
			for _, wisp in ipairs(data.sanguineHookWisps) do
				if wisp:Exists() then
					wisp:Kill()
				end
			end
			data.sanguineHookWisps = nil
		end

		if entity.Child then
			entity.Child:Remove()
		end
	end
end, EntityType.ENTITY_EFFECT)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, handler)
	if handler.SubType == 1 then
		if not handler.Parent or not handler.Parent:Exists() then
			handler:Remove()
		else
			handler.Position = handler.Parent.Position + Vector(0, -5) + Vector(20, 0):Rotated(handler.Parent:GetSprite().Rotation - 180)
			handler.Velocity = handler.Parent.Velocity
		end
	end
end, 1749)
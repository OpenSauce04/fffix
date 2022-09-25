-- Rift Walker --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:riftWalkerAI(npc, sprite, npcdata)
	if npc.SubType == 10 then
		npc.Color = Color(1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0)
		npc.Position = Vector(0,4000)
		npc.Velocity = nilvector
		if not npc.Parent or mod:isStatusCorpse(npc.Parent) then
			npc:Remove()
		end
	else
		local path = npc.Pathfinder
		local target = npc:GetPlayerTarget()
		local targetpos = mod:confusePos(npc, target.Position)
		local r = npc:GetDropRNG()
		
		if not npcdata.init then
			sprite:ReplaceSpritesheet(0, "blank.png")
			sprite:ReplaceSpritesheet(1, "blank.png")
			sprite:ReplaceSpritesheet(2, "blank.png")
			sprite:LoadGraphics()
		
			local above = Isaac.Spawn(mod.FF.RiftWalkerGfx.ID, mod.FF.RiftWalkerGfx.Var, mod.FF.RiftWalkerGfx.Sub, Vector(0,4000), nilvector, nil):ToNPC()
			above.Color = Color(1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0)
			
			above:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			above:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
			above.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			above.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			
			above.Parent = npc
			npcdata.above = above
		
			local below = Isaac.Spawn(mod.FF.RiftWalkerGfx.ID, mod.FF.RiftWalkerGfx.Var, mod.FF.RiftWalkerGfx.Sub, Vector(0,4000), nilvector, nil):ToNPC()
			below.Color = Color(1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0)
			below:GetData().reflection = true
			
			below:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			below:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
			below.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			below.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			
			below.Parent = npc
			npcdata.below = below
			
			if npc.SubType == 0 then
				npcdata.state = "above"
				npcdata.corpseDisplayAbove = true
			else
				npcdata.state = "below"
				npcdata.corpseDisplayAbove = false
			end
			npc.StateFrame = 0
			npcdata.flipCooldown = 140 + math.random(20)
			
			npcdata.params = ProjectileParams()
			npcdata.params.Variant = 4
			
			npcdata.init = true
		else
			npc.StateFrame = npc.StateFrame + 1
			npcdata.flipCooldown = npcdata.flipCooldown - 1
		end
		
		local above = npcdata.above
		local below = npcdata.below
		
		local level = game:GetLevel()
		if level:GetStage() == LevelStage.STAGE1_2 and StageAPI.GetDimension(level:GetCurrentRoomDesc()) == 1 then
			above = npcdata.below
			below = npcdata.above
		end
		
		local abovesprite = above:GetSprite()
		local belowsprite = below:GetSprite()

		if npcdata.state == "above" then
			above.Visible = true
			below.Visible = false
			
			if not (abovesprite:IsOverlayPlaying("Head01") or abovesprite:IsOverlayFinished("Head01")) then
				abovesprite:PlayOverlay("Head01", true)
			end
			belowsprite:SetFrame("Switch01", 999)
			
			if npc.Velocity:Length() > 0.1 then
				above.Velocity = npc.Velocity
				above:AnimWalkFrame("WalkHori","WalkVert",0)
				above.Velocity = nilvector
			else
				abovesprite:SetFrame("WalkVert", 0)
			end

			if mod:isScare(npc) then
				local targetvel = (targetpos - npc.Position):Resized(-3)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
			elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
				local targetvel = (targetpos - npc.Position):Resized(3)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
			else
				path:FindGridPath(targetpos, 0.4, 900, true)
			end

			if npcdata.flipCooldown <= 0 then
				npcdata.state = "fall"
			elseif npc.StateFrame > 30 and not mod:isScareOrConfuse(npc) then
				local isClear = game:GetRoom():CheckLine(npc.Position, target.Position, 3)
				if isClear and r:RandomInt(5) == 0 then
					npcdata.state = "attack"
					abovesprite:PlayOverlay("Shoot", true)
				end
			end
		elseif npcdata.state == "attack" then
			above.Visible = true
			below.Visible = false
			
			if not (abovesprite:IsOverlayPlaying("Shoot") or abovesprite:IsOverlayFinished("Shoot")) then
				abovesprite:PlayOverlay("Shoot", true)
			end
			belowsprite:SetFrame("Switch01", 999)
			
			if npc.Velocity:Length() > 0.1 then
				above.Velocity = npc.Velocity
				above:AnimWalkFrame("WalkHori","WalkVert",0)
				above.Velocity = nilvector
			else
				abovesprite:SetFrame("WalkVert", 0)
			end

			if mod:isScare(npc) then
				local targetvel = (targetpos - npc.Position):Resized(-3)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
			elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
				local targetvel = (targetpos - npc.Position):Resized(3)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
			else
				path:FindGridPath(targetpos, 0.4, 900, true)
			end

			if not npcdata.firedProj and abovesprite:GetOverlayFrame() >= 8 then
				if not mod:isScareOrConfuse(npc) then
					npc:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, 0.6, 0, false, 1.0)
					npc:FireProjectiles(npc.Position, (target.Position - npc.Position):Resized(9), 0, npcdata.params)
				end
				npcdata.firedProj = true
			elseif abovesprite:IsOverlayFinished("Shoot") then
				npc.StateFrame = 0
				npcdata.state = "above"
				npcdata.firedProj = nil
				abovesprite:PlayOverlay("Head01", true)
			end
		elseif npcdata.state == "below" then
			above.Visible = false
			below.Visible = true
			
			if not (belowsprite:IsOverlayPlaying("Head02") or belowsprite:IsOverlayFinished("Head02")) then
				belowsprite:PlayOverlay("Head02", true)
			end
			abovesprite:SetFrame("Switch01", 999)
			
			if npc.Velocity:Length() > 0.1 then
				below.Velocity = npc.Velocity
				below:AnimWalkFrame("WalkHori","WalkVert",0)
				below.Velocity = nilvector
			else
				belowsprite:SetFrame("WalkVert", 0)
			end

			if mod:isScare(npc) then
				local targetvel = (targetpos - npc.Position):Resized(-5)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
			elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
				local targetvel = (targetpos - npc.Position):Resized(5)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
			else
				path:FindGridPath(targetpos, 0.7, 900, true)
			end
			
			if npcdata.flipCooldown <= 0 then
				npcdata.state = "rise"
			end
		elseif npcdata.state == "fall" then
			npc.Velocity = npc.Velocity * 0.75
			
			above.Visible = true
			below.Visible = true
			
			abovesprite:RemoveOverlay()
			belowsprite:RemoveOverlay()
			
			if not (abovesprite:IsPlaying("Switch01") or abovesprite:IsFinished("Switch01")) then
				abovesprite:Play("Switch01", true)
			end
			
			if not (belowsprite:IsPlaying("Return02") or belowsprite:IsFinished("Return02")) then
				belowsprite:SetFrame("Return02", 0)
				belowsprite:Stop()
			end
			
			if abovesprite:IsEventTriggered("Splash") then
				npc:PlaySound(SoundEffect.SOUND_BOSS2_DIVE, 0.7, 0, false, 1.0)
				local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, npc.Position, nilvector, nil)
				splash.SpriteScale = Vector(0.8, 0.8)
				
				belowsprite:Play("Return02", true)
				belowsprite:SetFrame(1)
				
				npcdata.corpseDisplayAbove = false
			end
			
			if belowsprite:GetFrame() ~= 0 and belowsprite:IsFinished("Return02") then
				npc.StateFrame = 0
				npcdata.flipCooldown = 140 + math.random(20)
				npcdata.state = "below"
			end
		elseif npcdata.state == "rise" then
			npc.Velocity = npc.Velocity * 0.75
			
			above.Visible = true
			below.Visible = true
			
			abovesprite:RemoveOverlay()
			belowsprite:RemoveOverlay()
			
			if not (belowsprite:IsPlaying("Switch02") or belowsprite:IsFinished("Switch02")) then
				belowsprite:Play("Switch02", true)
			end
			
			if not (abovesprite:IsPlaying("Return01") or abovesprite:IsFinished("Return01")) then
				abovesprite:SetFrame("Return01", 0)
				abovesprite:Stop()
			end
			
			if belowsprite:IsEventTriggered("Splash") then
				npc:PlaySound(SoundEffect.SOUND_BOSS2_DIVE, 0.7, 0, false, 1.0)
				local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, npc.Position, nilvector, nil)
				splash.SpriteScale = Vector(0.8, 0.8)
				
				abovesprite:Play("Return01", true)
				abovesprite:SetFrame(1)
				
				npcdata.corpseDisplayAbove = true
			end
			
			if abovesprite:GetFrame() ~= 0 and abovesprite:IsFinished("Return01") then
				npc.StateFrame = 0
				npcdata.flipCooldown = 140 + math.random(20)
				npcdata.state = "above"
			end
		end
		
		if npc:HasMortalDamage() and FiendFolio:isLeavingStatusCorpse(npc) then -- To make Uranus/Crucifix corpses display the correct anim
			sprite:Reload()
			if npcdata.corpseDisplayAbove then
				sprite:SetFrame(abovesprite:GetAnimation(), abovesprite:GetFrame())
				sprite:SetOverlayFrame(abovesprite:GetOverlayAnimation(), abovesprite:GetOverlayFrame())
			else
				sprite:SetFrame(belowsprite:GetAnimation(), belowsprite:GetFrame())
				sprite:SetOverlayFrame(belowsprite:GetOverlayAnimation(), belowsprite:GetOverlayFrame())
			end
			sprite:Stop()
		end
	end
end

local function renderRiftWalkerGfx(npc, gfx, npcsprite, offset)
	if gfx then
		local gfxsprite = gfx:GetSprite()
		
		gfxsprite.Color = npcsprite.Color
		gfxsprite.Scale = npcsprite.Scale
		
		gfxsprite:Render(Isaac.WorldToRenderPosition(npc.Position + npc.PositionOffset) + offset, nilvector, nilvector)
		
		gfxsprite.Color = Color(1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0)
	end
end

function mod:riftWalkerRender(npc, sprite, npcdata, offset)
	if npc.SubType ~= 10 then
		local rendermode = game:GetRoom():GetRenderMode()
		if game:GetLevel():GetStage() == LevelStage.STAGE1_2 and StageAPI.GetDimension(game:GetLevel():GetCurrentRoomDesc()) == 1 then
			if rendermode ~= RenderMode.RENDER_NORMAL and rendermode ~= RenderMode.RENDER_WATER_ABOVE then
				renderRiftWalkerGfx(npc, npcdata.below, sprite, offset)
			elseif rendermode ~= RenderMode.RENDER_WATER_REFLECT then
				renderRiftWalkerGfx(npc, npcdata.above, sprite, offset)
			end
		else
			if rendermode ~= RenderMode.RENDER_WATER_REFLECT then
				renderRiftWalkerGfx(npc, npcdata.above, sprite, offset)
			elseif rendermode ~= RenderMode.RENDER_NORMAL and rendermode ~= RenderMode.RENDER_WATER_ABOVE then
				renderRiftWalkerGfx(npc, npcdata.below, sprite, offset)
			end
		end
	end
end

function mod:riftWalkerTakeDmg(entity, damage, flags, source, countdown)
	if entity.SubType == 10 then
		return false
	end
end

function mod:riftWalkerSetAnimMulti(entity, data, statusMultiplier)
	if entity.Type == mod.FF.RiftWalker.ID and entity.Variant == mod.FF.RiftWalker.Var and entity.SubType ~= mod.FF.RiftWalkerGfx.Sub then
		local above = data.above
		local below = data.below
		
		local slowAnimMulti = 1.0
		if entity:HasEntityFlags(EntityFlag.FLAG_SLOW) then
			slowAnimMulti = 0.5
		end
		
		local freezeAnimMulti = 1.0
		if entity:HasEntityFlags(EntityFlag.FLAG_FREEZE) or entity:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) then
			freezeAnimMulti = 0.0
		end
		
		if above and above:Exists() then
			above:GetSprite().PlaybackSpeed = statusMultiplier * slowAnimMulti * freezeAnimMulti
		end
		if below and below:Exists() then 
			below:GetSprite().PlaybackSpeed = statusMultiplier * slowAnimMulti * freezeAnimMulti
		end
	end
end

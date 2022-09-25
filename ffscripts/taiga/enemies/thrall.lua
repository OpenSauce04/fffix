-- Thrall --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local function indexOf(npc)
	return npc.Index .. " " .. npc.InitSeed
end

local function getEnthralledEnemies(npc)
	--find parent and all attached segments, support enemies, cuffed enemies, etc.
	local enthralledProcessed = {}
	local enthralledToBeProcessed = {{npc, true}}
	
	local eternalFlickerspirits = Isaac.FindByType(mod.FF.EternalFlickerspirit.ID, mod.FF.EternalFlickerspirit.Var, -1, true)
	local viscerspirits = Isaac.FindByType(mod.FF.Viscerspirit.ID, mod.FF.Viscerspirit.Var, -1, true)
	local harletwins = Isaac.FindByType(mod.FF.Harletwin.ID, mod.FF.Harletwin.Var, 0, true)
	local effigies = Isaac.FindByType(mod.FF.Effigy.ID, mod.FF.Effigy.Var, 0, true)
	local thralls = Isaac.FindByType(mod.FF.Thrall.ID, mod.FF.Thrall.Var, 0, true)
	local eternalFlies = Isaac.FindByType(EntityType.ENTITY_ETERNALFLY, -1, -1, true)
	local eternalFliesCustom = Isaac.FindByType(mod.FF.DeadFlyOrbital.ID, mod.FF.DeadFlyOrbital.Var, -1, true)
	local dwellerBros = Isaac.FindByType(mod.FF.DwellerBrother.ID, mod.FF.DwellerBrother.Var, -1, true)
	
	while #enthralledToBeProcessed > 0 do
		local processed = enthralledToBeProcessed[1][1]
		local doProcessSegments = enthralledToBeProcessed[1][2]
		
		if not enthralledProcessed[indexOf(processed)] then
			if (processed.Type == mod.FF.Harletwin.ID and processed.Variant == mod.FF.Harletwin.Var) or 
			   (processed.Type == mod.FF.Effigy.ID and processed.Variant == mod.FF.Effigy.Var) or
			   (processed.Type == mod.FF.Thrall.ID and processed.Variant == mod.FF.Thrall.Var)
			then
				if processed.Parent and not enthralledProcessed[indexOf(processed.Parent)] then
					table.insert(enthralledToBeProcessed, {processed.Parent, true})
				end
				
				if processed:GetData().balls then
					for _, ball in ipairs(processed:GetData().balls) do
						if not enthralledProcessed[indexOf(ball)] then
							enthralledProcessed[indexOf(ball)] = ball
						end
					end
				end
			elseif processed.Type == mod.FF.Cuffs.ID and processed.Variant == mod.FF.Cuffs.Var then
				for _, cuffed in pairs(processed:GetData().ConnectedEntities) do
					if indexOf(cuffed) ~= indexOf(processed) and
					   not enthralledProcessed[indexOf(cuffed)]
					then
						table.insert(enthralledToBeProcessed, {cuffed, true})
					end
				end	
				
				for _, chains in pairs(processed:GetData().Chains) do
					for _, chain in pairs(chains) do
						if not enthralledProcessed[indexOf(chain)] then
							enthralledProcessed[indexOf(chain)] = chain
						end
					end
				end
			end
			
			enthralledProcessed[indexOf(processed)] = processed
			
			for _, harletwin in pairs(harletwins) do
				if harletwin.Parent and
				   indexOf(harletwin.Parent) == indexOf(processed) and
				   not enthralledProcessed[indexOf(harletwin)]
				then
					table.insert(enthralledToBeProcessed, {harletwin, true})
				end
			end
			
			for _, effigy in pairs(effigies) do
				if effigy.Parent and
				   indexOf(effigy.Parent) == indexOf(processed) and
				   not enthralledProcessed[indexOf(effigy)]
				then
					table.insert(enthralledToBeProcessed, {effigy, true})
				end
			end
			
			for _, thrall in pairs(thralls) do
				if thrall.Parent and
				   indexOf(thrall.Parent) == indexOf(processed) and
				   not enthralledProcessed[indexOf(thrall)]
				then
					table.insert(enthralledToBeProcessed, {thrall, true})
				end
			end
			
			for _, eternalFlicker in pairs(eternalFlickerspirits) do
				if eternalFlicker.Parent and
				   indexOf(eternalFlicker.Parent) == indexOf(processed) and
				   not enthralledProcessed[indexOf(eternalFlicker)]
				then
					table.insert(enthralledToBeProcessed, {eternalFlicker, true})
				end
			end
			
			for _, viscer in pairs(viscerspirits) do
				if viscer.Parent and
				   indexOf(viscer.Parent) == indexOf(processed) and
				   not enthralledProcessed[indexOf(viscer)]
				then
					table.insert(enthralledToBeProcessed, {viscer, true})
				end
			end
			
			for _, eternal in pairs(eternalFlies) do
				if eternal.Parent and
				   indexOf(eternal.Parent) == indexOf(processed) and
				   not enthralledProcessed[indexOf(eternal)]
				then
					table.insert(enthralledToBeProcessed, {eternal, true})
				end
			end
			
			for _, customEternal in pairs(eternalFliesCustom) do
				if customEternal.Parent and
				   indexOf(customEternal.Parent) == indexOf(processed) and
				   not enthralledProcessed[indexOf(customEternal)]
				then
					table.insert(enthralledToBeProcessed, {customEternal, true})
				end
			end
			
			for _, brother in pairs(dwellerBros) do
				if brother.Parent and
				   indexOf(brother.Parent) == indexOf(processed) and
				   not enthralledProcessed[indexOf(brother)]
				then
					table.insert(enthralledToBeProcessed, {brother, true})
				end
			end
			
			if processed:GetData().IsCuffed then
				for _, cuffs in pairs(processed:GetData().ConnectedCuffs) do
					if indexOf(cuffs) ~= indexOf(processed) and
					   not enthralledProcessed[indexOf(cuffs)]
					then
						table.insert(enthralledToBeProcessed, {cuffs, true})
					end
				end
			end
			
			if doProcessSegments and mod:isSegmented(processed) then
				local segments = mod:getSegments(processed)
				
				for _, segment in pairs(segments) do
					if indexOf(segment) ~= indexOf(processed) and
					   not enthralledProcessed[indexOf(segment)]
					then
						table.insert(enthralledToBeProcessed, {segment, false})
					end
				end
			end
			
			if doProcessSegments and mod:isBasegameSegmented(processed) then
				local segments = mod:getBasegameSegments(processed)
				
				for _, segment in pairs(segments) do
					if indexOf(segment) ~= indexOf(processed) and
					   not enthralledProcessed[indexOf(segment)]
					then
						table.insert(enthralledToBeProcessed, {segment, false})
					end
				end
			end
		end
		
		table.remove(enthralledToBeProcessed, 1)
	end
	
	return enthralledProcessed
end

function mod:thrallAI(npc, sprite, npcdata)
	if npc.SubType == 1 then
		if not npcdata.init then
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
			mod:spritePlay(sprite, "ChainAppear")
			npcdata.init = true
		end

		if sprite:IsFinished("ChainAppear") then
			mod:spritePlay(sprite, "Chain")
		end

		npc.SpriteOffset = Vector(0, -10)

		if npc.Child and npc.Parent and not (mod:isStatusCorpse(npc.Child) or mod:isStatusCorpse(npc.Parent)) then
			local p1 = npc.Parent.Position
			local p2 = npc.Child.Position
			local vec = p2 - p1
			npc.Position = p1 + vec * npcdata.PeckingOrder[1] / npcdata.PeckingOrder[2]
		else
			npc:Remove()
		end
	else
		npc.SplatColor = FiendFolio.ColorDemonBlack
		
		if not npcdata.init then
			local friend = mod.FindClosestEnemyEffigy(npc.Position)
			if friend then
				npc.Parent = friend
				local numballs = 4
				local vec = friend.Position - npc.Position
				for i = 1, numballs do
					local ball = Isaac.Spawn(mod.FF.ThrallCord.ID, 
					                         mod.FF.ThrallCord.Var, 
					                         mod.FF.ThrallCord.Sub, 
					                         npc.Position + ((vec * i) / (numballs + 1)), 
					                         nilvector, 
					                         npc):ToNPC()
					ball.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					ball.GridCollisionClass = GridCollisionClass.COLLISION_NONE
					ball:GetData().PeckingOrder = {i, numballs + 1}
					ball.Parent = npc
					ball.Child = friend
					ball:Update()
					
					npcdata.balls = npcdata.balls or {}
					table.insert(npcdata.balls, ball)
				end
			end
			npcdata.state = "idle"
			npcdata.timeTillNextPhase = 0
			npcdata.hasDoneFirstPhase = false
			npcdata.init = true
		else
			npcdata.timeTillNextPhase = npcdata.timeTillNextPhase - 1
		end

		if npc.Parent and not mod:isStatusCorpse(npc.Parent) then
			--npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			local p = npc.Parent

			local vec = (p.Position - npc.Position)

				if not npcdata.ExtraVec or npc.FrameCount % 80 == 1 then
					npcdata.ExtraVec = RandomVector() * 70
				end
			if vec:Length() > 120 then
				npc.Velocity = mod:Lerp(npc.Velocity, vec:Resized(math.max(5, p.Velocity:Length())), 0.2)
			elseif vec:Length() > 80 then
				npc.Velocity = mod:Lerp(npc.Velocity, vec:Resized(5), 0.05)
			else
				npc.Velocity = npc.Velocity * 0.95
				local targetvel = npcdata.ExtraVec:Resized(2)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.05)
			end

			if npcdata.state == "idle" then
				mod:spritePlay(sprite, "Idle")

				if (not mod:isScareOrConfuse(npc)) and npcdata.timeTillNextPhase <= 0 then
					npcdata.state = "phase"
					npcdata.timeTillNextPhase = math.floor((math.random(70) + math.random(70)) / 2) + 160
					if not npcdata.hasDoneFirstPhase then
						npcdata.timeTillNextPhase = npcdata.timeTillNextPhase - 24
						npcdata.hasDoneFirstPhase = true
					end
				end
			elseif npcdata.state == "phase" then
				if sprite:IsFinished("Phase") then
					npcdata.state = "idle"
					npc.StateFrame = 0
				elseif sprite:IsEventTriggered("Fade") then
					local enthralled = getEnthralledEnemies(npc)
					local fadeOut = 40
					local fadeIn = math.random(35) + 80
					for _, enemy in pairs(enthralled) do
						if enemy:GetData().Enthralled == nil then 
							enemy:GetData().Enthralled = true
							enemy:GetData().EnthralledFadeOut = fadeOut
							enemy:GetData().EnthralledFadeIn = fadeIn
						end
					end
					
					npc:PlaySound(SoundEffect.SOUND_MONSTER_YELL_B, 0.5, 0, false, 1.7 + (math.random(100) - 50) * 0.002)
				else
					mod:spritePlay(sprite, "Phase")
				end
			end
		else
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc.Velocity = npc.Velocity * 0.95
			npcdata.FFIsDeathAnimation = true
			npc.CanShutDoors = false
			if sprite:IsFinished("Freed") then
				npc:Remove()
			else
				mod:spritePlay(sprite, "Freed")
			end
			
			if sprite:IsEventTriggered("SnapSound") then
				npc:PlaySound(SoundEffect.SOUND_CHAIN_BREAK, 0.7, 0, false, 1.3 + (math.random(100) - 50) * 0.002)
			elseif sprite:IsEventTriggered("Fly") then
				npc:PlaySound(SoundEffect.SOUND_MONSTER_ROAR_0, 0.4, 0, false, 2.0 + (math.random(100) - 50) * 0.002)
			end
		end
	end
end

function mod:handleEnthralled(npc, sprite, npcdata)
	if mod:isStatusCorpse(npc) then
		npcdata.Enthralled = nil
		npcdata.EnthralledFadeIn = nil
		npcdata.EnthralledFadeOut = nil
		npc.Visible = true
	elseif npcdata.Enthralled then
		if npcdata.EnthralledFadeOut then
			local alpha = 0.0 + 0.025 * (npcdata.EnthralledFadeOut)
			local currentColor = sprite.Color
			local newColor = Color.Lerp(currentColor, Color(1,1,1,1,0,0,0), 0)
			newColor:SetTint(currentColor.R, currentColor.G, currentColor.B, currentColor.A * alpha)
			npc:SetColor(newColor, 1, 0, false, false)
		elseif npcdata.EnthralledFadeIn > 20 then
			npc.Visible = false
		else
			npc.Visible = true
			local alpha = 1.0 - 0.05 * (npcdata.EnthralledFadeIn - 1)
			local currentColor = sprite.Color
			local newColor = Color.Lerp(currentColor, Color(1,1,1,1,0,0,0), 0)
			newColor:SetTint(currentColor.R, currentColor.G, currentColor.B, currentColor.A * alpha)
			npc:SetColor(newColor, 1, 0, false, false)
		end
		
		if npcdata.EnthralledFadeOut ~= nil then
			npcdata.EnthralledFadeOut = npcdata.EnthralledFadeOut - 1
			if npcdata.EnthralledFadeOut <= 0 then
				npcdata.EnthralledFadeOut = nil
			end
		else
			npcdata.EnthralledFadeIn = npcdata.EnthralledFadeIn - 1
			if npcdata.EnthralledFadeIn <= 0 then
				npcdata.EnthralledFadeIn = nil
				npcdata.Enthralled = nil
			end
		end
	
		if npc.Type == mod.FF.Cuffs.ID and npc.Variant == mod.FF.Cuffs.Var then	
			for _, chains in pairs(npc:GetData().Chains) do
				for _, chain in pairs(chains) do
					mod:handleEnthralled(chain, chain:GetSprite(), chain:GetData())
				end
			end	
		end
	end
end

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local function indexOf(npc)
	return npc.Index .. " " .. npc.InitSeed
end

local function getAttackLocations(npc)
	local effigyProcessed = {}
	local effigyProcessedButNotToBeUsed = {}
	local effigyToBeProcessed = {{npc.Parent, true}}
	
	while #effigyToBeProcessed > 0 do
		local processed = effigyToBeProcessed[1][1]
		local doProcessSegments = effigyToBeProcessed[1][2]
		
		if not effigyProcessed[indexOf(processed)] and not effigyProcessedButNotToBeUsed[indexOf(processed)] then
			if processed.Type == mod.FF.Cuffs.ID and processed.Variant == mod.FF.Cuffs.Var then
				for _, cuffed in pairs(processed:GetData().ConnectedEntities) do
					if indexOf(cuffed) ~= indexOf(processed) and
					   not effigyProcessed[indexOf(cuffed)] and
					   not effigyProcessedButNotToBeUsed[indexOf(cuffed)]
					then
						table.insert(effigyToBeProcessed, {cuffed, true})
					end
				end
				effigyProcessedButNotToBeUsed[indexOf(processed)] = processed
			else
				if not mod:isSegmented(processed) and not mod:isBasegameSegmented(processed) then
					if processed.Index ~= npc.Index or processed.InitSeed ~= npc.InitSeed then
						effigyProcessed[indexOf(processed)] = processed
					end
				else
					if doProcessSegments then
						if mod:isSegmented(processed) then
							local segments = mod:getSegments(processed)
							
							for _, segment in pairs(segments) do
								if indexOf(segment) ~= indexOf(processed) and
								   not effigyProcessed[indexOf(segment)] and
								   not effigyProcessedButNotToBeUsed[indexOf(segment)]
								then
									table.insert(effigyToBeProcessed, {segment, false})
								end
							end
						elseif mod:isBasegameSegmented(processed) then
							local segments = mod:getBasegameSegments(processed)
							
							for _, segment in pairs(segments) do
								if indexOf(segment) ~= indexOf(processed) and
								   not effigyProcessed[indexOf(segment)] and
								   not effigyProcessedButNotToBeUsed[indexOf(segment)]
								then
									table.insert(effigyToBeProcessed, {segment, false})
								end
							end
						end
					end
					
					if mod:isMainSegment(processed) then
						effigyProcessed[indexOf(processed)] = processed
					elseif mod:isBasegameMainSegment(processed) then
						effigyProcessed[indexOf(processed)] = processed
					else
						effigyProcessedButNotToBeUsed[indexOf(processed)] = processed
					end
				end
				
				if processed:GetData().IsCuffed then
					for _, cuffs in pairs(processed:GetData().ConnectedCuffs) do
						if indexOf(cuffs) ~= indexOf(processed) and
						   not effigyProcessed[indexOf(cuffs)] and
						   not effigyProcessedButNotToBeUsed[indexOf(cuffs)]
						then
							table.insert(effigyToBeProcessed, {cuffs, true})
						end
					end
				end
			end
		end
		
		table.remove(effigyToBeProcessed, 1)
	end
	
	return effigyProcessed
end

--harletwinai
function mod:effigyAI(npc, subt, var)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if subt == 1 then
		if not d.init then
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
			npc:AddEntityFlags(EntityFlag.FLAG_NO_DEATH_TRIGGER | EntityFlag.FLAG_HIDE_HP_BAR | EntityFlag.FLAG_NO_FLASH_ON_DAMAGE | EntityFlag.FLAG_NO_REWARD)
			mod:spritePlay(sprite, "ChainAppear")
			d.init = true
		end

		if sprite:IsFinished("ChainAppear") then
			mod:spritePlay(sprite, "Chain")
		end

		npc.SpriteOffset = Vector(0, -10)

		if npc.Child and npc.Parent and not (mod:isStatusCorpse(npc.Child) or mod:isStatusCorpse(npc.Parent)) then
			local p1 = npc.Parent.Position
			local p2 = npc.Child.Position
			local vec = p2 - p1
			npc.Position = p1 + vec * d.PeckingOrder[1] / d.PeckingOrder[2]
		else
			npc:Kill()
		end
	else

		if not d.init then
			local friend = mod.FindClosestEnemyEffigy(npc.Position)
			if friend then
				npc.Parent = friend
				local numballs = 4
				local vec = friend.Position - npc.Position
				for i = 1, numballs do
					local ball = Isaac.Spawn(npc.Type, var, 1, npc.Position + ((vec * i) / (numballs + 1)), nilvector, npc):ToNPC()
					ball.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					ball.GridCollisionClass = GridCollisionClass.COLLISION_NONE
					ball:GetData().PeckingOrder = {i, numballs + 1}
					ball.Parent = npc
					ball.Child = friend
					ball:Update()
					
					d.balls = d.balls or {}
					table.insert(d.balls, ball)
				end
			end
			d.state = "idle"
			d.init = true
		else
			npc.StateFrame = npc.StateFrame + 1
		end

		if npc.Parent and not mod:isStatusCorpse(npc.Parent) then
			--npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			local p = npc.Parent

			local vec = (p.Position - npc.Position)

				if not d.ExtraVec or npc.FrameCount % 80 == 1 then
					d.ExtraVec = RandomVector() * 70
				end
			if vec:Length() > 120 then
				npc.Velocity = mod:Lerp(npc.Velocity, vec:Resized(math.max(5, p.Velocity:Length())), 0.2)
			elseif vec:Length() > 80 then
				npc.Velocity = mod:Lerp(npc.Velocity, vec:Resized(5), 0.05)
			else
				npc.Velocity = npc.Velocity * 0.95
				local targetvel = d.ExtraVec:Resized(2)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.05)
			end

			if d.state == "idle" then
				mod:spritePlay(sprite, "Idle")

				if (not mod:isScareOrConfuse(npc)) and ((npc.StateFrame > 55 and math.random(7) == 1) or npc.StateFrame > 75) then
						d.state = "attack"
				end
			elseif d.state == "attack" then
				if sprite:IsFinished("Attack") then
					d.state = "idle"
					npc.StateFrame = 0
				elseif sprite:IsEventTriggered("Shoot") then
					npc:PlaySound(mod.Sounds.FlashBaby,1,2,false,1.3)
					local params = ProjectileParams()
					if var == 521 then
						params.BulletFlags = params.BulletFlags | ProjectileFlags.SMART
						params.HomingStrength = 1
					end
					
					local attacks = getAttackLocations(npc)
					for _, attackPosition in pairs(attacks) do
						for i = 60, 360, 60 do
							npc:FireProjectiles(attackPosition.Position + (attackPosition.Velocity*0.2), Vector(0,8):Rotated(i) + (attackPosition.Velocity*0.2), 0, params)
						end
					end
				else
					mod:spritePlay(sprite, "Attack")
				end
			end
		else
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc.Velocity = npc.Velocity * 0.95
			if sprite:IsFinished("Death") then
				npc:Kill()
			else
				mod:spritePlay(sprite, "Death")
			end
		end
	end
end
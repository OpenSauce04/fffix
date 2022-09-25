local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

FiendFolio.EclipsesShutDown = false

function mod:umbraAI(npc, subt)
	local sprite = npc:GetSprite();
	local d = npc:GetData();
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()

	if not d.init then
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		d.init = true
		if subt > 0 then
			if subt == 2 then
				sprite.FlipX = true
				npc.SubType = 1
			end
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			mod:spritePlay(sprite, "Combine")
			local poof = Isaac.Spawn(1000,15,0, npc.Position, nilvector, npc):ToEffect()
			poof:Update()
		end
		npc.SplatColor = Color(1,1,1,1,-1,-1,-1)
	end

	npc.SpriteOffset = Vector(0, -10)

	if subt == 0 then
		local closeBoy = mod.FindClosestEntity(npc.Position, 200, mod.FF.UmbraNormal.ID, mod.FF.UmbraNormal.Var, 0, nil, npc.InitSeed)
		if not sprite:IsPlaying("Appear") then
			mod:spritePlay(sprite, "Idle01")
		end
		if sprite:GetFrame() == 0 and npc.FrameCount > 10 and not mod:isScare(npc) then
			if math.random(2) == 1 or mod:isConfuse(npc) then
				if closeBoy and math.random(2) and not mod:isConfuse(npc) then
					npc.Velocity = mod:Lerp(npc.Velocity, (closeBoy.Position - npc.Position):Resized(20), 0.3)
				else
					npc.Velocity = mod:Lerp(npc.Velocity, RandomVector() * 20, 0.3)
				end
			else
				npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, (target.Position - npc.Position):Resized(20)), 0.3)
			end
		end
		npc.Velocity = npc.Velocity * 0.96
		if closeBoy then
			local dist = closeBoy.Position:Distance(npc.Position)
			if dist < 50 then
				local distvec = (closeBoy.Position - npc.Position):Resized((50 - dist) / 10)
				npc.Velocity = mod:Lerp(npc.Velocity, distvec, 0.2)
			end
		end
	elseif subt == 1 then
		if sprite:IsPlaying("SplitHori") or sprite:IsPlaying("SplitVert") or sprite:IsFinished("SplitHori") or sprite:IsFinished("SplitVert") then
			if sprite:IsFinished("SplitHori") or sprite:IsFinished("SplitVert") then
				--[[local xFunny = 1
				local yFunny = 1
				if d.vec.X < 0 then
					xFunny = -1
				end
				if d.vec.Y < 0 then
					yFunny = -1
				end]]
				for i = 0, 180, 180 do
					--local vel = mod:Lerp(d.vec:Resized(12), Vector(xFunny,yFunny):Resized(12),0.2)
					local boy = Isaac.Spawn(mod.FF.UmbraNormal.ID,mod.FF.UmbraNormal.Var,0, npc.Position + d.vec:Resized(25):Rotated(i), d.vec:Resized(12):Rotated(i), npc)
					boy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					boy.HitPoints = npc.HitPoints / 2
					boy:Update()
					boy:GetData().ChangedHP = true
					boy:GetData().HPIncrease = 0.1
					if d.ES and d.ES > 0 then
						boy:GetData().eclipsespawned = true
						d.ES = d.ES - 1
					end
					for k = -30, 30, 30 do
						local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position, d.vec:Resized(math.random(3,7)):Rotated(i + k - 10 + math.random(20)), npc):ToEffect()
						smoke.SpriteRotation = math.random(360)
						smoke.Color = Color(0,0,0,0.6,0,0,0)
						smoke.SpriteOffset = Vector(0, -16)
						smoke.RenderZOffset = 300
						smoke:Update()
					end
				end
				npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,0.3,2,false,math.random(130,140)/100)
				npc:Remove()
			end
		elseif not sprite:IsPlaying("Combine") then
			mod:spritePlay(sprite, "Idle02")
			if sprite:GetFrame() == 0 then
				if (math.random(2) == 1 or mod:isConfuse(npc)) and not mod:isScare(npc) then
					npc.Velocity = mod:Lerp(npc.Velocity, RandomVector() * 7, 0.3)
				else
					npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, (target.Position - npc.Position):Resized(7)), 0.3)
				end
			end
			if npc.FrameCount % 3 == 1 and not mod:isScareOrConfuse(npc) then
				if target.Position:Distance(npc.Position) < 100 then
					if sprite.FlipX then
						d.vec = Vector(1,-1)
					else
						d.vec = Vector(1,1)
					end
					d.vec = d.vec:Rotated(-30 + math.random(60))
					if math.abs(d.vec.X) > math.abs(d.vec.Y) then
						mod:spritePlay(sprite, "SplitHori")
					else
						mod:spritePlay(sprite, "SplitVert")
					end
				elseif target.Position:Distance(npc.Position) < 300 then
					local valcheck = 50
					if sprite.FlipX and ((target.Position.X > npc.Position.X + valcheck and target.Position.Y + valcheck < npc.Position.Y) or (target.Position.X + valcheck < npc.Position.X and target.Position.Y > npc.Position.Y + valcheck)) then
						d.vec = target.Position - npc.Position
						if math.abs(d.vec.X) > math.abs(d.vec.Y) then
							mod:spritePlay(sprite, "SplitHori")
						else
							mod:spritePlay(sprite, "SplitVert")
						end
					elseif (not sprite.FlipX) and ((target.Position.X + valcheck < npc.Position.X and target.Position.Y + valcheck < npc.Position.Y) or (target.Position.X > npc.Position.X + valcheck and target.Position.Y > npc.Position.Y + valcheck)) then
						d.vec = target.Position - npc.Position
						if math.abs(d.vec.X) > math.abs(d.vec.Y) then
							mod:spritePlay(sprite, "SplitHori")
						else
							mod:spritePlay(sprite, "SplitVert")
						end
					end
				end
			end
		end
		npc.Velocity = npc.Velocity * 0.96
	end
end

function mod:umbraColl(npc1, npc2)
	if npc1.SubType == 0 and npc2.Type == mod.FF.Umbra.ID and npc2.Variant == mod.FF.Umbra.Var and npc2.SubType == 0 and (not npc1:GetSprite():IsPlaying("Appear")) and (not npc2:GetSprite():IsPlaying("Appear")) then
		npc1.SubType = 1
		npc1.HitPoints = npc1.HitPoints + npc2.HitPoints
		if (npc2.Position.X > npc1.Position.X and npc2.Position.Y < npc1.Position.Y) or (npc2.Position.X < npc1.Position.X and npc2.Position.Y > npc1.Position.Y) then
			npc1:GetSprite().FlipX = true
		end
		mod:spritePlay(npc1:GetSprite(), "Combine")
		sfx:Play(SoundEffect.SOUND_GOOATTACH0, 0.3, 0, false, math.random(130,140)/100)
		for k = 0, 360, 45 do
			local vec = Vector(math.random(3,7),0):Rotated(k - 10 + math.random(20))
			local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc1.Position + vec:Resized(15), Vector(math.random(3,7),0):Rotated(k - 10 + math.random(20)), npc1):ToEffect()
			smoke.SpriteRotation = math.random(360)
			smoke.Color = Color(0,0,0,0.6,0,0,0)
			smoke.SpriteOffset = Vector(0, -16)
			smoke.RenderZOffset = 300
			smoke:Update()
		end
		local data = npc1:GetData()
		data.ES = 0 
		if data.eclipsespawned then
			data.ES = data.ES + 1
		end
		if npc2:GetData().eclipsespawned then
			data.ES = data.ES + 1
		end
		npc2:Remove()
	end
end

function mod:eclipseAI(npc, subt)
	local sprite = npc:GetSprite();
	local d = npc:GetData();
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()

	npc.Velocity = nilvector
	npc.RenderZOffset = -5000

	local maxSpawns = 6
	if subt > 0 then
		maxSpawns = subt
	end

	if not d.init then
		d.init = true
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		d.state = "open"
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if npc.FrameCount % 10 == 0 then
		for _,ClosePickup in ipairs(Isaac.FindInRadius(npc.Position, 1, EntityPartition.PICKUP)) do
			ClosePickup.Velocity = RandomVector()*2
		end
	end

	if d.state == "open" then
		if npc.FrameCount % 5 == 4 then
			local die = true
			if room:HasTriggerPressurePlates() then
				local size = room:GetGridSize()
				for i = 0, size - 1 do
					local gridEntity = room:GetGridEntity(i)
					if gridEntity then
						local desc = gridEntity.Desc.Type
						if gridEntity.Desc.Type == GridEntityType.GRID_PRESSURE_PLATE then
							if gridEntity:GetVariant() == 0 then
								if gridEntity.State ~= 3 then
									die = false
								end
							end
						end
					end
				end
			end
			for index,entity in ipairs(Isaac.GetRoomEntities()) do
				local hmm = (mod.dontpreventwaiting(entity) or entity:GetData().eclipsespawned)
				if hmm == false or hmm == nil then
					die = false
					break
				end
			end
			if die then
				d.state = "close"
			end
		end
		mod:spritePlay(sprite, "Pit")
		d.umbralSpawns = d.umbralSpawns or 0
		if (npc.StateFrame > 60 + (d.umbralSpawns * 10)) and math.random(5) == 1 then
			if (mod.GetEntityCount(mod.FF.UmbraNormal.ID, mod.FF.UmbraNormal.Var, mod.FF.UmbraNormal.Sub) + (mod.GetEntityCount(mod.FF.UmbraBlistered.ID, mod.FF.UmbraBlistered.Var, mod.FF.UmbraBlistered.Sub) * 2)) < maxSpawns then
				local boy = Isaac.Spawn(mod.FF.Umbra.ID, mod.FF.Umbra.Var, 0, npc.Position, nilvector, npc)
				boy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				boy:GetSprite():Play("Appear", true)
				boy:GetData().eclipsespawned = true
				boy:Update()
				npc.StateFrame = 0
				d.umbralSpawns = d.umbralSpawns + 1
			else
				d.umbralSpawns = d.umbralSpawns + 0.5 --Going to increment the spawn counter regardless to reduce punishment for lower DPS runs 
			end
		end
	elseif d.state == "close" then
		if sprite:IsFinished("PitClose") then
			local poof = Isaac.Spawn(1000,15,0, npc.Position, nilvector, npc):ToEffect()
			poof.Color = Color(0,0,0,1,0,0,0)
			poof:Update()
			npc:Remove()
		else
			mod:spritePlay(sprite, "PitClose")
		end
	end
end
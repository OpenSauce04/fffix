local mod = FiendFolio
local game = Game()

function mod:brisketAI(npc)
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	local data = npc:GetData()
	local room = game:GetRoom()
	local rand = npc:GetDropRNG()
	
	if not data.init then
		npc.SplatColor = Color(0,0,0,0.75,0.1,0.1,0.1)
		if npc.SubType == 1 then
			data.sprite = 1
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			npc.Visible = false
			data.rotation = 45
			Isaac.Spawn(1000, 15, 0, npc.Position, Vector.Zero, npc)
			data.state = "Appear"
		elseif npc.SubType == 0 then
			data.sprite = 0
			data.state = "Idle"
			data.rotation = 0
		elseif npc.SubType == 2 then
			data.sprite = rand:RandomInt(2)
			if data.sprite == 0 then
				data.state = "Idle"
				data.rotation = 0
			else
				data.state = "Appear"
				npc.Visible = false
				npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				data.rotation = 45
				Isaac.Spawn(1000, 15, 0, npc.Position, Vector.Zero, npc)
			end
		end
		data.attackSoon = 0
		data.attackLimit = 0
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
		data.attackLimit = data.attackLimit+1
	end
	
	if data.state == "Idle" then
		if data.attackSoon == 1 or data.attackLimit > 100 and not mod:isScareOrConfuse(npc) then
			data.state = "Attack"
		elseif npc.StateFrame > 45 then
			data.state = "Move"
			data.startMoving = false
		else
			mod:spritePlay(sprite, "Idle" .. data.sprite)
		end
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.4)
	elseif data.state == "Move" then
		if sprite:IsFinished("Move" .. data.sprite) then
			data.state = "Idle"
			npc.StateFrame = rand:RandomInt(25)-10
			data.attackSoon = rand:RandomInt(4)
		elseif sprite:IsEventTriggered("Move") then
			data.targetPosition = mod:FindRandomValidPathPosition(npc, 3, nil, 100)
			data.startMoving = true
			if (data.targetPosition-npc.Position).X > 0 then
				sprite.FlipX = false
			else
				sprite.FlipX = true
			end
		elseif sprite:IsEventTriggered("Shoot") then
			data.startMoving = false
		else
			mod:spritePlay(sprite, "Move" .. data.sprite)
		end
		
		if data.startMoving == false then
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.4)
		else
			if mod:isScare(npc) then
				npc.Velocity = mod:Lerp(npc.Velocity, (target.Position-npc.Position):Resized(-4), 0.4)
			else
				npc.Velocity = mod:Lerp(npc.Velocity, (data.targetPosition-npc.Position):Resized(4), 0.4)
			end
			if npc.FrameCount % 3 == 0 then
				local splat = Isaac.Spawn(1000, 7, 0, npc.Position, Vector.Zero, npc):ToEffect()
				splat.Color = Color(0,0,0,0.75,0.1,0.1,0.1)
				splat:Update()
			end
		end
	elseif data.state == "Attack" then
		if sprite:IsFinished("Attack" .. data.sprite) then
			data.state = "Idle"
			data.attackSoon = rand:RandomInt(6)
			data.attackLimit = 0
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH, 1, 0, false, math.random(75,90)/100)
			local params = ProjectileParams()
			params.FallingSpeedModifier = -0.1
			params.FallingAccelModifier = -0.165
			params.HeightModifier = 15
			params.Scale = 1.4
			for i=90,360,90 do
				npc:FireProjectiles(npc.Position, Vector(0,2.2):Rotated(i+data.rotation), 0, params)
			end
			local splat = Isaac.Spawn(1000, 2, 960, npc.Position, Vector.Zero, npc):ToEffect()
			splat.Color = Color(0,0,0,0.75,0.1,0.1,0.1)
			splat:Update()
			for i = -30, 30, 30 do
				local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position, Vector(0,-4.5):Rotated(i), npc):ToEffect()
				smoke.SpriteOffset = Vector(0, -15)
				smoke.DepthOffset = 45
				smoke:SetTimeout(20)
				smoke:Update()
			end
			for _, proj in pairs(Isaac.FindByType(9, 0, 0)) do
				if proj.FrameCount < 1 and proj.SpawnerType == npc.Type and proj.SpawnerVariant == npc.Variant then
					local pSprite = proj:GetSprite()
					pSprite:ReplaceSpritesheet(0, "gfx/projectiles/brisket_tear.png")
					pSprite:LoadGraphics()
					proj:GetData().customProjSplat = "gfx/projectiles/brisket_splat.png"
				end
			end
		else
			mod:spritePlay(sprite, "Attack" .. data.sprite)
		end
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.4)
	elseif data.state == "Appear" then
		if npc.FrameCount > 1 and npc.Visible == false then
			npc.Visible = true
		end
		if sprite:IsFinished("Appear1") then
			data.state = "Idle"
		else
			mod:spritePlay(sprite, "Appear1")
		end
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.4)
	end
	
	if npc:IsDead() then
		npc:PlaySound(SoundEffect.SOUND_BLACK_POOF, 0.4, 0, false, 1.6)
		for i = -30, 30, 30 do
			local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position, Vector(0,-10):Rotated(i), npc)
			smoke.SpriteOffset = Vector(0, -5)
			smoke:Update()
		end
		table.insert(mod.brisketPowder, {["npc"] = npc, ["pos"] = npc.Position, ["frameCount"] = 0, ["endDir"] = {}, ["rot"] = data.rotation})
	end
end

function mod:spreadBrisketSeasoning(entry)
	local room = game:GetRoom()
	local npc = entry.npc
	local pos = entry.pos
	local frameCount = entry.frameCount
	local barredDirections = entry.endDir
	local totalBarred = 0
	local rot = entry.rot
	
	for i=1,4 do
		if not barredDirections[i] then
			local powderPos = pos+Vector(0,20):Rotated(i*90+rot)*(frameCount/9)
			if room:GetGridCollisionAtPos(powderPos) == GridCollisionClass.COLLISION_NONE then
				if frameCount % 9 == 0 then
					--mod.SpawnGunpowder(npc, powderPos, 120, 30)
					local ash = Isaac.Spawn(1000, 26, 7001, powderPos, Vector.Zero, npc):ToEffect()
					ash.SpawnerEntity = npc
					local s = ash:GetSprite()
					s:Load("gfx/effects/1000.092_creep (ash).anm2",true)
					local rand = math.random(6)
					s:Play("SmallBlood0" .. rand,true)
					ash:SetTimeout(140)
					ash:GetData().burntime = 45
					ash.Scale = math.max(0.7, (130-frameCount)/100)
					ash:Update()
					local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, powderPos, Vector(0,-2):Rotated(math.random(360)), npc):ToEffect()
					smoke:SetTimeout(40)
					smoke:Update()
				end
			else
				barredDirections[i] = true
			end
		else
			totalBarred = totalBarred+1
		end
	end
	entry.frameCount = entry.frameCount+1
	if entry.frameCount > 120 or totalBarred == 4 or room:IsClear() then
		for i=1,4 do
			barredDirections[i] = true
		end
		entry = nil
	end
end
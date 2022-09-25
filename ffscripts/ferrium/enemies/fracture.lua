local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local boneColor = Color(1,1,1,1,0,0,0)
boneColor:SetColorize(217/255, 216/255, 215/255, 1)

function mod:fractureAI(npc)
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local sprite = npc:GetSprite()
	local rng = npc:GetDropRNG()
	local room = game:GetRoom()
	
	if not data.init then
		data.state = "Appear"
		npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		Isaac.Spawn(1000, 15, 0, npc.Position, Vector.Zero, npc)
		if npc.SubType == 2 then
			data.head = 3
		elseif npc.SubType == 1 then
			data.head = 2
			data.health2 = 20
		else
			data.head = 1
			data.health1 = 20
			data.health2 = 20
		end
		sprite:Play("Idle", true)
		sprite:Play("Appear" .. data.head, true)
		data.init = true
		data.frame = 1
		npc.Visible = false
	else
		npc.StateFrame = npc.StateFrame+1
	end

	if data.state == "Idle" then
		if npc.Velocity:Length() > 0.5 then
			npc:AnimWalkFrame("WalkHori","WalkVert",0)
		else
			mod:spritePlay(sprite, "Idle")
		end
		mod:spriteOverlayPlay(sprite, "IdleHead" .. data.head)
		
		if mod:isScare(npc) then
			local targetvel = (targetpos - npc.Position):Resized(-8)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
		elseif room:CheckLine(npc.Position, targetpos, 0, 1, false, false) then
			local targetvel = (targetpos - npc.Position):Resized(4)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
		else
			npc.Pathfinder:FindGridPath(targetpos, 0.51, 900, true)
		end
		
		if not mod:isScareOrConfuse(npc) and room:CheckLine(npc.Position, targetpos, 3, 1, false, false) then
			if npc.StateFrame > 25 and rng:RandomInt(50) == 1 then
				data.state = "Shoot"
				data.frame = 1
			elseif npc.StateFrame > 95 then
				data.state = "Shoot"
				data.frame = 1
			end
		end
	elseif data.state == "Shoot" then
		if npc.Velocity:Length() > 0.5 then
			npc:AnimWalkFrame("WalkHori","WalkVert",0)
		else
			mod:spritePlay(sprite, "Idle")
		end
		if mod:isScare(npc) then
			local targetvel = (targetpos - npc.Position):Resized(-5)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
		elseif room:CheckLine(npc.Position, targetpos, 0, 1, false, false) then
			local targetvel = (targetpos - npc.Position):Resized(2.5)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
		else
			npc.Pathfinder:FindGridPath(targetpos, 0.36, 900, true)
		end
		
		if data.frame > 27 then
			data.state = "Idle"
			npc.StateFrame = 0
			data.frame = 1
			data.shot = nil
		elseif sprite:GetOverlayFrame() == 16 and not data.shot then
			data.shot = true
			npc:PlaySound(SoundEffect.SOUND_BONE_HEART, 1, 0, false, 1.4)
			local params = ProjectileParams()
			params.Variant = 1
			if not npc:IsChampion() then
				params.Color = boneColor
			end
			if data.head == 1 then
				npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(13), 0, params)
			elseif data.head == 2 then
				for i=-12,12,24 do
					npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(11.5):Rotated(i), 0, params)
				end
			elseif data.head == 3 then
				for i=-26,26,52 do
					npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(11.5):Rotated(i), 0, params)
				end
				npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(10), 0, params)
				for i=1,6 do
					local particle = Isaac.Spawn(1000, 35, 0, npc.Position+mod:shuntedPosition(10), RandomVector()*math.random(1,6), nil)
					particle.Color = boneColor
				end
			end
		end
		sprite:SetOverlayFrame("Shoot" .. data.head, data.frame)
		data.frame = data.frame+1
	elseif data.state == "Appear" then
		npc.Velocity = Vector.Zero
		if data.frame > 16 then
			data.state = "Idle"
			npc.StateFrame = 0
		elseif data.frame > 3 then
			npc.Visible = true
		end
		sprite:SetOverlayFrame("Appear" .. data.head, data.frame)
		data.frame = data.frame+1
	end
end

function mod:fractureHurt(npc, damage, flag, source)
	local data = npc:GetData()
	if data.health1 then
		mod:applyFakeDamageFlash(npc)
		data.health1 = data.health1-damage
		if data.health1 <= 0 then
			data.head = 2
			data.health1 = nil
			npc:BloodExplode()
			sfx:Play(SoundEffect.SOUND_BONE_BREAK, 1, 0, false, 1)
			for i=1,6 do
				Isaac.Spawn(1000, 35, 0, npc.Position+mod:shuntedPosition(10), RandomVector()*math.random(1,6), nil)
			end
		end
		npc:ToNPC().StateFrame = 0
		return false
	elseif data.health2 then
		mod:applyFakeDamageFlash(npc)
		data.health2 = data.health2-damage
		if data.health2 <= 0 then
			local npc = npc:ToNPC()
			local rng = npc:GetDropRNG()
			data.head = 3
			data.health2 = nil
			npc:BloodExplode()
			sfx:Play(SoundEffect.SOUND_BONE_BREAK, 1, 0, false, 1)
			local params = ProjectileParams()
			params.Variant = 1
			if not npc:IsChampion() then
				params.Color = boneColor
			end
			--[[for i=90,360,90 do
				npc:FireProjectiles(npc.Position, Vector(0,7):Rotated(i), 0, params)
			end
			for i=45,315,90 do
				npc:FireProjectiles(npc.Position, Vector(0,10):Rotated(i), 0, params)
			end]]
			mod:SetGatheredProjectiles()
			for i=1,5 do
				local params = ProjectileParams()
				params.FallingSpeedModifier = mod:getRoll(-20,-10,rng)
				params.FallingAccelModifier = mod:getRoll(95,135,rng)/100
				params.Variant = 1
				npc:FireProjectiles(npc.Position, Vector(0,2+rng:RandomInt(2)):Rotated(rng:RandomInt(360)), 0, params)
			end
			for _, proj in pairs(mod:GetGatheredProjectiles()) do
				if math.random(2) == 1 then
					local sprite = proj:GetSprite()
					sprite:Load("gfx/002.030_black tooth tear.anm2", true)
					sprite:ReplaceSpritesheet(0, "gfx/projectiles/white_tooth.png")
					sprite:LoadGraphics()
					sprite:Play("Tooth2Move", false)
					proj:GetData().tooth = true
				end
			end
			for i=1,6 do
				local particle = Isaac.Spawn(1000, 35, 0, npc.Position+mod:shuntedPosition(10), RandomVector()*math.random(1,6), nil)
				particle.Color = boneColor
			end
		end
		npc:ToNPC().StateFrame = 0
		return false
	end
end
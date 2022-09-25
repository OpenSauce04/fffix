local mod = FiendFolio

function mod:wheezerAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local rand = npc:GetDropRNG()
	
	--[[if data.gasTier and npc.FrameCount % 20 == 0 then
		Isaac.ConsoleOutput("///   " .. data.gasTier .. "   ///")
	end]]

	if not data.init then
		npc.SplatColor = Color(0.1,0.4,0.2,1)
		data.state = "Idle"
		data.initPos = npc.Position
		data.spawnGas = true
		data.gasTier = 0
		data.shrinkHit = 0
		data.clearUp = -1
		if npc.SubType > 0 then
			data.gasMax = npc.SubType
		else
			data.gasMax = 5
		end
		data.randomRot = rand:RandomInt(360)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	if not data.isSpecturned then
		if not data.initPos then
			data.initPos = npc.Position
		end
		npc.Velocity = data.initPos-npc.Position
	else
		data.initPos = nil
	end
	
	if data.state == "Idle" then
		if data.flinch then
			npc:PlaySound(SoundEffect.SOUND_WHEEZY_COUGH, 1, 0 , false, 0.65)
			data.state = "Flinch"
			sprite:Play("FlinchStart")
		else
			if data.clearUp < 1 then
				mod:spritePlay(sprite, "Idle")
			else
				if sprite:IsFinished("FlinchStart") then
					sprite:Play("FlinchLoop")
				end
			end
		end
		
		if npc.StateFrame > 40+62*data.gasTier and data.gasTier < data.gasMax and data.clearUp < 1 then
			data.randomRot = rand:RandomInt(360)
			data.gasTier = data.gasTier+1
			npc.StateFrame = 0
			if data.gasTier < data.gasMax-1 then
				data.spawnGas = true
			end
		end
		
		if data.gasTier == data.gasMax and npc.StateFrame > 150 and data.gasMax > 2 then
			mod:spritePlay(sprite, "FlinchStart")
			data.clearUp = data.gasMax
			data.gasTier = 2
			npc.StateFrame = 0
		end
		if data.clearUp > 2 then
			if npc.FrameCount % 35 == 1 then
				npc:PlaySound(SoundEffect.SOUND_WHEEZY_COUGH, 1, 0 , false, (55+rand:RandomInt(20))/100)
				data.clearUp = data.clearUp-1
			end
		else
			data.clearUp = -1
		end
		if data.spawnGas == true then
			for i=0,(6+3*data.gasTier) do
				local gDir = Vector(0,1):Rotated(rand:RandomInt(10)+data.randomRot+i*360/(6+3*data.gasTier))*(90+rand:RandomInt(20))/100
				local gas = Isaac.Spawn(1000, 141, 0, npc.Position, gDir, npc):ToEffect()
				gas.Parent = npc
				local gData = gas:GetData()
				gData.gDir = gDir
				gData.gasTier = data.gasTier
			end
			data.spawnGas = false
		end
		
		if npc.FrameCount % 120 == 0 then
			npc:PlaySound(mod.Sounds.NimbusSigh, 4, 0, false, 0.5)
		elseif npc.FrameCount % 120 == 80 then
			npc:PlaySound(mod.Sounds.NimbusShoot, 0.5, 0, false, 0.8)
		end
	elseif data.state == "Flinch" then
		if sprite:IsFinished("FlinchStart") then
			sprite:Play("FlinchLoop")
		elseif sprite:IsFinished("Recover") then
			data.state = "Idle"
			data.flinch = nil
			if data.gasTier <= 0 then
				data.spawnGas = true
			end
			npc.StateFrame = 0
		end
		
		if data.flinchTimer > 0 then
			if data.shrink == true then
				
			end
			data.flinchTimer = data.flinchTimer-1
		else
			data.disappear = nil
			mod:spritePlay(sprite, "Recover")
		end
	end
end

function mod:wheezerHurt(npc, damage, flag, source)
	local data = npc:GetData()
	
	if not data.flinch then
		data.flinch = true
		data.shrinkHit = 2
		data.flinchTimer = 40
	end
	
	if data.shrinkHit == 2 or damage > 40 then
		if data.gasTier == nil then 
			data.gasTier = 0
		end
		data.disappear = data.gasTier
		if data.gasTier > 0 then
			data.gasTier = data.gasTier-1
		end
		data.shrinkHit = 0
	else
		data.shrinkHit = data.shrinkHit+1
	end
	data.flinchTimer = data.flinchTimer+8
	if data.flinchTimer > 60 then
		data.flinchTimer = 60
	end
end

function mod:checkGas(npc)
	local data = npc:GetData()
	if npc.Parent and npc.Parent.Type == mod.FF.Wheezer.ID and npc.Parent.Variant == mod.FF.Wheezer.Var then
		local pData = npc.Parent:GetData()
		if pData.gasTier == data.gasTier and not data.stopped then
			npc.Velocity = data.gDir
		else
			data.stopped = true
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.05)
		end
		
		if pData.disappear == data.gasTier or pData.clearUp == data.gasTier then
			npc.Parent = nil
		end
	elseif npc.Parent and mod:isStatusCorpse(npc.Parent) then
		npc.Parent = nil
	end
	
	if data.moveGasInfo then
		local tab = data.moveGasInfo
		if tab.vel then
			npc.Velocity = tab.vel
			if tab.accel then
				tab.vel = tab.vel*tab.accel
			end
		end
		
		if tab.timeout then
			if tab.timeout > 0 then
				tab.timeout = tab.timeout-1
			else
				npc.Parent = nil
			end
		end
		
		if tab.stopMovement then
			if tab.stopMovement > 0 then
				tab.stopMovement = tab.stopMovement-1
			else
				tab.vel = nil
				tab.stopMovement = nil
			end
		end
		
		if tab.grow then
			npc.SpriteScale = Vector(npc.SpriteScale.X+tab.grow, npc.SpriteScale.Y+tab.grow)
			if npc.SpriteScale.X >= tab.growLimit then
				tab.grow = nil
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.checkGas, 141)
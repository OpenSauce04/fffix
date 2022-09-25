local mod = FiendFolio
local game = Game()

function mod:zissuruRender(npc)
	if npc.Variant == mod.FF.Zissuru.Var then
		local rpos = Isaac.WorldToScreen(npc.Position)
		
		local data = npc:GetData()
		if data.saltActive and not data.finished then
			if not data.animated then
				data.auraSprite:Play("ZissAnim", true)
				data.animated = true
			end
			data.auraSprite:Render(rpos, Vector.Zero, Vector.Zero)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, mod.zissuruRender, mod.FFID.Ferrium)

function mod:zissuruAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local rand = npc:GetDropRNG()
	local room = game:GetRoom()
	
	if not data.init then
		data.findPos = npc.Position
		data.moveFrame = 0
		data.idleTime = rand:RandomInt(40)+10
		npc.StateFrame = 40
		data.state = "Idle"
		data.moveState = "Idle"
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
		data.moveFrame = data.moveFrame+1
	end
	
	if data.state == "Idle" then
		if npc.Velocity.X > 0 then
			sprite.FlipX = false
		else
			sprite.FlipX = true
		end
		
		if data.moveState == "Idle" then
			if data.moveFrame > data.idleTime and rand:RandomInt(4) == 1 then
				if npc.Position:Distance(target.Position) > 80 then
					data.findPos = mod:FindRandomValidPathPosition(npc, 3, nil, 120)
				else
					data.findPos = mod:FindRandomValidPathPosition(npc, 3, 80, 120)
				end
				data.moveState = "Moving"
				data.moveFrame = 0
			else
				mod:spritePlay(sprite, "Idle")
			end
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
			
			if npc.StateFrame > 100 and rand:RandomInt(10) == 1 and not mod:isScareOrConfuse(npc) then
				data.state = "Set Salt"
				sprite:Play("SetSalt")
				npc:PlaySound(SoundEffect.SOUND_DERP, 0.8, 0, false, 0.55+math.random(10)/100)
				npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
				npc.StateFrame = 0
			elseif npc.StateFrame > 140 and not mod:isScareOrConfuse(npc) then
				data.state = "Set Salt"
				sprite:Play("SetSalt")
				npc:PlaySound(SoundEffect.SOUND_DERP, 0.8, 0, false, 0.55+math.random(10)/100)
				npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
				npc.StateFrame = 0
			end
		elseif data.moveState == "Moving" then
			if npc.Position:Distance(data.findPos) < 20 or data.moveFrame > 30 then
				data.moveState = "Idle"
				data.idleTime = rand:RandomInt(40)+10
				data.moveFrame = 0
			else
				mod:spritePlay(sprite, "Walk")
			end
			if sprite:IsEventTriggered("Sound") then
				npc:PlaySound(SoundEffect.SOUND_BIRD_FLAP, 0.2, 0, false, 2.2)
			end
			npc.Velocity = mod:Lerp(npc.Velocity, (data.findPos-npc.Position):Resized(3), 0.1)
		end
	elseif data.state == "Set Salt" then
		if npc.StateFrame < 41 then
			local rotMod = -1
			if sprite.FlipX == true then
				rotMod = 1
			end
			local salt = Isaac.Spawn(1000, 92, 114, npc.Position, Vector(0,18):Rotated(rotMod*npc.StateFrame*9), npc):ToEffect()
			salt.Color = Color(1, 1, 1, 1, 0.5, 0.5, 0.5)
			salt.Parent = npc
			salt:SetTimeout(130-npc.StateFrame)
			salt:Update()
		end
		
		if npc.StateFrame > 30 and not data.saltActive == true then
			data.animated = nil
			data.auraSprite = Sprite()
			data.auraSprite:Load("gfx/enemies/zissuru/zissAura.anm2", true)
			data.auraSprite:Play("ZissAnim", true)
			
			data.saltActive = true
			data.tableNum = #mod.activeZissurus+1
			mod.activeZissurus[data.tableNum] = {npc.Position, game:GetFrameCount()}
		end
		
		if sprite:IsFinished("SetSalt") then
			data.state = "Salt Idle"
			npc.StateFrame = 0
		end
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.4)
	elseif data.state == "Salt Idle" then
		if npc.StateFrame > 50 then
			data.state = "Attack"
			sprite:Play("Attack")
		else
			mod:spritePlay(sprite, "Idle")
		end
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.4)
	elseif data.state == "Attack" then
		if sprite:IsFinished("Attack") then
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
			data.saltActive = false
			mod.activeZissurus[data.tableNum] = nil
			data.state = "Idle"
			data.moveState = "Idle"
			data.moveFrame = 0
			data.idleTime = rand:RandomInt(40)+10
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_DEATH_CARD, 1, 0, false, 1)
			npc:PlaySound(SoundEffect.SOUND_MONSTER_ROAR_2, 0.8, 0, false, 0.8)
			mod:zissuruRitual(npc, target, game:GetFrameCount())
		end
	end
	
	if data.saltActive == true then
		data.auraSprite:Update()
	end
end

function mod:zissuruRitual(npc, target, frameCount)
	if target.Type == 1 then
		for _, player in ipairs(Isaac.FindByType(1, -1, -1, false, false)) do
			player = player:ToPlayer()
			local safe = false
			for _, ziss in ipairs(Isaac.FindByType(mod.FFID.Ferrium, mod.FF.Zissuru.Var, -1, false, false)) do
				if player.Position:Distance(ziss.Position) < 90 and ziss:GetData().saltActive == true then
					safe = true
				end
			end
			
			for i=1,#mod.activeZissurus do
				if mod.activeZissurus[i] ~= nil then
					if frameCount-mod.activeZissurus[i][2] < 180 then
						if player.Position:Distance(mod.activeZissurus[i][1]) < 90 then
							safe = true
						end
					else
						mod.activeZissurus[i] = nil
					end
				end
			end
			
			if safe == false then
				player:TakeDamage(1, 0, EntityRef(npc), 30)
			end
		end
	else
		for _,enemy in ipairs(Isaac.FindInRadius(target.Position, 1000, EntityPartition.ENEMY)) do
			if enemy.Type ~= 292 then
				local safe = false
				for _, ziss in ipairs(Isaac.FindByType(mod.FFID.Ferrium, mod.FF.Zissuru.Var, -1, false, false)) do
					if enemy.Position:Distance(ziss.Position) < 90 and ziss:GetData().saltActive == true then
						safe = true
					end
				end
				if safe == false then
					enemy:TakeDamage(30, 0, EntityRef(npc), 0)
				end
			end
		end
	end
end

function mod:zissuruSalt(e)
	if e.SubType == 114 then
		local d = e:GetData()
		e.Velocity = e.Velocity*0.8
		
		if e.Parent and e.Parent:Exists() and not mod:isStatusCorpse(e.Parent) then
			--Isaac.ConsoleOutput("///Distance is: " .. e.Position:Distance(e.Parent.Position) .. " :)   ///")
			--local pData = e.Parent:GetData()
			if not d.attacked then
				e:SetTimeout(40)
			end
			if e.Parent:GetSprite():IsEventTriggered("Shoot") then
				d.blacken = 125
				d.attacked = true
			end
		elseif not d.remove then
			e:SetTimeout(1)
			d.remove = true
		end
		
		if d.attacked then
			e.Color = Color((d.blacken+130)/255, (d.blacken+130)/255, (d.blacken+130)/255, (224+d.blacken/4)/255, d.blacken/255, d.blacken/255, d.blacken/255)
			d.blacken = mod:Lerp(d.blacken, 0, 0.3)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.zissuruSalt, 92)
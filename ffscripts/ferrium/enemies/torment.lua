local mod = FiendFolio
local game = Game()

function mod:tormentAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local rand = npc:GetDropRNG()
	
	if not data.init then
		npc.SplatColor = Color(0.1,0.4,0.2,1)
		data.attackList = {
			{"Cyst", 0},
			{"Creep", 0},
			{"Gaper", 0},
		}
		if npc:IsChampion() and npc.SubType > 0 then
			npc:Morph(mod.FFID.Ferrium, mod.FF.AntiGolem.Var, npc.SubType, -1)
			npc:Morph(mod.FFID.Ferrium, mod.FF.Torment.Var, npc.SubType, -1)
			npc.HitPoints = 84
		end
		if npc.SubType == 0 then
			data.state = "Idle"
			npc.StateFrame = 30
		elseif npc.SubType == 100 then
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			data.state = "SpawnGaper"
		elseif npc.SubType > 0 and npc.SubType < 50 and not data.waited then
			mod.makeWaitFerr(npc, mod.FFID.Ferrium, npc.Variant, npc.SubType, 80)
		elseif data.waited then
			data.state = "Waiting"
			npc.Visible = false
		end
		data.initPos = npc.Position
		data.shootCreep = 0
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
		if npc.StateFrame > 75 and npc.StateFrame < 110 and rand:RandomInt(10) == 1 and not mod:isScareOrConfuse(npc) then
			if data.lastAttack == nil or data.lastAttack == 2 then
				data.state = mod.ChooseNextAttack(data.attackList, rand)
				npc.StateFrame = 0
			else
				data.state = "Creep"
				npc.StateFrame = 0
			end
		elseif npc.StateFrame > 110 and not mod:isScareOrConfuse(npc) then
			if data.lastAttack == nil or data.lastAttack == 2 then
				data.state = mod.ChooseNextAttack(data.attackList, rand)
				npc.StateFrame = 0
			else
				data.state = "Creep"
				npc.StateFrame = 0
			end
		end
		mod:spritePlay(sprite, "Idle")
	elseif data.state == "Cyst" then
		if sprite:IsFinished("Attack01") then
			data.state = "Idle"
			data.lastAttack = 1
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Sound") then
			npc:PlaySound(SoundEffect.SOUND_MONSTER_ROAR_3, 0.8, 0, false, 1)
			npc:PlaySound(SoundEffect.SOUND_GRROOWL, 0.8, 0, false, 1)
		elseif sprite:IsEventTriggered("Spawn") then
			npc:PlaySound(SoundEffect.SOUND_DEATH_BURST_LARGE, 1, 0, false, 0.9)
			local spawn = Isaac.Spawn(862, 0, 4, npc.Position+Vector(0,10), Vector(0,10), npc):ToNPC()
			spawn:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			for i=0,4 do
				local gibs = Isaac.Spawn(1000, 5, 0, npc.Position, Vector(0,3):Rotated(math.random(-20,20)), npc):ToEffect()
				gibs.Color = Color(0.1,0.4,0.2,1)
			end
		else
			mod:spritePlay(sprite, "Attack01")
		end
	elseif data.state == "Creep" then
		if sprite:IsFinished("Attack02") then
			data.state = "Idle"
			data.lastAttack = 2
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_GHOST_ROAR, 1, 0, false, 0.9)
			data.shootCreep = 8
			data.shootDir = (target.Position-npc.Position)
		elseif sprite:IsEventTriggered("Sound") then
			npc:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, 0.75, 0, false, 0.82)
		else
			mod:spritePlay(sprite, "Attack02")
		end
		
		if data.shootCreep > 0 then
			local params = ProjectileParams()
			params.BulletFlags = params.BulletFlags | ProjectileFlags.RED_CREEP
			params.FallingAccelModifier = (5+rand:RandomInt(4))/8
			params.FallingSpeedModifier = -(2+rand:RandomInt(6)/2)
			params.Scale = (5+rand:RandomInt(10))/15
			for i=0,2 do
				npc:FireProjectiles(npc.Position+Vector(0,-10), data.shootDir:Resized(data.shootCreep*(rand:RandomInt(2)+2)):Rotated(-10+rand:RandomInt(20)), 0, params)
			end
			data.shootCreep = data.shootCreep-1
		end
	elseif data.state == "Gaper" then
		if sprite:IsFinished("Submerge") then
			mod:tormentGaperSpawn(npc, target, rand)
			data.state = "GaperWaiting"
		elseif sprite:IsEventTriggered("Hide") then
			npc:PlaySound(SoundEffect.SOUND_MAGGOT_ENTER_GROUND, 1, 0, false, 1)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc.Visible = false
		else
			mod:spritePlay(sprite, "Submerge")
		end
	elseif data.state == "GaperWaiting" then
		if sprite:IsFinished("Emerge") then
			data.state = "Idle"
			npc.StateFrame = 0
			data.lastAttack = 3
		elseif sprite:IsEventTriggered("Emerge") then
			npc:PlaySound(SoundEffect.SOUND_MAGGOT_BURST_OUT, 0.6, 0, false, 1)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		elseif data.gaperSpawn > 1 then
			npc.Visible = true
			mod:spritePlay(sprite, "Emerge")
		end
	elseif data.state == "SpawnGaper" then
		if npc.SubType == 100 then
			if not data.originalSpawner:Exists() then
				npc:Kill()
			end
		
			if sprite:IsFinished("Attack03") then
				npc:Remove()
				data.originalSpawner:GetData().gaperSpawn = data.originalSpawner:GetData().gaperSpawn+1
			elseif sprite:IsEventTriggered("Spawn") then
				npc:PlaySound(SoundEffect.SOUND_MAGGOT_BURST_OUT, 0.6, 0, false, 1)
				mod.throwShit(npc.Position, Vector(0,1):Rotated(rand:RandomInt(360)), 10, -(3+rand:RandomInt(3)), npc, "rottenGaper")
			else
				mod:spritePlay(sprite, "Attack03")
			end
		else
			if sprite:IsFinished("Attack03") then
				npc:Remove()
			elseif sprite:IsEventTriggered("Spawn") then
				npc:PlaySound(SoundEffect.SOUND_MAGGOT_BURST_OUT, 0.6, 0, false, 1)
				mod.throwShit(npc.Position, Vector(0,1):Rotated(rand:RandomInt(360)), 10, -(3+rand:RandomInt(3)), npc, "rottenGaper", npc.SubType-2)
			else
				mod:spritePlay(sprite, "Attack03")
			end
		end
	elseif data.state == "Waiting" then
		mod:spritePlay(sprite, "superHidden")
		if npc.SubType > 1 then
			npc.Visible = true
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
			data.state = "SpawnGaper"
			mod:spritePlay(sprite, "Attack03")
			if math.random(2) == 1 then
				sprite.FlipX = true
			end
		else
			npc.Visible = true
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
			mod:spritePlay(sprite, "Emerge")
			data.state = "Extra State for the Emerge Animation"
		end
	elseif data.state == "Extra State for the Emerge Animation" then
		if sprite:IsFinished("Emerge") then
			data.state = "Idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Emerge") then
			npc:PlaySound(SoundEffect.SOUND_MAGGOT_BURST_OUT, 0.6, 0, false, 1)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		else
			mod:spritePlay(sprite, "Emerge")
		end
	end
end

function mod:tormentGaperSpawn(npc, target, rand)
	local room = game:GetRoom()
	local size = room:GetGridSize()
	local validPositions = {}
	
	for i=0, size do
		local gridpos = room:GetGridPosition(i)
		local gridEntity = room:GetGridEntity(i)
		if room:GetGridCollisionAtPos(gridpos) == GridCollisionClass.COLLISION_NONE and room:IsPositionInRoom(gridpos, 0) then
			local testPath = Isaac.Spawn(mod.FFID.Ferrium, 5, 0, gridpos, Vector.Zero, nil):ToNPC()
			testPath.Visible = false
			testPath:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			testPath.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			testPath:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
			if testPath.Pathfinder:HasPathToPos(target.Position, false) then
				if (target.Position + (target.Velocity * 3)):Distance(gridpos) > 60 then
					table.insert(validPositions, gridpos)
				end
			end
			testPath:Remove()
		end
	end
	
	if #validPositions > 1 then
		for i=0,1 do
			local tableNum = rand:RandomInt(#validPositions)+1
			local spawn = Isaac.Spawn(mod.FFID.Ferrium, 20, 100, validPositions[tableNum], Vector.Zero, npc):ToNPC()
			spawn:GetData().originalSpawner = npc
			if i == 1 then
				spawn:GetSprite().FlipX = true
			end
			table.remove(validPositions, tableNum)
		end
		npc:GetData().gaperSpawn = 0
	elseif #validPositions == 1 then
		local spawn = Isaac.Spawn(mod.FFID.Ferrium, 20, 100, validPositions[1], Vector.Zero, npc):ToNPC()
		spawn:GetData().originalSpawner = npc
		npc:GetData().gaperSpawn = 1
	end
end
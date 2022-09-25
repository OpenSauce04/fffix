local mod = FiendFolio

function mod:bellowAI(npc)
	local data = npc:GetData()
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)

	if not data.init then
		data.state = "Idle"
		data.bellowSpawnCount = 0
		data.bellowSpawnTimer = 40
		data.feartimer = 0
		data.init = true
	end

	if data.state == "Idle" then
		local bellowTarget = mod.bellowMovement(npc.Position)
		mod:spritePlay(sprite, "Walk")
		--Movement, tries to stick close by other enemies.
		if data.feartimer > 0 then
			local targetVel = (targetpos - npc.Position):Resized(-2)
			npc.Velocity = mod:Lerp(npc.Velocity, targetVel, 0.3)
			data.feartimer = data.feartimer-1
		elseif npc.Position:Distance(target.Position) < 120 or mod:isScare(npc) then
			data.feartimer = 50
		elseif bellowTarget then
			if npc.Position:Distance(bellowTarget.Position) > 60 then
				local targetVel = (bellowTarget.Position - npc.Position):Resized(1.5)
				npc.Velocity = mod:Lerp(npc.Velocity, targetVel, 0.3)
			else
				if npc.StateFrame % 40 == 0 then
					local targetPos = mod:FindRandomFreePosAir(target.Position, 120)
					data.targetVel = (targetPos - npc.Position):Resized(1)
				end
				npc.Velocity = mod:Lerp(npc.Velocity, data.targetVel, 0.1)
			end
		else
			local targetVel = (targetpos - npc.Position):Resized(0.8)
			npc.Velocity = mod:Lerp(npc.Velocity, targetVel, 0.3)
		end

		if data.bellowSpawnTimer <= 0 and not mod:isScareOrConfuse(npc) then
			local willowCount = 0
			for _, enemy in pairs(Isaac.FindByType(838, 0, 0, false, false)) do
				if enemy.Parent and not enemy:IsDead() then
					if enemy.Parent.InitSeed == npc.InitSeed then
						willowCount = willowCount+1
					end
				end
			end
			if willowCount < 3 then
				data.state = "Spawn"
				data.spawnWillos = math.min(2, 3-willowCount)
			end
		else
			data.bellowSpawnTimer = data.bellowSpawnTimer-1
		end
	elseif data.state == "Spawn" then
		if sprite:IsEventTriggered("Shoot") then
			local poofy = Isaac.Spawn(1000, 16, 5, npc.Position, Vector.Zero, npc):ToEffect()
			poofy.SpriteScale = Vector(0.5,0.5)
			poofy.Color = Color(12,9,0.3,1,0,0,0) -- I dnot't understn colors pleas lhp
			poofy:Update()
			for i=0,data.spawnWillos-1 do
				local vel = Vector(0,2)
				if data.spawnWillos == 2 then
					vel = vel:Rotated(-45+90*i)
				elseif data.spawnWillos == 3 then
					vel = vel:Rotated(-30+30*i)
				end
				local william = Isaac.Spawn(838, 0, 0, (npc.Position+Vector(0,3)), vel, npc):ToNPC()
				william:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				william.HitPoints = 5
				william.Scale = 0.7
				william.Parent = npc
			end
			npc.Velocity = npc.Velocity+Vector(0,-3)
			data.bellowSpawnCount = data.bellowSpawnCount+1
			npc:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, 1, 0, false, 1)
		elseif sprite:IsFinished("Attack01") then
			data.bellowSpawnTimer = math.min(350, 100+data.bellowSpawnCount*55)
			data.state = "Idle"
		else
			mod:spritePlay(sprite, "Attack01")
		end
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.1)
	end
end

--[[mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_,npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	npc.V1 = Vector(10,-10)
end, 838)]]

mod.bellowBlacklist = {
{811,0}, -- Deep Gapers (so they don't flock around submerged areas)
{808,0}, -- Willos
{838,0}, -- Level 2 Willos
{130,60}, -- Glass Eyes
{160,1160}, -- Deathanies
{114,4}, -- Bellows
{160,451}, -- Eternal Flickerspirits
{130,30}, -- Viscerspirits
{42,0}, -- Grimaces
{202,0}, -- Constant Stone Shooters
{202,10}, -- Cross Shooters
{202,11}, -- Cross Shooters
}

function mod.bellowMovement(position)
	local target = nil
	local radius = 99999
	for _,entity in ipairs(Isaac.GetRoomEntities()) do
		if entity:IsActiveEnemy() and not mod:isFriend(entity) then
			local blacklisted = false
			for _, check in ipairs(mod.bellowBlacklist) do
				if check[1] == entity.Type and check[2] == entity.Variant then
					blacklisted = true
				end
			end
			if not blacklisted then
				local distance = position:Distance(entity.Position)
				if distance < radius then
					radius = distance
					target = entity
				end
			end
		end
	end
	return target
end
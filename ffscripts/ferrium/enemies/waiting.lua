local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

mod.extraWaitingVanilla = {
	[1] = {816, 0, 0, 40}, --Polty
	[2] = {881, 0, 0, -10}, --Needle
	[3] = {881, 1, 0, -10}, --Pasty
	[4] = {34, 0, 0, 100}, --Leaper
	[5] = {34, 1, 0, 50}, --Sticky Leaper
	[6] = {311, 0, 0, 50}, --Mr. Mine
	[7] = {829, 0, 0, 60}, --Mole
	[8] = {829, 450, 0, 60}, --Blasted
	[9] = {219, 0, 0, 50}, --Wizoob
	[10] = {285, 0, 0, 50}, --Red Ghost
	[11] = {825, 0, 0, 50}, --Fire Worm
	[12] = {307, 0, 0, 50}, --Tar Boy
	[13] = {816, 1, 0, 50}, --Kineti
	[14] = {882, 0, 0, 50}, --Dust
	[15] = {854, 0, 0, 100}, --Adult Leech
	[16] = {209, 0, 0, 100}, --Fat Sack
}

function mod:ferrWaiting(npc)
	local data = npc:GetData()
	local room = game:GetRoom()
	npc.StateFrame = npc.StateFrame+1
	
	if not data.init then
		if npc.SubType == 1 then
			local rock = Isaac.GridSpawn(6, 0, npc.Position, true)
			data.gridIndex = room:GetGridIndex(npc.Position)
			mod:UpdateRocks()
		elseif npc.SubType == 6 or npc.SubType == 11 then
			local pit = Isaac.GridSpawn(7, 0, npc.Position, true)
			data.gridIndex = room:GetGridIndex(npc.Position)
			mod:UpdatePits()
		end
	
		if npc.SubType > 0 then
			local result = mod.extraWaitingVanilla[npc.SubType]
			data.specialOrders = true
			data.id = result[1]
			data.var = result[2]
			data.subt = result[3]
			data.pos = npc.Position
			data.dist = result[4]
			
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_TARGET)
			npc.Visible = false
		else
			if not data.id then
				npc:Remove()
			end
		end
		data.init = true
	end
	
	if npc:GetData().removeThisOne == true then
		npc:Remove()
	end
	
	if data.specialOrders then
		if mod:CanIComeOutYet() then
			if npc.StateFrame > 15 then
				if mod.farFromAllPlayers(npc.Position, data.dist) then
					local enemy = Isaac.Spawn(data.id, data.var, data.subt, data.pos, Vector.Zero, nil):ToNPC()
					enemy:GetData().waited = true
					enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					enemy.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					local sprite = enemy:GetSprite()
					
					if npc.SubType == 1 then
						enemy.State = 2
						sprite:Play("PotAppear", true)
						
						if room:GetGridCollision(data.gridIndex) == GridCollisionClass.COLLISION_NONE then
							enemy:Remove()
						end
					elseif npc.SubType == 6 or npc.SubType == 11 then
						if npc.SubType == 11 then
							enemy:Update()
							enemy.State = 6
						end
					
						if room:GetGridCollision(data.gridIndex) == GridCollisionClass.COLLISION_NONE then
							enemy:Remove()
						end
					elseif npc.SubType == 4 or npc.SubType == 5 or npc.SubType == 15 or npc.SubType == 16 then
						if npc.SubType == 15 then
							sfx:Play(SoundEffect.SOUND_LEECH, 1, 0, false, 0.7)
						end
						enemy.State = 16
						enemy.TargetPosition = data.pos
					elseif npc.SubType == 12 then
						enemy.TargetPosition = data.pos
						enemy.State = 6
						sprite:Play("TeleportEnd", true)
					elseif npc.SubType == 13 then
						enemy.State = 2
						sprite:Play("SpecialAppear", true)
					end
					enemy:Update()
					npc:Remove()
				end
			end
		else
			npc.StateFrame = 0
		end
	else
		if mod:CanIComeOutYet() then
			if npc.StateFrame > 15 then
				if mod.farFromAllPlayers(npc.Position, data.dist) then
					local enemy = Isaac.Spawn(data.id, data.var, data.subt, data.pos, Vector.Zero, nil)
					enemy:GetData().waited = true
					enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					enemy.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					if data.passWaitingInfo then
						enemy:GetData().passWaitingInfo = data.passWaitingInfo
					end
					if data.visible == false then
						enemy.Visible = false
					end
					npc:Remove()
				end
			end
		else
			npc.StateFrame = 0
		end
	end
end

function mod.makeWaitFerr(npc, id, var, subt, dist, visible)
	local waitEnt = Isaac.Spawn(mod.FFID.Ferrium, mod.FF.FerrWaiting.Var, 0, npc.Position, Vector.Zero, npc):ToNPC()
	local data = waitEnt:GetData()
	data.id = id
	data.var = var
	data.subt = subt
	data.dist = dist or 80
	data.pos = npc.Position
	data.passWaitingInfo = npc:GetData().passWaitingInfo
	data.IsFerrWaiting = true
	waitEnt:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	waitEnt.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	waitEnt:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_TARGET)
	waitEnt.Visible = false
	if visible == nil then
		data.visible = true
	else
		data.visible = visible
	end
	npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	npc:Morph(mod.FFID.Ferrium, mod.FF.FerrWaiting.Var, 0, -1)
	npc:GetData().removeThisOne = true
end



--SPECIAL CASES

function mod:waitingPoltyBuckets(npc)
	if npc:GetData().waited then
		if npc.Variant == 0 then
			if npc.State == 3 then
				npc.State = 9
				npc:GetData().waited = nil
				npc:Update()
			end
		elseif npc.Variant == 1 then
			if npc.State == 3 then
				npc.State = 13
				npc:GetData().waited = nil
				npc:Update()
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.waitingPoltyBuckets, 816)

function mod:waitingLeapers(npc)
	if npc:GetData().waited then
		local sprite = npc:GetSprite()
		if npc.Variant == 1 then
			npc.SplatColor = mod.ColorDankBlackReal
		end
		if npc.State ~= 16 then
			npc.State = 16
		end
		if npc.State == 16 then
			if sprite:IsFinished("BigJumpDown") then
				npc.State = 3
				npc:GetData().waited = nil
			elseif sprite:IsEventTriggered("Land") then
				sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS, 1, 0, false, 1)
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			else
				mod:spritePlay(sprite, "BigJumpDown")
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.waitingLeapers, 34)

function mod:waitingAdultLeech(npc)
	if npc:GetData().waited then
		local sprite = npc:GetSprite()
		if npc.State ~= 16 then
			npc.State = 16
		end
		if npc.State == 16 then
			if sprite:IsFinished("ChargeDown") then
				npc.State = 3
				npc:GetData().waited = nil
			elseif sprite:IsEventTriggered("Hit") then
				sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 1, 0, false, 1)
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			elseif sprite:IsEventTriggered("Sound") then
				sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
			else
				mod:spritePlay(sprite, "ChargeDown")
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.waitingAdultLeech, 854)

function mod:waitingFatSacks(npc)
	if npc:GetData().waited then
		local sprite = npc:GetSprite()
		if npc.State ~= 16 then
			npc.State = 16
		end
		if npc.State == 16 then
			if sprite:IsFinished("Land") then
				npc.State = 4
				npc:GetData().waited = nil
			elseif sprite:IsEventTriggered("Splash") then
				sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS, 1, 0, false, 1)
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			else
				mod:spritePlay(sprite, "Land")
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.waitingFatSacks, 209)
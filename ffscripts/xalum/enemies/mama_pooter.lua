local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function FiendFolio.mamaPooterDeathAnim(npc)
	FiendFolio.genericCustomDeathAnim(npc, "death", nil, nil)
end

function FiendFolio.mamaPooterDeathEffect(npc)
	--sorry im redoing a lot of this i just really wanted to tinker with what was spawned
	--[[for i = 1, 1 + math.ceil(math.random() - 0.5) do
		local maggot = Isaac.Spawn(21, 750, 0, npc.Position, Vector.Zero, npc):ToNPC()
		maggot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	end
	for i = 1, 1 + math.ceil(math.random() - 0.5) do
		local fly = Isaac.Spawn(18, 0, 0, npc.Position, Vector.Zero, npc):ToNPC()
		fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	end
	if math.ceil(math.random() - 0.5) == 1 then
		local poot = Isaac.Spawn(14, 1, 0, npc.Position, Vector.Zero, npc):ToNPC()
		poot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	end]]--
	--spawn 1 maggot. 2 is wAY too much, but none would be wierd
	local maggot = Isaac.Spawn(21, 750, 0, npc.Position, Vector.Zero, npc):ToNPC()
	maggot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	--spawn 1 pooter
	local poot = Isaac.Spawn(14, 0, 0, npc.Position, Vector.Zero, npc):ToNPC()
	poot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	--spawn some random pooters
	local randompoottable = {0, 1, 1, 1, 2}
	local randompoot = randompoottable[math.random(1,5)]
	if randompoot > 0 then
		for i = 1, randompoot do
			poot = Isaac.Spawn(14, math.random(0, 1), 0, npc.Position, Vector.Zero, npc):ToNPC()
			poot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		end
	end
	--and a swarm of flies
	local randomflytable = {1, 2, 2, 2, 2, 2, 3, 3, 4}
	local randomflytypetable = {13, 18, 18, 18}
	local randomfly = randomflytable[math.random(1,6)]
	if randomfly > 0 then
		for i = 1, randomfly do
			poot = Isaac.Spawn(randomflytypetable[math.random(1,4)], math.random(0, 1), 0, npc.Position, Vector.Zero, npc):ToNPC()
			poot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		end
	end
	--get some creep on!
	local creep = Isaac.Spawn(1000, 23, 0, npc.Position + Vector(0, 15), Vector.Zero, npc)
	creep:SetColor(Color(0, 0, 0, 1, 99 / 255, 56 / 255, 74 / 255), 60, 99999, true, false)
	creep.Size = creep.Size * 2
	creep:GetSprite().Scale = creep:GetSprite().Scale * 2
end

return {
	AI = function(npc, data, sprite) -- This one has been redone too but again idk by who to I can't credit
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		npc.Velocity = Vector.Zero
		mod.QuickSetEntityGridPath(npc)

		if not data.spawnchances then
			data.spawnchances = {"givebirth", "givebirth", "spitball", "spitball", "spitball"}
			data.spawntimer = math.random(2,4)
			data.shoottimer = math.random(1,2)
			npc.Mass = 99
			if sprite:GetAnimation() ~= "death" then
				sprite:Play("idle", false)
			end
		end

		--get number and limit of maggots: 2 maggots per mama!
		local maggotlimit = 0
		local maggotnumber = 0
		for _, entity in ipairs(Isaac.GetRoomEntities()) do
			local etype = entity.Type
			local evar = entity.Variant
			if etype == 21 and evar == 750 then
				maggotnumber = maggotnumber + 1
			end
			if etype == 750 and evar == 50 then
				maggotlimit = maggotlimit + 2
			end
		end

		if sprite:IsFinished("givebirth") or sprite:IsFinished("spitball") then
			sprite:Play("idle", false)
		end

		--[[if sprite:IsPlaying("idle") and not (npc:HasEntityFlags(EntityFlag.FLAG_FEAR) or npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION)) then
			if npc.FrameCount % 4 == 0 and math.random(20) == math.random(20) then
				local angletotarget = (npc:GetPlayerTarget().Position - npc.Position):GetAngleDegrees()
				local firingangle = Vector(0, 10):GetAngleDegrees()
				if math.abs(firingangle - angletotarget) > 45 then
					if npc.FrameCount % 12 == 0 then
						sprite:Play("givebirth", false)
					end
				else
					sprite:Play(data.spawnchances[math.random(#data.spawnchances)], false)
				end
			end
		end]]--
		--redoing this function so that 1. there can be a limit on the num of maggots and 2. it only does an action when on the final frame of idle (for extra smoothness)
		if sprite:IsPlaying("idle") then
			if sprite:GetFrame() > 42 and not FiendFolio:isScareOrConfuse(npc) then
				data.shoottimer = data.shoottimer - 1
				local angletotarget = (npc:GetPlayerTarget().Position - npc.Position):GetAngleDegrees()
				local firingangle = Vector(0, 10):GetAngleDegrees()
				if data.shoottimer <= 0 and math.abs(firingangle - angletotarget) < 45 then
					sprite:Play("spitball", false)
					data.shoottimer = math.random(2,3)
				elseif maggotnumber < maggotlimit then
					data.spawntimer = data.spawntimer - 1
					if data.spawntimer <= 0 then
						sprite:Play("givebirth", false)
						data.spawntimer = math.random(3,4) + maggotnumber
					end
				end
			end
		end

		if sprite:IsEventTriggered("birth") then
			sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.85, 0, false, 1)
			local maggot = Isaac.Spawn(21, 750, 0, npc.Position + Vector(0, 15), Vector.Zero, npc)
			maggot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			local creep = Isaac.Spawn(1000, 23, 0, npc.Position + Vector(0, 15), Vector.Zero, npc)
			creep:SetColor(Color(0, 0, 0, 1, 99 / 255, 56 / 255, 74 / 255), 60, 99999, true, false)
			creep.Size = creep.Size * 2
			creep:GetSprite().Scale = creep:GetSprite().Scale * 2
			creep = Isaac.Spawn(1000, 23, 0, npc.Position + Vector(0, 40), Vector.Zero, npc)
			creep:SetColor(Color(0, 0, 0, 1, 99 / 255, 56 / 255, 74 / 255), 60, 99999, true, false)
		end

		if sprite:IsEventTriggered("shootball") then
			sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.5, 0, false, 1.2)
			local angletotarget = (npc:GetPlayerTarget().Position - npc.Position):GetAngleDegrees()
			local firingangle = Vector(0, 10):GetAngleDegrees()
			if math.abs(firingangle - angletotarget) <= 45 then
				firingangle = angletotarget
			else
				if npc:GetPlayerTarget().Position.X >= npc.Position.X then
					firingangle = firingangle - 45
				else
					firingangle = firingangle + 45
				end
			end
			data.proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, npc.Position, Vector.FromAngle(firingangle):Resized(10), npc):ToProjectile()
			data.proj.Color = FiendFolio.ColorSpittyGreen
			--data.proj:SetColor(Color(99/255, 155/255, 74/255, 1, 0, 0, 0), 0, 99999, false, true)
			data.proj.Size = data.proj.Size * 2
		end

		if sprite:IsEventTriggered("splapsound") then
			sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS, 0.7, 0, false, 1)
		end

		if sprite:IsEventTriggered("splatty") then
			sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.7, 0, false, 1)
			npc:BloodExplode()
		end

		if sprite:IsEventTriggered("die") then
			--sorry im redoing a lot of this i just really wanted to tinker with what was spawned
			--[[for i = 1, 1 + math.ceil(math.random() - 0.5) do
				local maggot = Isaac.Spawn(21, 750, 0, npc.Position, Vector.Zero, npc):ToNPC()
				maggot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			end
			for i = 1, 1 + math.ceil(math.random() - 0.5) do
				local fly = Isaac.Spawn(18, 0, 0, npc.Position, Vector.Zero, npc):ToNPC()
				fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			end
			if math.ceil(math.random() - 0.5) == 1 then
				local poot = Isaac.Spawn(14, 1, 0, npc.Position, Vector.Zero, npc):ToNPC()
				poot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			end]]--
			--spawn 1 maggot. 2 is wAY too much, but none would be wierd
			local maggot = Isaac.Spawn(21, 750, 0, npc.Position, Vector.Zero, npc):ToNPC()
			maggot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			--spawn 1 pooter
			local poot = Isaac.Spawn(14, 0, 0, npc.Position, Vector.Zero, npc):ToNPC()
			poot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			--spawn some random pooters
			local randompoottable = {0, 1, 1, 1, 2}
			local randompoot = randompoottable[math.random(1,5)]
			if randompoot > 0 then
				for i = 1, randompoot do
					poot = Isaac.Spawn(14, math.random(0, 1), 0, npc.Position, Vector.Zero, npc):ToNPC()
					poot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				end
			end
			--and a swarm of flies
			local randomflytable = {1, 2, 2, 2, 2, 2, 3, 3, 4}
			local randomflytypetable = {13, 18, 18, 18}
			local randomfly = randomflytable[math.random(1,6)]
			if randomfly > 0 then
				for i = 1, randomfly do
					poot = Isaac.Spawn(randomflytypetable[math.random(1,4)], math.random(0, 1), 0, npc.Position, Vector.Zero, npc):ToNPC()
					poot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				end
			end
			--get some creep on!
			local creep = Isaac.Spawn(1000, 23, 0, npc.Position + Vector(0, 15), Vector.Zero, npc)
			creep:SetColor(Color(0, 0, 0, 1, 99 / 255, 56 / 255, 74 / 255), 60, 99999, true, false)
			creep.Size = creep.Size * 2
			creep:GetSprite().Scale = creep:GetSprite().Scale * 2
			npc:Kill()
		end

		if data.proj then
			data.proj:GetSprite():SetFrame("RegularTear11", data.proj.FrameCount % 4)

			if data.proj.FrameCount % 3 == 0 then
				local creep = Isaac.Spawn(1000, 23, 0, data.proj.Position, Vector.Zero, npc):ToEffect()
				creep:SetColor(Color(0, 0, 0, 1, 99 / 255, 56 / 255, 74 / 255), 60, 99999, true, false)
				--make it so it fades out before another is shot
				creep:SetTimeout(math.floor(creep.Timeout * 0.6))
			end

			if data.proj:CollidesWithGrid() or data.proj:IsDead() then
				sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS, 0.7, 0, false, 1)

				local creep = Isaac.Spawn(1000, 23, 0, data.proj.Position, Vector.Zero, npc):ToEffect()
				creep:SetColor(Color(0, 0, 0, 1, 99 / 255, 56 / 255, 74 / 255), 60, 99999, true, false)
				creep.Size = creep.Size * 2
				creep:GetSprite().Scale = creep:GetSprite().Scale * 2
				creep:SetTimeout(math.floor(creep.Timeout * 0.6))

				for i = 1, 5 + math.random(3) do
					local dir = Vector(math.random(-25, 25), - 10 - math.random(30)):Normalized()
					local vel = math.random(40, 80) * 0.1
					local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, data.proj.Position - data.proj.Velocity, dir * vel, npc):ToProjectile()
					proj.Color = FiendFolio.ColorSpittyGreen
					--proj:SetColor(Color(99/255, 155/255, 74/255, 1, 0, 0, 0), 0, 99999, false, true)
					proj.FallingSpeed = math.random(-26, -12)
					proj.FallingAccel = 2.5
				end

				data.proj = nil
			end

			for _, p in pairs(Isaac.FindByType(EntityType.ENTITY_PLAYER, -1, -1, false, false)) do
				if data.proj and p.Position:Distance(data.proj.Position + data.proj.Velocity) - data.proj.Size - p.Size <= 0 then
					sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS, 0.7, 0, false, 1)

					local creep = Isaac.Spawn(1000, 23, 0, data.proj.Position, Vector.Zero, npc)
					creep:SetColor(Color(0, 0, 0, 1, 99 / 255, 56 / 255, 74 / 255), 60, 99999, true, false)
					creep.Size = creep.Size * 2
					creep:GetSprite().Scale = creep:GetSprite().Scale * 2

					for i = 1, 5 + math.random(3) do
						local dir = Vector(math.random(-20, 20), math.random(-20, 20)):Normalized()
						local vel = math.random(40, 80) * 0.1
						local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 4, 0, data.proj.Position - data.proj.Velocity, dir * vel, npc):ToProjectile()
						proj:SetColor(Color(99/255, 155/255, 74/255, 1, 0, 0, 0), 0, 99999, false, true)
						proj.FallingSpeed = math.random(-26, -12)
						proj.FallingAccel = 3 * (1 + math.random())
					end

					data.proj = nil
				end
			end
		end
	end,
	Damage = function(npc)
		local data = npc:GetData()
		if data.FFIsDeathAnimation then
			return false
		end
	end,
}
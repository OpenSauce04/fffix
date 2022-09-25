local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

--Starving
function mod:starvingAI(npc)
	local d = npc:GetData()
	local r = npc:GetDropRNG()
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder
	local sprite = npc:GetSprite()

	if not d.init then
		d.init = true
		d.state = "shoot"
		d.ammo = 10
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		if npc.Velocity.X < 0 then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end
		if npc.Velocity:Length() > 1 then
			if math.abs(npc.Velocity.Y) > math.abs(npc.Velocity.X) then
				if npc.Velocity.Y > 0 then
					mod:spritePlay(sprite, "WalkDown")
				else
					mod:spritePlay(sprite, "WalkUp")
				end
			else
				mod:spritePlay(sprite, "WalkHori")
			end
		else
			sprite:SetFrame("WalkVert", 0)
		end

		local targetresults = mod.FindClosestEntityStarving(npc)
		local targetpos = targetresults[1]
		local targetdist = targetresults[2]

		local targetvelocity = mod:randomVecConfuse(npc, (targetpos - npc.Position):Resized(3), 3)

		if mod:isScare(npc) then
			npc.Velocity = mod:Lerp(npc.Velocity, targetvelocity * -1.2, 0.3)
		elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
			npc.Velocity = mod:Lerp(npc.Velocity, targetvelocity, 0.3)
		else
			path:FindGridPath(targetpos, 3/5, 1, true)
		end

		if npc.Position:Distance(targetpos) < targetdist and not mod:isScareOrConfuse(npc) then
			d.state = "chomp"
			d.ammo = 5
			if math.abs(targetvelocity.X) > math.abs(targetvelocity.Y) then
				if targetvelocity.X < 0 then
					d.dir = 2
				else
					d.dir = 4
				end
			else
				if targetvelocity.Y > 0 then
					d.dir = 1
				else
					d.dir = 3
				end
			end
		end



	elseif d.state == "shoot" then
		npc.Velocity = npc.Velocity * 0.3
		if sprite:IsFinished("Shoot") then
			d.state = "idle"
		elseif sprite:IsEventTriggered("Shoot") then
				local shotnumproj = mod:LuaRound(d.ammo/4 * 3)
				local shotnumbones = mod:LuaRound(d.ammo/4)
				npc:PlaySound(SoundEffect.SOUND_BOSS_SPIT_BLOB_BARF,1,2,false,1.5)
				local params = ProjectileParams()
				npc:FireBossProjectiles(shotnumproj, target.Position, 10, params)
				params.Variant = 1
				npc:FireBossProjectiles(shotnumbones, target.Position, 10, params)
		else
			mod:spritePlay(sprite, "Shoot")
		end
	elseif d.state == "chomp" then
		npc.Velocity = npc.Velocity * 0.3
		sprite.FlipX =  mod.GorgerDir[d.dir][2]
		if sprite:IsFinished("Chomp" .. mod.GorgerDir[d.dir][1]) then
			d.state = "shoot"
		elseif sprite:IsEventTriggered("Chomp") then
			npc:PlaySound(SoundEffect.SOUND_MEATY_DEATHS,1,2,false,math.random(11,13)/10)

			local efpos = npc.Position + Vector(-15,0):Rotated(mod.GorgerDir[d.dir][3] * 90)

			for i = 1, 6 do
				local giblets = Isaac.Spawn(1000, 5, 0, efpos, RandomVector()*(math.random(5)*2), npc):ToEffect();
				giblets:Update()
				local blood = Isaac.Spawn(1000, 7, 0, efpos + RandomVector()*(math.random(5)*3), nilvector, npc)
				blood:Update()
			end

			local pos = npc.Position + Vector(-35,0):Rotated(mod.GorgerDir[d.dir][3] * 90)

			for _,entity in ipairs(Isaac.GetRoomEntities()) do
				if entity.Position:Distance(pos) < 40 then
					if entity.Type == 1 then
						entity:TakeDamage(1, 0, EntityRef(npc), 0)
					end
					if entity:IsActiveEnemy() and entity.MaxHitPoints < 100 and (not entity:IsBoss()) and entity:GetData().FFMartyrDuration == nil then
						local toobig = nil
						for _, ridley in ipairs(mod.StarvingRidleys) do
							if entity.Type == ridley[1] and entity.Variant == ridley[2] then
								toobig = true
							end
						end
						if not toobig then
							if entity.Type == 310 and entity.Variant == 0 then
								entity:TakeDamage(entity.MaxHitPoints/4, 0, EntityRef(npc), 0)
								d.ammo = d.ammo + 15
							elseif entity.Type == 666 and entity.Variant < 2 then
								if entity.Variant == 0 then
									entity:TakeDamage(entity.MaxHitPoints/3, 0, EntityRef(npc), 0)
								elseif entity.Variant == 1 then
									entity:TakeDamage(entity.MaxHitPoints/2, 0, EntityRef(npc), 0)
								end
								d.ammo = d.ammo + 15
							elseif entity.Type == 666 and entity.Variant == 140 then
								local ed = entity:GetData()
								if ed.skin then
									entity.HitPoints = entity.MaxHitPoints
									ed.state = "break"
									ed.skin = false
								else
									entity:Kill()
								end
								d.ammo = d.ammo + entity.MaxHitPoints/2
							else
								d.ammo = d.ammo + entity.MaxHitPoints/2
								if entity.Type == 301 then
									npc:AddPoison(EntityRef(npc), 200, 5)
								end
								entity:Kill()
							end

						end
					end
				end
			end
		else
			mod:spritePlay(sprite, "Chomp" .. mod.GorgerDir[d.dir][1])
		end
	end
end

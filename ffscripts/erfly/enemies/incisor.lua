local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:incisorAI(npc)
	local d = npc:GetData()
	local sprite = npc:GetSprite();
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()

	if not d.init then
		d.state = "idle"
		d.init = true
		d.randwait = 0
		d.vec = RandomVector(100)
		local gridtarget = mod:FindRandomFreePosAir(target.Position, 120)
		d.targetvel = (gridtarget - npc.Position):Resized(5)
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "idle")
		if mod:isScare(npc) then
			d.targetvel = (target.Position - npc.Position):Resized(-10)
			npc.Velocity = mod:Lerp(npc.Velocity, d.targetvel, 0.05)
		elseif d.searching and not mod:isConfuse(npc) then
			local targetvel = (d.searching - npc.Position):Resized(6)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.05)
			if npc.Position:Distance(d.searching) < 40 and sprite:IsEventTriggered("gnashcheck") then
				d.state = "gnash"
				mod:spritePlay(sprite, "gnash")
				d.searching = nil
			end
		else
			if npc.Position:Distance(target.Position) < 120 then
				d.targetvel = (target.Position - npc.Position):Resized(-10)
				d.running = true
			else
				if npc.StateFrame % 30 == 0 or d.running then
					local gridtarget = mod:FindRandomFreePosAir(target.Position, 120)
					d.targetvel = (gridtarget - npc.Position):Resized(6)
					d.running = false
				end
			end
			npc.Velocity = mod:Lerp(npc.Velocity, d.targetvel, 0.05)
			if r:RandomInt(30) == 0 and npc.StateFrame > (40 + d.randwait) then
				d.searching = game:GetRoom():FindFreeTilePosition(npc.Position, 0)
			end
		end
	elseif d.state == "gnash" then
		npc.Velocity = npc.Velocity * 0.8
		if sprite:IsFinished("gnash") then
			d.state = "idle"
			npc.StateFrame = 0
			d.randwait = r:RandomInt(20) + 20
		elseif sprite:IsEventTriggered("land") then
			npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS,1,2,false,0.8)
			npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
			d.TargetPosition = npc.Position
		elseif sprite:IsEventTriggered("pullup") then
			npc:PlaySound(SoundEffect.SOUND_MEATHEADSHOOT, 1, 0, false, 1)
			npc:BloodExplode()
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
			local blood = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc)
			blood.SpriteScale = Vector(0.6,0.6)
			blood:Update()
			d.TargetPosition = nil
		elseif sprite:IsEventTriggered("spit") then
			npc:PlaySound(SoundEffect.SOUND_ANGRY_GURGLE,1,2,false,1.3)

			local shootpos = target.Position
			local starving = mod.FindClosestEntity(npc.Position, 200, mod.FF.Starving.ID, mod.FF.Starving.Var)
			if starving then
				shootpos = starving.Position
			end

			mod.spawnent(npc, npc.Position, (shootpos - npc.Position):Resized(8), 310, 1, 0)
		else
			mod:spritePlay(sprite, "gnash")
		end
	end

	if d.TargetPosition then
		--npc.Position = mod:Lerp(npc.Position, d.TargetPosition, 0.9)
		npc.Velocity = mod:Lerp(npc.Velocity, d.TargetPosition - npc.Position, 0.9)
	end
end
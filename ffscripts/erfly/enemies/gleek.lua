local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:gleekAI(npc)
	local d = npc:GetData()
	local sprite = npc:GetSprite();
	local target = npc:GetPlayerTarget()

	if not d.init then
		d.init = true
		d.state = "idle"
		d.shoot = 1
		d.creepscale = 0
	elseif d.init then
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.creepscale > 0 then
		if npc.FrameCount % (2 + (#mod.creepSpawnerCount)) == 0 then
			local creep = Isaac.Spawn(1000, 22, 0, npc.Position, nilvector, npc):ToEffect();
			creep.Scale = math.min(1, 0.07 * d.creepscale)
			creep:SetTimeout(10 + d.creepscale)
			creep:Update();
		end
		d.creepscale = d.creepscale - 1
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		if sprite:IsEventTriggered("Creep") then
			local targpos = mod:randomConfuse(npc, target.Position)
			npc.Velocity = mod:reverseIfFear(npc, (targpos - npc.Position):Resized(2))
			d.creepscale = 20
			d.accel = 0.30
		end
		if d.accel > 0 then
			d.accel = d.accel - 0.03
		else
			d.accel = 0
		end
		npc.Velocity = npc.Velocity * (0.97 + d.accel)
		if npc.Velocity:Length() > 10 then
			npc.Velocity:Resized(10)
		end
		if game:GetRoom():CheckLine(npc.Position,target.Position,0,3,false,false) and npc.Position:Distance(target.Position) < 150 and npc.StateFrame > 20 and math.random(5) == 1 and not mod:isConfuse(npc) then
			d.state = "attack"
			d.creepass = false
		end
	elseif d.state == "attack" then
		npc.Velocity = npc.Velocity * 0.9
		if sprite:IsFinished("Shoot") then
			d.shoot = d.shoot + 1
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			local rand = math.random(80,100)/100
			npc:PlaySound(SoundEffect.SOUND_ANGRY_GURGLE,1,0,false,rand)
			local params = ProjectileParams()
			local shootvec = (target.Position - npc.Position)
			if d.shoot % 2 == 0 then
				shootvec = shootvec:Rotated(-30)
				params.Scale = 1.5
				for i = 0, 60, 30 do
					local shootyfun = shootvec:Resized(8):Rotated(i)
					npc:FireProjectiles(npc.Position + shootyfun, shootyfun, 0, params)
				end
			else
				shootvec = shootvec:Rotated(-20)
				params.Scale = 2
				params.BulletFlags = params.BulletFlags | ProjectileFlags.RED_CREEP
				for i = 0, 40, 40 do
					local shootyfun = shootvec:Resized(5):Rotated(i)
					npc:FireProjectiles(npc.Position + shootyfun, shootyfun, 0, params)
				end
			end
		else
			mod:spritePlay(sprite, "Shoot")
		end
	end
end

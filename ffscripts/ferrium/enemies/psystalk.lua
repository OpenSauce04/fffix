local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:psykerAI(npc) -- Psystalk
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local room = game:GetRoom()

	if not data.init then
		npc.StateFrame = 110
		data.initPos = npc.Position
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
		data.state = "Idle"
		data.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
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
		if npc.StateFrame > 110 and not mod:isScareOrConfuse(npc) then
			data.state = "Attack"
		else
			mod:spritePlay(sprite, "Idle")
		end
	elseif data.state == "Attack" then
		if sprite:IsFinished("Attack") then
			data.state = "Idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			local poof = Isaac.Spawn(1000, 16, 0, npc.Position, Vector.Zero, npc):ToEffect()
			poof.Color = FiendFolio.ColorPsyGrape2
			poof.SpriteScale = poof.SpriteScale*0.6
			poof.SpriteOffset = Vector(3, -18)
			poof.DepthOffset = 1
			poof:Update()
			if npc.SubType == 0 then
				if math.abs(target.Position.X - npc.Position.X) >= math.abs(target.Position.Y - npc.Position.Y)*1.2 then
					data.projOrient = "Hori"
					if (target.Position.X - npc.Position.X) > 0 then
						data.projVel = Vector(1.5, 0)
					else
						data.projVel = Vector(-1.5, 0)
					end
				else
					data.projOrient = "Vert"
					if (target.Position.Y - npc.Position.Y) > 0 then
						data.projVel = Vector(0, 1.5)
					else
						data.projVel = Vector(0, -1.5)
					end
				end
			elseif npc.SubType == 1 then
				data.projOrient = "Hori"
				if (target.Position.X - npc.Position.X) > 0 then
					data.projVel = Vector(1.5, 0)
				else
					data.projVel = Vector(-1.5, 0)
				end
			elseif npc.SubType == 2 then
				data.projOrient = "Vert"
				if (target.Position.Y - npc.Position.Y) > 0 then
					data.projVel = Vector(0, 1.5)
				else
					data.projVel = Vector(0, -1.5)
				end
			end
			local projectile = Isaac.Spawn(9, 0, 0, npc.Position, data.projVel, npc):ToProjectile()
			npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,0,false,1)
			npc:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR,1,0,false,0.85)
			projectile.FallingAccel = -0.1
			projectile.FallingSpeed = -3
			projectile.ProjectileFlags = projectile.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
			mod:makeCharmProj(npc, projectile)
			projectile.Color = FiendFolio.ColorPsyGrape2
			projectile:GetData().projType = "Psyker"
			projectile:GetData().projOrient = data.projOrient
			projectile:GetData().projVel = data.projVel
		else
			mod:spritePlay(sprite, "Attack")
		end
	end
end

function mod.psykerProj(v, d)
	if d.projType == "Psyker" then
		local wallDetect = game:GetRoom():GetGridCollisionAtPos(v.Position)
		if wallDetect == GridCollisionClass.COLLISION_WALL and not d.Nihilism then
			v:Remove()
			local effect = Isaac.Spawn(1000, 11, 0, v.Position+Vector(0,v.Height), Vector.Zero, v):ToEffect()
			effect.Color = FiendFolio.ColorPsyGrape2
			effect:Update()
			sfx:Play(SoundEffect.SOUND_TEARIMPACTS, 1, 0, false, 1)
		end
		if v.SpawnerEntity and v.SpawnerEntity:Exists() and not mod:isStatusCorpse(v.SpawnerEntity) then
			local target = v.SpawnerEntity:ToNPC():GetPlayerTarget()
			if d.projOrient == "Hori" then
				if target.Position.Y > v.Position.Y then
					d.targetVel = Vector(0, 0.3)
				elseif target.Position.Y < v.Position.Y then
					d.targetVel = Vector(0, -0.3)
				else
					d.targetVel = Vector.Zero
				end
				v.Velocity = mod:Lerp(v.Velocity, v.Velocity+d.targetVel, 0.08)
			else
				if target.Position.X > v.Position.X then
					d.targetVel = Vector(0.3, 0)
				elseif target.Position.X < v.Position.X then
					d.targetVel = Vector(-0.3, 0)
				else
					d.targetVel = Vector.Zero
				end
				v.Velocity = mod:Lerp(v.Velocity, v.Velocity+d.targetVel, 0.08)
			end
			if d.projOrient == "Hori" then
				v.TargetPosition = mod:Lerp(v.Position, Vector(v.Position.X, target.Position.Y), 0.065)
				v.Velocity = Vector(d.projVel.X, v.TargetPosition.Y - v.Position.Y)
			else
				v.TargetPosition = mod:Lerp(v.Position, Vector(target.Position.X, v.Position.Y), 0.065)
				v.Velocity = Vector(v.TargetPosition.X - v.Position.X, d.projVel.Y)
			end
		else
			v.Velocity = mod:Lerp(v.Velocity, d.projVel, 0.065)
		end
	end
end
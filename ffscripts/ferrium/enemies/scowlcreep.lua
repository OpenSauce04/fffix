local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:scowlCreepAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	npc.Velocity = npc.Velocity * 0.925

	if not data.init then
		data.offsetValue = Vector.Zero
		if npc.SpriteRotation == 90 or npc.SpriteRotation == -90 then
			data.offsetValue = Vector(0,-22)
		end
		data.beam = Isaac.Spawn(7, 7, 0, npc.Position+data.offsetValue, Vector.Zero, npc):ToLaser()
		data.beam.Angle = npc.SpriteRotation+90
		data.beam.Color = Color(0.3,0.2,0.2,1,70 / 255,0 / 255,0 / 255)
		data.beam:Update()
		data.occultFrame = 0
		data.state = "Idle"
		data.init = true
	else
		data.occultFrame = data.occultFrame+1
	end

	data.beam.Velocity = (npc.Position+data.offsetValue+npc.Velocity) - (data.beam.Position) 
	--data.beam:Update()
	if npc:IsDead() or mod:isLeavingStatusCorpse(npc) then
		data.beam:Remove()
	end

	if data.state == "Idle" then
		if npc.State == 8 then
			if not mod:isScareOrConfuse(npc) and data.occultFrame > 35 then
				if npc.SpriteRotation == 0 or npc.SpriteRotation == 180 then
					if math.abs(npc.Position.X-target.Position.X) < 50 then
						data.state = "Attack"
						npc.State = 5
					else
						npc.State = 4
					end
				else
					if math.abs(npc.Position.Y-target.Position.Y) < 50 then
						data.state = "Attack"
						npc.State = 5
					else
						npc.State = 4
					end
				end
				if data.occultFrame > 80 then
					data.state = "Attack"
					npc.State = 5
				end
			else
				npc.State = 4
			end
		end
	elseif data.state == "Attack" then
		if npc.State == 5 then
			if sprite:IsFinished("Attack") then
				data.state = "Idle"
				npc.State = 4
				data.occultFrame = 0
			elseif sprite:IsEventTriggered("Shoot") then
				local sOffset = Vector.Zero
				if npc.SpriteRotation == 0 then
					sOffset = Vector(0,20)
				end

				local initvel = Vector(0, 3):Rotated(npc.SpriteRotation)
				if npc.SpriteRotation == 180 or npc.SpriteRotation == 0 then
					initvel = initvel:Rotated(180)
				end
				local poof = Isaac.Spawn(1000, 16, 0, npc.Position, Vector.Zero, npc):ToEffect()
				poof.Color = Color(0.4,0.4,0.4,1,55 / 255,0 / 255,20 / 255)
				poof.SpriteScale = Vector(0.5,0.5)
				poof.DepthOffset = 10
				poof:FollowParent(npc)
				poof:Update()
				local projectile = Isaac.Spawn(9, 0, 0, npc.Position + sOffset, initvel, npc):ToProjectile()
				npc:PlaySound(SoundEffect.SOUND_SPIDER_SPIT_ROAR, 1, 0, false, 1)
				projectile.FallingAccel = -0.1
				projectile.FallingSpeed = -2
				projectile.Scale = 2.2
				projectile.ProjectileFlags = projectile.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
				mod:makeCharmProj(npc, projectile)
				projectile.Color = Color(0.4,0.4,0.4,1,55 / 255,0 / 255,20 / 255)
				projectile.Height = -10
				projectile:GetData().projType = "Occult"
				if npc.SpriteRotation == 0 or npc.SpriteRotation == 180 then
					projectile:GetData().projOrient = "Vert"
				else
					projectile:GetData().projOrient = "Hori"
				end
				if npc.SpriteRotation == 90 or npc.SpriteRotation == 180 then
					projectile:GetData().moveSpeed = -3
				else
					projectile:GetData().moveSpeed = 3
				end
				projectile:Update()
			else
				mod:spritePlay(sprite, "Attack")
			end
		end
	end
end

function mod.scowlCreepProj(v, d)
	if d.projType == "Occult" then
		local wallDetect = game:GetRoom():GetGridCollisionAtPos(v.Position)
		if wallDetect == GridCollisionClass.COLLISION_WALL and v.FrameCount > 15 then
			v:Remove()
			local effect = Isaac.Spawn(1000, 11, 0, v.Position, Vector.Zero, v):ToEffect()
			effect.SpriteScale = effect.SpriteScale * 1.5
			effect.Color = Color(0.4,0.4,0.4,1,55 / 255,0 / 255,20 / 255)
			effect:Update()
			sfx:Play(SoundEffect.SOUND_TEARIMPACTS, 1, 0, false, 1)
		end
		if v.SpawnerEntity and v.SpawnerEntity:Exists() and not mod:isStatusCorpse(v.SpawnerEntity) then
			local target = v.SpawnerEntity
			if d.projOrient == "Vert" then
				v.Velocity = Vector(target.Position.X-v.Position.X, d.moveSpeed)
				--v.Position = mod:Lerp(v.Position, v.Position+Vector(target.Position.X-v.Position.X, 0), 0.65)
				--v.Velocity = mod:Lerp(v.Velocity, v.Velocity+Vector(target.Position.X-v.Position.X, 0)*0.1, 0.7)
			else
				v.Velocity = Vector(d.moveSpeed, target.Position.Y-v.Position.Y)
				--v.Position = mod:Lerp(v.Position, v.Position+Vector(0, target.Position.Y-v.Position.Y), 0.65)
				--v.Velocity = mod:Lerp(v.Velocity, v.Velocity+Vector(0, target.Position.Y-v.Position.Y)*0.1, 0.7)
			end
		else
			if d.projOrient == "Vert" then
				v.Velocity = Vector(0, d.moveSpeed)
			else
				v.Velocity = Vector(d.moveSpeed, 0)
			end
			--[[if d.projOrient == "Vert" then
				v.Velocity = mod:Lerp(v.Velocity, Vector(0, v.Velocity.Y), 0.7)
			else
				v.Velocity = mod:Lerp(v.Velocity, Vector(v.Velocity.X, 0), 0.7)
			end]]
		end
	end
end
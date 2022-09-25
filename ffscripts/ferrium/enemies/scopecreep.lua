local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:scopeCreepAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
    local rng = npc:GetDropRNG()
	npc.Velocity = npc.Velocity * 0.45

	if not data.init then
		data.offsetValue = Vector.Zero
		if npc.SpriteRotation == 90 or npc.SpriteRotation == -90 then
			data.offsetValue = Vector(0,-22)
		end
		data.stateFrame = 0
		data.state = "Idle"
		data.init = true
	else
		data.stateFrame = data.stateFrame+1
	end

	if data.state == "Idle" then
        local playerPos = target.Position+target.Velocity*50
		if npc.State == 8 then
			if not mod:isScareOrConfuse(npc) and data.stateFrame > 35 then
				if npc.SpriteRotation == 0 or npc.SpriteRotation == 180 then
					if math.abs(npc.Position.X-target.Position.X) < 50 or math.abs(npc.Position.X-playerPos.X) < 50 then
						data.state = "Attack"
						npc.State = 5
					else
						npc.State = 4
					end
				else
					if math.abs(npc.Position.Y-target.Position.Y) < 50 or math.abs(npc.Position.Y-playerPos.Y) < 50 then
						data.state = "Attack"
						npc.State = 5
					else
						npc.State = 4
					end
				end
			else
				npc.State = 4
			end
		elseif not mod:isScareOrConfuse(npc) and data.stateFrame > 35 then
            if npc.SpriteRotation == 0 or npc.SpriteRotation == 180 then
                if math.abs(npc.Position.X-target.Position.X) < 50 or math.abs(npc.Position.X-playerPos.X) < 50 then
                    data.state = "Attack"
                    npc.State = 5
                end
            else
                if math.abs(npc.Position.Y-target.Position.Y) < 50 or math.abs(npc.Position.Y-playerPos.Y) < 50 then
                    data.state = "Attack"
                    npc.State = 5
                end
            end
        end
	elseif data.state == "Attack" then
		if npc.State == 5 then
			if sprite:IsFinished("Attack") then
				data.state = "Idle"
				npc.State = 4
				data.stateFrame = 0
			elseif sprite:IsEventTriggered("Shoot") then
				local sOffset = Vector.Zero
				if npc.SpriteRotation == 0 then
					sOffset = Vector(0,20)
				end

				local initvel = Vector(0, 1):Rotated(npc.SpriteRotation)
				if npc.SpriteRotation == 180 or npc.SpriteRotation == 0 then
					initvel = -initvel:Rotated(180)
				end
				local poof = Isaac.Spawn(1000, 16, 0, npc.Position, Vector.Zero, npc):ToEffect()
				poof.Color = Color(0.4,0.4,0.4,1,55 / 255,0 / 255,20 / 255)
				poof.SpriteScale = Vector(0.5,0.5)
				poof.DepthOffset = 10
				poof:FollowParent(npc)
				poof:Update()
                local params = ProjectileParams()
                for i=1.5,10,2 do
                    local vel = initvel:Resized(i)*2
                    params.Scale = (4+i)/8
                    params.FallingSpeedModifier = mod:getRoll(-5,20,rng)/10
                    params.BulletFlags = params.BulletFlags | ProjectileFlags.ACCELERATE
                    params.Acceleration = 0.95
                    npc:FireProjectiles(npc.Position+initvel:Resized(10), vel:Rotated(mod:getRoll(-7,7, rng)), 0, params)
                end
				npc:PlaySound(mod.Sounds.ShottieShot, 0.7, 0, false, math.random(130,155)/100)
			else
				mod:spritePlay(sprite, "Attack")
			end
		end
	end
end
local mod = FiendFolio
local game = Game()

local coloDirToOffset = {
	["Down"] = Vector.Zero,
	["Right"] = Vector(22,0),
	["Up"] = Vector.Zero,
	["Left"] = Vector(-22,0),
}

function mod:coloscopeAI(npc)
    local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local sprite = npc:GetSprite()
	local rng = npc:GetDropRNG()
	local room = game:GetRoom()
	
	if not data.init then
		data.state = "Idle"
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end

	if data.state == "Idle" then
		if mod:isScare(npc) then
			local targetvel = (targetpos - npc.Position):Resized(-6)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
		elseif room:CheckLine(npc.Position, targetpos, 0, 1, false, false) then
			local targetvel = (targetpos - npc.Position):Resized(3)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
		else
			npc.Pathfinder:FindGridPath(targetpos, 0.45, 900, true)
		end

        if npc.Velocity:Length() > 0.1 then
			if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
                if npc.Velocity.X > 0 then
                    mod:spritePlay(sprite, "IdleRight")
                else
                    mod:spritePlay(sprite, "IdleLeft")
                end
            else
                if npc.Velocity.Y > 0 then
                    mod:spritePlay(sprite, "IdleDown")
                else
                    mod:spritePlay(sprite, "IdleUp")
                end
            end
		else
			mod:spritePlay(sprite, "StandDown")
		end
		
		if npc.StateFrame > 40 and not mod:isScareOrConfuse(npc) and room:CheckLine(npc.Position, targetpos, 3, 1, false, false) then
            local shoot = false
			if rng:RandomInt(40) == 1 then
				shoot = true
			elseif npc.StateFrame > 90 then
				shoot = true
			end
            if shoot == true then
                data.state = "Shoot"
                if math.abs(target.Position.X - npc.Position.X) >= math.abs(target.Position.Y - npc.Position.Y)*1.2 then
					if (target.Position.X - npc.Position.X) > 0 then
						data.dir = "Right"
					else
						data.dir = "Left"
					end
				else
					if (target.Position.Y - npc.Position.Y) > 0 then
						data.dir = "Down"
					else
						data.dir = "Up"
					end
				end
            end
		end
    elseif data.state == "Shoot" then
		local targetAngle = (target.Position-npc.Position):GetAngleDegrees()
		if data.dir == "Down" then
			data.shootDir = data.shootDir or Vector(0,20)
			if math.abs(targetAngle-90) < 50 then
				data.shootDir = (target.Position-npc.Position):Resized(20)
			end
		elseif data.dir == "Left" then
			data.shootDir = data.shootDir or Vector(-20,0)
			if math.abs(targetAngle-180) < 50 or math.abs(targetAngle+180) < 60 then
				data.shootDir = (target.Position-npc.Position):Resized(20)
			end
		elseif data.dir == "Up" then
			data.shootDir = data.shootDir or Vector(0,-20)
			if math.abs(targetAngle+90) < 50 then
				data.shootDir = (target.Position-npc.Position):Resized(20)
			end
		elseif data.dir == "Right" then
			data.shootDir = data.shootDir or Vector(20,0)
			if math.abs(targetAngle) < 50 then
				data.shootDir = (target.Position-npc.Position):Resized(20)
			end
		end

        if sprite:IsFinished("Shoot" .. data.dir) then
            data.state = "Waiting"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Shoot") then
			local prevProj = npc
			local offsetPos = npc.Position+coloDirToOffset[data.dir]
			for i=1,8 do
				--[[local var = 3
				if math.random(10) == 1 then
					var = 5
				end]]
				local proj = Isaac.Spawn(9, 3, 0, offsetPos, data.shootDir, npc):ToProjectile()
				proj.Scale = mod:getRoll(20,160,rng)/100
				local color = Color(1,1,1,1,0,0,0)
				color:SetColorize(1,1,1,math.random(-255,20)/255)
				proj.Color = color
				proj.Parent = prevProj
				proj:GetData().projType = "coloscope"
				proj:GetData().dir = data.dir
				if i == 1 then
					npc.Child = proj
				else
					prevProj.Child = proj
				end
				prevProj = proj
			end

			npc:PlaySound(SoundEffect.SOUND_DEATH_BURST_LARGE, 1, 0, false, math.random(90,110)/100)
			local splat = Isaac.Spawn(1000, 16, 5, offsetPos, Vector.Zero, npc):ToEffect()
			splat.SpriteScale = Vector(0.6,0.5)
			local color = Color(0, 0, 0, 1, 151/255, 102/255, 60/255)
			color:SetColorize(1,1,1,1)
			splat.Color = color
			splat.SpriteOffset = Vector(0,-20)
			if data.dir == "Up" then
				splat.SpriteOffset = Vector(0,-30)
				splat.DepthOffset = -500
			end
        else
            mod:spritePlay(sprite, "Shoot" .. data.dir)
        end

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
    elseif data.state == "Waiting" then
		if not npc.Child or not npc.Child:Exists() then
			data.state = "Idle"
			npc.StateFrame = 0
        elseif npc.StateFrame > 40 then
            data.state = "Sucking"
			npc.Child:GetData().pulling = true
			mod:adjustChildrenData(npc.Child, "pulling", true)
			npc.StateFrame = 0
        end

        mod:spritePlay(sprite, "Wait" .. data.dir)
        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
    elseif data.state == "Sucking" then
        if npc.Child and npc.Child:Exists() then
			local offsetPos = npc.Position+coloDirToOffset[data.dir]
			if npc.Child.Position:Distance(offsetPos) < 15 then
				local orig = npc.Child
				if npc.Child.Child and npc.Child.Child:Exists() then
					npc.Child = npc.Child.Child
					npc.Child.Parent = npc
				end
				orig:Remove()
				local splat = Isaac.Spawn(1000, 43, 160, offsetPos+mod:shuntedPosition(5, rng), Vector.Zero, npc):ToEffect()
				splat.DepthOffset = -30
				splat.SpriteOffset = Vector(0,orig:ToProjectile().Height)
				splat.SpriteScale = Vector(0.7, 0.7)
				npc:PlaySound(SoundEffect.SOUND_PLOP, 0.3, 0, false, math.random(80,120)/100)
				if math.random(3) == 2 then
					Isaac.Spawn(1000, 58, 0, offsetPos, RandomVector(), npc)
				end
			end
		end
        if not npc.Child or not npc.Child:Exists() or npc.StateFrame > 50 then
            data.state = "Idle"
            npc.StateFrame = 0
        end

        mod:spritePlay(sprite, "Suck" .. data.dir)
        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
    end
end

function mod.coloscopeProj(v, d)
	if d.projType == "coloscope" then
		if d.terminate then
			v.FallingSpeed = 1
			v.Velocity = v.Velocity*0.9
		end

		if v.Parent and v.Parent:Exists() and not d.terminate then
			local pos = v.Parent.Position
			if v.Parent:ToNPC() and v.Parent.Type == mod.FF.Coloscope.ID and v.Parent.Variant == mod.FF.Coloscope.Var then
				if v.Parent:GetData().dir then
					pos = coloDirToOffset[v.Parent:GetData().dir]+pos
				end
			end

			v.FallingSpeed = -0.01
			v.FallingAccel = -0.01

			local dist = pos - v.Position
            if dist:Length() > 13 and not d.pulling then
                local distToClose = dist - dist:Resized(22)
                v.Velocity = v.Velocity*0.35 + distToClose*0.15
				d.taut = true
            end
			
			if d.pulling then
				d.pullVel = d.pullVel or 0
				v.Velocity = mod:Lerp(v.Velocity, (pos - v.Position):Resized(d.pullVel), 0.3)

				if d.pullVel < 10 then
					d.pullVel = d.pullVel+0.75
				end
			elseif d.taut then
				v.Velocity = mod:Lerp(v.Velocity, Vector.Zero, 0.05)
			end
		else
			d.terminate = true
			mod:adjustChildrenData(v, "terminate", true)
		end
	end
end
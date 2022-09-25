local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:thousandEyesAI(npc, subt)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	mod.thousandeyes = true

	if not d.init then
		npc.SplatColor = mod.ColorCharred
		if subt == 1 or subt == 2 then
			d.state = "eyesopen"
			d.randomwait = math.random(8)
			sprite:SetFrame("EyeOpen", 0)
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        elseif subt == 10 then
            d.state = "waiting"
            npc.Visible = false
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)

            local pit = Isaac.GridSpawn(7, 0, npc.Position, true)
    		mod:UpdatePits()
		else
			npc.SpriteOffset = Vector(0,-15)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			d.state = "idle"
			npc.Velocity = RandomVector()*7
		end
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Move")
		npc.Velocity = npc.Velocity * 0.95
		if npc.Velocity.X > 0 then
			sprite.FlipX = false
		else
			sprite.FlipX = true
		end

		if npc.StateFrame % 25 == 24 then
			if mod:isScare(npc) then
				npc.Velocity = npc.Velocity + (target.Position - npc.Position):Resized(-7)
			else
				npc.Velocity = npc.Velocity + RandomVector()*7
			end
		end

		if npc.StateFrame > 30 and math.random(25) == 1 and not mod:isScareOrConfuse(npc) then
			d.state = "playercharge"
			d.chargestate = 0
		end

	elseif d.state == "playercharge" then
		if npc.Velocity.X > 0 then
			sprite.FlipX = false
		else
			sprite.FlipX = true
		end
		if d.chargestate == 0 then
			if sprite:IsFinished("ChargeStart") then
				d.chargestate = 1
			elseif sprite:IsEventTriggered("CHAAARGE") then
				npc:PlaySound(mod.Sounds.MonsterYellFlash, 1, 0, false, math.random(160,180)/100)
				d.playercharging = true
				d.chargetarget = target.Position
			else
				mod:spritePlay(sprite, "ChargeStart")
			end
		elseif d.chargestate == 1 then
			mod:spritePlay(sprite, "Charge")
			if subt ~= 1 and subt ~= 10 and npc.Position:Distance(d.chargetarget) < 50 then
				d.chargestate = 2
				d.playercharging = false
				npc.StateFrame = 0
			end
		elseif d.chargestate == 2 then
			mod:spritePlay(sprite, "Charge")
			if npc.StateFrame > 10 or npc:CollidesWithGrid() then
				d.state = "idle"
				npc.StateFrame = 0
			end
			if not d.playercharging then
				npc.Velocity = npc.Velocity * 0.99
			end
		end
	elseif d.state == "eyesopen" then
		if npc.StateFrame > d.randomwait then
            local anim = "EyeOpen"
            if not d.eyesvariant then
                d.eyesvariant = math.random(1, 4)
            end

            if d.eyesvariant ~= 1 then
                anim = "EyesOpen0" .. tostring(d.eyesvariant)
            end

			if sprite:IsFinished("EyeOpen") then
				d.state = "eyeswait"
			else
				mod:spritePlay(sprite, "EyeOpen")
			end
		end
	elseif d.state == "eyeswait" then
		npc.Velocity = nilvector
        local anim = "Eyes"
        if d.eyesvariant ~= 1 then
            anim = "Eyes0" .. tostring(d.eyesvariant)
        end

		mod:spritePlay(sprite, anim)
		if npc.StateFrame > 40 + d.randomwait then
			if subt == 1 or subt == 10 then
				if npc.StateFrame > 40 + d.randomwait + d.chargedelay then
					d.state = "appear"
					mod:spritePlay(sprite, "Appear")
					npc.SpriteOffset = Vector(0,-15)
					npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
				end
			else
				d.state = "eyesclose"
			end
		end
	elseif d.state == "eyesclose" then
		npc.Velocity = nilvector
        local anim = "EyeClose"
        if d.eyesvariant ~= 1 then
            anim = "EyesClose0" .. tostring(d.eyesvariant)
        end

		if sprite:IsFinished(anim) then
			npc:Remove()
		else
			mod:spritePlay(sprite, anim)
		end
	elseif d.state == "appear" then
		npc.Velocity = npc.Velocity * 0.95
		if sprite:IsFinished("Appear") then
			d.state = "playercharge"
			d.chargestate = 0
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "Appear")
		end
	end

	if d.playercharging then
		if subt == 1 or subt == 10 then
            local room = game:GetRoom()
			d.targvel = d.targvel or (d.chargetarget - npc.Position):Resized(16)
			npc.Velocity = mod:Lerp(npc.Velocity, d.targvel, 0.3)
			if npc.StateFrame > 300 or npc.Position.X < -100 or npc.Position.X > room:GetGridWidth()*40+100 or npc.Position.Y < -300 or npc.Position.Y > room:GetGridHeight()*40+300 then
				npc:Remove()
			end
		else
			local targvel = (d.chargetarget - npc.Position):Resized(16)
			npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.3)
		end
	end
end

function mod.ThousandEyesLogic()
	if not mod.thousandeyes then return end
	local OneEntireThousand = 1
	local TheNumberOfEyes = mod.GetEntityCount(mod.FF.ThousandEyes.ID,mod.FF.ThousandEyes.Var, 0)
	if mod.ThousandEyesSpawned then return end
	if TheNumberOfEyes < OneEntireThousand then
        local waitingEyes = Isaac.FindByType(mod.FF.ThousandEyes.ID, mod.FF.ThousandEyes.Var, mod.FF.ThousandEyesWait.Sub, false, false)
        if #waitingEyes == 0 then
            local room = game:GetRoom()
    		local validpits = {}
    		local size = room:GetGridSize()
    		for i=0, size do
    			local gridEntity = room:GetGridEntity(i)
    			if gridEntity then
    				if gridEntity.Desc.Type == GridEntityType.GRID_PIT and gridEntity.CollisionClass == GridCollisionClass.COLLISION_PIT then
    					if #validpits > 0 then
    						table.insert(validpits, math.random(#validpits + 1), room:GetGridPosition(i))
    					else
    						table.insert(validpits, room:GetGridPosition(i))
    					end
    				end
    			end
    		end

    		for i = 1, #validpits do
    			local subtypechoice = 2
    			if i < 5 then
    				subtypechoice = 1
    			end
    			if i < 5 or math.random(3) == 1 then
    				local eyes = Isaac.Spawn(mod.FF.ThousandEyes.ID, mod.FF.ThousandEyes.Var, subtypechoice, validpits[i], nilvector, npc):ToNPC()
    				eyes:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    				eyes.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    				eyes:GetData().chargedelay = i * 10
    				eyes:Update()
    			end
    		end
        else
            for i = 1, #waitingEyes * 2 do -- shuffle
                local a, b = math.random(#waitingEyes), math.random(#waitingEyes)
                waitingEyes[a], waitingEyes[b] = waitingEyes[b], waitingEyes[a]
            end

            for i, eyes in ipairs(waitingEyes) do
                local d, sprite = eyes:GetData(), eyes:GetSprite()
                eyes:ToNPC().StateFrame = 0
                d.state = "eyesopen"
    			d.randomwait = math.random(8)
    			sprite:SetFrame("EyeOpen", 0)
                eyes.Visible = true
    			eyes.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                eyes:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
                eyes:GetData().chargedelay = i * 10
                eyes:Update()
            end
        end

		mod.ThousandEyesSpawned = true
	end
end
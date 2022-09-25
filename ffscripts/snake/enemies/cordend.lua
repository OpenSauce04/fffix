local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

mod.cordendCords = {"Segment01", "Segment02", "Segment03"}

function mod:CordendUpdate(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = target.Position
	local subt = npc.SubType
	local room = game:GetRoom()
	npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
	-- cord
	if subt == 2 then
		if not d.init then
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_HIDE_HP_BAR)
			mod:spritePlay(sprite, mod.cordendCords[math.random(#mod.cordendCords)])
			d.init = true
		end

		npc.Velocity = nilvector

		if npc.FrameCount < 31 then
			npc.SpriteScale = Vector(npc.FrameCount/30, npc.FrameCount/10)
		else
			npc.SpriteScale = Vector(1,1)
		end

		for _, splosion in pairs(Isaac.FindByType(1000, 1, -1, false, false)) do
			if splosion.Position:Distance(npc.Position) < 40 then
				npc:Kill()
			end
		end

		-- update position
		if npc.Child and npc.Parent and d.BallOrder then
			if npc.Parent:GetData().State == "joined" then
				npc:Remove()
			else
				local p1 = npc.Parent.Position
				local p2 = npc.Child.Position
				local vec = p2 - p1
				npc.Position = p1 + (vec * d.BallOrder[1] / d.BallOrder[2])
			end
		else
			-- remove cord
			npc:Remove()
		end
	elseif subt == 0 then
		if not d.init then
			npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_HIDE_HP_BAR)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL

			d.LastFullPos = npc.Position
			d.State = "joined"
			d.StateFrame = 0
			d.CordMaxHP = 25
			d.CordHP = d.CordMaxHP

			d.init = true
		end

		-- die on room clear
		if room:IsClear() then
			if d.State == "splitted" and npc.Velocity.X == 0 and npc.Child.Velocity.X == 0 then
				d.State = "rejoin"
			elseif d.State == "joined" then
				d.State = "die"
			end
		end

		-- die ok
		if d.State == "die" then
			npc.Velocity = nilvector
			mod:spritePlay(sprite, "Death")

			if sprite:IsEventTriggered("Explode") then
				npc:Kill()
			end
		-- joined cordend
		elseif d.State == "joined" then
			npc.Velocity = Vector.Zero
			if not sprite:IsPlaying("Rejoice") then
				mod:spritePlay(sprite, "Walk")
			end

			-- if player is in line of sight, split
			d.extraWait = d.extraWait or 0
			--print(d.extraWait)
			if d.StateFrame >= d.extraWait and d.StateFrame % 5 == 0 then
				npc:SetColor(Color(1,1,1,1,100 / 255,0,0),5,1,true,false)
			end
			if d.StateFrame >= 25 + d.extraWait then
				--if room:CheckLine(npc.Position,targetpos,0,1,false,false) then
					d.State = "split"
					d.StateFrame = 0
				--end
			else
				d.StateFrame = d.StateFrame + 1
			end

		elseif d.State == "split" then
			-- if still playing the idle animation, make it split apart
			if sprite:IsPlaying("Walk") then
				mod:spritePlay(sprite, "SplitApart")
			-- split trigger
			elseif sprite:IsEventTriggered("SplitApart") then
				d.LastFullPos = npc.Position
				d.TargetL = room:GetLaserTarget(npc.Position, Vector(-1,0))
			  d.TargetR = room:GetLaserTarget(npc.Position, Vector(1,0))

				-- left half is just the main cordend
				npc.Position = npc.Position - (npc.Position - d.TargetL):Resized((npc.Position.X - d.TargetL.X) / 15)
				if d.TargetL:Distance(d.LastFullPos) > 80 then
					npc.Velocity = (d.TargetL - npc.Position):Resized(25)
				end
				mod:spritePlay(sprite, "Half01Split")

				-- spawn and set up right half
			 	npc.Child = Isaac.Spawn(mod.FF.Cordend.ID, mod.FF.Cordend.Var, 1, npc.Position, (d.TargetR - npc.Position):Resized(25), npc)
				local c = npc.Child
				c.Position = c.Position + (d.TargetR - c.Position):Resized((d.TargetR.X - c.Position.X) / 5)
				c.Parent = npc
				if d.TargetR:Distance(d.LastFullPos) > 80 then
					c.Velocity = (d.TargetR - npc.Child.Position):Resized(25)
				end
				c:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				c:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_HIDE_HP_BAR) 
				c.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				c.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS

				c:GetData().State = "splitted"
				mod:spritePlay(c:GetSprite(), "Half02Split")

				-- spawn cord
				-- cord length dependant on how long the cordend will stretch
				local count = d.TargetL:Distance(d.TargetR) / 20
				for i = 1, count do
				local ball = Isaac.Spawn(mod.FF.Cordend.ID, mod.FF.Cordend.Var, 2, npc.Position, nilvector, npc)
					ball:GetData().BallOrder = {i, count + 1}
					ball.Parent = npc
					ball.Child = npc.Child
					ball.SpriteOffset = Vector(0, -10)
					ball.SpriteScale = nilvector
					ball:Update()
				end

				d.State = "splitted"
				npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS,1,2,false,1)
			end
		elseif d.State == "splitted" then
			npc.Velocity = (d.TargetL - npc.Position):Resized(25)

			if npc.Position:Distance(d.TargetL) < 35 then
				npc.Velocity = nilvector
				npc.Position = d.TargetL
				mod:spritePlay(sprite, "Half01Walk")
			end

			if npc.Child then
				npc.Child.Velocity = (d.TargetR - npc.Child.Position):Resized(25)

				if npc.Child.Position:Distance(d.TargetR) < 35 then
					npc.Child.Velocity = nilvector
					npc.Child.Position = d.TargetR
					mod:spritePlay(npc.Child:GetSprite(), "Half02Walk")
				end
			end
		elseif d.State == "rejoin" then
			local m = d.LastFullPos
			if d.TargetL:Distance(d.LastFullPos) > 80 and d.TargetR:Distance(d.LastFullPos) > 80 then
				m = Vector((d.TargetL.X + d.TargetR.X) / 2, (d.TargetL.Y + d.TargetR.Y) / 2)
			end

			npc.Velocity = (m - npc.Position):Resized(m:Distance(npc.Position) / 3)
			if npc.Child then
				npc.Child.Velocity = (m - npc.Child.Position):Resized(m:Distance(npc.Child.Position) / 3)

				if npc.Child.Position:Distance(m + Vector(8, 0)) < 10 then
					npc.Child.Velocity = nilvector
					npc.Child.Position = m + Vector(8, 0)
					mod:spritePlay(npc.Child:GetSprite(), "Half02Walk")
				end
			end

			if npc.Position:Distance(m - Vector(8, 0)) < 10 and npc.Child.Position:Distance(m + Vector(8, 0)) < 10 then
				npc.Child:Remove()

				npc.Position = m
				npc.Velocity = nilvector
				d.State = "joined"
				mod:spritePlay(sprite, "Rejoice")
				d.StateFrame = 0
				d.extraWait = d.extraWait or 0
				d.extraWait = d.extraWait + 50
			end
		end
	end
end

function mod:CordendHurt(npc, damage, flag, source, countdown)
	local d = npc:GetData()
	local sprite = npc:GetSprite()
	
	if flag == flag | DamageFlag.DAMAGE_SPIKES then
		return false
	end

	if npc.SubType == 0 or npc.SubType == 1 then
		if d.State == "splitted" then
			if npc.Child and npc.Child.Velocity.X == 0 then
				d.State = "rejoin"
				npc.Child:GetData().State = "rejoin"
			elseif npc.Parent and npc.Parent.Velocity.X == 0 then
				d.State = "rejoin"
				npc.Parent:GetData().State = "rejoin"
			end
		end
		return false
	elseif npc.SubType == 2 then
		local d = npc.Parent:GetData()
		if not d.State == "splitted" then
			return false
		end
		npc.HitPoints = npc.HitPoints + damage
		
		d.CordHP = d.CordHP - damage
		if d.CordHP <= 0 then
			d.CordHP = d.CordMaxHP
			npc.Parent:GetData().State = "rejoin"
			npc.Child:GetData().State = "rejoin"
		end
	end
end
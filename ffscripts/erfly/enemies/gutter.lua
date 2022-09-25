local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:gutterAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not d.init then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		d.state = "waiting"
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if game:GetRoom():IsClear() then
		if d.state ~= "disappear" then
			d.state = "disappear"
			npc.StateFrame = 0
			d.anim = 1
			if target.Position.X > npc.Position.X then
				d.anim = 2
			end
		end
	end

	if d.state == "disappear" then
		mod:spritePlay(sprite, "Idle0" .. d.anim)
		npc.Velocity = npc.Velocity * 0.1
		if npc.StateFrame > 4 then
			npc:Remove()
		else
			local val = 1 - (0.2 * (npc.StateFrame + 1))
			npc.Color = Color(val,val,val,val)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		end
	elseif d.state == "waiting" then
		npc.Velocity = npc.Velocity * 0.1
		npc.Visible = false
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		if (npc.StateFrame > 30 and math.random(30) == 1) or npc.StateFrame > 60 then
			local room = Game():GetRoom()
			npc.Position = mod:FindRandomWall(npc)
			local vec = npc.Position - room:GetCenterPos()
			npc.Position = npc.Position + vec:Resized(60)

			d.state = "appear"
			npc.Velocity = (target.Position - npc.Position):Resized(5)
			d.anim = 1
			if target.Position.X > npc.Position.X then
				d.anim = 2
			end
			mod:spritePlay(sprite, "Appear0" .. d.anim)
			npc.Visible = true
		end
	elseif d.state == "appear" then
		npc.Velocity = npc.Velocity * 0.95
		if sprite:IsFinished() then
			d.state = "idle"
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "Appear0" .. d.anim)
		end
	elseif d.state == "idle" then
		npc.Velocity = npc.Velocity * 0.8
		d.anim = 1
		if target.Position.X > npc.Position.X then
			d.anim = 2
		end
		mod:spritePlay(sprite, "Idle0" .. d.anim)
		if (npc.StateFrame > 10 and math.random(10) == 1) or npc.StateFrame > 15 then
			d.state = "charge"
			d.sState = nil
			mod:spritePlay(sprite, "DashStart0" .. d.anim)
			npc.StateFrame = 0
		end
	elseif d.state == "charge" then
		if not d.sState then
			d.anim = 1
			if target.Position.X > npc.Position.X then
				d.anim = 2
			end
			if sprite:IsFinished() or npc.StateFrame >= 25 then
				d.sState = "charging"
			elseif sprite:GetFrame() == 20 then
				d.charging = true
				d.targpos = target.Position

			else
				mod:spritePlay(sprite, "DashStart0" .. d.anim)
				sprite:SetFrame(npc.StateFrame)
			end
		elseif d.sState == "charging" then
			mod:spritePlay(sprite, "Dash0" .. d.anim)
		elseif d.sState == "swipe" then
			if sprite:IsFinished("Swipe0" .. d.anim) then
				mod:spritePlay(sprite, "Idle0" .. d.anim + 2)
			elseif sprite:IsEventTriggered("Sound") then
				mod:PlaySound(SoundEffect.SOUND_KNIFE_PULL)
				npc.Velocity = npc.Velocity * 0.2
				local vec = Vector.FromAngle((d.anim * -60) + 200)
				local swipe = Isaac.Spawn(1000, mod.FF.FFKnifeSwipe.Var, mod.FF.FFKnifeSwipe.Sub, npc.Position + vec:Resized(5), npc.Velocity + vec:Resized(5), npc)
			--	swipe.SpriteScale = Vector(, 0.5)
				swipe.SpriteRotation = d.anim * -60 + 120
				swipe.SpriteOffset = Vector(0, -7)
				swipe.SpawnerEntity = npc
				swipe:Update()
			end
			if npc.StateFrame > 15 then
				d.state = "waiting"
				npc.Visible = false
				npc.Color = mod.ColorNormal
			elseif npc.StateFrame > 10 then
				local val = 1 - (0.2 * (npc.StateFrame - 10))
				npc.Color = Color(val,val,val,val)
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			end
		end

		if d.charging then
			if d.targpos then
				local vec = d.targpos - npc.Position
				npc.Velocity = mod:Lerp(npc.Velocity, vec:Resized(20), 0.5)
				if npc.Position:Distance(d.targpos) < 100 then
					d.sState = "swipe"
					d.swipeVec = target.Position - npc.Position
					d.anim = math.ceil(((d.swipeVec:GetAngleDegrees() + 180) * -1 % 360)  / 60)
					mod:spritePlay(sprite, "Swipe0" .. d.anim)
					d.charging = nil
					npc.StateFrame = 0
				end
			end
		else
			npc.Velocity = npc.Velocity * 0.75
		end
	end
end

function mod:knifeSwipeAI(e)
	local sprite = e:GetSprite()
	if sprite:IsFinished() then
		e:Remove()
	else
		if e.SpawnerEntity and e.FrameCount < 7 then
			local radiusCent = e.Position + e.SpriteOffset
			for _, player in pairs(Isaac.FindInRadius(radiusCent, 120, EntityPartition.PLAYER)) do
				if player.Position:Distance(radiusCent) - player.Size < 45 then
					player:TakeDamage(1, 0, EntityRef(e.SpawnerEntity), 0)
				end
			end
		end
	end
end
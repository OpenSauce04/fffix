local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:MistmongerUpdate(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = target.Position
	local room = game:GetRoom()

	if not d.Init then
		-- frame counter
		d.StateFrame = 0
		-- its incorporeal and serves as an annoyance more than an enemy
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE

		d.ApparitionCounter = 0
		d.State = "roam"
		d.Init = true
	end

	-- disappear on room clear
	if room:IsClear() then
		d.State = "vanish"
	end

	-- 'idle'
	if d.State == "roam" then
		-- flying animation (i forgot why i called it walk but im sure there was a great reason)
		mod:spritePlay(sprite, "Walk")

		-- slowly float towards player
		local targetvel = (targetpos - npc.Position):Resized(1.2)
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.20)

		-- start charging after a few frames
		d.StateFrame = d.StateFrame + 1
		if d.StateFrame > 40 then
			d.State = "start charge"
			d.StateFrame = 0
		end
	-- starting to charge
	elseif d.State == "start charge" then
		mod:spritePlay(sprite, "ChargeStart")

		npc.Velocity = mod:Lerp(npc.Velocity, Vector(-3, 0), 0.05)
		if sprite:IsEventTriggered("Charge") then
			npc.Velocity = Vector(-15, 0)
		end

		if sprite:IsFinished("ChargeStart") then
			d.State = "apparitions"
		end
	-- spawning apparitions
	elseif d.State == "apparitions" then
		npc.Velocity = nilvector

		-- set position to further than far right of the room
		npc.Position = Vector(room:GetGridWidth() * 40 + 80, npc.Position.Y)

		local maxApparations = 150
		-- count frames
		d.StateFrame = d.StateFrame + 1
		if d.ApparitionCounter < maxApparations then
			-- spawn an apparition every 2 frames
			if d.StateFrame > 0 then
				-- x, y, velocity
				local apparitionX = (room:GetGridWidth() * 40) + 50
				local apparitionY = math.random(180, room:GetGridHeight() * 40 + 100)
				local apparitionVel = Vector(math.random(-15, -10), 0)

				local apparition = Isaac.Spawn(1000, 5032, 0, Vector(apparitionX, apparitionY), apparitionVel, npc)
				apparition.Parent = npc

				-- count apparition and reset frame counter
				d.ApparitionCounter = d.ApparitionCounter + 1
				d.StateFrame = 0
			end
		elseif mod.GetEntityCount(1000, 5032) == 0 then
			npc.Position = Vector(npc.Position.X + math.random(-80, 80), math.random(180, room:GetGridHeight() * 40 + 100))
			npc.Velocity = Vector(-8, 0)
			d.State = "reappear"

			-- reset frame counter and apparition counter
			d.ApparitionCounter = 0
			d.StateFrame = 0
		end
	-- reappearing
	elseif d.State == "reappear" then
		-- gradually lower velocity
		npc.Velocity = npc.Velocity * 0.99

		-- stop charging animation
		mod:spritePlay(sprite, "Halt")

		if sprite:IsEventTriggered("Stop") then
			npc.Velocity = nilvector
		end
		if sprite:IsFinished("Halt") then
			-- idle again
			d.State = "roam"
		end
	-- vanish on room clear
	elseif d.State == "vanish" then
		mod:spritePlay(sprite, "Death")

		if sprite:IsFinished("Death") then
			npc:Remove()
		end
	end
end

mod.mistmongerChargeAnims = {"Charge01", "Charge02", "Charge03"}

function mod:MistmongerApparitionUpdate(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local r = npc:GetDropRNG()

	if not d.Init then
		-- play random charge sprite
		mod:spritePlay(sprite, mod.mistmongerChargeAnims[math.random(#mod.mistmongerChargeAnims)])
		-- set alpha to 0 to fade in
		npc:SetColor(Color(1, 1, 1, 0, 0, 0, 0), 0, 9999, false, false)
		d.fade = 0

		-- each apparition is a different alpha
		d.thisAlpha = math.random(5, 10) / 10
		-- fade in, fade out
		d.FadeType = ""

		d.Init = true
	end

	-- fade in when almost in room
	if d.FadeType == "" and npc.Position.X < (game:GetRoom():GetGridWidth() * 40) + 50 then
		d.FadeType = "fade in"
	end

	-- fade in
	if d.FadeType == "fade in" then
		d.fade = d.fade + 0.1
		if d.fade > d.thisAlpha then d.fade = d.thisAlpha end

		npc:SetColor(Color(1, 1, 1, d.fade, 0, 0, 0), 0, 9999, false, false)
	-- fade out
	elseif d.FadeType == "fade out" then
		d.fade = d.fade - 0.05
		if d.fade < 0 then d.fade = 0 end

		npc:SetColor(Color(1, 1, 1, d.fade, 0, 0, 0), 0, 9999, false, false)
	end

	-- if apparition far enough to the left or mistmonger somehow disappears, begin fading out
	if npc.Position.X < 10 or npc.Parent == nil then
		d.FadeType = "fade out"

		-- remove mistmonger apparition when fully faded out
		if d.fade <= 0 then
			npc:Remove()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.MistmongerApparitionUpdate, 5032)
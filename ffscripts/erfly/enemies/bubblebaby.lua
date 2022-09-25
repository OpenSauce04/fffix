local mod = FiendFolio
local game = Game()

--bbdb, bubble blowing double baby
function mod:bubbleBabyAI(npc, subt)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()

	if not d.init then
		d.state = "idle"
		d.init = true
	else
		if not mod:isScareOrConfuse(npc) then
			npc.StateFrame = npc.StateFrame + 1
		end
	end

	--Movement
		local targetvelocity = ((mod:randomConfuse(npc, target.Position) + RandomVector():Resized(100)) - (npc.Position + RandomVector():Resized(100))):Resized(1.2)
		targetvelocity = mod:reverseIfFear(npc, targetvelocity)
		npc.Velocity = mod:Lerp(npc.Velocity, targetvelocity, 0.2)

	--Double baby
	if not (subt == 1 or subt == 2) then

		if d.state == "idle" then
			mod:spritePlay(sprite, "idle")
			if npc.StateFrame > 60 and r:RandomInt(20)+1 == 1 and (target.Position - npc.Position):Length() < 200 and not mod:isScareOrConfuse(npc) then
				d.state = "shoot"
			end
		elseif d.state == "shoot" then
			if sprite:IsFinished("spit") then
				d.state = "idle"
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("shootv") then
				npc:PlaySound(SoundEffect.SOUND_LITTLE_SPIT,0.6,0,false,1.15)
				for i = -30, 30, 60 do
					mod.ShootBubble(npc, 1, npc.Position, (target.Position - npc.Position):Resized(6):Rotated(i))
				end
			else
				mod:spritePlay(sprite, "spit")
			end
		end

		if npc:IsDead() then
			local vectie = Vector(20, 0)
			for i = 1, 2 do
				local db = mod.spawnent(npc, npc.Position, vectie:Rotated(i*180), mod.FF.BubbleBaby.ID, mod.FF.BubbleBaby.Var, i)
				db.HitPoints = db.MaxHitPoints * 2/3
				db:GetData().ChangedHP = true
				db:GetData().HPIncrease = 0.1
			end
		end

	--Split babies
	else
		if d.state == "idle" then
			mod:spritePlay(sprite, "idle" .. subt)
			if npc.StateFrame > 60 and r:RandomInt(20)+1 == 1 and (target.Position - npc.Position):Length() < 200 and not mod:isScareOrConfuse(npc) then
				d.state = "shoot"
			end

		elseif d.state == "shoot" then
			if sprite:IsFinished("spit" .. subt) then
				d.state = "idle"
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("shootline") then
				npc:PlaySound(SoundEffect.SOUND_LITTLE_SPIT,0.6,0,false,1.15)
				mod.ShootBubble(npc, 0, npc.Position, (target.Position - npc.Position):Resized(10))
			else
				mod:spritePlay(sprite, "spit" .. subt)
			end
		end
	end
end

function mod:bubbleBabyColl(npc1, npc2)
    local d = npc1:GetData()
    if d.state == "idle" and npc2:IsEnemy() then
        d.changeDir = true
    end
end
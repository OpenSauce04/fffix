local mod = FiendFolio
local nilvector = Vector.Zero

function mod:babyBatAI(npc)
	local d = npc:GetData()
	local r = npc:GetDropRNG()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local sprite = npc:GetSprite()

	npc.StateFrame = npc.StateFrame + 1

	if npc.FrameCount == 5 then
		if npc.SubType == 7000 then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		end
	end

	if npc.State == 4 then
		mod:spritePlay(sprite, "Idle")
		npc.Velocity = npc.Velocity * 0.98
		if sprite:IsEventTriggered("Flap") then
			local targetvel = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(10))
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.1)
		end
		if npc.Position:Distance(targetpos) < 100 and npc.StateFrame > 25 then
			npc:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR,1,0,false,1.5)
			npc.State = 8
			npc.StateFrame = 0
		end
	elseif npc.State == 8 then
		mod:spritePlay(sprite, "Dash")
		if sprite:IsEventTriggered("Flap") then
			local targetvel = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(20))
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.05)
		end
		if npc.StateFrame > 25 then
			npc.State = 4
			npc.StateFrame = 0
		end
	else
		npc.State = 4
		npc.SpriteOffset = Vector(0,-15)
	end
end

local mod = FiendFolio

function mod:ringFlyOcter(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:confusePos(npc, target.Position, 50)

	mod:spritePlay(sprite, "Fly")
	npc.SpriteOffset = Vector(0, -16)

	local speed = (targetpos - npc.Position):Rotated(30):Resized(5)
	if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE) then
		speed = speed / 2
		npc.CollisionDamage = 0
	end
	npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, speed), 0.15)

	if npc:IsDead() and not mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE) then
		for i = 45, 360, 45 do
			local vec = Vector(15,0):Rotated(i)
			local ringfly = Isaac.Spawn(222, 0, 0, npc.Position + vec, vec, npc)
			ringfly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			ringfly:Update()
		end
	end
end
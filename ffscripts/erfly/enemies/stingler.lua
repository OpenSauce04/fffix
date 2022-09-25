local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:stinglerAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()

	npc.StateFrame = npc.StateFrame + 1

	if d.hurt then
		if mod:isScareOrConfuse(npc) then
			d.hurt = false
		end
		if sprite:IsFinished("Stinger") then
			d.hurt = false
			npc.StateFrame = -30
		elseif sprite:IsEventTriggered("Shoot") then
			local vec = RandomVector()
			npc:PlaySound(mod.Sounds.FrogShoot,0.7,0,false,math.random(12,14)/10)
			if npc.SpawnerType == EntityType.ENTITY_FISTULA_SMALL and npc.SpawnerVariant == 0 then
				mod.shootStinger(npc, npc.Position + vec*15, vec*9, 2)
			else
				mod.shootStinger(npc, npc.Position + vec*15, vec*9, 3)
			end
		else
			mod:spritePlay(sprite, "Stinger")
		end
	else
		mod:spritePlay(sprite, "Fly")
	end

	local targvel = mod:diagonalMove(npc, 3, 1)
	if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE) then
		targvel = targvel / 2
	end
	npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.1)
end

function mod:stinglerHurt(npc, damage, flag, source)
    if npc:ToNPC().StateFrame > 0 then
        local d = npc:GetData()
        d.hurt = true
    end
end

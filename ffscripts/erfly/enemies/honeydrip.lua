local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:honeydripAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not d.init then
		d.state = "idle"
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	npc.SpriteOffset = Vector(0, -15)

	if d.state == "idle" then
		mod:spritePlay(sprite, "Fly")
		local targspeed = 2.5
		if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE) then
			targspeed = targspeed / 2
		end
		mod:diagonalMove(npc, targspeed)
		if (not mod:isScareOrConfuse(npc)) and npc.StateFrame > 50 and game:GetRoom():GetGridCollisionAtPos(npc.Position) ~= GridCollisionClass.COLLISION_PIT then
			d.state = "slam"
		end
	elseif d.state == "slam" then
		npc.Velocity = npc.Velocity * 0.8
		if sprite:IsFinished("Slam") then
			npc.StateFrame = 0
			d.state = "idle"
		elseif sprite:IsPlaying("Slam") and sprite:GetFrame() == 1 then
			npc:PlaySound(mod.Sounds.BeeBuzzPrep, 1, 0, false, math.random(110,120)/100)
		elseif sprite:IsPlaying("Slam") and sprite:GetFrame() == 10 then
			npc:PlaySound(mod.Sounds.BeeBuzzDown, 1, 0, false, math.random(140,150)/100)
		elseif sprite:IsEventTriggered("Slam") then
			npc:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND,0.7,2,false,math.random(165,175)/100)
			local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, npc.Position, nilvector, npc):ToEffect()
			wave.Parent = npc
			wave.MinRadius = 20
			wave.MaxRadius = 40
			wave.Timeout = 2

		elseif sprite:IsEventTriggered("GetOut") then
			npc:PlaySound(SoundEffect.SOUND_PLOP,0.7,2,false,math.random(8,12)/10)
			if mod.GetEntityCount(256) < 7 then
				npc:PlaySound(SoundEffect.SOUND_SUMMONSOUND, 0.6, 0, false, 1)
				local baby = Isaac.Spawn(256, 0, 0, npc.Position, RandomVector() * 3, npc);
				baby:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				baby:Update()
			end
		else
			mod:spritePlay(sprite, "Slam")
		end
	end
end
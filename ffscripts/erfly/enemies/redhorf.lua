local mod = FiendFolio
local game = Game()
local rng = RNG()
local nilvector = Vector.Zero

function mod:redHorfAI(npc, subt, variant)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	d.Explosiveness = d.Explosiveness or 0

	if variant == mod.FF.ShittyHorf.Var and not d.init then
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
		d.init = true
	end

	npc.Velocity = npc.Velocity * 0.8

	local distance = target.Position:Distance(npc.Position)
	if d.dying then
		mod:spritePlay(sprite, "Death")
		if sprite:IsEventTriggered("Explode") then
			d.dying = false
			--d.Explosiveness = 50
			npc:Kill()
		end
	else
		if distance < 160 and not mod:isConfuse(npc) then
			d.Explosiveness = d.Explosiveness + (30 * (1/(distance/3)))
		elseif distance > 200 or mod:isConfuse(npc) then
			if d.Explosiveness > 0 then
				d.Explosiveness = d.Explosiveness - 1
			end
		end

		if d.Explosiveness > 100 or mod:isScare(npc) then
			d.dying = true
		elseif d.Explosiveness > 66 then
			mod:spritePlay(sprite, "Shake03")
		elseif d.Explosiveness > 33 then
			mod:spritePlay(sprite, "Shake02")
		else
			mod:spritePlay(sprite, "Shake01")
		end
	end

	if npc:IsDead() then
		npc:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR,1,0,false,1)
		local params = ProjectileParams()
		if variant == mod.FF.ShittyHorf.Var then
			params.Variant = 3
			if rng:RandomFloat() <= 0.5 then
				params.BulletFlags = params.BulletFlags | ProjectileFlags.CURVE_RIGHT
			else
				params.BulletFlags = params.BulletFlags | ProjectileFlags.CURVE_LEFT
			end
			params.CurvingStrength = 0.015
		end
		if d.Explosiveness > 66 then
			for i = 0, 360, 45 do
				params.FallingAccelModifier = -0.05
				npc:FireProjectiles(npc.Position, Vector(0,9):Rotated(i), 0, params)
			end
		elseif d.Explosiveness > 33 then
			for i = 0, 360, 45 do
				npc:FireProjectiles(npc.Position, Vector(0,6):Rotated(i), 0, params)
			end
		else
			for i = 45, 315, 90 do
				npc:FireProjectiles(npc.Position, Vector(0,6):Rotated(i), 0, params)
			end
		end
	end
end
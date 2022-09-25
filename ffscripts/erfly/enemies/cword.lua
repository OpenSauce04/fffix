local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:cwordAI(npc)
	local sprite = npc:GetSprite();
	local d = npc:GetData();
	local target = npc:GetPlayerTarget()

	if not d.init then
		d.init = true
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
		d.state = "idle"
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	npc.RenderZOffset = -5000
	npc.Velocity = nilvector

	if game:GetRoom():IsClear() then
		d.state = "die"
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		d.extracount = d.extracount or 0
		if npc.StateFrame > (30 + d.extracount) * mod.GetEntityCount(mod.FF.CWord.ID, mod.FF.CWord.Var) then
			if mod.GetEntityCount(mod.FF.Neonate.ID, mod.FF.Neonate.Var) < 5 then
				d.extracount = d.extracount + 15
				d.state = "spawn"
			else
				npc.StateFrame = 30
			end
		end
	elseif d.state == "spawn" then
		if sprite:IsFinished("Spawn") then
			npc.StateFrame = 0
			d.state = "idle"
		elseif sprite:IsEventTriggered("Spawn") then
			npc:PlaySound(SoundEffect.SOUND_MEATY_DEATHS,1,0,false,0.7)
			local neonate = Isaac.Spawn(mod.FF.Neonate.ID, mod.FF.Neonate.Var, 0, npc.Position, (target.Position - npc.Position):Resized(3), npc)
			neonate:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			neonate:Update()

			local bloodSplat = Isaac.Spawn(1000, 2, 2, npc.Position, nilvector, npc)
			bloodSplat.SpriteScale = Vector(2,2)
			bloodSplat.Color = Color(0.6,0.6,0.6,1,0,0,0)
			bloodSplat:Update()
		else
			mod:spritePlay(sprite, "Spawn")
		end
	elseif d.state == "die" then
		if sprite:IsFinished("Death") or sprite:IsEventTriggered("Explode") then
			npc:Kill()
		else
			mod:spritePlay(sprite, "Death")
		end
	end
end

function mod:neonateAI(npc)
	local sprite = npc:GetSprite();
	local d = npc:GetData();
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)

	if not d.init then
		d.state = "idle"
		d.init = true
		npc.StateFrame = 20
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Move")
		local targetvel = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(3))
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.1)
		if npc.StateFrame > 30 and math.random(5) == 1 and not mod:isScareOrConfuse(npc) then
			d.state = "attack"
		end
	elseif d.state == "attack" then
		npc.Velocity = npc.Velocity * 0.95
		if sprite:IsFinished("Attack") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(mod.Sounds.FlashBaby,1,0,false,math.random(85,115)/100)
			local params = ProjectileParams()
			params.Scale = 2
			d.shootvec = (target.Position - npc.Position):Resized(7)
			npc:FireProjectiles(npc.Position, d.shootvec, 0, params)
			d.shooting = 0
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "Attack")
		end
	end

	if d.shooting and npc.StateFrame % 4 == 3 then
		d.shooting = d.shooting + 1
		local params = ProjectileParams()
		params.Scale = 2 - (0.5 * d.shooting)
		npc:FireProjectiles(npc.Position, d.shootvec, 0, params)
		if d.shooting == 3 then
			d.shooting = nil
		end
	end
end
local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:cordifyAI(npc, variant)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	npc.Velocity = npc.Velocity * 0.2

	if not d.init then
		d.init = true
		d.state = "idle"
		d.timesdone = 0
		d.randval = math.random(10)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		if (not mod:isScareOrConfuse(npc)) and npc.StateFrame > 50 + d.timesdone + d.randval then
			local enmy = mod.FindClosestEntityPrimeMind(target.Position,99999999,{npc}, true)
			if enmy then
				d.state = "attack"
			else
				if --[[game:GetRoom():IsClear()]] not mod.AreThereEntitiesButNotThisOne(mod.FF.Cordify.ID, nil, mod.FF.Cordify.Var) then
					d.state = "attack"
					d.suicidal = true
				else
					npc.StateFrame = npc.StateFrame - 10
				end
			end
		end
	elseif d.state == "attack" then
		if sprite:IsFinished("Shoot") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			if d.suicidal or mod:isScareOrConfuse(npc) then
				game:Fart(npc.Position, 80, npc, 1.6, 0)
				game:BombExplosionEffects(npc.Position, 9, TearFlags.TEAR_POISON, Color(0, 0, 0, 0, 0, 0, 0), npc, 1.3, false, true)
				npc:Kill()
			else
				d.randval = math.random(10)
				d.timesdone = d.timesdone + 10
				local enmy = mod.FindClosestEntityPrimeMind(target.Position,99999999,{npc}, true)
				if enmy then
					enmy:GetData().cordified = true
					npc:PlaySound(SoundEffect.SOUND_SUMMONSOUND,1,1,false,1)
					local poof = Isaac.Spawn(1000, 15, 0, enmy.Position, nilvector, enmy):ToEffect()
					poof.Color = Color(1,2,1,1,0,0,0)
					poof:Update()
					local marker = Isaac.Spawn(1000, 1731, 0, enmy.Position, nilvector, enmy):ToEffect()
					marker:FollowParent(enmy)
					marker:Update()
				else
					game:Fart(npc.Position, 40, npc, 1, 0)
				end
			end
		else
			mod:spritePlay(sprite, "Shoot")
		end
	end

end

function mod:cordifyMarker(e)
	mod:spritePlay(e:GetSprite(), "Idle")
	if e.Parent then
		e.SpriteOffset = Vector(0.5, -e.Parent.Size*3.5)
	end
	if e.Parent and e.Parent:IsDead() or not e.Parent then
		game:Fart(e.Position, 40, e.Parent, 1, 0)
		game:BombExplosionEffects(e.Position, 9, TearFlags.TEAR_POISON, Color(0, 0, 0, 0, 0, 0, 0), e.Parent, 1, false, true)
		e:Remove()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.cordifyMarker, 1731)
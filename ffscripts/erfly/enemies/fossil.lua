local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

--Fossilbro
function mod:fossilAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not d.init then
		d.state = "idle"
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		npc.SplatColor = mod.ColorInvisible
		d.init = true
	elseif d.init then
		npc.StateFrame = npc.StateFrame + 1
	end

	npc.Velocity = nilvector

	if target.Position.X < npc.Position.X then
		sprite.FlipX = true
	else
		sprite.FlipX = false
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		if npc.StateFrame > 20 and math.random(5) == 1 then
			if game:GetRoom():CheckLine(npc.Position,target.Position,0,3,false,false) and not (mod:isScare(npc) or mod:isConfuse(npc)) then
				d.state = "shoot"
			else
				if npc.StateFrame > 50 then
					d.state = "submerge"
					npc.StateFrame = 5
				end
			end
		end
	elseif d.state == "shoot" then
		if sprite:IsFinished("Shoot") then
			d.state = "submerge"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1)
			local params = ProjectileParams()
			params.HeightModifier = 15
			params.FallingAccelModifier = -0.1
			params.FallingSpeedModifier = 0
			npc:FireProjectiles(npc.Position, (target.Position - npc.Position):Normalized()*7, 0, params)
		else
			mod:spritePlay(sprite, "Shoot")
		end
	elseif d.state == "submerge" then
		if sprite:IsFinished("Submerge") then
			if npc.StateFrame > 10 then
				d.state = "appear"
				npc.Position = mod:FindRandomGravity(npc)
			end
		else
			mod:spritePlay(sprite, "Submerge")
			npc.StateFrame = 0
		end
	elseif d.state == "appear" then
		if sprite:IsFinished("Appear") then
			d.state = "idle"
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "Appear")
		end
	end
end

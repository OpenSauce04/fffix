local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:beeterAI(npc)
	local sprite  = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()

	if not d.init then
		d.astate = 1
		d.state = "idle"
		d.init = true
		d.speed = 3
		d.attackang = RandomVector():GetAngleDegrees()
	elseif d.init then
		npc.StateFrame = npc.StateFrame + 1
	end

	if target.Position.X < npc.Position.X then
		sprite.FlipX = true
	else
		sprite.FlipX = false
	end

	local targetVelocity = (mod:randomConfuse(npc,target.Position) - npc.Position):Resized(d.speed)
	npc.Velocity = mod:Lerp(npc.Velocity, targetVelocity, 0.1)

	if d.state == "idle" then
		d.speed = 3
		d.speed = mod:reverseIfFear(npc, d.speed)
		mod:spritePlay(sprite, "Fly" .. d.astate)
		if r:RandomInt(10)+1 == 1 and npc.StateFrame > 10 and (target.Position - npc.Position):Length() < 250 and game:GetRoom():CheckLine(target.Position,npc.Position,3,900,false,false) and not (mod:isScareOrConfuse(npc) or mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE)) then
			d.state = "attack"
			d.count = 0
		end
	elseif d.state == "attack" then
		d.speed = 1
		d.speed = mod:reverseIfFear(npc, d.speed)
		if sprite:IsFinished("Shoot" .. d.astate) then
			d.astate = d.astate + 1
			d.count = d.count + 1
			if d.astate > 2 then
				d.astate = 1
			end
			if d.count > 5 then
				d.state = "idle"
				npc.StateFrame = 0
			end
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1)
			local params = ProjectileParams()
			params.FallingAccelModifier = 0.4
			params.Scale = 0.7
			for i = 1, 3 do
				npc:FireProjectiles(npc.Position, Vector(7,0):Rotated((120*i+d.attackang)), 0, params)
			end
			d.attackang = d.attackang + 30
		else
			mod:spritePlay(sprite, "Shoot" .. d.astate)
		end
	end
end

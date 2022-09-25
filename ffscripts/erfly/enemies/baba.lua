local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.babadirs = {
	[0] = "Up",
	[1] = "Right",
	[2] = "Down",
	[3] = "Left",
}

mod.babamovetimes = {15, 15, 15, 10, 10, 5}

function mod:babaIsEnemy(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
    local room = game:GetRoom()
	npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)

	if not d.init then
		d.init = true
		d.moveframe = 1
		d.babamovetime = 15
		npc.SplatColor = Color(0,0,0,1,1,1,1)
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if npc.StateFrame % d.babamovetime == 0 then
		local possibletargs = {}
		for i = 0, 3 do
			local nextgrid = npc.Position + Vector(0, -40):Rotated(i * 90)
			if room:GetGridCollisionAtPos(nextgrid) == GridCollisionClass.COLLISION_NONE then
				table.insert(possibletargs, {nextgrid, mod.babadirs[i]})
			end
		end
		if #possibletargs > 0 then
			local rand = math.random(#possibletargs)
			d.target = room:FindFreeTilePosition(possibletargs[rand][1], 10)
			d.moveframe = d.moveframe + 1
			if d.moveframe == 5 then d.moveframe = 1 end
			mod:spritePlay(sprite, possibletargs[rand][2] .. d.moveframe)
			npc:PlaySound(mod.Sounds.Baba, 2, 0, false, 1)
			local smoke = Isaac.Spawn(1000, 1729, 0, npc.Position, nilvector, npc):ToEffect();
			smoke.Color = Color(0,0,0,1,1,1,1)
			smoke.SpriteOffset = Vector(0,-10)
			smoke:Update()
		end
		d.babamovetime = mod.babamovetimes[math.random(#mod.babamovetimes)]
	end
	d.target = d.target or npc.Position
	local dist = npc.Position:Distance(d.target)
	if dist > 5 then
		npc.Velocity = (d.target - npc.Position):Resized(dist/2)
	else
		if dist < 5 or npc.StateFrame % d.babamovetime == 4 then
			npc.Velocity = nilvector
			npc.Position = d.target
		end
	end
end
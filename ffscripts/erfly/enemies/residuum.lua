local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:residuumAI(npc, subt)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	d.Clouds = d.Clouds or {}

	npc.StateFrame = npc.StateFrame + 1

	mod:spritePlay(sprite, "Idle")
	local targvel = mod:diagonalMove(npc, 2, 1)
	npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.5)

	if npc.StateFrame % 20 == 1 then
		local cloud = Isaac.Spawn(1000, 141, 1, npc.Position, nilvector, npc):ToEffect()
		--cloud:SetTimeout(1000)
		cloud:Update()
		table.insert(d.Clouds, cloud)
	end
	if npc:CollidesWithGrid() then
		for i = 1, #d.Clouds do
			d.Clouds[i]:SetTimeout(30)
		end
		npc.StateFrame = 0
	end
end
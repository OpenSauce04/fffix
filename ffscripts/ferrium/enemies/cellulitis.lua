local mod = FiendFolio

function mod:cellulitisAI(npc)
	local rand = npc:GetDropRNG()
	local target = npc:GetPlayerTarget()
	local sprite = npc:GetSprite()
	if sprite:IsEventTriggered("Shoot") then
		for i = 0, 8 do
			local params = ProjectileParams()
			params.FallingSpeedModifier = -(5+rand:RandomInt(8))
			params.FallingAccelModifier = (rand:RandomInt(5)+5)/7
			params.Scale = (10+rand:RandomInt(12))/16
			npc:FireProjectiles(npc.Position, (target.Position-npc.Position):Resized(3+rand:RandomInt(18)/3):Rotated(-20+rand:RandomInt(40)), 0, params)
		end
	end
	if npc.FrameCount % 12 == 0 then
		local creep = Isaac.Spawn(1000, 22, 0, npc.Position, Vector.Zero, npc):ToEffect()
		creep.SpriteScale = Vector(1.8, 1)
		creep:SetTimeout(230)
		creep:Update()
	end
	if npc:IsDead() then
		--Gutcheck fixes Skulltist interaction for some reason
		local gutcheck = false
		for _, gut in ipairs(Isaac.FindByType(40, 0, -1, false, false)) do
			if gut.SpawnerType == 57 and gut.SpawnerVariant == 114 and gut.Position:Distance(npc.Position) < 20 and gut.FrameCount < 1 then
				gut:ToNPC():Morph(40,1,gut.SubType,-1)
				gutcheck = true
			end
		end
		if gutcheck then
			local randVec = Vector(0,10):Rotated(rand:RandomInt(360))
			--[[for i = 0, 1 do
				Isaac.Spawn(40, 1, 0, npc.Position+randVec:Rotated(180*i), Vector.Zero, npc)
			end]]
			Isaac.Spawn(310, 1, 0, npc.Position+randVec:Rotated(90), Vector.Zero, npc)
		end
	end
end
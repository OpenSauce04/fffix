local mod = FiendFolio

mod.KNOT_ACTIVATION_RADIUS = 80

local function IsKnotAllowedToDisperse(npc)
	return npc:GetSprite():IsPlaying("Idle") and not (
		npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) or
		npc:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE)
	)
end

local function GetSpawn(tbl, rng)
	local totalWeight = 0
	for _, data in pairs(tbl) do
		totalWeight = totalWeight + data.Weight
	end

	local roll = rng:RandomFloat() * totalWeight

	for _, data in pairs(tbl) do
		if roll < data.Weight then
			return data.Entity
		else
			roll = roll - data.Weight
		end
	end
end

local frameWindowToSpawnGroup = {
	[0] = "Heavy",
	[1] = "Medium",
	[2] = "Light",
}

return {
	Init = function(npc)
		npc.SpriteRotation = npc.SubType * 90
		npc:GetSprite():Play("Appear")

		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

		mod.XalumInitNpcRNG(npc)
	end,

	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		mod.NegateKnockoutDrops(npc)
		mod.QuickSetEntityGridPath(npc)

		if sprite:IsFinished("Appear") then
			sprite:Play("Idle")
		elseif sprite:IsFinished("Disperse") then
			npc:Remove()
		end

		if npc.FrameCount >= 45 and IsKnotAllowedToDisperse(npc) and #Isaac.FindInRadius(npc.Position, mod.KNOT_ACTIVATION_RADIUS, EntityPartition.PLAYER) > 0 then
			sprite:Play("Disperse")
		end

		if sprite:IsPlaying("Disperse") then
			if sprite:GetFrame() % 6 == 0 then
				local window = math.floor(sprite:GetFrame() / 12)
				local group = frameWindowToSpawnGroup[window]

				local entityData = GetSpawn(mod.KnotSpawnTables[group], data.rng)
				local entity = Isaac.Spawn(entityData[1], entityData[2], entityData[3], npc.Position, Vector(1, 1):Rotated(npc.SpriteRotation), npc)
				entity:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

				entity:SetColor(Color(1, 1, 1, 0, 0, 0, 0), 5, 0, true, false)
			end
		end
	end,

	Damage = function(npc, amount, flags)
		if flags & DamageFlag.DAMAGE_POISON_BURN == 0 and IsKnotAllowedToDisperse(npc) then
			mod:applyFakeDamageFlash(npc)
			npc:GetSprite():Play("Disperse")
		end

		return false
	end,
}
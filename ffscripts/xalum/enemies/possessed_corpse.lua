local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		if not npc:GetData().Init then
			npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
			npc:GetData().Init = true
		end
		local sprite = npc:GetSprite()
		npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
		if npc.FrameCount >= 22 then
			sprite:Play("Idle", false)
		else
			sprite:SetFrame("Dead", npc.FrameCount)
		end

		npc.Mass = 99
		npc.Velocity = Vector.Zero
		mod.QuickSetEntityGridPath(npc)

		npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

		if game:GetRoom():IsClear() then
			npc:Die()
		end
	end,
	Damage = function()
		return false
	end,
	Collision = function(_, collider)
		if collider:IsFlying() then return true end
	end,
}
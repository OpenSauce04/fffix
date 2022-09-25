local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc) -- p sure this guy is unused, at least I don't think he's in any rooms
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if not data.init then
			npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
			data.init = true
		end

		if sprite:IsFinished("Appear") then
			sprite:Play("Idle")
		end

		if sprite:IsPlaying("Idle") and sprite:GetFrame() == 41 then
			math.randomseed(npc.Index + npc.FrameCount)
			--local traj = Vector(3, 0):Rotated(math.random(360))
			local traj = Vector(1, 0):Rotated(math.random(360))
			local e = Isaac.Spawn(FiendFolio.FF.SporeProjectile.ID, FiendFolio.FF.SporeProjectile.Var, 0, npc.Position, traj, npc)
			e:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			e:GetSprite().Offset = Vector(0, -14)
			e:GetData().traj = traj
			e.Parent = npc
		end
	end,
}
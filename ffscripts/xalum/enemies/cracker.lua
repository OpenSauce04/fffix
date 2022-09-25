local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if sprite:IsFinished("Fall") then
			sprite:Play("Ribless")
		elseif sprite:IsFinished("Recover") then
			sprite:Play("Idle")
		elseif sprite:IsFinished("Jump") and data.frame + 13 <= npc.FrameCount then
			sprite:Play("Fall")
		elseif sprite:IsPlaying("Ribless") and data.frame + 41 <= npc.FrameCount then
			sprite:Play("Recover")
			sfx:Play(SoundEffect.SOUND_SCAMPER, 0.8, 0, false, 1.2)
		end

		if not data.init then
			if data.waited then
				sprite:Play("Fall")
				npc.Visible = true
			elseif npc.SubType == 1 then
				FiendFolio.makeWaitFerr(npc, npc.Type, npc.Variant, npc.SubType, 90, false)
			else
				sprite:Play("Idle")
			end
			data.frame = npc.FrameCount - 20
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
			data.init = true
		end

		if sprite:IsPlaying("Idle") then
			npc.Velocity = npc.Velocity * 0.6
			if data.frame + 50 <= npc.FrameCount then
				if (not FiendFolio:isScareOrConfuse(npc)) and npc.FrameCount % 4 == 0 and math.random(3) == math.random(3) then
					sprite:Play("Jump")
				end
			end
		elseif sprite:IsPlaying("Ribless") or sprite:IsPlaying("Recover") or npc.EntityCollisionClass == EntityCollisionClass.ENTCOLL_ALL then
			npc.Velocity = Vector.Zero
		end

		if sprite:IsEventTriggered("GetPlayer") then
			local pos = (npc:GetPlayerTarget().Position - npc.Position):Normalized() * math.min(300, (npc.Position - npc:GetPlayerTarget().Position):Length())
			data.target = game:GetRoom():FindFreeTilePosition(npc.Position + pos, 40) + (RandomVector())

			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS

			npc.Velocity = (data.target - npc.Position) / 15
			data.frame = npc.FrameCount
		end

		if sprite:IsEventTriggered("Land") then
			local a = math.random(0, 1)
			for i = 0, 3 do
				local projectile = Isaac.Spawn(9, 1, 0, npc.Position, Vector(10, 0):Rotated(45 + 90*i), npc):ToProjectile();
				projectile.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
				local s = projectile:GetSprite()
				s:Load("gfx/projectiles/boomerang rib big.anm2",true)
				s:Play("spin",false)
				projectile.Parent = npc
				projectile.FallingSpeed = 0
				projectile.FallingAccel = -0.1
				projectile.ProjectileFlags = projectile.ProjectileFlags | ProjectileFlags.CURVE_LEFT << a
				local pd = projectile:GetData()
				pd.projType = "boomerang2"
				pd.origpos = npc.Position
				pd.rot = 0
			end

			sfx:Play(SoundEffect.SOUND_BONE_SNAP, 0.6, 0, false, math.random(8, 12)/10)

			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			npc.Velocity = Vector.Zero
			data.frame = npc.FrameCount
		end

		if sprite:IsEventTriggered("Sound") then
			sfx:Play(SoundEffect.SOUND_BONE_SNAP, 0.6, 0, false, 1.8)
		end
	end
}
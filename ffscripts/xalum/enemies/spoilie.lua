local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc, data, sprite)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if not data.init then
			npc.SplatColor = FiendFolio.ColorIpecacProper
			data.fract = data.fract or 10
			data.init = true
		end

		if sprite:IsFinished("Appear") or sprite:IsFinished("RegenShort") then
			data.globinwalk = true

		end

		if sprite:IsPlaying("RegenShort") then npc.Velocity = npc.Velocity * 0.9 end

		if npc.FrameCount % 5 == math.random(3) then npc:MakeSplat(0.5).Color = FiendFolio.ColorIpecacProper end

		if data.globinwalk then
			npc:AnimWalkFrame("WalkHori", "WalkVert", 0.1)
			FiendFolio.Xalum_globinpathfind(npc, 5, npc:GetPlayerTarget().Position)

			if npc.FrameCount % 45 == 2 and math.random(3) < 3 then
				sfx:Play(SoundEffect.SOUND_ZOMBIE_WALKER_KID, 0.8, 0, false, 1)
			end
		end

		if npc:IsDead() and not sprite:IsPlaying("RegenShort") then
			local spider = Isaac.Spawn(215, 0, 0, npc.Position, npc.Velocity, npc)
			spider:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

			spider:GetSprite():Load("gfx/enemies/rotspin/monster_spoilie.anm2", true)

			spider.HitPoints = 30 * (data.fract / 10)
			spider.SplatColor = FiendFolio.ColorIpecacProper
			spider:GetData().IsSpoilie = true
			spider:GetData().fract = data.fract
		end
	end
}
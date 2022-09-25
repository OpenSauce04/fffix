local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		if npc.FrameCount % 5 == math.random(3) then npc:MakeSplat(0.5).Color = FiendFolio.ColorIpecacProper end

		if npc.FrameCount > 120 and math.random(5) == math.random(5) and not npc:GetSprite():IsPlaying("Jump") then
			npc:Morph(FiendFolio.FF.Spoilie.ID, FiendFolio.FF.Spoilie.Var, 0, npc:GetChampionColorIdx())
			npc:GetSprite():Play("RegenShort")
			FiendFolio:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, npc, 1, 1)
			npc.HitPoints = npc.MaxHitPoints * 2/3
			npc:GetData().fract = math.max(1, (npc:GetData().fract) - 1)
		end
	end,
}
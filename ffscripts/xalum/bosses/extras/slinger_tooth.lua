local mod = FiendFolio
local game = Game()

return {
	Init = function(npc)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND

		local data = npc:GetData()
		data.noblood = "gfx/enemies/toothache/toothache_tooth_bloodless.png"

		if npc.SubType == 1 then
			local sprite = npc:GetSprite()

			sprite:ReplaceSpritesheet(0, "gfx/bosses/slinger/slinger_tooth.png")
			sprite:ReplaceSpritesheet(1, "gfx/bosses/slinger/slinger_tooth.png")
			sprite:LoadGraphics()

			data.noblood = "gfx/bosses/slinger/slinger_tooth_bloodless.png"
		end
	end,

	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()
		local room = game:GetRoom()

		if sprite:IsFinished("Appear") then
			sprite:Play("Idle")
		end

		local noCreep = (room:IsClear() or npc.FrameCount > 600)
		if npc.FrameCount % 45 == 1 and not noCreep then
			local creep = Isaac.Spawn(1000, 22, 0, npc.Position, Vector(0, 0), npc):ToEffect()
			creep.SpriteScale = creep.SpriteScale * 3
			creep.Scale = 0.75

			local backdrop = room:GetBackdropType()
			if backdrop == BackdropType.WOMB or backdrop == BackdropType.UTERO then
				creep.Color = mod.ColorSortaRed
			end

			creep:Update()
		elseif noCreep and not data.bloodless then
			sprite:ReplaceSpritesheet(0, data.noblood)
			sprite:ReplaceSpritesheet(1, data.noblood)
			sprite:LoadGraphics()

			data.bloodless = true
		end

		npc.Velocity = Vector.Zero
	end,

	Death = function(npc)
		mod:PlaySound(SoundEffect.SOUND_BOIL_HATCH, npc, 1, 0.8)
		mod:PlaySound(SoundEffect.SOUND_DEATH_BURST_BONE, npc, 2, 0.5)

		for i = 0, 2 do
			Isaac.Spawn(1000, 35, 0, npc.Position, RandomVector():Resized(math.random() * 4), npc)
		end
	end,
}
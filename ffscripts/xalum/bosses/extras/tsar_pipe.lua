local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc)
		npc.State = 0
		npc.Velocity = Vector.Zero

		mod.QuickSetEntityGridPath(npc)

		local dat = npc:GetData()
		local spr = npc:GetSprite()

		if spr:IsFinished("Shoot") then
			spr:Play("Idle")

			if dat.orbtime then
				dat.orbtime = false

				dat.tsar:GetSprite():Play("Grate")
				dat.tsar:GetData().state = "grated"
				dat.tsar:GetData().delay = dat.tsar.FrameCount + 10

				mod.tsarChangeGrate(dat.tsar)
			end
		end

		local varhori = (npc.SubType & 1 == 1)		-- 0: Vertical; 1:Horizontal
		local pipeType = (npc.SubType & ~ 1) >> 1 	-- 0: Septic; 1: Piss; 2: Poop; 3:Dank

		if not dat.facing then
			dat.tsar = Isaac.FindByType(mod.FF.Tsar.ID, mod.FF.Tsar.Var, -1)[1]

			dat.creeptype = 24 -- Green
			dat.bloodcol = mod.ColorMysteriousLiquid

			if pipeType == 1 then	-- Pee
				dat.creeptype = 26
				dat.bloodcol = mod.ColorPeepPiss

				spr:ReplaceSpritesheet(0, "gfx/bosses/tsar/boss_tsarpipepee.png")
			elseif pipeType == 2 then	-- Poop
				dat.creeptype = 94
				dat.bloodcol = mod.ColorPoop

				spr:ReplaceSpritesheet(0, "gfx/bosses/tsar/boss_tsarpipepoop.png")
			elseif pipeType == 3 then	-- Dank
				dat.creeptype = 23
				dat.bloodcol = mod.ColorDankBlackReal

				spr:ReplaceSpritesheet(0, "gfx/bosses/tsar/boss_tsarpipetar.png")
			end

			spr:LoadGraphics()

			-- Stealing (but slightly modifying) orientation code from the orignal pipes, thank you whoever coded those

			local room = game:GetRoom()

			npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
			if varhori then
				local Rpos = room:GetClampedPosition(npc.Position + Vector(40, 0), 0)
				local Lpos = room:GetClampedPosition(npc.Position + Vector(-40, 0), 0)

				local Rdist =  npc.Position:Distance(Rpos)
				local Ldist =  npc.Position:Distance(Lpos)

				if Rdist > Ldist then
					npc.Position = Lpos + Vector(-10, 0)
					npc.SpriteRotation = 270
					dat.facing = Vector(1, 0)
				else
					npc.Position = Rpos + Vector(10, 0)
					npc.SpriteRotation = 90
					dat.facing = Vector(-1, 0)
				end
			else
				local abovepos = room:GetClampedPosition(npc.Position + Vector(0, -40), 0)
				local belowpos = room:GetClampedPosition(npc.Position + Vector(0, 40), 0)

				local abovedist =  npc.Position:Distance(abovepos)
				local belowdist =  npc.Position:Distance(belowpos)

				if abovedist > belowdist then
					npc.Position = belowpos + Vector(0, 10)
					npc.SpriteRotation = 180
					dat.facing = Vector(0, -1)
				else
					npc.Position = abovepos + Vector(0, -10)
					dat.facing = Vector(0, 1)
				end
			end
		end

		if spr:IsPlaying("Shoot") and spr:GetFrame() == 41 then
			if dat.orbtime then
				sfx:Play(mod.Sounds.ShotgunBlast, 1, 0, false, 1)
			else
				npc:PlaySound(mod.Sounds.ShotgunBlast, 1, 0, false, 1)
			end
		end

		if spr:IsEventTriggered("Shoot") then
			mod.doTsarPipeShoot[pipeType](npc, dat.tsar, not dat.orbtime)
		end
	end
}
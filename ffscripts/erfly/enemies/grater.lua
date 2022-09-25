local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:graterAI(npc)
	local sprite = npc:GetSprite();
	local d = npc:GetData();
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()

	npc.Velocity = nilvector

	if not mod.graterInRoom then
		mod.graterInRoom = true
	end

	if not d.init then
		if d.waited then
			mod.graterInRoom = true
			d.passWaitingInfo:GetData().occupied = npc
			d.passWaitingInfo:Update()
			d.hole = d.passWaitingInfo
			d.state = "shake"
		elseif npc.SubType == 1 then
			local grate = mod.spawnent(npc, npc.Position, nilvector, mod.FF.Graterhole.ID, mod.FF.Graterhole.Var)
			grate:Update()
			d.passWaitingInfo = grate
			mod.makeWaitFerr(npc, npc.Type, npc.Variant, npc.SubType, -10)
		else
			d.state = "idle"
			mod.graterInRoom = true
			local grate = mod.spawnent(npc, npc.Position, nilvector, mod.FF.Graterhole.ID, mod.FF.Graterhole.Var)
			grate:GetData().occupied = npc
			grate:Update()
			d.hole = grate
		end
		npc.SplatColor = mod.ColorDankBlackReal
		npc.SpriteOffset = Vector(0,0.2)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if sprite:IsEventTriggered("DMG") then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
	elseif sprite:IsEventTriggered("NoDMG") then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	end


	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")

		if npc.StateFrame > 10 and r:RandomInt(10) == 0 then
			if d.readytogo then
				d.state = "burrow"
			elseif not mod:isScareOrConfuse(npc) then
				d.state = "attack"
			end
		end
	elseif d.state == "attack" then
		if sprite:IsFinished("Shoot") then
			d.state = "idle"
			d.readytogo = true
		elseif sprite:IsEventTriggered("Shoot") then
		npc:PlaySound(SoundEffect.SOUND_WORM_SPIT,1,0,false,0.9)
		local shotspeed = (target.Position - npc.Position)*0.05
		if shotspeed:Length() > 13 then
			shotspeed = shotspeed:Resized(13)
		end
		local projectile = Isaac.Spawn(9, 0, 0, npc.Position, shotspeed, npc):ToProjectile();
		projectile.FallingSpeed = -25
		projectile.FallingAccel = 1.5
		projectile.Scale = 2
		projectile.Color = mod.ColorDankBlackReal
		projectile:GetData().projType = "GraterShot"
		else
			mod:spritePlay(sprite, "Shoot")
		end
	elseif d.state == "burrow" then
		if sprite:IsFinished("Burrow") then
			if mod.GraterState then
				d.state = "eruptwait"
				d.hole:GetData().occupied = nil
				d.hole:Update()
				npc.Visible = false
			else
				local validgrates = {d.hole}
				for _, grate in pairs(Isaac.FindByType(mod.FF.Graterhole.ID, mod.FF.Graterhole.Var, -1, false, false)) do
					if not grate:GetData().occupied then
						table.insert(validgrates, grate)
					end
				end
				d.hole:GetData().occupied = nil
				d.hole:Update()
				d.hole = validgrates[math.random(#validgrates)]
				d.hole:GetData().occupied = npc
				npc.Position = d.hole.Position

				npc.StateFrame = 0
				d.state = "shake"
			end
		elseif sprite:IsPlaying("Burrow") and sprite:GetFrame() == 8 then
			npc:PlaySound(mod.Sounds.GraterBurrow, 0.3, 0, false, math.random(90,110)/100)
		else
			mod:spritePlay(sprite, "Burrow")
		end
	elseif d.state == "shake" then
		if npc.StateFrame > 10 then
			mod:spritePlay(sprite, "GrateShake")
			if not sfx:IsPlaying(mod.Sounds.GraterShake) then
				sfx:Play(mod.Sounds.GraterShake, 0.3, 0, true, 1)
			end
		end
		if npc.StateFrame > 40 then
			d.state = "emerge"
			sfx:Stop(mod.Sounds.GraterShake)
		end

	elseif d.state == "emerge" then
		if sprite:IsFinished("Emerge") then
			npc.StateFrame = 0
			d.readytogo = false
			d.state = "idle"
		elseif sprite:IsPlaying("Emerge") and sprite:GetFrame() == 1 then
			npc:PlaySound(mod.Sounds.GraterEmege, 0.3, 0, false, math.random(90,110)/100)
		else
			mod:spritePlay(sprite, "Emerge")
		end
	elseif d.state == "eruptwait" then
		if not mod.GraterState then
			local validgrates = {}
				for _, grate in pairs(Isaac.FindByType(mod.FF.Graterhole.ID, mod.FF.Graterhole.Var, -1, false, false)) do
					if not grate:GetData().occupied then
						table.insert(validgrates, grate)
					end
				end
				d.hole = validgrates[math.random(#validgrates)]
				d.hole:GetData().occupied = npc
				npc.Position = d.hole.Position

				npc.StateFrame = 0
				d.state = "shake"
				npc.Visible = true
		end
	end

end

function mod:grateholeAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()

	npc.State = 0
	npc.Velocity = nilvector

	if not d.init then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.RenderZOffset = -5000
	end

	if d.occupied then
		if d.occupied:IsDead() or mod:isStatusCorpse(d.occupied) then
			d.occupied = false
			npc.Visible = true
		else
			npc.Visible = false
		end
	else
		npc.Visible = true
	end

	if mod.GraterState == 2 then
		mod:spritePlay(sprite, "GrateShake")
	elseif mod.GraterState == 3 then
		mod:spritePlay(sprite, "GrateShake")
		if npc.FrameCount % 3 == 1 then
		npc:PlaySound(SoundEffect.SOUND_BOSS2_BUBBLES,1,2,false,1.5)
		local r = npc:GetDropRNG()
		local params = ProjectileParams()
		local rand = r:RandomFloat()
		params.FallingSpeedModifier = -30 + math.random(10);
		params.FallingAccelModifier = 2
		--params.VelocityMulti = math.random(13,19) / 10
		params.HeightModifier = 28
		params.Color = mod.ColorDankBlackReal
		params.Scale = 0.3
		npc:FireProjectiles(npc.Position, RandomVector() * 2, 0, params)
		end
	else
		mod:spritePlay(sprite, "Grate")
	end
end

function mod.graterGratesLogic()
	if mod.graterInRoom then
		if game:GetRoom():IsClear() or mod.GetEntityCount(mod.FF.Grater.ID, mod.FF.Grater.Var) < 1 then
			mod.GraterState = nil
		else
			mod.graterCount = mod.graterCount or 0
			mod.graterCount = mod.graterCount + 1
			if mod.GraterState == 1 then
				if mod.graterCount % 10 == 0 then
					local readytofire = true
					for _, grater in pairs(Isaac.FindByType(mod.FF.Grater.ID, mod.FF.Grater.Var, -1, false, false)) do
						if grater:GetData().state ~= "eruptwait" then
							readytofire = false
						end
					end
					if readytofire then
						mod.GraterState = 2
						mod.graterCount = 0
					end
				end

			elseif mod.GraterState == 2 then
				if not sfx:IsPlaying(mod.Sounds.GraterShake) then
					sfx:Play(mod.Sounds.GraterShake, 0.3, 0, true, 1.3)
				end
				if mod.graterCount > 20 then
					mod.GraterState = 3
					mod.graterCount = 0
				end
			elseif mod.GraterState == 3 then
				if mod.graterCount > 75 then
					mod.GraterState = nil
					mod.graterCount = 0
					sfx:Stop(mod.Sounds.GraterShake)
				else
					if not sfx:IsPlaying(mod.Sounds.GraterShake) then
						sfx:Play(mod.Sounds.GraterShake, 0.3, 0, true, 1.3)
					end
				end
			else
				if mod.graterCount > 300 then
					mod.GraterState = 1
					sfx:Stop(mod.Sounds.GraterShake)
				end
			end
		end
	end
end
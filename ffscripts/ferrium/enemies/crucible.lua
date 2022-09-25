local mod = FiendFolio
local game = Game()

local function GetSpiderCount()
	return mod.GetEntityCount(818) + mod.GetEntityCount(85)
end

function mod:crucibleAI(npc)
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	local data = npc:GetData()
	local rand = npc:GetDropRNG()
	local room = game:GetRoom()

	if not data.init then
		npc.StateFrame = 30
		sprite:PlayOverlay("IdleLegs")
		if npc.SubType == 0 then
			data.state = "Idle"
			data.speedDemon = 3
		else
			data.state = "Flaming"
			data.ignited = true
			data.speedDemon = 4
			npc.SplatColor = mod.ColorFireJuicy
		end
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end

	if npc.Velocity:Length() > 0.3 then
		if npc.Velocity.X > 0.2 then
			mod:spriteOverlayPlay(sprite, "MoveLegsR")
		else
			mod:spriteOverlayPlay(sprite, "MoveLegsL")
		end
	else
		mod:spriteOverlayPlay(sprite, "IdleLegs")
	end

	if data.state == "Idle" then
		if npc.Velocity:Length() > 0.3 then
			mod:spritePlay(sprite, "MoveHead01")
		else
			mod:spritePlay(sprite, "IdleHead01")
		end

		if data.ignited == true then
			npc:PlaySound(SoundEffect.SOUND_MONSTER_ROAR_3, 1, 0, false, 1.2)
			local oFrame = sprite:GetFrame()
			sprite:Play("MoveHead02")
			sprite:SetFrame("MoveHead02", oFrame)
			data.speedDemon = 3
			data.state = "Flaming"
		end

		if npc.StateFrame >= 50 and npc.StateFrame < 90 and rand:RandomInt(20) == 0 and not mod:isScareOrConfuse(npc)then
			npc.StateFrame = 0
			sprite:Play("ShootStart01")
			npc:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_2, 1, 0, false, 1)
			data.ending = true
			data.state = "ShootNorm"
			data.shootDir1 = rand:RandomInt(360)
			data.shootDir2 = data.shootDir1+180
		elseif npc.StateFrame >= 90 and not mod:isScareOrConfuse(npc) then
			npc.StateFrame = 0
			sprite:Play("ShootStart01")
			npc:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_2, 1, 0, false, 1)
			data.ending = true
			data.state = "ShootNorm"
			data.shootDir1 = rand:RandomInt(360)
			data.shootDir2 = data.shootDir1+180
		end
	elseif data.state == "Flaming" then
		if npc.Velocity:Length() > 0.3 then
			mod:spritePlay(sprite, "MoveHead02")
		else
			mod:spritePlay(sprite, "IdleHead02")
		end

		if data.ignited == false then
			local oFrame = sprite:GetFrame()
			sprite:Play("MoveHead01")
			sprite:SetFrame("MoveHead01", oFrame)
			data.speedDemon = 3
			data.state = "Idle"
		end

		if npc.StateFrame >= 95 and npc.StateFrame < 140 and rand:RandomInt(20) == 0 and not mod:isScareOrConfuse(npc) then
			npc.StateFrame = 0
			sprite:Play("ShootStart02")
			npc:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_2, 1, 0, false, 1)
			data.ending = true
			data.state = "ShootFlame"
			data.shootDir1 = rand:RandomInt(360)
			data.shootDir2 = data.shootDir1+180
		elseif npc.StateFrame >= 140 and not mod:isScareOrConfuse(npc) then
			npc.StateFrame = 0
			sprite:Play("ShootStart02")
			npc:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_2, 1, 0, false, 1)
			data.ending = true
			data.state = "ShootFlame"
			data.shootDir1 = rand:RandomInt(360)
			data.shootDir2 = data.shootDir1+180
		end
	elseif data.state == "ShootNorm" then
		if sprite:IsFinished("ShootStart01") then
			sprite:Play("ShootLoop01")
		elseif sprite:IsPlaying("ShootLoop01") then
			if npc.StateFrame % 6 == 0 then
				mod:SetGatheredProjectiles()
				for i=0,1 do
					local params = ProjectileParams()
					params.FallingSpeedModifier = -mod:getRoll(20,25,rand)
					params.FallingAccelModifier = mod:getRoll(8,14,rand)/8
					params.HeightModifier = -50
					params.Variant = 8
					params.Scale = 0.6
					if i == 0 then
						local dir = Vector(2, 0):Rotated(data.shootDir1)
						npc:FireProjectiles(npc.Position, npc.Velocity+dir, 0, params)
						data.shootDir1 = data.shootDir1+30
					else
						local dir = Vector(3.75, 0):Rotated(data.shootDir2)
						npc:FireProjectiles(npc.Position, npc.Velocity+dir, 0, params)
						data.shootDir2 = data.shootDir2-50
					end
				end
				for _, proj in pairs(mod:GetGatheredProjectiles()) do
					local pSprite = proj:GetSprite()
					pSprite:Load("gfx/009.009_rock projectile.anm2", true)
					pSprite:Play("Rotate3", true)
					pSprite:LoadGraphics()
					proj:GetData().makeSplat = 145
					proj:GetData().customProjSound = {SoundEffect.SOUND_ROCK_CRUMBLE, 0.2, math.random(8,12)/10}
					proj:GetData().toothParticles = mod.ColorRockGibs
				end
				npc:PlaySound(SoundEffect.SOUND_ROCK_CRUMBLE, 0.25, 0, false, 1)
			end
		elseif sprite:IsPlaying("ShootEnd01") then
			if sprite:IsEventTriggered("Shoot") then
				if GetSpiderCount() < 4 then
					mod.throwShit(npc.Position, npc.Velocity+RandomVector():Resized(mod:getRoll(2,6,rand)/4), -50, -mod:getRoll(2,6,rand), npc, "rockSpider")
				end
				npc:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, 1, 0, false, 1)
			end
		elseif sprite:IsFinished("ShootEnd01") then
			npc.StateFrame = 0
			data.state = "Idle"
		end

		if data.ignited == true then
			npc:PlaySound(SoundEffect.SOUND_MONSTER_ROAR_3, 1, 0, false, 1.2)
			npc.StateFrame = 30
			data.speedDemon = 4
			data.state = "ShootFlame"
			sprite:Play("ShootLoop02")
			data.ending = true
			npc.SplatColor = mod.ColorFireJuicy
		end

		if data.ending == true then
			if npc.StateFrame >= 120 and npc.StateFrame < 160 and rand:RandomInt(20) == 0 then
				npc.StateFrame = 0
				sprite:Play("ShootEnd01")
				data.ending = false
			elseif npc.StateFrame >= 160 then
				npc.StateFrame = 0
				sprite:Play("ShootEnd01")
				data.ending = false
			end
		end
	elseif data.state == "ShootFlame" then
		if sprite:IsFinished("ShootStart02") then
			sprite:Play("ShootLoop02")
		elseif sprite:IsPlaying("ShootLoop02") then
			if npc.StateFrame % 20 == 0 then
				npc:PlaySound(SoundEffect.SOUND_ROCK_CRUMBLE, 0.3, 0, false, 1)
				local smoke = Isaac.Spawn(1000, 88, 0, npc.Position+Vector(0,-60), Vector.Zero, npc)
				smoke.Color = Color(6,3,0.3,1,0,0,0)
				smoke:Update()
				mod.throwShit(npc.Position, npc.Velocity+RandomVector():Resized(mod:getRoll(6,9,rand)/4), -50, -mod:getRoll(5,7,rand), npc, "coal")

				mod:SetGatheredProjectiles()
				local rangle = rand:RandomInt(360)
				local vec = Vector(mod:getRoll(10,16,rand)/4, 0)
				local params = ProjectileParams()
				params.FallingSpeedModifier = -mod:getRoll(20,25,rand)
				params.FallingAccelModifier = mod:getRoll(8,14,rand)/8
				params.HeightModifier = -50
				params.Variant = 8
				params.Scale = 0.6
				for i=0,4 do
					npc:FireProjectiles(npc.Position, npc.Velocity+vec:Rotated(rangle+i*72), 0, params)
				end
				for _, proj in pairs(mod:GetGatheredProjectiles()) do
					local pSprite = proj:GetSprite()
					pSprite:Load("gfx/009.009_rock projectile.anm2", true)
					pSprite:Play("Rotate3", true)
					pSprite:ReplaceSpritesheet(0, "gfx/projectiles/charredrock_proj.png")
					pSprite:LoadGraphics()
					proj:GetData().makeSplat = 145
					proj:GetData().customProjSound = {SoundEffect.SOUND_ROCK_CRUMBLE, 0.2, math.random(8,12)/10}
					proj:GetData().toothParticles = Color(50/255, 30/255, 30/255, 1, 0, 0, 0)
					proj:GetData().customProjSplat = "gfx/projectiles/charredrock_splat.png"
				end
			end
		elseif sprite:IsPlaying("ShootEnd02") then
			if sprite:IsEventTriggered("Shoot") then
				if mod.GetEntityCount(818, 2) < 2 and GetSpiderCount() < 4 then
					mod.throwShit(npc.Position, npc.Velocity+RandomVector():Resized(math.random(2,6)/4), -50, -math.random(2,5), npc, "coalSpider")
				else
					mod.throwShit(npc.Position, npc.Velocity+RandomVector():Resized(math.random(6,9)/4), -50, -math.random(5,7), npc, "coal")
				end
				npc:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, 1, 0, false, 1)
			end
		elseif sprite:IsFinished("ShootEnd02") then
			npc.StateFrame = 0
			data.state = "Flaming"
		end

		if data.ignited == false then
			npc.StateFrame = 0
			data.speedDemon = 3
			data.state = "Idle"
		end

		if data.ending == true then
			if npc.StateFrame >= 60 and npc.StateFrame < 85 and rand:RandomInt(20) == 0 then
				npc.StateFrame = 0
				sprite:Play("ShootEnd02")
				data.ending = false
			elseif npc.StateFrame >= 85 then
				npc.StateFrame = 0
				sprite:Play("ShootEnd02")
				data.ending = false
			end
		end
	end

	data.newhome = data.newhome or mod:GetNewPosAligned(npc.Position)
	if npc.Position:Distance(data.newhome) < 20 or npc.Velocity:Length() < 0.3 or (not room:CheckLine(data.newhome,npc.Position,0,900,false,false)) or (mod:isConfuse(npc) and npc.StateFrame % 10 == 0) then
		data.newhome = mod:GetNewPosAligned(npc.Position)
	end
	local targvel = (data.newhome - npc.Position):Resized(data.speedDemon)
	if mod:isScare(npc) then
		targvel = (target.Position - npc.Position):Resized(-(data.speedDemon+0.5))
	end
	npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.3)
end

function mod:crucibleHurt(npc, damage, flag, source)
	local data = npc:GetData()
	if flag & DamageFlag.DAMAGE_FIRE ~= 0 and source.Type ~= 1 then
		data.ignited = true
		npc:TakeDamage(damage*0.2, flag & ~DamageFlag.DAMAGE_FIRE, source, 0)
		return false
    end
end

function mod:crucibleColl(npc, coll, bool)
	if coll.Type == 33 or (coll.Type == 818 and coll.Variant == 2) then
		npc:GetData().ignited = true
	end
end
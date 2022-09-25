local game = Game()
local sfx = SFXManager()

--WickAI
return {
	AI = function(npc) -- Wick was redone by someone, idk who though so I can't credit (IT WAS ME GUWAHAVEL)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		local path = npc.Pathfinder
		local target = npc:GetPlayerTarget()
		local targetpos = FiendFolio:confusePos(npc, target.Position)

		if not data.init then
			data.state = "idle"
			npc.SplatColor = FiendFolio.ColorCandleWax
			data.init = true
		else
			npc.StateFrame = npc.StateFrame + 1
		end
		FiendFolio.QuickSetEntityGridPath(npc, 900)
		npc:AnimWalkFrame("WalkHori", "WalkVert", 0.3)
		if FiendFolio:isScare(npc) then
			local targetvel = (targetpos - npc.Position):Resized(-6)
			npc.Velocity = FiendFolio:Lerp(npc.Velocity, targetvel,0.25)
		elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
			local targetvel = (targetpos - npc.Position):Resized(3.5)
			npc.Velocity = FiendFolio:Lerp(npc.Velocity, targetvel,0.25)
		else
			path:FindGridPath(targetpos, 0.45, 900, true)
		end
		if npc.StateFrame % 8 == 0 then
			local splat = Isaac.Spawn(1000,7,0,npc.Position,Vector.Zero,npc)
			splat.SpriteScale = splat.SpriteScale * 0.5
			splat.Color = FiendFolio.ColorCandleWax
		end
		if data.state == "idle" then
			sprite:PlayOverlay("Head", false)
			if npc.StateFrame > 90 and math.random(10) == 1 and game:GetRoom():CheckLine(npc.Position, targetpos, 3, 0, false, false) and not FiendFolio:isScareOrConfuse(npc) then
				data.state = "shoot"
			end
		--[[elseif data.state == "charge" then
			npc.Velocity = npc.Velocity * 0.7
			sprite:SetFrame("WalkVert", 0)
			sprite.FlipX = false
			if sprite:IsOverlayFinished("Charge") then
				data.state = "shoot"
				npc:PlaySound(FiendFolio.Sounds.FriedStart,1,0,false,1.3)
				npc.StateFrame = 0
			else
				FiendFolio:spriteOverlayPlay(sprite, "Charge")
			end]]
		elseif data.state == "shoot" then
			sprite:PlayOverlay("Shoot", false)
			if sprite:IsOverlayFinished("Shoot") then
				data.state = "idle"
				data.Shooted = false
				npc.StateFrame = 0
			end
			if sprite:GetOverlayFrame() == 12 and not data.Shooted then
				local vec = targetpos - npc.Position
				local flame = Isaac.Spawn(33,10,0,npc.Position,vec:Resized(10),npc)
				flame.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
				npc:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_0, 0.8, 0, false, 1.2)
				
				local effect = Isaac.Spawn(1000, FiendFolio.FF.FFWhiteSmoke.Var, FiendFolio.FF.FFWhiteSmoke.Sub, npc.Position - Vector(0,25), Vector.Zero, nil):ToEffect()
				effect:FollowParent(npc)
				effect:GetData().longonly = true
				effect.Color = Color(0.5, 0.5, 0.5, 1)
				effect.DepthOffset = npc.Position.Y * 1.25

				local effect = Isaac.Spawn(1000, 2, 1, npc.Position, Vector.Zero, npc):ToEffect()
				effect:FollowParent(npc)
				effect.SpriteOffset = Vector(0,-15)
				effect.DepthOffset = npc.Position.Y * 1.25
				effect.Color = FiendFolio.ColorCandleWax
				data.Shooted = true
			end
			--[[sprite:SetFrame("WalkVert", 0)
			npc.Velocity = npc.Velocity * 0.7
			if not (sfx:IsPlaying(FiendFolio.Sounds.FriedStart) or sfx:IsPlaying(FiendFolio.Sounds.FriedLoop)) then
				npc:PlaySound(FiendFolio.Sounds.FriedLoop,1,0,true,1.3)
			end
			if npc.StateFrame % 3 == 1 then
				local vec = (targetpos - npc.Position):Resized(6)
				local frame = FiendFolio:calcPeepeeDir(vec)
				sprite:SetOverlayFrame("Loop", frame)
				local fire = Isaac.Spawn(1000, 7005, 0, npc.Position + vec:Resized(10), vec, npc):ToEffect()
				fire:SetColor(Color(1,1,1,1,-100 / 255,70 / 255,455 / 255),10,1,true,false)
				fire:GetData().timer = 9
				fire:GetData().gridcoll = 1
				fire:GetData().flamethrower = true
				fire:GetSprite().Offset = Vector(0, -14)
				fire:Update()

				local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position + vec:Resized(16), vec:Rotated(-30 + math.random(60)), npc):ToEffect()
				smoke.SpriteRotation = math.random(360)
				smoke.Color = Color(1,1,1,0.3,75 / 255,70 / 255,50 / 255)
				--smoke.SpriteScale = Vector(2,2)
				smoke.SpriteOffset = Vector(0, -16)
				smoke.RenderZOffset = 300
				smoke:Update()
			end
			if npc.StateFrame > 60 and npc.Position:Distance(targetpos) - target.Size > 120 then
				data.state = "end"
				sfx:Stop(FiendFolio.Sounds.FriedLoop)
				npc:PlaySound(FiendFolio.Sounds.FriedEnd,1,0,false,1.3)
			end
		elseif data.state == "end" then
			npc.Velocity = npc.Velocity * 0.7
			sprite:SetFrame("WalkVert", 0)
			sprite.FlipX = false
			if sprite:IsOverlayFinished("End") then
				data.state = "idle"
				npc.StateFrame = 0
			else
				FiendFolio:spriteOverlayPlay(sprite, "End")
			end]]
		end

		--[[if npc:HasMortalDamage() then
			sfx:Stop(FiendFolio.Sounds.FriedLoop)
		end]]
    end,
    Damage = function(npc, amount, flags, source)
		if flags & DamageFlag.DAMAGE_FIRE > 0 then
			return false
		elseif amount > (npc.MaxHitPoints / 10) then
			local vec = Vector.Zero
			local sourceplayer = FiendFolio:GetPlayerSource(source)
			if sourceplayer then
				vec = (npc.Position - sourceplayer.Position)
			end
			local fire = Isaac.Spawn(33,10,0, npc.Position, vec:Resized(FiendFolio:RandomInt(1,3)):Rotated(50 + FiendFolio:RandomInt(-40,40)), npc)
			if (npc.HitPoints - amount) <= 0 then
				fire.HitPoints = fire.HitPoints / 1.2
			else
				fire.HitPoints = fire.HitPoints / 2
			end
			fire.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
			fire:Update()
			npc:ToNPC():PlaySound(SoundEffect.SOUND_FIREDEATH_HISS, 0.18, 0, false, 2)
		end
	end
}
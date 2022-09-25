local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc) -- This was redone, I think by Erfly
		local d = npc:GetData()
		local sprite = npc:GetSprite()
		local target = npc:GetPlayerTarget()

		if not d.init then
			d.init = true
			d.state = "idle"
			npc.SpriteOffset = Vector(0, -10)
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			if npc.SubType ~= 1 then
				local lantern = Isaac.Spawn(750, 70, 0, npc.Position + Vector(-15, 0), Vector.Zero, npc):ToNPC()
				lantern.Parent = npc
				npc.Child = lantern
			end
			d.lantern = "followNormal"
		else
			npc.StateFrame = npc.StateFrame + 1
		end

		if d.state == "idle" then
			d.gravediggerIsInvulnerable = false
			FiendFolio:spritePlay(sprite, "MoveNormal")
			npc.Pathfinder:MoveRandomlyBoss(false)
			if npc.Velocity:Length() <= 6 then
				npc.Velocity = npc.Velocity * 1.1
			else
				npc.Velocity = npc.Velocity * 0.9
			end
			if npc.StateFrame > 10 and math.random(10) == 1 then
				d.state = "attackStart"
				FiendFolio:spritePlay(sprite, "LantShootStart")
				if target.Position.X > npc.Position.X then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end

				d.subState = nil
				npc.StateFrame = 0
				if not npc.Child then
					d.state = "GhostShoot"
					d.subState = "idle"
				elseif d.lastAttack == "GhostShoot" then
					d.state = "BulletHell"
					d.lastAttack = "BulletHell"
				elseif d.lastAttack == "BulletHell" then
					d.state = "GhostShoot"
					d.lastAttack = "GhostShoot"
				else
					local rand = math.random(2)
					if rand == 1 then
						d.state = "GhostShoot"
						d.lastAttack = "GhostShoot"
					else
						d.state = "BulletHell"
						d.lastAttack = "BulletHell"
					end
				end
				--d.state = "GhostShoot"

			end
		elseif d.state == "GhostShoot" then
			if not d.subState then
				if not npc.Child then
					d.subState = "idle"
				end
				npc.Velocity = npc.Velocity * 0.8
				if sprite:IsFinished("LantShootStart") then
					d.subState = "becomeNormal"
				elseif sprite:IsEventTriggered("Shoot") then
					d.lantern = "moveIt"
					d.lanternAttack = "GhostShoot"
				end
			elseif d.subState == "becomeNormal" then
				npc.Velocity = npc.Velocity * 0.8
				if sprite:IsFinished("BecomeNormal02") then
					d.subState = "idle"
				else
					FiendFolio:spritePlay(sprite, "BecomeNormal02")
				end
			elseif d.subState == "idle" then
				npc.Pathfinder:MoveRandomlyBoss(false)
				if npc.Velocity:Length() <= 6 then
					npc.Velocity = npc.Velocity * 1.1
				else
					npc.Velocity = npc.Velocity * 0.9
				end
				if not d.shooting then
					FiendFolio:spritePlay(sprite, "MoveNormal")
					if math.random(10) == 1 then
						d.shooting = true
						--d.shootvec = (target.Position - npc.Position):Resized(13)
						if target.Position.X > npc.Position.X then
							sprite.FlipX = true
						else
							sprite.FlipX  = false
						end
					end
					if (npc.Child and d.lantern == "followNormal") or ((not npc.Child) and npc.StateFrame > 100) then
						d.shoooting = false
						d.state = "digupSomeGhosties"
						if target.Position.X > npc.Position.X then
							sprite.FlipX = true
						else
							sprite.FlipX = false
						end
					end
				else
					npc.Velocity = npc.Velocity * 0.8
					if sprite:IsFinished("Swing") then
						d.shooting = false
					elseif sprite:IsEventTriggered("Shoot") then
						if target.Position.X > npc.Position.X then
							sprite.FlipX = true
						else
							sprite.FlipX  = false
						end
						--npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,0,false,1)
						npc:PlaySound(FiendFolio.Sounds.WingFlap,1,0,false,math.random(120,150)/100)

						local params = ProjectileParams()
						params.BulletFlags = params.BulletFlags | ProjectileFlags.GHOST
						params.FallingAccelModifier = 0.13
						params.FallingSpeedModifier = 0
						params.Scale = 2.5
						params.Variant = 4
						for i = -30, 30, 30 do
							npc:FireProjectiles(npc.Position, (target.Position - npc.Position):Resized(13):Rotated(i), 0, params)
						end
					else
						FiendFolio:spritePlay(sprite, "Swing")
					end
				end
			end
		elseif d.state == "BulletHell" then
			if sprite:IsFinished("LantShootStart") then
				FiendFolio:spritePlay(sprite, "MoveLantShoot")
			elseif sprite:IsEventTriggered("Shoot") then
				d.lantern = "moveIt"
			elseif sprite:IsPlaying("MoveLantShoot") then
				if npc.StateFrame > 120 then
					d.state = "stopAttack"
					d.lanternAttack = "stopFiring"
				end
			end

			local room = game:GetRoom()
			if sprite:IsPlaying("LantShootStart") or npc.StateFrame < 20 then
				local targ = room:GetCenterPos()
				local targVec = (targ - npc.Position) * 0.2
				if targVec:Length() > 18 then
					targVec = targVec:Resized(18)
				end
				npc.Velocity = FiendFolio:Lerp(npc.Velocity, targVec, 0.05)
			else
				local targ = room:GetCenterPos()
				local targVec = (targ - npc.Position)
				npc.Velocity = npc.Velocity * 0.8
				npc.Velocity = FiendFolio:Lerp(npc.Velocity, targVec * 0.2, 0.05)
				d.lanternAttack = "BulletHell"
			end

			if not npc.Child then
				d.state = "GhostShoot"
				d.subState = "idle"
			end
		elseif d.state == "stopAttack" then
			d.lanternAttack = "stopFiring"
			d.lantern = "followNormal"
			if sprite:IsFinished("BecomeNormal02") then
				d.state = "digupSomeGhosties"
				if target.Position.X > npc.Position.X then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end
			else
				FiendFolio:spritePlay(sprite, "BecomeNormal02")
			end
		elseif d.state == "digupSomeGhosties" then
			npc.Pathfinder:MoveRandomlyBoss(false)
			if npc.Velocity:Length() <= 6 then
				npc.Velocity = npc.Velocity * 1.1
			else
				npc.Velocity = npc.Velocity * 0.9
			end
			if d.digness then
				npc.Velocity = npc.Velocity * 0.5
			end
			if sprite:IsFinished("Dig") then
				if npc.StateFrame > 100 then
					d.state = "doYouPreferTheShieldOnOrOff"
					npc.StateFrame = 0
				end
			elseif sprite:IsEventTriggered("DiggyDiggy") then
				d.digness = true
				sfx:Play(FiendFolio.Sounds.GravediggerDig, 0.5, 0, false, math.random(9,11)/10)
			elseif sprite:IsEventTriggered("Summon") then
				d.digness = false
				sfx:Play(FiendFolio.Sounds.GravediggerDigUp, 0.5, 0, false, math.random(9,11)/10)
				local rand = math.random(#FiendFolio.gravediggerSummons)
				local ary = FiendFolio.gravediggerSummons[rand]
				local targvec = (target.Position - npc.Position)
				if targvec.X > 0 then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end
				for i = 1, ary.Count do
					local sub = 0
					if ary.ID[1] == FiendFolio.FF.Spoop.ID and ary.ID[2] == FiendFolio.FF.Spoop.Var then
						sub = FiendFolio:RandomInt(2,4)
					end
					targvec = targvec:Resized(math.random(2,4)):Rotated(-50 + math.random(100))
					local friend = Isaac.Spawn(ary.ID[1], ary.ID[2], sub, npc.Position + targvec:Resized(30), targvec, npc)
					friend:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					--friend.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
					friend:SetColor(Color(1,1,1,0,0,0,0),15,1,true,false)
					friend:Update()

					local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, friend.Position, targvec * 0.7, npc)
					smoke.SpriteRotation = math.random(360)
					smoke.Color = Color(1,1,1,0.3,75 / 255,70 / 255,50 / 255)
					smoke.SpriteScale = Vector(2,2)
					smoke.SpriteOffset = Vector(0, -10)
					smoke:Update()
				end
			else
				FiendFolio:spritePlay(sprite, "Dig")
			end
		elseif d.state == "doYouPreferTheShieldOnOrOff" then
			--off please
			if sprite:IsFinished("BecomeInvul") then
				d.state = "tooBad"
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("ShieldOn") then
				d.gravediggerIsInvulnerable = true
				npc:PlaySound(FiendFolio.Sounds.PsionBubble,0.5,0,false,1.1)
			else
				FiendFolio:spritePlay(sprite, "BecomeInvul")
			end
		elseif d.state == "tooBad" then
			d.gravediggerIsInvulnerable = true
			FiendFolio:spritePlay(sprite, "MoveInvul")
			npc.Pathfinder:MoveRandomlyBoss(false)
			if npc.Velocity:Length() <= 6 then
				npc.Velocity = npc.Velocity * 1.1
			else
				npc.Velocity = npc.Velocity * 0.9
			end

			if npc.StateFrame > 40 and npc.FrameCount % 10 == 0 then
				if not FiendFolio.AreThereEntitiesButNotThisOne(750, nil, 60) then
					d.state = "faceReveal"
				end
			end
		elseif d.state == "faceReveal" then
			if sprite:IsFinished("BecomeNormal01") then
				d.state = "idle"
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("ShieldOff") then
				d.gravediggerIsInvulnerable = false
				npc:PlaySound(FiendFolio.Sounds.PsionBubbleBreak,0.5,0,false,1.1)
			else
				FiendFolio:spritePlay(sprite, "BecomeNormal01")
			end
		end
	end,
	Damage = function(npc, amount, flags, source)
		if npc:GetData().gravediggerIsInvulnerable then
			return false
		end
		if flags & DamageFlag.DAMAGE_FIRE > 0 and (source.Type ~= 1 or source.Type ~= 3) then
			return false
		end
	end,
}
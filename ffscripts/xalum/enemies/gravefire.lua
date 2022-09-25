local game = Game()
local sfx = SFXManager()

return {
	AI = function(npc) -- Same as gravedigger, p sure this was redone by Erfly
		local d = npc:GetData()
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if npc.SubType == 1 then
			if not d.init then
				d.init = true
				FiendFolio:spritePlay(sprite, "FireAppear")
				npc.SpriteOffset = Vector(0,-15)
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			end

			if npc.Parent and npc.Parent.Child then
				local p = npc.Parent
				if sprite:IsFinished("FireExit") then
					npc:Remove()
				elseif sprite:IsFinished("FireAppear") then
					FiendFolio:spritePlay(sprite, "Walk02")
				elseif sprite:IsPlaying("FireAppear") and sprite:IsEventTriggered("Shoot") then
					for i = 1, 4 do
						local laser = EntityLaser.ShootAngle(4, npc.Position, Vector(1,1):Rotated(90 * i):GetAngleDegrees(), 5, Vector(0,-15), npc)
						local ls = laser:GetSprite()
						ls:ReplaceSpritesheet(0, "gfx/enemies/gravedigger/flamelaser.png")
						ls:LoadGraphics()
						laser:Update()
					end
					sfx:Play(SoundEffect.SOUND_REDLIGHTNING_ZAP, 0.7, 0, false, 1)
				end
				if sprite:IsPlaying("FireExit") then
					npc.Velocity = npc.Velocity * 0.8
					if sprite:IsEventTriggered("Shoot") then
						local pl = p.Child
						local shootvec = (p.Child.Position - npc.Position)

						local laser = EntityLaser.ShootAngle(2, npc.Position, shootvec:GetAngleDegrees(), 5, Vector(0,-15), npc)
						laser.Color = FiendFolio.ColorGravefireGreen
						--[[local ls = laser:GetSprite()
						ls:ReplaceSpritesheet(0, "gfx/enemies/gravedigger/flamelaser.png")
						ls:LoadGraphics()]]
						laser:SetMaxDistance(shootvec:Length())
						laser:Update()
						sfx:Play(SoundEffect.SOUND_REDLIGHTNING_ZAP, 0.7, 0, false, 1)

						pl:GetData().shooting = "returnHome"
					end
				else
					npc.Velocity = FiendFolio:Lerp(npc.Velocity, Vector(d.xVec, (p.Position.Y - npc.Position.Y)), 0.3)
				end
				if d.flippedOver and npc.Position:Distance(p.Position) < 100 then
					FiendFolio:spritePlay(sprite, "FireExit")
				end

				local room = game:GetRoom()
				if d.xVec > 0 then
					if npc.Position.X > room:GetGridWidth()*40+100 then
						npc.Position = Vector(-100, npc.Position.Y)
						d.flippedOver = true
					end
				else
					if npc.Position.X < -100 then
						npc.Position = Vector(room:GetGridWidth()*40+100, npc.Position.Y)
						d.flippedOver = true
					end
				end
			else
				npc.Velocity = npc.Velocity * 0.1
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				if sprite:IsFinished("Death02") then
					npc:Remove()
				else
					FiendFolio:spritePlay(sprite, "Death02")
				end
			end
		else
			if not data.init then
				npc.SpriteOffset = Vector(0, -10)
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
				data.init = true
			else
				npc.StateFrame = npc.StateFrame + 1
			end
			if npc.Parent and not FiendFolio:IsReallyDead(npc.Parent) then
				local p = npc.Parent
				local pd = p:GetData()
				if pd.lantern == "followNormal" then
					d.shooting = nil
					d.sitStill = nil
					if sprite:IsPlaying("BulletHellLoop") then
						FiendFolio:spritePlay(sprite, "BulletHellStop")
						if sfx:IsPlaying(FiendFolio.Sounds.FriedLoop) then
							sfx:Stop(FiendFolio.Sounds.FriedLoop)
							sfx:Play(FiendFolio.Sounds.FriedEnd, 0.5, 0, false, 1.3)
						end
					elseif not (sprite:IsPlaying("BulletHellStop") or sprite:IsPlaying("FireReturn")) then
						FiendFolio:spritePlay(sprite, "Walk01")
					end
					local vec = (p.Position - npc.Position)
					if vec:Length() > 60 then
						npc.Velocity = FiendFolio:Lerp(npc.Velocity, vec:Resized(7), 0.4)
					elseif vec:Length() > 40 then
						npc.Velocity = FiendFolio:Lerp(npc.Velocity, vec:Resized(7), 0.2)
					else
						npc.Velocity = npc.Velocity * 0.95
					end
				elseif pd.lantern == "moveIt" then
					if d.sitStill then
						npc.Velocity = npc.Velocity * 0.2
					else
						local extraVec = Vector(-40, -3)
						if p:GetSprite().FlipX then
							extraVec.X = extraVec.X * -1
						end
						local vec = ((p.Position + extraVec) - npc.Position)
						npc.Velocity = FiendFolio:Lerp(npc.Velocity, vec:Resized(vec:Length()/5), 0.4)
					end

					if pd.lanternAttack == "BulletHell" then
						if not d.shooting then
							if sprite:IsFinished("BulletHellStart") then
								d.shooting = true
								d.rotcount = 0
							elseif sprite:IsEventTriggered("Shoot") then
								npc:PlaySound(FiendFolio.Sounds.GraterShakeShort, 0.5, 0, false, 1.3)
								sfx:Play(FiendFolio.Sounds.FriedStart, 0.5, 0, false, 1.3)
							else
								FiendFolio:spritePlay(sprite, "BulletHellStart")
							end
						elseif d.lanternAttack == "stopFiring" then
							if sfx:IsPlaying(FiendFolio.Sounds.FriedLoop) then
								sfx:Stop(FiendFolio.Sounds.FriedLoop)
								sfx:Play(FiendFolio.Sounds.FriedEnd, 0.5, 0, false, 1.3)
							end
							if sprite:IsFinished("BulletHellStop") then
								pd.lantern = "followNormal"
							else
								FiendFolio:spritePlay(sprite, "BulletHellStop")
							end
						elseif d.shooting then
							FiendFolio:spritePlay(sprite, "BulletHellLoop")
							if not (sfx:IsPlaying(FiendFolio.Sounds.FriedStart) or sfx:IsPlaying(FiendFolio.Sounds.FriedLoop)) then
								sfx:Play(FiendFolio.Sounds.FriedLoop, 0.5, 0, true, 1.3)
							end
							d.attackang = d.attackang or 0
							d.rotcount = d.rotcount or 0
							if npc.StateFrame % 8 == 1 then
								for i = 1, 3 do
									local fire = Isaac.Spawn(1000,7005, 20, npc.Position, Vector(12,0):Rotated(d.attackang + i * 120), npc):ToEffect()
									fire.Color = Color(0.2,2,1,1,0,0,0)
									fire:GetData().timer = 50
									--fire:GetData().gridcoll = 0
									fire.Parent = npc
								end
								--if d.rotcount >= 2 then
									d.attackang = d.attackang - 24
								--[[else
									d.rotcount = d.rotcount + 1
								end]]
							end
						end
					elseif pd.lanternAttack == "GhostShoot" then
						if not d.shooting then
							if sprite:IsFinished("SpawnFire") then
								d.shooting = "sitQuietly"
								FiendFolio:spritePlay(sprite, "Land")
								npc:PlaySound(FiendFolio.Sounds.GraterShakeShort, 0.5, 0, false, 1)
							elseif sprite:IsEventTriggered("Summon") then
								npc:PlaySound(FiendFolio.Sounds.GraterShake, 0.5, 0, false, 1.3)
								d.sitStill = true
								if p:GetSprite().FlipX then
									sprite.FlipX = true
								else
									sprite.FlipX = false
								end

								local shootVec = Vector(-9, 0)
								if sprite.FlipX then
									shootVec = shootVec * -1
								end
								local ghost = Isaac.Spawn(750, 70, 1, npc.Position + shootVec, shootVec, npc)
								if sprite.FlipX then
									ghost:GetSprite().FlipX = false
								else
									ghost:GetSprite().FlipX = true
								end
								ghost:GetData().xVec = shootVec.X
								ghost.Parent = p

								ghost:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
								ghost:Update()
							else
								FiendFolio:spritePlay(sprite, "SpawnFire")
							end
						elseif d.shooting == "sitQuietly" then
							if sprite:IsFinished("Land") then
								FiendFolio:spritePlay(sprite, "Idle")
							end
						elseif d.shooting == "returnHome" then
							if sprite:IsFinished("FireReturn") or sprite:IsEventTriggered("Shoot") then
								pd.lantern = "followNormal"
								d.shooting = false
								d.sitStill = false
							elseif sprite:IsPlaying("FireReturn") and sprite:GetFrame() == 4 then
								npc:PlaySound(FiendFolio.Sounds.GraterShake, 0.5, 0, false, 1.3)
							else
								FiendFolio:spritePlay(sprite, "FireReturn")
							end
						end
					end
				end
			else
				if d.sitStill then
					npc.Velocity = npc.Velocity * 0.1
					npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					npc.CanShutDoors = false
				else
					sfx:Stop(FiendFolio.Sounds.FriedLoop)
					npc.Velocity = npc.Velocity * 0.1
					npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					if sprite:IsFinished("Death") then
						npc:Remove()
					else
						FiendFolio:spritePlay(sprite, "Death")
					end
				end
			end

			if npc:HasMortalDamage() then
				sfx:Stop(FiendFolio.Sounds.FriedLoop)
			end
		end
	end,
	Damage = function()
		return false
	end,
	Collision = function(npc)
		if npc:GetSprite():IsPlaying("Shrink") then return true end
	end,
}
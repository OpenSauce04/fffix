local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.DwellerItems = {
	c2 = {"gfx/items/collectibles/collectibles_002_theinnereye.png",
			costume = true, firerate = 24, special = "triple", checkangle = 35},
	c3 = {"gfx/items/collectibles/collectibles_003_spoonbender.png",
			costume = true, flags = ProjectileFlags.SMART, checkangle = 50, firerate = 20},
	c6 = {"gfx/items/collectibles/collectibles_006_numberone.png",
			costume = true, firerate = 5, color = mod.ColorPeepPiss, heightmodifier = 15, distanceclose = 50},
	c8 = {"gfx/items/collectibles/collectibles_008_brotherbobby.png",
			bobby = true},
	c68 = {"gfx/items/collectibles/collectibles_068_technology.png",
			costume = true, special = "technology", firerate = 50},
	c169 = {"gfx/items/collectibles/collectibles_169_polyphemus.png",
			costume = true, firerate = 24, scale = 2.5},
	c213 = {"gfx/items/collectibles/collectibles_213_lostcontact.png",
			costume = true, special = "lostcontact", velocitymodifier = 0.84, range = 0},
	c224 = {"gfx/items/collectibles/collectibles_224_cricketsbody.png",
			costume = true, flags = ProjectileFlags.BURST, range = 2, scale = 1.5, checkangle = 35},
	c316 = {"gfx/items/collectibles/collectibles_316_cursedeye.png",
			costume = true, firerate = 50, mode = "charge", special = "cursedeye"},
	c330 = {"gfx/items/collectibles/collectibles_330_soymilk.png",
			costume = true, firerate = 2, color = mod.ColorSoyCreep, scale = 0.3, heightmodifier = 5, checkangle = 70},
	c475 = {"gfx/items/collectibles/collectibles_475_planc.png",
			planc = true},
	c496 = {"gfx/items/collectibles/collectibles_496_euthanasia.png",
			costume = true, euthanasia = true},
	c1001 = {"gfx/items/collectibles/012_the_fiend_folio.png",
			flags = ProjectileFlags.SMART | ProjectileFlags.BURST,
			firerate = 2, checkangle = 70, range = -10, special = "triple", bobby = true, scale = 2.5}
}

mod.DwellerRandom = {2, 6, 169, 224, 316}

function mod:dwellerAI(npc, subType)
local d = npc:GetData()
local sprite = npc:GetSprite();
local target = npc:GetPlayerTarget()
local room = game:GetRoom()

	if not d.init then
		d.walking = true
		d.init = true
		d.stats = {}
		if subType == 1000 then
			local ran = math.random(#mod.DwellerRandom)
			npc.SubType = mod.DwellerRandom[ran]
		end
		d.pickupwait = math.random(10)
		d.headnum = 0
		d.tempstateframe = 0
	elseif d.init and not d.checkeditem then
		npc.StateFrame = 0
		d.tempstateframe = d.tempstateframe + 1
		if subType ~= 0 then
			if d.tempstateframe + d.pickupwait > 15  then
				sprite:RemoveOverlay()
				sprite:ReplaceSpritesheet(2, mod.DwellerItems["c" .. subType][1])
				d.itemget = true
				d.checkeditem = true
			end
		else
			d.checkeditem = true
		end
	elseif d.init then
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "teleport" then
		npc.Velocity = nilvector
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		sprite:RemoveOverlay()

		if sprite:IsFinished("Teleport") then
			npc:Remove()
		else
			mod:spritePlay(sprite, "Teleport")
		end
	else

		--Item use
		if d.itemget then
			d.walking = false
			if d.synced then
				if sprite:IsFinished("PickupSync") then
					d.walking = true
					d.itemget = false
					d.itemgotten = true
					d.stats = mod.DwellerItems["c" .. subType]
				elseif sprite:IsEventTriggered("DownItem") then
					d.headnum = 0
					if mod.DwellerItems["c" .. subType] then
						if mod.DwellerItems["c" .. subType].costume then
							d.headnum = subType
						end
					end
					sprite:SetOverlayFrame("Head" .. d.headnum, 0)
				else
					mod:spritePlay(sprite, "PickupSync")
				end
			else
				if sprite:IsFinished("Pickup") then
					d.walking = true
					d.itemget = false
					d.itemgotten = true
					d.stats = mod.DwellerItems["c" .. subType]
					if d.stats.bobby then
						local bobby = Isaac.Spawn(mod.FF.DwellerBrother.ID, mod.FF.DwellerBrother.Var, 0, npc.Position+(RandomVector()*20), nilvector, npc):ToNPC()
						bobby.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
						bobby.Parent = npc
					end
					if d.stats.euthanasia then
						d.needleChance = true
					end
				elseif sprite:IsEventTriggered("Item") then
					sprite:LoadGraphics()
					npc:PlaySound(SoundEffect.SOUND_POWERUP1,0.6,0,false,math.random(110,120)/100)
					
					if npc.SubType == 475 then
						target:TakeDamage(999, 0, EntityRef(npc), 0)
						game:ShakeScreen(12)
						npc.StateFrame = 0
						d.planc = true
					end
				elseif sprite:IsEventTriggered("DownItem") then
					d.headnum = 0
					if mod.DwellerItems["c" .. subType] then
						if mod.DwellerItems["c" .. subType].costume then
							d.headnum = subType
						end
					end
					sprite:SetOverlayFrame("Head" .. d.headnum, 0)
				else
					mod:spritePlay(sprite, "Pickup")
				end
			end
		end
		
		if d.planc == true then
			if npc.StateFrame > 33 then
				npc:Kill()
			end
		end

		--Stats
		local movespeed = d.stats.movespeed or 4
		local firerate = d.stats.firerate or 10
		local shotspeed = d.stats.shotspeed or 8

		--AI changes
		local distanceclose = d.stats.distanceclose or 150
		local checkangle = d.stats.checkangle or 20
		local controloverriden = false

		if npc.Parent then
			if mod:IsReallyDead(npc.Parent) then
				npc.Parent = nil
			else
				controloverriden = true
			end
		end

		--Status Effects
		if mod:isConfuse(npc) then
			if math.random(2) == 1 then
				movespeed = movespeed * -1
			end
			if math.random(3) == 1 then
				movespeed = movespeed * 2.5
			end
			--[[if math.random(4) == 1 then
				--shotspeed = shotspeed * -1
				d.reversetarg = true
			end]]
		end

		--Targeting

		local targpos = mod:confusePos(npc, target.Position, 30)
		local targdistance = mod:reverseIfFear(npc,targpos - npc.Position)
		--[[if d.reversetarg then
			targdistance = targdistance:Rotated(math.random(360))
			d.reversetarg = false
		end]]
		local targrel
		local techOffset = Vector(0,0)
		local techDOffset = -500
		local chargeOffset = Vector(0,0)
		local chargeDOffset = -500
		if math.abs(targdistance.X) > math.abs(targdistance.Y) then
			if targdistance.X < 0 then
				targrel = 3 -- Left
				techOffset = Vector(-5, -25)
				chargeOffset = Vector(-2, 1)
				chargeDOffset = 500
				techDOffset = 1500
			else
				targrel = 1 -- Right
				--techDOffset = 0
				techOffset = Vector(5, -25)
				chargeOffset = Vector(2, 1)
			end
		else
		 	if targdistance.Y < 0 then
				targrel = 2 -- Up
				--techDOffset = 0
				techOffset = Vector(-10, -30)
				chargeOffset = Vector(-8, -3)
			else
				targrel = 0 -- Down
				techOffset = Vector(10, -10)
				chargeOffset = Vector(8, 1)
				chargeDOffset = 500
				techDOffset = 1500
			end
		end

		--Walking
		if d.walking then
			local targetpos = target.Position
			local distanceabs = npc.Position:Distance(targetpos)

			if controloverriden then
				npc.Velocity = mod:Lerp(npc.Parent.Velocity:Resized(movespeed), npc.Velocity, 0.8)
			else

				if distanceabs < distanceclose and room:CheckLine(npc.Position,targetpos,0,3,false,false) and not mod:isScare(npc)  then
					local extravec = 0
					if distanceabs < 100 then
						extravec = distanceabs / 3
					end

					local tpa = target.Position
					if targrel == 0 then
						tpa = target.Position + Vector((target.Position.X - npc.Position.X), -distanceabs - extravec)
					elseif targrel == 1 then
						tpa = target.Position + Vector(-distanceabs - extravec, (target.Position.Y - npc.Position.Y))
					elseif targrel == 2 then
						tpa = target.Position + Vector((target.Position.X - npc.Position.X), distanceabs + extravec)
					elseif targrel == 3 then
						tpa = target.Position + Vector(distanceabs + extravec, (target.Position.Y - npc.Position.Y))
					end

					if npc.Position:Distance(tpa) > 10 then
						d.targetvelocity = (tpa - npc.Position):Resized(movespeed)
						npc.Velocity = mod:Lerp(d.targetvelocity, npc.Velocity, 0.8)
					else
						npc.Velocity = npc.Velocity * 0.8
					end

				else
					if mod:isScare(npc) then
						d.targetvelocity = (targetpos - npc.Position):Resized(movespeed * -1.5)
						npc.Velocity = mod:Lerp(d.targetvelocity, npc.Velocity, 0.8)

					elseif room:CheckLine(npc.Position,targetpos,0,1,false,false) then
						d.targetvelocity = (targetpos - npc.Position):Resized(movespeed)
						npc.Velocity = mod:Lerp(d.targetvelocity, npc.Velocity, 0.8)

					elseif npc.Pathfinder:HasPathToPos(targetpos, false) then
						mod:CatheryPathFinding(npc, targetpos, {
							Speed = movespeed,
							Accel = 0.2,
							Interval = 1,
							GiveUp = true
						})
					else
						local targvec = Vector(npc.Position.X, targetpos.Y)
						if targrel == 2 or targrel == 0 then
							targvec = Vector(targetpos.X, npc.Position.Y)
						end
						d.targetvelocity = (targvec - npc.Position):Resized(movespeed)
						npc.Velocity = mod:Lerp(d.targetvelocity, npc.Velocity, 0.8)
					end
				end
			end

			if npc.Velocity:Length() > 0.1 then
				if math.abs(npc.Velocity.Y) > math.abs(npc.Velocity.X) then
					mod:spritePlay(sprite, "WalkVert")
				else
					if npc.Velocity.X > 0 then
						mod:spritePlay(sprite, "WalkRight")
					else
						mod:spritePlay(sprite, "WalkLeft")
					end
				end
			else
				sprite:SetFrame("WalkVert", 0)
			end
		else
			npc.Velocity = npc.Velocity * 0.8
		end

		if not d.firing and not d.itemget then
			if d.stats.mode == "charge" then
				if d.charging then
					sprite:SetOverlayFrame("Head" .. d.headnum, targrel * 2+1)
					if npc.StateFrame > firerate / 2 and not mod:isScareOrConfuse(npc) then
						if (math.abs(targdistance.X) < checkangle or math.abs(targdistance.Y) < checkangle) then
							d.direction = targrel
							d.firing = true
							npc.StateFrame = 0
						end
					end
				else
					sprite:SetOverlayFrame("Head" .. d.headnum, targrel * 2)
					if npc.StateFrame > firerate / 2 then
						d.charging = true
						npc.StateFrame = 0
					end
				end

			else
				d.headway = targrel * 2
				if controloverriden then
					d.headway = npc.Parent:GetData().headway
					if npc.StateFrame > firerate and npc.Parent:GetData().IWishICouldshoot then
						d.firing = true
						npc.StateFrame = 0
						d.direction = npc.Parent:GetData().direction
					end
				else
					if npc.StateFrame > firerate and room:CheckLine(target.Position,npc.Position,3,900,false,false) and not mod:isScareOrConfuse(npc) then
						if (math.abs(targdistance.X) < checkangle or math.abs(targdistance.Y) < checkangle) then
							d.direction = targrel
							d.firing = true
							npc.StateFrame = 0
						end
					end
				end
				sprite:SetOverlayFrame("Head" .. d.headnum, d.headway)
			end


		elseif d.firing then
			if d.stats.special == "technology" then
				if npc.StateFrame > 10 then
					sprite:SetOverlayFrame("Head" .. d.headnum, d.direction * 2 + 1)
					if npc.StateFrame == 11 then
						npc:PlaySound(mod.Sounds.FlashZap,0.9,0,false,0.9)
						local techVec = Vector(0,1):Rotated(-d.direction * 90)
						local laser = EntityLaser.ShootAngle(2, npc.Position, techVec:GetAngleDegrees(), 4, techOffset, npc)
						laser.RenderZOffset = techDOffset
						laser.Parent = npc
						laser:GetData().offSetSpawn = Vector(0, -30)
						laser:Update()
					end
					if npc.StateFrame > 20 then
						d.firing = false
					end
				elseif npc.StateFrame == 1 then
					SFXManager():Play(SoundEffect.SOUND_BATTERYCHARGE,1,1,false,2)
					sprite:SetOverlayFrame("Head" .. d.headnum, d.direction * 2)
					local charge = Isaac.Spawn(1000, 668, 1, npc.Position, nilvector,npc):ToEffect()
					charge.SpriteOffset = chargeOffset
					charge.RenderZOffset = chargeDOffset
					charge.SpriteScale = Vector(0.7,0.7)
					charge.Parent = npc
					charge:GetData().parent = npc
					charge.Color = Color(1,0,0,1,0,0,0)
					charge:Update()
				end
			elseif d.stats.mode == "charge" then
				sprite:SetOverlayFrame("Head" .. d.headnum, d.direction * 2)
				if d.stats.special == "cursedeye" then
					if npc.StateFrame > 12 then
						d.charging = false
						d.firing = false
						npc.StateFrame = 0
					elseif npc.StateFrame % 3 == 1 then
						npc:PlaySound(mod.Sounds.TearFireFuckYouRevv,0.9,0,false,0.9)
						npc:FireProjectiles(npc.Position, Vector(0,shotspeed):Rotated(-d.direction * 90) + (npc.Velocity/3), 0, ProjectileParams())
					end
				end
			else
				sprite:SetOverlayFrame("Head" .. d.headnum, d.direction * 2 + 1)
				if npc.StateFrame == 1 then
					local params = ProjectileParams()

					--For that good Soy color
					if npc.SubType == 330 then
						params.Variant = 4
					end

					if d.stats.scale then
						params.Scale = d.stats.scale
					end

					if d.stats.color then
						params.Color = d.stats.color
					end

					if d.stats.range then
						params.FallingSpeedModifier = d.stats.range
					end

					if d.stats.heightmodifier then
						params.HeightModifier = d.stats.heightmodifier
					end

					params.VelocityMulti = d.stats.velocitymodifier or 1

					if d.stats.flags then
						params.BulletFlags = params.BulletFlags | d.stats.flags
						if d.stats.hs then
							params.HomingStrength = d.stats.hs
						end
					end
					mod:SetGatheredProjectiles()
					npc:FireProjectiles(npc.Position + Vector(0,shotspeed):Rotated(-d.direction * 90), Vector(0,shotspeed):Rotated(-d.direction * 90) + (npc.Velocity/3), 0, params)
					npc:PlaySound(mod.Sounds.TearFireFuckYouRevv,0.9,0,false,0.9)

					if d.stats.special == "triple" then
						local rotangle = -7.5
						for i = 0, 1 do
							npc:FireProjectiles(npc.Position + Vector(10 - (20 * i),shotspeed-5):Rotated((-d.direction * 90) + rotangle + (15 * i)), Vector(0,shotspeed):Rotated((-d.direction * 90) + rotangle + (15 * i)) + (npc.Velocity/3), 0, params)
						end
					end
					for _, proj in pairs(mod:GetGatheredProjectiles()) do
						if d.stats.special == "lostcontact" then
							local psprite = proj:GetSprite()
							psprite:ReplaceSpritesheet(0, "gfx/projectiles/lost_contact_projectiles.png")
							psprite:LoadGraphics()
							proj:GetData().projType = "LostContact"
						elseif d.needleChance then
							local psprite = proj:GetSprite()
							psprite:ReplaceSpritesheet(0, "gfx/projectiles/needle_projectile.png")
							psprite:LoadGraphics()
							proj:GetData().projType = "killerNeedle"
							proj:GetData().RotationUpdate = true
							proj:Update()
						end
					end
				end
				if npc.StateFrame > firerate / 2 then
					d.firing = false
					npc.StateFrame = 0
				end
			end
		end
	end
end

function mod:dwellerHurt(npc)
    if npc.SubType == 316 then
        local d = npc:GetData()
        if d.charging and not d.firing then
            if d.state ~= "teleport" then
                local r = npc:GetDropRNG()
                if r:RandomInt(10) == 0 then
                    npc:ToNPC():PlaySound(SoundEffect.SOUND_HELL_PORTAL1,1,0,false,1)
                    d.state = "teleport"
                end
            end
        end
    end
end

mod.dwellerbobbyframe = {
[0] = {"Down", false},
[1] = {"Side", false},
[2] = {"Up", false},
[3] = {"Side", true},
}

function mod:dwellerBobbyAI(npc)
local d = npc:GetData()
local sprite = npc:GetSprite();
local target = npc:GetPlayerTarget()

	if npc.Parent and not mod:isStatusCorpse(npc.Parent) then
		local p = npc.Parent
		local pd = p:GetData()

		local vec = (p.Position - npc.Position)
		if vec:Length() > 80 then
			npc.Velocity = mod:Lerp(npc.Velocity, vec:Resized(5), 0.2)
		elseif vec:Length() > 40 then
			npc.Velocity = mod:Lerp(npc.Velocity, vec:Resized(5), 0.09)
		else
			npc.Velocity = npc.Velocity * 0.95
		end

		if d.cooldown then
			d.cooldown = d.cooldown - 1
			if d.cooldown < 1 then
				d.cooldown = nil
				sprite.FlipX = false
			elseif d.cooldown == 5 then
				sprite:Play("Float" .. mod.dwellerbobbyframe[d.dir][1])
			end
		else
			sprite:Play("FloatDown", true)
		end

		if pd.firing and not d.cooldown then
			if pd.direction then
				if pd.direction then
					npc:PlaySound(mod.Sounds.TearFireFuckYouRevv,0.3,0,false,1.3)
					local params = ProjectileParams()
					params.Scale = 0.5
					npc:FireProjectiles(npc.Position, Vector(0,8):Rotated(-pd.direction * 90) + (npc.Velocity/3), 0, params)
					d.cooldown = 20
					local fram = pd.direction
					sprite:Play("FloatShoot" .. mod.dwellerbobbyframe[fram][1])
					sprite.FlipX = mod.dwellerbobbyframe[fram][2]
					d.dir = fram
				end
			end
		end
	else
		npc:Kill()
	end
end

mod.TaintedDwellerItems = {
	c167 = {"gfx/items/collectibles/collectibles_167_harlequinbaby.png",
			harley = true},
	c329 = {"gfx/items/collectibles/collectibles_329_theludovicotechnique.png",
			costume = true, special = "ludo", distanceclose = 300},
	c331 = {"gfx/items/collectibles/collectibles_331_godhead.png",
			costume = true, special = "godhead", flags = ProjectileFlags.ANY_HEIGHT_ENTITY_HIT, checkangle = 50, firerate = 9, scale = 1.6, shotspeed = 4.5, range2 = -0.065, range = 0},
	c369 = {"gfx/items/collectibles/collectibles_369_continuum.png",
			costume = true, flags = ProjectileFlags.CONTINUUM | ProjectileFlags.ANY_HEIGHT_ENTITY_HIT, range2 = -0.165, range = 0, spread = 16},
	c395 = {"gfx/items/collectibles/collectibles_395_techx.png",
			costume = true, special = "techx", mode = "charge", spread = 0},
	c452 = {"gfx/items/collectibles/collectibles_452_varicoseveins.png",
			costume = true, special = "varicose", range2 = 0},
	c636 = {"gfx/items/collectibles/collectibles_636_rkey.png",
			rkey = true}
}

mod.TaintedDwellerRandom = {167, 329, 331, 369, 395, 452}

function mod:dwellerTAI(npc, subType)
local d = npc:GetData()
local sprite = npc:GetSprite();
local target = npc:GetPlayerTarget()
local room = game:GetRoom()
local rand = npc:GetDropRNG()
	
	if not d.init then
		d.movement = 0
		d.walking = true
		d.init = true
		d.stats = {}
		if subType == 1000 then
			local ran = rand:RandomInt(#mod.TaintedDwellerRandom)+1
			npc.SubType = mod.TaintedDwellerRandom[ran]
		end
		d.pickupwait = rand:RandomInt(10)+1
		d.headnum = 0
		d.tempstateframe = 0
		d.invcount = 0
		d.hitcount = d.hitcount or 0
	elseif d.init and not d.checkeditem then
		npc.StateFrame = 0
		d.tempstateframe = d.tempstateframe + 1
		if subType ~= 0 then
			if d.tempstateframe + d.pickupwait > 15  then
				sprite:RemoveOverlay()
				sprite:ReplaceSpritesheet(2, mod.TaintedDwellerItems["c" .. subType][1])
				d.itemget = true
				d.checkeditem = true
			end
		else
			d.checkeditem = true
		end
	elseif d.init then
		npc.StateFrame = npc.StateFrame + 1
	end
	
	if d.invincible then
		if (d.wasbruised and d.invcount > 25) or d.invcount > 40 then
			npc.Color = mod.ColorNormal
			d.invincible = false
			d.wasbruised = nil
			d.invcount = 0
		else
			if d.invcount == 0 then
				mod:applyFakeDamageFlash(npc)
			elseif d.invcount % 4 == 2 then
				npc:SetColor(mod.ColorInvisible, 2, 0, false, false)
			end
			d.invcount = d.invcount + 1
			--if d.invcount < 2 then
			--	npc.Color = Color(30,1,1,1,0,0,0)
			--elseif d.invcount % 4 < 2 then
			--	npc.Color = mod.ColorNormal
			--else
			--	npc.Color = mod.ColorInvisible
			--end
		end
	end
	if d.varicose then
		if d.varicose > 0 then
			d.varicose = d.varicose-1
			if d.varicose % 12 == 0 then
				if mod:isFriend(npc) then
					local creep = Isaac.Spawn(1000, 46, 0, npc.Position, Vector.Zero, npc):ToEffect()
					creep:SetTimeout(200)
					creep:Update()
				else
					local creep = Isaac.Spawn(1000, 22, 0, npc.Position, Vector.Zero, npc):ToEffect()
					creep:SetTimeout(200)
					creep:Update()
				end
			end
		else
			d.stats.range2 = d.stats.range2+0.05
			d.varicose = nil
		end
	end
	
	if d.rkeyed then
		if not d.rkeyMoved then
			npc.Position = Vector(320,290)
			sprite:Play("Appear", true)
			d.movement = 40
			d.rkeyMoved = true
		end
		for i = 1, game:GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			player.Visible = false
			player.ControlsEnabled = false
			player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		end
	end
	
	if d.state == "Hurt" then
		if sprite:IsFinished("Hurt") then
			d.state = nil
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Headgone") then
			sprite:SetOverlayFrame("Head" .. d.headnum, 0)
		else
			mod:spritePlay(sprite, "Hurt")
		end
		npc.Velocity = npc.Velocity * 0.8
	else
		if d.itemget then
			d.walking = false

			if sprite:IsFinished("Pickup") then
				d.walking = true
				d.itemget = false
				d.itemgotten = true
				d.stats = mod.TaintedDwellerItems["c" .. subType]
				if d.stats.harley then
					local harley = Isaac.Spawn(mod.FF.TDwellerBrother.ID, mod.FF.TDwellerBrother.Var, 0, npc.Position+(RandomVector()*20), nilvector, npc):ToNPC()
					harley.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
					harley.Parent = npc
				end
				if d.stats.rkey == true then
					npc:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
					npc.CanShutDoors = false
					Isaac.GetPlayer(0):UseActiveItem(636, false, false, true, false, -1)
					d.rkeyed = true
					sprite:Play("Appear", true)
				end
			elseif sprite:IsEventTriggered("Item") then
				sprite:LoadGraphics()
				npc:PlaySound(SoundEffect.SOUND_POWERUP1,0.6,0,false,math.random(110,120)/100)
			elseif sprite:IsEventTriggered("DownItem") then
				d.headnum = 0
				if mod.TaintedDwellerItems["c" .. subType] then
					if mod.TaintedDwellerItems["c" .. subType].costume then
						d.headnum = subType
					end
				end
				sprite:SetOverlayFrame("Head" .. d.headnum, 0)
			else
				mod:spritePlay(sprite, "Pickup")
			end
		end
		
		local movespeed = d.stats.movespeed or 3
		local firerate = d.stats.firerate or 10
		local shotspeed = d.stats.shotspeed or 8

		--AI changes
		local distanceclose = d.stats.distanceclose or 150
		local checkangle = d.stats.checkangle or 20

		--Status Effects
		if mod:isConfuse(npc) then
			if rand:RandomInt(2) == 1 then
				movespeed = movespeed * -1
			end
			if rand:RandomInt(3) == 1 then
				movespeed = movespeed * 2.5
			end
			--[[if math.random(4) == 1 then
				--shotspeed = shotspeed * -1
				d.reversetarg = true
			end]]
		end

		--Targeting

		local targpos = mod:confusePos(npc, target.Position, 30)
		local targdistance = mod:reverseIfFear(npc,targpos - npc.Position)
		--[[if d.reversetarg then
			targdistance = targdistance:Rotated(math.random(360))
			d.reversetarg = false
		end]]
		local targrel
		local chargeOffset = Vector(0,0)
		local chargeDOffset = -500
		if math.abs(targdistance.X) > math.abs(targdistance.Y) then
			if targdistance.X < 0 then
				targrel = 3 -- Left
				chargeOffset = Vector(-14, -12)
				chargeDOffset = 500
			else
				targrel = 1 -- Right
				chargeOffset = Vector(14, -12)
				chargeDOffset = 500
			end
		else
			if targdistance.Y < 0 then
				targrel = 2 -- Up
				chargeOffset = Vector(0, -20)
			else
				targrel = 0 -- Down
				chargeOffset = Vector(0, -11)
				chargeDOffset = 500
			end
		end
		
		if d.rkeyed and d.walking then
			if d.movement > 0 then
				npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
				d.movement = d.movement-1
			elseif not d.goHere then
				npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
				d.goHere = mod:FindRandomValidPathPosition(npc, 3, 60, 120)
				d.movement = math.floor(-(npc.Position:Distance(d.goHere)*2))
			elseif d.movement < 0 then
				d.movement = d.movement+1
				if npc.Position:Distance(d.goHere) < 25 then
					d.movement = 25+rand:RandomInt(30)
					d.goHere = nil
				elseif room:CheckLine(npc.Position, d.goHere, 0, 1, false, false) then
					local targetvel = (d.goHere - npc.Position):Resized(2)
					npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
				else
					npc.Pathfinder:FindGridPath(d.goHere, 0.3, 900, true)
				end
			else
				d.movement = 10
				d.goHere = nil
			end
		
			if npc.Velocity:Length() > 0.1 then
				if math.abs(npc.Velocity.Y) > math.abs(npc.Velocity.X) then
					if npc.Velocity.Y > 0 then
						mod:spritePlay(sprite, "WalkDown")
						targrel = 0
					else
						mod:spritePlay(sprite, "WalkUp")
						targrel = 2
					end
				else
					if npc.Velocity.X > 0 then
						mod:spritePlay(sprite, "WalkRight")
						targrel = 1
					else
						mod:spritePlay(sprite, "WalkLeft")
						targrel = 3
					end
				end
			else
				sprite:SetFrame("WalkDown", 0)
				targrel = 0
			end
			sprite:SetOverlayFrame("Head0", targrel * 2)
		elseif d.walking then
			local targetpos = target.Position
			local distanceabs = npc.Position:Distance(targetpos)

			if distanceabs < distanceclose and room:CheckLine(npc.Position,targetpos,0,3,false,false) and not mod:isScare(npc) then
				local extravec = 0
				if distanceabs < 100 or (d.stats.special == "ludo" and distanceabs < 250) then
					extravec = distanceabs / 3
				end

				local tpa = target.Position
				if targrel == 0 then
					tpa = target.Position + Vector((target.Position.X - npc.Position.X), -distanceabs - extravec)
				elseif targrel == 1 then
					tpa = target.Position + Vector(-distanceabs - extravec, (target.Position.Y - npc.Position.Y))
				elseif targrel == 2 then
					tpa = target.Position + Vector((target.Position.X - npc.Position.X), distanceabs + extravec)
				elseif targrel == 3 then
					tpa = target.Position + Vector(distanceabs + extravec, (target.Position.Y - npc.Position.Y))
				end

				if npc.Position:Distance(tpa) > 10 then
					d.targetvelocity = (tpa - npc.Position):Resized(movespeed)
					npc.Velocity = mod:Lerp(d.targetvelocity, npc.Velocity, 0.8)
				else
					npc.Velocity = npc.Velocity * 0.8
				end

			else
				if mod:isScare(npc) then
					d.targetvelocity = (targetpos - npc.Position):Resized(movespeed * -1.5)
					npc.Velocity = mod:Lerp(d.targetvelocity, npc.Velocity, 0.8)

				elseif room:CheckLine(npc.Position,targetpos,0,1,false,false) then
					d.targetvelocity = (targetpos - npc.Position):Resized(movespeed)
					npc.Velocity = mod:Lerp(d.targetvelocity, npc.Velocity, 0.8)

				elseif npc.Pathfinder:HasPathToPos(targetpos, false) then
					mod:CatheryPathFinding(npc, targetpos, {
						Speed = movespeed,
						Accel = 0.2,
						Interval = 1,
						GiveUp = true
					})
				else
					local targvec = Vector(npc.Position.X, targetpos.Y)
					if targrel == 2 or targrel == 0 then
						targvec = Vector(targetpos.X, npc.Position.Y)
					end
					d.targetvelocity = (targvec - npc.Position):Resized(movespeed)
					npc.Velocity = mod:Lerp(d.targetvelocity, npc.Velocity, 0.8)
				end
			end

			if npc.Velocity:Length() > 0.1 then
				if math.abs(npc.Velocity.Y) > math.abs(npc.Velocity.X) then
					if npc.Velocity.Y > 0 then
						mod:spritePlay(sprite, "WalkDown")
					else
						mod:spritePlay(sprite, "WalkUp")
					end
				else
					if npc.Velocity.X > 0 then
						mod:spritePlay(sprite, "WalkRight")
					else
						mod:spritePlay(sprite, "WalkLeft")
					end
				end
			else
				sprite:SetFrame("WalkDown", 0)
			end
		else
			npc.Velocity = npc.Velocity * 0.8
		end
		
		if d.stats.special == "ludo" then
			if not npc.Child or (not npc.Child:Exists()) then
				npc:PlaySound(mod.Sounds.TearFireFuckYouRevv,0.9,0,false,0.9)
				sprite:SetOverlayFrame("Head" .. d.headnum, targrel * 2)
				local proj = Isaac.Spawn(9, 0, 0, npc.Position, Vector.Zero, npc):ToProjectile()
				local pData = proj:GetData()
				proj:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
				if mod:isFriend(npc) then
					proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.HIT_ENEMIES
				end
				proj.Scale = 2
				pData.projType = "dwellerLudo"
				proj.Parent = npc
				npc.Child = proj
			else
				local newPos = target.Position + target.Velocity*10
				local dir = (newPos-npc.Child.Position):Resized(3)
				if not mod:isScareOrConfuse(npc) then
					if math.abs(dir.X) > math.abs(dir.Y) then
						if dir.X > 0 then
							targrel = 1
						else
							targrel = 3
						end
					else
						if dir.Y > 0 then
							targrel = 0
						else
							targrel = 2
						end
					end
				end
				sprite:SetOverlayFrame("Head" .. d.headnum, targrel * 2)
				
				npc.Child.Velocity = mod:Lerp(npc.Child.Velocity, dir+Vector(0,rand:RandomInt(5)+1):Rotated(rand:RandomInt(-10+rand:RandomInt(20)-targrel*90))+Vector(0,6):Rotated(-targrel*90), 0.1)
			end
		end
		
		if d.stats.special == "ludo" then
		elseif not d.firing and not d.itemget then
			if d.stats.mode == "charge" then
				if d.charging then
					sprite:SetOverlayFrame("Head" .. d.headnum, targrel * 2+1)
					if npc.StateFrame > firerate / 2 and not mod:isScareOrConfuse(npc) then
						if (math.abs(targdistance.X) < checkangle or math.abs(targdistance.Y) < checkangle) then
							d.direction = targrel
							if npc.StateFrame*2 < 25 then
								d.techXSize = 25
							else
								d.techXSize = math.min(65, npc.StateFrame*2)
							end
							d.firing = true
							npc.StateFrame = 0
						end
					end
				else
					sprite:SetOverlayFrame("Head" .. d.headnum, targrel * 2)
					if npc.StateFrame > firerate / 2 then
						d.charging = true
						npc.StateFrame = 0
					end
				end

			else
				sprite:SetOverlayFrame("Head" .. d.headnum, targrel * 2)
				if npc.StateFrame > firerate and room:CheckLine(target.Position,npc.Position,3,900,false,false) and not mod:isScareOrConfuse(npc) then
					if (math.abs(targdistance.X) < checkangle or math.abs(targdistance.Y) < checkangle) then
						d.direction = targrel
						d.firing = true
						npc.StateFrame = 0
					end
				end
			end


		elseif d.firing and not d.rkeyed then
			if d.stats.special == "techx" then
				if npc.StateFrame > 10 then
					sprite:SetOverlayFrame("Head" .. d.headnum, d.direction * 2 + 1)
					if npc.StateFrame == 11 then
						local techVec = Vector(0,4+(65-d.techXSize)/10):Rotated(-d.direction * 90)
						local ring = Isaac.Spawn(7, 2, 2, npc.Position+Vector(0,-40), techVec+npc.Velocity, npc):ToLaser()
						ring.Parent = npc
						npc.Child = ring
						ring.Radius = d.techXSize
						ring.DepthOffset = 500
					end
					if npc.StateFrame > 20 then
						d.charging = false
						d.firing = false
					end
				elseif npc.StateFrame == 1 then
					SFXManager():Play(SoundEffect.SOUND_BATTERYCHARGE,0.5,1,false,2)
					sprite:SetOverlayFrame("Head" .. d.headnum, d.direction * 2)
					local charge = Isaac.Spawn(1000, 668, 1, npc.Position, nilvector,npc):ToEffect()
					charge.SpriteOffset = chargeOffset
					charge.RenderZOffset = chargeDOffset
					charge.SpriteScale = Vector(0.7,0.7)
					charge.Parent = npc
					charge:GetData().parent = npc
					charge.Color = Color(1,0,0,1,0,0,0)
					charge:Update()
				end
			else
				sprite:SetOverlayFrame("Head" .. d.headnum, d.direction * 2 + 1)
				if npc.StateFrame == 1 then
					local params = ProjectileParams()

					if d.stats.scale then
						params.Scale = d.stats.scale
					end

					if d.stats.color then
						params.Color = d.stats.color
					end

					if d.stats.range then
						params.FallingSpeedModifier = d.stats.range
					end

					if d.stats.range2 then
						params.FallingAccelModifier = d.stats.range2
					end

					params.HeightModifier = -16
					if d.stats.heightmodifier then
						params.HeightModifier = d.stats.heightmodifier
					end

					if d.stats.flags then
						params.BulletFlags = params.BulletFlags | d.stats.flags
						if d.stats.hs then
							params.HomingStrength = d.stats.hs
						end
					end
					
					local spread = 36
					if d.stats.spread then
						spread = d.stats.spread
					end
					
					local spreadVal = rand:RandomInt(spread)-(spread/2)
					npc:FireProjectiles(npc.Position + Vector(0,shotspeed):Rotated(-d.direction * 90), Vector(0,shotspeed):Rotated(spreadVal-d.direction * 90) + (npc.Velocity/3), 0, params)
					npc:PlaySound(mod.Sounds.TearFireFuckYouRevv,0.9,0,false,0.9)
					if d.stats.special == "godhead" then
						for _, proj in pairs(Isaac.FindByType(9, 0, 0)) do
							if proj.FrameCount < 1 and proj.SpawnerType == npc.Type and proj.SpawnerVariant == npc.Variant then
								proj:GetData().projType = "dwellerGodhead"
								local aura = Isaac.Spawn(1000, 123, 0, proj.Position, proj.Velocity, proj):ToEffect()
								aura.Parent = proj
								proj.Child = aura
								aura:GetSprite():Load("gfx/1000.123_Halo (Static Prerendered).anm2", true)
								aura:GetSprite():ReplaceSpritesheet(0, "gfx/enemies/dweller/tainted/manwhyyougottadothis.png")
								aura:GetSprite():LoadGraphics()
								aura:GetSprite():Play("Idle", true)
								aura.SpriteScale = aura.SpriteScale*1.3
								aura:FollowParent(proj)
								proj:GetData().target = target
								proj:Update()
							end
						end
					end
				end
				if npc.StateFrame > firerate / 2 then
					d.firing = false
					npc.StateFrame = 0
				end
			end
		end
	end
end

function mod.deepDwellerLudo(v, d)
	if d.projType == "dwellerLudo" then
		if v.Parent and v.Parent:Exists() then
			v.FallingSpeed = 0
			v.FallingAccel = -0.1
		else
			v:Remove()
			local effect = Isaac.Spawn(1000, 11, 0, v.Position, Vector.Zero, v):ToEffect()
			effect.SpriteScale = effect.SpriteScale * 1.3
			effect.SpriteOffset = Vector(0, v.Height)
			effect:Update()
			sfx:Play(SoundEffect.SOUND_TEARIMPACTS, 1, 0, false, 1)
		end
	end
	if d.projType == "dwellerGodhead" then
		if v:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
			for _,entity in ipairs(Isaac.FindInRadius(v.Position, 80, EntityPartition.ENEMY)) do
				if not mod:isFriend(entity) then
					entity:TakeDamage(1, 0, EntityRef(v), 0)
				end
			end
		end
		
		if d.target and d.target:Exists() then
			if d.target.Position:Distance(v.Position) < 100 then
				local tVel = (d.target.Position-v.Position)
				local difference = mod:GetAngleDifference(v.Velocity, tVel)
				if difference < 60 then
					v.Velocity = v.Velocity:Rotated(-3)
				elseif difference > 300 then
					v.Velocity = v.Velocity:Rotated(3)
				end
			end
		end
		
		if v:IsDead() then
			if v.Child then
				v.Child:GetSprite():Play("Disappear", true)
				v.Child.Parent = v.Child
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	local godhead = false
	local data = player:GetData()
	for _, proj in ipairs(Isaac.FindByType(9, 0, 0, false, false)) do
		if proj:GetData().projType == "dwellerGodhead" then
			if not proj:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
				if player.Position:Distance(proj.Position) < 110 then
					godhead = true
				end
			end
		end
	end
	
	if godhead == true then
		data.dwellerGodheadTimer = (data.dwellerGodheadTimer or 0)+1
		
		if data.dwellerGodheadTimer > 22 and not data.dwellerGodheadWarning then
			data.dwellerGodheadWarning = true
			sfx:Play(SoundEffect.SOUND_LIGHTBOLT_CHARGE, 1, 0, false, 1)
		elseif data.dwellerGodheadTimer > 42 then
			Isaac.Spawn(1000, 19, 0, player.Position, Vector.Zero, nil)
			data.dwellerGodheadTimer = 0
			data.dwellerGodheadWarning = nil
		end
	elseif data.dwellerGodheadTimer then
		if data.dwellerGodheadTimer < 20 then
			data.dwellerGodheadWarning = nil
		end
		if data.dwellerGodheadTimer > 0 then
			data.dwellerGodheadTimer = data.dwellerGodheadTimer-3
		else
			data.dwellerGodheadTimer = nil
		end
	end
	if data.dwellerGodheadTimer then
		local val = data.dwellerGodheadTimer*2
		player:SetColor(Color(1,1,1,1,val/255,val/255,val/255), 0, 0, true, false)
	end
end)

function mod:deepDwellerHurt(npc)
	local d = npc:GetData()
    d.hitcount = d.hitcount or 0
	if (d.itemget or not d.itemgotten) and npc.SubType > 0 then
		if not d.invincible then
			npc:ToNPC():PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_5,1,0,false,math.random(11,14)/10)
			d.hitcount = d.hitcount + 1
			npc.HitPoints = npc.HitPoints - 1
		end
		d.invincible = true
		return false
    elseif not d.invincible then
		if d.stats.special == "varicose" then
			local params = ProjectileParams()
			params.FallingSpeedModifier = 0
			params.Scale = 1.8
			npc:ToNPC():FireProjectiles(npc.Position, Vector(10, 10), 9, params)
			if not d.varicose then
				d.stats.range2 = d.stats.range2-0.05 --IMPORTANT (so true)
			end
			d.varicose = 72
		end
		if npc.HitPoints <= 1 then
			npc:Kill()
		else
			npc:ToNPC():PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_5,1,0,false,math.random(11,14)/10)
			d.hurt = true
			d.invincible = true
			d.wasbruised = d.FFBruiseInstances ~= nil and #d.FFBruiseInstances > 0
			d.firing = false
			d.charging = false
			d.state = "Hurt"
			d.hitcount = d.hitcount + 1
			npc.HitPoints = npc.HitPoints - 1
			npc:GetSprite():RemoveOverlay()
			return false
		end
    elseif d.invincible then
        return false
    end
end

function mod.deepDwellerDeathAnim(npc)
    local DeadFish = Isaac.Spawn(1000, 1730, 1, npc.Position, nilvector, npc):ToEffect()
    sfx:Play(SoundEffect.SOUND_MONSTER_YELL_A,1,0,false,math.random(115,125)/100)
    if npc.Velocity.X < 0 then
        DeadFish:GetSprite().FlipX = true
    end
    DeadFish:Update()
end

function mod:dwellerTBobbyAI(npc)
local d = npc:GetData()
local sprite = npc:GetSprite();
local target = npc:GetPlayerTarget()

	if npc.Parent and not mod:isStatusCorpse(npc.Parent) then
		local p = npc.Parent
		local pd = p:GetData()

		local vec = (p.Position - npc.Position)
		if vec:Length() > 80 then
			npc.Velocity = mod:Lerp(npc.Velocity, vec:Resized(5), 0.2)
		elseif vec:Length() > 40 then
			npc.Velocity = mod:Lerp(npc.Velocity, vec:Resized(5), 0.09)
		else
			npc.Velocity = npc.Velocity * 0.95
		end

		if d.cooldown then
			d.cooldown = d.cooldown - 1
			if d.cooldown < 1 then
				d.cooldown = nil
				sprite.FlipX = false
			elseif d.cooldown == 5 then
				sprite:Play("Float" .. mod.dwellerbobbyframe[d.dir][1])
			end
		else
			sprite:Play("FloatDown", true)
		end

		if pd.firing and not d.cooldown then
			if pd.direction then
				if pd.direction then
					npc:PlaySound(mod.Sounds.TearFireFuckYouRevv,0.3,0,false,1.3)
					local params = ProjectileParams()
					params.Scale = 0.5
					for i=-30,30,60 do
						npc:FireProjectiles(npc.Position, Vector(0,8):Rotated(i-pd.direction * 90) + (npc.Velocity/3), 0, params)
					end
					d.cooldown = 15
					local fram = pd.direction
					sprite:Play("FloatShoot" .. mod.dwellerbobbyframe[fram][1])
					sprite.FlipX = mod.dwellerbobbyframe[fram][2]
					d.dir = fram
				end
			end
		end
	else
		npc:Kill()
	end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, damageFlags, source, iFrames)
    if source.Entity and entity:ToNPC() and source.Type == mod.FF.TDweller.ID and source.Variant == mod.FF.TDweller.Var and not mod:isFriend(source.Entity) then
        return false
    end
end)
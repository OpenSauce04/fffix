local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:gobNeckAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()

	if (d.Source and not (d.Source:IsDead() or mod:isStatusCorpse(d.Source)) and d.Source:Exists()) and
	   (d.Home and not (d.Home:IsDead() or mod:isStatusCorpse(d.Home)) and d.Home:Exists()) then
		mod:spritePlay(sprite, "Neck")

		local dist = d.Source.Position:Distance(d.Home.Position)
		local vecfun = d.Home.Position - d.Source.Position
		local targpos = d.Source.Position + vecfun:Resized(dist * ((d.Pos) / (d.Num )))

		local targvel = (targpos - npc.Position):Resized(3)
		--npc.Velocity = targvel
		npc.Velocity = nilvector
		npc.Position = targpos

		npc.SpriteOffset = Vector(0, -10 - (-2 * (d.Pos / d.Num) ))

	else
		npc:Remove()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.gobNeckAI, 1740)

function mod:mrGobAI(npc, subt)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder
	local target = npc:GetPlayerTarget()
	if npc.Parent and target.InitSeed == npc.Parent.InitSeed then
		target = Isaac.GetPlayer(0)
	elseif npc.Child and target.InitSeed == npc.Child.InitSeed then
		target = Isaac.GetPlayer(0)
	end
	local targetpos = mod:confusePos(npc, target.Position)
	local r = npc:GetDropRNG()
	npc.StateFrame = npc.StateFrame + 1
	npc.SplatColor = mod.ColorDankBlackReal

	if subt == 1 then
		local p = npc.Parent
		if p and not mod:isStatusCorpse(p) then
			if not d.state then
				npc.Position = p.Position
				mod:spritePlay(sprite, "HeadAttackStart")
				if sprite:IsEventTriggered("NeckExtend") then
					d.bloodin = true
					npc:PlaySound(SoundEffect.SOUND_MEATHEADSHOOT,1,0,false,1)
					d.state = "shooten"
					npc.Velocity = (targetpos - npc.Position):Resized(11)
					if targetpos.X < npc.Position.X then
						sprite.FlipX = true
					else
						sprite.FlipX = false
					end
					local vecfun = p.Position - npc.Position
					local vecdist = vecfun:Length()
					local numchains = 9
					for i = 1, numchains do
						local chain = Isaac.Spawn(1000, 1740, 0, npc.Position + vecfun:Resized(vecdist * (i / numchains+2)), nilvector, npc):ToEffect()
						local chaind = chain:GetData()
						chaind.Pos = i
						chaind.Num = numchains + 1
						chaind.Source = npc
						chaind.Home = p
						chain:Update()
					end
				end
			elseif d.state == "shooten" then
				if not sprite:IsPlaying("HeadAttackStart") then
					mod:spritePlay(sprite, "HeadAttack")
				end

				if npc.Position.X < p.Position.X then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end

				npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(4)),0.03)

				local pvec = (p.Position - npc.Position)
				if npc.Position:Distance(p.Position) > 120 then
					npc.Velocity = mod:Lerp(npc.Velocity, pvec * 0.1, 0.03)
				elseif npc.Position:Distance(p.Position) > 100 then
					npc.Velocity = npc.Velocity * 0.9
				end

				if npc.FrameCount % 3 == 1 then
					npc:PlaySound(SoundEffect.SOUND_BOSS2_BUBBLES,1,2,false,1.2)
					local pvecl = pvec:Length()
					local rand = r:RandomInt(math.ceil(pvecl)) * 0.8
					local ang = 90
					if r:RandomInt(2) == 1 then ang = -90 end
					local params = ProjectileParams()
					params.Color = mod.ColorDankBlackReal
					params.FallingAccelModifier = 0.5
					params.Scale = 0.7
					npc:FireProjectiles(npc.Position + pvec:Resized(rand), pvec:Rotated(ang):Resized(9), 0, params)

					local gn = mod.FindClosestEntity(npc.Position + pvec:Resized(rand), 50, 1000, 1740)
					if gn then
						gn:SetColor(Color(5,1,1,1,50 / 255,0,0),5,1,true,false)

						local bloo2 = Isaac.Spawn(1000, 2, 1, gn.Position, nilvector, npc):ToEffect();
						bloo2.SpriteScale = Vector(1,1)
						bloo2.SpriteOffset = gn.SpriteOffset
						bloo2.SpriteRotation = math.random(360)
						bloo2.Color = Color(0.1,0.2,0.2,1,0,0,0)
						bloo2:Update()
					end

				end

				if npc.StateFrame > 150 or mod:isScareOrConfuse(npc) then
					d.state = "return"
				end
			elseif d.state == "return" then
				local pvec = (p.Position - npc.Position)
				npc.Velocity = mod:Lerp(npc.Velocity, pvec * 0.1, 0.2)
				if npc.Position:Distance(p.Position) < 7 then
					sfx:Play(SoundEffect.SOUND_SCAMPER, 0.8, 0, false, 1)
					p:GetData().state = "headReturn"
					p:GetData().headHealth = npc.HitPoints
					p:Update()
					npc:Remove()
				end
			end
		else
			npc:Morph(mod.FF.Gob.ID, mod.FF.Gob.Var, 0, -1)
		end

		if d.bloodin then
			local bloodoff = Vector(-8, -13)
			if sprite.FlipX then
				bloodoff = Vector(bloodoff.X * -1, bloodoff.Y)
			end

			local blood = Isaac.Spawn(1000, 7, 0, npc.Position-bloodoff, nilvector, npc)
			blood.SpriteScale = Vector(0.4,0.4)
			blood.Color = Color(0.1,0.2,0.2,1,0,0,0)
			blood:Update()
		end
	else
		if not d.init then
			d.state = "idle"
			d.init = true
		end

		if npc:IsDead() and not (d.state == "attack" or mod:isLeavingStatusCorpse(npc)) then
			local head = Isaac.Spawn(mod.FF.Gob.ID, mod.FF.Gob.Var, 1, npc.Position, nilvector, npc):ToNPC()
			if d.headHealth then
				head.HitPoints = d.headHealth
			end
			head:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			head:Update()
		end

		if d.state == "idle" then
			mod:spriteOverlayPlay(sprite, "HeadNormal")
			if npc.Velocity:Length() > 0.1 then
				npc:AnimWalkFrame("WalkHori","WalkVert",0)
			else
				sprite:SetFrame("WalkVert", 0)
			end

            local room = game:GetRoom()

			if mod:isScare(npc) then
				local targetvel = (targetpos - npc.Position):Resized(-6)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
			elseif room:CheckLine(npc.Position,targetpos,0,1,false,false) then
				local targetvel = (targetpos - npc.Position):Resized(4)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
			else
				path:FindGridPath(targetpos, 0.6, 900, true)
			end

			if npc.StateFrame > 30 and (not mod:isScareOrConfuse(npc)) and room:CheckLine(npc.Position, targetpos,2,1100,true,true) and targetpos:Distance(npc.Position) < 180 then
				d.state = "attack"
				sprite:RemoveOverlay()
				npc.Velocity = nilvector
				sprite:SetFrame("WalkVert", 0)

				local head = Isaac.Spawn(mod.FF.MrGob.ID, mod.FF.MrGob.Var, 1, npc.Position, nilvector, npc):ToNPC()
				head.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
				head.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
				head:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				head.Parent = npc
				npc.Child = head
				if sprite.FlipX then
					head:GetSprite().FlipX = true
				end
				head.RenderZOffset = 500
				if d.headHealth then
					head.HitPoints = d.headHealth
				end
				head:Update()
			end
		elseif d.state == "attack" then
			npc.Velocity = npc.Velocity * 0.7
			sprite:SetFrame("WalkVert", 0)
			if (not npc.Child) or mod:isStatusCorpse(npc.Child) then
				local pacer = Isaac.Spawn(280, 0, 0, npc.Position, nilvector, npc):ToNPC();
				pacer:GetSprite():ReplaceSpritesheet(0, "gfx/enemies/mrgob/gobbody.png")
				pacer:GetSprite():LoadGraphics()
				pacer:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				pacer:Update()
				pacer.HitPoints = npc.HitPoints
				pacer.SplatColor = mod.ColorDankBlackReal
				npc:Remove()
			end
		elseif d.state == "headReturn" then
			npc.Velocity = npc.Velocity * 0.7
			sprite:SetFrame("WalkVert", 0)
			if sprite:IsOverlayFinished("HeadReturn") then
				d.state = "idle"
				npc.StateFrame = 0
			else
				mod:spriteOverlayPlay(sprite, "HeadReturn")
			end
		end
	end
end

function mod:mrGobColl(npc1, npc2)
	if npc1.Parent and npc1.Parent.InitSeed == npc2.InitSeed then -- Prevent selfdamage from charm/bait
		return true
	elseif npc1.Child and npc1.Child.InitSeed == npc2.InitSeed then
		return true
	end
end

function mod:regularGobAI(npc)
	local d = npc:GetData()
	local sprite = npc:GetSprite();
	local target = npc:GetPlayerTarget()
	local targetpos = mod:confusePos(npc, target.Position)
	local r = npc:GetDropRNG()

	if not d.init then
		d.state = "idle"
		d.init = true
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
		npc.SplatColor = mod.ColorDankBlackReal
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	npc.Velocity = npc.Velocity * 0.9

	if npc.Position.X > target.Position.X then
		sprite.FlipX = true
	else
		sprite.FlipX = false
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "HeadShake")
		npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(3)),0.06)
		if npc.StateFrame > 65 and r:RandomInt(20)+1 == 1 and game:GetRoom():CheckLine(target.Position,npc.Position,3,900,false,false) and not mod:isScareOrConfuse(npc) then
			d.state = "startAttack"
		end
	elseif d.state == "startAttack" then
		if sprite:IsFinished("HeadAttackStart") then
			mod:spritePlay(sprite, "HeadAttackShake")
		elseif sprite:IsEventTriggered("NeckExtend") then
			d.attacking = true
			npc.StateFrame = 0
		elseif not sprite:IsPlaying("HeadAttackShake") then
			mod:spritePlay(sprite, "HeadAttackStart")
		end
	elseif d.state == "stopAttack" then
		if sprite:IsFinished("HeadReturn") then
			d.state = "idle"
		elseif sprite:IsEventTriggered("ReturnHead") then
			d.attacking = false
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "HeadReturn")
		end
	end

	if d.attacking then
		if npc.FrameCount % 3 == 1 then
			npc:PlaySound(SoundEffect.SOUND_BOSS2_BUBBLES,1,2,false,1.2)
			local shootvec = (target.Position - npc.Position):Resized(math.random(5,8)):Rotated(-20+math.random(40))
			local proj = Isaac.Spawn(9, 0, 0, npc.Position, shootvec, npc):ToProjectile()
			proj.Scale = math.random(8,10)/10
			proj.Color = mod.ColorDankBlackReal
			proj.FallingSpeed = -15 - math.random(20)/10
			proj.FallingAccel = 0.9 + math.random(10)/10
			npc.Velocity = mod:Lerp(npc.Velocity, shootvec * -1, 0.3)
		end
		local bloodoff = Vector(-8, -13)
		if sprite.FlipX then
			bloodoff = Vector(bloodoff.X * -1, bloodoff.Y)
		end

		local blood = Isaac.Spawn(1000, 7, 0, npc.Position-bloodoff, nilvector, npc)
		blood.SpriteScale = Vector(0.4,0.4)
		blood.Color = Color(0.1,0.2,0.2,1,0,0,0)
		blood:Update()
		if npc.StateFrame > 80 or mod:isScareOrConfuse(npc) then
			d.state = "stopAttack"
		end
	end
end
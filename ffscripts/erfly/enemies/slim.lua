local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero
local sfx = SFXManager()
local rng = RNG()

local function shouldPlayerSlapHurt(player)
	local playerType = player:GetPlayerType()
	local effects = player:GetEffects()

	return (
		playerType == FiendFolio.PLAYER.GOLEM or
		playerType == FiendFolio.PLAYER.BOLEM or
		playerType == PlayerType.PLAYER_APOLLYON or
		playerType == PlayerType.PLAYER_APOLLYON_B or
		effects:HasNullEffect(NullItemID.ID_TOOTH_AND_NAIL) or
		effects:HasNullEffect(NullItemID.ID_REVERSE_CHARIOT)
	)
end

function mod:slimRelay(npc, subType, variant)
    if subType == mod.FF.Limb.Sub then
		if variant == mod.FF.RedHand.Var then
			mod:RedHandAI(npc, npc:GetSprite(), npc:GetData())
		else
        	mod:limbAI(npc, variant)
		end
    else
        mod:slimAI(npc, variant, subType)
    end
end

function mod:slimAI(npc, var, subt)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local path = npc.Pathfinder
	local target = npc:GetPlayerTarget()
    local room = game:GetRoom()

	if not d.init then
		if var == mod.FF.SlimShady.Var then
			npc.SplatColor = FiendFolio.ColorShadyBlack 
			d.jumpCooldown = 2
		end
		d.state = "idle"
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	--Animation Funnies
	if d.state == "idle" then
		if npc.Velocity:Length() > 0.05 then
			local velx = npc.Velocity.X
			local vely = npc.Velocity.Y
			if math.abs(velx) > math.abs(vely) then
				if velx > 0 then
					d.dir = "Right"
				else
					d.dir = "Left"
				end
			else
				if vely > 0 then
					d.dir = "Down"
				else
					d.dir = "Up"
				end
			end
			mod:spritePlay(sprite, "Walk " .. d.dir)
			d.idle2 = false
		else
			if subt == 1 then
				sprite:SetFrame("Walk Down", 18)
			else
				if d.idle2 then
					if sprite:IsFinished("Idle2") then
						d.idle2 = false
					else
						mod:spritePlay(sprite, "Idle2")
					end
				else
					mod:spritePlay(sprite, "Idle")
					if math.random(150) == 1 then
						d.idle2 = true
					end
				end
			end
		end

		--Movement
		if subt == 1 or mod:isConfuse(npc) then
			if npc.StateFrame > 160 or not d.walktarg then
				d.walktarg = mod:FindRandomValidPathPosition(npc)
				npc.StateFrame = 0
			end
			if npc.Position:Distance(d.walktarg) > 30 then
				if room:CheckLine(npc.Position,d.walktarg,0,1,false,false) or mod:isScare(npc) then
					local targetvel = mod:runIfFear(npc, (d.walktarg - npc.Position):Resized(2))
					npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.2)
				else
					path:FindGridPath(d.walktarg, 0.25, 900, true)
				end
			else
				npc.Velocity = npc.Velocity * 0.8
				npc.StateFrame = npc.StateFrame + 2
			end
		else
			local targetpos = target.Position
			if room:CheckLine(npc.Position,targetpos,0,1,false,false) or mod:isScare(npc) then
				local targetvel = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(3))
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
			else
				path:FindGridPath(targetpos, 0.4, 900, true)
			end
		end
		local targetdist = 90
		if var == mod.FF.SlimShady.Var then
			targetdist = 200
		end
		if ((subt ~= 1 and npc.Position:Distance(target.Position) < targetdist) or (subt == 1 and math.random(20) == 1)) and npc.StateFrame > 25 and not mod:isScareOrConfuse(npc) then
			if var == mod.FF.SlimShady.Var and d.jumpCooldown <= 0 then
				npc.Velocity = Vector.Zero
				sprite:Play("Jump")
				d.state = "JUMP"
			else
				local vec = target.Position - npc.Position
				if subt == 1 then
					vec = RandomVector()
				end
				d.punchvec = mod:SnapVector(vec:Resized(25), 90)
				local velx = vec.X
				local vely = vec.Y
				if math.abs(velx) > math.abs(vely) then
					if velx > 0 then
						d.dir = "Right"
					else
						d.dir = "Left"
					end
				else
					if vely > 0 then
						d.dir = "Down"
					else
						d.dir = "Up"
					end
				end
				d.state = "PUNCH"
				if var == mod.FF.SlimShady.Var then
					d.ChargeVel = mod:reverseIfFear(npc, (vec/16))
					d.jumpCooldown = d.jumpCooldown - 1
				else
					npc.Velocity = npc.Velocity + d.punchvec:Resized(5.5)
				end
				d.idle2 = false
			end
		end
	elseif d.state == "PUNCH" then
		if d.ChargeVel then
			npc.Velocity = d.ChargeVel
			if game:GetRoom():GetGridCollisionAtPos(npc.Position + d.ChargeVel) > 0 then
				d.ChargeVel = nil
				npc.Velocity = Vector.Zero
			elseif npc.FrameCount % 2 == 0 then
				mod:MakeAfterimage(npc)
			end
		else
			npc.Velocity = npc.Velocity * 0.9
		end
		if sprite:IsFinished("Strike " .. d.dir) then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsPlaying("Strike " .. d.dir) and sprite:GetFrame() == 1 then
			npc:PlaySound(mod.Sounds.WingFlap,1,0,false,math.random(120,130)/100)
		elseif sprite:IsEventTriggered("Hit") then
			if var == mod.FF.SlimShady.Var then 
				d.ChargeVel = nil
				npc.Velocity = Vector.Zero
			end
			local coll = room:GetGridCollisionAtPos(npc.Position + d.punchvec:Resized(40))
			if coll > 1 then
				local grident = room:GetGridEntity(room:GetGridIndex(npc.Position + d.punchvec:Resized(40)))
				if grident and grident.Desc.Type == GridEntityType.GRID_POOP then
					grident:Destroy()
					npc:PlaySound(SoundEffect.SOUND_SHELLGAME,1,0,false,math.random(65,75)/100)
				else
					mod:SlimArmHurt(npc, d)
				end
				--npc:TakeDamage(5, 0, EntityRef(npc), 0)
			else
				local hasHit
				for _,entity in ipairs(Isaac.GetRoomEntities()) do
					if entity.Position:Distance(npc.Position + d.punchvec) < 40 then
						if mod:isDamagableByStatus(npc, entity) then
							if entity.InitSeed ~= npc.InitSeed and entity:IsActiveEnemy() and entity.Variant ~= 1003 then
								entity:TakeDamage(15, 0, EntityRef(npc), 0)
								hasHit = true
								entity.Velocity = entity.Velocity + d.punchvec
							end
						else
							if entity.Type == 1 then
								entity = entity:ToPlayer()
								npc:PlaySound(mod.Sounds.EpicPunch,1,0,false,1)
								hasHit = true
								entity:TakeDamage(1, 0, EntityRef(npc), 0)
								entity.Velocity = entity.Velocity + d.punchvec:Resized(2)
								if shouldPlayerSlapHurt(entity:ToPlayer()) then
									mod:SlimArmHurt(npc, d)
								end
							end
						end
					end
				end
				if not hasHit then
					npc:PlaySound(SoundEffect.SOUND_SHELLGAME,1,0,false,math.random(65,75)/100)
				elseif mod:isFriend(npc) and hasHit then
					npc:PlaySound(mod.Sounds.EpicPunch,1,0,false,1)
				end
			end
		else
			mod:spritePlay(sprite, "Strike " .. d.dir)
		end
	elseif d.state == "JUMP" then
		npc.Velocity = Vector.Zero
		if sprite:IsFinished("Jump") then
			d.state = "idle"
			npc.StateFrame = 0
			d.jumpCooldown = 3
		end
		if sprite:IsEventTriggered("Jump") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
		elseif sprite:IsEventTriggered("Land") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
			for i = 45, 360, 45 do
				local effect = Isaac.Spawn(1000, 144, 1, npc.Position+Vector(0,75):Rotated(i), Vector.Zero, npc)
				effect.Parent = npc
				if mod:isFriend(npc) then
					mod:DamageEnemiesInRadius(effect.Position, 40, 40, npc)
				else
					mod:DamagePlayersInRadius(effect.Position, 40, 1, npc)	
				end
				sfx:Play(SoundEffect.SOUND_DEMON_HIT)
			end
			local effect = Isaac.Spawn(1000,16,3,npc.Position,Vector.Zero,npc)
			for i = 30, 360, 30 do
				local nova = Isaac.Spawn(mod.FF.SlimShadyNova.ID, mod.FF.SlimShadyNova.Var, mod.FF.SlimShadyNova.Sub, npc.Position+Vector(0,120):Rotated(i), Vector.Zero, npc)
				if mod:isFriend(npc) then
					nova:GetData().Friendly = true
				end
			end
		end
	elseif d.state == "OW" then
		npc.Velocity = npc.Velocity * 0.1
		if not d.throbstate then
			if sprite:IsFinished("Ouch " .. d.dir) then
				if var == mod.FF.SlimShady.Var then
					d.state = "idle"
					npc.StateFrame = 0
					d.throbstate = nil
				else
					d.throbstate = 1
					npc.StateFrame = 0
					if d.dir ~= "Left" then
						d.dir = "UpRightDown"
						d.Vec = 15
					else
						d.Vec = -15
					end
				end
			elseif sprite:GetFrame() == 1 and not var == mod.FF.SlimShady.Var then
				npc:TakeDamage(5, 0, EntityRef(npc), 0)
			else
				mod:spritePlay(sprite, "Ouch " .. d.dir)
			end
		elseif d.throbstate == 1 then
			mod:spritePlay(sprite, "Hurt " .. d.dir)
			if npc.StateFrame % 4 == 1 then
				local shotspeed = RandomVector()*3
				local params = ProjectileParams()
				params.Scale = math.random(7, 9) / 10
				params.FallingSpeedModifier = -15 - math.random(10)/10
				params.FallingAccelModifier = 1.4 + math.random(2)/10;
				npc:FireProjectiles(npc.Position + Vector(d.Vec, 1), shotspeed, 0, params)
			end
			if npc.StateFrame > 50 then
				d.throbstate = 2
			end
		elseif d.throbstate == 2 then
			if sprite:IsFinished("Recover " .. d.dir) then
				d.state = "idle"
				npc.StateFrame = 0
				d.throbstate = nil
			else
				mod:spritePlay(sprite, "Recover " .. d.dir)
			end
		end
	end

	if npc:IsDead() then
		local rand = 5
		if d.GOTHURT then
			rand = 8
		end
		if math.random(rand) == 1 then
			local limb = Isaac.Spawn(npc.Type, var, 2, npc.Position, RandomVector():Resized(10), npc)
			limb:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			limb:GetData().state = "drop"
			limb:Update()
		end
	end
end

function mod:SlimArmHurt(npc, d)
	if npc.Variant == mod.FF.SlimShady.Var then
		local params = ProjectileParams()
		params.Color = mod.ColorShadyRed
		params.Scale = 1.5
		params.FallingAccelModifier = -0.06
		params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
		npc:FireProjectiles(npc.Position + d.punchvec, Vector(10,10), 9, params)
		mod:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, npc, 0.7)
		local effect = Isaac.Spawn(1000,2,3, npc.Position + d.punchvec, Vector.Zero, npc)
	else
		d.GOTHURT = true
		npc:PlaySound(SoundEffect.SOUND_BONE_SNAP, 0.6, 0, false, math.random(8, 12)/10)
	end
	d.state = "OW"
end

function mod:paleSlimKill(npc)
    if npc.SubType == mod.FF.PaleSlim.Sub then
        if npc:ToNPC():GetDropRNG():RandomInt(2) == 1 then
            if not (npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) or npc:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) or mod:isLeavingStatusCorpse(npc)) then
                local spawned = Isaac.Spawn(mod.FF.Jim.ID, mod.FF.Jim.Var, mod.FF.Jim.Sub, npc.Position, npc.Velocity, npc)
                spawned:ToNPC():Morph(spawned.Type, spawned.Variant, spawned.SubType, npc:ToNPC():GetChampionColorIdx())
                spawned.HitPoints = spawned.MaxHitPoints
                spawned:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

                if (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                    spawned:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
                end

                npc:Remove()
            end
        end
    end
end

function mod:SlimShadyNovaAI(effect, sprite, data)
	if not data.Init then
		sprite:Play("Glow")
		data.Init = true
	end
	if sprite:IsFinished("Glow") then
		Isaac.Spawn(1000,144,1,effect.Position,Vector.Zero,effect)
		local source
		if effect.SpawnerEntity then
			source = effect.SpawnerEntity
		end
		if data.Friendly then
			mod:DamageEnemiesInRadius(effect.Position, 40, 40, source)
		else
			mod:DamagePlayersInRadius(effect.Position, 40, 1, source)
		end
		sfx:Play(SoundEffect.SOUND_DEMON_HIT)
		effect:Remove()
	end
end

function mod:limbAI(npc, var)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local path = npc.Pathfinder
	local target = npc:GetPlayerTarget()

	if not d.init then
		d.state = d.state or "idle"
		d.init = true
		d.bleedin = true
		if math.random(2) == 1 then
			sprite.FlipX = true
		end
		npc.SpriteOffset = Vector(0,-1)
	else
		npc.StateFrame = npc.StateFrame + 1
	end
	if var == mod.FF.PaleLimb.Var then
		if d.bleedin and npc.FrameCount % 20 == 0 then
			local creep = Isaac.Spawn(1000,22,0,npc.Position,Vector.Zero,npc):ToEffect()
			creep:SetTimeout(60)
			creep.Scale = creep.Scale * 0.5
			creep:Update()
		end
	end
	if d.state == "idle" then
		npc.Velocity = npc.Velocity * 0.8
		if not sprite:IsPlaying("Idle2") then
			mod:spritePlay(sprite, "Idle")
			if math.random(50) == 1 then
				mod:spritePlay(sprite, "Idle2")
			end
		end
		if target.Position:Distance(npc.Position) < 120 and npc.StateFrame > 30 then
			d.state = "jompe"
			npc.StateFrame = 0
		end
	elseif d.state == "jompe" then
		npc.Velocity = npc.Velocity * 0.9
		if sprite:IsFinished("Leap") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Jump") then
			npc.Velocity = (target.Position - npc.Position):Resized(10):Rotated(-60 + math.random(120))
			d.bleedin = false
			if npc.Velocity.X > 0 then
				sprite.FlipX = true
			else
				sprite.FlipX = false
			end
		elseif sprite:IsEventTriggered("Land") then
			npc.Velocity = npc.Velocity * 0.5
			d.bleedin = true
		else
			mod:spritePlay(sprite, "Leap")
		end
	elseif d.state == "drop" then
		npc.Velocity = npc.Velocity * 0.9
		if sprite:IsFinished("Spawn") then
			d.state = "idle"
		elseif sprite:IsEventTriggered("Land") then
			npc.Velocity = npc.Velocity * 0.5
		else
			mod:spritePlay(sprite, "Spawn")
		end
	end
end

function mod:RedHandAI(npc, sprite, data)
	local target = npc:GetPlayerTarget()
	local targetpos = mod:confusePos(npc, target.Position)
	if not data.Init then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		if rng:RandomFloat() <= 0.5 then
			sprite.FlipX = true
		end
		sprite:Play("Spawn")
		data.Init = true
	end
	if sprite:IsPlaying("Idle") then
		local vel
		if mod:isScare(npc) then
			vel = (targetpos - npc.Position):Resized(-10)
		else
			vel = (targetpos - npc.Position):Resized(10)
		end
		npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.1)
		mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
		if sprite:IsEventTriggered("Shoot") then
			local params = ProjectileParams()
			params.Variant = 4
			params.Color = Color(1,1,1,1,1,0,0)
			params.FallingAccelModifier = -0.06
			params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
			npc:FireProjectiles(npc.Position, Vector(0,0), 0, params)
			local effect = Isaac.Spawn(1000,2,1,npc.Position,Vector.Zero,npc)
			effect.SpriteOffset = Vector(0,-17)
			mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc, 1.2, 0.5)
		end
	else
		if sprite:IsFinished("Spawn") then
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			sprite:Play("Idle")
		end
		npc.Velocity = Vector.Zero
	end
end
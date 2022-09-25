local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--Phoenix is all by Julia

function mod:bumblerAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local isBuckshot = (npc.Variant == mod.FF.Buckshot.Var)

	local anims = mod.bumbleranims
	if npc.Type == mod.FF.Phoenix.ID and npc.Variant == mod.FF.Phoenix.Var then
		anims = mod.phoenixanims

		if npc.SubType == 2 then
			if not d.init then
                --npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				sprite:Load("gfx/enemies/phoenix/monster_phoenix02.anm2", true)
                sprite:Play("Idle", true)
				npc.SplatColor = mod.ColorFireJuicy
			end

			if npc.FrameCount % 30 == 0 and npc.Velocity ~= nilvector then --blood splat effect spawning
				local color = Color(1, 0.45, 0.05, 1, 1/1.2, 0.45/1.2, 0.05/1.2)
				color:SetColorize(1, 0.45, 0.05, 1)

				local splat = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc):ToEffect()
				splat:GetData().fire = true
				splat.Color = color
				splat.Scale = math.random(3,7)/10
			end
		elseif npc.SubType == 0 then
			npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
		end
	end

	if npc.State == 11 then --phoenix death anim
		mod:spritePlay(sprite, "Death")

		if sprite:GetFrame() < 10 then --fall
			npc.SpriteOffset = Vector(0,math.min(0, npc.SpriteOffset.Y + 1))
		end

		if sprite:IsFinished("Death") then --spawn corpse
			local corpse = Isaac.Spawn(npc.Type, npc.Variant, 1, npc.Position, npc.Velocity, npc)
			corpse:ToNPC():Morph(corpse.Type, corpse.Variant, corpse.SubType, npc:ToNPC():GetChampionColorIdx())
			corpse.HitPoints = 30
			corpse:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			corpse:GetSprite():Play("Corpse", true)
			npc:Remove()
		end

		return
	else
		npc.SpriteOffset = Vector(0,-10)
	end

	if not d.init then
		d.state = "idle"
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE) then
		d.passive = true
		npc.CollisionDamage = 0
	else
		d.passive = false
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		local targpos = mod:confusePos(npc, target.Position - (target.Velocity * 40))
		local targvel = mod:reverseIfFear(npc, (targpos - npc.Position):Resized(4))
		npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.25)

		if npc.StateFrame > 30 then
			local targrel = mod:GetPositionAligned(npc.Position, target.Position, 50)
			if npc.Position:Distance(target.Position) < 180 and targrel and not (mod:isScareOrConfuse(npc) or d.passive) then
				d.targrel = targrel
				d.state = "attack"
				d.anim = "Shoot"
				npc.StateFrame = 0
			end
		end

	elseif d.state == "attack" then
		if not d.shooting then
			npc.Velocity = npc.Velocity * 0.3
		end
		sprite.FlipX = anims[d.targrel][2]
		if sprite:IsFinished("Shoot" .. anims[d.targrel][1]) then
			d.state = "travelling"
		elseif sprite:IsPlaying("Shoot" .. anims[d.targrel][1]) and sprite:GetFrame() == 8 then
			npc:PlaySound(SoundEffect.SOUND_FART_GURG,0.5,0,false,math.random(175,185)/100)
		elseif sprite:IsEventTriggered("Shoot") then
			d.shooting = true
			if isBuckshot then
				if d.targrel % 2 == 1 then
					npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS_Y
				else
					npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS_X
				end
				d.wraps = 2
			end
		else
			mod:spritePlay(sprite, "Shoot" .. anims[d.targrel][1])
		end

	elseif d.state == "travelling" then
		mod:spritePlay(sprite, "Shoot" .. anims[d.targrel][1] .. "Loop")
	elseif d.state == "collide" then
		npc.Velocity = npc.Velocity * 0.2
		if sprite:IsFinished("Shoot" .. anims[d.targrel][1] .. "End") then
			d.state = "idle"
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "Shoot" .. anims[d.targrel][1] .. "End")
		end
	elseif d.state == "charge" then
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		if sprite:IsPlaying("Charge"..d.suffix.."Loop") or sprite:WasEventTriggered("Shoot") then
			local movevel = Vector(0, 25):Rotated(d.targrel * 90)
			npc.Velocity = movevel
			if npc:CollidesWithGrid() then
				local lol = Isaac.Spawn(822, 0, 0, npc.Position, Vector.Zero, npc):ToNPC() --Spawn a Bouncer and kill it bc lazy and its what i wanted anyway
				lol.Parent = npc
				lol.State = 16
				lol.Visible = false
				lol:Kill()
				npc:Kill()
			end
		end
		if sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(mod.Sounds.Ricochet,1.5,0,false,0.6)
		elseif sprite:IsFinished("Charge"..d.suffix) then
			mod:spritePlay(sprite, "Charge"..d.suffix.."Loop")
		end
	end

	if d.shooting then
		local movevel = Vector(0, -13):Rotated(d.targrel * 90)
		if isBuckshot then
			if d.targrel % 2 == 1 then
				local diff = Vector(0, target.Position.Y - npc.Position.Y)
				diff = diff:Resized(math.min(diff:Length(), 2))
				movevel = movevel + diff
			else
				local diff = Vector(target.Position.X - npc.Position.X, 0)
				diff = diff:Resized(math.min(diff:Length(), 2))
				movevel = movevel + diff
			end
			local wrappos = room:ScreenWrapPosition(npc.Position, -120)
			if wrappos:Distance(npc.Position) > 100 then --Check if you screen wrapped
				d.wraps = d.wraps - 1
			end
			npc.Position = wrappos
		end
		npc.Velocity = mod:Lerp(npc.Velocity, movevel, 0.25)
		if npc.Type == mod.FF.Phoenix.ID and npc.Variant == mod.FF.Phoenix.Var then 			--PHOENIX
			if npc.SubType == 2 then																--revived form
				if npc.StateFrame % 3 == 0 then
					npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,0,false,math.random(90,110)/100)
					--color:SetColorize(1, 1, 1, 1)

					local proj = Isaac.Spawn(9, 0, 0, npc.Position, Vector(0, 10):Rotated((math.random(20) - 10) + (d.targrel * 90)), npc):ToProjectile()

					proj.Color = FiendFolio.ColorCrackleOrange	--your salvation is here :))))
					proj:GetData().customFireShot = true
					proj.FallingSpeed = math.random(2, 5)
				end
			else																					--previved form
				if npc.StateFrame % 6 == 0 then
					npc:PlaySound(SoundEffect.SOUND_WHEEZY_COUGH,1,0,false,math.random(90,110)/100)

					if not d.spawnedFlyBomb then 													--spawn 1 grounded fly bomb
						local fly = Isaac.Spawn(EntityType.ENTITY_FLY_BOMB, 0, 0, npc.Position, Vector(0, 10):Rotated((math.random(20) - 10) + (d.targrel * 90)), npc):ToNPC()
						fly.State = 3
						fly:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
						fly:Die()

						d.spawnedFlyBomb = true
					else
						--npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,0,false,math.random(90,110)/100)
						local boneColor = Color(0.45, 0.4, 0.4, 1, 0, 0, 0)							--slow bones
						boneColor:SetColorize(0.35, 0.3, 0.3, 1)

						local params = ProjectileParams()
						params.Variant = 1
						--params.Color = boneColor

						npc:FireProjectiles(npc.Position, Vector(0, 5):Rotated((math.random(40) - 20) + (d.targrel * 90)), 0, params)
					end
				end
			end
		elseif isBuckshot then
			if npc.StateFrame % 4 == 1 and room:IsPositionInRoom(npc.Position, 0) then
				local angle = d.targrel * 90
				local shootvec = Vector(0,1):Rotated(angle)
				local offset = shootvec:Rotated(90):Resized(mod:RandomInt(-10,10))
				local fly = Isaac.Spawn(mod.FF.ShotFly.ID, mod.FF.ShotFly.Var, 0, npc.Position + shootvec:Resized(20) + offset, shootvec:Resized(14), npc) 
				fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				fly:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_REWARD)  
				local suffix = anims[d.targrel][1]
				if suffix == "Hori" then
					if d.targrel == 3 then
						fly:GetSprite():Play("ChargeRight")
					else
						fly:GetSprite():Play("ChargeLeft")
					end
				else
					fly:GetSprite():Play("Charge" .. suffix)
				end
				fly:GetData().Charging = true
				if d.wraps <= 0 then
					npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
				end
			end
		else --BUMBLER
			if npc.StateFrame % 3 == 1 then
				npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,0,false,math.random(90,110)/100)
				npc:FireProjectiles(npc.Position, Vector(0, 10):Rotated((math.random(20) - 10) + (d.targrel * 90)), 0, ProjectileParams())
			end
		end

		if npc:CollidesWithGrid() then
			if npc.Type == mod.FF.Phoenix.ID and npc.Variant == mod.FF.Phoenix.Var and npc.SubType == 2 then --special phoenix wall impact
				local fireProj = Isaac.Spawn(9, 2, 0, npc.Position, nilvector, npc):ToProjectile()
				fireProj.ProjectileFlags = ProjectileFlags.FIRE_WAVE_X
				fireProj:Die()
				game:ShakeScreen(5)
			elseif isBuckshot then
				local params = ProjectileParams()
				params.Scale = 1.5
				npc:FireProjectiles(npc.Position, Vector(10,10), 9, params)
			end
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS,1,2,false,1)
			d.state = "collide"
			d.shooting = false

			d.spawnedFlyBomb = false
		elseif npc.StateFrame > 200 and not isBuckshot then
			d.state = "idle"
			npc.StateFrame = 0
			d.shooting = false

			d.spawnedFlyBomb = false
		end
	end
end

mod.bumbleranims = {
    [0] = {"Down", false},
    [1] = {"Hori", true},
    [2] = {"Up", false},
    [3] = {"Hori", false}
}

mod.phoenixanims = {
    [0] = {"Down", false},
    [1] = {"Left", false},
    [2] = {"Up", false},
    [3] = {"Right", false}
}

function mod.BuckshotDeathAnim(npc)
	local targpos = npc:GetPlayerTarget().Position
	local anims = mod.phoenixanims
	local targrel = mod:GetPositionAligned(npc.Position, targpos)
	local suffix = anims[targrel][1]
	local anim = "Charge" .. suffix
	local onCustomDeath = function(npc, deathAnim)
		local data = deathAnim:GetData()
		deathAnim:GetSprite().FlipX = false
		data.init = true
		data.targrel = targrel
		data.suffix = suffix
		data.state = "charge"
	end
	mod.genericCustomDeathAnim(npc, anim, true, onCustomDeath, true)
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, amount, flags, source, countdown) --so revived phoenix doesnt get hurt by its own fire blast   and immunity during death/revive
    if ent.Variant == mod.FF.Phoenix.Var then
        if ent.SubType > 0 and mod:HasDamageFlag(flags, DamageFlag.DAMAGE_FIRE) then
			return false
		elseif ent:ToNPC().State == 11 then
            return false
        end
        if ent:GetSprite():IsPlaying("Revive") then
            ent:AddHealth(amount * 0.9)
        end
    end
end, mod.FF.Phoenix.ID)

function mod:phoenixKill(npc)
    local data = npc:GetData()

    if not data.FFIsDeathAnimation then
        if not (npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) or npc:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) or mod:isLeavingStatusCorpse(npc)) then
            local spawned = Isaac.Spawn(npc.Type, npc.Variant, npc.SubType, npc.Position, nilvector, npc)
            spawned:ToNPC():Morph(spawned.Type, spawned.Variant, spawned.SubType, npc:ToNPC():GetChampionColorIdx())
            spawned.HitPoints = 0
            spawned:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            spawned:ToNPC().State = 11

            local spawnedData = spawned:GetData()
            spawnedData.FFIsDeathAnimation = true

            if (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                spawned:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
            end

            npc:Remove()
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, ent) --phoenix 2nd form fire projectiles (spawn fire jet and sometimes a movable fire), custom because the default flag wasnt spawning movable fires enough for my taste
    if ent:GetData().customFireShot then
        Isaac.Spawn(1000, 147, 0, ent.Position, nilvector, ent)
        if math.random(0, 2) > 0 then
            local fire = Isaac.Spawn(33, 10, 0, ent.Position, nilvector, ent.SpawnerEntity)
			fire.HitPoints = fire.HitPoints / 1.25
			fire:Update()
        end
    end
end, 9)

function mod:phoenixCorpseAI(npc)		--phoenix corpse update
    local sprite = npc:GetSprite()
    local count = 0

    --npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND

    if sprite:IsFinished("Revive") then 						--rise my little phoenix!!
        local spawned = Isaac.Spawn(npc.Type, npc.Variant, 2, npc.Position, nilvector, npc)
        spawned:ToNPC():Morph(spawned.Type, spawned.Variant, spawned.SubType, npc:ToNPC():GetChampionColorIdx())
        spawned.HitPoints = 30
		spawned.SplatColor = mod.ColorFireJuicy
        spawned:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        spawned:Update()
        npc:Remove()
    end

    --for _, e in pairs(Isaac.GetRoomEntities()) do 				--if there are no other enemies left, revive (should this have some complicated way to check for needles that are currently underground or does it not matter hm)
        --if e:IsActiveEnemy() and e:IsVulnerableEnemy() and not e:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and not (e.Type == mod.FF.Phoenix.ID and e.Variant == mod.FF.Phoenix.Var and e.SubType > 0) and e.Type ~= 286 and e.Type ~= 212 then
        --	count = count + 1
        --end
    --end

    --if count > 0 and not sprite:IsPlaying("Revive") then
    if mod.CanIComeOutYet() == false and not sprite:IsPlaying("Revive") then
        mod:spritePlay(sprite, "Corpse")
    else
        mod:spritePlay(sprite, "Revive")
    end

    if sprite:IsPlaying("Revive") then
        if sprite:IsEventTriggered("ShootFire") then --FIRE
			npc.SplatColor = mod.ColorFireJuicy
            local dir = math.random(0, 3)
            local angle = 0

            if dir == 0 then
                angle = math.random(35, 55)
            elseif dir == 1 then
                angle = math.random(125, 145)
            elseif dir == 2 then
                angle = math.random(215, 235)
            else
                angle = math.random(305, 325)
            end
            local vel = Vector(math.random(7,8) * math.sin(math.rad(angle)), math.random(7,8) * math.cos(math.rad(angle)))
            local fire = Isaac.Spawn(1000, 7005, 0, npc.Position, vel, npc):ToEffect()
            local scale = math.random(6, 7)/10
            fire.SpriteScale = Vector(scale, scale)
            fire:GetData().timer = 4
            fire:Update()
        end

        --if sprite:GetFrame() == 12 then   		--GAMEFEEL (too much)
        --	game:ShakeScreen(70)
        --end

        if sprite:GetFrame() == 62 then				--RRAAAGhhh
            npc:PlaySound(SoundEffect.SOUND_MONSTER_YELL_A, 1, 0, false, 1)
        end

        if sprite:GetFrame() > 75 then 				--go up in the air again
            npc.SpriteOffset = Vector(0,math.max(-10, npc.SpriteOffset.Y - 1))
        end

        if sprite:IsEventTriggered("FireWave") then --do + shaped wave
            game:ShakeScreen(5)
			npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, 0.8, 0, false, 1)
            local fireProj = Isaac.Spawn(9, 2, 0, npc.Position, nilvector, npc):ToProjectile()
            fireProj.ProjectileFlags = ProjectileFlags.FIRE_WAVE
            fireProj:Die()							--(hacky way to spawn the wave without the projectile)

            --for i=0, 3 do
            --	if i == 0 then
            --		angle = 45
            --	elseif i == 1 then
            --		angle = 135
            --	elseif i == 2 then
            --		angle = 225
            --	else
            --		angle = 315
            --	end

                --local vel = Vector(8 * math.sin(math.rad(angle)), 8 * math.cos(math.rad(angle)))  		<-----  adding another fire cross to respawn anim (bit too intense)
                --local fire = Isaac.Spawn(1000, 7005, 0, npc.Position, vel, npc):ToEffect()
                --local fire = Isaac.Spawn(33, 10, 0, npc.Position, vel, npc)
            --end
        end
    end

    npc.Velocity = mod:Lerp(npc.Velocity, nilvector, 0.2) --stay relatively still because youre a corpse
end

--mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
--	if eff:GetData().fire then
--		--local gray = Color(0.2, 0.2, 0.2, 1, 0.2, 0.2, 0.2)
--		--eff.Color = Color.Lerp(eff.Color, gray, 0.5)
--		eff.Color = eff.Color:SetColorize(1, 1, 1, 1)
--	end
--end, 7)
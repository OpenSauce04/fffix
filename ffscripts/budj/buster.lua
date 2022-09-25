local mod = FiendFolio

local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local function EnqueueList(orig, new)
    for i = #new, 1, -1 do
        table.insert(orig, 1, new[i])
    end
end

FiendFolio.Buster = {
	Id = {
		Type = mod.FF.Buster.ID,
		Variant = mod.FF.Buster.Var,
		SubType = 0
    },

    Sfx = {
		--[[
        SpitoomEat       = function(npc) npc:PlaySound(SoundEffect.SOUND_THE_STAIN_BURST, 1.3, 0, false, 1) end,
        SpitoomBite      = function(npc) npc:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_1, 1, 0, false, 0.8) end,
        SpitoomChew      = function(npc) npc:PlaySound(SoundEffect.SOUND_MOUTH_FULL, 1, 0, false, 1) end,
        SpitoomSpit      = function(npc) npc:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_2, 1, 0, false, 1) end,
        HotShriekScream  = function(npc) npc:PlaySound(SoundEffect.SOUND_BOSS_BUG_HISS, 1, 0, false, 1.5) end,
        ChewDashWindup   = function(npc) npc:PlaySound(SoundEffect.SOUND_MONSTER_ROAR_1, 1, 0, false, 0.8) end,
        DashWindup       = function(npc) npc:PlaySound(SoundEffect.SOUND_DOG_BARK, 1, 0, false, 0.6) end,
        CarpetDashWindup = function(npc) npc:PlaySound(SoundEffect.SOUND_DOG_HOWELL, 1, 0, false, 0.6) end,
        DashCharge       = function(npc) npc:PlaySound(SoundEffect.SOUND_LITTLE_HORN_GRUNT_2, 1, 0, false, 0.4) end,
        DashEnd          = function(npc) npc:PlaySound(mod.Sounds.FireFizzle, 0.4, 0, false, 1.3) end,
        BurpSpawn        = function(npc) sfx:Play(mod.Sounds.FireLight, 0.3, 0, false, 1.3) end,
        BurpSkyRumble    = function(npc) npc:PlaySound(SoundEffect.SOUND_GRROOWL, 0.8, 4, false, 0.4) end,
        BurpSkyShoot     = function(npc) npc:PlaySound(SoundEffect.SOUND_FAT_GRUNT, 1, 0, false, 0.8) end,
        Whistle          = function(npc) npc:PlaySound(SoundEffect.SOUND_WHISTLE, 1, 0, false, 0.8) end,
        Snicker          = function(npc) npc:PlaySound(SoundEffect.SOUND_BROWNIE_LAUGH, 1, 0, false, 0.9) end,
        Death            = function(npc) sfx:Play(SoundEffect.SOUND_BOSS_BUG_HISS, 1.2, 0, false, 0.8) end,
		]] -- The old ones

        Flying           = function(npc) sfx:Play(SoundEffect.SOUND_INSECT_SWARM_LOOP, 0.4, 0, true, 0.7) end,
        SpitoomEat       = function(npc) npc:PlaySound(mod.Sounds.BusterEatStart, 1.3, 0, false, 1) end,
        SpitoomBite      = function(npc) npc:PlaySound(mod.Sounds.BusterEatChew, 1, 0, false, 1) end,
        SpitoomChew      = function(npc) npc:PlaySound(mod.Sounds.BusterWalkChewLoop, 1, 0, false, 1) end,
        SpitoomSpit      = function(npc) npc:PlaySound(mod.Sounds.BusterSpitoomAttack, 1, 0, false, 1) end,
        SpitoomCharge    = function(npc) npc:PlaySound(mod.Sounds.BusterSpitoomCharge, 1, 0, false, 1) end,
        HotShriekStart   = function(npc) npc:PlaySound(mod.Sounds.BusterHotShriekStart, 1, 0, false, 1) end,
        HotShriekScream  = function(npc) npc:PlaySound(mod.Sounds.BusterHotShriekScream, 1, 0, false, 1) end,
        ChewDashWindup   = function(npc) npc:PlaySound(mod.Sounds.BusterChargeStart, 1, 0, false, 1) end,
        DashWindup       = function(npc) npc:PlaySound(mod.Sounds.BusterChargeEnd2, 1, 0, false, 1) end,
        CarpetDashWindup = function(npc) npc:PlaySound(mod.Sounds.BusterChargeStart2, 1, 0, false, 1) end,
        ChargeRoar       = function(npc) npc:PlaySound(mod.Sounds.BusterChargeEnd1, 1, 0, false, 1) end,
        DashCharge       = function(npc) npc:PlaySound(mod.Sounds.BusterChargeLoop, 1, 0, false, 1) end,
        DashEnd          = function(npc) npc:PlaySound(mod.Sounds.FireFizzle, 0.4, 0, false, 1.3) end,
        BurpSpawn        = function(npc) sfx:Play(mod.Sounds.BusterBurpSpawn, 0.3, 0, false, 1) end,
        BurpSkyRumble    = function(npc) npc:PlaySound(mod.Sounds.BusterBurpskyCharge, 0.8, 4, false, 1) end,
        BurpSkyShoot     = function(npc) npc:PlaySound(mod.Sounds.BusterBurpskyShoot, 1, 0, false, 1) end,
        Whistle          = function(npc) npc:PlaySound(mod.Sounds.BusterWhistle, 1, 0, false, 1) end,
        Snicker          = function(npc) npc:PlaySound(mod.Sounds.BusterSnicker, 1, 0, false, 1) end,
        Death            = function(npc) sfx:Play(mod.Sounds.BusterDeth, 1.2, 0, false, 1) end,
        DeathBeep        = function(npc) sfx:Play(mod.Sounds.BusterDethBeep, 1.2, 0, false, 1) end,
        DeathTaunt       = function(npc) sfx:Play(mod.Sounds.BusterVictory, 1.2, 0, false, 1) end,
    },

	Balance = {
		Attacks = {
			Spitoom = 1,
			HotShriek = 1.2,
			--Rubburn = 1,
			--BurpSpawn = 1,
            BurpSky = 1.3,
            CarpetComs = 1
		},

        Mass = 400,
        BaseFriction = 0.9,
        Speed = 3,
        TrackingFrameDelay = 4,
        MaxTrackingFrames = 6,
        PathfindingPeriod = 6,
        FireScale = 1.25,
        FireLife = 67,
        ComRoomOffset = 100,
        ChargeSpeed = 27,
		MaxOrbitCommissions = 4,
		SpitRoastCap = 3,
		CommissionWaitMin = 10,
		CommissionWaitMax = 25,
		IdleWaitMin = 30,
		IdleWaitMax = 55,
        SpitoomSpeed = 28,
        SpitoomFriction = 0.9,
        HotShriekSpeed = 25,
        HotShriekNoCollideTime = 5,
		WanderMaxTime = 60,
        ChargeMaxTime = 30,
        ChargeFriction = 0.7,
        ChargeEndThreshold = 100,
        ChargeEndSpeedScale = 0.7,
        ChargeOutsideThreshold = 160,
        ChargeInsideThreshold = 160,
        RubburnWeightDistThreshold = 120,
        NumCarpetComs = 3,
        CarpetComStaggerPeriod = 20,
        CarpetFireLife = 140,
		BurpSkyCooldown = 15,
        BurpSkyProjTimeToTarget = 30,
		BurpSkyProjFallAccel = 2.2,
        BurpSkyProjHeight = 15,
	},

    ResetCommissionTimer = function(data)
        data.CommissionWait = math.random(data.bal.CommissionWaitMin, data.bal.CommissionWaitMax)
	end,

    GoIdle = function(n, s, d)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            mod:spritePlay(sprite, "WalkIdle")
            FiendFolio.Buster.Sfx.Flying(npc)
            data.IdleWait = math.random(data.bal.IdleWaitMin, data.bal.IdleWaitMax)
        end)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            if d.CommissionWait <= 0 and data.WasOrbitOpen then
                -- spawn in commission on some cooldown outside room
                local room = game:GetRoom()
                local topLeft, bottomRight = room:GetTopLeftPos(), room:GetBottomRightPos()
                local pos = Vector(math.random(topLeft.X, bottomRight.X), math.random(topLeft.Y, bottomRight.Y))
                local dir = math.random(1, 4)
                if dir == 1 then
                    pos.X = topLeft.X - d.bal.ComRoomOffset
                elseif dir == 2 then
                    pos.X = bottomRight.X + d.bal.ComRoomOffset
                elseif dir == 3 then
                    pos.Y = topLeft.Y - d.bal.ComRoomOffset
                else
                    pos.Y = bottomRight.Y + d.bal.ComRoomOffset
                end

                local com = Isaac.Spawn(FiendFolio.Commission.Id.Type,
                                        FiendFolio.Commission.Id.Variant,
                                        FiendFolio.Commission.Id.SubType,
                                        pos, nilvector, npc)
                com:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                com.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                com.Parent = npc
                table.insert(d.orbiters, com)

                FiendFolio.Buster.ResetCommissionTimer(d)
	        end

			data.IdleWait = data.IdleWait - 1
			return data.IdleWait <= 0
		end)
		table.insert(d.ActionQueue, function(npc, sprite, data)
			if #data.RecentAttacks > 3 then
				table.remove(data.RecentAttacks)
			end

            local weights = {}
            local attacks = {}
			for attack, weight in pairs(data.bal.Attacks) do
                weights[attack] = weight
                table.insert(attacks, attack)
			end

			for i, attack in ipairs(data.RecentAttacks) do
				weights[attack] = weights[attack] * 0.8 / i
			end
			if #data.orbiters == 0 then
				-- can't do these attacks with no orbitals
				weights.Spitoom = 0.01
			end

			-- if on the opposite side of the room, weight rubburn higher
			--local target = npc:GetPlayerTarget()
			--local targetRightSide = target.Position.X - room:GetCenterPos().X > 0
			--if targetRightSide ~= rightSide
			--and target.Position:DistanceSquared(npc.Position) > data.bal.RubburnWeightDistThreshold then
			--	weights.Rubburn = weights.Rubburn * 2
            --end

            -- if not many commissions in the room, weight burp sky lower
            local comCount = mod.GetEntityCount(FiendFolio.FF.Commission.ID,
                                                FiendFolio.FF.Commission.Var)
            if comCount and comCount < 4 then
                weights.BurpSky = 0.2
            else
                weights.BurpSky = weights.BurpSky + (comCount - 4) / 3
            end

			-- select the attack
			local r = math.random(0, 10 * #attacks)
			local attackPicked
			repeat
				for attack, weight in pairs(weights) do
					weight = weight * 10
					if r < weight then
						attackPicked = attack
						break
					end
					r = r - weight
				end
			until r < 0 or attackPicked

            attackPicked = attackPicked or attacks[1]

			table.insert(data.ActionQueue, FiendFolio.Buster['Go' .. attackPicked])
			table.insert(data.RecentAttacks, 1, attackPicked)
		end)
	end,

	GoSpitoom = function(n, s, d)
		table.insert(d.ActionQueue, function(npc, sprite, data)
			-- cancel the attack if all orbitals are dead
			if #data.orbiters == 0 then
				data.ActionQueue = {}
				return
			end

			-- when an orbiting commission is getting close to the mouth, proceed
			local eatOffset = Vector(0, npc.Size + 10)
			--local eatPos = npc.Position + eatOffset
            for _, orbit in ipairs(data.orbiters) do
                if orbit.Position.X > npc.Position.X then
				    local diff = orbit.Position - npc.Position
                    local dt = orbit:GetData()
                    if eatOffset:Dot(diff) > 0 and dt.OrbitState == 'Orbiting' then
					    dt.Passive = true
					    dt.Invuln = true
                        orbit.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                        data.Food = orbit
                        return true
                    end
				end
            end
            return false
		end)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            data.Stopped = true
            sprite:Play("Eat", true)
		end)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            npc.Velocity = npc.Velocity * 0.8
            if data.Food then
                local eatOffset = Vector(0, npc.Size + 10)
                local eatPos = npc.Position + eatOffset

                local v = (eatPos - data.Food.Position)
                local sp = v:Length()
                if sp > 5 then v = v * 5 / sp end

                data.Food.Velocity = v
            end

			if sprite:IsEventTriggered("Eat") then
                data.Food:Die()
                data.Food = nil
                FiendFolio.Buster.Sfx.SpitoomBite(npc)
			elseif sprite:IsEventTriggered("EatStart") then
				FiendFolio.Buster.Sfx.SpitoomEat(npc)
			end
			return sprite:IsFinished("Eat")
		end)
		table.insert(d.ActionQueue, function(npc, sprite, data)
            sprite:Play("WalkChew", true)
            FiendFolio.Buster.Sfx.SpitoomChew(npc)
            data.DashPrefix = 'Chew'
		end)
        FiendFolio.Buster.GoWanderSide(n, s, d)
        FiendFolio.Buster.GoDash(n, s, d)
		table.insert(d.ActionQueue, function(npc, sprite, data)
            sprite:Play("Spitoom", true)
		end)
		table.insert(d.ActionQueue, function(npc, sprite, data)
			if sprite:IsEventTriggered("Shoot") then
				sfx:Stop(mod.Sounds.BusterWalkChewLoop)
				-- spit an exploding, non-berserk commission toward the player at high speed
				local dir = (d.TargetPositions[#d.TargetPositions] - npc.Position):Normalized()
				local com = Isaac.Spawn(FiendFolio.Commission.Id.Type,
                                        FiendFolio.Commission.Id.Variant,
                                        FiendFolio.Commission.Id.SubType,
                                        npc.Position + dir * (10 + npc.Size), dir * d.bal.SpitoomSpeed, npc):ToNPC()
                com:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				local cdata = com:GetData()
				cdata.Passive = true
                cdata.Exploding = true
                cdata.ExplodeOnSolidContact = true
                cdata.Spin = 45
                --cdata.Rotation = dir:GetAngleDegrees()
                com.Mass = 10000
				com.Friction = data.bal.SpitoomFriction
                FiendFolio.Buster.Sfx.SpitoomSpit(npc)
			elseif sprite:IsEventTriggered("SpitoomUp") then
				sfx:Stop(mod.Sounds.BusterWalkChewLoop)
				FiendFolio.Buster.Sfx.SpitoomCharge(npc)
			end

            if not sprite:IsFinished("Spitoom") then return false end

            data.Stopped = false
            return true
        end)
    end,

    GoShriek = function(n, s, d)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            local hasOrbitsComing = false
            local hasOrbits = false
            for _, orb in ipairs(data.orbiters) do
                local isOrbiting = orb:GetData().OrbitState == 'Orbiting'
				hasOrbits = hasOrbits or isOrbiting
                hasOrbitsComing = hasOrbitsComing or not isOrbiting
            end

            if hasOrbitsComing then return false end -- wait until all coms are orbiting

            if not hasOrbits then return end -- if no orbits, don't shriek

			sprite:Play("HotShriek", true)
            data.Stopped = true

            table.insert(d.ActionQueue, 1, function(npc, sprite, data)
                if sprite:IsEventTriggered("Scream") then
                    FiendFolio.Buster.Sfx.HotShriekScream(npc)
                    -- send out commissions radially at semi-high speed and berserk them
                    for _, orbiter in ipairs(data.orbiters) do
                        local odata = orbiter:GetData()
                        if odata.OrbitState == 'Orbiting' then
                            orbiter.Velocity = (orbiter.Position - npc.Position):Resized(data.bal.HotShriekSpeed)
                            --odata.Berserk = true
                            --odata.Exploding = true
                            odata.NoCollideFrames = data.bal.HotShriekNoCollideTime
                            orbiter.Parent = nil
                        end
                    end
				elseif sprite:IsEventTriggered("ShriekStart") then
				    FiendFolio.Buster.Sfx.HotShriekStart(npc)
                end

                npc.Velocity = npc.Velocity * 0.8
                if not sprite:IsFinished("HotShriek") then return false end
                data.Stopped = false
                mod:spritePlay(sprite, "Idle")
            end)
        end)
    end,

	GoHotShriek = function(n, s, d)
        FiendFolio.Buster.GoShriek(n, s, d)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            data.DashThroughWalls = true
            --data.ChargeAtTarget = true
            data.DashWindupSfx = 'ChewDashWindup'
        end)
        FiendFolio.Buster.GoDash(n, s, d)
	end,

    GoWanderSide = function(n, s, d)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            data.WasStopped = data.Stopped
            data.Stopped = true
            data.WanderTimer = (data.WanderTimer and data.WanderTimer > 0)
                                and data.WanderTimer or data.bal.WanderMaxTime
		end)
		table.insert(d.ActionQueue, function (npc, sprite, data)
            data.WanderTimer = data.WanderTimer - 1
			if data.WanderTimer < 0 then return true end

			local room = game:GetRoom()
			local direction = (npc.Position.X - room:GetCenterPos().X > 0) and 1 or -1
			direction = Vector(direction, 0)

            local wanderMove = direction * (data.bal.Speed * 0.8)
			npc.Velocity = (npc.Velocity + wanderMove):Resized(data.bal.Speed)

			-- if within 2 grids of the appropriate side of the room, continue
			return not room:IsPositionInRoom(npc.Position + direction * 80, 0)
        end)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            data.Stopped = data.WasStopped
            data.WasStopped = nil
            data.WanderTimer = nil
        end)
    end,

    GoWanderCorner = function(n, s, d)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            data.WasStopped = data.Stopped
            data.Stopped = true
            data.WanderTimer = (data.WanderTimer and data.WanderTimer > 0)
                                and data.WanderTimer or data.bal.WanderMaxTime
		end)
		table.insert(d.ActionQueue, function (npc, sprite, data)
			data.WanderTimer = data.WanderTimer - 1
			if data.WanderTimer <= 0 then return true end

            local room = game:GetRoom()
            local center = room:GetCenterPos()
			local goRight    = (npc.Position.X - center.X > 0) and 1 or -1
            local goDown     = (npc.Position.Y - center.Y > 0) and 1 or -1
			local wanderMove = Vector(1.2 * goRight, 0.4 * goDown) * data.bal.Speed

			npc.Velocity = (npc.Velocity + wanderMove):Resized(data.bal.Speed)

            -- if within 2 grids of the appropriate side of the room, continue
            return not (room:IsPositionInRoom(npc.Position + Vector(80 * goRight, 0), 0)
                     or room:IsPositionInRoom(npc.Position + Vector(0, 100 * goDown), 0))
        end)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            data.Stopped = data.WasStopped
            data.WasStopped = nil
            data.WanderTimer = nil
        end)
    end,

    GoDash = function(n, s, d)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            data.WasStopped = data.Stopped
			data.Stopped = true
            local target = data.ChargeAtTarget and npc:GetPlayerTarget().Position or game:GetRoom():GetCenterPos()
            data.ChargeLeft = npc.Position.X - target.X > 0
            data.DashPrefix = data.DashPrefix or ''
            local anim = data.ChargeLeft and "ChargeLeftStart" or "ChargeRightStart"
			sprite:Play(data.DashPrefix .. anim, true)
		end)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            local anim = data.ChargeLeft and "ChargeLeftStart" or "ChargeRightStart"
            sprite:Play(data.DashPrefix .. anim, true)
            FiendFolio.Buster.Sfx[data.DashWindupSfx or 'DashWindup'](npc)
		end)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            npc.Velocity = npc.Velocity * 0.97
			if sprite:IsEventTriggered("Dash") then
				FiendFolio.Buster.Sfx.ChargeRoar(npc)
				FiendFolio.Buster.Sfx.DashCharge(npc)
				sfx:Stop(mod.Sounds.BusterWalkChewLoop)
                data.ChargeVel = Vector(data.bal.ChargeSpeed * (data.ChargeLeft and -1 or 1), 0)
                data.DashStartPos = npc.Position
                data.DashedThrough = false
                if data.DashThroughWalls then
                    npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS_Y
                end
				-- spew fires in a track behind during this period, controlled in main update
				data.DropFire = true
            end
            if data.ChargeVel then
                npc.Velocity = data.ChargeVel
            end
            local anim = data.ChargeLeft and "ChargeLeftStart" or "ChargeRightStart"
			return sprite:IsFinished(data.DashPrefix .. anim)
		end)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            local anim = data.ChargeLeft and "ChargeLeft" or "ChargeRight"
            sprite:Play(data.DashPrefix .. anim, true)
			data.ChargeTimer = data.bal.ChargeMaxTime
		end)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            npc.Velocity = data.ChargeVel
            if not data.DashThroughWalls then
			    data.ChargeTimer = data.ChargeTimer - 1
			    if data.ChargeTimer <= 0 then return true end
			    -- if within a certain distance of being outside the room stop dashing
			    local room = game:GetRoom()
                local outRoomPos = npc.Position + Vector((data.ChargeLeft and -1 or 1) * d.bal.ChargeInsideThreshold, 0)
                return not room:IsPositionInRoom(outRoomPos, 0)
            elseif not data.DashedThrough then
                -- if out of the room by some distance, loop to other side
                local room = game:GetRoom()
			    local inRoomPos = npc.Position - Vector((data.ChargeLeft and -1 or 1) * d.bal.ChargeOutsideThreshold, 0)
                if not room:IsPositionInRoom(inRoomPos, 0) then
                    local x
                    if npc.Position.X < 0 then
                        x = room:GetCenterPos().X * 2 + d.bal.ChargeOutsideThreshold
                    else
                        x = -d.bal.ChargeOutsideThreshold
                    end
                    --npc.Position = Vector(x, npc.Position.Y)
                    local targetPos = npc:GetPlayerTarget().Position
                    npc.Position = Vector(x, targetPos.Y)
                    data.DashedThrough = true
                end
                return false
            else
                -- rush until past start pos
			    local room = game:GetRoom()
                npc.Velocity = npc.Velocity * d.bal.ChargeEndSpeedScale
                local passedComingFromLeft = math.abs(data.DashStartPos.X - npc.Position.X) < d.bal.ChargeEndThreshold
                return passedComingFromLeft and room:IsPositionInRoom(npc.Position, 0)
            end
        end)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            local anim = data.ChargeLeft and "ChargeLeftEnd" or "ChargeRightEnd"
			sprite:Play(data.DashPrefix .. anim, true)
			FiendFolio.Buster.Sfx.DashEnd(npc)
			data.WasChargeLeft = data.ChargeLeft
			data.ChargeLeft = nil
            if data.DashThroughWalls then
                npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            end
            npc.Velocity = npc.Velocity * data.bal.ChargeFriction
		end)
		table.insert(d.ActionQueue, function(npc, sprite, data)
            -- quickly slow down during charge end
            local anim = data.WasChargeLeft and "ChargeLeftEnd" or "ChargeRightEnd"
            if not sprite:IsFinished(data.DashPrefix .. anim) then
                if sprite:IsEventTriggered('StopFire') then
                    data.DropFire = false
					sfx:Stop(mod.Sounds.BusterChargeLoop)
					if data.DashPrefix == 'Chew' then
						FiendFolio.Buster.Sfx.SpitoomChew(npc)
					end
                end

			    local vel = npc.Velocity
			    if vel:LengthSquared() > 0.4 then
				    npc.Velocity = vel * data.bal.ChargeFriction
			    end
                return false
            end

            npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            data.Stopped = data.WasStopped
            data.WasStopped = nil
            data.DashPrefix = nil
            data.DashWindupSfx = nil
            data.DashThroughWalls = nil
            data.ChargeVel = nil
            data.ChargeAtTarget = nil
			return true
		end)
    end,

    GoRubburn = function(n, s, d)
        FiendFolio.Buster.GoShriek(n, s, d)
        FiendFolio.Buster.GoWanderSide(n, s, d)
        FiendFolio.Buster.GoDash(n, s, d)
	end,

	GoBurpSpawn = function(n, s, d)
		table.insert(d.ActionQueue, function(npc, sprite, data)
			sprite:Play("BurpSpawn", true)
		end)
		table.insert(d.ActionQueue, function(npc, sprite, data)
			if sprite:IsEventTriggered("Shoot") then
				-- spawn two spitroasts
				local offset = Vector(15, 40)
				local vel = offset:Resized(10)
                local spitroast = Isaac.Spawn(mod.FF.Spitroast.ID, mod.FF.Spitroast.Var, 0, npc.Position + offset, vel, npc)
                spitroast:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				offset.X = offset.X * -1
                spitroast = Isaac.Spawn(mod.FF.Spitroast.ID, mod.FF.Spitroast.Var, 0, npc.Position + offset, vel, npc)
                spitroast:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

                FiendFolio.Buster.Sfx.BurpSpawn(npc)
			end

			return sprite:IsFinished("BurpSpawn")
		end)
    end,

    GoBurpSkyProj = function(n, s, d)
        local targetCom = nil
        repeat
            local com = d.SkyBurpTargets[#d.SkyBurpTargets]
            if com and not com:IsDead() then
                targetCom = com
            end
            table.remove(d.SkyBurpTargets)
        until targetCom or #d.SkyBurpTargets == 0

        if not targetCom then return end

        local targetPos = targetCom.Position

        d.DidShoot = true
        s:Play("BurpSkyShoot", true)
        FiendFolio.Buster.Sfx.BurpSkyRumble(n)

        EnqueueList(d.ActionQueue, {
            function(npc, sprite, data)
		        if sprite:IsEventTriggered("Shoot") then
			        -- on trigger, shoot a flaming projectile into the air towards com targets
                    --local targetPos = npc:GetPlayerTarget().Position
                    local bet = targetPos - npc.Position

                    local fallSpeed = -0.75 * data.bal.BurpSkyProjTimeToTarget * data.bal.BurpSkyProjFallAccel

				    local proj = Isaac.Spawn(9, 0, 0, npc.Position, bet * (1.02 / data.bal.BurpSkyProjTimeToTarget), npc):ToProjectile()
                    proj.SpawnerEntity = npc
                    proj.Scale = 2
				    proj.Height = data.bal.BurpSkyProjHeight
                    proj.FallingSpeed = fallSpeed
                    proj.FallingAccel = data.bal.BurpSkyProjFallAccel
					proj.Color = mod.ColorCrackleOrange
                    proj:GetData().BusterFireball = true
				    -- when the projectile lands, do the spit roast death effect

                    FiendFolio.Buster.Sfx.BurpSkyShoot(npc)
			    end

		        return sprite:IsFinished("BurpSkyShoot")
		    end,
            function(npc, sprite, data)
                npc.Velocity = npc.Velocity * 0.6
			    sprite:Play("WalkBurpSky", true)
			    data.BurpSkyTimer = data.bal.BurpSkyCooldown
		    end,
            function(npc, sprite, data)
		        data.BurpSkyTimer = data.BurpSkyTimer - 1
			    return data.BurpSkyTimer <= 0
            end,
            FiendFolio.Buster.GoBurpSkyProj
        })
    end,

    GoBurpSky = function(n, s, d)
        FiendFolio.Buster.GoShriek(n, s, d)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            data.Stopped = true
            sprite:Play("Snicker", true)
        end)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            npc.Velocity = npc.Velocity * 0.9
            if sprite:IsEventTriggered("Snicker") then
                FiendFolio.Buster.Sfx.Snicker(npc)
                data.SkyBurpTargets = {}
                -- scare all free coms
                local coms = Isaac.FindByType(FiendFolio.Commission.Id.Type,
                                              FiendFolio.Commission.Id.Variant,
                                              FiendFolio.Commission.Id.SubType, false, false)
                for _, com in pairs(coms) do
                    local comData = com:GetData()
                    if not comData.Parent then
                        table.insert(data.SkyBurpTargets, com)
                        comData.Terrified = true
                    end
                end
            end

            return sprite:IsFinished("Snicker")
		end)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            sprite:Play("WalkIdle", true)
        end)
        table.insert(d.ActionQueue, FiendFolio.Buster.GoBurpSkyProj)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            if data.DidShoot then
			    sprite:Play("BurpSkyEnd", true)
                table.insert(d.ActionQueue, 1, function(npc, sprite, data)
			        return sprite:IsFinished("BurpSkyEnd")
                end)
            end
            data.DidShoot = nil
            data.Stopped = false
        end)
    end,

    GoCarpetComs = function(n, s, d)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            data.Stopped = true
            data.FireLifeOverride = data.bal.CarpetFireLife
            data.DashWindupSfx = 'CarpetDashWindup'
        end)
        FiendFolio.Buster.GoWanderCorner(n, s, d)
        FiendFolio.Buster.GoDash(n, s, d)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            sprite:Play("Whistle", true)
        end)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            if sprite:IsEventTriggered("Whistle") then
                FiendFolio.Buster.Sfx.Whistle(npc)
            end

            if not sprite:IsFinished("Whistle") then return false end

            sprite:Play("WalkIdle", true)
            FiendFolio.Buster.Sfx.Flying(npc)
            data.Stopped = false
            data.FireLifeOverride = nil

            data.CarpetData = {
                Timer = 0,
                Count = 0
            }

            local room = game:GetRoom()
            local center = room:GetCenterPos()
            local nearRight    = npc.Position.X - center.X > 0
            local nearBottom   = npc.Position.Y - center.Y > 0

            -- send in staggered coms from the top or bottom
            local topLeft, bottomRight = room:GetTopLeftPos(), room:GetBottomRightPos()
            data.CarpetData.StartPos = Vector(nearRight and bottomRight.X or topLeft.X,
                                nearBottom and (bottomRight.Y + data.bal.ComRoomOffset)
                                            or (topLeft.Y     - data.bal.ComRoomOffset))

            local count = data.bal.NumCarpetComs
            local width = bottomRight.X - topLeft.X
            data.CarpetData.Offset = width / count

            data.CarpetData.Direction = Vector(nearRight and -1 or 1, 0)
        end)
        table.insert(d.ActionQueue, function(npc, sprite, data)
            local cdata = data.CarpetData

            cdata.Timer = cdata.Timer - 1
            if cdata.Timer > 0 then return false end

            cdata.Count = cdata.Count + 1
            cdata.Timer = data.bal.CarpetComStaggerPeriod

            local count = data.bal.NumCarpetComs
            if cdata.Count > count then return end

            local pos = cdata.StartPos + cdata.Direction * ((cdata.Count - 0.5) * cdata.Offset)

            local com = Isaac.Spawn(FiendFolio.Commission.Id.Type,
                                    FiendFolio.Commission.Id.Variant,
                                    FiendFolio.Commission.Id.SubType,
                                    pos, nilvector, npc)
            com:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            com.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE

            local comData = com:GetData()
            comData.Passive = true
            comData.PassiveTimer = 40

            return false
        end)
    end
}

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.Variant ~= FiendFolio.Buster.Id.Variant then return end

    local sprite = npc:GetSprite()
	local d = npc:GetData()

    if not d.init then
		npc.SpriteOffset = Vector(0,-5)

		d.Stopped = false
		d.bal = FiendFolio.Buster.Balance
		d.orbiters = {}
		d.ActionQueue = {}
		d.RecentAttacks = {}
		d.CurrentAction = nil

        d.TargetPositions = {}
		d.CommissionWait = 0

        npc.Mass = d.bal.Mass
        npc.Friction = d.bal.BaseFriction
        -- this ensures buster isn't pushed around by other entities
        -- thanks for not properly supporting high mass moving objects isaac!
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        -- no knockback from bombs
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)

		d.init = true
    end

	if mod.allPlayersDead() then
		FiendFolio.Buster.Sfx.DeathTaunt(npc)
	end

    local target = npc:GetPlayerTarget()

    table.insert(d.TargetPositions, 1, target.Position)
    if #d.TargetPositions >= d.bal.MaxTrackingFrames + 1 then
        table.remove(d.TargetPositions, d.bal.MaxTrackingFrames + 1)
    end

    local pos = npc.Position

	local toTarget = d.TargetPositions[math.min(#d.TargetPositions, d.bal.TrackingFrameDelay)] - pos

    if not d.Stopped and npc.FrameCount % d.bal.PathfindingPeriod == 0 then
        local vel = Vector(toTarget.X * math.abs(toTarget.X) * 0.7, toTarget.Y * math.abs(toTarget.Y) * 1.4) * (d.bal.Speed / 5000)
        local speed = vel:Length()
        if speed > d.bal.Speed then
            vel = vel * (d.bal.Speed / speed)
        end

        npc.Velocity = vel
    end

	for i = #d.orbiters, 1, -1 do
        local baby = d.orbiters[i]
		if not (baby:Exists() and baby.Parent and baby.Parent.InitSeed == npc.InitSeed) then
			table.remove(d.orbiters, i)
		end
    end

    local isOrbitOpen = #d.orbiters < d.bal.MaxOrbitCommissions
    if isOrbitOpen and not d.WasOrbitOpen then
        FiendFolio.Buster.ResetCommissionTimer(d)
    end
    d.WasOrbitOpen = isOrbitOpen

    d.CommissionWait = d.CommissionWait - 1

    -- spawning fires during charge
    if d.DropFire and npc.FrameCount % 1 == 0 then
        local room = game:GetRoom()
        local pos = npc.Position - npc.Velocity * 0.2
        if room:IsPositionInRoom(pos, 0)
        and room:GetGridCollisionAtPos(pos) ~= GridCollisionClass.COLLISION_WALL then
            local f = Isaac.Spawn(1000,7005, 0, pos + Vector(0, math.random(-5, 5)), nilvector, npc)
			f:SetColor(Color(1,1,1,1,-100 / 255,70 / 255,455 / 255),10,1,true,false)
            local fData = f:GetData()
			fData.flamethrower = true
            fData.scale = d.bal.FireScale
            fData.timer = d.FireLifeOverride or d.bal.FireLife
        end
	end

	if #d.ActionQueue == 0 then
		table.insert(d.ActionQueue, FiendFolio.Buster.GoIdle)
	end

	if d.CurrentAction == nil then
		d.CurrentAction = table.remove(d.ActionQueue, 1)
	end

	if d.CurrentAction(npc, sprite, d) ~= false then
		d.CurrentAction = nil
    end
end, FiendFolio.Buster.Id.Type)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, e, amt, flags, src)
	if not (e.Type == FiendFolio.Buster.Id.Type
		and e.Variant == FiendFolio.Buster.Id.Variant) then
		return
	end

	-- ignore fire damage
	if src.Type == 1000 and src.Variant == 7005 then
		return false
    end

    if flags & DamageFlag.DAMAGE_EXPLOSION ~= 0 then
        e:TakeDamage(amt * 0.5, flags & ~DamageFlag.DAMAGE_EXPLOSION, src, 0)
        return false
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, e)
	if not (e.Type == FiendFolio.Buster.Id.Type
		and e.Variant == FiendFolio.Buster.Id.Variant) then
		return
	end

	if e:IsDead() and not game:IsPaused() then
        game:BombExplosionEffects(e.Position, 80, 0, Color(1, 1, 1, 1, 75 / 255, 25 / 255, 0), e, 1.75, false, true)
        game:ShakeScreen(20)
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, e)
	if not (e.Type == FiendFolio.Buster.Id.Type
		and e.Variant == FiendFolio.Buster.Id.Variant) then
		return
	end
	local sprite = e:GetSprite()
	if sprite:IsPlaying("Death") then
		if sprite:IsEventTriggered("Dying") then
			FiendFolio.Buster.Sfx.Death(e)
		elseif sprite:IsEventTriggered("Blink") then
			FiendFolio.Buster.Sfx.DeathBeep(e)
		end
	end
end, FiendFolio.Buster.Id.Type)

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, e)
	if e:IsDead() and e:GetData().BusterFireball then
		local npc = e.SpawnerEntity:ToNPC()
		npc:PlaySound(mod.Sounds.FireFizzle, 0.4, 0, false, 1.3)
		local numberofflames = 10
		for i = 1, numberofflames do
			local fire = Isaac.Spawn(1000,7005, 1, e.Position, Vector(8,0):Rotated((360/numberofflames) * i), npc)
			fire:Update()
		end
	end
end)

FiendFolio.Commission = {
    Id = {
        Type = mod.FF.Commission.ID,
        Variant = mod.FF.Commission.Var,
        SubType = 0
    },

    Explode = function(npc)
        Isaac.Explode(npc.Position, npc, 40)
        local f = Isaac.Spawn(1000, 7005, 0, npc.Position, nilvector, npc)
        local fData = f:GetData()
        fData.timer = 45
    end,

    Mass = 40,
    ExplodeWait = 45,
    Speed = 10,
    WalkFriction = 0.9,
    WalkPeriod = 25,
    FlyInSpeed = 10,
    FlyInFrames = 15,
    FlyInNoCollideTime = 27,
    OrbitPositioningSpeed = 5.5,
    BerserkSpeed = 18,
    BerserkPeriod = 10,
    BerserkFriction = 0.8,
    BerserkGunpowderPeriod = 15,
    GunpowderPeriod = 8,
    GunpowderBurnTime = 45,
    GunpowerTimeout = 35,
    TerrorTimer = 30 * 10,
    OrbitSpeed = 5,
    OrbitDistance = 30,
    OrbitPeriod = 30
}

local function GetOrbitTargetPos(idx, numOrbiters, parent, period, dist)
    local angle = (idx * (math.pi * 2) / numOrbiters) + (parent.FrameCount / period)
    local targetOffset = Vector(math.cos(angle), math.sin(angle)) * (parent.Size + dist)
    -- parent position in 2 frames (update + render) at the target offset
    return (parent.Position + parent.Velocity * 2) + targetOffset
end

-- A dot B > 0 tells you B is in the general same direction as A
-- let A' = A rot 90 clockwise = -Ay, Ax (assuming y points down)
-- A' dot B > 0 tells you B is in the general same direction as A'
-- in other words, it's in the general *clockwise* direction from A
-- A' dot B = A'x * Bx + A'y * By = -Ay * Bx + Ax * By
-- -Ay * Bx + Ax * By > 0 ->
-- Ax * By > Ay * Bx means B is further clockwise than A
local function IsLessClockwise(a, b)
    -- returns whether a is less clockwise than b
    return a.X * b.Y > a.Y * b.X
end

function mod:commissionAI(npc, sprite, d)
    if not d.init then
		d.OrbitState = nil
		d.bal = FiendFolio.Commission

        npc.Mass = d.bal.Mass
        npc.SplatColor = Color(0,0,0,1,80 / 255,80 / 255,80 / 255)
        npc.SpriteOffset = Vector(0,-10)
        sprite:ReplaceSpritesheet(0, "gfx/bosses/buster/monster_commission" .. math.random(1,3) .. '.png')
		sprite:LoadGraphics()

		local room = game:GetRoom()
		if not room:IsPositionInRoom(npc.Position, 0) then
            d.State = "fly-in"

			local topLeft, bottomRight  = room:GetTopLeftPos(), room:GetBottomRightPos()
			d.FlyInDirection = Vector(0,0)
			if npc.Position.X < topLeft.X then
				d.FlyInDirection.X = 1
			elseif npc.Position.X > bottomRight.X then
				d.FlyInDirection.X = -1
			elseif npc.Position.Y > bottomRight.Y then
				d.FlyInDirection.Y = -1
			else
				d.FlyInDirection.Y = 1
			end
        end

        d.NoCollideFrames = 0

		d.init = true
    end

    if d.State == "fly-in" then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    elseif d.OrbitState == "MovingIntoOrbit" then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
    elseif d.OrbitState then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
    else
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
    end

    if d.NoCollideFrames > 0 then
        d.NoCollideFrames = d.NoCollideFrames - 1
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    end

    if d.Exploding then
        local anim = d.Spin and "PulseCenter" or "Pulse"

        mod:spritePlay(sprite, anim)

        if d.ExplodeOnSolidContact then
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
        end

		d.ExplodeTimer = d.ExplodeTimer or d.bal.ExplodeWait
		d.ExplodeTimer = d.ExplodeTimer - 1

        local explode = d.ExplodeTimer <= 0 or npc:HasMortalDamage()
                        or (d.ExplodeOnSolidContact and npc:CollidesWithGrid())
        if not explode then
            explode = #Isaac.FindInRadius(npc.Position, npc.Size + 5, EntityPartition.PLAYER) > 0
        end

        if explode then
			npc:Die()
            FiendFolio.Commission.Explode(npc)
			return
		end
	end

    if d.Spin then
        sprite.Rotation = sprite.Rotation + d.Spin
    elseif d.Rotation then
        sprite.Rotation = d.Rotation - 90
    end

    if npc.Parent then
        local psprite = npc.Parent:GetSprite()
        if psprite:IsPlaying("Death") and psprite:IsEventTriggered("ExplodeBegin") then
            d.Terrified = true
        end
    end

    -- please die please please please
    if d.Terrified then
        d.Invuln = false
    end

    if d.Terrified and not d.Berserk then
        if not sprite:IsPlaying("Terror") then
            if sprite:IsFinished("TerrorStart") then
                d.KeepMoving = nil
                sprite:Play("Terror", true)
                d.TerrorTimer = d.bal.TerrorTimer
            else
                npc.Velocity = nilvector
                mod:spritePlay(sprite, "TerrorStart")
            end
        else
            d.TerrorTimer = d.TerrorTimer - 1
            if d.TerrorTimer <= 0 then
                d.Terrified = false
                d.TerrorTimer = nil
            end
        end
        return
    end

    if d.State == "fly-in" then
        if d.FlewIn then
            mod:spritePlay(sprite, "Idle")
        elseif sprite:IsFinished("FlyIn") then
            d.FlewIn = true
        else
            mod:spritePlay(sprite, "FlyIn")
        end

		-- play fly in animation if not playing
		-- move into room in prescribed direction
		local currSpeed = mod:Lerp(d.bal.FlyInSpeed, d.bal.Speed, npc.FrameCount / d.bal.FlyInFrames)
		npc.Velocity = d.FlyInDirection * math.max(d.bal.Speed, currSpeed)

		if game:GetRoom():IsPositionInRoom(npc.Position - d.FlyInDirection * 20, 0) then
            d.State = nil
            mod:spritePlay(sprite, "Idle")
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        end
    end

    local gunpowderPeriod = d.Berserk and d.bal.BerserkGunpowderPeriod or d.bal.GunpowderPeriod
    if npc.FrameCount % gunpowderPeriod == 0 and d.OrbitState ~= "Orbiting" then
        local pos = npc.Position
        if game:GetRoom():IsPositionInRoom(pos, 0) then
            mod.SpawnGunpowder(npc, pos, d.bal.GunpowerTimeout, d.bal.GunpowderBurnTime)
        end
    end

    if d.Passive then
        if d.PassiveTimer then
            d.PassiveTimer = d.PassiveTimer - 1
            if d.PassiveTimer < 0 then
                d.Passive = false
                d.PassiveTimer = nil
            end
        end
		return
    end

    if not (npc.Parent and npc.Parent:Exists()) then
		d.State = 'idle'
		d.OrbitState = nil
	elseif not d.OrbitState then
    -- when unorbiting, make sure to unparent
        d.NoCollideFrames = d.bal.FlyInNoCollideTime
		d.OrbitState = "MovingIntoOrbit"
	end

    if d.Berserk then
        --[[
		d.BerserkTime = d.BerserkTime or 0
        local t = d.BerserkTime / d.bal.BerserkPeriod

        local targetPos = nil
        if t > 0.75 then
            targetPos = npc.Position + npc.Velocity * 40
            d.ExplodeOnContact = true
        else
            targetPos = npc:GetPlayerTarget().Position
        end

        local toTarget = targetPos - npc.Position

        npc.Velocity = npc.Velocity * 0.8 + toTarget:Resized(0.3 * d.bal.BerserkSpeed * t * (t - 0.2))

        -- at about 1/3 points through period trigger weird movement offsets
        local move = npc.FrameCount * t * 10 / 3
        local movePhase = math.floor(move)
        local phasePercent = move - movePhase
        if movePhase > 0 and phasePercent < 0.3 then
            local sign = (movePhase % 2 == 0) and 1 or -1
            npc.Velocity = npc.Velocity +
                (toTarget:Rotated(sign * 60)):Resized(2 * d.bal.BerserkSpeed * (1 - t) ^ 2)
        end

        local sp = npc.Velocity:Length()
        local clampSp = d.bal.BerserkSpeed * 1.5
        if sp > clampSp then
            npc.Velocity = npc.Velocity * (clampSp / sp)
        end

        d.BerserkTime = d.BerserkTime + 1
        ]]
        npc.Friction = d.bal.BerserkFriction

        local players = Isaac.FindInRadius(npc.Position, d.bal.BerserkSpeed * 2, EntityPartition.PLAYER, true)
        for _, player in pairs(players) do
            local bet = npc.Position - player.Position
            local betSp = bet:Length()
            local mul = (d.bal.BerserkSpeed * 4 - betSp) / betSp
            npc.Velocity = npc.Velocity + bet * mul
        end

        if npc.FrameCount % d.bal.BerserkPeriod == 0 then
			local movspeed = d.bal.BerserkSpeed
			if mod:isConfuse(npc) or mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE) then
				movspeed = movspeed * 0.6
			end
            local vel = mod:runIfFear(npc, (npc.Velocity * 0.8 + RandomVector() * 3):Resized(movspeed))
            npc.Velocity = vel
        end
    elseif d.State == 'idle' then
        if not d.Terrified then
            mod:spritePlay(sprite, d.Scared and "ScaredIdle" or "Idle")
        end
        npc.Friction = d.bal.WalkFriction
        if npc.FrameCount % d.bal.WalkPeriod == 0 then
			local movspeed = d.bal.Speed
			if mod:isConfuse(npc) or mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE) then
				movspeed = movspeed * 0.6
			end

            npc.Velocity = mod:runIfFear(npc, (npc.Velocity * 0.8 + RandomVector() * 3)):Resized(movspeed)
        end
        --npc.Velocity = npc.Velocity:Resized(d.bal.Speed)
		--npc.Pathfinder:MoveRandomly(false)
    elseif d.State ~= "fly-in" and d.OrbitState then
		local parent = npc.Parent
		local pdata = parent:GetData()

		local idx
		local activeOrbitIdx = 0
		local numOrbiters = 0
        for i, orbit in ipairs(pdata.orbiters) do
            local odata = orbit:GetData()
			if odata.OrbitState == "Orbiting" then
				numOrbiters = numOrbiters + 1
			end
			if orbit.InitSeed == npc.InitSeed then
				idx = i
				activeOrbitIdx = numOrbiters
			end
		end

		if d.OrbitState == "MovingIntoOrbit" then
            local bet = parent.Position - npc.Position
			if bet:LengthSquared() < (parent.Size + d.bal.OrbitDistance) ^ 2 then
				npc.Velocity = nilvector
                d.OrbitState = "Orbiting"

                local closest = 100000
                local newIdx = numOrbiters + 1
                for i = 1, numOrbiters + 1 do
                    local pos = GetOrbitTargetPos(i, numOrbiters, parent, d.bal.OrbitPeriod, d.bal.OrbitDistance)
                    local dist = (pos - npc.Position):LengthSquared()
                    if dist < closest then
                        -- is the potential position clockwise of my position
                        -- this way it won't look weird
                        local betMe, betPos = npc.Position - parent.Position, pos - parent.Position
                        if IsLessClockwise(betMe, betPos) then
                            newIdx, closest = i, dist
                        end
                    end
                end

                table.remove(pdata.orbiters, idx)
                table.insert(pdata.orbiters, newIdx, npc)
			else
				npc.Velocity = (npc.Velocity + bet:Resized(d.bal.Speed)):Resized(d.bal.OrbitPositioningSpeed)
			end
        elseif d.OrbitState == "Orbiting" then
            local projectedPosition = GetOrbitTargetPos(activeOrbitIdx, numOrbiters, parent, d.bal.OrbitPeriod, d.bal.OrbitDistance)
            npc.Velocity = npc.Velocity * 0.6 + (projectedPosition - npc.Position) * 0.2

            local sp = npc.Velocity:Length()
            if sp > d.bal.OrbitSpeed then
                npc.Velocity = npc.Velocity * (d.bal.OrbitSpeed / sp)
            end
		end
	end

	d.PrevPosition = npc.Position
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, e, amt, flags, src)
	if e.Variant ~= FiendFolio.Commission.Id.Variant then
		return
	end

    local d = e:GetData()
	if d.Invuln then return false end

	-- ignore fire damage
	if flags & DamageFlag.DAMAGE_FIRE ~= 0 then
		if d.OrbitState ~= "Orbiting" then
            d.Exploding = true
            d.Berserk = true
            d.Parent = nil
		end
		return not (src.Type == 1000 and src.Variant == 7005)
    end
end, FiendFolio.Commission.Id.Type)

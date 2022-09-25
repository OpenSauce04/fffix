local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:GlobAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    local room = game:GetRoom()
    if not data.Init then
        if npc.SubType == 1 then
            npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            sprite:Play("Idle02")
            npc.StateFrame = mod:RandomInt(20,30)
            data.state = "extinguished"
            data.stoned = true
        elseif npc.SubType == 2 then
            if data.waited then
                data.state = "fall"
                data.airborne = true
                data.noDMG = true
                npc.Visible = true
                local effect = Isaac.Spawn(1000,1743,0,npc.Position,Vector.Zero,npc)
                effect:GetSprite():Load("gfx/enemies/glob/effect_glob_target.anm2", true)
                mod:spritePlay(effect:GetSprite(), "Appear")
                effect.Parent = npc
                npc.Child = effect
                effect:Update()
            else
                mod.makeWaitFerr(npc, npc.Type, npc.Variant, npc.SubType, 120, false)
            end
        else
            data.state = data.state or "idle"
            data.squidgecount = 5
        end
        npc.SplatColor = mod.ColorFireJuicy
        data.Init = true
    end
    if data.state == "appear" then --Used for when other enemies spawn them
        npc.Velocity = Vector.Zero
		if sprite:IsFinished("Appear") then
			data.state = "idle"
			data.squidgecount = 5
		else
			mod:spritePlay(sprite, "Appear")
		end
    elseif data.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		npc.Velocity = npc.Velocity * 0.95
        npc.StateFrame = npc.StateFrame - 1
		if npc.StateFrame <= 0 and npc.FrameCount > 5 then
			if mod:RandomInt(0,data.squidgecount) == 0 and not (mod:isScare(npc) or mod:isConfuse(npc)) then
				npc.Velocity = Vector.Zero
				data.state = "submerge"
				npc:PlaySound(mod.Sounds.DripSuck,0.4,0,false,1)
			else
				local movepos = mod:runIfFear(npc, mod:FindRandomValidPathPosition(npc, 10), nil, true)
				if movepos then
					if game:GetRoom():CheckLine(npc.Position,movepos,0,1,false,false) then
						npc.Velocity = (movepos - npc.Position):Resized(4)
					else
						npc.Pathfinder:FindGridPath(movepos, 2, 900, false)
					end
					data.state = "squidge"
				else
					data.state = "submerge"
					npc:PlaySound(mod.Sounds.DripSuck,0.4,0,false,1)
				end
			end
		end
	elseif data.state == "squidge" then
		npc.Velocity = npc.Velocity * 0.99
        mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
		if sprite:IsFinished("Move") then
			data.state = "idle"
			data.squidgecount = math.max(1,data.squidgecount - 1)
			npc.StateFrame = mod:RandomInt(10,15)
		else
			mod:spritePlay(sprite, "Move")
		end
	elseif data.state == "submerge" then
		npc.Velocity = Vector.Zero
		if sprite:IsFinished("Submerge") then
			npc.Velocity = Vector.Zero
			data.state = "fall"
            data.airborne = true
			npc.StateFrame = 0
			npc.Position = game:GetRoom():FindFreeTilePosition(targetpos, 40) + RandomVector()*5

			local effect = Isaac.Spawn(1000,1743,0,npc.Position,Vector.Zero,npc)
            effect:GetSprite():Load("gfx/enemies/glob/effect_glob_target.anm2", true)
			mod:spritePlay(effect:GetSprite(), "Appear")
			effect.Parent = npc
			npc.Child = effect
			effect:Update()
		elseif sprite:IsEventTriggered("NoDMG") then
			data.noDMG = true
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		else
			mod:spritePlay(sprite, "Submerge")
		end
	elseif data.state == "fall" then
		npc.Velocity = Vector.Zero
		mod:spritePlay(sprite, "Fall")
        npc.StateFrame = npc.StateFrame + 1
		if npc.StateFrame < 12 then
			npc.SpriteOffset = Vector(0, -300 + npc.StateFrame * 25)
		else
			npc.SpriteOffset = Vector(0, 0)
			data.state = "land"
			data.noDMG = false
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc:PlaySound(mod.Sounds.SplashSmall,2,0,false,1)
            npc:PlaySound(SoundEffect.SOUND_BEAST_LAVA_BALL_SPLASH, 1, 0, false, 1.2)
			if npc.Child and npc.Child:Exists() then
				npc.Child.Parent = nil
				npc.Child = nil
			end
            data.stoned = true
            local count = 3 --math.random(3,5)
            for i = 1, count do
                local fire = Isaac.Spawn(33,10,0, npc.Position, Vector(2.5,0):Rotated(360/count * i - 25 + mod:RandomInt(0,50)), npc)
                fire.HitPoints = fire.HitPoints / (1.5 + (0.25 * mod:RandomInt(0,4)))
                fire:Update()
            end
            local creep = Isaac.Spawn(1000,22,0,npc.Position,Vector.Zero,npc):ToEffect()
            creep.Color = mod.ColorGreyscaleLight
            creep:SetColor(mod.ColorFireJuicy, 60, 0, true, false)
            creep.SpriteScale = creep.SpriteScale * 1.5
            creep:SetTimeout(40)
            local effect = Isaac.Spawn(1000,16,3,npc.Position,Vector.Zero,npc):ToEffect()
            effect.Color = mod.ColorFireJuicy
            effect:GetSprite().Scale = effect:GetSprite().Scale * 0.75
		end
	elseif data.state == "land" then
		npc.Velocity = Vector.Zero
		if sprite:IsFinished("Land") then
			data.state = "extinguished"
			npc.StateFrame = mod:RandomInt(10,15)
		else
			mod:spritePlay(sprite, "Land")
		end
    elseif data.state == "extinguished" then
        npc.Velocity = npc.Velocity * 0.75
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            npc.TargetPosition = mod:GetGlobTarget(npc)
            if npc.TargetPosition:Distance(npc.Position) < 20 and data.TargetIndex and mod:IsPitAdjacent(data.TargetIndex) then
                data.state = "rollend"
                npc.StateFrame = mod:RandomInt(30,45)
                data.endanim = "JumpNoRoll"
            else
                data.state = "rollstart"
            end
		else
			mod:spritePlay(sprite, "Idle02")
		end
    elseif data.state == "rollstart" then
        if sprite:WasEventTriggered("Roll") then
            mod:CatheryPathFinding(npc, npc.TargetPosition, {
                Speed = 7,
                Accel = 0.1,
                GiveUp = true
            })
            if not sfx:IsPlaying(mod.Sounds.RolyPolyRoll) and not npc:HasMortalDamage() then
				sfx:Play(mod.Sounds.RolyPolyRoll, 0.6, 0, true, 1)
			end
            mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
        else
            npc.Velocity = npc.Velocity * 0.85
        end
        if sprite:IsFinished("RollStart") then
            data.state = "roll"
        elseif sprite:IsEventTriggered("Roll") then

        else
            mod:spritePlay(sprite, "RollStart")
        end
    elseif data.state == "roll" then
        npc.TargetPosition = npc.TargetPosition or mod:GetGlobTarget(npc)
        if npc.TargetPosition:Distance(npc.Position) < 20 then
            if data.TargetIndex and mod:IsPitAdjacent(data.TargetIndex) then
                data.state = "rollend"
                data.endanim = "RollEnd"
                sfx:Stop(mod.Sounds.RolyPolyRoll)
                npc.StateFrame = mod:RandomInt(30,45)
            else
                npc.TargetPosition = mod:GetGlobTarget(npc)
            end
        else
            mod:CatheryPathFinding(npc, npc.TargetPosition, {
                Speed = 7,
                Accel = 0.05,
                GiveUp = true
            })
            if not sfx:IsPlaying(mod.Sounds.RolyPolyRoll) and not npc:HasMortalDamage() then
				sfx:Play(mod.Sounds.RolyPolyRoll, 0.6, 0, true, 1)
			end
        end
        mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
        mod:spritePlay(sprite, "Roll")
    elseif data.state == "rollend" then
        if sprite:WasEventTriggered("Jump") then
            npc.Velocity = npc.Velocity * 0.85
        else
            npc.Velocity = npc.Velocity * 0.75
        end
        if sprite:IsEventTriggered("Jump") then
            local pit = mod:GetNearestGridIndexOfType(GridEntityType.GRID_PIT, GridCollisionClass.COLLISION_PIT, npc.Position) or data.TargetIndex
            npc.Velocity = (room:GetGridPosition(pit) - npc.Position) / 6
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            npc:PlaySound(SoundEffect.SOUND_FETUS_JUMP,0.8,0,false,1)
            mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
            data.airborne = true
        elseif sprite:IsEventTriggered("NoDMG") then
            Isaac.Spawn(1000,16,66,npc.Position,Vector.Zero,npc):ToEffect()
            mod:PlaySound(SoundEffect.SOUND_WAR_LAVA_SPLASH, npc, 1.2, 0.8)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR)
        elseif sprite:IsFinished(data.endanim) or data.plonked then
            npc.StateFrame = npc.StateFrame - 1
            npc.Visible = false
            if npc.StateFrame <= 0 then
                data.state = "emerge"
                data.TargetIndex = nil
				npc.Visible = true
                data.stoned = false
                npc.Velocity = (mod:GetNearestPosOfCollisionClass(npc.Position, GridCollisionClass.COLLISION_NONE) - npc.Position) / 6
				mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
            end
        else
            mod:spritePlay(sprite, data.endanim)
        end
    elseif data.state == "emerge" then
        if sprite:WasEventTriggered("Land") then
            npc.Velocity = npc.Velocity * 0.75
        else
            npc.Velocity = npc.Velocity * 0.85
        end
        if sprite:IsEventTriggered("TakeDMG") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR)
			Isaac.Spawn(1000,16,66,npc.Position - npc.Velocity:Resized(20),Vector.Zero,npc):ToEffect()
			mod:PlaySound(SoundEffect.SOUND_WAR_LAVA_SPLASH, npc, 1.2, 0.8)
        elseif sprite:IsEventTriggered("Land") then
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            data.airborne = false
            local effect = Isaac.Spawn(1000,16,3,npc.Position,Vector.Zero,npc):ToEffect()
            effect.Color = mod.ColorFireJuicy
            effect:GetSprite().Scale = effect:GetSprite().Scale * 0.5
            npc:PlaySound(mod.Sounds.SplashSmall,2,0,false,1)
        elseif sprite:IsFinished("Emerge") then
            data.squidgecount = 5
            npc.StateFrame = mod:RandomInt(10,15)
            data.state = "idle"
        else
            mod:spritePlay(sprite, "Emerge")
        end
	end

    local interval = 7
    if npc.FrameCount % interval == 2 and not (data.airborne or data.stoned or data.IsFerrWaiting) then
        local creep = Isaac.Spawn(1000,22,0,npc.Position,Vector.Zero,npc):ToEffect()
        creep.Color = mod.ColorGreyscaleLight
        creep:SetColor(mod.ColorFireJuicy, interval * 3, 0, true, false)
        creep:SetTimeout(interval * 2)
    end

    if room:HasWater() then
		npc:Kill()
	end

    if npc:IsDead() then
		if data.stoned then
			for i = 0, 3 do
				local shard = Isaac.Spawn(1000, 35, 0, npc.Position, Vector.One:Resized(rng:RandomFloat()*4):Rotated(mod:RandomAngle()), npc)
				shard.Color = mod.ColorCharred
			end
			sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
		end
	end
    if mod:IsReallyDead(npc) then
        sfx:Stop(mod.Sounds.RolyPolyRoll)
    end
end

function mod:GetGlobTarget(npc)
    local room = game:GetRoom()
    local gridtarg = mod:GetSizzleTarget(npc)
    if gridtarg then 
        npc:GetData().TargetIndex = gridtarg
        return room:GetGridPosition(gridtarg)
    else
        npc:GetData().TargetIndex = nil
        return mod:FindRandomValidPathPosition(npc)
    end
end

function mod:GlobHurt(npc, amount, damageFlags, source)
    if npc:GetData().noDMG or (mod:HasDamageFlag(DamageFlag.DAMAGE_FIRE, damageFlags) and not mod:IsPlayerDamage(source)) then
        return false
    else
        if math.random(5) == 1 then
            npc:PlaySound(SoundEffect.SOUND_BABY_HURT,1,0,false,1)
        end
    end
end
-- Warble (ported from Morbus, originally coded by Xalum) --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:warbleAI(npc, sprite, npcdata)
	if npc.SubType == 10 then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc.Visible = false
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		
		if not npc.Parent or npc.Parent:IsDead() or mod:isStatusCorpse(npc.Parent) then
			npc:Remove()
		end
	else
		if not npcdata.init then
			if npc.SubType == 0 or npc.SubType > 4 then 
				npcdata.dir = math.random(4) 
			else 
				npcdata.dir = npc.SubType 
			end

			if npcdata.dir == 1 then
				npcdata.dir = Vector(-0.5, 0.5)
			elseif npcdata.dir == 2 then
				npcdata.dir = Vector(0.5, 0.5)
			elseif npcdata.dir == 3 then
				npcdata.dir = Vector(-0.5, -0.5)
			elseif npcdata.dir == 4 then
				npcdata.dir = Vector(0.5, -0.5)
			end

			--npc.Mass = 18

			npcdata.init = true
		end
		
		local tail = npc.Child
		if not tail then
			tail = Isaac.Spawn(mod.FF.WarbleTail.ID, mod.FF.WarbleTail.Var, mod.FF.WarbleTail.Sub, npc.Position, nilvector, npc)
			tail:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			tail.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			tail:GetSprite():Play("Hidden", true)
			
			npc.Child = tail
			tail.Parent = npc
		end
		tail.Velocity = Vector(0,0)
		tail.HitPoints = npc.HitPoints

		if sprite:IsFinished("Appear") or (npc.Velocity.X == 0 and npc.Velocity.Y == 0) then
			if npc.Velocity.X == 0 then
				npcdata.dir = Vector(npcdata.dir.X * -1, npcdata.dir.Y)
			end
			if npc.Velocity.Y == 0 then
				npcdata.dir = Vector(npcdata.dir.X, npcdata.dir.Y * -1)
			end
			
			npc.Velocity = npcdata.dir
		end
		
		if mod:isConfuse(npc) then
			local confuseVel = mod:confusePos(npc, npc.Velocity, nil, true)
			
			local actualVel = mod:Lerp(npc.Velocity, confuseVel, 0.1)
			npc.Velocity = actualVel
			npcdata.dir = actualVel
		elseif mod:isScare(npc) then
			local angle = npc.Velocity:GetAngleDegrees()
			local regularVel = npc.Velocity:Rotated((90 * math.floor((angle + 45) / 90 + 0.5) - (angle + 45))):Resized(6)
			
			local target = npc:GetPlayerTarget()
			local confuseVel = (target.Position - npc.Position):Resized(-6)
			
			local lerpAmount = 1 / math.max(4/3, (target.Position - npc.Position):Length() - 80)
			local mixedVel = mod:Lerp(regularVel, confuseVel, lerpAmount)
			
			local actualVel = mod:Lerp(npc.Velocity, mixedVel, 0.1)
			npc.Velocity = actualVel
			npcdata.dir = actualVel
		else
			local angle = npc.Velocity:GetAngleDegrees()
			local regularVel = npc.Velocity:Rotated((90 * math.floor((angle + 45) / 90 + 0.5) - (angle + 45))):Resized(6)
			
			local actualVel = mod:Lerp(npc.Velocity, regularVel, 0.1)
			npc.Velocity = actualVel
			npcdata.dir = actualVel
		end

		sprite.FlipX = npc.Velocity.X > 0

		if npc.Velocity.Y > 0 then
			sprite:Play("FlyDown")

			if sprite.FlipX then
				tail.Position = npc.Position + Vector(-0.5, -0.5)
			else
				tail.Position = npc.Position + Vector(0.5, -0.5)
			end
		elseif npc.Velocity.Y < 0 then
			sprite:Play("FlyUp")

			if sprite.FlipX then
				tail.Position = npc.Position + Vector(-0.5, 0.5)
			else
				tail.Position = npc.Position + Vector(0.5, 0.5)
			end
		end

		if npc:IsDead() and not mod:isLeavingStatusCorpse(npc) then
			local params = ProjectileParams()
			params.HeightModifier = -5
			
			for i = 1, 7 + math.random(5) do
				params.Scale = math.random(10, 15)/10
				npc:FireProjectiles(npc.Position, RandomVector():Resized(9 - math.random()*2), 0, params)
			end

			for _, projectile in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE, 0)) do
				if projectile.FrameCount <= 1 and projectile.SpawnerEntity and projectile.SpawnerEntity.Index == npc.Index and projectile.SpawnerEntity.InitSeed == npc.InitSeed then
					projectile:GetData().WarbleProjectile = true
				end
			end

			sfx:Play(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, 1)
		end
	end
end

function mod.warbleProjectiles(projectile, data)
	if data.WarbleProjectile then
		projectile.Velocity = projectile.Velocity * 0.9
		if projectile.Velocity:Length() > 0.1 and projectile.FallingAccel then
			projectile.FallingAccel = 0.01
		else
			projectile.FallingAccel = projectile.FallingAccel + 0.1
		end
	end
end

function mod:warbleCollision(npc1, npc2)
    if npc1.Parent and npc1.Parent.InitSeed == npc2.InitSeed then -- Prevent selfdamage from charm/bait
        return true
    elseif npc1.Child and npc1.Child.InitSeed == npc2.InitSeed then
        return true
    end
	
	if npc2.Type == EntityType.ENTITY_MOVABLE_TNT or
	   (npc2.Type == mod.FF.AmnioticSac.ID and npc2.Variant == mod.FF.AmnioticSac.Var) or
	   (npc2.Type == mod.FF.Miscarriage.ID and npc2.Variant == mod.FF.Miscarriage.Var)
	then
		return true
	end
end

function mod:warbleKill(npc)
	if npc.Child then
		npc.Child:Remove()
	end
end

function mod:warbleTakeDmg(npc, damage, flag, source, countdown)
    local data = npc:GetData()

    if flag == flag | DamageFlag.DAMAGE_POISON_BURN then -- Keep Poison/Burn synced to once per 40 frames
        data.FFLastPoisonProc = data.FFLastPoisonProc or 0
        if Isaac.GetFrameCount() - data.FFLastPoisonProc < 40 then
            return false
        end
        data.FFLastPoisonProc = Isaac.GetFrameCount()

        if flag ~= flag | DamageFlag.DAMAGE_CLONES then
            if npc.SubType ~= 10 then
				--if npc.Child then
				--	npc.Child:TakeDamage(damage, flag | DamageFlag.DAMAGE_CLONES, source, 0)
				--end
            else
				if npc.Parent then
					npc.Parent:TakeDamage(damage, flag | DamageFlag.DAMAGE_CLONES, source, 0)
				end
				return false
            end
        end
    elseif npc.SubType ~= 10 then
		if flag ~= flag | DamageFlag.DAMAGE_CLONES and not data.FFTakingBleedDamage then -- Regular damage
            return false
		end
    else
		if flag ~= flag | DamageFlag.DAMAGE_CLONES then -- Regular damage
			if npc.Parent then
				npc.Parent:TakeDamage(damage, flag | DamageFlag.DAMAGE_CLONES, source, 0)
			end
			return false
        end
    end
end

local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local player = fam.Player
	local d = fam:GetData()
	local sprite = fam:GetSprite()
	local isSuperpositioned = mod:isSuperpositionedPlayer(fam.Player)
	local isSirenCharmed = mod:isSirenCharmed(fam)

    fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
    fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS

    if not d.init then
        d.Charging = nil
        d.targetPos = nil
        d.WaitFrame = 5
        d.init = true
    end

    if d.ReChargeCooldown then
        d.ReChargeCooldown = d.ReChargeCooldown - 1
        if d.ReChargeCooldown <= 0 then
            d.ReChargeCooldown = nil
        end
    end

    local stringAdd = ""
    if isSirenCharmed then
        stringAdd = "Naughty"
    end

    local room = game:GetRoom()
    --[[if room:IsClear() then
        if sprite:IsPlaying("Spikes" .. stringAdd) then
            sfx:Play(SoundEffect.SOUND_GOOATTACH0, 1, 0, false, 0.5)
        end
        mod:spritePlay(sprite, "No-Spikes" .. stringAdd)
        fam.Velocity = fam.Velocity * 0.7
        d.Charging = nil
    else]]
        if sprite:IsPlaying("No-Spikes") then
            sfx:Play(SoundEffect.SOUND_GOOATTACH0, 1, 0, false, 0.8)
        end
        mod:spritePlay(sprite, "Spikes" .. stringAdd)
        if d.Charging then
            d.chargeTime = d.chargeTime or 0
            d.chargeTime = d.chargeTime + 1
            local vec = d.Charging:Resized(15)
            fam.Velocity = mod:Lerp(fam.Velocity, vec, 0.2)
            local checkPos = fam.Position + d.Charging:Resized(40)
            if room:GetGridCollisionAtPos(checkPos) > 1 then
                local grident = room:GetGridEntityFromPos(checkPos)
                if grident and grident:ToPoop() and d.chargeTime >= 5 then
                    grident:Destroy()
                end
                if room:GetGridCollisionAtPos(checkPos) > 1 then
                    d.Charging = nil
                    if d.chargeTime >= 5 then
                        sfx:Play(SoundEffect.SOUND_STONE_IMPACT,1,2,false,1)
                        d.WaitFrame = 60

                        for _, entity in pairs(Isaac.FindInRadius(fam.Position, 150, EntityPartition.ENEMY)) do
                            if entity.Position:Distance(fam.Position) < fam.Size + entity.Size then
                                entity:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
                                entity:TakeDamage(fam.CollisionDamage * 5, 0, EntityRef(fam), 0)
                                mod.scheduleForUpdate(function()
                                    if fam and fam:Exists() then
                                        d = d or fam:GetData()
                                        if entity then
                                            if entity:IsDead() or entity:HasMortalDamage() then
                                                d.killed = 30
                                                d.killedSplat = entity.SplatColor
                                                for i = 1, 10 do
                                                    local blood = Isaac.Spawn(1000,7,0,fam.Position + RandomVector():Resized(math.random(20)), nilvector, fam)
                                                    blood.Color = d.killedSplat
                                                    blood:Update()
                                                end
                                                if Sewn_API then
                                                    if Sewn_API:IsUltra(d) then
                                                        local creep = Isaac.Spawn(1000,32,0,fam.Position, nilvector, fam)
                                                        creep.Color = Color(1,0,0,1)
                                                        creep:Update()
                                                    end
                                                end
                                            else
                                                entity:ClearEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
                                            end
                                        else
                                            d.killed = 30
                                        end
                                    end
                                end, 1)
                            end
                        end
                    end
                end
            end

            local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, fam.Position, fam.Velocity:Resized(3), fam)
            smoke.SpriteScale = smoke.SpriteScale * 1.2
            smoke.SpriteOffset = Vector(0, -5)
            smoke.SpriteRotation = math.random(360)
            smoke.Color = Color(1.8, 2, 1.8, 0.4)
            smoke:Update()

            if fam.FrameCount % 3 == 1 then
                if Sewn_API then
                    if Sewn_API:IsSuper(d, true) then
                        local tear = Isaac.Spawn(2, 1, 0, fam.Position, nilvector, fam):ToTear()
                        tear.CollisionDamage = fam.CollisionDamage / 5
                        tear:Update()
                    end
                end
            end

            d.targetPos = nil
        else
            d.chargeTime = nil
            if d.WaitFrame then
                local targpos = room:GetGridPosition(room:GetGridIndex(fam.Position))
                fam.Velocity = mod:Lerp(fam.Velocity, (targpos - fam.Position), 0.3)
                d.WaitFrame = d.WaitFrame - 1
                if d.WaitFrame <= 0 then
                    d.WaitFrame = nil
                end
            else
                if not d.targetPos then
                    local priorityDirs = {}
                    local validDirs = {}
                    for j = 40, 200 do
                        for i = 90, 360, 90 do
                            local pos = room:GetGridPosition(room:GetGridIndex(fam.Position + Vector(j, 0):Rotated(90 * math.random(4))))
                            local posColl = room:GetGridCollisionAtPos(pos) 
                            if posColl <= 1 and room:IsPositionInRoom(pos, 0) then
                                if room:CheckLine(fam.Position, pos, 3) then
                                    if posColl == 0 then
                                        if room:GetGridCollisionAtPos(fam.Position) == 1 or room:CheckLine(fam.Position, pos, 0) then
                                            table.insert(priorityDirs, pos)
                                        end
                                    else
                                        table.insert(validDirs, pos)
                                    end
                                end
                            end
                        end
                    end
                    if #priorityDirs > 0 then
                        d.targetPos = priorityDirs[math.random(#priorityDirs)]
                    elseif #validDirs > 0 then
                        d.targetPos = validDirs[math.random(#validDirs)]
                    else
                        d.targetPos = fam.Position
                    end
                end
                if d.targetPos then
                    fam.Velocity = mod:Lerp(fam.Velocity, (d.targetPos - fam.Position):Resized(3), 0.3)
                    if d.targetPos:Distance(fam.Position) < 5 then
                        d.targetPos = nil
                    end
                end
            end
        end
    --end

    if d.killed then
        if (not d.WaitFrame and fam.FrameCount % 3 == 0) or d.Charging then
            local blood = Isaac.Spawn(1000,7,0,fam.Position, nilvector, fam)
            blood.SpriteScale = Vector(d.killed/30, d.killed/30)
            if d.killedSplat then
                blood.Color = d.killedSplat
            end
            blood:Update()

            d.killed = d.killed - 1
            if d.killed <= 0 then
                d.killed = nil
            end
        end
    else
        d.killedSplat = nil
    end

end, mod.ITEM.FAMILIAR.PET_PEEVE)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, familiar, collider)
	if collider.Type == EntityType.ENTITY_SIREN_HELPER and 
	   collider.Target and 
	   collider.Target.Index == familiar.Index and 
	   collider.Target.InitSeed == familiar.InitSeed 
	then
		return true
	end
    if collider.Type == 9 then
        if not mod:isSirenCharmed(familiar) then
            collider:Die()
        end
    elseif collider.Type ~= 1 then
        if familiar:GetData().Charging then
            familiar:GetData().ReChargeCooldown = 10
            if not collider:HasEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) then
                local vec = collider.Position - familiar.Position
                collider.Velocity = familiar.Velocity * 1.25
                collider.Position = familiar.Position + vec
            end
            collider:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
            mod.scheduleForUpdate(function()
                if familiar and familiar:Exists() then
                    local d = familiar:GetData()
                    if collider then
                        if collider:IsDead() or collider:HasMortalDamage() then
                            d.killed = 30
                            d.killedSplat = collider.SplatColor
                            for i = 1, 10 do
                                local blood = Isaac.Spawn(1000,7,0,familiar.Position + RandomVector():Resized(math.random(20)), nilvector, familiar)
                                blood.Color = d.killedSplat
                                blood:Update()
                            end
                            if Sewn_API then
                                if Sewn_API:IsUltra(d) then
                                    local creep = Isaac.Spawn(1000,32,0,familiar.Position, nilvector, familiar)
                                    creep.Color = Color(1,0,0,1)
                                    creep:Update()
                                end
                            end
                        else
                            collider:ClearEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
                        end
                    else
                        d.killed = 30
                    end
                end
            end, 2)
        else
            local targvec = (familiar.Position - collider.Position)
            targvec = targvec:Resized(targvec:Length() - familiar.Size - collider.Size)
            collider.Velocity = mod:Lerp(collider.Velocity, targvec, 0.1)
        end
    end
end, mod.ITEM.FAMILIAR.PET_PEEVE)

function mod:petPeeveDoubleTap(player, aim, data, sdata)
    local petpeeves = Isaac.FindByType(3, mod.ITEM.FAMILIAR.PET_PEEVE, -1, false, false)
    for _, petpeeve in pairs(petpeeves) do
        local d = petpeeve:GetData()
        if not mod:isSirenCharmed(petpeeve:ToFamiliar()) then
            if (not d.WaitFrame or d.WaitFrame and d.WaitFrame <= 50) and not d.ReChargeCooldown then
                d.Charging = aim
            end
        end
    end
end
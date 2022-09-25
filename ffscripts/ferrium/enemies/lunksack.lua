local mod = FiendFolio
local sfx = SFXManager()

function mod:lunksackAI(npc)
    local data = npc:GetData()
    local sprite = npc:GetSprite()
    local target = npc:GetPlayerTarget()
    local rng = npc:GetDropRNG()

    if not data.init then
		data.state = "Idle"
		data.initPos = npc.Position
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
        npc.StateFrame = 20
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	if not data.isSpecturned then
		if not data.initPos then
			data.initPos = npc.Position
		end
		npc.Velocity = data.initPos-npc.Position
	else
		data.initPos = nil
	end

    if data.state == "Idle" then
        if npc.StateFrame > 35 and not mod:isScareOrConfuse(npc) then
            data.state = "Prepare"
        end

        mod:spritePlay(sprite, "Idle")
    elseif data.state == "PreppedIdle" then
        if data.target and data.target:Exists() and not mod:isStatusCorpse(data.target) then
            if npc.StateFrame > 30 and rng:RandomInt(40) == 0 and not mod:isScareOrConfuse(npc) then
                data.state = "Swing"
            elseif npc.StateFrame > 65 and not mod:isScareOrConfuse(npc) then
                data.state = "Swing"
            end
        else
            local radius = 9999
            local chosen
            for _,enemy in ipairs(Isaac.FindInRadius(npc.Position, 999, EntityPartition.ENEMY)) do
                if enemy:IsActiveEnemy() and not npc:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) and not (enemy.Type == mod.FF.Lunksack.ID and enemy.Variant == mod.FF.Lunksack.Var) and not enemy:GetData().lunksackChosen and not enemy:IsBoss() then
                    if not mod:isLunksackBlacklist(enemy) and not enemy:GetData().eternalFlickerspirited then
                        if enemy.Position:Distance(target.Position) < radius then
                            chosen = enemy
                            radius = enemy.Position:Distance(target.Position)
                        end
                    end
                end
            end
            if chosen then
                data.target = chosen
                data.target:GetData().lunksackChosen = true
            else
                data.playerTarget = true
                data.target = target
            end
            local needle = Isaac.Spawn(mod.FF.LunksackNeedle.ID, mod.FF.LunksackNeedle.Var, mod.FF.LunksackNeedle.Sub, data.target.Position, data.target.Position, npc):ToEffect()
            needle:FollowParent(data.target)
            needle.SpriteOffset = Vector(0,-70)
            needle.Child = npc
            needle.Parent = data.target
            data.needle = needle
            if mod:isFriend(npc) then
                data.needle:GetData().friend = ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.HIT_ENEMIES
            elseif mod:isCharm(npc) then
                data.needle:GetData().friend = ProjectileFlags.HIT_ENEMIES
            end
            data.target:SetColor(Color(0.6, 0.6, 0.6, 1.0, 0.5, 0.2, 0.5), 5, 0, true, false)
            local beam = Isaac.Spawn(1000, 175, 0, data.target.Position, Vector.Zero, npc):ToEffect()
            --beam.Color = Color(1, 0.1, 0.1, 0.3, 0,0,0)
            beam.Parent = npc
            beam.Target = data.target
            data.needle:GetData().beam = beam
            npc.StateFrame = math.min(15, npc.StateFrame)
        end

        mod:spritePlay(sprite, "PrimedIdle")
    elseif data.state == "Prepare" then
        if sprite:IsFinished("Raise") then
            data.state = "PreppedIdle"
            npc.StateFrame = 0

            local radius = 9999
            local chosen
            for _,enemy in ipairs(Isaac.FindInRadius(npc.Position, 999, EntityPartition.ENEMY)) do
                if enemy:IsActiveEnemy() and not npc:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) and not (enemy.Type == mod.FF.Lunksack.ID and enemy.Variant == mod.FF.Lunksack.Var) and not enemy:GetData().lunksackChosen and not enemy:IsBoss() then
                    if not mod:isLunksackBlacklist(enemy) and not enemy:GetData().eternalFlickerspirited then
                        if enemy.Position:Distance(target.Position) < radius then
                            chosen = enemy
                            radius = enemy.Position:Distance(target.Position)
                        end
                    end
                end
            end
            if chosen then
                data.target = chosen
                data.target:GetData().lunksackChosen = true
            else
                data.playerTarget = true
                data.target = target
            end
            local needle = Isaac.Spawn(mod.FF.LunksackNeedle.ID, mod.FF.LunksackNeedle.Var, mod.FF.LunksackNeedle.Sub, data.target.Position, data.target.Position, npc):ToEffect()
            needle:FollowParent(data.target)
            needle.SpriteOffset = Vector(0,-70)
            needle.Child = npc
            needle.Parent = data.target
            data.needle = needle
            if mod:isFriend(npc) then
                data.needle:GetData().friend = ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.HIT_ENEMIES
            elseif mod:isCharm(npc) then
                data.needle:GetData().friend = ProjectileFlags.HIT_ENEMIES
            end
            data.target:SetColor(Color(0.6, 0.6, 0.6, 1.0, 0.5, 0.2, 0.5), 5, 0, true, false)
            local beam = Isaac.Spawn(1000, 175, 0, data.target.Position, Vector.Zero, npc):ToEffect()
            --beam.Color = Color(1, 0.1, 0.1, 0.3, 0,0,0)
            beam.Parent = npc
            beam.Target = data.target
            data.needle:GetData().beam = beam
        elseif sprite:IsEventTriggered("Warn") then
            npc:PlaySound(mod.Sounds.BuckAppear1, 1, 0, false, 0.8)
        else
            mod:spritePlay(sprite, "Raise")
        end
    elseif data.state == "Swing" then
        if sprite:IsFinished("Attack") then
            data.state = "Idle"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Shout") then
            npc:PlaySound(mod.Sounds.TemperCharge, 1, 0, false, 0.8)
        elseif sprite:IsEventTriggered("Shoot") then
            npc:PlaySound(SoundEffect.SOUND_TOOTH_AND_NAIL, 1, 0, false, 2)
            if data.needle and data.needle:Exists() then
                data.needle:GetData().state = "StabStart"
                if data.playerTarget then
                    data.needle:GetData().playerTarget = true
                end
            end
        elseif sprite:IsEventTriggered("Chortle") then
            npc:PlaySound(mod.Sounds.BuckRummage, 1.5, 0, false, 1.2)
        else
            mod:spritePlay(sprite, "Attack")
        end
    end
end

function mod:lunksackNeedleEffect(e)
    local sprite = e:GetSprite()
    local data = e:GetData()

    if not data.init then
        data.state = "Idle"
        data.init = true
    end

    if (e.Child and e.Child:Exists() and not mod:isStatusCorpse(e.Child)) and (e.Parent and e.Parent:Exists() and not mod:isStatusCorpse(e.Parent)) or data.launched then
        if data.state == "Falling" then
            mod:spritePlay(sprite, "FallLoop")
            e.Velocity = Vector.Zero
        elseif data.state == "StabStart" then
            if not data.launched then
                data.launchedEnemyInfo = {height = e.SpriteOffset.Y, zVel = -5, accel = 0.5, landFunc = function() 
                    data.state = "Landed" 
                    sfx:Play(SoundEffect.SOUND_KNIFE_PULL, 0.6, 0, false, math.random(100,120)/100)
                    e.SpriteOffset = Vector(0,-5)

                    if not data.playerTarget then
                        if e.Parent and e.Parent:Exists() and not mod:isStatusCorpse(e.Parent) then
                            e.Parent:Kill()
                        end
                    end
                end, additional = function(tab) if tab.zVel > 5 and data.playerTarget then e.IsFollowing = false end
                end}
                data.launched = true
            end
            if sprite:IsFinished("FallStart") then
                data.state = "Falling"
            elseif sprite:IsEventTriggered("Shoot") then
                --[[if data.playerTarget then
                    e.IsFollowing = false
                end]]
            else
                mod:spritePlay(sprite, "FallStart")
            end
            e.Velocity = Vector.Zero
        elseif data.state == "Landed" then
            if sprite:IsFinished("FallEnd") then
                e:Remove()
            elseif sprite:IsEventTriggered("Shoot") then
                for i=45,360,45 do
                    local proj = Isaac.Spawn(9, 8, 0, e.Position, Vector(15,0):Rotated(i), e):ToProjectile()
                    local pData = proj:GetData()
                    if data.friend ~= nil then
                        proj.ProjectileFlags = proj.ProjectileFlags | data.friend
                    end
                    local pSprite = proj:GetSprite()
                    pSprite:Load("gfx/projectiles/hp_pinhead_projectile.anm2",true)
                    pSprite:Play("RegularTear9")
                    pData.pointedProjectile = true
                    pData.customProjSound = {[1] = SoundEffect.SOUND_POT_BREAK, [2] = 0.5, [3] = 3}
                    pData.makeSplat = EffectVariant.IMPACT
                    pData.toothParticles = Color(0.3,0.3,0.3,1,0,0,0)
                end
                if data.beam then
                    data.beam:Remove()
                end
            else
                mod:spritePlay(sprite, "FallEnd")
            end
        end
    else
        if sprite:IsFinished("Fade") then
            e:Remove()
            if data.beam then
                data.beam:Remove()
            end
        else
            mod:spritePlay(sprite, "Fade")
        end
    end
end

function mod.pointedProjectile(v, d)
    if d.pointedProjectile then
        v:GetSprite().Rotation = v.Velocity:GetAngleDegrees()
    end
end

function mod:isLunksackBlacklist(entity)
	return mod.lunksackBlacklist[entity.Type] or
        mod.lunksackBlacklist[entity.Type .. " " .. entity.Variant] or
        mod.lunksackBlacklist[entity.Type .. " " .. entity.Variant .. " " .. entity.SubType]
end
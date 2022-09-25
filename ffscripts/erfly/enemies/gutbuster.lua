local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--GutbusterAI
function mod:drownedLongLegsAI(npc, subt)
    local sprite = npc:GetSprite()
    local target = npc:GetPlayerTarget()
    local d = npc:GetData()
    local isKrass = (npc.Variant == mod.FF.KrassBlaster.Var)
    
    if not d.init then
        d.init = true
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_BLOOD_SPLASH)
        if isKrass then
            --npc.SpriteOffset = Vector(0,-10)
            --npc.SplatColor = mod.ColorKrassBlaster
            if npc.SubType == 0 then
                d.npcState = 3
                d.GutSucked = 0
            else
                d.npcState = 1
            end
            d.GutsNum = npc.SubType
            d.GutSucked = 0
            d.GutSheet = math.max(d.GutsNum, 1)
            if d.GutSheet == 1 then
                sprite:ReplaceSpritesheet(0, "gfx/enemies/krassblaster/monster_krassblaster02.png")
                sprite:LoadGraphics()
            end
        else
            --npc.SplatColor = mod.ColorGutbuster
            npc.SplatColor = Color(0.4,0.4,0.5,1)
            if npc.SubType == 1 then
                d.npcState = 3
            else
                d.npcState = 1
            end
        end
        d.Hurtable = false
    elseif d.init then
        npc.StateFrame = npc.StateFrame + 1
    end
    if isKrass then
        if npc.FrameCount % 90 == 0 then
            --print(d.GutsNum)
        end
        mod:CheckGutSheet(d, sprite)
    end
    sprite.FlipX = false
    if sprite:IsEventTriggered("Shoot") then
        if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_BURSTING_SACK) then
            npc:PlaySound(SoundEffect.SOUND_KISS_LIPS1,2,0,false,math.random(80,120)/100)
        else
            npc:PlaySound(SoundEffect.SOUND_BOIL_HATCH,0.4,0,false,1.3)
            local params = ProjectileParams()
            params.Variant = 1
            if isKrass then
                params.Color = mod.ColorKrassBlaster
                npc:FireProjectiles(npc.Position, (target.Position - npc.Position):Resized(8), 3, params)
            else
                params.Color = mod.ColorGutbuster
                npc:FireProjectiles(npc.Position, (target.Position - npc.Position):Resized(7), 0, params)
            end
        end
    elseif sprite:IsEventTriggered("Summon") then
        if isKrass then
            for i = 1, 2 do
                if i <= d.GutsNum then
                    local pos = mod:FindRandomValidPathPosition(npc, 2, 60)
                    local npcguts = mod.spawnent(npc, pos, nilvector, mod.FF.DriedOffal.ID, mod.FF.DriedOffal.Var)
                    npcguts:GetSprite():Play("GutEmerge", true)
                    if d["GutPoints"..i] then
                        npcguts.HitPoints = d["GutPoints"..i]
                    end
                    npcguts.Parent = npc
                    npcguts:GetData().HasTarget = true
                    d["Guts"..i] = npcguts
                    local poofy = Isaac.Spawn(1000, 16, 2, npcguts.Position+Vector(0,10), Vector.Zero, npcguts):ToEffect()
                    poofy.SpriteScale = Vector(0.8, 0.8)
                    poofy.Color = mod.ColorGreyscale
                    if mod:RandomInt(1,2) == 1 then
                        poofy:GetSprite().FlipX = true
                    end
                    poofy:Update()
                    npcguts:ToNPC():PlaySound(SoundEffect.SOUND_BLACK_POOF, 0.6, 0, false, 1)
                else
                    d["Guts"..i] = nil
                end
            end
            d.GutSucked = 0
            npc.StateFrame = -20
        else
            local pos = mod:FindRandomValidPathPosition(npc, 2, 60)
            local npcguts = mod.spawnent(npc, pos, nilvector, mod.FF.Offal.ID, mod.FF.Offal.Var)
            npcguts:GetSprite():Play("GutEmerge", true)
            if d.GutPoints then
                npcguts.HitPoints = d.GutPoints
            end
            npcguts.Parent = npc
            npcguts:GetData().HasTarget = true
            d.Guts = npcguts
            npc.StateFrame = 0
        end
        if npc:HasEntityFlags(EntityFlag.FLAG_CHARM) then
            npc:ClearEntityFlags(EntityFlag.FLAG_CHARM)
        end
    elseif sprite:IsEventTriggered("Hurtable") then
        d.Hurtable = true
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    elseif sprite:IsEventTriggered("Unhurtable") then
        d.Hurtable = false
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
    elseif sprite:IsEventTriggered("SFXSplosh") then
        if isKrass then
            local poofy = Isaac.Spawn(1000, 16, 1, npc.Position, Vector.Zero, npc):ToEffect()
            poofy.SpriteScale = Vector(0.8, 0.8)
            poofy.Color = mod.ColorGreyscale
            if mod:RandomInt(1,2) == 1 then
                poofy:GetSprite().FlipX = true
            end
            poofy:Update()
            npc:PlaySound(SoundEffect.SOUND_BLACK_POOF, 0.8, 0, false, 0.8)
        else
            npc:PlaySound(mod.Sounds.SplashLarge,0.7,0,false,1.3)
        end
    end
    if d.npcState == 1 then
        npc.State = 4
        if isKrass then
            if d.GutsNum < 2 then
                npc.Velocity = npc.Velocity * 0.9
            else
                npc.Velocity = npc.Velocity * 0.8
            end
        else
            if sprite:IsPlaying("Walk") and not npc:IsDead() then
                if not sfx:IsPlaying(mod.Sounds.GutbusterRun) then
                    sfx:Play(mod.Sounds.GutbusterRun, 0.1, 0, true, 1.3)
                end
            else
                sfx:Stop(mod.Sounds.GutbusterRun)
            end
        end
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        if npc.Position:Distance(target.Position) < 50 or (npc.StateFrame > 150 and math.random(10) == 1) then
            d.npcState = 2
            if not isKrass then
                sfx:Stop(mod.Sounds.GutbusterRun)
            end
        end
    elseif d.npcState == 2 then
        npc.State = 9
        npc.Velocity = nilvector
        if sprite:IsFinished("Attack") then
            d.attackstate = 0
            d.npcState = 3
        else
            mod:spritePlay(sprite, "Attack")
        end
    elseif d.npcState == 3 then
        npc.State = 9
        npc.Velocity = nilvector
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        if isKrass then
            mod:CheckGutStatus(npc, d)
        else
            if not d.Guts or d.Guts:IsDead() or mod:isStatusCorpse(d.Guts) then
                local newgut = mod.FindClosestEntityHasTarget(target.Position, 99999, mod.FF.Offal.ID, mod.FF.Offal.Var)
                if newgut then
                    newgut.Parent = npc
                    newgut:GetData().HasTarget = true
                    d.Guts = newgut
                else
                    npc:Kill()
                end
            end
        end
        

        d.attackstate = d.attackstate or 0
        if d.attackstate > 0 then
            npc.StateFrame = 0
            if sprite:IsFinished("AttackGutless") then
                d.attackstate = d.attackstate - 1
                sprite:Play("AttackGutless", true)
            else
                mod:spritePlay(sprite, "AttackGutless")
            end
        elseif d.krassattack then
            if sprite:IsFinished("ShootIdle") then
                d.krassattack = false
                npc.StateFrame = 0
            else
                mod:spritePlay(sprite, "ShootIdle")
            end
        else
            mod:spritePlay(sprite, "IdleGutless")
            if npc.StateFrame > 50 and game:GetRoom():CheckLine(npc.Position,target.Position,3,1,false,false) and math.random(10) == 1 then
                if isKrass then
                    d.krassattack = true
                else
                    d.attackstate = 3
                end
            end
        end

        --Re-merge with guts
        if isKrass then
            if d.Guts1 and d.Guts1:Exists() and d.Guts1.Position:Distance(npc.Position) < 10 and not d.Guts1:GetData().hiding then
                mod:RetriveKrassGut(npc, d, d.Guts1, 1)
            elseif d.Guts2 and d.Guts2:Exists() and d.Guts2.Position:Distance(npc.Position) < 10 and not d.Guts2:GetData().hiding then
                mod:RetriveKrassGut(npc, d, d.Guts2, 2)
            end
        else
            if d.Guts and d.Guts:Exists() and d.Guts.Position:Distance(npc.Position) < 10 and not d.Guts:GetData().hiding then
                d.npcState = 4
                d.Guts.Position = npc.Position
                d.Guts.Velocity = nilvector
                d.Guts:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                d.Hurtable = true
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
                mod:spritePlay(sprite, "GutReturn")
                d.Guts:GetSprite():Play("GutReturnGuts")
            end
        end
    elseif d.npcState == 4 then
        npc.State = 9
        npc.Velocity = nilvector
        if isKrass then
            mod:CheckGutStatus(npc, d)
        end
        if d.Guts then
            d.Guts.Position = npc.Position
            if d.Hurtable and mod:IsReallyDead(d.Guts) then
                d.npcState = 3
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                d.Guts = nil
                if isKrass then
                    d.GutSucked = d.GutSucked - 1
                end
            end
        end
        if not d.Hurtable then
            if d.Guts then
                if d.Guts:HasEntityFlags(EntityFlag.FLAG_CHARM) then
                    npc:AddEntityFlags(EntityFlag.FLAG_CHARM)
                end
                if isKrass then
                    d["GutPoints"..d.GutSucked] = d.Guts.HitPoints
                else
                    d.GutPoints = d.Guts.HitPoints
                end
                npc:PlaySound(mod.Sounds.Slurp,2.5,0,false,1.4)
                d.Guts:Remove()
                d.Guts = nil
            end
        end
        if sprite:IsFinished("GutReturn") or sprite:IsFinished("GetUp") then
            d.npcState = 1
            d.Guts1Sucked = false
            d.Guts2Sucked = false
            npc.StateFrame = 0
        elseif sprite:IsFinished("GutReturnPartial") then
            d.npcState = 3
        end
    elseif d.npcState == 5 then
        npc.State = 9
        npc.Velocity = npc.Velocity * 0.9
        if sprite:IsFinished("Bombed") then
            d.npcState = 1
        else
            mod:spritePlay(sprite, "Bombed")
        end
    end
    if npc:HasMortalDamage() and not isKrass then
        sfx:Stop(mod.Sounds.GutbusterRun)
    end
end

function mod:CheckGutStatus(npc, d)
    local sprite = npc:GetSprite()
    if d.Guts1 and not d.Guts1Sucked then
        if mod:IsReallyDead(d.Guts1) then
            d.GutsNum = d.GutsNum - 1
            if mod:TryFindNewKrassGut(npc, d, 1) then
                d.GutsNum = d.GutsNum + 1
            else
                d.Guts1 = nil
            end
        end
    elseif d.GutsNum < 2 then
        if mod:TryFindNewKrassGut(npc, d, 1) then
            d.GutsNum = d.GutsNum + 1
        end
    end
    if d.Guts2 and not d.Guts2Sucked then
        if mod:IsReallyDead(d.Guts2) then
            d.GutsNum = d.GutsNum - 1
            if mod:TryFindNewKrassGut(npc, d, 2) then
                d.GutsNum = d.GutsNum + 1
            else
                d.Guts2 = nil
            end
        end
    elseif d.GutsNum < 2 then
        if mod:TryFindNewKrassGut(npc, d, 2) then
            d.GutsNum = d.GutsNum + 1
        end
    end
    --print(d.GutSucked.." "..d.GutsNum)
    if d.GutSucked >= d.GutsNum and npc.StateFrame > 30 and not (sprite:IsPlaying("GutReturn") or sprite:IsFinished("GutReturn")) then
        d.npcState = 4
        mod:spritePlay(sprite, "GetUp")
    end
    if d.GutsNum <= 0 and d.GutSucked <= 0 and npc.StateFrame > 30 then
        npc:Kill()
    end
end

function mod:CheckGutSheet(d, sprite)
    if d.GutsNum ~= d.GutSheet then
        if d.GutsNum <= 1 then
            sprite:ReplaceSpritesheet(0, "gfx/enemies/krassblaster/monster_krassblaster02.png")
        else
            sprite:ReplaceSpritesheet(0, "gfx/enemies/krassblaster/monster_krassblaster.png")
        end
        d.GutSheet = d.GutsNum
        sprite:LoadGraphics()
    end
end

function mod:RetriveKrassGut(npc, d, gut, i)
    d.npcState = 4
    gut.Position = npc.Position
    gut.Velocity = nilvector
    d.GutSucked = d.GutSucked + 1
    d["Guts"..i.."Sucked"] = true
    gut:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
    npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    d.Hurtable = true
    if d.GutSucked >= d.GutsNum then
        mod:spritePlay(npc:GetSprite(), "GutReturn")
    else
        mod:spritePlay(npc:GetSprite(), "GutReturnPartial")   
    end
    d.Guts = gut:ToNPC()
    gut:GetSprite():Play("GutReturnGuts")
    gut = nil
end

function mod:TryFindNewKrassGut(npc, d, i)
    local newgut = mod.FindClosestEntityHasTarget(npc.Position, 99999, mod.FF.DriedOffal.ID, mod.FF.DriedOffal.Var)
    if newgut then
        newgut.Parent = npc
        newgut:GetData().HasTarget = true
        d["Guts"..i] = newgut
        return true
    end
end

function mod:checkGutBusterHurt(npc, damage, flag, source)
    local variant = npc.Variant
    if variant == mod.FF.Gutbuster.Var or variant == mod.FF.KrassBlaster.Var then
        if flag & DamageFlag.DAMAGE_EXPLOSION ~= 0 then
            local d = npc:GetData()
            if d.npcState == 1 then
                d.npcState = 5
            end
        end
        return false
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.checkGutBusterHurt, 207)

--Offal AI
function mod:gutbusterGutsAI(npc, subt)
    local sprite = npc:GetSprite()
    local d = npc:GetData()
    local path = npc.Pathfinder
    local isDry = (npc.Variant == mod.FF.DriedOffal.Var)
    
    if not d.init then
        d.init = true
        d.target = game:GetRoom():GetRandomPosition(1)
        if isDry then
            d.shootCounter = mod:RandomInt(2,5)
        end
        if subt == 1 then
            d.hiding = true
            npc.Visible = false
            npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
        else
            if not sprite:IsPlaying("GutEmerge") then
                mod:spritePlay(sprite, "GutEmerge")
            end
        end
    end

    if sprite:IsFinished("GutEmerge") or sprite:IsFinished("GutShoot") then
        mod:spritePlay(sprite, "GutWalk")
    elseif sprite:IsFinished("GutReturnGuts") then
        npc:Remove()
    end

    if d.hiding then
        if mod.CanIComeOutYet() then
            npc.StateFrame = npc.StateFrame + 1
            if npc.StateFrame > 15 then
                if mod.farFromAllPlayers(npc.Position, 60) then
                    d.state = "emerge"
                    npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
                    mod:spritePlay(sprite, "GutEmerge")
                    npc.Visible = true
                    if isDry then
                        local poofy = Isaac.Spawn(1000, 16, 2, npc.Position+Vector(0,10), Vector.Zero, npc):ToEffect()
                        poofy.SpriteScale = Vector(0.8, 0.8)
                        poofy.Color = mod.ColorGreyscale
                        if mod:RandomInt(1,2) == 1 then
                            poofy:GetSprite().FlipX = true
                        end
                        poofy:Update()
                        npc:PlaySound(SoundEffect.SOUND_BLACK_POOF, 0.6, 0, false, 1)
                    else
                        npc:PlaySound(mod.Sounds.SplashLargePlonkless,0.6,0,false,1.5)
                    end
                    npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                    d.hiding = nil
                end
            end
        end
    else
        if npc.Parent then
            if mod:IsReallyDead(npc.Parent) then
                d.HasTarget = nil
                npc.Parent = nil
            else
                if npc.Parent.Position:Distance(npc.Position) < 50 then
                    npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                else
                    npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                end
            end
        else
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        end

        if sprite:IsEventTriggered("Scootch") then
            if isDry then
                d.shootCounter = d.shootCounter - 1
            end
            if d.shootCounter and d.shootCounter <= 0 then
                sprite:Play("GutShoot")
                d.shootCounter = mod:RandomInt(3,6)
            else
                npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,0.2,0,false,1.4)
                local targetpos
                if npc:HasEntityFlags(EntityFlag.FLAG_CHARM) or npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
                    targetpos = npc:GetPlayerTarget().Position
                elseif npc.Parent then
                    if path:HasPathToPos(npc.Parent.Position, false) and not mod:isConfuse(npc) then
                        targetpos = mod:runIfFear(npc, npc.Parent.Position, nil, true)
                    else
                        targetpos = mod:runIfFear(npc, mod:FindRandomValidPathPosition(npc), nil, true)
                    end
                else
                    targetpos = mod:runIfFear(npc, mod:FindRandomValidPathPosition(npc), nil, true)
                end
                if game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) and npc.Position:Distance(targetpos) then
                    npc.Velocity = (targetpos - npc.Position):Resized(math.random(4,6))
                else
                    path:FindGridPath(targetpos, 5, 900, false)
                end
            end
        elseif sprite:IsEventTriggered("SFXSplat") then
            d.Landed = true
            if isDry then
                sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
            else
                npc:PlaySound(mod.Sounds.SplashSmall,3,0,false,1)
            end
        elseif sprite:IsEventTriggered("SFXSlurp") then
            --npc:PlaySound(mod.Sounds.Slurp,2.5,0,false,1.4)
        elseif sprite:IsEventTriggered("Shoot") then
            local params = ProjectileParams()
            params.Scale = 0.6
            npc:FireProjectiles(npc.Position, Vector(8,0), 7, params)
            local effect = Isaac.Spawn(1000,2,1,npc.Position,Vector.Zero,npc)
            effect.SpriteOffset = Vector(2,-10)
            effect.DepthOffset = npc.Position.Y * 1.25
            mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc, 1.2)
        end

        npc.Velocity = npc.Velocity * 0.9
        if d.Landed and npc.FrameCount % 5 == 1 then
            local blood = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc)
            blood.SpriteScale = Vector(0.6,0.6)
            blood:Update()
        end
    end
end

function mod:offalInit(npc)
    npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    npc:GetSprite():Play("GutEmerge",true)
    npc:AddEntityFlags(EntityFlag.FLAG_APPEAR)
end
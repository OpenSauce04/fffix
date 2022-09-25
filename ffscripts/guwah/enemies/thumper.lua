local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:ThumperAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    npc.Velocity = Vector.Zero
    mod.NegateKnockoutDrops(npc)
    mod.QuickSetEntityGridPath(npc)
    if not data.Init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc.StateFrame = mod:RandomInt(60,90,rng)
        data.Params = ProjectileParams()
        data.Params.Variant = 9
        data.state = "appear"
        mod:PlaySound(mod.Sounds.SqueakyRotate, npc, 1, 1.5)
        data.Init = true
    end
    if data.state == "appear" then
        if sprite:IsFinished("Appear") and npc.FrameCount > 0 then
            data.state = "idle"
            sfx:Stop(mod.Sounds.SqueakyRotate)
        else
            mod:spritePlay(sprite, "Appear")
        end
    elseif data.state == "idle" then
        if data.blinkin then
            if sprite:IsFinished("Blink") then
                data.blinkin = false
            else
                mod:spritePlay(sprite, "Blink")
            end
        else
            if sprite:IsEventTriggered("Blink") and mod:RandomInt(0,4,rng) == 0 then
                data.blinkin = true
            end
            mod:spritePlay(sprite, "Idle")
        end
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if not mod:AreThereAnyOthersInState(npc, "thump", true) then
                data.blinkin = false
                data.state = "thump"
            end
        end
    elseif data.state == "thump" then
        if sprite:IsFinished("Attack") then
            npc.StateFrame = mod:RandomInt(90,150,rng)
            data.state = "idle"
            sfx:Stop(mod.Sounds.SqueakyRotate)
        elseif sprite:IsEventTriggered("Shoot") then
            npc:FireProjectiles(npc.Position, Vector(10,0), 6, data.Params)
            mod.scheduleForUpdate(function()
				Isaac.Spawn(20, 0, 150, npc.Position, Vector.Zero, nil)
                sfx:Stop(SoundEffect.SOUND_FORESTBOSS_STOMPS)
			end, 0)
            for _, nubert in pairs(Isaac.FindByType(mod.FF.Nubert.ID, mod.FF.Nubert.Var, mod.FF.Nubert.Sub, false, false)) do
                nubert:GetData().popup = math.floor(npc.Position:Distance(nubert.Position)/25)
            end
            local poof = Isaac.Spawn(1000,16,1,npc.Position,Vector.Zero,npc)
            poof.SpriteScale = Vector(0.7,0.7)
            mod:PlaySound(mod.Sounds.DeepThump, npc, 1, 2)
            mod:PlaySound(SoundEffect.SOUND_STONE_IMPACT, npc)
        elseif sprite:IsEventTriggered("Screw") then
            mod:PlaySound(mod.Sounds.SqueakyRotate, npc, 1, 1.5)
        else
            mod:spritePlay(sprite, "Attack")
        end
    end
    if npc:IsDead() then
        local peg = Isaac.Spawn(mod.FF.ThumperPeg.ID, mod.FF.ThumperPeg.Var, mod.FF.ThumperPeg.Sub, npc.Position, Vector.Zero, npc)
        peg:GetSprite():Play("Peg")
    end
end

function mod:NubertAI(npc, sprite, data)
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    if not data.Init then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        data.Params = ProjectileParams()
        data.Params.Scale = 0.6
        data.state = "wander"
        npc.Visible = false
        data.Init = true
    end
    if data.state == "wander" then
        if data.targetpos then
            if npc.StateFrame <= 0 or data.targetpos:Distance(npc.Position) < 5 then
                data.targetpos = nil
            elseif npc.FrameCount > 15 then
                npc.StateFrame = npc.StateFrame - 1
                if room:CheckLine(npc.Position,data.targetpos,0,1,false,false) then
                    local targetvel = (data.targetpos - npc.Position):Resized(3)
                    npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.1)
                else
                    npc.Pathfinder:FindGridPath(data.targetpos, 0.5, 0, true)
                end
            end
        else
            data.targetpos = mod:FindRandomValidPathPosition(npc)
            npc.StateFrame = 90
        end
        if mod.GetEntityCount(mod.FF.Thumper.ID, mod.FF.Thumper.Var, 0) <= 0 then
            npc:Remove()
        else
            if npc.FrameCount % 6 == 0 then
                local dirtpile = Isaac.Spawn(1000, 146, 0, npc.Position, Vector.Zero, npc)
                dirtpile.SpriteScale = Vector(0.8,0.8)
            end
            if data.popup then
                data.popup = data.popup - 1
                if data.popup <= 0 then
                    data.state = "emerge"
                    mod:FlipSprite(sprite, npc.Position, targetpos)
                    npc.Visible = true
                end
            end
        end
    else
        npc.Velocity = Vector.Zero
        if data.state == "emerge" then
            if sprite:IsFinished("Emerge") then
                npc.StateFrame = 15
                data.state = "idle"
            elseif sprite:IsEventTriggered("Appear") then
                npc:PlaySound(SoundEffect.SOUND_SHOVEL_DIG,0.4,0,false,mod:RandomInt(150,170,rng)/100)
                npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR)
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            else
                mod:spritePlay(sprite, "Emerge")
            end
        elseif data.state == "idle" then
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                data.state = "shoot"
            else
                mod:spritePlay(sprite, "Idle")
            end
        elseif data.state == "shoot" then
            if sprite:IsFinished("Shoot") then
                data.state = "wander"
                data.popup = nil
                data.targetpos = nil
                npc.Visible = false
            elseif sprite:IsEventTriggered("Shoot") then
                mod:FlipSprite(sprite, npc.Position, targetpos)
                mod:PlaySound(SoundEffect.SOUND_LITTLE_SPIT, npc, mod:RandomInt(14,20,rng) * 0.1)
                npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(10), 0, data.Params)
                local effect = Isaac.Spawn(1000, 2, 1, npc.Position, Vector.Zero, npc):ToEffect()
                effect.SpriteOffset = Vector(0,-6)
                effect.DepthOffset = npc.Position.Y * 1.25
            elseif sprite:IsEventTriggered("Disappear") then
                npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR)
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            else
                mod:spritePlay(sprite, "Shoot")
            end
        end
    end
end
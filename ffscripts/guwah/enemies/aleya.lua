local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local function GetOuttaDaFire(npc, data)
    data.state = "leavefire"
    data.IsInFire = false
    data.suffix = "02"
    npc.Visible = true
    npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
    npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR)
    if npc.Child then
        npc.Child:GetData().aleyaclaimed = false
        npc.Child = nil
    end
end

function mod:AleyaAI(npc, sprite, data)
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    local rng = npc:GetDropRNG()
    if not data.Init then
        npc.SplatColor = mod.ColorMinMinFireJuicier
        npc.SpriteOffset = Vector(0,-10)
        npc.StateFrame = mod:RandomInt(45,90,rng)
        data.state = "appear"
        data.suffix = ""
        data.fireFilter = function (position, fire)
			if fire:ToNPC().State == 8 then
				return true
			end
		end
        local params = ProjectileParams()
        params.Variant = 4
        params.Color = mod.ColorMinMinFire
        params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
        data.Params = params
        data.Init = true
    end 
    if npc.Child then
        if npc.Child:ToNPC().State == 3 or mod:IsReallyDead(npc.Child) then
            GetOuttaDaFire(npc, data)
        else
            npc.Velocity = Vector.Zero
            npc.Position = npc.Child.Position + Vector(0,1)
        end
    elseif data.IsInFire and not npc.Child then
        GetOuttaDaFire(npc, data)
    end 
    if data.state == "appear" then
        if sprite:IsFinished("Appear") and npc.FrameCount > 0 then
            data.state = "wander"
            sprite:Play("Walk")
        else
            mod:spritePlay(sprite, "Appear")
        end
    elseif data.state == "wander" then
        local wander = true
        if data.findfire then
            if data.TargetFire and data.TargetFire:Exists() and data.TargetFire:ToNPC().State == 8 then
                wander = false
                if npc.Position:Distance(data.TargetFire.Position) < 5 then
                    npc.Velocity = Vector.Zero
                    npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                    mod:PlaySound(SoundEffect.SOUND_CANDLE_LIGHT, npc)
                    --npc.Child = data.TargetFire
                    data.TargetFire:GetData().aleyaclaimed = true
                    data.state = "enterfire"
                else
                    npc.TargetPosition = mod:confusePos(npc, data.TargetFire.Position)
                    npc.Velocity = mod:Lerp(npc.Velocity, (npc.TargetPosition - npc.Position):Resized(5), 0.05)
                end
            else
                data.TargetFire = mod:GetNearestThing(npc.Position, mod.FF.AleyaFirePlace.ID, mod.FF.AleyaFirePlace.Var, mod.FF.AleyaFirePlace.Sub, data.fireFilter)
            end
        end
        if wander then
            local vel
            if targetpos:Distance(npc.Position) < 100 or mod:isScare(npc) then
                vel = (npc.Position - targetpos):Resized(8)
            else
                if npc.FrameCount % 30 == 0 or npc.TargetPosition:Distance(npc.Position) < 10 then
                    npc.TargetPosition = mod:FindRandomFreePosAir(targetpos, 120)
                end
                vel = (npc.TargetPosition - npc.Position):Resized(3)
            end
            npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.05)
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                if not mod:AreThereAnyOthersInState(npc, "commandfires") then
                    data.state = "commandfires"
                end
            end
        end
        if targetpos:Distance(npc.Position) < 100 or mod:isScare(npc) then
            sprite:SetAnimation("Walk02", false)
        else
            sprite:SetAnimation("Walk", false)
        end
        mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
    elseif data.state == "commandfires" then
        npc.Velocity = npc.Velocity * 0.7
        if sprite:IsFinished("Shoot") then
            data.state = "wander"
            npc.StateFrame = mod:RandomInt(60,105,rng)
            data.findfire = true
            sprite:Play("Walk")
        elseif sprite:IsEventTriggered("Shoot") then
            for _, fire in pairs(Isaac.FindByType(33)) do --Convert extinguished fires of any type into Aleya Fires
                if fire.Variant < 10 then
                    fire = fire:ToNPC()
                    if fire.State == 3 then
                        if fire.SubType ~= mod.FF.AleyaFirePlace.Sub then
                            mod:ConvertToAleyaFire(fire)
                        end
                        local poof = Isaac.Spawn(1000,16,2,fire.Position - Vector(0,20),Vector.Zero,npc)
                        poof.SpriteScale = Vector(0.7,0.7)
                        poof.Color = mod.ColorMinMinFireJuicier
                    end
                end
            end
            local sorttable = {}
            for _, aleyafire in pairs(Isaac.FindByType(mod.FF.AleyaFirePlace.ID, mod.FF.AleyaFirePlace.Var, mod.FF.AleyaFirePlace.Sub)) do --Make them all shoot
                aleyafire = aleyafire:ToNPC()
                if aleyafire.State ~= 8 then --Re-ignite all extinguished Aleya fires
                    aleyafire.State = 8
                    aleyafire.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                    aleyafire.HitPoints = aleyafire.MaxHitPoints
                    aleyafire:GetData().deathinit = false
                    aleyafire:GetSprite():PlayOverlay("Shoot")
                end
                local dist = aleyafire.Position:Distance(targetpos)
                table.insert(sorttable, {aleyafire, dist})
                --[[aleyafire:GetSprite():PlayOverlay("Shoot")
                aleyafire:GetData().shootdelay = 15]]
            end
            table.sort(sorttable, function( a, b ) return a[2] < b[2] end )
            for i = 1, math.min(3, #sorttable) do
                local shootfire = sorttable[i][1]
                shootfire:GetData().shootdelay = 20 * i
            end
            mod:PlaySound(SoundEffect.SOUND_CANDLE_LIGHT, npc)
        else
            mod:spritePlay(sprite, "Shoot")
        end
    elseif data.state == "enterfire" then
        npc.Velocity = Vector.Zero
        if sprite:IsFinished("IntoFire") then
            data.state = "hidden"
            npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR)
            data.peekcount = mod:RandomInt(1,3,rng)
            npc.StateFrame = mod:RandomInt(5,15,rng)
            npc.SpriteOffset = Vector(0, -5)
            npc.Child = mod:GetAleyaFire(npc)
            data.TargetFire = nil
            data.IsInFire = true
        elseif sprite:IsEventTriggered("Disappear") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        else
            mod:spritePlay(sprite, "IntoFire")
        end
    elseif data.state == "hidden" then
        npc.Visible = false
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            npc.Visible = true
            data.state = "peekstart"
        end
    elseif data.state == "peekstart" then
        if sprite:IsFinished("AppearInFire") then
            npc.StateFrame = mod:RandomInt(20,30,rng)
            data.state = "peekidle"
        else
            mod:spritePlay(sprite, "AppearInFire")
        end
    elseif data.state == "peekidle" then
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if data.peekcount <= 0 then
                data.state = "peekshoot"
            else
                if npc.Child.HitPoints >= 4 and rng:RandomFloat() <= 0.5 then
                    data.state = "peekshoot"
                else
                    data.state = "peekleave"
                end
            end
        end
        mod:spritePlay(sprite, "Idle03")
    elseif data.state == "peekshoot" then
        if sprite:IsFinished("ShootFromFire") then
            data.state = "peekleave"
        elseif sprite:IsEventTriggered("Shoot") then
            mod:PlaySound(SoundEffect.SOUND_LITTLE_SPIT, npc)
            npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(12), 0, data.Params)
            local effect = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc):ToEffect()
            effect.SpriteOffset = Vector(0,-6)
            effect.DepthOffset = npc.Position.Y * 1.25
            effect.Color = mod.ColorMinMinFireJuicier
        else
            mod:spritePlay(sprite, "ShootFromFire")
        end
    elseif data.state == "peekleave" then
        if sprite:IsFinished("Disappear") then
            if data.peekcount <= 0 then
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR)
                npc.Child:GetData().aleyaclaimed = false
                npc.Child = nil
                mod:PlaySound(SoundEffect.SOUND_CANDLE_LIGHT, npc)
                data.state = "leavefire"
                data.IsInFire = false
            else
                data.peekcount = data.peekcount - 1
                npc.Visible = false
                npc.StateFrame = mod:RandomInt(5,15,rng)
                local doHigh = (data.peekcount <= 0)
                npc.Child = mod:GetAleyaFire(npc, doHigh)
                npc.Child:GetData().aleyaclaimed = true
                data.state = "hidden"
            end
        else
            mod:spritePlay(sprite, "Disappear")
        end
    elseif data.state == "leavefire" then
        npc.SpriteOffset = Vector(0, -10)
        npc.Velocity = npc.Velocity * 0.8
        if sprite:IsFinished("Return"..data.suffix) then
            data.state = "wander"
            data.findfire = false
            data.suffix = ""
            npc.StateFrame = mod:RandomInt(60,105,rng)
            sprite:Play("Walk")
        else
            mod:spritePlay(sprite, "Return"..data.suffix)
        end
    elseif data.state == "death" then
        npc.Velocity = Vector.Zero
        if sprite:IsFinished(data.anim) then
            if not mod:AreThereAnyOthers(npc) then
                for _, fire in pairs(Isaac.FindByType(mod.FF.AleyaFirePlace.ID, mod.FF.AleyaFirePlace.Var, mod.FF.AleyaFirePlace.Sub)) do
                    mod:ExtinguishAleyaFire(fire)
                end
            end
            npc:Kill()
        else
            mod:spritePlay(sprite, data.anim)
        end
    end
end

function FiendFolio.AleyaDeathAnim(npc)
    local anim = "Death"
    if npc.EntityCollisionClass == EntityCollisionClass.ENTCOLL_NONE then
        anim = "ReturnDeath"
    end
    local onCustomDeath = function(npc, deathAnim)
        mod:PlaySound(SoundEffect.SOUND_BEAST_FIRE_RING, npc, 1, 0.8)
        mod:PlaySound(SoundEffect.SOUND_STEAM_HALFSEC, npc, 1.2, 0.8)
        deathAnim.SplatColor = npc.SplatColor
        deathAnim.SpriteOffset = npc.SpriteOffset
        deathAnim:GetData().state = "death"
        deathAnim:GetData().anim = anim
        deathAnim:GetData().Init = true
    end
    FiendFolio.genericCustomDeathAnim(npc, anim, true, onCustomDeath)
end

function mod:AleyaColl(npc, collider, low)
    if collider.Type == 33 then
        return true
    end
end

function mod:AleyaRemove(npc)
    if npc.Child then
        npc.Child:GetData().aleyaclaimed = false
    end
end

function mod:ConvertToAleyaFire(fire)
    local anim = fire:GetSprite():GetAnimation()
    fire:GetData().AnimSuffix = mod.FireplaceAnimToSuffix[anim]
    fire:Morph(mod.FF.AleyaFirePlace.ID, mod.FF.AleyaFirePlace.Var, mod.FF.AleyaFirePlace.Sub, -1)
    fire:GetData().GuwahFunctions = mod:GetGuwahEnemyFunctions(fire)
    fire:GetData().IsAleyaFire = true
end

mod.FireplaceAnimToSuffix = {
    ["NoFire"] = "",
    ["NoFire2"] = "2",
    ["NoFire3"] = "3",
    ["Flickering"] = "",
    ["Flickering2"] = "2",
    ["Flickering3"] = "3",
    ["Dissapear"] = "",
    ["Dissapear2"] = "2",
    ["Dissapear3"] = "3",
    ["Idle"] = "",
    ["Idle2"] = "2",
    ["Idle3"] = "3",
}

function mod:GetAleyaFire(npc, pickHighHealth)
    local rng = npc:GetDropRNG()
    local data = npc:GetData()
    local choices = {}
    local choicesEX = {}
    for _, fire in pairs(Isaac.FindByType(mod.FF.AleyaFirePlace.ID, mod.FF.AleyaFirePlace.Var, mod.FF.AleyaFirePlace.Sub)) do
        local isValid = (fire:ToNPC().State == 8 and not fire:GetData().aleyaclaimed)
        if isValid and npc.Child then
            isValid = (fire.InitSeed ~= npc.Child.InitSeed)
        end
        if isValid then
            if pickHighHealth and fire.HitPoints >= 4 then
                table.insert(choicesEX, fire)
            else
                table.insert(choices, fire)
            end
        end
    end
    if npc.Child then
        npc.Child:GetData().aleyaclaimed = false
    end
    if data.TargetFire then
        data.TargetFire:GetData().aleyaclaimed = false
    end
    local choicefire 
    if pickHighHealth then
        choicefire = mod:GetRandomElem(choicesEX,rng)
    end
    if not choicefire then
        choicefire = mod:GetRandomElem(choices,rng)
    end
    if choicefire then
        return choicefire
    elseif data.TargetFire then
        return data.TargetFire
    else
        return npc.Child
    end
end

function mod:AreThereAnyOthers(npc, checkSub)
    local sub = -1
    if checkSub then
        sub = npc.SubType
    end
    for _, other in ipairs(Isaac.FindByType(npc.Type, npc.Variant, sub, false, true)) do
        if other:Exists() and other.InitSeed ~= npc.InitSeed then
            return true
        end
    end
    return false
end

function mod:AreThereAnyOthersInState(npc, state, checkSub)
    local sub = -1
    if checkSub then
        sub = npc.SubType
    end
    for _, other in ipairs(Isaac.FindByType(npc.Type, npc.Variant, sub, false, true)) do
        if other:Exists() and other.InitSeed ~= npc.InitSeed and (other:GetData().state == state or other:GetData().State == state) then
            return true
        end
    end
    return false
end
local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
    local sprite, d, player = fam:GetSprite(), fam:GetData(), fam.Player or Isaac.GetPlayer()
    if not d.init then
        d.state = "idle"
        d.init = true
        fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        fam.Size = 45
        if Sewn_API then
            Sewn_API:AddCrownOffset(fam, Vector(0, -60))
        end
    end

    fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS

    d.stateFrame = d.stateFrame or 0
    d.stateFrame = d.stateFrame + 1

    if d.state == "idle" then
        mod:spritePlay(sprite, "Idle")
        if d.stateFrame > 10 then
            local enemy = mod.FindClosestEnemy(fam.Position, 500, nil, nil, nil, nil, nil, true)
            local target
            if enemy then
                target = enemy
            else
                target = player
            end
            d.target = target
            if target.Type == 1 then
                if target.Position:Distance(fam.Position) >= 100 then
                    d.state = "jomp"
                end
            else
                d.state = "jomp"
            end
        end
    elseif d.state == "jomp" then
        if sprite:IsFinished("Jump") then
            d.state = "fall"
        elseif sprite:IsEventTriggered("Sound") then
            sfx:Play(SoundEffect.SOUND_MEAT_JUMPS,0.3,0,false,1.4)
            --sfx:Play(mod.Sounds.BingBingWahoo,0.05,0,false,1)
            d.jumping = true
        else
            mod:spritePlay(sprite, "Jump")
        end
    elseif d.state == "fall" then
        if sprite:IsFinished("Fall") then
            d.state = "idle"
            if player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) then
                d.stateFrame = 10
            else
                d.stateFrame = math.random(10)
            end
        elseif sprite:IsEventTriggered("Land") then
            sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS,0.3,0,false,1.4)
            local smoke = Isaac.Spawn(1000, 16, 1, fam.Position, nilvector, fam):ToEffect()
            smoke.SpriteScale = Vector(0.5, 0.5)
            smoke.Color = Color(1,1,1,0.2)
            smoke:FollowParent(fam)
            smoke:Update()
            --JOKE, don't readd this if you're from the future and reviving FF
            --[[mod.scheduleForUpdate(function()
				Isaac.Spawn(20, 0, 150, fam.Position, Vector.Zero, nil)
			end, 0)
            sfx:Play(SoundEffect.SOUND_SATAN_STOMP,1,0,false,1)
            game:ShakeScreen(10)]]
            d.jumping = nil
            d.justLanded = 2
            if Sewn_API then
                if Sewn_API:IsSuper(d, true) then
                    for i = 45, 360, 45 do
                        local tear = Isaac.Spawn(2, 0, 0, fam.Position, Vector(9, 0):Rotated(i), fam):ToTear()
                        if fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                            tear.Scale = 1.1
                            tear.CollisionDamage = 4
                        else
                            tear.Scale = 0.9
                            tear.CollisionDamage = 2
                        end
                        if fam.Player:HasTrinket(TrinketType.TRINKET_BABY_BENDER) then
                            tear.TearFlags = tear.TearFlags | TearFlags.TEAR_HOMING
                            tear:GetData().customtype = "makeyinyangorb"
                            tear:GetData().yinyangstrength = 0.02
                            tear.Color = FiendFolio.ColorPsy
                        end
                        tear:Update()
                    end
                end
            end
        else
            mod:spritePlay(sprite, "Fall")
        end
    else
        d.state = "idle"
    end

    if d.jumping and d.target then
        d.justLanded = nil
        fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        local targpos = d.target.Position
        local wimpVec = (targpos - fam.Position) / 2
        wimpVec = wimpVec:Resized(math.min(wimpVec:Length(), 30))
        fam.Velocity = mod:Lerp(fam.Velocity, wimpVec, 0.05)
    else
        if d.justLanded then
            fam.Size = 45
            d.justLanded = d.justLanded - 1
            if d.justLanded <= 0 then
                d.justLanded = nil
            end
            fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
        else
            fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        end
        fam.Velocity = fam.Velocity * 0.5
        fam.CollisionDamage = 5
        local room = game:GetRoom()
        if room:GetGridCollisionAtPos(fam.Position) > 0 then
            fam.SpriteOffset = Vector(0, -10)
        else
            fam.SpriteOffset = Vector(0, 0)
        end
    end
end, FamiliarVariant.WIMPY_BRO)
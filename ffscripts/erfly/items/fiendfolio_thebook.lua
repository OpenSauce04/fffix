local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero
local sfx = SFXManager()

local fiendFolioSubs = {
    0, 1, 3
}

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, ItemID, rng, player)
	sfx:Play(mod.Sounds.FiendFolioBook, 1, 0, false, 1)

    mod.scheduleForUpdate(function()
        local famsub = fiendFolioSubs[math.random(#fiendFolioSubs)]
        while famsub == player:GetData().lastFiendFolioBookSpawned do
            famsub = fiendFolioSubs[math.random(#fiendFolioSubs)]
        end
        if mod.GetEntityCount(mod.FF.Battie.ID, mod.FF.Battie.Var) > 0 then
            famsub = 0
        end
        --famsub = 1
        player:GetData().lastFiendFolioBookSpawned = famsub
        local fam = Isaac.Spawn(3, FamiliarVariant.FF_BOOK_HELPER, famsub, player.Position, nilvector, player)
        fam:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        fam:Update()
    end, 35)

    mod.FFGiantBook = game:GetFrameCount()
    mod.PauseGame(35)
    return true
end, mod.ITEM.COLLECTIBLE.FIEND_FOLIO)

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if mod.FFGiantBook then
        local sprite = Sprite()
        sprite:Load("gfx/ui/giantbook/giantbook_ff.anm2", true)
        sprite:SetFrame("Appear", game:GetFrameCount() - mod.FFGiantBook)
        sprite:Render(Vector(Isaac.GetScreenWidth()/2, Isaac.GetScreenHeight()/2), nilvector, nilvector)
        if (game:GetFrameCount() - mod.FFGiantBook) >= 35 then
            mod.FFGiantBook = false
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
    local player = fam.Player
	local d = fam:GetData()
	local sprite = fam:GetSprite()
    if fam.SubType == 0 then
        mod:famBattie(fam, player, sprite, d)
    elseif fam.SubType == 1 then
        mod:famMonsoon(fam, player, sprite, d)
    elseif fam.SubType == 3 then
        mod:famTechnopin(fam, player, sprite, d)
    elseif fam.SubType == 4 then
        mod:famBuster(fam, player, sprite, d)
    end
end, FamiliarVariant.FF_BOOK_HELPER)

function mod:famBattie(fam, player, sprite, d)
    local r = fam:GetDropRNG()
    local room = game:GetRoom()

	if not d.init then
		d.init = true
        mod:spritePlay(sprite, "Idle")
		fam.SpriteOffset = Vector(0, -25)
        d.state = "charge"
        d.slamattackcount = 0
		d.chargeattackcount = 0
        d.target = (mod.FindRandomEnemy(player.Position) or player)
        fam.Position = Vector(d.target.Position.X, -100)
        d.lerpness = 1
        fam.CollisionDamage = 10
        
	end

    if d.state == "charge" then
        --Initialise the charge, and set how many times she should charge
        if not d.chargestate then
            fam.Velocity = fam.Velocity * 0.85
            if sprite:IsFinished("ChargeStart") then
                mod:spritePlay(sprite, "Charge")
                d.chargestate = "go"
                fam:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                --Either 3 or 5 charges will occur
                d.maxcharges = 3 + r:RandomInt(3)
            else
                mod:spritePlay(sprite, "ChargeStart")
            end

        --Actually performing the charge
        elseif d.chargestate == "go" then
            mod:spritePlay(sprite, "Charge")
            
            if sprite:GetFrame() == 4 then
                sfx:Play(mod.Sounds.WingFlap,0.5,0,false,math.random(130,150)/100)
            end
            local add = Vector(0, 0)
            local homeStrength = 50
            
            d.target = d.target or (mod.FindRandomEnemy(player.Position) or player)
            local target = d.target

            homeStrength = (fam.Position.X - target.Position.X) / 10

            d.lerpness = d.lerpness or 1
            d.lerpness = mod:Lerp(d.lerpness, 0.03, 0.05)
            fam.Velocity = mod:Lerp(fam.Velocity, Vector((homeStrength * -1) / 3, 20), d.lerpness)
            --Move her to the top of the screen if she goes down far enough
            local chargecomplete
            if fam.Position.Y > (room:GetGridHeight() * 40) + 300 then
                d.chargecount = d.chargecount or 0
                d.chargecount = d.chargecount + 1
                if d.chargecount > 3 then
                    if fam.Position.Y > (room:GetGridHeight() * 40) + 500 then
                        d.chargestate = "slam"
                        fam.Position = (mod.FindRandomEnemy(player.Position) or player).Position
                        local batties = Isaac.FindByType(mod.FF.Battie.ID, mod.FF.Battie.Var, -1, false, false)
                        if #batties > 0 then
                            fam.Position = batties[1].Position
                        end
                        fam.Velocity = nilvector
                        mod:spritePlay(sprite, "FlyDown")
                        fam.SpriteOffset = Vector(0,-15)
                    end
                else
                    chargecomplete = true
                end
            end

            if chargecomplete then
                d.target = (mod.FindRandomEnemy(player.Position) or player)
                fam.Position = Vector(d.target.Position.X, -100)
                d.lerpness = 1
            end

            --The projectiles
            if fam.FrameCount % 2 == 0 then
                local tear = Isaac.Spawn(2, 1, 0, fam.Position, nilvector, fam):ToTear()
                tear.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                tear:Update()
                sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
            end
        elseif d.chargestate == "slam" then
            fam.Velocity = nilvector
            if sprite:IsFinished("FlyDown") then
                d.chargestate = "leave"
            --Called in the animation when she finally hits the ground
            elseif sprite:IsEventTriggered("SlamJam") then
                if game:GetRoom():GetType() == RoomType.ROOM_BOSS then
                    local batties = Isaac.FindByType(mod.FF.Battie.ID, mod.FF.Battie.Var, -1, false, false)
                    if #batties > 0 then
                        for _, batty in pairs(batties) do
                            if batty.Position:Distance(fam.Position) < 100 then
                                Isaac.Spawn(5, 100, mod.ITEM.COLLECTIBLE.BABY_BADGE, batty.Position, Vector.Zero, nil)
                                batty:Kill()
                                break
                            end
                        end
                    end
                end

                --Some effects to make it look cool
                game:ShakeScreen(15)
                sfx:Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND,0.6,2,false,1.7)

                --Crackwave
                local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, fam.Position, nilvector, player):ToEffect()
                wave.Parent = player
                wave.MaxRadius = 100

                --Projectiles
                local params = ProjectileParams()
                params.BulletFlags = params.BulletFlags | ProjectileFlags.BOOMERANG | ProjectileFlags.CURVE_LEFT
                for i = 45, 360, 45 do
                    --npc:FireProjectiles(npc.Position, Vector(0,10 * speedmulti):Rotated(i), 0, params)
                end
            else
                mod:spritePlay(sprite, "FlyDown")
            end
        elseif d.chargestate == "leave" then
            fam.SpriteOffset = mod:Lerp(fam.SpriteOffset, Vector(0, -125), 0.02)
            fam.Color = Color(fam.Color.R * 0.99,fam.Color.G * 0.99,fam.Color.B * 0.99,fam.Color.A * 0.99)
            if not d.dir then
                local wall = mod:GetClosestWall(fam.Position)
                d.dir = wall - fam.Position
            end
            mod:spritePlay(sprite, "Idle")
            if sprite:GetFrame() == 10 then
				--Flapcount determines rotation on velocity, so each flap is rotated by either -30 or 30 degrees
				--this is a dumb lazy way of doing it though.
				if d.flapcount == 0 then
					d.flapcount = 60
				else
					d.flapcount = 0
				end
				--Only updates her velocity in a flap every ten frames
				fam.Velocity = (d.dir):Resized(10):Rotated(-30 + d.flapcount)
                fam.Velocity = fam.Velocity * 0.9
				sfx:Play(mod.Sounds.WingFlap,0.5 * fam.Color.A,0,false,math.random(70,90)/100)
			end
            if fam.Color.A < 0.02 then
                fam:Remove()
            end
        end
    end
end

function mod:famMonsoon(fam, player, sprite, d)
    if not d.init then
        local targ = mod.FindClosestEnemy(fam.Position, 1250, true)
        if targ then
            fam.Position = targ.Position
        end
        d.state = "fallIntro"
        d.falling = true
        d.init = true
        d.falling = true
        d.fallheight = 600
        d.fallstop = 10
        fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    end

    fam.Velocity = fam.Velocity * 0.8

    if d.falling then
        d.fallheight = d.fallheight - 30
        if d.fallheight < d.fallstop + 1 then
            d.falling = false
            d.fallheight = 0
        end
        fam.SpriteOffset = Vector(0, -d.fallheight)
    end

    if d.state == "fallIntro" then
        mod:spritePlay(sprite, "FallLoop")
        if not d.falling then
            d.state = "Land"
            mod.scheduleForUpdate(function()
                Isaac.Spawn(20, 0, 150, fam.Position+Vector(0,-45), Vector.Zero, nil)
                sfx:Stop(SoundEffect.SOUND_FORESTBOSS_STOMPS)
            end, 0)
        end
    elseif d.state == "Land" then
        if sprite:IsFinished("FallEnd") then
            d.state = "monstroblast"
        elseif sprite:IsEventTriggered("Land") then
            fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            fam.CollisionDamage = 100
            mod.scheduleForUpdate(function()
                fam.CollisionDamage = 2
            end, 1)
            sfx:Play(mod.Sounds.LandSoft,1,0,false,0.7)
            sfx:Play(SoundEffect.SOUND_FORESTBOSS_STOMPS, 1, 0, false, 1.3)
            for i = 22.5, 360, 22.5 do
                local therand = -6 + math.random(10)
                local tear = Isaac.Spawn(2, 0, 0, fam.Position + Vector(0,20):Rotated(i + therand), Vector(0,10):Rotated(i + therand), fam):ToTear()
                tear.Height = -30
                tear.FallingAcceleration = 1.5 + math.random()
                tear.FallingSpeed = -15 - math.random(10)
                tear:Update()
            end
        else
            mod:spritePlay(sprite, "FallEnd")
        end
    elseif d.state == "monstroblast" then
        if sprite:IsFinished("Shoot") then
            d.state = "split"
            mod:spritePlay(sprite, "SplitApart")
            sprite:ReplaceSpritesheet(1, "gfx/nothing.png")
            sprite:LoadGraphics()
        elseif sprite:IsEventTriggered("Shoot") then
            local target = mod.FindClosestEnemy(fam.Position, 1250, true) or player
            if target.Position.X > fam.Position.X then
                sprite.FlipX = true
            else
                sprite.FlipX = false
            end
            sfx:Play(mod.Sounds.WateryBarf,1,0,false,1)
            local vec = ((target.Position) - (fam.Position)):Resized(8)
            for i = 1, 7 do
                local tear = Isaac.Spawn(2, 0, 0, fam.Position, vec + (RandomVector() * math.random() * 5.5), fam):ToTear()
                tear.FallingAcceleration = 1 + (math.random() * 0.5)
                tear.FallingSpeed = -10 - math.random(20)
                tear.Scale = mod.MoistroScales[math.random(3)]
            end
            for i = 1, 8 do
                local tear = Isaac.Spawn(2, 0, 0, fam.Position, vec + (RandomVector() * (0.5 + (math.random() * 0.5)) * 6.5),    fam):ToTear()
                tear.FallingAcceleration = 1 + (math.random() * 0.5)
                tear.FallingSpeed = -10 - math.random(20)
                tear.Scale = mod.MoistroWideScales[math.random(3)]
            end
        else
            mod:spritePlay(sprite, "Shoot")
        end
    elseif d.state == "split" then
        if sprite:IsFinished("SplitApart") then
            fam:Remove()
        elseif sprite:IsEventTriggered("Shudder") then
            sfx:Play(mod.Sounds.WateryBarf,1,0,false,0.8)
        elseif sprite:IsEventTriggered("Spawn") then
            sfx:Play(mod.Sounds.SplashLargePlonkless,1,0,false,1.3)
            local target = mod.FindClosestEnemy(fam.Position, 1250, true) or player
            local vec = (target.Position - fam.Position):Resized(12)
            local dribble = mod.spawnent(fam, fam.Position + vec, vec, mod.FF.Dribble.ID, mod.FF.Dribble.Var)
            dribble.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            mod:spritePlay(dribble:GetSprite(), "ChargeLoop")
            dribble.HitPoints = dribble.HitPoints * 0.6
            dribble:AddCharmed(EntityRef(player), -1)
            local ddat = dribble:GetData()
            ddat.state = "charge"
            ddat.charging = 1
            ddat.moist = true
            dribble:Update()
        else
            mod:spritePlay(sprite, "SplitApart")
        end
    end
end

function mod:famTechnopin(fam, player, sprite, d)
    if not d.init then
        d.attackCount = 0
        d.state = "attack"
        sprite:ReplaceSpritesheet(2, "gfx/bosses/champions/pin/boss_pin_techno_dirt.png")
        sprite:LoadGraphics()
        fam.Position = mod:FindRandomFreePos(fam)
        fam.TargetPosition = fam.Position
        d.init = true
    end

    if d.state == "attack" then
        if sprite:IsFinished("AttackFast") then
            mod:spritePlay(sprite, "HoleClose")
            d.state = "wait"
        elseif sprite:IsEventTriggered("Chargesound") then
            sfx:Play(mod.Sounds.EpicTwinkle,2,0,false,1.8)
        elseif sprite:IsEventTriggered("Attack") then
            local target = mod.FindClosestEnemy(fam.Position, 1250, true) or player
            local ang
            ang = (target.Position - Vector(8,-67) - fam.Position):GetAngleDegrees()
            local laser = EntityLaser.ShootAngle(2, fam.Position, ang, 10, nilvector, player)
            laser.DepthOffset = 500
            laser.Parent = fam
            laser.Position = fam.Position + Vector(8,-67)
            laser.DisableFollowParent = true
            laser.CollisionDamage = 25
            --laser:SetMaxDistance(500)
            laser:AddTearFlags(TearFlags.TEAR_BOUNCE)
            laser.OneHit = true
            laser:Update()
            d.attackCount = d.attackCount + 1
        else
            mod:spritePlay(sprite, "AttackFast")
        end
    elseif d.state == "wait" then
        if sprite:IsFinished("HoleClose") then
            fam.Visible = false
            if d.attackCount >= 4 or room:IsClear() then
                fam:Remove()
            else
                d.count = d.count or 0
                d.count = d.count + 1
                if math.random(5) == 1 then
                    fam.Visible = true
                    fam.Position = mod:FindRandomFreePos(fam)
                    fam.TargetPosition = fam.Position
                    d.state = "attack"
                    d.count = 0
                end
            end
        end
    end

    fam.Velocity = fam.TargetPosition - fam.Position
end

function mod:famBuster(fam, player, sprite, d)
    if not d.init then
        d.init = true
    end

end
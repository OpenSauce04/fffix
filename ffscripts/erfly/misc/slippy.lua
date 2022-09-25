local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function(_, item, rng, player, flags, slot)
    if flags == flags | UseFlag.USE_VOID then
        Game():Fart(player.Position, 80, player, 1, 0)
        for i = 45, 360, 45 do
            Game():Fart(player.Position + Vector(40, 0):Rotated(i), 80, player, 1, 0)
        end
        game:ButterBeanFart(player.Position, 280, player, false)
        sfx:Play(mod.Sounds.FartFrog4,1,0,false,math.random(90,110)/100)
        Game():ShakeScreen(50)
        sfx:Stop(SoundEffect.SOUND_FART)
    else
        local data = player:GetData()
        data.frogModeAction = slot < ActiveSlot.SLOT_POCKET and ButtonAction.ACTION_ITEM or ButtonAction.ACTION_PILLCARD
        data.canTrackFrogMode = true
    end
end, CollectibleType.COLLECTIBLE_FROG_HEAD)

local function shouldCtrlCancelFrogHead(player)
    local data = player:GetData()

    return (
        (data.frogModeAction == ButtonAction.ACTION_ITEM and player:HasCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG)) or
        (data.frogModeAction == ButtonAction.ACTION_PILLCARD and (
            player:GetActiveItem(ActiveSlot.SLOT_POCKET2) > 0 or
            player:GetCard(0) > 0 or
            player:GetPill(0) > 0
        ))
    )
end

function mod:frogmodeLogic()
	for i = 1, game:GetNumPlayers() do
		local p = Isaac.GetPlayer(i - 1)
		if p:HasCollectible(CollectibleType.COLLECTIBLE_FROG_HEAD) then
            local data = p:GetData()
            if shouldCtrlCancelFrogHead(p) and Input.IsActionPressed(ButtonAction.ACTION_DROP, p.ControllerIndex) then
                data.canTrackFrogMode = false
            end

            if data.canTrackFrogMode and Input.IsActionPressed(data.frogModeAction, p.ControllerIndex) and not p:GetSprite():IsPlaying("Death") then
                data.frogStop = true
            else
                data.canTrackFrogMode = false
                data.frogStop = false
            end
		end
	end
end

local blockedAnimations = {
    ["Appear"] = true,
    ["Death"] = true,
}

local goldenFrogHeadCostume = Isaac.GetCostumeIdByPath("gfx/characters/frogModeGold.anm2")

function mod:slippyPeffectUpdate(player, data)
    if player:GetPlayerType() == FiendFolio.PLAYER.SLIPPY then
        if mod:ShouldPlayerGetInitialised(player) then
            player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/frogMode.anm2"))
            player:AddCollectible(CollectibleType.COLLECTIBLE_FROG_HEAD,0,false)
        end
    end
end

function mod:slippyPlayerUpdate(player, data)
--Frog Mode
    local isSlippy
    local isBirthright
    if player:GetPlayerType() == FiendFolio.PLAYER.SLIPPY then
        isSlippy = true
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
            isBirthright = true
            if not data.SlippyHasBirthrightCostume then
                player:AddNullCostume(goldenFrogHeadCostume)
                player:SetColor(Color(1,1,1,1,1,1,1), 5, 10, true, false)
                data.SlippyHasBirthrightCostume = true
            end
        end
    end
    if isSlippy or player:HasCollectible(CollectibleType.COLLECTIBLE_FROG_HEAD) then
        local sprite = player:GetSprite()
        data.frogTimer = data.frogTimer or 0
        --print(player:GetSprite():GetAnimation(), player:IsExtraAnimationFinished())
        if data.frogStop or (isSlippy and ((not player.ControlsEnabled) or blockedAnimations[sprite:GetAnimation()])) then
            if player.ControlsEnabled then
                data.frogTimer = data.frogTimer + 1
            end
            if not isSlippy then
                if not data.hasFrogCostume then
                    player:SetColor(Color(1,1,1,1,1,1,1), 5, 10, true, false)
                    player:AddNullCostume(goldenFrogHeadCostume)
                    --Isaac.Spawn(1000, 15, 0, player.Position, nilvector, player)
                    data.hasFrogCostume = true
                end
            end

            if data.frogTimer > 150 then
                if data.frogTimer % 5 == 1 then
                    player:SetColor(Color(1,1,1,1,100 / 255,0,0),5,1,true,false)
                end
            elseif data.frogTimer > 80 then
                if data.frogTimer % 10 == 1 then
                    player:SetColor(Color(1,1,1,1,100 / 255,0,0),5,1,true,false)
                end
            elseif data.frogTimer > 30 then
                if data.frogTimer % 10 == 1 then
                    player:SetColor(Color(1,1,1,1,20 / 255,20 / 255,20 / 255),5,1,true,false)
                end
            end
            player.Velocity = nilvector
            if sprite:GetAnimation() == "Death" and sprite:GetFrame() > 15 and data.frogTimer > 150 then
                mod:explodePlayer(player)
                Game():Fart(player.Position, 80, player, 1, 0)
                for i = 45, 360, 45 do
                    Game():Fart(player.Position + Vector(40, 0):Rotated(i), 80, player, 1, 0)
                end
                game:ButterBeanFart(player.Position, 280, player, false)
                sfx:Play(mod.Sounds.FartFrog4,1,0,false,math.random(90,110)/100)
                Game():ShakeScreen(50)
                sfx:Stop(SoundEffect.SOUND_FART)
                data.frogTimer = 0
            end
        else
            if data.frogTimer and data.frogTimer > 0 then
                if data.frogTimer > 150 then
                    Game():Fart(player.Position, 80, player, 1, 0)
                    for i = 45, 360, 45 do
                        Game():Fart(player.Position + Vector(40, 0):Rotated(i), 80, player, 1, 0)
                        if isBirthright then
                            local gas = Isaac.Spawn(1000, 141, 0, player.Position + Vector(20, 0):Rotated(i), Vector(5, 0):Rotated(i), player):ToEffect()
                            gas.Timeout = 300
                        end
                    end
                    game:ButterBeanFart(player.Position, 280, player, false)
                    sfx:Play(mod.Sounds.FartFrog4,1,0,false,math.random(90,110)/100)
                    Game():ShakeScreen(50)
                    sfx:Stop(SoundEffect.SOUND_FART)
                    if isBirthright then
                        local gas = Isaac.Spawn(1000, 141, 0, player.Position, nilvector, player):ToEffect()
                        gas.Timeout = 300
                    end
                elseif data.frogTimer > 80 then
                    Game():Fart(player.Position, 80, player, 1, 0)
                    game:ButterBeanFart(player.Position, 280, player, false)
                    sfx:Play(mod.Sounds.FartFrog3,1,0,false,math.random(90,110)/100)
                    Game():ShakeScreen(10)
                    sfx:Stop(SoundEffect.SOUND_FART)
                    if isBirthright then
                        local vec = RandomVector()
                        for i = 120, 360, 120 do
                            local gas = Isaac.Spawn(1000, 141, 0, player.Position + Vector(10, 0):Rotated(i), Vector(2.5, 0):Rotated(i), player):ToEffect()
                            gas.Timeout = 150
                        end
                    end
                elseif data.frogTimer > 30 then
                    Game():ShakeScreen(5)
                    sfx:Play(mod.Sounds.FartFrog2,1,0,false,math.random(70,130)/100)
                    game:ButterBeanFart(player.Position, 280, player, true)
                    sfx:Stop(SoundEffect.SOUND_FART)
                    if isBirthright then
                        local gas = Isaac.Spawn(1000, 141, 0, player.Position, nilvector, player):ToEffect()
                        gas.Timeout = 60
                    end
                elseif data.frogTimer > 10 then
                    sfx:Play(mod.Sounds.FartFrog1,0.2,0,false,math.random(80,120)/100)
                    local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 960, player.Position, player.Velocity:Resized(-1), player):ToEffect();
                    local smokeCol = Color(1,1,1,1,100 / 255,100 / 255,100 / 255)
                    smokeCol:SetColorize(0.5,3,0.5,1)
                    smoke.Color = smokeCol
                    smoke.SpriteOffset = Vector(0,-10)
                    smoke.SpriteRotation = math.random(360)
                    smoke:Update()
                end
                data.frogTimer = 0
                if isSlippy then
                    player.Velocity = player:GetMovementVector():Normalized():Rotated(-90 + math.random(180))
                else
                    if data.hasFrogCostume then
                        player:TryRemoveNullCostume(goldenFrogHeadCostume)
                        player:SetColor(Color(1,1,1,1,1,1,1), 5, 10, true, false)
                        data.hasFrogCostume = false
                    end
                end
            end
        end
        if isSlippy or data.frogTimer > 0 then
            local venus = Isaac.FindByType(mod.FF.CacophobiaVenus.ID, mod.FF.CacophobiaVenus.Var)[1]
            if venus then
                if data.frogTimer > 0 then
                    player.Velocity = RandomVector()
                end
            else
                if flattening and flattening.modVersionNumber then
                    player.Velocity = player.Velocity:Resized(player.MoveSpeed * 4)
                    player.Velocity = mod:Lerp(player.Velocity, Vector(player.Velocity.X * theWidth, player.Velocity.Y * theHeight), 0.2)
                else
                    player.Velocity = player.Velocity:Resized(player.MoveSpeed * 4)
                end
                if player.Velocity:Length() == 0 then
                    player.Velocity = RandomVector()
                end
            end
        end
    end
end

function mod:slippyPlayerNewRoom(player, d, savedata)
    if player:GetPlayerType() == FiendFolio.PLAYER.SLIPPY or player:HasCollectible(CollectibleType.COLLECTIBLE_FROG_HEAD) then
        d.frogTimer = 1
    end
end

function mod:slippyPostFireTear(player, tear, rng, pdata, tdata, ignorePlayerEffects, isLudo)
	--Slippy's tear stuff
	if player:GetPlayerType() == FiendFolio.PLAYER.SLIPPY then
		mod:changeTearVariant(tear, TearVariant.FROG, TearVariant.FROG_BLOOD)
		if not (pdata.cannotFireMoreSlippyTears) and (not ignorePlayerEffects) and (not isLudo) then
			pdata.cannotFireMoreSlippyTears = true
            for i = -15, 15, 30 do
				local shotvel = tear.Velocity:Rotated(i - 5 + math.random(10))
				--local frogExtra = Isaac.Spawn(EntityType.ENTITY_TEAR, tear.Variant, 0, player.Position, shotvel, player):ToTear()
				local frogExtra = player:FireTear(tear.Position, shotvel, true, false, true, player, 0.8)
                frogExtra.Scale = tear.Scale * 0.9
                --[[frogExtra.FallingSpeed = tear.FallingSpeed
				frogExtra.Height = tear.Height
				frogExtra.FallingAcceleration = tear.FallingAcceleration
				frogExtra.TearFlags = tear.TearFlags
				frogExtra:GetSprite().Color = tear:GetSprite().Color
				frogExtra.CollisionDamage = tear.CollisionDamage * 0.8
				frogExtra.Parent = player
				frogExtra.Scale = tear.Scale * 0.9
				frogExtra:Update()]]
                mod.scheduleForUpdate(function()
                    frogExtra.Position = tear.Position
                end, 0)
			end
            pdata.cannotFireMoreSlippyTears = false
		end
	end
end

function mod:frogLocustAI(fam)
    local sprite = fam:GetSprite()
    fam.SpriteOffset = Vector(0, 6)
    sprite.PlaybackSpeed = fam.Velocity:Length() * 0.03
end
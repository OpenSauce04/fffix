local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local clutchCurseCostume = Isaac.GetCostumeIdByPath("gfx/characters/clutchs_curse.anm2")

local stackedShots = {
    [1] = {0,0,1},
    [2] = {-10,10,20},
    [3] = {-15,15,15},
    [4] = {-15,15,10},
    [5] = {-20,20,10},
    [6] = {-25,25,10},
    [7] = {-30,30,10},
}

function mod:clutchsCursePlayerUpdate(player, data)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.CLUTCHS_CURSE) then
        data.clutchsCursePurpleGutLumpTimer = data.clutchsCursePurpleGutLumpTimer or 240
        data.clutchsCursePurpleGutLumpTimer = data.clutchsCursePurpleGutLumpTimer - 1
        if data.clutchsCursePurpleGutLumpTimer <= 0 then
            if data.clutchsCursePurpleGutLump then
                if not data.clutchsCursePurpleGutLumpCostume then
                    player:AddNullCostume(clutchCurseCostume)
                    data.clutchsCursePurpleGutLumpCostume = true
                end
            end
        end
    elseif data.clutchsCursePurpleGutLumpTimer then
        data.clutchsCursePurpleGutLumpTimer = nil
        if data.clutchsCursePurpleGutLumpCostume then
            player:TryRemoveNullCostume(clutchCurseCostume)
            data.clutchsCursePurpleGutLumpCostume = nil
        end
    end

    if data.clutchsCursePurpleGutLump then
        player.FireDelay = player.MaxFireDelay
        local aim = player:GetAimDirection()
        if data.clutchsCursePurpleGutLumpTimer <= -20 then
            if mod:canUseDrawnItem(player, mod.DrawnItemTypes.ClutchsCurse, aim) then   
			    data.FFdrawnItemCooldown = player.MaxFireDelay
                local familiars = Isaac.FindInRadius(player.Position, 5, EntityPartition.FAMILIAR)
                local numClutches = 0
                local clutches = {}
                for _, familiar in ipairs(familiars) do
                    if familiar.Variant == mod.ITEM.FAMILIAR.CLUTCHS_CURSE and familiar:GetData().insidePlayer then
                        numClutches = numClutches + 1
                        table.insert(clutches, familiar)
                    end
                end
                numClutches = math.min(math.max(numClutches, 1), #stackedShots)
                local checkedClutches = 0
                for i = stackedShots[numClutches][1], stackedShots[numClutches][2], stackedShots[numClutches][3] do
                    checkedClutches = checkedClutches + 1
                    local vec = aim:Resized(10) + player:GetTearMovementInheritance(aim)
                    local tear = Isaac.Spawn(2, 5, 0, player.Position, vec:Rotated(i), player):ToTear()
                    tear.Scale = 1.5
                    tear.TearFlags = tear.TearFlags | TearFlags.TEAR_EXPLOSIVE | TearFlags.TEAR_HOMING
                    tear.CollisionDamage = math.max(25, player.Damage * 5)
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                        tear.CollisionDamage = tear.CollisionDamage * 2
                        tear.Scale = 2
                    end
                    if Sewn_API then
                        if clutches[checkedClutches] then
                            local data = clutches[checkedClutches]:GetData()
                            if Sewn_API:IsUltra(data) then
                                tear.TearFlags = tear.TearFlags | TearFlags.TEAR_HYDROBOUNCE | TearFlags.TEAR_QUADSPLIT
                            elseif Sewn_API:IsSuper(data) then
                                tear.TearFlags = tear.TearFlags | TearFlags.TEAR_QUADSPLIT
                            end
                        end
                    end
                    tear.FallingSpeed = -15
                    tear.FallingAcceleration = 0.5
                    tear.Color = FiendFolio.ColorDarkPurple
                end
                data.clutchsCursePurpleGutLump = nil
                if data.clutchsCursePurpleGutLumpTimer then
                    local rng = player:GetCollectibleRNG(mod.ITEM.COLLECTIBLE.CLUTCHS_CURSE)
                    data.clutchsCursePurpleGutLumpTimer = 600 + rng:RandomInt(601)
                    if player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) then
                        data.clutchsCursePurpleGutLumpTimer = math.floor(data.clutchsCursePurpleGutLumpTimer / 2)
                    end
                end
                if data.clutchsCursePurpleGutLumpCostume then
                    player:TryRemoveNullCostume(clutchCurseCostume)
                    data.clutchsCursePurpleGutLumpCostume = nil
                    player:SetColor(Color(1,1,1,1,1,1,1.5), 5, 5, true, false)
                end
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local d = fam:GetData()
	local sprite = fam:GetSprite()
	local isSirenCharmed, charmer = mod:isSirenCharmed(fam)
    local player = fam.Player
    local pdata = player:GetData()

    if not d.init then
        d.init = true
    end
    fam.SpriteOffset = Vector(0, -5)
    fam.DepthOffset = 0.1

    if not fam.Child or (fam.Child and not fam.Child:Exists()) then
        local tail = Isaac.Spawn(mod.FF.ClutchFamiliarTail.ID, mod.FF.ClutchFamiliarTail.Var, mod.FF.ClutchFamiliarTail.Sub, fam.Position, nilvector, fam):ToEffect()
        tail:FollowParent(fam)
        fam.Child = tail
    end

    if d.insidePlayer and not player:IsDead() then
        fam.Visible = false
        d.LeaveTimer = d.LeaveTimer or 0
        if pdata.clutchsCursePurpleGutLump then
            d.LeaveTimer = 0
        else
            d.LeaveTimer = d.LeaveTimer + 1
            if d.LeaveTimer > 10 then
                d.LeaveTimer = 90
                fam.Velocity = RandomVector() * 10
                d.insidePlayer = nil
            end
        end
    else
        fam.Visible = true
        d.insidePlayer = nil
        if d.LeaveTimer then
            d.LeaveTimer = d.LeaveTimer - 1
            if d.LeaveTimer <= 0 then
                d.LeaveTimer = nil
                d.playedEnterSwoosh = nil
                d.playedNaughtySmile = nil
            end
        end
    end

    local movement = "follow"
    local headOverride

    pdata.clutchsCursePurpleGutLumpTimer = pdata.clutchsCursePurpleGutLumpTimer or 240
    if pdata.clutchsCursePurpleGutLumpTimer <= 0 then
        headOverride = "Evil"
        movement = "enter"
        if not d.playedEnterSwoosh then
            sfx:Play(SoundEffect.SOUND_BEAST_GHOST_DASH, 0.3, 0, false, 1.2)
            sfx:Play(SoundEffect.SOUND_MONSTER_ROAR_0, 0.7, 0, false, math.random(150,180)/100)
            d.playedEnterSwoosh = true
        end
    elseif pdata.clutchsCursePurpleGutLumpTimer <= 120 then
        if not d.playedNaughtySmile then
            sfx:Play(SoundEffect.SOUND_MONSTER_GRUNT_4, 0.7, 0, false, 1.2)
            d.playedNaughtySmile = true
        end
        headOverride = "Evil"
    else

    end

    if d.insidePlayer then
        fam.Velocity = nilvector
        fam.Position = player.Position
    elseif player:IsDead() or d.LeaveTimer then
        if player:IsDead() or d.LeaveTimer > 30 then
            headOverride = "Laugh"
            if sprite:IsPlaying("FloatLaugh") then
                if sprite:GetFrame() == 1 or sprite:GetFrame() == 9 then
                    sfx:Play(mod.Sounds.AceVenturaLaughShort, 0.1, 0, false, math.random(130,150)/100)
                end
            end
        end
        fam.Velocity = fam.Velocity * 0.9
    elseif movement == "follow" then
        local targetpos = player.Position + (fam.Position - player.Position):Resized(50)
        if fam.Position:Distance(player.Position) > 50 then
            local targvec = (targetpos - fam.Position)
            local speedCap = 10
            if targvec:Length() > speedCap then
                targvec = targvec:Resized(speedCap)
            end
            fam.Velocity = mod:Lerp(fam.Velocity, targvec, 0.05)
        else
            fam.Velocity = fam.Velocity * 0.9
        end
    elseif movement == "enter" then
        local targvec = (player.Position - fam.Position)
        local speedCap = 20
        if targvec:Length() > speedCap then
            targvec = targvec:Resized(speedCap)
        end
        fam.Velocity = mod:Lerp(fam.Velocity, targvec, 0.3)
        if fam.Position:Distance(player.Position) < 10 then
            pdata.clutchsCursePurpleGutLump = true
            d.insidePlayer = true
            fam.Visible = false
            player:SetColor(Color(1,1,1,1,1,1,1.5), 5, 5, true, false)
            sfx:Play(SoundEffect.SOUND_PORTAL_SPAWN, 1, 0, false, 1.5)
            sfx:Play(SoundEffect.SOUND_VAMP_GULP, 0.3, 0, false, 0.8)
            sfx:Play(mod.Sounds.FishRoll, 1, 0, false, math.random(110,130)/100)
        end
    end

    if headOverride then
        mod:spritePlay(sprite, "Float" .. headOverride)
    else
        mod:spritePlay(sprite, "FloatDown")
    end
	
end, mod.ITEM.FAMILIAR.CLUTCHS_CURSE)

function mod:lilClutchTailAI(e)
    local sprite, d = e:GetSprite(), e:GetData()
    e.DepthOffset = 0
    if e.Parent then
        mod:spritePlay(sprite, "Body")
        local p = e.Parent
        e.Visible = p.Visible
        e.SpriteOffset = Vector(0, -14 + p.SpriteOffset.Y)
        if p.Velocity:Length() < 0.1 then
            if e.SpriteRotation > 180 then
                e.SpriteRotation = mod:Lerp(e.SpriteRotation, 360, 0.3)
            else
                e.SpriteRotation = mod:Lerp(e.SpriteRotation, 0, 0.3)
            end
        else
            e.SpriteRotation = p.Velocity:GetAngleDegrees() + 90
        end
    else
        e:Remove()
    end
end

local acceptableClutchRocks = {
    [GridEntityType.GRID_ROCK] = true,
    [GridEntityType.GRID_ROCKT] = true,
    [GridEntityType.GRID_ROCK_ALT] = true,
    [GridEntityType.GRID_ROCK_BOMB] = true,
    [GridEntityType.GRID_ROCK_SS] = true,
}

function mod.clutchsCurseNewRoom()
    mod.ClutchCurseRocks = {}
	if mod.anyPlayerHas(mod.ITEM.COLLECTIBLE.CLUTCHS_CURSE) then
        local room = game:GetRoom()
        local r = RNG()
		for i = 0, room:GetGridSize() do
			local g = room:GetGridEntity(i)
			local gt = g and g:GetType()
            if acceptableClutchRocks[gt] then
                r:SetSeed(g.Desc.SpawnSeed, 1)
                --print(g.Desc.SpawnSeed)
                if r:RandomInt(25) == 0 then
                    local destroyed = 0
                    if g.State ~= 1 then
                        destroyed = 1
                    end
                    table.insert(mod.ClutchCurseRocks, {Grid = g, State = destroyed})
                end
            end
        end
	end
end

function mod.clutchCurseRocks()
    if mod.ClutchCurseRocks and #mod.ClutchCurseRocks > 0 then
        local room = game:GetRoom()
        local redness = math.sin(room:GetFrameCount() / 10) / 10
        local blueness = math.cos(room:GetFrameCount() / 10) / 10
        for _, rock in pairs(mod.ClutchCurseRocks) do
            local grid = rock.Grid
            local sprite = grid:GetSprite()
            sprite.Color = Color(1,1,1,1,0.1 + redness,0,0.1 + blueness)
            --print(grid.State, rock.State)
            if grid.State ~= 1 and rock.State == 0 then
                rock.State = 1
                sfx:Play(SoundEffect.SOUND_FLAME_BURST, 1, 0, false, math.random(90,110)/100)
			    sfx:Play(SoundEffect.SOUND_FLAMETHROWER_END, 1, 0, false, math.random(90,110)/100)
                for i = 90, 360, 90 do
					local wave = Isaac.Spawn(1000, 148, 1, grid.Position, nilvector, Isaac.GetPlayer()):ToEffect()
					wave.Parent = Isaac.GetPlayer()
                    wave.Rotation = i
					wave:Update()
				end
            end
        end
    end
end
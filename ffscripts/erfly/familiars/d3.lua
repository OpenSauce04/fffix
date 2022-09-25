local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, fam)
    fam.OrbitDistance = Vector(50,50)
    fam.OrbitSpeed = 1
    fam.OrbitLayer = 2
    fam:RecalculateOrbitOffset(fam.OrbitLayer, true)
end, mod.ITEM.FAMILIAR.D3)

local customTearFlags = {
    "isRerolliganTear",
    "bloodDiamond",
    "IsFortuneTear",
    "BlackMoonInflicting",
    "HoneySlow",
    "isImpSodaTear",
    "YinYangOrb",
}

--Beautiful triangular tables (there has to be a better way to code something like this)
local d3tears = {
    10,
    9,9,
    8,8,8,
    7,7,7,7,
    6,6,6,6,6,
    5,5,5,5,5,5,
    4,4,4,4,4,4,4,
    3,3,3,3,3,3,3,3,
    2,2,2,2,2,2,2,2,2,
    1,1,1,1,1,1,1,1,1,1,
}

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
    local sprite = fam:GetSprite()
    local d = fam:GetData()
    local player = fam.Player
    local dist = 60 + (math.sin(fam.FrameCount / 5) * 15)
    fam.OrbitDistance = Vector(dist,dist)
    local targetPosition = fam:GetOrbitPosition(player.Position + player.Velocity)
    fam.Velocity = targetPosition - fam.Position
    fam.SpriteOffset = Vector(0,-2)
    fam.OrbitSpeed = -0.04

    --fam.Color = Color(1,1,1,0.3)

    for _, tear in ipairs(Isaac.FindInRadius(fam.Position, 15, EntityPartition.TEAR)) do
		tear = tear:ToTear()
        local td = tear:GetData()
        if not td.hasBeenD3Rolled then
            mod:changeToRandomTearVariant(tear, true)
            tear.Color = Color(math.random(200)/100, math.random(200)/100, math.random(200)/100, 1)
            local count = d3tears[math.random(#d3tears)]
            if tear.TearFlags == tear.TearFlags | mod:SetTearFlag(123) then
                count = 1
            end
            for i = 1, math.random(count) do
                if math.random(3) == 1 then
                    td[customTearFlags[math.random(#customTearFlags)]] = true
                else
                    tear.TearFlags = tear.TearFlags | mod:SetTearFlag(math.random(81))
                end
            end
            local randExtraDamage = math.random(50,150) / 100
            tear.CollisionDamage = tear.CollisionDamage * randExtraDamage
            tear.Scale = tear.Scale * randExtraDamage
            tear.Velocity = tear.Velocity * (math.random(10,150) / 100)
            td.hasBeenD3Rolled = true
        end
    end

    local bombs = Isaac.FindByType(EntityType.ENTITY_BOMBDROP)
	for _, bomb in ipairs(bombs) do
        bomb = bomb:ToBomb()
        if bomb.IsFetus then
            local bd = bomb:GetData()
            if not bd.hasBeenD3Rolled then
                if bomb.Position:Distance(fam.Position) < 15 then
                    for i = 1, d3tears[math.random(#d3tears)] do
                        bomb:AddTearFlags(mod:SetTearFlag(math.random(81)))
                    end
                    bomb.Velocity = bomb.Velocity * (math.random(10,150) / 100)
                    bomb.Color = Color(math.random(200)/100, math.random(200)/100, math.random(200)/100, 1)
                    bd.hasBeenD3Rolled = true
                end
            end
        end
    end

    --Laser Nonsense
    local lasers = Isaac.FindByType(EntityType.ENTITY_LASER)
	for _, laser in ipairs(lasers) do
        laser = laser:ToLaser()
        local ld = laser:GetData()
        if ld.rollColldown and ld.rollColldown > 0 then
            ld.rollColldown = ld.rollColldown - 1
            if ld.rollColldown <= 1 then
                ld.rollColldown = nil
            end
        elseif laser.SpawnerEntity and laser.SpawnerEntity.Type == 1 and (not (ld.hasBeenD3Rolled or laser.Variant == 7)) then
            local laserStart = laser.Position
            local laserEnd = laser:GetEndPoint()
            local laserVec = laserEnd - laserStart
            local d3Vec = fam.Position - laserStart
            --print(laser.PositionOffset)
            local successful
            if d3Vec:Length() < laserVec:Length() then
                local dotProd = laserVec:Normalized():Dot(d3Vec:Normalized())
                if dotProd > 0.99 then
                    successful = true
                end
            end
            if successful then
                ld.rollColldown = ld.rollColldown or 10
                if not ld.shortenedByD3 then
                    ld.shortenedByD3 = laser.MaxDistance
                    local randomVar = math.random(14)
                    if randomVar >=7 then
                        randomVar = randomVar + 1
                    end
                    local wackyLaser = EntityLaser.ShootAngle(randomVar, fam.Position, laserVec:GetAngleDegrees(), laser.Timeout, nilvector, fam):ToLaser()
                    wackyLaser.Timeout = math.max(laser.Timeout, 10)
                    wackyLaser.CollisionDamage = laser.CollisionDamage
                    wackyLaser.MaxDistance = laserVec:Length() - d3Vec:Length()
                    wackyLaser.TearFlags = laser.TearFlags
                    for i = 1, d3tears[math.random(#d3tears)] do
                        if math.random(3) == 1 then
                            wackyLaser:GetData()[customTearFlags[math.random(#customTearFlags)]] = true
                        else
                            wackyLaser.TearFlags = wackyLaser.TearFlags | mod:SetTearFlag(math.random(81))
                        end
                    end
                    local setColor
                    if math.random(3) == 1 then
                        if math.random(2) == 1 then
                            setColor = mod:tryMakeLaserSapphic(wackyLaser)
                        else
                            setColor = mod:tryMakeLaserTrans(wackyLaser)
                        end
                    end
                    local lascolor
                    if setColor then
                        if math.random(3) ~= 1 then
                            lascolor = Color(math.random(200)/100, math.random(200)/100, math.random(200)/100,1,0,0,0)
                        end
                    else
                        lascolor = Color(1,1,1,1,0,0,0)
                        lascolor:SetColorize(math.random(200)/100, math.random(200)/100, math.random(200)/100, 1)
                    end
                    if lascolor then
                        wackyLaser.Color = lascolor
                    end
                    wackyLaser:GetData().hasBeenD3Rolled = true
                    ld.trackedLaser = wackyLaser
                end
                if ld.trackedLaser then
                    local vec = (laserStart + laserVec:Resized(d3Vec:Length())) - fam.Position
                    ld.trackedLaser.PositionOffset = laser.PositionOffset + vec
                    ld.trackedLaser:Update()
                end
                laser.MaxDistance = d3Vec:Length()
                laser:Update()
            else
                if ld.shortenedByD3 then
                    laser.MaxDistance = ld.shortenedByD3
                    ld.shortenedByD3 = nil
                    laser:Update()
                    if ld.trackedLaser then
                        ld.trackedLaser.Timeout = math.min(ld.trackedLaser.Timeout, 10)
                        d.trackedLasers = d.trackedLasers or {}
                        table.insert(d.trackedLasers, ld.trackedLaser)
                        ld.trackedLaser = nil
                    end
                end
            end
        end
    end

    d.trackedLasers = d.trackedLasers or {}
    for _, laser in pairs(d.trackedLasers) do
        if laser:Exists() then
            laser.PositionOffset = mod:Lerp(laser.PositionOffset, Vector(0, -25), 0.15)
        end
    end

end, mod.ITEM.FAMILIAR.D3)
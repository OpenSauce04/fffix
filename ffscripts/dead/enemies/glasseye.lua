local mod = FiendFolio

local wackyCapture = true
local orbitDistance = 60
local orbitSpeedMulti = 1
local saturnusSprite = Sprite()
saturnusSprite:Load("gfx/enemies/glasseye/halo.anm2", true)
saturnusSprite:Play("Idle", true)

local game = Game()

local ignoreProjTypes = {
    ["Clergy"] = true,
    ["foeorbital"] = true
}

local removeProjTypes = {
    ["craterorbital"] = true,
    ["mutantorbital"] = true,
    ["dewdrop"] = true,
	["Psyker"] = true,
	["Occult"] = true,
}

function mod:glassEyeAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetAngle = (target.Position - npc.Position):GetAngleDegrees()
    local frameAngle = (targetAngle - 90)
    local frame = (frameAngle / 360) * 11
    frame = math.ceil(frame - 0.5)

    sprite:SetFrame("Rotate", frame % 12)

    local room = game:GetRoom()
    local index = room:GetGridIndex(npc.Position)
    if not data.Position then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_HIDE_HP_BAR | EntityFlag.FLAG_NO_TARGET)
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        data.Position = room:GetGridPosition(index)
    end

    if npc.FrameCount > 0 then
        if room:GetGridPath(index) < 3000 and not data.isSpecturned then
            room:SetGridPath(index, 3000)
        end
    end

    npc.Velocity = Vector.Zero
    if not data.isSpecturned then
        npc.Position = data.Position
    end

    if wackyCapture and not data.CapturedProjectiles then
        data.CapturedProjectiles = {}
    end

    local projectiles = Isaac.FindByType(EntityType.ENTITY_PROJECTILE)
    for _, proj in ipairs(projectiles) do
        local pdata = proj:GetData()
        if not wackyCapture then
            if proj.Position:DistanceSquared(npc.Position) < (proj.Size + npc.Size) ^ 2 then
                proj.Velocity = Vector.FromAngle(targetAngle) * proj.Velocity:Length()
                proj:ToProjectile().FallingAccel = -0.1
            end
        elseif not pdata.GlassEyeCaptured and proj.Position:DistanceSquared(npc.Position) < orbitDistance ^ 2 then
            local angle = (proj.Position - npc.Position):GetAngleDegrees()
            local travelAngle = proj.Velocity:GetAngleDegrees()
            local speed = proj.Velocity:Length()
            local clockwise = mod:AngleDifference(angle, travelAngle) < 0

            local ignore
            if pdata.projType then
                ignore = ignoreProjTypes[pdata.projType]
                if removeProjTypes[pdata.projType] then
                    pdata.projType = nil
                end
            elseif proj.Variant == ProjectileVariant.PROJECTILE_GRID and proj:ToProjectile():HasProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE) then -- kineti tractor beam
                ignore = true
            end

            if not ignore then
                data.CapturedProjectiles[#data.CapturedProjectiles + 1] = {
                    Projectile = proj,
                    Angle = angle,
                    Speed = speed,
                    CaptureTime = 0,
                    InitialFallAccel = proj:ToProjectile().FallingAccel,
                    Clockwise = (clockwise and 1) or -1
                }
                pdata.GlassEyeCaptured = true
				pdata.ShaggothCaptured = false
            end
        end
    end

    if wackyCapture then
        for i = #data.CapturedProjectiles, 1, -1 do
            local projData = data.CapturedProjectiles[i]
            local proj = projData.Projectile:ToProjectile()
            if not proj:Exists() or proj:IsDead() then
                table.remove(data.CapturedProjectiles, i)
            else
                proj.FallingAccel = -0.1
                proj.Height = mod:Lerp(proj.Height, -20, 0.1)
                proj:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)

                if projData.Speed < 7 then
                    projData.Speed = mod:Lerp(projData.Speed, 7, 0.1)
                end

                local angleAdd = projData.Speed * orbitSpeedMulti
                projData.Angle = projData.Angle + (angleAdd * projData.Clockwise)

                local targetPos = npc.Position + Vector.FromAngle(projData.Angle) * 60
                projData.CaptureTime = math.min(10, projData.CaptureTime + 1)
                proj.Velocity = mod:Lerp(proj.Velocity, targetPos - proj.Position, projData.CaptureTime / 10)


                projData.Angle = ((proj.Position + proj.Velocity) - npc.Position):GetAngleDegrees()

                local toTarget = (target.Position - proj.Position):GetAngleDegrees()
                if math.abs(mod:AngleDifference(toTarget, proj.Velocity:GetAngleDegrees())) < 10 then
                    local ffFlags = mod:getCustomProjectileFlags(proj)
                    ffFlags.RemoveSpectralIfFree = true

                    proj.FallingAccel = math.min(projData.InitialFallAccel, 0)
                    proj.Velocity = proj.Velocity:Resized(projData.Speed)
                    table.remove(data.CapturedProjectiles, i)
                end
            end
        end
    end
end

function mod:updateGlassEyeSprites()
    saturnusSprite:Update()
end

function mod:glassEyeRender(npc)
    local rpos = Isaac.WorldToScreen(npc.Position)
    local rscale = (orbitDistance / 100) * Vector.One
    saturnusSprite.Scale = rscale
    saturnusSprite.Offset = Vector(0, -8)
    saturnusSprite:Render(rpos, Vector.Zero, Vector.Zero)
end

function mod:glassEyeRemove(npc)
    local room = game:GetRoom()
    local index = room:GetGridIndex(npc.Position)
    local grid = room:GetGridEntity(index)
    if not grid then
        if room:GetGridPath(index) == 3000 then
            room:SetGridPath(index, 0)
        end
    end
end

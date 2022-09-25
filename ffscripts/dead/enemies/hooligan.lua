local mod = FiendFolio
local game = Game()

FiendFolio.HooliganBlacklist = {
    {13, 0, 250}, --Soundmaker Fly
    {96},			--Eternal Fly
    {EntityType.ENTITY_FROZEN_ENEMY}, --Uranus Frozen Enemy
    FiendFolio.ENT("GorgerAss"),	--Gorger ass
    FiendFolio.ENT("Cortex"),		--Cortex
    FiendFolio.ENT("PsiKnight"),	--Psionic Knight Husk
    FiendFolio.ENT("ToxicKnight"),	--Toxic Knight Husk
    FiendFolio.ENT("DeadFlyOrbital"),		--Eternal Fly reimplementation
    FiendFolio.ENT("Harletwin"),		--Harletwin
    FiendFolio.ENT("Effigy"),		--Effigy
    FiendFolio.ENT("BolaHead"),	--Bola Skull
    FiendFolio.ENT("BolaNeck"),	--Bola Neck
    FiendFolio.ENT("FingoreHand"),	--Fingore Hand
    FiendFolio.ENT("Cuffs"), -- Cuffs
}

FiendFolio.HooliganWhitelist = {
    FiendFolio.ENT("EternalFlickerspirit"),
    FiendFolio.ENT("Viscerspirit")
}

local function compareEnt(list, etype, evar, esub)
    for _, v in ipairs(list) do
        if v[3] then if etype == v[1] and evar == v[2] and esub == v[3] then return true end
        elseif v[2] then if etype == v[1] and evar == v[2] then return true end
        elseif etype == v[1] then return true end
    end

    return false
end

function mod:getHooliganTargets(npc, numTargets, ignoreEnts)
    ignoreEnts = ignoreEnts or {}
    ignoreEnts[GetPtrHash(npc)] = true

    local validEntities = {}
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if (entity:ToPickup() or entity:ToBomb() or entity.Type == EntityType.ENTITY_SLOT or (entity:IsActiveEnemy() and not mod:isFriend(entity))) and not ignoreEnts[GetPtrHash(entity)] then
            local etype = entity.Type
            local evar = entity.Variant
            local esub = entity.SubType
            local goodent = compareEnt(mod.HooliganWhitelist, entity.Type, entity.Variant, entity.SubType)
            local badent = false
            if not goodent then
                badent = compareEnt(mod.HooliganBlacklist, entity.Type, entity.Variant, entity.SubType) or compareEnt(mod.HidingUnderwaterEnts, entity.Type, entity.Variant, entity.SubType)
            end

            local isHooligan
            if entity.Type == FiendFolio.FF.Hooligan.ID and entity.Variant == FiendFolio.FF.Hooligan.Var then
                isHooligan = true
                badent = FiendFolio.GetBits(entity.SubType, 0, 1) ~= 1
            end

            if not badent then
                local dist = entity.Position:DistanceSquared(npc.Position)
                local ind
                for i, ent in ipairs(validEntities) do
                    if dist < ent.Distance then
                        ind = i
                        break
                    end
                end

                table.insert(validEntities, ind or #validEntities + 1, {Entity = entity, Distance = dist, IsHooligan = isHooligan})
            end
        end
    end

    local targets = {}
    for i, ent in ipairs(validEntities) do
        local entData = validEntities[i]
        if entData and entData.Entity:Exists() then
            ignoreEnts[GetPtrHash(entData.Entity)] = true
            if entData.IsHooligan then
                mod:ensureHooliganInitialized(entData.Entity:ToNPC(), ignoreEnts)
            end

            targets[#targets + 1] = entData.Entity
        end

        if #targets == numTargets then
            break
        end
    end

    return targets
end

local function playIfNoAnim(sprite, anim)
    if sprite:GetAnimation() == "" then
        sprite:Play(anim, true)
    end
end

local function animExists(sprite, anim)
    local curAnim, frame, isPlaying = sprite:GetAnimation(), sprite:GetFrame(), sprite:IsPlaying()
    sprite:Play(anim, true)
    local exists = sprite:GetAnimation() == anim

    if isPlaying then
        sprite:Play(curAnim, true)
        sprite:SetFrame(frame)
    else
        sprite:SetFrame(curAnim, frame)
    end

    return exists
end

function mod:ensureHooliganInitialized(npc, ignoreEnts)
    local data = npc:GetData()
    if not data.SpawnEntities then
        local numTargets = FiendFolio.GetBits(npc.SubType, 1, 4) + 1
        data.SpawnEntities = {}
        local targets = mod:getHooliganTargets(npc, numTargets, ignoreEnts)
        --print(#targets)
        for _, ent in ipairs(targets) do
            local sprite = ent:GetSprite()

            if sprite:GetAnimation() == "Empty" then -- weaver-type
                sprite:Play("HeadDown2", true)
            end

            playIfNoAnim(sprite, "Appear")
            playIfNoAnim(sprite, "Idle")

            if animExists(sprite, "DigOut2") then -- mole
                sprite:Play("DigOut", true)
                sprite:SetLastFrame()
            end
            
            if sprite:GetAnimation() == "Appear" then
                sprite:SetLastFrame()
            end
            
            local anim, frame, overlay, overlayframe, filename = sprite:GetAnimation(), sprite:GetFrame(), sprite:GetOverlayAnimation(), sprite:GetOverlayFrame(), sprite:GetFilename()

            local newSprite = Sprite()
            newSprite:Load(filename, true)
            newSprite:SetFrame(anim, frame)
            newSprite:SetOverlayFrame(overlay, overlayframe)
            newSprite.Scale = Vector(0.5, 0.5)

            data.SpawnEntities[#data.SpawnEntities + 1] = {
                Type = ent.Type,
                Variant = ent.Variant,
                SubType = ent.SubType,
                SpawnEntities = ent:GetData().SpawnEntities,
                Sprite = newSprite
            }
            ent:Remove()
        end
    end
end

function mod:allTopLevelHooligansInitialized()
    local hooligans = Isaac.FindByType(FiendFolio.FF.Hooligan.ID, FiendFolio.FF.Hooligan.Var, -1, false, false)
    for _, hooligan in ipairs(hooligans) do
        if FiendFolio.GetBits(hooligan.SubType, 0, 1) == 0 and not hooligan:GetData().SpawnEntities then
            return false
        end
    end

    return true
end

function mod:hooliganAI(npc, sprite, data)
    if not data.Init then
        data.Init = true
        data.State = "Move"
    end

    if not data.SpawnEntities then
        if FiendFolio.GetBits(npc.SubType, 0, 1) == 0 or mod:allTopLevelHooligansInitialized() then
            mod:ensureHooliganInitialized(npc)
        end
    end

    data.UseFFPlayerMap = true

    if data.State == "Move" then
        sprite:PlayOverlay("Walk")
        if npc.Velocity:Length() > 1 then
            npc:AnimWalkFrame("WalkHori","WalkVert",0)
            sprite.FlipX = npc.Velocity.X < 0
        else
            sprite:SetFrame("WalkVert", 0)
        end

        local room = game:GetRoom()
        local index = room:GetGridIndex(npc.Position)
        if room:GetGridPath(index) < 900 then
            room:SetGridPath(index, 900)
        end

        if data.Path then
            FiendFolio.FollowPath(npc, 0.8, data.Path, true, 0.85, 500)
        else
            npc.Velocity = npc.Velocity * 0.85
        end

        local explode
        for i = 1, game:GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            if player.Position:DistanceSquared(npc.Position) < 80 ^ 2 then
                explode = true
                break
            end
        end

        if explode and npc.FrameCount > 1 then
            data.State = "Explode"
            sprite:SetFrame("WalkVert", 0)
            sprite:PlayOverlay("Explode", true)
        end
    elseif data.State == "Explode" then
        if sprite:IsOverlayFinished("Explode") then
            if data.SpawnEntities then
                for _, ent in ipairs(data.SpawnEntities) do
                    local vel = Vector.Zero
                    if #data.SpawnEntities > 1 then
                        vel = RandomVector() * 2
                    end

                    local spawn = Isaac.Spawn(ent.Type, ent.Variant, ent.SubType, npc.Position + vel, vel, npc)
                    if ent.SpawnEntities then
                        spawn:GetData().SpawnEntities = ent.SpawnEntities
                    end
                end
            end

            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, npc.Position, Vector.Zero, npc)
            npc:Kill()
        end

        npc.Velocity = npc.Velocity * 0.75
    end
end

local function anyPlayerGuppyEye()
    for i = 0, game:GetNumPlayers() - 1 do
        if Isaac.GetPlayer(i):HasCollectible(CollectibleType.COLLECTIBLE_GUPPYS_EYE) then
            return true
        end
    end

    return false
end

function mod:hooliganRender(npc, sprite, data)
    if data.SpawnEntities and anyPlayerGuppyEye() then
        local npcPos = game:GetRoom():WorldToScreenPosition(npc.Position)
        local entityCount = #data.SpawnEntities
        local minRotation, maxRotation = -90, 90
        local minXOff, maxXOff = -13, 13
        if entityCount == 1 then
            minRotation, maxRotation = 0, 0
            minXOff, maxXOff = 0, 0
        elseif entityCount == 2 then
            minRotation, maxRotation = -45, 45
            minXOff, maxXOff = -9, 9
        end

        for i, entity in ipairs(data.SpawnEntities) do
            if entity.Sprite then
                local percent
                if entityCount == 1 then
                    percent = 1
                else
                    percent = (i - 1) / (entityCount - 1)
                end

                local xOff = mod:Lerp(minXOff, maxXOff, percent)

                local rotation = mod:Lerp(minRotation, maxRotation, percent)
                entity.Sprite:Render(npcPos + Vector(xOff, -18 + Vector(0, -3):Rotated(rotation).Y), Vector.Zero, Vector.Zero)
            end
        end
    end
end
local scripts = {
    enemies = {
        "organization",
        "morvid",
        "hooligan",
        "glasseye",
        "tagbag",
        "sleeper",
        "foe", -- has a different id

        "cacophobia",
    },

    -- grids
    grids = {
        "rubberrock",
        "cursedpoop",
        "platinumpoop",
        "petrifiedpoop",
        "poisonpoop",
        "bulbrock",
        "goldenrewardplate",
        "soottag",
    },

    -- technical
    "membercardrelocator",

    -- items
    "eternalcarbattery",
    "empty_book",

    -- characters
    "fiend_b_skin_legitimate",

    -- the gauntlet
    "thegauntlet",
}

local function loadScripts()
    local toLoad = {}
    for k, v in pairs(scripts) do
        if type(v) == "table" then
            for _, v2 in ipairs(v) do
                toLoad[#toLoad + 1] = "ffscripts.dead." .. k .. "." .. v2
            end
        else
            toLoad[#toLoad + 1] = "ffscripts.dead." .. v
        end
    end

    FiendFolio.LoadScripts(toLoad)
end

loadScripts()

function FiendFolio.FillBits(numBits)
    return (1 << numBits) - 1
end

function FiendFolio.GetBits(number, startBit, numBits)
    number = number >> startBit
    number = number & FiendFolio.FillBits(numBits)
    return number
end

-- Run Dead AI
local mod = FiendFolio
local game = Game()
function mod:check130(npc)
    local sprite = npc:GetSprite()
	local data = npc:GetData()
	local variant = npc.Variant

    if variant == mod.FF.Magleech.Var then
        mod:magleechAI(npc, sprite, data)
    elseif variant == mod.FF.Myiasis.Var then
        mod:blubberAI(npc, sprite, data)
    elseif variant == mod.FF.MyiasisProj.Var then
        mod:blubberProjectileAI(npc, sprite, data)
    elseif variant == mod.FF.Viscerspirit.Var then
        mod:viscerspiritAI(npc, sprite, data)
    elseif variant == mod.FF.Morvid.Var then
        mod:morvidAI(npc, sprite, data)
    elseif variant == mod.FF.Hooligan.Var then
        mod:hooliganAI(npc, sprite, data)
    elseif variant == mod.FF.GlassEye.Var then
        mod:glassEyeAI(npc, sprite, data)
    elseif variant == mod.FF.Tagbag.Var then
        mod:tagbagAI(npc, sprite, data)
    elseif variant == mod.FF.Sleeper.Var then
        mod:sleeperAI(npc, sprite, data)
    elseif variant == mod.FF.NightTerrors.Var then
        mod:nightTerrorsAI(npc, sprite, data)
    end
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.check130, mod.FFID.Dead)

function mod:render130(npc)
    local sprite = npc:GetSprite()
	local data = npc:GetData()
	local variant = npc.Variant

    if variant == mod.FF.Morvid.Var then
        mod:morvidRender(npc, sprite, data)
    elseif variant == mod.FF.GlassEye.Var then
        mod:glassEyeRender(npc, sprite, data)
    elseif variant == mod.FF.NightTerrors.Var then
        mod:nightTerrorsRender(npc, sprite, data)
    elseif variant == mod.FF.Hooligan.Var then
        mod:hooliganRender(npc, sprite, data)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, mod.render130, mod.FFID.Dead)

function mod:remove130(npc)
    npc = npc:ToNPC()
    local variant = npc.Variant

    local room = game:GetRoom()
    if room:GetFrameCount() > 0 then -- only count in-room removals
        if variant == mod.FF.GlassEye.Var then
            mod:glassEyeRemove(npc)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, mod.remove130, mod.FFID.Dead)

function mod:check130Kill(npc)
    npc = npc:ToNPC()
    local data = npc:GetData()
    local variant = npc.Variant


end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mod.check130Kill, mod.FFID.Dead)

function mod:check130Hurt(npc, damage, flags, source, iframes)
    npc = npc:ToNPC()
    local sprite = npc:GetSprite()
    local data = npc:GetData()
    local variant = npc.Variant

    if variant == mod.FF.Sleeper.Var then
        return mod:sleeperHurt(npc, sprite, data, damage, flags, source, iframes)
    elseif variant == mod.FF.GlassEye.Var then
        return mod:IgnoreDamage(npc, damage, flags, source)
    end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.check130Hurt, mod.FFID.Dead)

function mod:deadGenericUpdate()
    mod:updateGlassEyeSprites()
    mod:checkCacophobiaFrozen()
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.deadGenericUpdate)

function mod:deadGenericRender()
    mod:cacophobiaRoomRender()
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.deadGenericRender)

function mod:getCustomProjectileFlags(proj, data, noCreateIfMissing)
    data = data or proj:GetData()
    if not noCreateIfMissing and not data.ffProjFlags then
        data.ffProjFlags = {}
    end

    return data.ffProjFlags
end

function mod:projectileFlags(proj, data)
    if data.CacophobiaProjectile then
        mod:cacophobiaProjectileAI(proj, data)
    end
    
    local flags = mod:getCustomProjectileFlags(proj, data, true)
    if flags then
        if flags.MatchRotation then
            proj.SpriteRotation = proj.Velocity:GetAngleDegrees() + (data.ffProjRotationOffset or 0)
        end

        if flags.RemoveSpectralIfFree then
            local room = game:GetRoom()
            local collision = room:GetGridCollisionAtPos(proj.Position)
            if collision == GridCollisionClass.COLLISION_NONE or collision == GridCollisionClass.COLLISION_PIT then
                proj:ClearProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
                flags.RemoveSpectralIfFree = false
            end
        end
    end
end

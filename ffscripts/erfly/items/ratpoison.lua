local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero
local sfx = SFXManager()

local roomMakerNames = {
    --FF Devs
    "al",
    "blorenge",
    "bub",
    "budj",
    "cake",
    "ciiru",
    "com",
    "cornmunity",
    "creeps",
    "dead",
    "erfly",
    "ferrium",
    "guillotine-21",
    "gummy",
    "guwah",
    "happyhead",
    "jm2k",
    "jon",
    "maria",
    "mini",
    "peas",
    "pixelo",
    "pkpseudo",
    "ren",
    "sin",
    "snake",
    "sunil_b",
    "taiga",
    "vermin",
    "xalum",
    --Deliverance
    "fly",
    "jubba",
    --Ipecac
    "arai",
    "pedroff_1",
    "spearkiller",
    "strvn",
    "wtp",
    --CRR
    "dragon",
    --MODs with a significant or complete lack of creator-based room names
    "rev",
    "[deliverance]",
    "[godmode]",
    "megamixedrooms",
    "(ah)",
    --Spite towards Sylvan_Night's future room mod cause funni
    "sylvannight",
    --Give erfly a shout on discord if you want to incorporate your mods to this btw!
}

local roomMakerSynonyms = {
    {"maria", "tom clancy"},
    {"maria", "amy"},
    {"guwah", "inspector"},
    {"blorenge", "blor"},
}

function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end

local function getFFRoomName()
    local roomDescriptorData = game:GetLevel():GetCurrentRoomDesc().Data
    local text
    local currentRoom = StageAPI.GetCurrentRoom()
    if currentRoom and currentRoom.Layout then
        text = currentRoom.Layout.Name
    else
        local useVar = roomDescriptorData.Variant
        --print(useVar)
        if useVar >= 17000 and useVar <= 20000 then
            text = roomDescriptorData.Name
        end
    end
    if text then
        text = string.lower(text)
        if string.starts(text, "(s)") then
            text = string.sub(text, 5)
        else
            --Clears out strings like (12) or (1) for shared rooms / bosses
            if string.starts(text, "(") then
                text = string.sub(text, 2)
            end
            for i = 1, 3 do
                if text:find("%d") then
                    text = string.sub(text, 2)
                end
            end
            if string.starts(text, ")") then
                text = string.sub(text, 3)
            end
        end
        print(text)
        --compat
        if string.starts(text, "[Deliverance]") then
            text = string.sub(text, 15)
        end
        if string.starts(text, "IPECAC -") then
            text = string.sub(text, 10)
        end
        for i = 1, #roomMakerSynonyms do
            if string.starts(text, roomMakerSynonyms[i][2]) then
                text = roomMakerSynonyms[i][1]
            end
        end
        return text
    end
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, ItemID, rng, player, useFlags, activeSlot)
    local text = getFFRoomName()
    local successful
    if text then
        for i = 1, #roomMakerNames do
            if string.starts(text, roomMakerNames[i]) then
                local saveData = FiendFolio.savedata.run
                saveData.RatPoison = saveData.RatPoison or {}
                table.insert(saveData.RatPoison, roomMakerNames[i])
                mod:skipCardRoom()
                saveData.level.SkippedRooms = saveData.level.SkippedRooms or {}
                saveData.level.SkippedRooms[tostring(game:GetRoom():GetDecorationSeed())] = true
                successful = true
                if roomMakerNames[i] == "vermin" then
                    local pos = game:GetRoom():GetCenterPos()
                    local verm = Isaac.Spawn(1000, mod.FF.DeadVermin.Var, mod.FF.DeadVermin.Sub, pos, nilvector, nil)
                end
                break
            end
        end
    end
    if successful then
        --player:RemoveCollectible(FiendFolio.ITEM.COLLECTIBLE.RAT_POISON, true, activeSlot)
        return {Discharge = false, Remove = true, ShowAnim = true}
    end
end, FiendFolio.ITEM.COLLECTIBLE.RAT_POISON)

function mod.ratPoisonRoom()
    local saveData = FiendFolio.savedata.run
    if saveData.RatPoison then
        saveData.level = saveData.level or {}
        saveData.level.SkippedRooms = saveData.level.SkippedRooms or {}
        if not saveData.level.SkippedRooms[tostring(game:GetRoom():GetDecorationSeed())] then
            local text = getFFRoomName()
            if text then
                for i = 1, #saveData.RatPoison do
                    if string.starts(text, saveData.RatPoison[i]) then
                        --mod:skipCardRoom()
                        mod.scheduleForUpdate(function()
                            mod:skipCardRoom()
                        end, 1, nil, true)
                        saveData.level.SkippedRooms[tostring(game:GetRoom():GetDecorationSeed())] = true
                        break
                    end
                end
            end
        end
    end
end

function mod:deadVerminAI(e)
	local sprite = e:GetSprite()
	if sprite:IsFinished("Death") then
		sprite:Play("Dead")
    elseif sprite:IsEventTriggered("splat") then
        sfx:Play(SoundEffect.SOUND_MEAT_JUMPS,1,2,false,1)
        for i = 30, 360, 30 do
            blood = Isaac.Spawn(1000, 7, 0, e.Position + Vector(math.random(50),0):Rotated(i), nilvector, nil)
            blood.Color = mod.ColorSpittyGreen
            blood:Update()
        end
	end
end

function mod:ratPoisonOnLocustDamage(player, locust, entity)
    if math.random(100) == 1 then
        if not entity:GetData().RatPoisonLocustTriedToWipe then
            entity:GetData().RatPoisonLocustTriedToWipe = true
            local tear = Isaac.Spawn(2, 45, 0, entity.Position, nilvector, nil):ToTear()
            --tear:AddTearFlags(TearFlags.TEAR_PIERCING)
            tear.Visible = false
            tear:Update()
            entity:Update()
            sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
            mod.scheduleForUpdate(function()
                sfx:Stop(SoundEffect.SOUND_PLOP)
            end, 2)
        end
    end
end
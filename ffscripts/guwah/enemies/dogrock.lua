local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()
local music = MusicManager()

function mod:DogrockAI(npc, sprite, data)
    local room = game:GetRoom()
    mod.NegateKnockoutDrops(npc)
    mod.QuickSetEntityGridPath(npc, 900)
    npc.Velocity = Vector.Zero
    if not data.Init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        data.state = "appear"
        if npc.SubType ~= 1 then
            npc.CanShutDoors = true
            if npc.SubType == 8521 then --Sneaky Retriever
                for i = 0, 1 do
                    sprite:ReplaceSpritesheet(i, "gfx/secret/shhhhh/nothing to see here/monster_sneakyretriever.png")
                end
                sprite:LoadGraphics()
                data.sneaky = true
            end
        end
        data.Init = true
    end
    if data.state == "appear" then
        if sprite:IsFinished("Appear") then
            data.state = "idle"
            data.starin = true
            npc.StateFrame = mod:RandomInt(90,150)
        else
            mod:spritePlay(sprite, "Appear")
        end
    elseif data.state == "idle" then
        if data.blinkin then
            if sprite:IsFinished("Blink") then
                data.blinkin = false
                npc.StateFrame = mod:RandomInt(90,150)
            elseif sprite:IsEventTriggered("Check") then
                data.starin = true
            else
                mod:spritePlay(sprite, "Blink")
            end
        else
            if not data.sneaky then
                npc.StateFrame = npc.StateFrame - 1
            end
            if sprite:IsEventTriggered("Check") and npc.StateFrame <= 0 then
                data.wanttoblink = true
            else
                mod:spritePlay(sprite, "Idle")
            end
        end
        if npc.SubType == 1 and room:IsClear() then
            data.state = "deactivated"
            data.starin = false
            sprite:Play("Deactivate")
        end
    end
end

local dogrockIris = Sprite()
dogrockIris:Load("gfx/enemies/dogrock/monster_dog rock.anm2", true)
dogrockIris:Play("IrisCentered", true)

function mod:DogrockRender(npc, sprite, data, isPaused, isReflected)
    if data.starin then
        data.eyeangle = data.eyeangle or 0
        data.eyeoffset = data.eyeoffset or 0
        if not isPaused then
            if data.sneaky then
                data.eyeangle = data.eyeangle + mod:RandomInt(-60,60)
            else
                local targetangle = mod:GetAngleDegreesButGood(npc.Position - mod:confusePos(npc, npc:GetPlayerTarget().Position))
                data.eyeangle = targetangle
            end
            if data.wanttoblink then
                data.eyeoffset = data.eyeoffset + 0.5
                if data.eyeoffset >= 0 then
                    data.wanttoblink = false
                    data.starin = false
                    data.blinkin = true
                end
            else
                if data.eyeoffset > -5 then
                    data.eyeoffset = data.eyeoffset - 0.5
                end
            end
            if npc.Visible == false then
                dogrockIris.Color = Color(1,1,1,0)
            else
                dogrockIris.Color = sprite.Color
            end
            dogrockIris.Scale = sprite.Scale
        end
        local renderoffset = Vector(data.eyeoffset,0):Rotated(data.eyeangle)
        local renderpos = npc.Position + Vector(renderoffset.X * dogrockIris.Scale.X, renderoffset.Y * dogrockIris.Scale.Y)
        dogrockIris:Render(Isaac.WorldToScreen(renderpos), Vector.Zero, Vector.Zero)
    end
end

function mod:DogrockLogic()
    local room = game:GetRoom()
    local noDogStatus = true
    local isDogrock = false
    for i = 1, game:GetNumPlayers() do
        local noDogsNear = true
        local player = Isaac.GetPlayer(i - 1)
        local data = player:GetData()
        data.DogrockDebuff = data.DogrockDebuff or 0
        for _, dog in pairs(Isaac.FindByType(mod.FF.Dogrock.ID, mod.FF.Dogrock.Var, -1, false, true)) do
            if dog.Position:Distance(player.Position) < 110 and not (dog:GetData().state == "deactivated" or dog:GetData().sneaky) then
                if mod.DogrockIntensity <= 1 then
                    mod.DogrockIntensity = mod.DogrockIntensity + 0.04
                    mod.DogrockIntensity = math.min(mod.DogrockIntensity, 1)
                end
                if data.DogrockDebuff <= 1 then
                    data.DogrockDebuff = data.DogrockDebuff + 0.04
                    data.DogrockDebuff = math.min(data.DogrockDebuff, 1)
                    player:AddCacheFlags(CacheFlag.CACHE_ALL)
                    player:EvaluateItems()
                    sfx:SetAmbientSound(mod.Sounds.Dogrock, data.DogrockDebuff, 1)
                end
                isDogrock = true
                noDogsNear = false
                noDogStatus = false
            end
        end
        for _, mushy in pairs(Isaac.FindByType(mod.FF.InfectedMushroom.ID, mod.FF.InfectedMushroom.Var, -1, false, true)) do
            if mushy:GetData().Radius and mushy.Position:Distance(player.Position) <= mushy:GetData().Radius then
                if mod.DogrockIntensity <= 1 then
                    mod.DogrockIntensity = mod.DogrockIntensity + 0.04
                    mod.DogrockIntensity = math.min(mod.DogrockIntensity, 1)
                end
                noDogsNear = false
            end
        end
        if player:HasTrinket(FiendFolio.ITEM.ROCK.DOGROCK_ROCK) then
            if mod.DogrockIntensity <= 1 then
                mod.DogrockIntensity = mod.DogrockIntensity + (0.06 * player:GetTrinketMultiplier(FiendFolio.ITEM.ROCK.DOGROCK_ROCK))
                mod.DogrockIntensity = math.min(mod.DogrockIntensity, 1)
            end
            noDogStatus = false
        end
        if noDogsNear then
            if data.DogrockDebuff > 0 then
                data.DogrockDebuff = data.DogrockDebuff - 0.01
                data.DogrockDebuff = math.max(data.DogrockDebuff, 0)
                player:AddCacheFlags(CacheFlag.CACHE_ALL)
                player:EvaluateItems()
                sfx:SetAmbientSound(mod.Sounds.Dogrock, data.DogrockDebuff, 1)
            end
        end
    end
    if noDogStatus then
        if mod.DogrockIntensity > 0 then
            mod.DogrockIntensity = mod.DogrockIntensity - 0.01
            mod.DogrockIntensity = math.max(mod.DogrockIntensity, 0)
        end
    end
    if mod.DogrockIntensity > 0 then
        mod.TargetFloorColor = mod.TargetFloorColor or mod:RandomColor(0.4 * mod.DogrockIntensity)
        mod.CurrentFloorColor = mod.CurrentFloorColor or Color.Default
        if game:GetFrameCount() % 10 == 0 then
            mod.TargetFloorColor = mod:RandomColor(0.025 * mod.DogrockIntensity)
            --mod:PrintColor(mod.TargetFloorColor)
        end
        mod.CurrentFloorColor = Color.Lerp(mod.CurrentFloorColor, mod.TargetFloorColor, 0.1)
        local pitchrange = 0.3
        if not mod.MusicTampered then
            music:PitchSlide(1.0 + (Random() % pitchrange) - (pitchrange*0.5))
            mod.MusicTampered = true
        elseif game:GetFrameCount() % 30 == 0 then
            music:PitchSlide(1.0 + (Random() % pitchrange) - (pitchrange*0.5))
        end
    else
        if mod.CurrentFloorColor then
            mod.CurrentFloorColor = Color.Lerp(mod.CurrentFloorColor, Color.Default, 0.05)
        end
        if mod.MusicTampered then
            music:PitchSlide(1.0)
            mod.MusicTampered = false
        end
    end
    if mod.CurrentFloorColor then
        room:SetFloorColor(mod.CurrentFloorColor)
        room:SetWallColor(mod.CurrentFloorColor)
    end
end
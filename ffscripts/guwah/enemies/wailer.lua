local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local function SwapWailerFace(sprite, matchSkin)
    local skin = matchSkin or mod:RandomInt(1,8)
    sprite:ReplaceSpritesheet(1, "gfx/enemies/wailer/monster_wailer"..skin..".png")
    sprite:LoadGraphics()
    return skin
end

function mod:WailerInit(npc)
    if (game:GetRoom():IsClear() and mod:AreAllButtonsPressed()) then
        npc.Visible = false
        npc:Remove()
    end
end

function mod:WailerAI(npc, sprite, data)
    if not data.Init then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS)
        npc.SplatColor = mod.ColorGhostly
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    
        data.Interval = (npc.SubType >> 0) & 31 
        data.Delay = (npc.SubType >> 5) & 31
		data.MovementPattern = (npc.SubType >> 10) & 3
        data.MovementDirection = (npc.SubType >> 12) & 3

        if data.MovementPattern == 1 then
            npc.Velocity = Vector(-4,0):Rotated(90 * data.MovementDirection)
        elseif data.MovementPattern == 2 or data.MovementPattern == 3 then
            mod:WallHuggerInit(npc, mod:GetOrientationFromVector(Vector(-4,0):Rotated(90 * data.MovementDirection)), (data.MovementPattern == 3), GridCollisionClass.COLLISION_PIT, 1)
        end

        npc.StateFrame = (data.Interval * 5) + (data.Delay * 5)
        data.State = "Idle"
        data.Init = true
    end

    npc.StateFrame = npc.StateFrame - 1

    if data.State == "Idle" then
        mod:spritePlay(sprite, "Idle")
        if game:GetRoom():IsClear() and mod:AreAllButtonsPressed() then
            data.State = "Death"
        elseif npc.StateFrame <= 0 then
            npc.StateFrame = (data.Interval * 5)
            data.State = "Inflate"
            data.Skin = SwapWailerFace(sprite)
        end

    elseif data.State == "Inflate" then
        if sprite:IsFinished("AngerStart") then
            data.FaceOffset = 0
            data.State = "Inflated"
        elseif sprite:IsEventTriggered("Collision") then
            mod:PlaySound(mod.Sounds.WailerGrow, npc, 0.05 * mod:RandomInt(18,25,rng), 0.8)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            --npc:SetSize(18, Vector(1,1), 12)
        else
            mod:spritePlay(sprite, "AngerStart")
        end

    elseif data.State == "Inflated" then
        mod:spritePlay(sprite, "AngerLoop")
        if npc.StateFrame <= 0 or (game:GetRoom():IsClear() and mod:AreAllButtonsPressed()) then
            npc.StateFrame = (data.Interval * 5)
            data.State = "Deflate"
        end

    elseif data.State == "Deflate" then
        if sprite:IsFinished("AngerEnd") then
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Collision") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            --npc:SetSize(8, Vector(1,1), 12)
        else
            mod:spritePlay(sprite, "AngerEnd")
        end

    elseif data.State == "Death" then
        if sprite:IsFinished("Death") then
            npc:Remove()
        else
            mod:spritePlay(sprite, "Death")
        end
    end
    
    if data.MovementPattern == 0 or data.State == "Death" then --Stationary
        npc.Velocity = Vector.Zero
    elseif data.MovementPattern == 1 then --Bouncing 
        npc.Velocity = mod:SnapVector(npc.Velocity, 90):Resized(4)
    else --Wall Hugging
        mod:WallHuggerMovement(npc, 8)
    end
end

local wailerFace = Sprite()
wailerFace:Load("gfx/enemies/wailer/monster_wailer.anm2", true)
wailerFace:Play("Face", true)

function mod:WailerRender(npc, sprite, data, isPaused, isReflected, offset)
    if sprite:IsPlaying("AngerLoop") then
        if not (isPaused or isReflected) then
            if data.FaceOffset < 3 then
                data.FaceOffset = data.FaceOffset + 0.1
            end
        end

        if npc.Visible == false then
            wailerFace.Color = Color(1,1,1,0)
        else
            wailerFace.Color = sprite.Color
        end
        wailerFace.Scale = sprite.Scale
        SwapWailerFace(wailerFace, data.Skin)
        
        local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
        local angle = mod:GetAngleDegreesButGood(targetpos - npc.Position)
        local renderoffset = Vector(data.FaceOffset,0):Rotated(angle) + Vector((npc.FrameCount % 2 == 0 and 1 or -1),0)
        local renderpos = npc.Position + Vector(renderoffset.X * wailerFace.Scale.X, renderoffset.Y * wailerFace.Scale.Y)
        wailerFace:Render(Isaac.WorldToScreen(renderpos), Vector.Zero, Vector.Zero)
    end
end

function mod:AreAllButtonsPressed()
    local room = game:GetRoom()		
    if room:HasTriggerPressurePlates() then
        local size = room:GetGridSize()
        for i=0, size do
            local gridEntity = room:GetGridEntity(i)
            if gridEntity then
                local desc = gridEntity.Desc.Type
                if gridEntity.Desc.Type == GridEntityType.GRID_PRESSURE_PLATE then
                    if gridEntity:GetVariant() == 0 then
                        if gridEntity.State ~= 3 then
                            return false
                        end
                    end
                end
            end
        end
        return true
    end
end
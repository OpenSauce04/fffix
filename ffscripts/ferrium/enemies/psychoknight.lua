local mod = FiendFolio
local game = Game()

local function psychoKnightTeleportPos(npc, target)
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()
    local availablePos = {}
    local targetPos = room:GetGridPosition(room:GetGridIndex(target.Position))
    local blacklistedDir = 0
    local sprite = npc:GetSprite()
    if sprite:IsOverlayPlaying("WalkUp01") or sprite:IsOverlayPlaying("WalkUp02") then
        blacklistedDir = 90
    elseif sprite:IsOverlayPlaying("WalkDown01") or sprite:IsOverlayPlaying("WalkDown02") then
        blacklistedDir = 360
    elseif sprite:IsOverlayPlaying("WalkRight01") or sprite:IsOverlayPlaying("WalkRight02") then
        if sprite.FlipX then
            blacklistedDir = 90
        else
            blacklistedDir = 270
        end
    end

    for i=90,360,90 do
        local j = 1
        repeat
            local checkGrid = room:GetGridEntityFromPos(targetPos+Vector(0,40*j):Rotated(i))
            if (blacklistedDir == i) or (checkGrid and checkGrid.CollisionClass > GridCollisionClass.COLLISION_NONE) then
                j = 10
            elseif j > 2 then
                table.insert(availablePos, {targetPos+Vector(0,40*j+20):Rotated(i), i})
                j = 10
            end
            j = j+1
        until j > 5
    end

    if #availablePos > 0 then
        return availablePos[rng:RandomInt(#availablePos)+1]
    else
        return nil
    end
end

function mod:psychoKnightAI(npc)
    local data = npc:GetData()
    local sprite = npc:GetSprite()
    local target = npc:GetPlayerTarget()

    if not data.init then
        data.teleportCooldown = 150
        data.state = "Idle"
        data.spottedTimer = 0
        data.init = true
    else
        data.teleportCooldown = data.teleportCooldown+1
        if data.spottedTimer > 0 then
            data.spottedTimer = data.spottedTimer-1
        end
    end

    if sprite:IsFinished("Appear") then
        sprite:SetFrame("Down", 0)
        sprite:SetOverlayFrame("WalkDown01", 0)
        sprite:Update()
    end

    local spotted = false

    if npc.Position:Distance(target.Position) < 400 then
        if math.abs(target.Position.X-npc.Position.X) < 40 then
            if sprite:IsOverlayPlaying("WalkDown01") or sprite:IsOverlayPlaying("WalkDown02") then
                if npc.Position.Y > target.Position.Y then
                    data.spottedTimer = data.spottedTimer+2
                    spotted = true
                end
            elseif sprite:IsOverlayPlaying("WalkUp01") or sprite:IsOverlayPlaying("WalkUp02") then
                if npc.Position.Y < target.Position.Y then
                    data.spottedTimer = data.spottedTimer+2
                    spotted = true
                end
            end
        elseif math.abs(target.Position.Y-npc.Position.Y) < 40 then
            if sprite:IsOverlayPlaying("WalkRight01") or sprite:IsOverlayPlaying("WalkRight02") then
                if sprite.FlipX then
                    if npc.Position.X < target.Position.X then
                        data.spottedTimer = data.spottedTimer+2
                        spotted = true
                    end
                else
                    if npc.Position.X > target.Position.X then
                        data.spottedTimer = data.spottedTimer+2
                        spotted = true
                    end
                end
            end
        end
    end

    if data.spottedTimer > 22 and data.teleportCooldown > 200 and not mod:isScareOrConfuse(npc) then
        data.teleport = psychoKnightTeleportPos(npc, target)
        if data.teleport then
            npc.State = 4
            data.charging = true
            local p = Isaac.Spawn(1000, 7020, 1, npc.Position, Vector.Zero, npc)
			local pcolor = Color(1,1,1,1,0,0,0)
			pcolor:SetColorize(0.9, 0.5, 1, 1)
			p.Color = pcolor
			p:Update()

            npc.Position = data.teleport[1]
            npc:PlaySound(SoundEffect.SOUND_HELL_PORTAL2, 1, 0, false, 1)
            local poof = Isaac.Spawn(1000, 16, 2, npc.Position, Vector.Zero, npc):ToEffect()
            poof.DepthOffset = 50
            poof.Color = Color(0.7,0.5,0.8,1,0.3,0,0.5)
            poof:Update()
            data.teleColor = 10
            data.spottedTimer = 0
            data.teleportCooldown = 0
            npc.TargetPosition = Vector(0,-1):Rotated(data.teleport[2])
            npc.Velocity = Vector.Zero
            mod.scheduleForUpdate(function()
                npc.State = 8
                data.charging = true
                npc.TargetPosition = Vector(0,-1):Rotated(data.teleport[2])
            end, 1)
        else
            data.spottedTimer = 10
        end
    end

    local anim = "01"
    if spotted or data.charging then
        anim = "02"
    elseif data.teleportCooldown < 200 then
        anim = "03"
    end
       
    if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
        --[[ if npc.Velocity.X > 0 then
            mod:spriteOverlayPlay(sprite, "WalkRight" .. anim)
        else
            mod:spriteOverlayPlay(sprite, "WalkLeft" .. anim)
        end]]
        mod:spriteOverlayPlay(sprite, "WalkRight" .. anim)
    else
        if npc.Velocity.Y > 0 then
            mod:spriteOverlayPlay(sprite, "WalkDown" .. anim)
        else
            mod:spriteOverlayPlay(sprite, "WalkUp" .. anim)
        end
    end

    if npc.State == 4 then
        if data.charging == true then
            data.charging = false
            data.teleportCooldown = 0
            data.spottedTimer = 0
        end
    elseif npc.State == 8 then
        if data.charging then
            if npc.Velocity:Length() < 8 then
                npc.Velocity = npc.Velocity*1.2
            end
        end
    end

    if data.teleColor then
        local color = Color(1,1,1,1,0.06*data.teleColor,0.02*data.teleColor,0.08*data.teleColor)
        color:SetColorize(1,1,1,1)
        npc.Color = color
        data.teleColor = data.teleColor-1
        if data.teleColor <= 0 then
            npc.Color = Color(1,1,1,1,0,0,0)
            data.teleColor = nil
        end
    end
end
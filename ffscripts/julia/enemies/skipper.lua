local mod = FiendFolio
local game = Game()

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.Variant == mod.FF.Skipper.Var then
        local data = npc:GetData()
        local sprite = npc:GetSprite()
        local room = game:GetRoom()

        local player = npc:GetPlayerTarget()

        if not data.init then
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS

            npc.State = 3
            npc.StateFrame = 0

            data.nextJump = "hop"
            data.direction = (npc.TargetPosition - npc.Position):Normalized()
            data.skips = 0
            data.init = true

            data.skipTreshold = 2

            data.currentSkip = 0
        end

        if sprite:IsEventTriggered("Jump") then
            Isaac.Spawn(1000, 133, 0, npc.Position + npc.Velocity, Vector.Zero, npc) --spawn water ripple

            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS --fly
        end

        if sprite:IsEventTriggered("Land") then
            Isaac.Spawn(1000, 133, 0, npc.Position + npc.Velocity, Vector.Zero, npc) --spawn water ripple
            npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, 1, 0, false, 1)

            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS --dont fly anymore
        end

        if (npc.State == 3 and npc.StateFrame == 1 and data.nextJump == "skip") or (npc.State == 3 and npc.StateFrame == 20 and data.nextJump == "hop") then --begin jumping
            data.currentSkip = 0

            npc.State = 4
            npc.StateFrame = 0
            sprite:Play("Hop", true)

            if player.Position:Distance(npc.Position) < 300 and not npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then --chase player
                if npc:HasEntityFlags(EntityFlag.FLAG_FEAR | EntityFlag.FLAG_SHRINK) then --fear
                    npc.TargetPosition = npc.Position + player.Position
                else
                    npc.TargetPosition = player.Position
                end
            else --skip randomly
                npc.TargetPosition = room:GetRandomPosition(0)
            end
        elseif npc.State == 4 and npc.StateFrame == 1 then --at beginning of jump
            local speed = 6 + player.Position:Distance(npc.Position) / 40 --faster if player is farther away

            if data.nextJump == "skip" then --small skip
                speed = 1 + (data.skipTreshold - data.currentSkip) * 2 --get slightly slower with every skip

                sprite:SetFrame(4)

                npc.TargetPosition = npc.Position + data.direction * (20 + 20 * (data.skipTreshold - data.currentSkip)) --skip in stored direction

                data.skips = data.skips + 1
                data.currentSkip = data.skips
                if data.skips >= data.skipTreshold then
                    data.skips = 0
                    data.nextJump = "hop"
                end
            else
                --npc.TargetPosition = npc.TargetPosition - (npc.TargetPosition - npc.Position) / 1.5 --short hop
                data.nextJump = "skip"
                
                data.direction = (npc.TargetPosition - npc.Position):Normalized()

                local max = 1 --get number of max possible skips without repeatedly jumping into a wall
                for i = 2, 3 do
                    if room:GetClampedPosition(npc.TargetPosition + data.direction * (40 * i), 0):Distance(npc.TargetPosition + data.direction * (40 * i)) < 10 then
                        max = i
                    end
                end

                --data.skipTreshold = max
                data.skipTreshold = math.random(1, max)
            end

            npc.TargetPosition = room:FindFreePickupSpawnPosition(npc.TargetPosition, 0, false, true)

            data.targetVel = (npc.TargetPosition - npc.Position):Normalized() * speed
        end

        --animation & velocity stuff
        if npc.State == 3 then --idle
            mod:spritePlay(sprite, "Idle")

            npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
        elseif npc.State == 4 then --jumping
            if sprite:IsEventTriggered("Land") and data.nextJump == "skip" then
                npc.State = 3
                npc.StateFrame = 0
            elseif sprite:IsFinished("Hop") then
                npc.State = 3
                npc.StateFrame = 0
            else
                mod:spritePlay(sprite, "Hop")
            end 

            if npc.Position:Distance(npc.TargetPosition) > 40 then
                if data.targetVel then
                    npc.Velocity = mod:Lerp(npc.Velocity, data.targetVel, 0.3)
                end
            end
        end

        if sprite:IsPlaying("Hop") and sprite:GetFrame() >= 4 and sprite:GetFrame() <= 14 then --adjust height for skips
            npc.SpriteOffset = Vector(0, -11 + data.currentSkip * 6)
        else
            npc.SpriteOffset = Vector(0, 0)
        end

        npc.StateFrame = npc.StateFrame + 1

        --print(npc.State)
        --print(npc.TargetPosition)
    end
end, 170)
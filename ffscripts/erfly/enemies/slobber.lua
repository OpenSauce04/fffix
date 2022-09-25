local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:slobberFormerlyDroolyAI(npc, sub, var)
    local sprite, d, r = npc:GetSprite(), npc:GetData(), npc:GetDropRNG()
    local target, path = npc:GetPlayerTarget(), npc.Pathfinder
    local distance = target.Position:Distance(npc.Position)
    local angle = (target.Position - npc.Position):GetAngleDegrees()
    npc:MultiplyFriction(0.7)

    if not d.init then
        d.init = true
        d.state = "idle"
        d.CoolDown = 20 + r:RandomInt(11)
		d.MaxCoolDown = 80 + r:RandomInt(16)
    end

    if npc.FrameCount % 8 == 0 and npc.FrameCount > 1 then
        if var == mod.FF.Slobber.Var then
            if mod:isFriend(npc) then
                local creep = Isaac.Spawn(1000, 46,  0, npc.Position, nilvector, npc):ToEffect()
                creep.Scale = creep.Scale * 0.75
                creep:SetTimeout(creep.Timeout - 84)
                creep:GetSprite():ReplaceSpritesheet(0, "gfx/effects/effect_waterpool.png")
                creep:GetSprite():LoadGraphics()
                creep:Update()
            else
                local creep = Isaac.Spawn(1000, 94,  160, npc.Position, nilvector, npc):ToEffect()
                creep.Scale = creep.Scale * 0.75
                creep:SetTimeout(creep.Timeout - 84)
                creep:Update()
            end
        else
            local creep = Isaac.Spawn(1000, 22,  0, npc.Position, Vector(0, 0), npc):ToEffect()
            creep.Scale = creep.Scale * 0.75
            creep:SetTimeout(creep.Timeout - 94)
            creep:Update()
        end
    end

    if d.state == "idle" then
        npc:AnimWalkFrame("WalkHori", "WalkVert", 1.0)
        sprite:PlayOverlay("HeadWalk")
        if mod:isCharm(npc) then
            if (Game():GetRoom():CheckLine(npc.Position, target.Position, 0, 1, false, false) and not npc:CollidesWithGrid()) or npc:GetChampionColorIdx() == 8 then
                npc.Velocity = npc.Velocity + (target.Position - npc.Position):Normalized() * 1.35
            else
                path:FindGridPath(target.Position, 0.85, 1, true)
            end
        elseif mod:isScare(npc) then
            if (Game():GetRoom():CheckLine(npc.Position, target.Position, 0, 1, false, false) and not npc:CollidesWithGrid()) or npc:GetChampionColorIdx() == 8 then
                npc.Velocity = npc.Velocity + (target.Position - npc.Position):Normalized() * -1.35
            else
                path:FindGridPath(target.Position, -0.85, 1, true)
            end
        else
            npc.Velocity = npc.Velocity + npc.Velocity:Normalized() * 1.05
            path:MoveRandomly(false)
        end

        if d.CoolDown < d.MaxCoolDown then
            d.CoolDown = d.CoolDown + 1
        end

        if (Game():GetRoom():CheckLine(npc.Position, target.Position, 3, 20, false, false) or npc:GetChampionColorIdx() == 8) and distance <= 180 and d.CoolDown >= d.MaxCoolDown and npc.FrameCount > 4 then
            if not mod:isScareOrConfuse(npc) then
                d.state = "attack"
                d.CoolDown = 0
                d.MaxCoolDown = 85 + r:RandomInt(16)
            end	
        end
    elseif d.state == "attack" then
        sprite:RemoveOverlay()
        if sprite:IsFinished("Attack") then
            d.state = "idle"
        elseif sprite:IsEventTriggered("Shoot") then
			local flipped_sprite
            if angle > 90 or angle < -90 then
                npc:GetSprite().FlipX = true
				flipped_sprite = -1
            else
                npc:GetSprite().FlipX = false
				flipped_sprite = 1
            end
            npc:PlaySound(SoundEffect.SOUND_WHEEZY_COUGH, 1.0, 0, false, 1.1)
            local projectile_params = ProjectileParams()
            if game.Difficulty % 2 == 1 then
                projectile_params.VelocityMulti = 9
            else
                projectile_params.VelocityMulti = 7
            end
			local effect = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc):ToEffect()
			effect.SpriteOffset = Vector(flipped_sprite * 5,-11)
			effect.DepthOffset = npc.Position.Y * 1.25
				if var == mod.FF.Slobber.Var then
					projectile_params.Variant = 4
					effect.Color = mod.ColorLessSolidWater
				else
					effect.Color = Color(1,1,1,0.8)
				end
            effect:FollowParent(npc)
			if var == mod.FF.PaleBleedy.Var and sprite:GetFrame() >=  36 then
				projectile_params.Scale = projectile_params.Scale * 1.4
			end
            npc:FireProjectiles(npc.Position, Vector.FromAngle(angle), 0, projectile_params)
        else
            mod:spritePlay(sprite, "Attack")
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	if effect.SubType == 160 then
        if effect.FrameCount < 1 then
            effect.Color = Color(1,1,1,1,0,0,0)
        end
    end
end, 94)

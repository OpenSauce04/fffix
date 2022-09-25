local mod = FiendFolio
local game = Game()

function mod:tagbagAI(npc, sprite, data)
    if not data.State then
        data.State = "Idle"
    end

    data.UseFFPlayerFlyingMap = true
    local room = game:GetRoom()
    if data.Path and data.State == "Idle" then
        if npc.MaxHitPoints == 0 then
            sprite:Play("Suspended")
        else
            sprite:Play("Idle")
        end

        local index = room:GetGridIndex(npc.Position)
        if room:GetGridPath(index) < 900 then
            room:SetGridPath(index, 900)
        end

        FiendFolio.FollowPath(npc, 0.5, data.Path, true, 0.75, 500)
    else
        npc.Velocity = npc.Velocity * 0.75
    end

    if sprite:IsFinished("SuspendStart") then
        npc.MaxHitPoints = 0
        data.State = "Idle"
    end

    if data.State == "Idle" then
        local target = npc:GetPlayerTarget()
        local dist = target.Position:DistanceSquared(npc.Position)
		if npc.FrameCount > 1 then
			if npc.MaxHitPoints == 0 and (room:IsClear() or dist < (npc.Size + target.Size + 20) ^ 2) then
				data.State = "Attack"
				sprite:Play("Drop", true)
			elseif npc.MaxHitPoints > 0 and dist < 80 ^ 2 then
				data.State = "Attack"
				data.Repeats = math.random(1, 3)
				sprite:Play("Attack", true)
			end
		end
    elseif data.State == "Attack" then
        if sprite:IsEventTriggered("Shoot") then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 5, npc.Position, Vector.Zero, npc)
            local params = ProjectileParams()
            params.VelocityMulti = 1.5
            game:ShakeScreen(3)
            npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, 1, 0, false, 1)
            npc:FireBossProjectiles(10, npc.Position, 10, params)
        end

        if sprite:IsEventTriggered("Explode") then
            mod.tagbagDeathEffect(npc)
            npc:Kill()
        end

        if sprite:IsFinished("Attack") then
            if data.Repeats and data.Repeats > 0 then
                data.Repeats = data.Repeats - 1
                sprite:Play("Attack", true)
            else
                data.State = "Idle"
            end
        end
    end
end

function mod.tagbagDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
		deathAnim:GetData().State = "Raise"
		deathAnim:GetData().Path = npc:GetData().Path
		deathAnim.Velocity = npc.Velocity
	end
	
	mod.genericCustomDeathAnim(npc, "SuspendStart", false, onCustomDeath)
end

function mod.tagbagDeathEffect(npc)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 5, npc.Position, Vector.Zero, npc)
    local params = ProjectileParams()
    params.VelocityMulti = 3
    game:ShakeScreen(3)
    npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, 1, 0, false, 1)
    npc:FireBossProjectiles(10, npc.Position, 10, params)

    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, npc.Position, Vector.Zero, npc)
    local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, npc.Position, Vector.Zero, npc):ToEffect()
    creep.SpriteScale = Vector(3, 3)
    creep:Update()
    game:ShakeScreen(10)
    npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, 1, 0, false, 1)
end
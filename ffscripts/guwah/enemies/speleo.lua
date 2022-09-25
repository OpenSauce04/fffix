local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:SpeleoAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()

    if not data.Init then
        if npc.SubType > 0 then
            if npc.SubType == 2 and room:GetFrameCount() <= 1 then
                local rock = Isaac.GridSpawn(2, 0, npc.Position, true)
				mod:UpdateRocks()
            end
            mod.makeWaitFerr(npc, mod.FF.Speleo.ID, mod.FF.Speleo.Var, 0, 80, false)
        end
        if data.waited then
            npc.Visible = true
        end
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_BLOOD_SPLASH | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        data.State = "Land"
        data.Init = true
    end

    if data.State == "Land" then
        if sprite:IsFinished("Land") then
            data.State = "Idle"
            npc.StateFrame = mod:RandomInt(30,60,rng)
        elseif sprite:IsEventTriggered("Shoot") then
            if data.FirstLanding then
                local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, npc.Position, Vector.Zero, npc):ToEffect()
                wave.Parent = npc
                wave.MaxRadius = 50
            else
                data.FirstLanding = true
            end
            mod:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND, npc)
            mod:PlaySound(SoundEffect.SOUND_MOTHER_LAND_SMASH, npc)
            mod:DestroyNearbyGrid(npc, 50)
            game:ShakeScreen(10)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            data.Rooted = true

            if npc.Child and npc.Child:Exists() then
				npc.Child.Parent = nil
				npc.Child = nil
			end
        else
            mod:spritePlay(sprite, "Land")
        end
    elseif data.State == "Idle" then
        mod:spritePlay(sprite, "Idle")
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 and not mod:AreThereAnyOthersInState(npc, "Jump") then
            data.State = "Jump"
            mod:FlipSprite(sprite, npc.Position, targetpos)
        end
    elseif data.State == "Jump" then
        if sprite:IsFinished("Jump") then
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                data.State = "Land"
            end
        elseif sprite:IsEventTriggered("Shoot") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            npc.StateFrame = 10
            local playerpos = targetpos + (target.Velocity * 45)
            local vec = (playerpos - npc.Position)
            local landpos = npc.Position + vec:Resized(math.min(300, vec:Length()))
            npc.TargetPosition = mod:KeepPosWithinRoom(npc.Position, landpos, true)
            npc.Velocity = (npc.TargetPosition - npc.Position)/25
            mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
            data.Rooted = false
            mod:PlaySound(SoundEffect.SOUND_BOSS_LITE_ROAR,npc,0.8,1.5)

            local effect = Isaac.Spawn(1000,1743,0,npc.TargetPosition,Vector.Zero,npc)
            effect:GetSprite():Load("gfx/enemies/speleo/speleo_target.anm2", true)
            mod:spritePlay(effect:GetSprite(), "Blink")
            effect.Parent = npc
            npc.Child = effect
            effect:Update()
        else
            mod:spritePlay(sprite, "Jump")
        end
    end

    if data.Rooted then
        npc.Velocity = Vector.Zero
        mod.QuickSetEntityGridPath(npc)
    end
end

function mod:IgnoreCrushDamage(npc, amount, damageFlags, source)
    if mod:HasDamageFlag(DamageFlag.DAMAGE_CRUSH, damageFlags) and not mod:IsPlayerDamage(source) then
        return false
    end
end

function mod:KeepPosWithinRoom(pos1, pos2, avoidPits)
    local room = game:GetRoom()
    local vec = pos2 - pos1
    while pos1:Distance(pos2) > 1 and ((avoidPits == nil or room:GetGridCollision(room:GetGridIndex(pos2)) == GridCollisionClass.COLLISION_PIT) or not room:IsPositionInRoom(pos2, 10)) do
        pos2 = pos2 - (vec/10)
    end
    return pos2
end
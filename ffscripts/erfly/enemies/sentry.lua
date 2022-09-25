local mod = FiendFolio
local nilvector = Vector.Zero

--Sentry
function mod:sentryAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not d.init then
		d.state = "idle"
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
		sprite:Play("Idle")
		d.init = true
		d.boopable = true
	elseif d.init then
		npc.StateFrame = npc.StateFrame + 1
	end

	npc.RenderZOffset = -5500

	if sprite:IsFinished("Bopped") then
		sprite:Play("Idle")
	end

	if sprite:IsEventTriggered("bopback") or npc.StateFrame == 6 then
		d.boopable = true
	end

	npc.Velocity = nilvector
end

function mod:sentryHurt(npc, damage, flag, source)
    if npc.SubType == mod.FF.SentryShell.Sub then
        return false
    end
end

function mod:sentryColl(npc1, npc2)
    if npc2.Type == 1 then
        if npc2.Position.Y < npc1.Position.Y then
            local d = npc1:GetData()
            if d.boopable then
                npc1:PlaySound(SoundEffect.SOUND_BONE_DROP,1,0,false,math.random(100,150)/100)
                npc2.Velocity = Vector(npc2.Velocity.X, -5)
                npc1:GetSprite():Play("Bopped", true)
                npc1.StateFrame = 0
                d.boopable = false
            end
        end
    end
end
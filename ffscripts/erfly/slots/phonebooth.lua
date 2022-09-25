local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

FiendFolio.onEntityTick(EntityType.ENTITY_SLOT, function(slot)
    local sprite, d = slot:GetSprite(), slot:GetData()
	local data = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})

    if not d.init then
        d.state = "idle"
        d.init = true
    end

    local mus = MusicManager()

    d.StateFrame = d.StateFrame or 0
    d.StateFrame = d.StateFrame + 1

    if d.state == "idle" then
        mus:VolumeSlide(Options.MusicVolume * 10, 0.01)
        if not d.ringing then
            mod:spritePlay(sprite, "Idle")
            if d.StateFrame > 30 then
                if math.random(300) == 1 then
                    d.ringing = 0
                end
            end
        elseif d.ringing then
            d.ringing = d.ringing + 1
            if d.ringing >= 240 then
                d.ringing = nil
            elseif d.ringing % 60 == 1 then
                sprite:Play("RingRing", true)
                sfx:Play(mod.Sounds.TBRing, 1, 0, false, 1)
            end
        end
    elseif d.state == "inuse" then
        mod:spritePlay(sprite, "Used")
        mus:VolumeSlide(Options.MusicVolume, 0.05)
    end

	if not d.DropFunc then
		function d.DropFunc()
			if not d.DidDropFunc then
                d.DidDropFunc = true
                if math.random(5) == 1 then
                    local spawn = Isaac.Spawn(5, 20, 1, slot.Position, nilvector, slot)
                    spawn:GetData().DontRemoveRecentReward = true
                end
            end
		end
	end

    FiendFolio.OverrideExplosionHack(slot)
end, mod.FF.PhoneBooth.Var)

FiendFolio.onMachineTouch(mod.FF.PhoneBooth.Var, function(player, slot)
    local sprite, d = slot:GetSprite(), slot:GetData()
	local data = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})

    if d.ringing then
        d.ringing = nil
        d.state = "inuse"
        d.StateFrame = 0
        sfx:Play(mod.Sounds.TBPickup, 1, 0, false, 1)
        d.player = player
        local phone = Isaac.Spawn(1000, mod.FF.LittlePhone.Var, mod.FF.LittlePhone.Sub, player.Position, nilvector, nil)
        phone:GetData().spawner = slot
        phone.Parent = player
        phone:Update()
        
    elseif d.state == "inuse" then
        d.StateFrame = d.StateFrame or 0
        d.StateFrame = d.StateFrame + 1
        if d.StateFrame > 30 then
            sfx:Play(mod.Sounds.TBHangup, 1, 0, false, 1)
            d.state = "idle"
            d.StateFrame = 0
            sfx:Stop(mod.Sounds.TBBen)
            for i = 1, #mod.phoneBoothSpeechSounds do
                if sfx:IsPlaying(mod.phoneBoothSpeechSounds[i]) then
                    sfx:Stop(mod.phoneBoothSpeechSounds[i])
                end
            end
        end
    end
end)

mod.phoneBoothSpeechSounds = {
    mod.Sounds.TBYes,
    mod.Sounds.TBNo,
    mod.Sounds.TBHeartyLaugh,
    mod.Sounds.TBEurgh,
}

--LittlePhone
function mod:littlePhoneUpdate(e)
    local sprite, d = e:GetSprite(), e:GetData()

    if e.Parent and d.spawner then
        e.Position = e.Parent.Position
        e.Velocity = e.Parent.Velocity
        e.SpriteOffset = Vector(17, -19)
        local vec = (d.spawner.Position - e.Parent.Position)
        if vec:Length() > 150 then
            e.Parent.Velocity = mod:Lerp(e.Parent.Velocity, vec:Resized(vec:Length() - 150), 0.2)
        end
        if not e.Child then
            local handler = Isaac.Spawn(1000, 1749, 160, e.Position, nilvector, e):ToEffect()
            handler.Parent = e
            handler.Visible = false
            handler:Update()
    
            local rope = Isaac.Spawn(EntityType.ENTITY_EVIS, 10, 160, d.spawner.Position, nilvector, e)
            e.Child = rope
    
            rope.Parent = handler
            rope.Target = d.spawner
    
            rope:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            rope:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            rope.DepthOffset = -20
    
            rope:GetSprite():Play("Idle", true)
            rope:GetSprite():SetFrame(100)
            rope:Update()
    
            rope.SplatColor = Color(1,1,1,0,0,0,0)
        end
    else
        if e.Child then
            e.Child:Remove()
        end
        e:Remove()
    end

    if (not d.spawner) or d.spawner and d.spawner:GetData().state == "idle" then
        e.Child:Remove()
        e:Remove()
    end

    if e.FrameCount == 25 then
        sfx:Play(mod.Sounds.TBBen, 1, 0, false, 1)
        d.timer = math.random(60, 240)
    end
    if d.timer then
        d.timer = d.timer - 1
        if d.timer <= 0 then
            local choice = math.random(#mod.phoneBoothSpeechSounds)
            sfx:Play(mod.phoneBoothSpeechSounds[choice], 1, 0, false, 1)
            d.timer = math.random(60, 120)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, handler)
	if handler.SubType == 160 then
		if not handler.Parent or not handler.Parent:Exists() then
			handler:Remove()
		else
			handler.Position = handler.Parent.Position + handler.Parent.SpriteOffset + Vector(-12, -15):Rotated(handler.Parent:GetSprite().Rotation - 180)
			handler.Velocity = handler.Parent.Velocity
		end
	end
end, 1749)


mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, function(_, npc)
    if npc.Variant == 10 and npc.SubType == 160 then
        return false
    end
end, EntityType.ENTITY_EVIS)
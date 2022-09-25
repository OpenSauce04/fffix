local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local hugbeggarvec = {
    ["Left"] = -25,
    ["Right"] = 25
}

local hugbeggarhaters = {
    [FiendFolio.PLAYER.FIEND] = true,
    [FiendFolio.PLAYER.BIEND] = true,
}

FiendFolio.onEntityTick(EntityType.ENTITY_SLOT, function(slot)
    local sprite, d = slot:GetSprite(), slot:GetData()
	local data = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})

    if data.left then
        if sprite:IsFinished("Teleport") then
            slot:Remove()
        else
            mod:spritePlay(sprite, "Teleport")
        end
    elseif d.hugee and d.hugee.Player then
        local player = d.hugee.Player
        if sprite:IsFinished("Hug" .. d.hugee.Side) and (player.Velocity:Length() > 1) then
            data.left = true
            slot.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            local payouts = 1
            payouts = payouts + math.ceil(FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.THANK_YOU_FOSSIL))
			for i = 1, payouts do
                local pickup = Isaac.Spawn(5, 10, 0, slot.Position, Vector(0,2):Rotated(-30 + math.random(60)), slot)
            end
            sfx:Play(SoundEffect.SOUND_FETUS_JUMP,1,0,false,1)
        else
            mod:spritePlay(sprite, "Hug" .. d.hugee.Side)
        end

        local targpos = slot.Position + Vector(hugbeggarvec[d.hugee.Side], -5)
        local targvec = targpos - player.Position
        player.Velocity = mod:Lerp(player.Velocity, targvec, 0.1)
        player.Position = mod:Lerp(player.Position, targpos, 0.3)
    else
        if data.hasHugged then
            slot:Remove()
        end
        local player = mod:getClosestPlayer(slot.Position, 300)
        if player and player.Position:Distance(slot.Position) < 125 then
            if sprite:IsPlaying("IdleSad") then
                mod:spritePlay(sprite, "Happy")
            end
        elseif player and player.Position:Distance(slot.Position) > 150 then
            if sprite:IsPlaying("IdleHappy") then
                mod:spritePlay(sprite, "Sad")
            end
        end
    
        if sprite:IsFinished("Happy") then
            mod:spritePlay(sprite, "IdleHappy")
        elseif sprite:IsFinished("Sad") then
            mod:spritePlay(sprite, "IdleSad")
        end
    end

	if not d.DropFunc then
		function d.DropFunc()
			if not d.DidDropFunc then
                d.DidDropFunc = true
                for _, player in ipairs(Isaac.FindByType(1, 0, -1)) do
                    player = player:ToPlayer()
                    if hugbeggarhaters[player:GetPlayerType()] then
                        player:AnimateHappy()
                    else
                        player:AnimateSad()
                    end
                end
			end
		end
	end

    FiendFolio.OverrideExplosionHack(slot)
end, mod.FF.HugBeggar.Var)

FiendFolio.onMachineTouch(mod.FF.HugBeggar.Var, function(player, slot)
    local sprite, d = slot:GetSprite(), slot:GetData()
	local data = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
    if not d.hugee then
        local side = "Left"
        if player.Position.X > slot.Position.X then
            side = "Right"
        end
        d.hugee = {Player = player, Side = side}
        data.hasHugged = true
        sfx:Play(SoundEffect.SOUND_FETUS_LAND,1,0,false,1)
    end
end)
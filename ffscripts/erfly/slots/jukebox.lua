local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local beatFrames = {
    [10] = Vector(98, 102),
    [11] = Vector(99, 101)
}

FiendFolio.onEntityTick(EntityType.ENTITY_SLOT, function(slot)
    local sprite, d = slot:GetSprite(), slot:GetData()
	local data = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})

    local mus = MusicManager()
    print(mus:IsEnabled())

    if not mus:IsEnabled() then
        sprite:SetFrame("Idle", 0)
        sprite:RemoveOverlay()
    else
        mod:spritePlay(sprite, "Idle")
        mod:spriteOverlayPlay(sprite, "Idle Overlay")
        if beatFrames[sprite:GetFrame()] then
            slot.SpriteScale = beatFrames[sprite:GetFrame()]/100
        else
            slot.SpriteScale = Vector.One
        end

    end

	if not d.DropFunc then
		function d.DropFunc()
			if not d.DidDropFunc then
                d.DidDropFunc = true
            end
		end
	end

    FiendFolio.OverrideExplosionHack(slot)
end, mod.FF.Jukebox.Var)

FiendFolio.onMachineTouch(mod.FF.Jukebox.Var, function(player, slot)
    local sprite, d = slot:GetSprite(), slot:GetData()
	local data = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
    
end)
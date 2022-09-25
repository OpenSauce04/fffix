local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:dogboardUpdate(player, d)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.DOGBOARD) then
        if not d.hasDogboard then
            d.hasDogboard = Isaac.Spawn(mod.FF.Dogboard.ID, mod.FF.Dogboard.Var, mod.FF.Dogboard.Sub, player.Position, nilvector, player)
            d.hasDogboard.Parent = player
            d.hasDogboard:Update()
        end
        if player.Velocity:Length() < 3 then
            player.Friction = 1.15
        else
            player.Friction = 1
        end
    elseif d.hasDogboard then
        if d.hasDogboard:Exists() then
            d.hasDogboard.Parent = nil
            d.hasDogboard:Remove()
            player.Friction = 1
        end
        d.hasDogboard = nil
    end
end

function mod:dogboardEffectUpdate(e)
    local sprite = e:GetSprite()
    if e.Parent then
        if e.Parent.Type == 1 then --Player
            e.DepthOffset = -50
            e.Position = mod:Lerp(e.Position, e.Parent.Position, 0.6)
            e.Velocity = mod:Lerp(e.Velocity, e.Parent.Velocity, 0.6)
            local ang = e.Parent.Velocity:GetAngleDegrees() + 180
            ang = math.floor(((ang * -1) / 11.25) - 1) % 32
            print(ang)
            sprite:SetFrame("Directions", ang)
        elseif e.Parent.Type == 5 then --Pedestal
            e.DepthOffset = 5
            e.Position = mod:Lerp(e.Position, e.Parent.Position, 0.6)
            e.Velocity = mod:Lerp(e.Velocity, e.Parent.Velocity, 0.6)
            e.SpriteOffset = Vector(0, -20 + math.sin(e.FrameCount/10) * 5)
        end
    else
        e:Remove()
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
    local d = pickup:GetData()
    --print(pickup.SubType)
    if pickup.SubType == mod.ITEM.COLLECTIBLE.DOGBOARD then
        if (not d.hasDogboard) or (not d.hasDogboard:Exists()) then
            local ps = pickup:GetSprite()
            ps:ReplaceSpritesheet(1, "gfx/nothing.png")
            ps:LoadGraphics()
            local d = pickup:GetData()
            d.hasDogboard = Isaac.Spawn(mod.FF.Dogboard.ID, mod.FF.Dogboard.Var, mod.FF.Dogboard.Sub, pickup.Position, nilvector, pickup)
            d.hasDogboard.Parent = pickup
            d.hasDogboard:Update()
        end
    elseif d.hasDogboard and pickup.SubType ~= mod.ITEM.COLLECTIBLE.DOGBOARD then
        d.hasDogboard.Parent = nil
        d.hasDogboard:Update()
        d.hasDogboard:Remove()
        d.hasDogboard = nil
    end
end, 100)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, coll)
    local player = coll:ToPlayer()
    if player and player:IsExtraAnimationFinished() then
        if pickup.SubType == mod.ITEM.COLLECTIBLE.DOGBOARD then
            local d = pickup:GetData()
            local ps = pickup:GetSprite()
            if d.hasDogboard then
                d.hasDogboard.Parent = nil
                d.hasDogboard:Update()
                d.hasDogboard:Remove()
                d.hasDogboard = nil
                ps:ReplaceSpritesheet(1, "gfx/items/collectibles/collectibles_dogboard.png")
                ps:LoadGraphics()
            end
        end
    end
end, 100)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, item, rng)
	local player = mod:GetPlayerUsingItem()
	local data = player:GetData()
	
	data.launchedEnemyInfo = {zVel = -5, collision = -10, landFunc = function() SFXManager():Play(mod.Sounds.SkateboardLand, 0.4, 0, false, 1.3) end}
	sfx:Play(mod.Sounds.SkateboardJump, 1, 0, false, 1)
	data.hasDogboard:GetData().launchedEnemyInfo = {zVel = -5}
end, mod.ITEM.COLLECTIBLE.DOGBOARD)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	for i = 1, game:GetNumPlayers() do
        local p = Isaac.GetPlayer(i - 1)
        if p:HasCollectible(mod.ITEM.COLLECTIBLE.DOGBOARD) then
            p:GetData().hasDogboard:Remove()
			p:GetData().hasDogboard = nil
        end
    end
end)
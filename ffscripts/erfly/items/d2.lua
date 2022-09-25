local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, itemID, rng, player, useflags, activeslot)
    if useflags == useflags | UseFlag.USE_CARBATTERY then
        return {Discharge = false, Remove = false, ShowAnim = false}
    else
        local d = player:GetData()
        if d.holdingFFItem then
            d.holdingFFItem = nil
            d.HoldingFFItemBlankVisual = nil
            player:AnimateCollectible(mod.ITEM.COLLECTIBLE.D2, "HideItem", "PlayerPickup")
        else
            d.holdingFFItem = mod.ITEM.COLLECTIBLE.D2
            d.holdingFFItemSlot = activeslot
            d.HoldingFFItemBlankVisual = true
            player:AnimateCollectible(mod.ITEM.COLLECTIBLE.D2, "LiftItem", "PlayerPickup")
        end

        return {Discharge = false, Remove = false, ShowAnim = false}
    end
end, mod.ITEM.COLLECTIBLE.D2)

function mod:throwD2(player, data, aim)
    if player:HasTrinket(mod.ITEM.TRINKET.ETERNAL_CAR_BATTERY) then
        for i = 1, math.random(3,5) do
            local d2 = Isaac.Spawn(1000, 1742, 0, player.Position, aim:Resized(math.random(40,60)/10):Rotated(-15 + math.random(30)), player)
            d2:Update()
        end
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
        for i = -10, 10, 20 do
            local d2 = Isaac.Spawn(1000, 1742, 0, player.Position, aim:Resized(math.random(40,60)/10):Rotated(i), player)
            d2:Update()
        end
    else
        local d2 = Isaac.Spawn(1000, 1742, 0, player.Position, aim:Resized(math.random(40,60)/10), player)
        d2:Update()
    end
    sfx:Play(mod.Sounds.D2Toss, 1, 0, false, 1)
    if data.holdingFFItemSlot then
        player:DischargeActiveItem(data.holdingFFItemSlot)
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player)
    local vec = RandomVector()
    if player:GetAimDirection():Length() > 0.5 then
        vec = player:GetAimDirection()
    elseif player.Velocity:Length() > 0.5 then
        vec = player.Velocity
    end
    local d2 = Isaac.Spawn(1000, 1742, 1, player.Position, vec:Resized(math.random(40,60)/10), player)
    d2:Update()
    sfx:Play(mod.Sounds.D2Toss, 1, 0, false, 1.5)
    player:AnimateCollectible (-1, "UseItem", "")
end, mod.ITEM.CARD.GLASS_D2)

function mod:rollingD2AI(e)
	local d, sprite = e:GetData(), e:GetSprite()
	if not d.init then
        local player = e.SpawnerEntity and e.SpawnerEntity:ToPlayer() or Isaac.GetPlayer()
		--e:GetSprite():Play("spinthemeat", false)
		d.init = true
        d.flung = true

		e.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
	end
    if e.Velocity:Length() < 1 then
        d.dying = true
    end

    if d.dying then
        e.Velocity = nilvector
        if sprite:IsFinished("explode") then
            e:Remove()
        else
            mod:spritePlay(sprite, "explode")
        end
        if sprite:IsEventTriggered("dead") then
            if e.SubType == 1 then
                sfx:Play(mod.Sounds.ChainSnap, 0.3, 0, false, 1.5)
            else
                sfx:Play(mod.Sounds.ChainSnap, 0.3, 0, false, 1)
            end
        end
    else
        if d.flung then
            d.fallingAccel = d.fallingAccel or math.random(80,120)/100
            d.fallingSpeed = d.fallingSpeed or -math.random(10,12)
            d.fallingSpeed = d.fallingSpeed + d.fallingAccel
            e.SpriteOffset = e.SpriteOffset + Vector(0, d.fallingSpeed)
            if e.SpriteOffset.Y >= 0 then
                if e.SubType == 1 then
                    sfx:Play(mod.Sounds.D2Land, 0.3, 0, false, 1.5)
                else
                    sfx:Play(mod.Sounds.D2Land, 0.3, 0, false, 1)
                end
                d.flung = nil
                e.SpriteOffset = nilvector
            end
        end
        e.Velocity = e.Velocity * 0.99
        local swerveness = math.max(e.FrameCount * 0.1, 1)
        local turn = math.random(math.floor(swerveness * 10))/3
        if math.random(2) == 1 then
            turn = turn * -1
        end
        e.Velocity = e.Velocity:Rotated(turn)

        d.frame = d.frame or 0
        d.frame = d.frame + e.Velocity:Length() / 2.5
        sprite:SetFrame("spinthemeat", math.ceil(d.frame) % 19)

        if not d.flung then
            d.rollList = d.rollList or {}
            if e.FrameCount % 2 == 0 then
                for _, entity in pairs(Isaac.FindInRadius(e.Position, 150, EntityPartition.ENEMY)) do
                    local npc = entity:ToNPC()
                    if npc and npc:CanReroll() and npc.EntityCollisionClass >= 2 then
                        if npc.FrameCount <= 5 then
                            d.rollList[npc.InitSeed] = true
                        end
                        if not d.rollList[npc.InitSeed] then
                            if npc.Position:Distance(e.Position) < npc.Size + e.Size then
                                d.rollList.npc = true
                                game:RerollEnemy(npc)
                                sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 0.6, 0, false, 1.2)
                            end
                        end
                    end
                end
                for _, entity in pairs(Isaac.FindInRadius(e.Position, 150, EntityPartition.PICKUP)) do
                    local pickup = entity:ToPickup()
                    if pickup:CanReroll() and pickup.FrameCount > 10 and pickup.Variant ~= 100 then
                        if pickup.Position:Distance(e.Position) < pickup.Size + e.Size then
                            pickup:Morph(5,0,2,true,false,false)
                            sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 0.6, 0, false, 1.5)
                        end
                    end
                end
                for _, tear in ipairs(Isaac.FindInRadius(e.Position, 15, EntityPartition.TEAR)) do
                    tear = tear:ToTear()
                    local td = tear:GetData()
                    if not td.hasBeenD2Rolled then
                        if tear.TearFlags ~= tear.TearFlags | mod:SetTearFlag(123) then
                            sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 0.6, 0, false, 1.5)
                            mod:changeToRandomTearVariant(tear, true)
                            tear.Color = Color(math.random(200)/100, math.random(200)/100, math.random(200)/100, 1)
                            tear.TearFlags = tear.TearFlags | mod:SetTearFlag(math.random(81))
                            local randExtraDamage = math.random(50,150) / 100
                            tear.CollisionDamage = tear.CollisionDamage * randExtraDamage
                            tear.Scale = tear.Scale * randExtraDamage
                            tear.Velocity = tear.Velocity * (math.random(10,150) / 100)
                        end
                        td.hasBeenD2Rolled = true
                    end
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.rollingD2AI, 1742)
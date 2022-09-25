local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:telebombsPlayerUpdate(player, data)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.TELEBOMBS) then
        if (not data.telebombMarker) or (data.telebombMarker and not data.telebombMarker:Exists()) then
            local marker = Isaac.Spawn(1000, mod.FF.TelebombsCrosshair.Var, mod.FF.TelebombsCrosshair.Sub, player.Position, nilvector, player)
            marker.Parent = player
            marker:Update()
            data.telebombMarker = marker
        end
    end
end

function mod:handleTelebombBombInit(player, bomb)
    --if bomb.IsFetus then return end
    if bomb.Variant == 3 then return end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR) then
        if player:GetAimDirection():Length() > 0.3 then
            return
        end
    end
    local data = player:GetData()
    if data.telebombMarker and data.telebombMarker:GetData().isActive then
        player.Position = data.telebombMarker.Position
        player:SetColor(Color(1,1,1,1,1,1,1),3,1,true,false)
        sfx:Play(SoundEffect.SOUND_HELL_PORTAL1,1,0,false,1)
        data.telebombMarker:Remove()
        data.telebombMarker = nil

        for _, entity in pairs(Isaac.FindInRadius(player.Position, 40, EntityPartition.ENEMY)) do
            if not mod:isFriend(entity) then
                entity:TakeDamage(20, 0, EntityRef(player), 0)
            end
        end

        if bomb then
            bomb:SetExplosionCountdown(0)
        end
    end
end

function mod:telebombsMarkerUpdate(e)
    local sprite, d, room = e:GetSprite(), e:GetData(), game:GetRoom()
    mod:spritePlay(sprite, "Blink")
    e.DepthOffset = -100

    d.HeldPositions = d.HeldPositions or {}
    local posistionDelay = 22
    if e.Parent and e.Parent:ToPlayer():HasCollectible(mod.ITEM.COLLECTIBLE.TELEBOMBS) then
        local p = e.Parent:ToPlayer()
        table.insert(d.HeldPositions, p.Position)

        local isDisabled
        if e.Position:Distance(p.Position) <= 20 then
            isDisabled = true
        end
        if room:GetGridCollisionAtPos(e.Position) > 0 then
            print(p.GridCollisionClass)
            if p.GridCollisionClass == 5 then
                isDisabled = true
            end
        end

        if isDisabled then
            d.isActive = false
            e.Color = Color(1,1,1,0.2)
        else
            d.isActive = true
            e.Color = Color(1,1,1,1)
        end

        if #d.HeldPositions > posistionDelay then
            table.remove(d.HeldPositions, 1)
        end
        if d.HeldPositions[posistionDelay] then
            --e.Position = d.HeldPositions[10]
            e.Velocity = d.HeldPositions[1] - e.Position
        else
            e.Velocity = e.Velocity * 0.5
        end
    else
        e:Remove()
    end
end
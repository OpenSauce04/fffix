local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, ID, rng, player, useflags, activeslot)
    if useflags == useflags | UseFlag.USE_CARBATTERY then
        return {Discharge = false, Remove = false, ShowAnim = false}
    else
        local d = player:GetData()
        if d.holdingFFItem then
            d.holdingFFItem = nil
            d.holdingFFItemSlot = nil
            player:AnimateCollectible(ID, "HideItem", "PlayerPickup")
        else
            d.holdingFFItem = ID
            d.holdingFFItemSlot = activeslot
            player:AnimateCollectible(ID, "LiftItem", "PlayerPickup")
        end
        return {Discharge = false, Remove = false, ShowAnim = false}
    end
end, FiendFolio.ITEM.COLLECTIBLE.KALUS_HEAD)

local kaluhumVolume = 1

function mod:useHeldKaluHead(player, d, aim)
    if aim:Length() > 0.5 and player:GetActiveCharge(d.holdingFFItemSlot) > 0 then
        local item = player:GetActiveItem(d.holdingFFItemSlot)
        player:SetActiveCharge((player:GetActiveCharge(d.holdingFFItemSlot) + player:GetBatteryCharge(d.holdingFFItemSlot)) - 4, d.holdingFFItemSlot)
        if not d.kaluHasBeenUsed then
            d.kaluHasBeenUsed = true
            local visage = Isaac.Spawn(mod.FF.KalusVisage.ID, mod.FF.KalusVisage.Var, mod.FF.KalusVisage.Sub, player.Position, nilvector, player):ToEffect()
            visage:FollowParent(player)
            visage:Update()
            sfx:Play(mod.Sounds.BlackMoonIntro,kaluhumVolume,0,false,1)
        end
        if not (sfx:IsPlaying(mod.Sounds.BlackMoonLoop) or sfx:IsPlaying(mod.Sounds.BlackMoonIntro)) then
            sfx:Play(mod.Sounds.BlackMoonLoop,kaluhumVolume,0,true,1)
        end
        for _, enemy in pairs(Isaac.FindInRadius(player.Position + aim:Resized(150), 250, EntityPartition.ENEMY)) do
            if enemy.EntityCollisionClass >= 2 then
                local enemyVec = (enemy.Position - player.Position):Normalized()
                local dotProd = aim:Normalized():Dot(enemyVec)
                --print(dotProd)
                if dotProd >= 0.9 and enemy.Position:Distance(player.Position + aim:Resized(150)) < (125 + enemy.Size) then
                    if not enemy:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
                        if enemy:ToNPC() then
                            if enemy:ToNPC():IsBoss() and not enemy:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
                                enemy:AddFreeze(EntityRef(player), 360)
                            elseif not enemy:ToNPC():IsBoss() then
                                local slowness = 1
                                if player:HasTrinket(mod.ITEM.TRINKET.ETERNAL_CAR_BATTERY) then
                                    slowness = slowness * math.random(3,5)
                                elseif player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
                                    slowness = slowness * 2
                                end
                                enemy:AddFreeze(EntityRef(player), slowness)
                            end
                            enemy:GetData().KaluHeadFrozen = player
                        end
                    end
                    if player.FrameCount % 5 == 0 and not enemy:GetData().KaluHeadHurt then
                        local damageMult = 0.02
                        if player:HasTrinket(mod.ITEM.TRINKET.ETERNAL_CAR_BATTERY) then
                            damageMult = damageMult * math.random(3,5)
                        elseif player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
                            damageMult = damageMult * 2
                        end
                        enemy:TakeDamage(player.Damage * damageMult, 0, EntityRef(player), 0)
                        enemy:GetData().KaluHeadHurt = true
                    else
                        enemy:GetData().KaluHeadHurt = false
                    end
                end
            end
        end
    else
        if d.kaluHasBeenUsed then
            sfx:Stop(mod.Sounds.BlackMoonIntro)
            sfx:Stop(mod.Sounds.BlackMoonLoop)
            sfx:Play(mod.Sounds.BlackMoonEnd,kaluhumVolume,0,false,1)
            --player:DischargeActiveItem(d.holdingFFItemSlot)
            d.holdingFFItem = nil
            d.holdingFFItemSlot = nil
            player:AnimateCollectible(FiendFolio.ITEM.COLLECTIBLE.KALUS_HEAD, "HideItem", "PlayerPickup")
            d.kaluHasBeenUsed = false
        end 
    end
end

function mod:kalusVisageAI(e)
    local sprite, d = e:GetSprite(), e:GetData()
    e.SpriteScale = Vector(0.5,0.25)
    e.SpriteOffset = Vector(0, -15)
    e.DepthOffset = 500
    if e.Parent and e.Parent.Type == 1 then
        local player = e.Parent:ToPlayer()
        local pdata = player:GetData()
        if player:GetAimDirection():Length() > 0.5 then
            d.LookVec = d.LookVec or player:GetAimDirection():Normalized()
            d.LookVec = mod:Lerp(d.LookVec, player:GetAimDirection():Normalized(), 0.3)
            e.SpriteRotation = d.LookVec:GetAngleDegrees()
        end
        if not pdata.kaluHasBeenUsed then
            d.fadeout = d.fadeout or 0
            d.fadeout = d.fadeout + 1
            e.Color = Color(1,1,1,0.5 - d.fadeout/10, e.Color.RO, e.Color.GO, e.Color.BO)
            if d.fadeout >= 5 then
                e:Remove()
            end
        else
            local redness = math.sin(e.FrameCount / 10) / 10
            local blueness = math.cos(e.FrameCount / 10) / 10
            e.Color = Color(1,1,1,math.min(0.5, e.FrameCount/10),0.1 + redness,0,0.1 + blueness)
        end
    else
        e:Remove()
    end
end

function mod:kalusHeadPlayerRender(player, offset, d)
    --[[local icon = Sprite()
    icon:Load("gfx/effects/kalu_cone.anm2", true)
    icon:Play("Idle", true)
    icon.Color = Color(1,1,1,0.5)
    icon.Scale = Vector(0.3,0.3)
    local pos = Isaac.WorldToRenderPosition(player.Position) + game:GetRoom():GetRenderScrollOffset()
    icon:Render(pos, nilvector, nilvector)]]
end

function mod:kaluHeadEntityUpdate(npc, d)
    if d.KaluHeadFrozen then
        if not npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
            d.KaluHeadFrozen = nil
        elseif npc:IsDead() then
            local player
            if d.KaluHeadFrozen:Exists() and d.KaluHeadFrozen:ToPlayer() then
                player = d.KaluHeadFrozen:ToPlayer()
            else
                player = Isaac.GetPlayer()
            end
            local vec = RandomVector():Resized(10 * player.ShotSpeed)
            for i = 45, 360, 45 do
                player:FireTear(npc.Position + vec:Resized(npc.Size + 1):Rotated(i), vec:Rotated(i), true, true, false)
            end
        end
    end
end
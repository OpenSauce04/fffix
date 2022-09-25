local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local isBony = {
    [227] = true,
    [277] = true,
}


function mod.onUpdateMinichibisidian()
    local minichibisStrength = 0
    mod.AnyPlayerDo(function(player)
        if player:HasTrinket(FiendFolio.ITEM.ROCK.MINICHIBISIDIAN) then
            local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.MINICHIBISIDIAN)
            minichibisStrength = minichibisStrength + trinketPower
        end
    end)

    if minichibisStrength > 0 then
        local room = game:GetRoom()
        if room:GetFrameCount() % 120 == 30 then
            for i, v in ipairs(Isaac.GetRoomEntities()) do
                if v:IsVulnerableEnemy() and not v:IsBoss() then
                    --print(minichibisStrength)
                    if not isBony[v.Type] and math.random(100) <= minichibisStrength * 10 then
                        mod.scheduleForUpdate(function()
                            if v and v:Exists() and v:ToNPC().Pathfinder:HasPathToPos(Isaac.GetPlayer().Position, true) then
                                local storedHitPoints = v.HitPoints
                                local storedSize = v.Size
                                v:ToNPC():Morph(227, 0, 0, -1)
                                v.HitPoints = storedHitPoints
                                v:ToNPC().Scale = storedSize / 13
                                v:ToNPC().State = NpcState.STATE_INIT
                                v.Size = storedSize
                                v:SetColor(Color(1,1,1,1,1,1,1), 10, 1, true, false)
                                v.SpriteOffset = nilvector
                                v.Visible = true

                                sfx:Play(mod.Sounds.FlashZap, 1, 0, false, math.random(130,150)/100)

                                local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_ATTRACT, 10, v.Position, nilvector, v):ToEffect()
                                eff.MinRadius = 1
                                eff.MaxRadius = v:ToNPC().Scale * 10
                                eff.LifeSpan = 10
                                eff.Timeout = 10
                                eff.SpriteOffset = Vector(0, -v:ToNPC().Scale * 10)
                                eff.Color = Color(1,1,1,1,0,0,0)
                                eff.Visible = false
                                eff:FollowParent(v)
                                eff:Update()
                                eff.Visible = true
                            end
                        end, math.random(100))
                    end
                end
            end
        end
    end
end
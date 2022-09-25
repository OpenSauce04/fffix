local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

local debugFunny = false

function mod:TrihorfAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    if sprite:IsEventTriggered("TriShoot") then
        if debugFunny then
            
        else
            local vel = 8
            if game.Difficulty % 2 == 1 then
                vel = 10
            end
            mod:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR, npc)
            local params = ProjectileParams()
            --params.Variant = mod.FF.FrogProjectileBlood.Var
            npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(vel), 2, params)
            local effect = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc):ToEffect()
            effect.SpriteOffset = Vector(0,-6)
            effect.DepthOffset = npc.Position.Y * 1.25
            effect.Color = Color(1,1,1,0.8,0.1,0.1,0.1)
        end
    end
end

function mod:ThumbsUpFlyColl(npc, collider)
    if collider:ToPlayer() ~= nil then
        collider:ToPlayer():AnimateHappy()
    end
end

function mod:ThumbsUpFlyDeath(npc)
    for i = 0, game:GetNumPlayers() - 1 do
        local player = game:GetPlayer(i)
        player:AnimateSad()
    end
end

function mod:GoldenSpiderAI(npc, sprite, data)
    if npc.FrameCount % 3 == 0 then
        local sparkle = Isaac.Spawn(1000, 7003, 0, npc.Position, Vector.Zero, npc):ToEffect()
        sparkle.RenderZOffset = -5
        sparkle.SpriteOffset = Vector(-10 + math.random(20), -10 + math.random(20))
    end
    if npc:IsDead() and rng:RandomFloat() <= 0.5 then
        Isaac.Spawn(mod.FF.GoldenSpider.ID, mod.FF.GoldenSpider.Var, 0, game:GetRoom():GetRandomPosition(0), Vector.Zero, npc)
    end
end
local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:MayflyAI(npc, sprite, data)
    if not data.Init then
        local params = ProjectileParams()
        if mod:CheckStage("Dross", {45}) then
            npc.SplatColor = mod.ColorPoopyPeople
            params.Color = FiendFolio.ColorDrossWater
        else
            npc.SplatColor = mod.ColorWaterPeople
        end
        params.Variant = 4
        params.Spread = 1.5
        data.Params = params
        data.Init = true
    end
    if npc:IsDead() then
        local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
        npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(10), 1, data.Params)
    end
end
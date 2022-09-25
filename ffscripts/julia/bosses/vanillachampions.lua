local mod = FiendFolio
local game = Game()

local function findSelf(entity)
    for _, e in pairs(Isaac.FindByType(entity.Type, entity.Variant, entity.SubType, false, true)) do
        if e.Index == entity.Index then return e end
    end
end

local function isNearAlienLoki(entity)
    for _, e in pairs(Isaac.FindByType(69, 0, 1)) do
        if entity.Position:Distance(e.Position) < 5 then return e end
    end
    return nil
end

local function spawnDirections(spawner, start, goal, step)
    for i = start, goal, step do
        local vel = Vector.FromAngle(i) * 12
        local proj = Isaac.Spawn(9, 0, 0, spawner.Position, vel, spawner):ToProjectile()
        proj:AddProjectileFlags(ProjectileFlags.SMART)
        proj.Color = mod.ColorPsy
        proj:GetData().customSpawn = true
    end
end

--green alien loki
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.Variant == 0 and npc.SubType == mod.FF.AlienLokiChampion.Sub then
        local data = npc:GetData()
        local sprite = npc:GetSprite()

        if not data.initialized then
            --sprite:ReplaceSpritesheet(0, "gfx/bosses/champions/boss_loki_green.png")
            --sprite:LoadGraphics()
            data.initialized = true
        end

        if sprite:IsPlaying("TeleportUp") and sprite:IsEventTriggered("Jump") then
            npc:PlaySound(SoundEffect.SOUND_CUTE_GRUNT, 1, 0, false, 1)
            Isaac.Spawn(1000, 2, 0, npc.Position, Vector(0,0), npc)
            spawnDirections(npc, 18, 306, 72) --5 projectiles
        end
        
        if sprite:IsPlaying("Attack03") and sprite:IsEventTriggered("Shoot") then
            spawnDirections(npc, 18, 306, 72) --5 projectiles
        end

        if sprite:IsPlaying("Attack01") and sprite:IsEventTriggered("Shoot") then
            local frame = sprite:GetFrame()

            if frame == 25 or frame == 75 then --diagonals
                spawnDirections(npc, 45, 315, 90)
            else --cardinals
                spawnDirections(npc, 0, 360, 90)
            end
        end

    end
end, 69) --nice

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, proj)
    if proj.SpawnerEntity then
        if proj.FrameCount > 0 and proj.SpawnerEntity.Type == 69 and proj.SpawnerEntity.Variant == 0 and proj.SpawnerEntity.SubType == mod.FF.AlienLokiChampion.Sub and not proj:GetData().customSpawn then --if spawned by green loki and not custom, remove
            proj:Remove()
        end
    end
end)

--mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, eff) --remove his blood splash when firing projectiles (this is such a horrible way of doing it im going to puke)
--    local loki = isNearAlienLoki(eff)
--    if loki then
--        local sprite = loki:GetSprite()
--
--        if sprite:IsEventTriggered("Shoot") then
--            eff:Remove()
--        end
--    end
--end, 2)

mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, type, var, sub, pos, vel, spawner, seed) 
    if spawner then
        if spawner.Type == 69 and spawner.Variant == 0 and spawner.SubType == mod.FF.AlienLokiChampion.Sub then

            if type == 25 and var == 0 then --replace boom fly with 3-4 lightning flies
                local extra = math.random(2, 3)
                for i=1, extra do
                    Isaac.Spawn(170, 30, 0, Isaac.GetFreeNearPosition(spawner.Position, 0), vel, findSelf(spawner)) --i cant just use spawner for some fucked up reason
                end

                return {170, 30, 0, seed}
            end
        end
    end
end)



--yellow mask of infamy haha pee
local function spawnDirectionsMask(spawner, start, goal, step, scale)
    for i = start, goal, step do
        local vel = Vector.FromAngle(i) * 9
        local proj = Isaac.Spawn(9, 0, 0, spawner.Position, vel, spawner):ToProjectile()
        proj.Color = mod.ColorLemonYellow
        proj.Scale = scale
        proj:GetData().customSpawn = true
    end
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.Variant == 0 then
        local data = npc:GetData()
        local sprite = npc:GetSprite()
		
            if npc.Parent then
                if npc.Variant == 0 and npc.SubType == mod.FF.YellowMaskOfInfamy.Sub and npc.Parent.Type == 98 and npc.Parent.Variant == 0 and not data.yellowChampion then
                    data.yellowChampion = true
					--sprite:ReplaceSpritesheet(0, "gfx/bosses/champions/boss_maskofinfamy_yellow.png")
					--sprite:LoadGraphics()
					--[[local anim = sprite:GetAnimation()
					local frame = sprite:GetFrame()
					sprite:Load("gfx/bosses/champions/kidneyofinfamymask.anm2", true)
					sprite:SetFrame(anim, frame)]]
                end
            end		
		
	  if data.yellowChampion then


        if npc.State == 9 then --2nd phase
            --this does exactly what i need but it sucks because i cant remove the fucking skull symbol
            --trying to reimplement mask of infamy ai from the ground up was making me too depressed though so im leaving it like this for now
            if not npc:HasEntityFlags(EntityFlag.FLAG_FEAR) then 
                npc:AddEntityFlags(EntityFlag.FLAG_FEAR)
            end

            if npc.Velocity:Length() > 8 and npc.FrameCount % 10 == 0 then --spawn creep if "charging"
                local creep = Isaac.Spawn(1000, 24, 0, npc.Position, Vector(0, 0), npc):ToEffect()
                local scale = math.random(5, 15)/10
                creep.Scale = scale
                creep:Update()
            end                        
        end
	  end
    end
end, 97)

--yellow heart
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.Variant == 0 and npc.SubType == mod.FF.KidneyOfInfamy.Sub then
        local data = npc:GetData()
        local sprite = npc:GetSprite()

        if not data.initialized then                
            --[[sprite:ReplaceSpritesheet(0, "gfx/bosses/champions/boss_maskofinfamy_yellow.png")
            sprite:LoadGraphics()]]

            if npc.Child then
                if npc.Child.Type == 97 and npc.Child.Variant == 0 and npc.Child.SubType == mod.FF.YellowMaskOfInfamy.Sub then
                    npc.Child:GetData().yellowChampion = true
					--npc.Child:GetSprite():ReplaceSpritesheet(0, "gfx/bosses/champions/boss_maskofinfamy_yellow.png")
					--npc.Child:GetSprite():LoadGraphics()
					--[[local anim = npc.Child:GetSprite():GetAnimation()
					local frame = npc.Child:GetSprite():GetFrame()
					npc.Child:GetSprite():Load("gfx/bosses/champions/kidneyofinfamymask.anm2", true)
					npc.Child:GetSprite():SetFrame(anim, frame)]]
                end
            end

            data.initialized = true
        end        


        if sprite:IsPlaying("HeartAttack") then --projectile burst and creep spawning
            if sprite:GetFrame() == 19 then
                spawnDirectionsMask(npc, 0, 360, 90, 2)

                local creep = Isaac.Spawn(1000, 24, 0, npc.Position, Vector(0, 0), npc):ToEffect()
                creep.Scale = 1.5
                creep:Update()

            elseif sprite:GetFrame() == 21 then
                spawnDirectionsMask(npc, 0, 360, 90, 1.5)
                spawnDirectionsMask(npc, 45, 315, 90, 1.5)

            elseif sprite:GetFrame() == 23 then
                spawnDirectionsMask(npc, 0, 360, 90, 0.5)
                spawnDirectionsMask(npc, 45, 315, 90, 0.5)
                
            end
        end
    end
end, 98)

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, proj) --if spawned by kidney and not custom, remove
    if proj.SpawnerEntity then
        if proj.FrameCount > 0 and proj.SpawnerEntity.Type == 98 and proj.SpawnerEntity.Variant == 0 and proj.SpawnerEntity.SubType == mod.FF.KidneyOfInfamy.Sub and not proj:GetData().customSpawn then 
            proj:Remove()
        end
    end
end)



--golden baby plum
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.Variant == 0 and npc.SubType == mod.FF.GoldenPlum.Sub then
        local data = npc:GetData()
        local sprite = npc:GetSprite()

        if not data.initialized then                
            --[[sprite:ReplaceSpritesheet(0, "gfx/bosses/champions/boss_babyplum_golden.png")
            sprite:LoadGraphics()]]
            data.initialized = true

            data.fiendfolio_isGoldenPlumChampion = true
        end

        if npc.FrameCount % 10 == 0 then --gbf sparkles
            local sparkle = Isaac.Spawn(1000, 7003, 0, npc.Position, Vector(0, 0), npc):ToEffect()
            sparkle.RenderZOffset = -5
            sparkle.SpriteOffset = Vector(-10 + math.random(20), -40 + math.random(20))
        end

        if npc.FrameCount % 6 == 0 then
            if npc.State == 10 and (sprite:IsPlaying("Attack3Loop") or sprite:IsPlaying("Attack3BackLoop")) then --when bounce, fire an extra slow projectile every 4th frame (not so sure if this is the best way to approach this but eh)
                local params = ProjectileParams()
                params.FallingAccelModifier = -0.1
                params.Scale = math.random(4, 10)/10
                params.HeightModifier = -10
                
                npc:FireProjectiles(npc.Position, -(npc.Velocity):Normalized() + Vector((math.random() - 0.5) / 2, (math.random() - 0.5) / 2) * math.random(2, 4), 0, params)
            elseif npc.State == 8 then

            end
        end

        if npc.State == 9 and sprite:IsEventTriggered("Shoot") then --monstro coin blast
            for i = 1, 10 do
                local dir = math.random(0, 360)
                local vel = Vector.FromAngle(dir) * math.random(4, 7)

                local proj = Isaac.Spawn(9, 7, 0, npc.Position, vel, npc):ToProjectile()
                proj:AddProjectileFlags(ProjectileFlags.GREED)
                proj:GetData().customSpawn = true
                proj.FallingSpeed = -10 - math.random(20)
				proj.FallingAccel = 1 + (math.random() * 0.5)
            end
        elseif npc.State == 8 and sprite:IsPlaying("Attack1") then -- radius burst
            if not data.fireAngle then
                data.fireAngle = 0 --initialize angle
            elseif sprite:GetFrame() > 6 and sprite:GetFrame() < 31 and sprite:GetFrame() % 2 == 0 then
                for i = 0, 41, 41 do --shoot one shot and one further back in the circle
                    if data.fireAngle + i <= 360 then
                        local vel = Vector.FromAngle(data.fireAngle + i) * 7

                        local proj = Isaac.Spawn(9, 0, 0, npc.Position, vel, npc):ToProjectile()
                        proj:GetData().customSpawn = true
                        --proj.Color = mod.ColorGolden
                        proj:AddHeight(-30)
                    end
                end

                data.fireAngle = data.fireAngle + 30 --two circles
            elseif sprite:GetFrame() == 33 then
                data.fireAngle = 0 --reset fire angle
            end
        end
		
	for _, proj in ipairs(Isaac.FindByType(9, 0, 170, false, false)) do
        if proj.SpawnerType == 908 and proj.SpawnerVariant == 0 and not proj:GetData().customSpawn and proj.Position:Distance(npc.Position) < 20 and proj.FrameCount < 1 then
			if sprite:GetAnimation() == "Attack2" or sprite:GetAnimation() == "Attack1" then
				proj:Remove()
			else
				--proj.Color = mod.ColorGolden
			end
        end
	end

        -- print(npc.State)
    end
end, 908)

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, proj)
	if proj.Variant == 0 and proj.SubType == 170 and proj.SpawnerType == 908 and proj.SpawnerVariant == 0 then --golden plum projectile color
		local data = proj:GetData()
		if not data.GoldenPlum_ProjInitialized then
			proj.Color = mod.ColorGolden
			data.GoldenPlum_ProjInitialized = true
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, type, variant, sub, pos, vel, spawner, seed)
    if type == 1000 and variant == 22 and spawner then
        if spawner.Type == 908 and spawner.Variant == 0 and spawner.SubType == mod.FF.GoldenPlum.Sub then --golden plum
            return {1000, 24, 0, seed}
        end
    end
    if type == 9 and variant == 0 and sub == 0 and spawner then
        if spawner.Type == 908 and spawner.Variant == 0 and spawner.SubType == mod.FF.GoldenPlum.Sub then --golden plum
            return {9, 0, 170, seed}
        end
    end
end)

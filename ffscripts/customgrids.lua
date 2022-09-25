local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local grng = RNG()

--[[
function mod:CheckSpawnGrid(type, variant, subtype, gridindex, seed, stageAPIFirstLoad)
    if type ~= mod.FFID.Grid or true then return end

    local spawn = nil
    local data = nil
    local ret = {999, StageAPI.E.DeleteMeEffect.V, 0}
    if variant == 1013 then
        spawn = FiendFolio.KeyBlockGrid.Blue
    elseif variant == 1014 then
        spawn = FiendFolio.KeyBlockGrid.Green
    elseif variant == 1015 then
        spawn = FiendFolio.KeyBlockGrid.Red
    elseif variant == 1017 then
        spawn = FiendFolio.ChainBlockGrid.Blue
        data = { BreakDelay = subtype }
    elseif variant == 1018 then
        spawn = FiendFolio.ChainBlockGrid.Green
        data = { BreakDelay = subtype }
    elseif variant == 1019 then
        spawn = FiendFolio.ChainBlockGrid.Red
        data = { BreakDelay = subtype }
    elseif variant == 1016 then
        spawn = FiendFolio.FirePotGrid
    elseif variant == 1020 then
        spawn = FiendFolio.ShampooGrid
	elseif variant == 1031 then
        spawn = FiendFolio.BeehiveGrid
    elseif variant == 1032 then
        spawn = FiendFolio.SpiderNestGrid
    elseif variant == 1024 then
        spawn = FiendFolio.LilyPadGrid
    elseif variant == 1025 then
        spawn = FiendFolio.RubberRockGrid
        ret = {1002, 0, 0}
    elseif variant == 1026 then
        spawn = FiendFolio.CursedPoopGrid
        ret = {1500, 0, 0}
    elseif variant == 1027 then
        spawn = FiendFolio.PlatinumPoopGrid
        ret = {1496, 0, 0}
    elseif variant == 1028 then
        spawn = FiendFolio.PetrifiedPoopGrid
        ret = {1496, 0, 0}
    elseif variant == 1034 then
        spawn = FiendFolio.KeyBlockGrid.Gray
    elseif variant == 1035 then
        spawn = FiendFolio.ChainBlockGrid.Gray
        data = { BreakDelay = subtype }
    elseif variant == 1036 then
        spawn = FiendFolio.DogDooGrid
        ret = {1496, 0, 0}
    elseif variant == 1037 then
        spawn = FiendFolio.EvilPoopGrid
    elseif variant == 1038 then
        spawn = FiendFolio.FlippedBucketGrid
        ret = {1002, 0, 0}
    end

    if spawn then
        if game:GetRoom():IsFirstVisit() or stageAPIFirstLoad then
            spawn:Spawn(gridindex, true, false, data)
        end

        return ret
    end
end

function mod:checkPoopSpawners(npc)
    if not npc:Exists() or true then return end
    local data = {}
    local room = game:GetRoom()
	if npc.Variant == 1020 then
		FiendFolio.ShampooGrid:Spawn(room:GetGridIndex(npc.Position), true, false, data)
		npc:Remove()
	elseif npc.Variant == 1031 then
		FiendFolio.BeehiveGrid:Spawn(room:GetGridIndex(npc.Position), true, false, data)
		npc:Remove()
    elseif npc.Variant == 1032 then
        FiendFolio.SpiderNestGrid:Spawn(room:GetGridIndex(npc.Position), true, false, data)
		npc:Remove()
    elseif npc.Variant == 1037 then
        data.Radius = npc.SubType * 0.01
        data.AuraScale = Vector(data.Radius, data.Radius)
        FiendFolio.EvilPoopGrid:Spawn(room:GetGridIndex(npc.Position), true, false, data)
		npc:Remove()
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.checkPoopSpawners, mod.FFID.Poop)]]

FiendFolio.FirePotGrid = StageAPI.CustomGrid("FFFirePot", {
    BaseType = GridEntityType.GRID_WALL,
    Anm2 = "stageapi/none.anm2",
    Animation = "None",
    SpawnerEntity = {Type = mod.FFID.Grid, Variant = 1016}
})
FiendFolio.ShampooGrid = StageAPI.CustomGrid("FFShampoo", {
    BaseType = GridEntityType.GRID_POOP,
    Anm2 = "gfx/grid/grid_shampoo.anm2",
    Animation = "State1",
    OverrideGridSpawns = true,
    RemoveOnAnm2Change = true,
    PoopExplosionColor = Color(0,0,0,0.7,57 / 255,133 / 255,197 / 255),
    PoopGibSheet = "gfx/grid/grid_shampoo_gibs.png",
    SpawnerEntity = {Type = mod.FFID.Poop, Variant = 1020}
})
FiendFolio.LilyPadGrid = StageAPI.CustomGrid("FFLilyPad", {
    BaseType = GridEntityType.GRID_PIT,
    NoOverrideGridSprite = true,
    SpawnerEntity = {Type = mod.FFID.Grid, Variant = 1024}
})
FiendFolio.BeehiveGrid = StageAPI.CustomGrid("FFBeehive", {
    BaseType = GridEntityType.GRID_POOP,
    Anm2 = "gfx/grid/beehive/beehive_beeless.anm2",
    Animation = "State1",
    OverrideGridSpawns = true,
    RemoveOnAnm2Change = true,
    PoopExplosionColor = Color(0,0,0,0.7,255 / 255,165 / 255,0 / 255),
    PoopGibSheet = "gfx/grid/beehive/grid_beehive_gibs.png",
    SpawnerEntity = {Type = mod.FFID.Poop, Variant = 1031}
})

function FiendFolio.SetPoopSpriteState(grid, sprite)
    if grid.State == 1000 then
        sprite:SetFrame("State5", 4)
    elseif grid.State > 750 then
        sprite:SetFrame("State4", 4)
    elseif grid.State > 500 then
        sprite:SetFrame("State3", 4)
    elseif grid.State > 250 then
        sprite:SetFrame("State2", 4)
    else
        sprite:SetFrame("State1", 4)
    end
end

StageAPI.AddCallback("FiendFolio", "POST_SPAWN_CUSTOM_GRID", 1, function(customGrid)
    local grid = customGrid.GridEntity
	local sprite = grid:GetSprite()
    
    if mod:CheckStage("Dross", {45}) then --Load Dross skin
        sprite:ReplaceSpritesheet(0, "gfx/grid/grid_shampoo_dross.png")
        customGrid.GridConfig.PoopGibSheet = "gfx/grid/grid_shampoo_dross_gibs.png"
        customGrid.GridConfig.PoopExplosionColor = Color(0,0,0,1,120 / 255,135 / 255,90 / 255)
        sprite:LoadGraphics()
    end
	FiendFolio.SetPoopSpriteState(grid, sprite)
end, "FFShampoo")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_DESTROY", 1, function(customGrid, projectile)
    local rng = customGrid.RNG
	local room = Game():GetRoom()
	local dripChances = 4
	if mod.anyPlayerHas(TrinketType.TRINKET_PETRIFIED_POOP, true) then
		dripChances = 2
	end

    local pos = customGrid.Position
    if not customGrid:IsOnGrid() then
        if customGrid.ThrownByPlayer then
            dripChances = 0

            for i = 1, 8 do
                local vel = Vector.FromAngle(i * (360 / 8)) * 6
                Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLUE, 0, pos, vel, nil)
            end
        else
            dripChances = 100
        end
    end

    if game.Challenge == mod.challenges.theGauntlet then
        dripChances = 100
    end

    local petrifiedGelMultiplier = mod.GetGlobalTrinketMultiplier(TrinketType.TRINKET_PETRIFIED_GEL)

	if petrifiedGelMultiplier == 0 and rng:RandomInt(10) < dripChances then
		Isaac.Spawn(mod.FF.Drop.ID, mod.FF.Drop.Var, 0, pos, Vector.Zero, nil)
	else
		local petrifiedPoopMultiplier = mod.GetGlobalTrinketMultiplier(TrinketType.TRINKET_PETRIFIED_POOP)
		local rollDivisor = 1 + 2 * petrifiedGelMultiplier + petrifiedPoopMultiplier
		local rollChance = math.floor(200 / rollDivisor)
		local spawns = rng:RandomInt(rollChance)

		if spawns < 4 then	--Key
			Isaac.Spawn(5, 30, 0, pos, Vector.Zero, nil)
		elseif spawns < 8 then	--Half Soul
			Isaac.Spawn(5, 10, 8, pos, Vector.Zero, nil)
		elseif spawns < 24 then	--Penny
            Isaac.Spawn(5, 20, 0, pos, Vector.Zero, nil)
		end
	end

	if mod.anyPlayerHas(TrinketType.TRINKET_BROWN_CAP, true) then
		for i = 90, 360, 90 do
			local bubl = Isaac.Spawn(mod.FF.Bubble.ID, mod.FF.Bubble.Var, FiendFolio.Bubble.EXPLOSIVE, pos + Vector(14,14):Rotated(i), Vector(4,4):Rotated(i), nil)
			bubl:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			bubl:Update()
		end
	end
end, "FFShampoo")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_DIRTY_MIND_SPAWN", 1, function(customGrid, familiar)
    local player = familiar.Player

    local dip = player:ThrowFriendlyDip(666, familiar.Position, familiar.TargetPosition)
	dip.SplatColor = Color(0,0,0,0.7,57 / 255,133 / 255,197 / 255)

    familiar.Visible = false
    familiar:Remove()
end, "FFShampoo")

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, dip)
	if dip.SubType == 666 then
		local d = dip:GetData()
		local sprite = dip:GetSprite()
		local target = mod.FindClosestEnemy(dip.Position, 1000, true) or dip.Player
		local r = dip:GetDropRNG()

		dip.SplatColor = Color(0,0,0,0.7,57 / 255,133 / 255,197 / 255)

		if not d.init then
			d.state = "Idle"
			d.dmg = true

			d.randwait = r:RandomInt(5)
			d.squidgecount = 5
			d.StateFrame = 0
			d.init = true
			d.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		elseif d.init then
			d.StateFrame = d.StateFrame + 1
		end

		if d.currentAnim then
			d.currentFrame = d.currentFrame + 1
			sprite:SetFrame(d.currentAnim, d.currentFrame)
			sprite.FlipX = d.currentFlip
		end

		if d.state == "Idle" then
			d.currentAnim = nil
			d.currentFrame = nil
			d.currentFlip = nil

			if sprite:IsPlaying("Idle") and d.StateFrame > 10 + d.randwait then
				if r:RandomInt(d.squidgecount) == 0 then
					dip.Velocity = Vector.Zero
					d.state = "Submerge"
					sfx:Play(mod.Sounds.DripSuck,0.4,0,false,1)

					d.currentAnim = "Submerge"
					d.currentFrame = -1
					d.currentFlip = sprite.FlipX
				end
			end

			if sprite:IsFinished("Move") then
				d.randwait = r:RandomInt(5)
				d.squidgecount = math.max(1,d.squidgecount - 1)
				d.StateFrame = 0
			end
		elseif d.state == "Submerge" then
			dip.Velocity = Vector.Zero
			if d.currentAnim == "Submerge" and d.currentFrame >= 19 then
				dip.Velocity = Vector.Zero
				d.state = "Fall"
				d.StateFrame = 0
				dip.Position = game:GetRoom():FindFreeTilePosition(target.Position, 40) + RandomVector()*5

				d.currentAnim = "Fall"
				d.currentFrame = -1
				d.currentFlip = sprite.FlipX
			elseif d.currentAnim == "Submerge" and d.currentFrame == 13 then
				d.dmg = false
				d.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			end
		elseif d.state == "Fall" then
			dip.Velocity = Vector.Zero
			if d.StateFrame < 12 then
				dip.SpriteOffset = Vector(0, -300 + d.StateFrame * 25)
				if d.currentAnim == "Fall" and d.currentFrame == 7 then
					d.currentFrame = -1
				end
			else
				dip.SpriteOffset = Vector(0, 0)
				d.state = "Land"
				d.dmg = true
				d.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				sfx:Play(mod.Sounds.SplashSmall,1,0,false,1)
				--sfx:Play(mod.Sounds.LandSoft,1,2,false,1.5)

				d.currentAnim = "Land"
				d.currentFrame = -1
				d.currentFlip = sprite.FlipX
			end
		elseif d.state == "Land" then
			dip.Velocity = Vector.Zero
			if d.currentAnim == "Land" and d.currentFrame == 23 then
				d.state = "Idle"
				d.randwait = r:RandomInt(5)
				d.squidgecount = 5
				d.StateFrame = 0
			end
		end

		dip.EntityCollisionClass = d.EntityCollisionClass
	end
end, FamiliarVariant.DIP)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, damage, flag, source)
    if source.Entity then
		local src = source.Entity
		if src.Type == EntityType.ENTITY_FAMILIAR and src.Variant == FamiliarVariant.DIP and src.SubType == 666 and not src:GetData().dmg then
			return false
        end
    end
end)

StageAPI.AddCallback("FiendFolio", "POST_SPAWN_CUSTOM_GRID", 1, function(customGrid)
    local grid = customGrid.GridEntity
	local sprite = grid:GetSprite()

	FiendFolio.SetPoopSpriteState(grid, sprite)
end, "FFBeehive")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_DESTROY", 1, function(customGrid, projectile)
    local pos = customGrid.Position
    local rng = customGrid.RNG
    local rollchances = 6
    local spawns = rng:RandomInt(rollchances)
    local bee
    if spawns == 1 then	--HONEY PENNY
        Isaac.Spawn(5, 20, 215, pos, Vector.Zero, nil)
    elseif spawns == 2 then	--Emeny :(((
        bee = Isaac.Spawn(256, 0, 0, pos, Vector.Zero, nil)
    elseif spawns == 3 then
        local dummynpc = Isaac.Spawn(17,0,0,pos,Vector.Zero,nil)
        mod.cheekyspawn(pos, dummynpc, pos, 281, 0, 0)
        dummynpc:Remove()
    elseif spawns == 4 and rng:RandomFloat() <= 0.4 then
       --bee = Isaac.Spawn(mod.FF.Zingy.ID, mod.FF.Zingy.Var, 0, pos, Vector.Zero, nil)
       bee = Isaac.Spawn(mod.FF.Beeter.ID, mod.FF.Beeter.Var, 0, pos, Vector.Zero, nil)
    elseif spawns == 5 and rng:RandomFloat() <= 0.1 then
        bee = Isaac.Spawn(mod.FF.Zingling.ID, mod.FF.Zingling.Var, 0, pos, Vector.Zero, nil)
        local d = bee:GetData()
        d.state = "drop"
        d.deadstate = rng:RandomInt(3) + 1
        d.init = true
    end
    if bee then
        bee:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
    local honeycolor = Color(1,1,1,1,0,0,0)
    honeycolor:SetColorize(5.5, 3.5, 1, 1)
    local creep = Isaac.Spawn(1000, EffectVariant.CREEP_BROWN, 0, pos, Vector(0,0), nil):ToEffect()
    creep.SpriteScale = Vector(2, 2)
    creep:SetTimeout(8000)
    creep:Update()
    creep:GetSprite().Color = honeycolor
end, "FFBeehive")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_DIRTY_MIND_SPAWN", 1, function(customGrid, familiar)
    local player = familiar.Player
	for i = 1, math.random(2) + 1 do
		local dip = player:ThrowFriendlyDip(668, familiar.Position, familiar.TargetPosition)
		dip.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS

		local honeycolor = Color(1,1,1,1,0,0,0)
		honeycolor:SetColorize(5.5, 3.5, 1, 1)
		dip.SplatColor = honeycolor
	end
    familiar.Visible = false
    familiar:Remove()
end, "FFBeehive")

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, dip)
	if dip.SubType == 668 then
		dip.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		local honeycolor = Color(1,1,1,1,0,0,0)
		honeycolor:SetColorize(5.5, 3.5, 1, 1)
		dip.SplatColor = honeycolor
	end
end, FamiliarVariant.DIP)

function mod.firepotAI(customGrid)
    local grid = customGrid.GridEntity
    local sprite = customGrid.Data.Effect:GetSprite()
	if sprite:IsFinished("Extinguish") then
		sprite:Play("Idle", true)
	elseif sprite:IsFinished("Ignite") then
		sprite:Play("Burning", true)
    end
    local players = Isaac.FindInRadius(grid.Position, 100, EntityPartition.PLAYER)
    local room = game:GetRoom()
    if #players > 0 and room:GetFrameCount() >= 30 then
        for _, p in pairs(players) do
            if p.Position:DistanceSquared(grid.Position) <= (p.Size + 24) ^ 2 then
                p = p:ToPlayer()
                if p.CanFly then
					if (not REVEL) or (REVEL and not p:HasCollectible(REVEL.ITEM.FFIRE.id)) then
						p:TakeDamage(1, 0, EntityRef(customGrid.Data.Effect), 0)
					end
                end
            end
        end

		if sprite:IsPlaying("Idle") or sprite:IsFinished("Idle") then
			sfx:Play(mod.Sounds.Lighter, 1.3, 0, false, 1)
			sprite:Play("Ignite", true)
		end
	else
		if sprite:IsPlaying("Burning") or sprite:IsFinished("Burning") then
			sfx:Play(mod.Sounds.WingFlap, 0.5, 0, false, 1)
			sprite:Play("Extinguish", true)
		end
	end
    if room:GetFrameCount() == 1 then
        if mod.roomBackdrop == 10 or mod.GetEntityCount(150,1000,10) > 0 then
            sprite:Load("gfx/grid/firepot_flesh.anm2", true)
            sprite:ReplaceSpritesheet(0, "gfx/grid/firepot_flesh_morbus.png")
            sprite:LoadGraphics()
            sprite:Play("Idle")
        end
    end
end

function mod.firepotSpawn(customGrid)
    -- use an effect because grid sprites update their depth when updated through the api :))))))
    customGrid.Data.Effect = Isaac.Spawn(1000, 1016, 0, customGrid.GridEntity.Position, Vector.Zero, nil)

    local room = game:GetRoom()
	local backid = room:GetBackdropType()
	if backid == BackdropType.WOMB or backid == BackdropType.UTERO or backid == BackdropType.SCARRED_WOMB then
        local sprite = customGrid.Data.Effect:GetSprite()
		sprite:Load("gfx/grid/firepot_flesh.anm2", true)
		sprite:Play("Idle")
		if backid == BackdropType.SCARRED_WOMB then
			sprite:ReplaceSpritesheet(0, "gfx/grid/firepot_scarred.png")
			sprite:LoadGraphics()
        elseif backid == BackdropType.UTERO then
            sprite:ReplaceSpritesheet(0, "gfx/grid/firepot_flesh_utero.png")
            sprite:LoadGraphics()
		end
	elseif backid == BackdropType.CORPSE or backid == BackdropType.CORPSE2 or backid == BackdropType.CORPSE3 then
        local sprite = customGrid.Data.Effect:GetSprite()
		sprite:Load("gfx/grid/firepot_flesh.anm2", true)
		sprite:Play("Idle")
        if mod.roomBackdrop == 10 or mod.GetEntityCount(150,1000,10) > 0 then
            sprite:ReplaceSpritesheet(0, "gfx/grid/firepot_flesh_morbus.png")
            sprite:LoadGraphics()
		elseif backid == BackdropType.CORPSE then
            sprite:ReplaceSpritesheet(0, "gfx/grid/firepot_flesh_corpse.png")
            sprite:LoadGraphics()
        elseif backid == BackdropType.CORPSE2 then
            sprite:ReplaceSpritesheet(0, "gfx/grid/firepot_flesh_corpse_2.png")
            sprite:LoadGraphics()
        elseif backid == BackdropType.CORPSE3 then
            sprite:ReplaceSpritesheet(0, "gfx/grid/firepot_flesh_corpse_3.png")
            sprite:LoadGraphics()
		end
	elseif backid == BackdropType.MAUSOLEUM or (backid >= BackdropType.MAUSOLEUM2 and backid <= BackdropType.MAUSOLEUM4) or backid == BackdropType.DARKROOM then
        local sprite = customGrid.Data.Effect:GetSprite()
        sprite:Load("gfx/grid/firepot_mausoleum.anm2", true)
        sprite:Play("Idle")
	elseif backid == BackdropType.GEHENNA then
        local sprite = customGrid.Data.Effect:GetSprite()
        sprite:Load("gfx/grid/firepot_gehenna.anm2", true)
        sprite:Play("Idle")
	end
end

function mod.firepotRemove(customGrid)
    if customGrid.Data.Effect then customGrid.Data.Effect:Remove() end
end

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_UPDATE", 0, mod.firepotAI, FiendFolio.FirePotGrid.Name)
StageAPI.AddCallback("FiendFolio", "POST_SPAWN_CUSTOM_GRID", 1, mod.firepotSpawn, FiendFolio.FirePotGrid.Name)
StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_REMOVE", 1, mod.firepotRemove, FiendFolio.FirePotGrid.Name)

local function checkLilyPadStepped(pos, index, doExtraChecks)
    local steppedOn
    local players = Isaac.FindByType(EntityType.ENTITY_PLAYER, -1, -1, false, false)
    local room = game:GetRoom()
    for _, player in ipairs(players) do
        if room:GetGridIndex(player.Position) == index or (doExtraChecks and player.Position:DistanceSquared(pos) <= (20 + player.Size) ^ 2) then
            steppedOn = true
        end
    end

    if not steppedOn and doExtraChecks then
        local ents = Isaac.FindInRadius(pos, 20, EntityPartition.ENEMY)
        for _, ent in ipairs(ents) do
            if ent.GridCollisionClass == EntityGridCollisionClass.GRIDCOLL_GROUND then
                steppedOn = true
            else
                for _, pitent in ipairs(FiendFolio.PitEnemies) do
                    if ent.Type == pitent[1] and ent.Variant == pitent[2] then
                        steppedOn = true
                        break
                    end
                end
            end

            if steppedOn then
                break
            end
        end
    end

    return steppedOn
end

function FiendFolio.LoadPadSkin(sprite, skin)
    local prefix = "lily_pad"
    local room = game:GetRoom()
    if room:GetBackdropType() == BackdropType.DARKROOM then
        prefix = "pad_darkroom"
	elseif room:GetBackdropType() == BackdropType.CHEST then
        return
    end

    sprite:ReplaceSpritesheet(0, "gfx/grid/lily pad/" .. prefix .. tostring(skin) .. ".png")
    sprite:LoadGraphics()
end

function mod.lilyPadAI(customGrid)
    local persistData = customGrid.PersistentData
    local data = customGrid.Data
    local grid = customGrid.GridEntity
    local index = customGrid.GridIndex
    local sprite = data.Effect:GetSprite()

    local room = game:GetRoom()
    if persistData.State == "Idle" then
        if room:GetGridPath(index) == 3000 then
            room:SetGridPath(index, 0)
        end

        grid.CollisionClass = GridCollisionClass.COLLISION_NONE

        if grid.State == 1 then -- bridge
            sprite:Play("Break", true)
            persistData.State = "Broken"
        else
            local steppedOn = checkLilyPadStepped(grid.Position, index, persistData.Stepped)
            if steppedOn then
                if not sprite:IsPlaying("Stepped On") then
                    sprite:Play("Stepped On", true)
                end

                persistData.Stepped = true
            elseif persistData.Stepped then
                sprite:Play("Sink", true)
                persistData.State = "Fallen"
                persistData.FallenTime = 90
                persistData.Stepped = nil
            else
                mod:spritePlay(sprite, "Normal")
            end
        end
    elseif persistData.State == "Raise" then
        if room:GetGridPath(index) ~= 3000 then
            room:SetGridPath(index, 3000)
        end

        grid.CollisionClass = GridCollisionClass.COLLISION_PIT
        local steppedOn = checkLilyPadStepped(grid.Position, index, true)
        if steppedOn then
            persistData.State = "Fallen"
            if sprite:IsPlaying("Raise") then
                local sinkFrame = 15 - sprite:GetFrame()
                sprite:Play("Sink", true)
                if sinkFrame > 0 then
                    for i = 1, sinkFrame do
                        sprite:Update()
                    end
                end
            end
        elseif sprite:IsFinished("Raise") then
            persistData.State = "Idle"
        else
            mod:spritePlay(sprite, "Raise")
        end
    elseif persistData.State == "Fallen" then
        if room:GetGridPath(index) ~= 3000 then
            room:SetGridPath(index, 3000)
        end

        grid.CollisionClass = GridCollisionClass.COLLISION_PIT

        if persistData.FallenTime then
            persistData.FallenTime = persistData.FallenTime - 1
            if persistData.FallenTime <= 0 then
                persistData.FallenTime = nil
            end
        else
            local steppedOn = checkLilyPadStepped(grid.Position, index, true)
            if not steppedOn then
                local newSkin = math.random(1, 4)
                if newSkin ~= persistData.Skin then
                    persistData.Skin = newSkin
                    FiendFolio.LoadPadSkin(sprite, persistData.Skin)
                end

                persistData.State = "Raise"
            end
        end
    end
end

function mod.lilyPadSpawn(customGrid)
    local persistData = customGrid.PersistentData
    local data = customGrid.Data
    data.Effect = Isaac.Spawn(1000, 1024, 0, customGrid.GridEntity.Position, Vector.Zero, nil)

    data.Effect:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)
    data.Effect.RenderZOffset = -10000

    persistData.Stepped = false
    persistData.State = "Idle"

    if not persistData.Skin then
        persistData.Skin = math.random(1, 4)
    end

    local sprite = data.Effect:GetSprite()
    local room = game:GetRoom()
    if room:GetBackdropType() == BackdropType.DARKROOM then
        sprite:Load("gfx/grid/lily pad/pad_darkroom.anm2", true)
    elseif room:GetBackdropType() == BackdropType.CHEST then
        sprite:Load("gfx/grid/lily pad/pad_chest.anm2", true)
    end

    if persistData.Skin ~= 1 then
        FiendFolio.LoadPadSkin(sprite, persistData.Skin)
    end

    sprite:Play("Normal", true)
end

function mod.lilyPadRemove(customGrid)
    if customGrid.Data.Effect and customGrid.Data.Effect:Exists() then customGrid.Data.Effect:Remove() end
end

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_UPDATE", 1, mod.lilyPadAI, FiendFolio.LilyPadGrid.Name)
StageAPI.AddCallback("FiendFolio", "POST_SPAWN_CUSTOM_GRID", 1, mod.lilyPadSpawn, FiendFolio.LilyPadGrid.Name)
StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_REMOVE", 1, mod.lilyPadRemove, FiendFolio.LilyPadGrid.Name)

FiendFolio.NPCBlockerGrid = StageAPI.CustomGrid("FFNPCBlocker", GridEntityType.GRID_WALL, nil, "stageapi/none.anm2", "None")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_UPDATE", 1, function (customGrid)
    local persistData = customGrid.PersistentData
    if not (persistData.Parent and persistData.Parent:Exists()) then
        game:GetRoom():RemoveGridEntity(customGrid.GridIndex, 0, false)
    end
end, FiendFolio.NPCBlockerGrid.Name)

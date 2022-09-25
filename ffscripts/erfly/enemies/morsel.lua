local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:morselAI(npc, subType)
    local d = npc:GetData()
    local sprite = npc:GetSprite();
    local target = npc:GetPlayerTarget()
    local path = npc.Pathfinder
    local room = game:GetRoom()
	local isSlick = (npc.Variant == mod.FF.Slick.Var)
	local isStump = (npc.Variant == mod.FF.Stump.Var)
    
    if not d.init then
        if subType > 1 then
            local Vec = RandomVector()*10
            for i = 1, subType do
                local baby = Isaac.Spawn(mod.FF.Morsel.ID, npc.Variant, 0, npc.Position + Vec:Rotated(360/i), nilvector, npc):ToNPC()
                baby.SpawnerEntity = npc.SpawnerEntity
				if npc:IsChampion() and i == 1 then
					baby:MakeChampion(69, npc:GetChampionColorIdx(), true)
					baby.HitPoints = baby.MaxHitPoints
				end
				if not (isSlick or isStump) then
					if d.UglyBaby then
						baby:GetData().UglyBaby = true
					elseif (d.FromIceHazard or (REVEL and REVEL.STAGE.Glacier:IsStage())) then
						baby:GetData().GlacierReskin = true
					end
				end
            end
			d.FuckinPoser = true
            npc:Remove()
        end
        d.init = true

		if not (isSlick or isStump) then
			if d.UglyBaby then
				mod:ReplaceEnemySpritesheet(npc, "gfx/enemies/morsel/morsel_mouthful", 0)
				mod:ReplaceEnemySpritesheet(npc, "gfx/enemies/morsel/morsel_mouthful", 1)
			elseif (d.FromIceHazard or (REVEL and REVEL.STAGE.Glacier:IsStage())) or d.GlacierReskin then
				npc.SplatColor = Color(0, 0.2, 0.8, 1, 0,20/255,70/255)
				mod:ReplaceEnemySpritesheet(npc, "gfx/enemies/morsel/morsel_glacier", 0)
				mod:ReplaceEnemySpritesheet(npc, "gfx/enemies/morsel/morsel_glacier", 1)
			end
		end

        d.head = math.random(177)-1
		if not isStump then
        	sprite:SetOverlayFrame("Head",d.head)
		else
			sprite:PlayOverlay("Gush")
		end
    --	d.AttackPos = RandomVector()*math.random(20)
    --	d.AttackVel = math.random(50)/10
    elseif d.init then
		if not isStump then
        	sprite:SetOverlayFrame("Head",d.head)
		else
			sprite:PlayOverlay("Gush")
		end

        local targetpos = mod:confusePos(npc, target.Position, 5, nil, isStump)
        if mod:isScare(npc) then
            local targetvelocity = (targetpos - npc.Position):Resized(-5)
            npc.Velocity = mod:Lerp(npc.Velocity, targetvelocity, 0.25)
        elseif room:CheckLine(npc.Position,targetpos,0,1,false,false) then
            local targetvelocity = (targetpos - npc.Position):Resized(5)
            npc.Velocity = mod:Lerp(npc.Velocity, targetvelocity, 0.25)
        else
            path:FindGridPath(targetpos, 0.7, 1, true)
        end

    end

    if math.random(175) == 1 and not isStump then
        npc:PlaySound(165,0.3,0,false,2)
    end

	if (isSlick or isStump) and npc.FrameCount % 2 == 0 then
		local creep = Isaac.Spawn(1000,22,0,npc.Position,Vector.Zero,npc):ToEffect()
		creep:SetTimeout(20)
		if isStump then
			creep.Scale = creep.Scale * 0.5
		else
			creep.Scale = creep.Scale * 0.35
		end
		creep:Update()
	end

	if npc:IsDead() and not d.FuckinPoser then
		if isSlick and mod:RandomInt(1,2) == 2 then
			local stump = Isaac.Spawn(mod.FF.Stump.ID, mod.FF.Stump.Var, 0, npc.Position, Vector.Zero, npc):ToNPC()
			stump:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			if npc:IsChampion() then
				stump:MakeChampion(69, npc:GetChampionColorIdx(), true)
				stump.HitPoints = stump.MaxHitPoints
			end
		end
	end

    --Play animations
    if npc.Velocity:Length() > 1 then
        npc:AnimWalkFrame("WalkHori","WalkVert",0)
    else
        sprite:SetFrame("WalkVert", 0)
    end
end

function mod:morselInit(npc, subType)
    if subType > 1 then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end

function mod:falafelAI(npc)
	local d = npc:GetData()
	local sprite = npc:GetSprite();
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder

	if not d.init then
		d.state = d.state or "idle"
		d.head = math.random(60) - 1
		
		if npc.SubType == 1 then
			local color = Color(1,1,1,1,0,0,0)
			color:SetColorize(1,1,1,1)
			npc.SplatColor = color
		end
		
		d.init = true
	end

	if d.state == "idle" then
		sprite:SetOverlayFrame("Head",d.head)

		local targetpos = mod:confusePos(npc, target.Position, frameCountCheck)
		if mod:isScare(npc) then
			local targetvelocity = (targetpos - npc.Position):Resized(-5)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvelocity, 0.25)
		elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
			local targetvelocity = (targetpos - npc.Position):Resized(5)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvelocity, 0.25)
		else
			path:FindGridPath(targetpos, 0.7, 1, true)
		end

		if npc.Velocity:Length() > 1 then
			npc:AnimWalkFrame("WalkHori","WalkVert",0)
		else
			sprite:SetFrame("WalkVert", 0)
		end
	elseif d.state == "thrown" then
		sprite:SetFrame("Morph", 11)
		npc.SpriteRotation = Vector(npc.Velocity.X, d.fallspeed):GetAngleDegrees() + 270
		d.fallspeed = d.fallspeed + d.fallaccel
		npc.SpriteOffset = Vector(0, npc.SpriteOffset.Y + d.fallspeed)
		if npc.SpriteOffset.Y > 0 then
			npc.SpriteRotation = 0
			npc.SpriteOffset = nilvector
			d.state = "landed"
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			
			if game:GetRoom():GetGridCollisionAtPos(npc.Position) ~= GridCollisionClass.COLLISION_NONE then
				npc:Kill()
			end
			
			sprite:Play("Morph", true)
		end
	elseif d.state == "landed" then
		npc.Velocity = npc.Velocity * 0.7
		if sprite:IsFinished("Morph") then
			d.state = "idle"
		else
			mod:spritePlay(sprite, "Morph")
		end
	elseif d.state == "shot" then
		mod:spritePlay(sprite, "Ball")
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
		
		if npc.Velocity:Length() > 10.5 then
			npc.Velocity = npc.Velocity:Resized(10.5)
		end
		
		if npc:CollidesWithGrid() or npc.Velocity:Length() < 9 then
			d.state = "thrown"
			
			npc.Velocity = npc.Velocity * 0.4
			npc.SpriteOffset = Vector(0, npc.SpriteOffset.Y + (d.fallspeed * 2))
			
			-- spawn poof
			local poof = Isaac.Spawn(1000, 16, 0, npc.Position, nilvector, npc)
			mod:Greyscale(poof:GetSprite(), 0.6)
			poof.SpriteOffset = npc.SpriteOffset
			poof.SpriteScale = Vector(0.5, 0.5)
			poof.DepthOffset = 100
			poof:Update()
		end
	end
end

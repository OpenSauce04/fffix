local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--Mother 3
function mod:mushroomFromMotherSeriesIncludingHitGameEarthboundAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local path = npc.Pathfinder
	local target = npc:GetPlayerTarget()

	if not d.init then
		d.init = true
		d.walkin = true
		d.attackCount = 35
        mod.scheduleForUpdate(function()
            if mod.RambleInRoom then
                d.walktarg = nil
                local closestRamble = {nil, 99999999, nil}
                for i = 1, #mod.RambleInRoom do
                    local dist = (mod.RambleInRoom[i].pos - npc.Position):Length()
                    if dist < closestRamble[2] then
                        closestRamble = {mod.RambleInRoom[i].point, dist, mod.RambleInRoom[i].colour}
                    end
                end
                if closestRamble[1] then
                    --Isaac.ConsoleOutput("found home")
                    d.goPos = {currentNum = closestRamble[1], colour = closestRamble[3]}
                end
            end
        end, 1, nil, true)
	else
		d.attackCount = d.attackCount or 0
		d.attackCount = d.attackCount + 1
	end

	if d.walkin then
		npc.StateFrame = npc.StateFrame + 1
		if d.attackCount > 70 and math.random(50) == 1 and mod.GetEntityCount(mod.FF.Shiitake.ID, mod.FF.Shiitake.Var) < 10 and not mod:isScareOrConfuse(npc) then
			d.walkin = false
		end
		--Plan the animations bart!
		if npc.Velocity:Length() > 0.2 then
			npc:AnimWalkFrame("WalkHori","WalkVert",0)
		else
			sprite:SetFrame("WalkVert", 0)
		end
		--Chose where to walk to
		if (npc.StateFrame > 160 and not d.goPos) or not d.walktarg then
			if d.goPos then
				if mod.RambleInRoom then
					for i = 1, #mod.RambleInRoom do
						if mod.RambleInRoom[i].point == d.goPos.currentNum and mod.RambleInRoom[i].colour == d.goPos.colour then
							d.walktarg = mod.RambleInRoom[i].pos
						end
					end
					if (not d.walktarg) or mod:isConfuse(npc) then
						d.walktarg = mod:FindRandomValidPathPosition(npc)
					end
				end
			else
				d.walktarg = mod:FindRandomValidPathPosition(npc)
			end
			npc.StateFrame = 0
		end
		--Pathing
		if mod:isScare(npc) then
			local targetvel = (target.Position - npc.Position):Resized(-4)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.1)
			d.walktarg = nil
		elseif d.walktarg and npc.Position:Distance(d.walktarg) > 10 then
			if game:GetRoom():CheckLine(npc.Position,d.walktarg,0,1,false,false) then
				local targetvel = (d.walktarg - npc.Position):Resized(4)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.1)
			else
				path:FindGridPath(d.walktarg, 0.6, 900, true)
			end
		else
			--Find new place to go
			npc.Velocity = npc.Velocity * 0.9
			npc.StateFrame = npc.StateFrame + 2
			if d.goPos then
				d.goPos.currentNum = d.goPos.currentNum + 1
				mod.maxRamblePoint = mod.maxRamblePoint or 2
				if d.goPos.currentNum > mod.maxRamblePoint then
					d.goPos.currentNum = 1
				end
				d.walktarg = nil
			end
		end
	else
		npc.Velocity = npc.Velocity * 0.9
		if sprite:IsFinished("Attack") then
			d.walkin = true
			d.attackCount = 0
		elseif sprite:IsEventTriggered("Shoot") then
			local poof = Isaac.Spawn(1000, 15, 0, npc.Position, nilvector, npc):ToEffect()
			npc:PlaySound(SoundEffect.SOUND_SUMMONSOUND, 0.6, 0, false, 1)

			local spore = Isaac.Spawn(mod.FF.FloatingSpore.ID,mod.FF.FloatingSpore.Var,0,npc.Position,nilvector,nil)
			local sd = spore:GetData()
			sd.fallspeed = -4
			sd.height = -5
			sd.target = mod:FindRandomValidPathPosition(npc, 3, nil, 120, nil, true)
			if mod:isCharm(npc) then
				spore:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
			end
			spore:Update()
		else
			mod:spritePlay(sprite, "Attack")
		end
	end
end

function mod:floatingSporeAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()

	mod:spritePlay(sprite, "Spore")

	if not d.init then

		d.randCol = math.random(7) - 1
		if d.randCol > 0 then
			sprite:ReplaceSpritesheet(0, "gfx/enemies/small mushroom/extraCol" .. d.randCol .. ".png")
			sprite:LoadGraphics()
		end
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		d.fallspeed = d.fallspeed or -2
		d.height = d.height or -100
		d.multiplier = math.random(80,120) / 10
		d.negativemulti = 1
		if math.random(2) == 1 then d.negativemulti = -1 end
		npc.SpriteOffset = Vector(0, d.height)
		d.init = true
	end

	if d.target then
		if npc.Position:Distance(d.target) > 5 then
			npc.Velocity = (d.target - npc.Position):Resized(1)
		else
			npc.Velocity = npc.Velocity * 0.9
		end
	end

	d.fallspeed = d.fallspeed + 0.1
	if d.fallspeed > 1 then d.fallspeed = 1 end
	local vecX = (math.cos(npc.FrameCount / d.multiplier) * d.multiplier) * d.negativemulti
	npc.SpriteOffset = Vector(vecX, npc.SpriteOffset.Y) + Vector(0, d.fallspeed)

	if npc.SpriteOffset.Y > -5 then
		local mushy = Isaac.Spawn(mod.FF.Shiitake.ID,mod.FF.Shiitake.Var,0,npc.Position + Vector(npc.SpriteOffset.X, 0),nilvector,nil)
		if d.randCol then
			mushy:GetData().randCol = d.randCol
		end
		if mod:isCharm(npc) then
			mushy:AddEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM)
		end
		if d.ramblinOpal then
			mushy:GetData().ramblinOpal = true
			mushy.HitPoints = math.min(30, 7*d.ramblinOpalMult)
		end
		mushy:Update()
		npc:PlaySound(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1.3)
		npc:Remove()
	end
end

function mod.makeRamblinPoints()
	mod.RambleInRoom = {}
	mod.maxRamblePoint = -1
	if mod.ramblinPoints then
		if #mod.ramblinPoints > 0 then
			for i = 1, #mod.ramblinPoints do
				table.insert(mod.RambleInRoom, {point = mod.ramblinPoints[i].point, colour = mod.ramblinPoints[i].colour, pos = mod.ramblinPoints[i].pos})
				if mod.ramblinPoints[i].point > mod.maxRamblePoint then
					mod.maxRamblePoint = mod.ramblinPoints[i].point
				end
			end
		end
		mod.ramblinPoints = {}
	else
		mod.ramblinPoints = {}
	end
end
-- Oralid (ported from Morbus, originally coded by Xalum) --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local function canWalkToTarget(npc, target)
	return game:GetRoom():CheckLine(npc.Position, target + (npc.Position - target):Resized(5), 0, 1, false, false)
end

local function oralidPathfind(npc, speedlimit)
	local target = target or npc:GetPlayerTarget().Position

	local npcdata = npc:GetData()
	if npc:CollidesWithGrid() then
		npcdata.lastgridcollision = npc.FrameCount
	end

	if canWalkToTarget(npc, target) and not (npcdata.lastgridcollision and npcdata.lastgridcollision + 15 > npc.FrameCount) then
		npc.Velocity = npc.Velocity * 0.8 + (target - npc.Position):Resized(0.5)
	else
		npc.Pathfinder:FindGridPath(target, npc.Velocity:Length() + 0.1, 2, false)
	end
	npc.Velocity = npc.Velocity:Resized(math.min(speedlimit, npc.Velocity:Length() * 1.2))
end

function mod:oralidAI(npc, sprite, npcdata)
	if not npcdata.init then
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_HIDE_HP_BAR)
		npcdata.instawake = npc.SubType % 2 == 0
		npcdata.init = true
	end

	npcdata.speed = npcdata.speed or 6 

	if sprite:IsFinished("Appear") then
		sprite:Play("Dormant")
	elseif sprite:IsFinished("Wake") then
		npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_HIDE_HP_BAR)
		sprite:Play("Idle")
	end

	if sprite:IsPlaying("Dormant") then
		npc.Velocity = nilvector

		if (mod.CanIComeOutYet() or npcdata.instawake) and not npcdata.waitToEmegre then
			sprite:Play("Wake")
		end
	end

	if not npc.Parent or npc.Parent:IsDead() or not npc.Parent:Exists() or mod:isStatusCorpse(npc.Parent) or
	   npc.Parent.Type ~= mod.FF.Oralopede.ID or npc.Parent.Variant ~= mod.FF.Oralopede.Var 
	then 
		npc.Parent = nil
		npcdata.strongarmed = false
	end

	if sprite:IsPlaying("Idle") or sprite:IsPlaying("Walk") then
		if npc.Velocity:Length() >= 0.3 then
			sprite:Play("Walk")
		else
			sprite:Play("Idle")
		end

		if not npcdata.strongarmed then
			oralidPathfind(npc, npcdata.speed)
		else
			if npc.Parent and (npc.Position:Distance(npc.Parent.Position) > 45) then
				npc.Velocity = npc.Velocity * 0.8 + (npc.Parent.Position - npc.Position):Resized(0.5)
				npc.Velocity = npc.Velocity * 1.2
				if npc.Velocity:Length() > 4 then npc.Velocity = npc.Velocity:Resized(4) end
			else
				npc.Velocity = npc.Velocity * 0.8
			end
		end
	else
		npc.Velocity = npc.Velocity * 0.8
	end

	if sprite:IsEventTriggered("hatch") then
		sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 1, 0, false, 1)
	end

	if npcdata.speed > 6 then
		npcdata.speed = npcdata.speed - 0.1
	end

	if npcdata.waitToEmegre then
		npcdata.waitToEmegre = npcdata.waitToEmegre - 1
		if npcdata.waitToEmegre <= 0 then
			npcdata.waitToEmegre = nil
		end
	end
end

function mod:oralidTakeDmg(entity, damage, flags, source, countdown)
	local sprite = entity:GetSprite()
	if sprite:IsPlaying("Dormant") and not entity:GetData().waitToEmegre then 
		sprite:Play("Wake")

		if entity.Parent and entity.Parent:Exists() and not mod:isStatusCorpse(entity.Parent) and
		   entity.Parent.Type == mod.FF.Oralopede.ID and entity.Parent.Variant == mod.FF.Oralopede.Var
		then
			entity.Parent:GetSprite():Play("Wake")
			
			local parentdata = entity.Parent:GetData()
			if parentdata.oralids and #parentdata.oralids > 0 then
				for _, oralid in pairs(parentdata.oralids) do
					oralid:GetSprite():Play("Wake")
				end
			end
		end
	end
end

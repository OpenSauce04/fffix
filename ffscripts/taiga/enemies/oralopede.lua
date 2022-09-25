-- Oralopede (ported from Morbus, originally coded by Xalum) --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local function canWalkToTarget(npc, target)
	return game:GetRoom():CheckLine(npc.Position, target + (npc.Position - target):Resized(5), 0, 1, false, false)
end

local function oralopedePathfind(npc, speedlimit)
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

function mod:oralopedeAI(npc, sprite, npcdata)
	if not npcdata.init then
		npcdata.oralids = {}

		local offset = math.random(360)
		local numOralids = npc.SubType >> 1
		for i = 1, numOralids do
			local oralid = Isaac.Spawn(mod.FF.Oralid.ID, mod.FF.Oralid.Var, npc.SubType % 2, npc.Position + Vector(0, 30):Rotated(i * (360 / numOralids) + offset), nilvector, npc)
			oralid.Parent = npc
			oralid:GetData().strongarmed = true
			npcdata.oralids[#npcdata.oralids + 1] = oralid
		end

		npcdata.speed = 3
		
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_HIDE_HP_BAR)
		npcdata.instawake = npc.SubType % 2 == 0
		
		npcdata.init = true
	end

	if sprite:IsFinished("Appear") then
		sprite:Play("Dormant")
	elseif sprite:IsFinished("Wake") or sprite:IsFinished("Command") or sprite:IsFinished("Unembed") then
		if sprite:IsFinished("Wake") or sprite:IsFinished("Unembed") then
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_HIDE_HP_BAR)
			npcdata.last = npc.FrameCount - 75
		else
			npcdata.last = npc.FrameCount
		end
		sprite:Play("Idle")
	elseif sprite:IsFinished("Jump") then
		sprite:Play("Idle02")
		npcdata.last = npc.FrameCount
	end

	for i = #npcdata.oralids, 1, -1 do
		local oralid = npcdata.oralids[i]

		if oralid:IsDead() or not oralid:Exists() or mod:isStatusCorpse(oralid) or
		   oralid.Type ~= mod.FF.Oralid.ID or oralid.Variant ~= mod.FF.Oralid.Var
		then
			table.remove(npcdata.oralids, i)
			return
		end
	end

	if sprite:IsPlaying("Dormant") then
		npc.Velocity = nilvector
		
		if mod.CanIComeOutYet() or npcdata.instawake then
			sprite:Play("Wake")
			if npcdata.oralids and #npcdata.oralids > 0 then
				for _, oralid in pairs(npcdata.oralids) do
					oralid:GetSprite():Play("Wake")
				end
			end
		end
	elseif sprite:IsPlaying("Idle02") then
		if npcdata.last + 15 - npc.FrameCount <= 0 then
			sprite:Play("Unembed")
		end
	end

	if sprite:IsPlaying("Idle") or sprite:IsPlaying("Walk") then
		if npc.Velocity:Length() >= 0.3 then
			sprite:Play("Walk")
		else
			sprite:Play("Idle")
		end

		oralopedePathfind(npc, npcdata.speed)

		if npcdata.last + 150 - npc.FrameCount <= 0 and math.random(3) == math.random(3) then
			if #npcdata.oralids < 3 then
				sprite:Play("Jump")
			else
				sprite:Play("Command")
			end
		elseif npcdata.last + 90 - npc.FrameCount <= 0 and not (npcdata.oralids[1] and npcdata.oralids[1]:GetData().strongarmed) then
			npcdata.speed = 3
			for _, oralid in pairs(npcdata.oralids) do
				oralid:GetData().strongarmed = true
			end
		end
	else
		npc.Velocity = npc.Velocity * 0.8
	end

	if sprite:IsEventTriggered("command") then
		for _, oralid in pairs(npcdata.oralids) do
			oralid:GetData().strongarmed = false
			oralid:GetData().speed = 9
		end
		npcdata.speed = 2

		--[[if #npcdata.oralids < 3 and math.random(3) == math.random(3) then

			for i = 1, math.random(math.min(3 - #npcdata.oralids, 2)) do
				local oralid = Isaac.Spawn(mod.FF.Oralid.ID, mod.FF.Oralid.Var, 0, npc.Position + RandomVector():Resized(30), nilvector, npc)
				oralid:GetData().instawake = true
				oralid.Parent = npc
				oralid:GetData().strongarmed = true
				npcdata.oralids[#npcdata.oralids + 1] = oralid
			end
		end]]

		sfx:Play(SoundEffect.SOUND_MONSTER_ROAR_0, 1, 0, false, math.random(9, 11)/10)
	elseif sprite:IsEventTriggered("hatch") then
		sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 1, 0, false, 0.8)
	elseif sprite:IsEventTriggered("Land") then
		if sprite:IsPlaying("Jump") then
			for i = 1, 3 do
				local oralid = Isaac.Spawn(mod.FF.Oralid.ID, mod.FF.Oralid.Var, 0, npc.Position + RandomVector():Resized(30), nilvector, npc)
				oralid.Parent = npc
				oralid:GetData().waitToEmegre = 30
				oralid:GetData().strongarmed = true
				npcdata.oralids[#npcdata.oralids + 1] = oralid
			end

			for i = 1, mod:RandomInt(3,5) do
				local rubble = Isaac.Spawn(1000, 4, 0, npc.Position, RandomVector() * mod:RandomInt(2,6), npc)
				rubble:Update()
			end

			npc.Velocity = Vector.Zero
			npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
			sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)
		end
	elseif sprite:IsEventTriggered("Jump") then
		if sprite:IsPlaying("Unembed") then
			sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 1, 0, false, 0.8)
			for _, oralid in pairs(npcdata.oralids) do
				oralid:GetData().waitToEmegre = nil
				oralid:GetData().instawake = true
			end
		elseif sprite:IsPlaying("Jump") then
			npc.Velocity = (npc:GetPlayerTarget().Position - npc.Position):Resized(20)
			sfx:Play(SoundEffect.SOUND_FETUS_JUMP)
		end
	end
end

function mod:oralopedeTakeDmg(entity, damage, flags, source, countdown)
	local sprite = entity:GetSprite()
	if sprite:IsPlaying("Dormant") then 
		sprite:Play("Wake")
		
		local npcdata = entity:GetData()
		if npcdata.oralids and #npcdata.oralids > 0 then
			for _, oralid in pairs(npcdata.oralids) do
				oralid:GetSprite():Play("Wake")
			end
		end
	end
end

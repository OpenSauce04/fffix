local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--------------------------------------------------------------------------------------------
--Callback funnies

--Unused ones I can copy
--[[
function mod:Hurt(npc, damage, flag, source)

end

function mod:Coll(npc1, npc2)

end
]]

--Generic death anim func used by a few
function mod.erflyCustomDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
		deathAnim.State = 11
	end

	mod.genericCustomDeathAnim(npc, nil, nil, onCustomDeath)
end

function mod:returnFalse()
	return false
end

--------------------------------------------------------------------------------------------
--Flush compatibility for custom FF enemies

mod.flushList = {
	{ID = {mod.FF.SoftServe.ID, mod.FF.SoftServe.Var}, Anim = {"idle3", 0}},					--Soft Serve
	{ID = {mod.FF.Sundae.ID, mod.FF.Sundae.Var}, Anim = {"pop3", 12}},							--Sundae
	{ID = {mod.FF.Scoop.ID, mod.FF.Scoop.Var}, Anim = {"pop2", 10}},							--Scoop
	{ID = {mod.FF.Load.ID, mod.FF.Load.Var}, Anim = {"death", 16}},								--Load
	{ID = {mod.FF.CornLoad.ID, mod.FF.CornLoad.Var}, Anim = {"death", 0}},						--Corn Load
	{ID = {mod.FF.Poople.ID, mod.FF.Poople.Var}, Anim = {"WalkVert", 0}, Overlay = "HeadDown"},	--Poople
	{ID = {mod.FF.Dung.ID, mod.FF.Dung.Var}, Anim = {"Shoot", 0}},								--Dung
	{ID = {mod.FF.Drop.ID, mod.FF.Drop.Var}, Anim = {"Idle", 3}},								--Drip
	{ID = {mod.FF.Dribble.ID, mod.FF.Dribble.Var}, Anim = {"ChargeLoop", 2}},					--Dribble
	{ID = {mod.FF.Tallboi.ID, mod.FF.Tallboi.Var}, Anim = {"Idle", 0}},							--Tall Boi
	{ID = {mod.FF.Shitling.ID, mod.FF.Shitling.Var}, Anim = {"Idle", 0}},						--Shitling
	{ID = {mod.FF.Berry.ID, mod.FF.Berry.Var}, Anim = {"Idle", 0}},								--Berry
	{ID = {mod.FF.SpicyDip.ID, mod.FF.SpicyDip.Var}, Anim = {"Flush", 0}},						--Spicy Dip
	--Rep
	{ID = {mod.FF.Connipshit.ID, mod.FF.Connipshit.Var}, Anim = {"Idle", 0}},
	{ID = {mod.FF.Stomy.ID, mod.FF.Stomy.Var}, Anim = {"Idle", 0}},
	{ID = {mod.FF.Spoop.ID, mod.FF.Spoop.Var}, Anim = {"Prepare", 7}},
	{ID = {mod.FF.ShittyHorf.ID, mod.FF.ShittyHorf.Var}, Anim = {"Appear", 0}},
}

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
	for _, entity in pairs(Isaac.GetRoomEntities()) do
		for i = 1, #mod.flushList do
			if entity.Type == mod.flushList[i].ID[1] and entity.Variant == mod.flushList[i].ID[2] then
				entity.SplatColor = mod.ColorInvisible
				entity:BloodExplode()
				local poop = mod.FindClosestEntity(entity.Position, 1, 245)
				if poop then
					poop:Remove()
				end
				local effect = Isaac.Spawn(1000,7018,24,entity.Position,nilvector,nil)
				local efsprite = effect:GetSprite()
				efsprite:Load(entity:GetSprite():GetFilename(),true)
				if mod.flushList[i].Anim[1] == "Flush" then
					mod:spritePlay(efsprite, "Flush")
				else
					efsprite:SetFrame(mod.flushList[i].Anim[1], mod.flushList[i].Anim[2])
					if mod.flushList[i].Overlay then
						efsprite:SetOverlayFrame(mod.flushList[i].Overlay, mod.flushList[i].Anim[2])
					end
				end
				effect:Update()
			end
		end
		--Manual cases
		if entity.Type == mod.FF.Cacamancer.ID and entity.Variant == mod.FF.Cacamancer.Var then
			--print("ye")
			if entity:GetData().state ~= "relocate" then
				entity:GetData().state = "relocate"
				entity:GetData().sState = nil
				entity:ToNPC().StateFrame = 0
			end
		--Manual cases
		elseif entity.Type == mod.FF.Monsoon.ID and entity.Variant == mod.FF.Monsoon.Var then
			--print("ye")
			if entity:GetData().smallstate then
				local splash = Isaac.Spawn(1000, 132, 0, entity.Position, Vector.Zero, nil)
				splash:Update()
				Isaac.Spawn(5, 100, mod.ITEM.COLLECTIBLE.DRIPPING_BADGE, entity.Position, Vector.Zero, nil)
				entity:Kill()
			end
		end
	end
end, CollectibleType.COLLECTIBLE_FLUSH)

--------------------------------------------------------------------------------------------
--Fear / Confusion / Friend related stuff
--Makes it a whoooooole lot easier to make stuff react to being scared n such

function mod:isFriend(npc)
	return npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
end
function mod:isCharm(npc)
	return npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM)
end
function mod:isScare(npc)
	return npc:HasEntityFlags(EntityFlag.FLAG_FEAR | EntityFlag.FLAG_SHRINK)
end
function mod:isConfuse(npc)
	return npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION)
end
function mod:isScareOrConfuse(npc)
	return npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION | EntityFlag.FLAG_FEAR | EntityFlag.FLAG_SHRINK)
end
function mod:isBaited(npc)
	return npc:HasEntityFlags(EntityFlag.FLAG_BAITED)
end

function mod:makeProjectileConsiderFriend(npc, projectile)
	if npc and mod:isFriend(npc) then
		projectile:AddProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.HIT_ENEMIES)
	end
end

--Used to make it easier to make random confused stuff
--Instead of getting target position, get a random one
function mod:randomConfuse(npc, pos)
	if mod:isConfuse(npc) then
		return game:GetRoom():GetRandomPosition(1)
	else
		return pos
	end
end
--Instead of getting a target vector, get a random one
function mod:randomVecConfuse(npc, vec, mult)
	mult = mult or 1
	if mod:isConfuse(npc) then
		return RandomVector() * mult
	else
		return vec
	end
end

function mod:runIfFear(npc, vec, speed, isPosition)
	if mod:isScare(npc) then
		local target = npc:GetPlayerTarget()
		--Returns a position for enemies moving towards a target
		if isPosition then
			speed = speed or 50
			return game:GetRoom():GetClampedPosition(npc.Position + (npc.Position - target.Position):Resized(speed), 0)
		--Returns a velocity for enemies just wanting to get away
		else --IsVelocity
			speed = speed or 8
			return (npc.Position - target.Position):Resized(speed)
		end
	else
		return vec
	end
end
function mod:runIfFearNearby(npc, returnVec)
	if mod:isScare(npc) then
		if npc:GetPlayerTarget() then
			local pdist = npc:GetPlayerTarget().Position:Distance(npc.Position)
			if pdist < 100 then
				local vec = (npc.Position - npc:GetPlayerTarget().Position):Resized(math.max(5, 10 - pdist/20))
				if returnVec then
					return vec
				else
					npc.Velocity = mod:Lerp(npc.Velocity, vec, 0.3)
					return true
				end
			end
		end
	end
end
function mod:reverseIfFear(npc, vec, multiplier)
	multiplier = multiplier or 1
	if mod:isScare(npc) then
		vec = vec * -1 * multiplier
	end
	return vec
end
function mod:confusePos(npc, pos, frameCountCheck, isVec, alwaysConfuse)
	frameCountCheck = frameCountCheck or 10
	local d = npc:GetData()
	if mod:isConfuse(npc) or alwaysConfuse then
		if isVec then
			if npc.FrameCount % frameCountCheck == 0 then
				d.confusedEffectPos = nil
			end
			d.confusedEffectPos = d.confusedEffectPos or RandomVector()*math.random(2,5)
			return d.confusedEffectPos
		else
			if npc.FrameCount % frameCountCheck == 0 then
				d.confusedEffectPos = nil
			end
			if d.confusedEffectPos and npc.Position:Distance(d.confusedEffectPos) < 2 then
				d.confusedEffectPos = npc.Position
			end
			d.confusedEffectPos = d.confusedEffectPos or npc.Position + RandomVector()*math.random(5,15)
			return d.confusedEffectPos
		end
	else
		d.confusedEffectPos = nil
		return pos
	end
end
function mod:rotateIfConfuse(npc, vec)
	if mod:isConfuse(npc) then
		vec = vec:Rotated(math.random(360))
	end
	return vec
end
function mod:UnscareWhenOutOfRoom(npc, timeCheck)
	local d = npc:GetData()
	timeCheck = timeCheck or 10
	if mod:isScare(npc) then
		local room = Game():GetRoom()
		if not room:IsPositionInRoom(npc.Position, 0) then
			d.outOfRoomUncareTimer = d.outOfRoomUncareTimer or 0
			d.outOfRoomUncareTimer = d.outOfRoomUncareTimer + 1
			if d.outOfRoomUncareTimer > timeCheck then
				npc:ClearEntityFlags(EntityFlag.FLAG_FEAR)
				npc.Color = mod.ColorNormal
			end
		else
			d.outOfRoomUncareTimer = 0
		end
	else
		d.outOfRoomUncareTimer = 0
	end
end

--------------------------------------------------------------------------------------------

function mod.chooseClosestRotationDirection(currentVec, targetVec, returnDif)
	local vec1 = currentVec:GetAngleDegrees()
	local vec2 = targetVec:GetAngleDegrees()
	local dist = 99999
	local savedir = 0

	for i = -2, 2 do
		local newdist = vec1 - (vec2 + (360 * i))
		if math.abs(newdist) < dist then
			dist = math.abs(newdist)
			savedir = newdist
		end
	end
	--This doesn't work for some reason??????????????????????????
	--[[if savedir ~= 0 then
		savedir = savedir ^ 0
	end
	]]
	if savedir > 0 then
		savedir = 1
	else
		savedir = -1
	end
	if returnDif then
		return {savedir, 180 - dist}
	else
		return savedir
	end
end

function mod.bounceOffWall(pos, dir, pVel)
	local baseVel = Vector(1,0):Resized(pVel:Length())
	local bouncedVel = mod.bounceOffWallLegacy(pos, dir)
	local newVel

    if bouncedVel ~= dir then
		if bouncedVel.X == -dir.X then --If collision is a side wall
			newVel = baseVel:Rotated(120+math.random(120)) --Bounce at a random angle away from the wall
			if bouncedVel.X > 0 then --Flip when necessary
			  newVel.X = -newVel.X
			end
		else --If collision is a top/bottom wall
			newVel = baseVel:Rotated(30+math.random(120)) --Bounce at a random angle away from the wall
			if bouncedVel.Y < 0 then --Flip when necessary
			  newVel.Y = -newVel.Y
			end
		end
	end

	return newVel
end

function mod.bounceOffWallLegacy(pos, dir)
	local room = game:GetRoom()
	local center = room:GetCenterPos()
	local topLeft = room:GetTopLeftPos()
	local bottomRight = room:GetBottomRightPos()

	local horizontalRef
	local verticalRef
	if pos.X < center.X then
		horizontalRef = topLeft.X
	else
		horizontalRef = bottomRight.X
	end
	if pos.Y < center.Y then
		verticalRef = topLeft.Y
	else
		verticalRef = bottomRight.Y
	end

	local horizontal
	if math.abs(pos.X - horizontalRef) < math.abs(pos.Y - verticalRef) then
		horizontal = true
	else
		horizontal = false
	end

	local returnVector = Vector(dir.X, dir.Y)
	if horizontal == true then
		returnVector.X = -returnVector.X
	else
		returnVector.Y = -returnVector.Y
	end

	return returnVector
end

--[[--Legacy method
function mod.FindClosestEntity(pos,radius,type,variant,subtype)
	radius = radius or 99999
	type = type or nil
	variant = variant or nil
	subtype = subtype or nil
	local target = nil
	for index,entity in ipairs(Isaac.GetRoomEntities()) do
		if type == nil or type == entity.Type then
			if variant == nil or variant == entity.Variant then
				if subtype == nil or subtype == entity.SubType then
					local distance = pos:Distance(entity.Position)
					if distance < radius then
						radius = distance
						target = entity
					end
				end
			end
		end
	end
	return target
end]]

--pass the npc for haspath
function mod.FindClosestEntity(pos,radius,etype,variant,subtype,haspath,ignoreseed)
	radius = radius or 99999
	etype = etype or -1
	variant = variant or -1
	subtype = subtype or -1
	local target = nil
	for index,entity in ipairs(Isaac.FindByType(etype, variant, subtype, false, false)) do
		if (not ignoreseed) or (ignoreseed ~= entity.InitSeed) then
			local distance = pos:Distance(entity.Position)
			if distance < radius then
				if (haspath and haspath.Pathfinder:HasPathToPos(entity.Position, false)) or not haspath then
					radius = distance
					target = entity
				end
			end
		end
	end
	return target
end

function mod.FindClosestEnemy(pos,radius, nofriends, useCollRad, ignoreSeed, collClass, prioritiseFlagless, ignoreNoHealth, ignoreNoBerserk)
	radius = radius or 99999
	local radius2 = radius
	if useCollRad then
		radius2 = radius2 + 100
	end
	local target = nil

	local targetFlag = nil
	local radiusFlag = 99999
	for index,entity in ipairs(Isaac.FindInRadius(pos, radius2, EntityPartition.ENEMY)) do
		if entity:IsVulnerableEnemy() and
		   (not (entity:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) or entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY))) and
		   ((not nofriends) or (not mod:isCharm(entity))) and
		   ((not ignoreSeed) or (ignoreSeed and ignoreSeed ~= entity.InitSeed)) and
		   ((not colClass) or (collClass and entity.EntityCollisionClass >= collClass)) and
		   ((not ignoreNoHealth) or entity.HitPoints > 0.0) and
		   ((not ignoreNoBerserk) or (not mod:isBerserkBlacklisted(entity))) and
		   ((not mod:isFriend(entity)))
		then
			local distance = pos:Distance(entity.Position)
			if useCollRad then
				distance = distance - entity.Size
			end
			if (useCollRad and distance < radius2 - 100) or (not useCollRad) then
				if distance < radius then
					radius = distance
					target = entity
				end
				if prioritiseFlagless then
					if not entity:HasEntityFlags(prioritiseFlagless) then
						if distance < radiusFlag then
							radiusFlag = distance
							targetFlag = entity
						end
					end
				end
			end
		end
	end
	if prioritiseFlagless and targetFlag then
		return targetFlag
	else
		return target
	end
end


mod.blacklistedPrimeMind = {
	{mod.FF.PsiKnight.ID, mod.FF.PsiKnight.Var, 1},	--Psionic Knight Brain
	{35, 10},		--Maw Neck
	{42},			--Grimace + associated entities
	{218},			--Wall Hugger, Banshee etc.
	{219},			--Wizoob
	{677, 56241},	--Revelations Wandering Soul (wtf this is a familiar not an enemy??????)
	{EntityType.ENTITY_EVIS, 10},	--Evis Guts (and other rope entities)
	{mod.FF.Congression.ID},								--Congression
	--{mod.FF.Gravedigger.ID, mod.FF.Gravedigger.Var},		--Gravedigger
	{mod.FF.Gravefire.ID, mod.FF.Gravefire.Var},			--Gravedigger Fire
	{mod.FF.Watcher.ID, mod.FF.Watcher.Var},				--Watcher
	{mod.FF.Mistmonger.ID, mod.FF.Mistmonger.Var},			--Mistmonger
	{mod.FFID.Tech},										--Technical entities
	--{mod.FF.Psion.ID, mod.FF.Psion.Var},					--Psion
	{mod.FF.ToxicKnight.ID, mod.FF.ToxicKnight.Var, 1},		--Toxic Knight Brain
	{mod.FF.Poobottle.ID, mod.FF.Poobottle.Var},			--Poobottle
	{mod.FF.Drainfly.ID, mod.FF.Drainfly.Var},				--Drainfly
	{mod.FF.ThousandEyes.ID, mod.FF.ThousandEyes.Var, mod.FF.ThousandEyesCharge.Sub},	--Thousand Eyes Escaper
	{mod.FF.ThousandEyes.ID, mod.FF.ThousandEyes.Var, mod.FF.ThousandEyesLook.Sub},		--Thousand Eyes Looker
	--{mod.FF.Cordify.ID, mod.FF.Cordify.Var},				--Cordify
	{mod.FF.Temper.ID, mod.FF.Temper.Var},					--Temper
	{mod.FF.Pawn.ID, mod.FF.Pawn.Var, 10},					--King Cord Hitbox
	{mod.FF.EternalFlickerspirit.ID, mod.FF.EternalFlickerspirit.Var}, 	--Eternal Flickerspirit
	{mod.FF.Viscerspirit.ID, mod.FF.Viscerspirit.Var}, 		--Viscerspirit
	{mod.FF.Specturn.ID, mod.FF.Specturn.Var},				--Specturn
	{866}, --Dark Esau
}

function mod.FindClosestEntityPrimeMind(pos,radius,currentents,blockstony)
	radius = radius or 400
	local target = nil
	for index,entity in ipairs(Isaac.GetRoomEntities()) do
		if entity:IsActiveEnemy() then
			local etype = entity.Type
			local evar = entity.Variant
			local esub = entity.SubType
			local safetochoose = true
			for _, v in ipairs(mod.blacklistedPrimeMind) do
				if v[3] then if etype == v[1] and evar == v[2] and esub == v[3] then safetochoose = false end
				elseif v[2] then if etype == v[1] and evar == v[2] then safetochoose = false end
				elseif etype == v[1] then safetochoose = false end
			end
			if entity.EntityCollisionClass == EntityCollisionClass.ENTCOLL_NONE and entity.Visible == false then safetochoose = false end
			if blockstony and etype == 302 then safetochoose = false end
			if entity:GetData().cordified then safetochoose = false end
			if mod:isFriend(entity) then safetochoose = false end
			if mod:isStatusCorpse(entity) then safetochoose = false end
			if safetochoose then
				local diffent = true
				for i = 1, #currentents do
					if currentents[i].InitSeed == entity.InitSeed then
						diffent = false
					end
				end
				if diffent then
					local distance = pos:Distance(entity.Position)
					if distance < radius then
						radius = distance
						target = entity
					elseif math.abs(distance - radius) < 1 then
						if math.random(2) == 1 then
							target = entity
						end
					end
				end
			end
		end
	end
	return target
end

function mod.FindRandomEntityDeadfly(DontCheckThisInitSeed)
	local validpicks = {}
	for index,entity in ipairs(Isaac.GetRoomEntities()) do
		if entity:IsActiveEnemy() then
			local etype, evar, esub = entity.Type, entity.Variant, entity.SubType
			local safetochoose = true
			for _, v in ipairs(mod.blacklistedPrimeMind) do
				if v[3] then if etype == v[1] and evar == v[2] and esub == v[3] then safetochoose = false end
				elseif v[2] then if etype == v[1] and evar == v[2] then safetochoose = false end
				elseif etype == v[1] then safetochoose = false end
			end
			for _, v in ipairs(mod.HidingUnderwaterEnts) do
				if v[3] then if etype == v[1] and evar == v[2] and esub == v[3] then safetochoose = false end
				elseif v[2] then if etype == v[1] and evar == v[2] then safetochoose = false end
				elseif etype == v[1] then safetochoose = false end
			end
			if etype == mod.FF.DeadFly.ID and evar == mod.FF.DeadFly.Var then safetochoose = false end
			if etype == mod.FF.DeadFlyOrbital.ID and evar == mod.FF.DeadFlyOrbital.Var then safetochoose = false end
			if etype == mod.FF.Menace.ID and evar == mod.FF.Menace.Var then safetochoose = false end
			--moms
			if etype == 45 or etype == 396 then safetochoose = false end
			if DontCheckThisInitSeed and (entity.InitSeed == DontCheckThisInitSeed) then safetochoose = false end
			if etype == 96 then safetochoose = false end
			if mod:isStatusCorpse(entity) then safetochoose = false end
			if etype == mod.FF.HarletwinCord.ID and evar == mod.FF.HarletwinCord.Var and esub == mod.FF.HarletwinCord.Sub then safetochoose = false end
			if etype == mod.FF.EffigyCord.ID and evar == mod.FF.EffigyCord.Var and esub == mod.FF.EffigyCord.Sub then safetochoose = false end
			if etype == mod.FF.ThrallCord.ID and evar == mod.FF.ThrallCord.Var and esub == mod.FF.ThrallCord.Sub then safetochoose = false end
			if safetochoose then
				if not entity:GetData().eFlied then
					table.insert(validpicks, entity)
				end
			end
		end
	end
	if #validpicks > 0 then
		return validpicks[math.random(#validpicks)]
	else
		return nil
	end
end

mod.psihunterWhitelist = {
{1},		--Player :)
{mod.FF.PsiKnight.ID, mod.FF.PsiKnight.Var, 0},	--Psionic Knight
{mod.FF.Psion.ID, mod.FF.Psion.Var},		--Psion
{mod.FF.PsyEg.ID, mod.FF.PsyEg.Var},	--PsyEg
{mod.FF.Crosseyes.ID, mod.FF.Crosseyes.Var},	--Crosseyes
{mod.FF.Foreseer.ID, mod.FF.Foreseer.Var},	--Foreseer
{mod.FF.PsionLeech.ID, mod.FF.PsionLeech.Var},	--Psionic Leech
{mod.FF.Psiling.ID, mod.FF.Psiling.Var},	--Psiling
{mod.FF.Outlier.ID, mod.FF.Outlier.Var},    --Outlier
{mod.FF.Observer.ID, mod.FF.Observer.Var},    --Observer
{EntityType.ENTITY_CAMILLO_JR, 0},    --Camillo Jr.
{mod.FF.Hermit.ID, mod.FF.Hermit.Var},	--Hermit
{mod.FF.Horse.ID, mod.FF.Horse.Var},	--Horse
}

function mod.FindClosestEntityPsiHunter(npc)
	local radius = 150
	local target = nil
	for index,entity in ipairs(Isaac.FindInRadius(npc.Position, 150, EntityPartition.ENEMY)) do
		local etype = entity.Type
		local evar = entity.Variant
		local esub = entity.SubType
		local safetochoose = false
		if mod:isStatusCorpse(npc) or not entity:IsVulnerableEnemy() or not entity:IsActiveEnemy() then
			safetochoose = false
		elseif mod:isBerserk(npc) and not entity:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
			safetochoose = true
		elseif mod:isCharm(npc) then
			if not (mod:isCharm(entity) or entity:HasEntityFlags(EntityFlag.FLAG_NO_TARGET)) then
				safetochoose = true
			end
		else
			for _, v in ipairs(mod.psihunterWhitelist) do
				if v[3] then if etype == v[1] and evar == v[2] and esub == v[3] then safetochoose = true end
				elseif v[2] then if etype == v[1] and evar == v[2] then safetochoose = true end
				elseif etype == v[1] then safetochoose = true end
			end
		end
		if safetochoose then
			local distance = npc.Position:Distance(entity.Position)
			if distance < radius then
				if npc.Pathfinder:HasPathToPos(entity.Position, false) and game:GetRoom():GetGridCollisionAtPos(entity.Position) < 1 then
					radius = distance
					target = entity
				end
			end
		end
	end
	return target
end
function mod.CountCloseEnemiesPsiHunter(npc)
	local target = nil
	local entityCount = 0
	for index,entity in ipairs(Isaac.FindInRadius(npc.Position, 100, EntityPartition.ENEMY)) do
		local etype = entity.Type
		local evar = entity.Variant
		local esub = entity.SubType
		local safetochoose = false
		if mod:isStatusCorpse(npc) then
			safetochoose = false
		elseif mod:isBerserk(npc) and not entity:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
			safetochoose = true
		elseif mod:isCharm(npc) then
			if not (mod:isCharm(entity) or entity:HasEntityFlags(EntityFlag.FLAG_NO_TARGET)) then
				safetochoose = true
			end
		else
			for _, v in ipairs(mod.psihunterWhitelist) do
				if v[3] then if etype == v[1] and evar == v[2] and esub == v[3] then safetochoose = true end
				elseif v[2] then if etype == v[1] and evar == v[2] then safetochoose = true end
				elseif etype == v[1] then safetochoose = true end
			end
		end
		if safetochoose then
			entityCount = entityCount + 1
		end
	end
	return entityCount
end

function mod.FindRandomEntity(npc,type,variant,subtype,mode)
	type = type or 0
	variant = variant or nil
	subtype = subtype or nil
	mode = mode or nil
	local targets = {}
	local target = nil
	for index,entity in ipairs(Isaac.GetRoomEntities()) do
		if type == 0 or type == entity.Type then
			if variant == nil or variant == entity.Variant then
				if subtype == nil or subtype == entity.SubType then
					if mode == nil or (mode and npc.Pathfinder:HasPathToPos(entity.Position)) then
						table.insert(targets, entity)
					end
				end
			end
		end
	end
	if #targets > 0 then
		target = targets[math.random(#targets)]
	end
	return target
end
function mod.FindRandomEnemy(pos, radius)
	pos = pos or Game:GetRoom():GetCenterPos()
	radius = radius or 1000
	local targets = {}
	local target = nil
	for _, entity in pairs(Isaac.FindInRadius(pos, radius, EntityPartition.ENEMY)) do
		if entity then
			local etype = entity.Type
			local evar = entity.Variant
			local esub = entity.SubType
			local badent = false
			for _, v in ipairs(mod.BadEnts) do
				if v[3] then if etype == v[1] and evar == v[2] and esub == v[3] then badent = true end
				elseif v[2] then if etype == v[1] and evar == v[2] then badent = true end
				elseif etype == v[1] then badent = true end
			end

			if entity.EntityCollisionClass > 0 and not badent then
				table.insert(targets, entity)
			end
		end
	end
	if #targets > 0 then
		target = targets[math.random(#targets)]
	end
	return target
end

function mod.FindNearbyBombs(pos,radius)
	local dist = radius
	local nearestPos
	local bombs = Isaac.FindByType(4, -1, -1, false, false)
	for _, bomb in pairs(bombs) do
		local bombdist = bomb.Position:Distance(pos)
		if bombdist < dist and not bomb:GetData().FFCopperBombWasADud then
			dist = bombdist
			nearestPos = bomb
		end
	end

	return nearestPos
end

function mod.FindClosestFire(pos,radius,includeFriend)
	radius = (radius or 9999) ^ 2
	local target = nil

	if mod.fireEntities then
		for index,entity in ipairs(mod.fireEntities) do
			if entity.FrameCount > 2 then
				local distance = pos:DistanceSquared(entity.Position)
				if distance < radius then
					radius = distance
					target = entity
				end
			end
		end
	end
	if includeFriend and mod.fireEntitiesFriend then
		for index,entity in ipairs(mod.fireEntitiesFriend) do
			if entity.FrameCount > 2 then
				local distance = pos:DistanceSquared(entity.Position)
				if distance < radius then
					radius = distance
					target = entity
				end
			end
		end
	end
	return target
end

function mod:SetRoomAlight(npc)
	if npc and mod:isFriend(npc) then
		for _, p in pairs(Isaac.FindByType(1000, 45, 7001, false, false)) do
			p:GetData().flaming = true
		end
		for _, p in pairs(Isaac.FindByType(mod.FF.Mote.ID, mod.FF.Mote.Var, -1, false, false)) do
			if p:isFriend(npc) then
				p:GetData().flaming = true
			end
		end

	else
		for _, p in pairs(Isaac.FindByType(1000, 26, 7001, false, false)) do
			p:GetData().flaming = true
		end
		for _, p in pairs(Isaac.FindByType(mod.FF.Mote.ID, mod.FF.Mote.Var, -1, false, false)) do
			p:GetData().flaming = true
		end
	end
end

function mod.FindClosestEntityStarving(npc)
	local path = npc.Pathfinder
	local priorities = {}
	local backups = {}

	for _,entity in ipairs(Isaac.GetRoomEntities()) do
		--Couple things to get out the way first
		if path:HasPathToPos(entity.Position, false) and entity:IsActiveEnemy() and entity.MaxHitPoints < 100 and (not entity:IsBoss()) and (not npc:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) and (not mod:isStatusCorpse(entity))) then
			local etype = entity.Type
			local evar = entity.Variant
			--First select through prioritised enemies
			local prioritised = nil
			for _, priority in ipairs(mod.StarvingPriorities) do
				if etype == priority[1] and evar == priority[2] then
					table.insert(priorities, entity)
					prioritised = true
				end
			end
			--If they're not prioritised, check if they're blacklisted
			if not prioritised then
				local toobig = nil
				for _, ridley in ipairs(mod.StarvingRidleys) do
					if etype == ridley[1] and evar == ridley[2] then
						toobig = true
					end
				end
				--If not on the blacklist, select them as the backup
				if not toobig then
					table.insert(backups, entity)
				end
			end
		end
	end

	local target
	local backuptarg
	local backuptargclose
	local pos = npc.Position
	local targposition = npc:GetPlayerTarget().Position
	local dist = 50

	if #backups > 0 then
		local radius = 99999
		for _, entity in ipairs(backups) do
			local distance = pos:Distance(entity.Position)
			if distance < radius then
				radius = distance
				backuptarg = entity
			end
			if distance < 60 then
				backuptargclose = true
			end
		end
	end


	if targposition:Distance(pos) < 70 then
		target = targposition
		dist = 70
	elseif backuptargclose then
		target = backuptarg.Position
	elseif #priorities > 0 then
		local radius = 999999
		for _, entity in ipairs(priorities) do
			local distance = pos:Distance(entity.Position)
			if distance < radius then
				radius = distance
				target = entity.Position
			end
		end
	elseif backuptarg then
		target = backuptarg.Position
		dist = 50
	else
		target = targposition
		dist = 120
	end



	return {target, dist}
end

function mod.FindClosestPitEnemy(pos,radius)
	radius = radius or 99999
	local target = nil
	for index,entity in ipairs(Isaac.GetRoomEntities()) do
		for i = 1, #mod.PitEnemies do
			if entity.Type == mod.PitEnemies[i][1] then
				if entity.Variant == mod.PitEnemies[i][2] then
					local distance = pos:Distance(entity.Position)
					if distance < radius then
						radius = distance
						target = entity
					end
				end
			end
		end
	end
	return target
end

function mod.FindClosestPotEnemy(pos,radius)
	radius = radius or 99999
	local target = nil
	for index,entity in ipairs(Isaac.GetRoomEntities()) do
		for i = 1, #mod.PotEnemies do
			if entity.Type == mod.PotEnemies[i][1] then
				if entity.Variant == mod.PotEnemies[i][2] then
					local distance = pos:Distance(entity.Position)
					if distance < radius then
						radius = distance
						target = entity
					end
				end
			end
		end
	end
	return target
end

function mod.FindClosestEntityHasTarget(pos,radius,type,variant,subtype)
	radius = radius or 99999
	type = type or -1
	variant = variant or -1
	subtype = subtype or -1
	local target
	for index,entity in ipairs(Isaac.GetRoomEntities()) do
		if type == -1 or type == entity.Type then
			if variant == -1 or variant == entity.Variant then
				if subtype == -1 or subtype == entity.SubType then
					local distance = pos:Distance(entity.Position)
					if distance < radius then
						if entity:Exists() and not entity:GetData().HasTarget then
							radius = distance
							target = entity
						end
					end
				end
			end
		end
	end
	return target
end


function mod.FindClosestUnlitPowder(pos, npc)
	local target = nil
	local radius = 99999999
	for index,entity in ipairs(Isaac.GetRoomEntities()) do
		if entity.Type == 1000 then
			if entity.Variant == 26 then
				if entity.SubType == 7001 then
					if not entity:GetData().flaming then
						local distance = pos:Distance(entity.Position)
						if distance < radius then
							radius = distance
							target = entity
						end
					end
				end
			end
		end
	end
	return target
end

function mod.FindClosestEnemyEffigy(pos)
	local radius = 99999
	local target = nil
	for _, entity in ipairs(Isaac.GetRoomEntities()) do
		if entity:IsActiveEnemy() and not mod:isFriend(entity) then
			local etype = entity.Type
			local evar = entity.Variant
			local esub = entity.SubType
			local badent = false
			for _, v in ipairs(mod.effigyBlacklist) do
				if v[3] then if etype == v[1] and evar == v[2] and esub == v[3] then badent = true end
				elseif v[2] then if etype == v[1] and evar == v[2] then badent = true end
				elseif etype == v[1] then badent = true end
			end
			for _, v in ipairs(mod.HidingUnderwaterEnts) do
				if v[3] then if etype == v[1] and evar == v[2] and esub == v[3] then badent = true end
				elseif v[2] then if etype == v[1] and evar == v[2] then badent = true end
				elseif etype == v[1] then badent = true end
			end
			if not badent then
				local distance = pos:Distance(entity.Position)
				if distance < radius then
					radius = distance
					target = entity
				end
			end
		end
	end
	--Isaac.ConsoleOutput("{" .. target.Type .. ", " .. target.Variant .. "}\n")
	return target
end

--Pass the npc.Pathfinder for checkpath
function mod.FindClosestSpecificEntity(pos, etype, evar, esub, dist, checkPath)
	etype = etype or -1
	evar = evar or -1
	esub = esub or -1
	dist = dist or 99999

	local closest
	for _, entity in ipairs(Isaac.FindByType(etype, evar, esub, false, true)) do
		if entity.Position:Distance(pos) < dist then
			if checkPath then
				if checkPath:HasPathToPos(entity.Position) then
					closest = entity
				end
			else
				closest = entity
			end
		end
	end
	return closest
end

--WTF was this function
--[[function mod.FindClosestVertRock(npc)
	local position = npc.Position
	local rock
	local room = game:GetRoom()
	for i = 1, room:GetGridSize() do
		local gridEntity = room:GetGridEntity(i)
		if gridEntity ~= nil then

		end
	end
	return target
end]]

--[[function mod.FindClosestVertRock(npc)
	local radius = 99999
	local npcpos = npc.Position
	local npcgridpos = room:GetGridPosition(npcpos)
	local rock
	for i = 1, room:GetGridSize() do
		local gridEntity = room:GetGridEntity(i)
		if gridEntity ~= nil then
			local gridpos = room:GetGridPosition(i)
			if math.abs(npcgridpos.X - gridpos.X) < 20 then
				local distance = npcpos:Distance(gridpos)
				if distance < radius then
					radius = distance
					rock = gridEntity
				end
			end
		end
	end
	return rock
end]]

function mod.FindClosestVertRock(npc)
	local npcpos = npc.Position
	local room = game:GetRoom()
	local posup = room:GetLaserTarget(npcpos, Vector(0,-1))
	local posdown = room:GetLaserTarget(npcpos, Vector(0,1))

	if npcpos:Distance(posdown) < npcpos:Distance(posup) then
		return posdown
	else
		return posup
	end
end

function mod.FindClosestHoriRock(npc)
	local npcpos = npc.Position
	local room = game:GetRoom()
	local posleft = room:GetLaserTarget(npcpos, Vector(-1,0))
	local posright = room:GetLaserTarget(npcpos, Vector(1,0))

	if npcpos:Distance(posright ) < npcpos:Distance(posleft) then
		return posright
	else
		return posleft
	end
end

--[[function mod.GetEntityCountOld(type,variant,subtype)
	local radius = radius or 99999
	local type = type or 0
	local variant = variant or -1
	local subtype = subtype or -1
	local target
	local entitycount = { }
	for index,entity in ipairs(Isaac.GetRoomEntities()) do
		if type == 0 or type == entity.Type then
			if variant == -1 or variant == entity.Variant then
				if subtype == -1 or subtype == entity.SubType then
					table.insert(entitycount, entity)
				end
			end
		end
	end
	return #entitycount
end]]

function mod.GetEntityCount(type,variant,subtype)
	local type = type or -1
	local variant = variant or -1
	local subtype = subtype or -1
	local entitycount = {}
	for index,entity in ipairs(Isaac.FindByType(type, variant, subtype, EntityPartition.ENEMY, true)) do
		table.insert(entitycount, entity)
	end
	return #entitycount
end

function mod.GetBatCount()
	local radius = radius or 99999
	local entitycount = { }
	for index,entity in ipairs(Isaac.GetRoomEntities()) do
		for _, bat in ipairs(mod.BatEnemies) do
			if entity.Type == bat[1] then
				if bat[2] then
					if entity.Variant == bat[2] then
						table.insert(entitycount, entity)
					end
				else
					table.insert(entitycount, entity)
				end
			end
		end
	end
	--Isaac.ConsoleOutput(#entitycount)
	return #entitycount
end

function mod.GetMaggotCount()
	local radius = radius or 99999
	local entitycount = { }
	for index,entity in ipairs(Isaac.GetRoomEntities()) do
		for _, maggot in ipairs(mod.MaggotEnemies) do
			if entity.Type == maggot[1] then
				if maggot[2] then
					if entity.Variant == maggot[2] then
						table.insert(entitycount, entity)
					end
				else
					table.insert(entitycount, entity)
				end
			end
		end
	end
	--Isaac.ConsoleOutput(#entitycount)
	return #entitycount
end

--[[
Sorts entities based on their lowest distance to one of the positions

In sorted order, assigns each entity to the closest position not yet taken

Should assign each entity to the best possible position, without assigning multiple the same position
]]

function mod:PairEntitiesToPositions(ents, positions)
    local entDists = {}
    local takenPositions = {}
    for _, ent in ipairs(ents) do
        local dists = {}
        local highest, lowest = {ind = nil, dist = nil}, {ind = nil, dist = nil}
        for i, pos in ipairs(positions) do
            dists[i] = ent.Position:DistanceSquared(pos)
            if not lowest.dist or lowest.dist > dists[i] then
                lowest.dist = dists[i]
                lowest.ind = j
            end
        end

        dists.ent = ent
        dists.lowest = lowest

        local insertInd = #entDists + 1
        for j, entDist in ipairs(entDists) do
            if dists.lowest.dist > entDist.lowest.dist then
                insertInd = j
            end
        end

        table.insert(entDists, insertInd, dists)
    end

    local entPairs = {}
    for _, entDist in ipairs(entDists) do
        local lowestNotTaken, lowestDist
        for i, dist in ipairs(entDist) do
            if not takenPositions[i] and (not lowestDist or dist < lowestDist) then
                lowestNotTaken = i
                lowestDist = dist
            end
        end

        takenPositions[lowestNotTaken] = true
        entPairs[#entPairs + 1] = {ent = entDist.ent, posind = lowestNotTaken}
    end

    return entPairs
end

function mod.IsEnemyReallyInvulnerable(entity)
    if entity:IsVulnerableEnemy() then
        return false
    else
        local isVuln = false
        for _, ent in ipairs(FiendFolio.NotReallyInvulnerableEnemies) do
            if entity.Type == ent[1] then
                if not ent[2] or entity.Variant == ent[2] then
                    if not ent[3] or entity.SubType == ent[3] then
                        isVuln = true
                        break
                    end
                end
            end
        end

        return not isVuln
    end
end

function mod.AreThereEntitiesButNotThisOne(etype, framecountboolean, evar, esub)
	etype = etype or 0
	evar = evar or -1
	esub = esub or -1
	local entitycount = { }
	for index,entity in ipairs(Isaac.GetRoomEntities()) do
		if not mod.IsEnemyReallyInvulnerable(entity) then
			if not framecountboolean or (framecountboolean and entity.FrameCount) > 120 then
				if not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
					if not ((entity.Type == etype and evar == -1 and esub == -1) or (entity.Type == etype and entity.Variant == evar and esub == -1) or (entity.Type == etype and entity.Variant == evar and esub == entity.SubType)) then
						local badent = false
						for i = 1, #mod.BadEnts do
							if mod.BadEnts[i][2] then
								if entity.Type == mod.BadEnts[i][1] and entity.Variant == mod.BadEnts[i][2] then
									badent = true
								end
							else
								if entity.Type == mod.BadEnts[i][1] then
									badent = true
								end
							end
						end
						if etype ~= 0 then
							for i = 1, #mod.SpecialBadEnts do
								if mod.SpecialBadEnts[i][2] then
									if entity.Type == mod.SpecialBadEnts[i][1] and entity.Variant == mod.SpecialBadEnts[i][2] then
										badent = true
									end
								else
									if entity.Type == mod.SpecialBadEnts[i][1] then
										badent = true
									end
								end
							end
						end
						if entity:GetData().eternalFlickerspirited or entity:GetData().isSpecturnInvuln then
							badent = true
						end
						if not badent then
							table.insert(entitycount, entity)
						end
					end
				end
			end
		end
	end
	if #entitycount > 0 then
		return #entitycount
	else
		return false
	end
end

function mod.areRoomPressurePlatesPressed()
	local room = game:GetRoom()
	if room:HasTriggerPressurePlates() then
		local size = room:GetGridSize()
		for i=0, size do
			local gridEntity = room:GetGridEntity(i)
			if gridEntity then
				local desc = gridEntity.Desc.Type
				if gridEntity.Desc.Type == GridEntityType.GRID_PRESSURE_PLATE then
					if gridEntity:GetVariant() == 0 then
						if gridEntity.State ~= 3 then
							return false
						end
					end
				end
			end
		end
		--Not returned yet?
		return true
	else
		return false
	end
end

mod.ComeOutTables = {
	mod.BadEnts,
	mod.HidingUnderwaterEnts
}

function mod.CanIComeOutYet()
	local room = game:GetRoom()
	local wipeSecondCheck = false --Extra Check for splitting/spawning enemies
	--Give a couple of frames for the room to be properly intialized
	if room:GetFrameCount() <= 1 then
		return false
	else
		--Cancel out if buttons aren't pressed
		if room:HasTriggerPressurePlates() then
			local size = room:GetGridSize()
			for i=0, size do
				local gridEntity = room:GetGridEntity(i)
				if gridEntity then
					local desc = gridEntity.Desc.Type
					if gridEntity.Desc.Type == GridEntityType.GRID_PRESSURE_PLATE then
						if gridEntity:GetVariant() == 0 then
							if gridEntity.State ~= 3 then
								return false
							end
						end
					end
				end
			end
		end
		--waiting enemies only need to be triggered once a room
		if mod.waitingEnemiesTriggered then
			return true
		else
			--real check real
			local good = true
			for index,entity in ipairs(Isaac.GetRoomEntities()) do
				if not mod.dontpreventwaiting(entity) then
					good = false
					break
				end
			end
			if not good then
				mod.comeconsecutivecheck = false
				wipeSecondCheck = true
			else
				if(not mod.comeconsecutivecheck) then
					mod.comeconsecutivecheck = true
					return false
				end
				if mod.comeconsecutivecheck2 and mod.comeconsecutivecheck2 > 5 then
					mod.waitingEnemiesTriggered = true
					return true
				else
					if mod.comeconsecutivecheck2 == nil then
						mod.comeconsecutivecheck2 = 0
					end
					mod.comeconsecutivecheck2 = mod.comeconsecutivecheck2+1
					return false
				end
			end
		end
	end
	if wipeSecondCheck == true then
		mod.comeconsecutivecheck2 = nil
		return false
	end
end

function mod.dontpreventwaiting(entity)
	if entity:GetData().FFBerserkKilled then
		return false
	elseif entity:IsActiveEnemy() and entity:CanShutDoors() then
		if not framecountboolean or (framecountboolean and entity.FrameCount) > 120 then
			if not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
				for k = 1, #mod.ComeOutTables do
					for i = 1, #mod.ComeOutTables[k] do
						if mod.ComeOutTables[k][i][3] then
							if entity.Type == mod.ComeOutTables[k][i][1] and entity.Variant == mod.ComeOutTables[k][i][2] and entity.SubType == mod.ComeOutTables[k][i][3] then
								return true
							end
						elseif mod.ComeOutTables[k][i][2] then
							if entity.Type == mod.ComeOutTables[k][i][1] and entity.Variant == mod.ComeOutTables[k][i][2] then
								return true
							end
						else
							if entity.Type == mod.ComeOutTables[k][i][1] then
								return true
							end
						end
					end
				end
				if entity:ToNPC():GetChampionColorIdx() == 6 then
					return true
				end
				if entity:GetData().WasEternalFlickerspirited then
					return true
				end
				if entity:GetData().madeEternalInvuln then
					return true
				end
				if entity.Type == mod.FF.Centipede.ID and entity.Variant == mod.FF.Centipede.Var then
					if entity.SubType > 0 and entity.SubType < 100 then
						return true
					end
				end
				if entity.Type == mod.FF.Oralid.ID and entity.Variant == mod.FF.Oralid.Var then
					if entity:GetSprite():IsPlaying("Dormant") then
						return true
					end
				end
				if entity.Type == mod.FF.Oralopede.ID and entity.Variant == mod.FF.Oralopede.Var then
					if entity:GetSprite():IsPlaying("Dormant") then
						return true
					end
				end
				if entity.Type == mod.FFID.Ferrium and entity.Variant == mod.FF.Stalagnaught.Var then
					if entity:GetSprite():IsPlaying("InCeiling") then
						return true
					end
				end
				if entity.Type == mod.FF.Bunkter.ID and entity.Variant == mod.FF.Bunkter.Var then
					if entity:ToNPC().I1 ~= 1 and entity.SubType ~= 0 then
						return true
					end
				end
				if entity.Type == mod.FF.Chummer.ID and entity.Variant == mod.FF.Chummer.Var then
					if entity:GetData().pile == true and entity.FrameCount > 80 then
						return true
					end
				end
				--[[if REVEL.ENT.PENANCE_ORB then
					if entity.Type == REVEL.ENT.PENANCE_ORB.Type and entity.Variant == REVEL.ENT.PENANCE_ORB.Variant then
						badent = true
					end
				end
				if REVEL.ENT.PENANCE_SIN then
					if entity.Type == REVEL.ENT.PENANCE_SIN.Type and entity.Variant == REVEL.ENT.PENANCE_SIN.Variant then
						badent = true
					end
				end]]
			end
		end
		return false
	end
	return true
end

function mod.farFromAllPlayers(pos, dist, extrasafe)
dist = dist or 120
	if mod.playerPositions then
		for i = 1, #mod.playerPositions do
			if pos:Distance(mod.playerPositions[i].Position) < dist then
				return false
			end
			if extraSafe and mod.playerVelocities then
				if pos:Distance(mod.playerPositions[i].Position + mod.playerVelocities[i] * 10) < dist then
					return false
				end
			end
		end
		return true
	else
		return false
	end
end

function mod.allPlayersDead()
	for _, p in pairs(Isaac.FindByType(1)) do
		if not p:IsDead() then
			return false
		end
	end
	return true
end

function mod.GetAllEntities(npc,type,variant,subtype)
	local	type = type or 0
	local	variant = variant or 0
	local	subtype = subtype or 0
	local	initseed = npc.InitSeed or 0
	local target
	local entitycount = { }
	for index,entity in ipairs(Isaac.GetRoomEntities()) do
		if not (entity.InitSeed == initseed) then
			if type == 0 or type == entity.Type then
				if variant == 0 or variant == entity.Variant then
					if subtype == 0 or subtype == entity.SubType then
						table.insert(entitycount, entity)
					end
				end
			end
		end
	end
	return entitycount
end

function mod.FindDoorShutter()
	for index,entity in ipairs(Isaac.GetRoomEntities()) do
		if entity:CanShutDoors() then
		return true
		end
	end
	return false
end

function mod.FindExactEnt(ref)
	for index,entity in ipairs(Isaac.GetRoomEntities()) do
		if entity.InitSeed == ref then
		return entity
		end
	end
	return false
end

function mod.GetRefEntity(ref)
	for k,v in ipairs(Isaac.GetRoomEntities()) do
		if v.InitSeed == ref.InitSeed then
			return v
		end
	end
end

function mod:findPickup(pos, radius, bummode, ref)
	bummode = bummode or false
	ref = ref or nil
	local target
	for k,v in ipairs(Isaac.GetRoomEntities()) do
		local pickup = v:ToPickup()
		if pickup ~= nil then
			if pickup.Variant < 50 then
				local d = v:GetData()
				if not d.bumtargeteer or d.bumtargeteer == ref then
					local distance = pos:Distance(pickup.Position)
					if distance < radius then
						radius = distance
						target = pickup
					end
				end
			end
		elseif (v.Type == 9 and v:GetData().projType == "buckbomb") then
			local d = v:GetData()
				if not d.bumtargeteer or d.bumtargeteer == ref then
					local distance = pos:Distance(v.Position)
					if distance < radius then
						radius = distance
						target = pickup
					end
				end
		end
	end
	if target then
		if bummode then
		local bum = mod.FindClosestEntity(target.Position, 99999, mod.FF.Snagger.ID)
			if bum then
				target:GetData().bumtargeteer = bum.InitSeed
			end
		end
	end
	return target
end

mod.BubbleTotal = {}

function mod.ShootBubble(spawner,bubbletype,pos,vector)
local r = spawner:GetDropRNG()
local rand = r:RandomInt(#mod.bubbles)+1
local bubbletype = bubbletype or mod.bubbles[rand]
	if bubbletype == -1 then bubbletype = mod.bubbles[rand] end
local pos = pos or spawner.Position
	if pos == 0 then pos = spawner.Position end
local vector = vector or spawner.Velocity*10
	return mod.spawnent(spawner, pos, vector, mod.FF.Bubble.ID, mod.FF.Bubble.Var, bubbletype)
end

function mod.SpawnAsh(npc,pos,scale)
	local ash = Isaac.Spawn(1000, 26, 7000, pos, nilvector, npc):ToEffect()
	ash.Scale = 1
	ash:GetData().Spawner = npc
	ash.SpawnerEntity = npc
	ash:Update()
	local s = ash:GetSprite()
	s:Load("gfx/effects/1000.092_creep (ash).anm2",true)
	local rand = math.random(6)
	s:Play("SmallBlood0" .. rand,true)
	local d = npc:GetData()
	if #d.AshTable > 0 then
		ash.Parent = d.AshTable[#d.AshTable]
	end
	table.insert(d.AshTable, ash)
end

function mod.SpawnGunpowder(npc, pos, timeout, burntime, spreaddist, uniqueColor, dontDoReplace, ashColor, uniqueSpritesheet)
	local var = 26
	if npc and npc.Type == 1 then
		var = 45
	end
	local ash = Isaac.Spawn(1000, var, 7001, pos, nilvector, npc):ToEffect()
	ash.SpawnerEntity = npc
	local s = ash:GetSprite()
	timeout = timeout or 30
	--spreaddist = spreaddist or 50
	if (not dontDoReplace) then
		s:Load("gfx/effects/1000.092_creep (ash).anm2",true)
		local rand = math.random(6)
		s:Play("SmallBlood0" .. rand,true)
	end
	if ashColor then
		ash:SetColor(FiendFolio.ColorModernOuroborosShitty, 99999, 1, false, false)
	end
	ash:SetTimeout(timeout)
	ash:GetData().burntime = burntime
	ash:GetData().spreaddist = spreaddist
	ash:GetData().uniqueColor = uniqueColor
	ash:GetData().uniqueSpritesheet = uniqueSpritesheet
	ash:Update()
end

function mod:FindRandomValidPathPosition(npc, mode, avoidplayer, nearposses,farposses,ignorepoops)
	local validPositions = {}
	local validPositionsFar = {}
	local validPositionsNear = {}
	local pathfinder = npc.Pathfinder
	local room = game:GetRoom()
	local size = room:GetGridSize()
	nearposses = nearposses or 80
	farposses = farposses or 150
	ignorepoops = ignorepoops or false
	local playertable = {}

	if avoidplayer then
		for _, entity in ipairs(Isaac.GetRoomEntities()) do
			if entity.Type == 1 then
				table.insert(playertable, entity)
			end
		end
	end
	for i=0, size do
		local gridpos = room:GetGridPosition(i)
		local gridEntity = room:GetGridEntity(i)
		local farfromplayer = true
		if npc.Pathfinder:HasPathToPos(gridpos, ignorepoops) and not gridEntity then
			if avoidplayer then
				for k = 1, #playertable do
					if gridpos:Distance(playertable[k].Position) < avoidplayer then
						farfromplayer = false
					end
				end
			end
			if farfromplayer then
				table.insert(validPositions, gridpos)
				if npc.Position:Distance(gridpos) > farposses then
					table.insert(validPositionsFar, gridpos)
				elseif npc.Position:Distance(gridpos) < nearposses and npc.Position:Distance(gridpos) > 30 then
					table.insert(validPositionsNear, gridpos)
				end
			end
		end
	end
	if #validPositionsFar > 0 and mode == 2 then
		return validPositionsFar[math.random(#validPositionsFar)]
	elseif #validPositionsNear > 0 and mode == 3 then
		return validPositionsNear[math.random(#validPositionsNear)]
	elseif #validPositions > 0 then
		return validPositions[math.random(#validPositions)]
	else
		if mode == 10 then
			return false
		else
			return npc.Position
		end
	end
end

function mod:FindRandomVisiblePosition(npc, npcPos, mode, avoidplayer, nearposses,farposses,ignorepoops)
local validPositions = {}
local validPositionsFar = {}
local validPositionsNear = {}
local room = game:GetRoom()
local size = room:GetGridSize()
nearposses = nearposses or 80
farposses = farposses or 150
ignorepoops = ignorepoops or false
local playertable = {}
	if avoidplayer then
		for _, entity in ipairs(Isaac.GetRoomEntities()) do
			if entity.Type == 1 then
				table.insert(playertable, entity)
			end
		end
	end
	for i=0, size do
		local gridpos = room:GetGridPosition(i)
		local gridEntity = room:GetGridEntity(i)
		local farfromplayer = true
		if room:CheckLine(gridpos,npcPos,0,900,false,false) and not gridEntity then
			if avoidplayer then
				for k = 1, #playertable do
					if gridpos:Distance(playertable[k].Position) < avoidplayer then
						farfromplayer = false
					end
				end
			end
			if farfromplayer then
				table.insert(validPositions, gridpos)
				if npc.Position:Distance(gridpos) > farposses then
					table.insert(validPositionsFar, gridpos)
				elseif npcPos:Distance(gridpos) < nearposses and npcPos:Distance(gridpos) > 30 then
					table.insert(validPositionsNear, gridpos)
				end
			end
		end
	end
	if #validPositionsFar > 0 and mode == 2 then
		return validPositionsFar[math.random(#validPositionsFar)]
	elseif #validPositionsNear > 0 and mode == 3 then
		return validPositionsNear[math.random(#validPositionsNear)]
	elseif #validPositions > 0 then
		return validPositions[math.random(#validPositions)]
	else
		if mode == 10 then
			return false
		else
			return npc.Position
		end
	end
end

function mod:IsCampfireWithinRadius(pos, radius)
	radius = radius or 40
	local fires = Isaac.FindByType(33)
	for _, fire in pairs(fires) do
		if fire.Variant < 10 and fire:ToNPC().State ~= 3 then --State 3 = extinguished
			if fire.Position:Distance(pos) <= radius then
				return true
			end
		end
	end
end

--careful with npc, you can pass targets too which crash if you use avoidplayer
function mod:FindRandomFreePos(npc, radius, findnear, avoidplayer, avoidfire)
radius = radius or 0
local validPositions = {}
local validPositionsFar = {}
local validPositionsNear = {}
local room = game:GetRoom()
local size = room:GetGridSize()
	for i=0, size do
		local gridpos = room:GetGridPosition(i)
		--local gridEntity = room:GetGridEntity(i)
		if room:GetGridCollisionAtPos(gridpos) == GridCollisionClass.COLLISION_NONE and room:IsPositionInRoom(gridpos, 0) then
			if (avoidplayer == nil or (avoidplayer and (npc:GetPlayerTarget().Position + (npc:GetPlayerTarget().Velocity * 3)):Distance(gridpos) > 60)) 
			and (avoidfire == nil or (avoidfire and not mod:IsCampfireWithinRadius(gridpos, 40)))
			then
				table.insert(validPositions, gridpos)
				if npc.Position:Distance(gridpos)> radius then
					table.insert(validPositionsFar, gridpos)
				end
				if npc.Position:Distance(gridpos)< radius then
					table.insert(validPositionsNear, gridpos)
				end
			end
		end
	end
	if #validPositionsNear > 0 and findnear then
		return validPositionsNear[math.random(#validPositionsNear)]
	elseif #validPositionsFar > 0 and not findnear then
		return validPositionsFar[math.random(#validPositionsFar)]
	elseif #validPositions > 0 then
		return validPositions[math.random(#validPositions)]
	else
		return room:GetRandomPosition(1)
	end
end

function mod:checkRealGridRock(grid)
	if grid and grid:ToRock() then
		if grid.CollisionClass == GridCollisionClass.COLLISION_SOLID then
			return true
		else
			return false
		end
	end
end

function mod:FindRandomFreePosAir(pos, radius, maxrad)
	radius = radius or 0
	local validPositions = {}
	local validPositionsFar = {}
	local room = game:GetRoom()
	local size = room:GetGridSize()
	for i=0, size do
		local gridpos = room:GetGridPosition(i)
		if room:GetGridCollisionAtPos(gridpos) < GridCollisionClass.COLLISION_WALL then
			table.insert(validPositions, gridpos)
			local dist = pos:Distance(gridpos)
			if dist > radius then
				if maxrad then
					if dist < maxrad then
						table.insert(validPositionsFar, gridpos)
					end
				else
					table.insert(validPositionsFar, gridpos)
				end
			end
		end
	end
	if #validPositionsFar > 0 then
		return validPositionsFar[math.random(#validPositionsFar)]
	elseif #validPositions > 0 then
		return validPositions[math.random(#validPositions)]
	else
		return room:GetRandomPosition(1)
	end
end

function mod:FindRandomFreePosAirNoGrids(pos, radius, maxrad, avoidnearby)
radius = radius or 0
local validPositions = {}
local validPositionsFar = {}
local room = game:GetRoom()
local size = room:GetGridSize()
	for i=0, size do
		local gridpos = room:GetGridPosition(i)
		if room:GetGridCollisionAtPos(gridpos) <= GridCollisionClass.COLLISION_PIT and room:IsPositionInRoom(gridpos, 0) and not gridEntity then
			if (not avoidnearby) or (avoidnearby and not mod.FindClosestEnemy(gridpos, 30)) then
				table.insert(validPositions, gridpos)
				local dist = pos:Distance(gridpos)
				if dist > radius then
					if maxrad then
						if dist < maxrad then
							table.insert(validPositionsFar, gridpos)
						end
					else
						table.insert(validPositionsFar, gridpos)
					end
				end
			end
		end
	end
	if #validPositionsFar > 0 then
		return validPositionsFar[math.random(#validPositionsFar)]
	elseif #validPositions > 0 then
		return validPositions[math.random(#validPositions)]
	else
		return room:GetRandomPosition(1)
	end
end

function mod:FindRandomFreePosAirWithPitOrNoColl(pos, radius, maxrad, avoidnearby)
radius = radius or 0
local validPositions = {}
local validPositionsFar = {}
local room = game:GetRoom()
local size = room:GetGridSize()
	for i=0, size do
		local gridpos = room:GetGridPosition(i)
		if room:GetGridCollisionAtPos(gridpos) <= GridCollisionClass.COLLISION_PIT and room:IsPositionInRoom(gridpos, 0) then
			if (not avoidnearby) or (avoidnearby and not mod.FindClosestEnemy(gridpos, 30)) then
				table.insert(validPositions, gridpos)
				local dist = pos:Distance(gridpos)
				if dist > radius then
					if maxrad then
						if dist < maxrad then
							table.insert(validPositionsFar, gridpos)
						end
					else
						table.insert(validPositionsFar, gridpos)
					end
				end
			end
		end
	end
	if #validPositionsFar > 0 then
		return validPositionsFar[math.random(#validPositionsFar)]
	elseif #validPositions > 0 then
		return validPositions[math.random(#validPositions)]
	else
		return room:GetRandomPosition(1)
	end
end


function mod:FindRandomFreePosOfFour(npc, radius, findnear, avoidplayer)
radius = radius or 0
local validPositions = {}
local validPositionsFar = {}
local validPositionsNear = {}
local room = game:GetRoom()
local size = room:GetGridSize()
	for i=0, size do
		local gridpos = room:GetGridPosition(i) + Vector(20,20)
		local gridEntity = room:GetGridEntity(i)
		local valid = true
		for i = 1, 4 do
			local testpos = gridpos + Vector(20,20):Rotated(i * 90)
			if not (room:GetGridCollisionAtPos(testpos) == GridCollisionClass.COLLISION_NONE and room:IsPositionInRoom(testpos, 0)) then
				valid = false
			end
		end
		if valid and (avoidplayer == nil or (avoidplayer and (npc:GetPlayerTarget().Position + (npc:GetPlayerTarget().Velocity * 3)):Distance(gridpos) > 60)) then
			table.insert(validPositions, gridpos)
			if npc.Position:Distance(gridpos)> radius then
				table.insert(validPositionsFar, gridpos)
			end
			if npc.Position:Distance(gridpos)< radius then
				table.insert(validPositionsNear, gridpos)
			end
		end
	end
	if #validPositionsNear > 0 and findnear then
		return validPositionsNear[math.random(#validPositionsNear)]
	elseif #validPositionsFar > 0 and not findnear then
		return validPositionsFar[math.random(#validPositionsFar)]
	elseif #validPositions > 0 then
		return validPositions[math.random(#validPositions)]
	else
		return room:GetRandomPosition(1)
	end
end

function mod:FindRandomFreePosOfFourPits(npc, radius, findnear, avoidplayer)
radius = radius or 0
local validPositions = {}
local validPositionsFar = {}
local validPositionsNear = {}
local room = game:GetRoom()
local size = room:GetGridSize()
	for i=0, size do
		local gridpos = room:GetGridPosition(i) + Vector(20,20)
		local gridEntity = room:GetGridEntity(i)
		local valid = true
		for i = 1, 4 do
			local testpos = gridpos + Vector(20,20):Rotated(i * 90)
			if not (room:GetGridCollisionAtPos(testpos) == GridCollisionClass.COLLISION_PIT and room:IsPositionInRoom(testpos, 0)) then
				valid = false
			end
		end
		if valid and (avoidplayer == nil or (avoidplayer and (npc:GetPlayerTarget().Position + (npc:GetPlayerTarget().Velocity * 3)):Distance(gridpos) > 60)) then
			table.insert(validPositions, gridpos)
			if npc.Position:Distance(gridpos)> radius then
				table.insert(validPositionsFar, gridpos)
			end
			if npc.Position:Distance(gridpos)< radius then
				table.insert(validPositionsNear, gridpos)
			end
		end
	end
	if #validPositionsNear > 0 and findnear then
		return validPositionsNear[math.random(#validPositionsNear)]
	elseif #validPositionsFar > 0 and not findnear then
		return validPositionsFar[math.random(#validPositionsFar)]
	elseif #validPositions > 0 then
		return validPositions[math.random(#validPositions)]
	else
		return false
	end
end

function mod:FindRandomPit(npc,findClosestToTarget)
local validPositions = {}
local pos = npc.Position
local room = game:GetRoom()
local size = room:GetGridSize()
local radius = 99999
local target = npc:GetPlayerTarget()
	for i=0, size do
		local gridpos = room:GetGridPosition(i)
		local gridEntity = room:GetGridEntity(i)
		if gridEntity then
			local desc = gridEntity.Desc.Type
			if gridEntity.Desc.Type == GridEntityType.GRID_PIT and (mod.FindClosestPitEnemy(gridpos, 10) == nil) and gridpos:Distance(target.Position) > 40 then
				if gridEntity.CollisionClass == GridCollisionClass.COLLISION_PIT  then
					local distance = gridpos:Distance(target.Position)
					table.insert(validPositions, {gridpos, distance})
				end
			end
		end
	end
	if #validPositions > 0 then
		if findClosestToTarget then
			local closesttotarget = nil
			for i = 1, #validPositions do
				if validPositions[i][2] < radius then
					radius = validPositions[i][2]
					closesttotarget = validPositions[i][1]
				end
			end
			if closesttotarget ~= nil then
				return closesttotarget
			else
				return validPositions[math.random(#validPositions)][1]
			end
		else
			return validPositions[math.random(#validPositions)][1]
		end
	else
		return npc.Position
	end
end

function mod:FindRandomWall(npc,findClosestToTarget)
local validPositions = {}
local pos = npc.Position
local room = game:GetRoom()
local size = room:GetGridSize()
local radius = 99999
local target = npc:GetPlayerTarget()
	for i=0, size do
		local gridpos = room:GetGridPosition(i)
		local gridEntity = room:GetGridEntity(i)
		if gridEntity then
			local desc = gridEntity.Desc.Type
			if gridEntity.Desc.Type == GridEntityType.GRID_WALL then
				local distance = gridpos:Distance(target.Position)
				table.insert(validPositions, {gridpos, distance})
			end
		end
	end
	if #validPositions > 0 then
		if findClosestToTarget then
			local closesttotarget = nil
			for i = 1, #validPositions do
				if validPositions[i][2] < radius then
					radius = validPositions[i][2]
					closesttotarget = validPositions[i][1]
				end
			end
			if closesttotarget ~= nil then
				return closesttotarget
			else
				return validPositions[math.random(#validPositions)][1]
			end
		else
			return validPositions[math.random(#validPositions)][1]
		end
	else
		return npc.Position
	end
end

mod.PillarBlacklist = {
	{1},
	mod.ENT("Looksee")
}

function mod:FindRandomPillar(npc,findClosestToTarget)
local validPositions = {}
local pos = npc.Position
local room = game:GetRoom()
local size = room:GetGridSize()
local radius = 99999
local target = npc:GetPlayerTarget()
	for i=0, size do
		local gridpos = room:GetGridPosition(i)
		local gridEntity = room:GetGridEntity(i)
		if gridEntity then
			local desc = gridEntity.Desc.Type
			if gridEntity.Desc.Type == GridEntityType.GRID_PILLAR then
				local tooClose = false
				for i = 1, #mod.PillarBlacklist do
					local radius = 10
					if mod.PillarBlacklist[i][1] == 1 then
						radius = 150
					end
					for j = -40, 40, 40 do
						if mod.FindClosestEntity(gridpos + Vector(j, 0), radius, mod.PillarBlacklist[i][1], mod.PillarBlacklist[i][2] or nil, mod.PillarBlacklist[i][3] or nil, nil, npc.InitSeed) then
							tooClose = true
						end
					end
					if not (room:GetGridCollisionAtPos(gridpos + Vector(40, 0)) < GridCollisionClass.COLLISION_OBJECT or room:GetGridCollisionAtPos(gridpos + Vector(-40, 0)) < GridCollisionClass.COLLISION_OBJECT) then
						tooClose = true
					end
				end
				if not tooClose then
					local distance = gridpos:Distance(target.Position)
					table.insert(validPositions, {gridpos, distance})
				end
			end
		end
	end
	if #validPositions > 0 then
		if findClosestToTarget then
			local closesttotarget = nil
			for i = 1, #validPositions do
				if validPositions[i][2] < radius then
					radius = validPositions[i][2]
					closesttotarget = validPositions[i][1]
				end
			end
			if closesttotarget ~= nil then
				return closesttotarget, true
			else
				return validPositions[math.random(#validPositions)][1], true
			end
		else
			return validPositions[math.random(#validPositions)][1], true
		end
	else
		return npc.Position, false
	end
end

function mod:IsCurrentPitSafe(npc)
	local room = Game():GetRoom()
	local pit = room:GetGridCollisionAtPos(npc.Position)
	if pit == GridCollisionClass.COLLISION_PIT then
		return true
	else
		return false
	end
end

function mod:FindRandomPot(npc,findClosestToTarget)
local validPositions = {}
local pos = npc.Position
local room = game:GetRoom()
local size = room:GetGridSize()
local radius = 99999
local target = npc:GetPlayerTarget()
	for i=0, size do
		local gridpos = room:GetGridPosition(i)
		local gridEntity = room:GetGridEntity(i)
		if gridEntity then
			local desc = gridEntity.Desc.Type
			if gridEntity.Desc.Type == GridEntityType.GRID_ROCK_ALT and (mod.FindClosestPotEnemy(gridpos, 10) == nil) and gridpos:Distance(target.Position) > 40 then
				--if gridEntity.CollisionClass == GridCollisionClass.COLLISION_PIT  then
					local distance = gridpos:Distance(target.Position)
					table.insert(validPositions, {gridpos, distance})
				--end
			end
		end
	end
	if #validPositions > 0 then
		if findClosestToTarget then
			local closesttotarget = nil
			for i = 1, #validPositions do
				if validPositions[i][2] < radius then
					radius = validPositions[i][2]
					closesttotarget = validPositions[i][1]
				end
			end
			if closesttotarget ~= nil then
				return closesttotarget
			else
				return validPositions[math.random(#validPositions)][1]
			end
		else
			return validPositions[math.random(#validPositions)][1]
		end
	else
		return npc.Position
	end
end

function mod:FindNearbyDoor(pos,findClosestToTarget)
local validPositions = {}
local room = game:GetRoom()
local size = room:GetGridSize()
local radius = 99999
	for i=0, size do
		local gridpos = room:GetGridPosition(i)
		local gridEntity = room:GetGridEntity(i)
		if gridEntity then
			local desc = gridEntity.Desc.Type
			if gridEntity.Desc.Type == GridEntityType.GRID_DOOR then
				local distance = gridpos:Distance(pos)
				table.insert(validPositions, {gridpos, distance})
			end
		end
	end
	if #validPositions > 0 then
		if findClosestToTarget then
			local closesttotarget = nil
			for i = 1, #validPositions do
				if validPositions[i][2] < radius then
					radius = validPositions[i][2]
					closesttotarget = validPositions[i][1]
				end
			end
			if closesttotarget ~= nil then
				return closesttotarget
			else
				return validPositions[math.random(#validPositions)][1]
			end
		else
			return validPositions[math.random(#validPositions)][1]
		end
	else
		return pos
	end
end

function mod:SnapVector(angle, snapAngle)
local snapped = math.floor(((angle:GetAngleDegrees() + snapAngle/2) / snapAngle)) * snapAngle
local snappedDirection = angle:Rotated(snapped - angle:GetAngleDegrees())
return snappedDirection
end

function mod:FindRandomGravity(npc)
local validPositions = {}
local pos = npc.Position
local room = game:GetRoom()
local size = room:GetGridSize()
local radius = 99999
local target = npc:GetPlayerTarget()
	for i=0, size do
		local gridpos = room:GetGridPosition(i)
		local gridEntity = room:GetGridEntity(i)
		if gridEntity then
			local desc = gridEntity.Desc.Type
			local lowercoll = room:GetGridCollisionAtPos(Vector(gridpos.X, gridpos.Y + 50))
			if gridEntity.Desc.Type == GridEntityType.GRID_GRAVITY and lowercoll ~= GridCollisionClass.COLLISION_WALL then
				table.insert(validPositions, gridpos)
			end
		end
	end
	if #validPositions > 0 then
		return validPositions[math.random(#validPositions)]
	else
		return npc.Position
	end
end

function mod:FindClosestPoop(pos)
local radius = 999999
local validPositions = {}
local room = game:GetRoom()
local size = room:GetGridSize()
	for i=0, size do
		local gridEntity = room:GetGridEntity(i)
		if gridEntity then
			local desc = gridEntity.Desc.Type
			if gridEntity.Desc.Type == GridEntityType.GRID_POOP then
				if gridEntity.State < 1000 then
					local distance = (pos - gridEntity.Position):Length()
					if distance < radius - 10 then
						radius = distance
						validPositions = {gridEntity}
					elseif distance < radius + 10 then
						table.insert(validPositions, gridEntity)
					end
				end
			end
		end
	end
	if #validPositions > 0 then
		return validPositions[math.random(#validPositions)]
	else
		return nil
	end
end

function mod:DestroyNearbyGrid(npc, radius, spawnPit)
radius = radius or 30
local validPositions = {}
local pos = npc.Position
local room = game:GetRoom()
local size = room:GetGridSize()
local successfulPit
	for i=0, size do
		local gridpos = room:GetGridPosition(i)
		local gridEntity = room:GetGridEntity(i)
		if gridEntity then
			local desc = gridEntity.Desc.Type
			if (pos:Distance(gridpos) < radius) then
				gridEntity:Destroy()
			end
		end
		if spawnPit and (pos:Distance(gridpos) < radius) then
			local pit = Isaac.GridSpawn(7, 0, gridpos, true)
			successfulPit = true
		end
	end

	if successfulPit then
		mod:UpdatePits(0)
	end
end

function mod:UpdatePits(newIndex)
	local room = game:GetRoom()
	local size = room:GetGridSize()
	for i=0, size do
		local gridEntity = room:GetGridEntity(i)
		if gridEntity then
			if gridEntity.Desc.Type == GridEntityType.GRID_PIT then
				if newIndex then --For when spawning pits while a room is under progress, this prevents visual oddness with standalone pits changing sprites
					if mod:IsPitAdjacent(i) or i == newIndex then
						gridEntity:PostInit()
					else
						gridEntity.CollisionClass = GridCollisionClass.COLLISION_PIT
					end
				else --Otherwise, just do it as normal
					gridEntity:PostInit()
				end
			end
		end
	end

	local roomGfx = mod:getCurrentRoomGfx()
	if roomGfx then
		StageAPI.ChangeGrids(roomGfx.Grids)
	end
	--room = game:GetRoom()
end

function mod:UpdateRocks()
	local room = game:GetRoom()
	local size = room:GetGridSize()
	for i=0, size do
		local gridEntity = room:GetGridEntity(i)
		if gridEntity then
			if gridEntity.Desc.Type == GridEntityType.GRID_ROCK then
				gridEntity:PostInit()
			end
		end
	end

	local roomGfx = mod:getCurrentRoomGfx()
	if roomGfx then
		StageAPI.ChangeGrids(roomGfx.Grids)
	end
	--room = game:GetRoom()
end

function mod:GetPositionAligned(pos1, pos2, leeway, mode) --Modes(1: Cardinal, 2: Diagonal, 3: Both) UNIMPLEMENTED
	local targrel = nil
	local aligned = nil
	if mode == 2 then
		--I ain't workin boi
	else

		local targdistance = pos1 - pos2
		if math.abs(targdistance.X) > math.abs(targdistance.Y) then
			if targdistance.X < 0 then
				targrel = 3 -- Left
			else
				targrel = 1 -- Right
			end
		else
			if targdistance.Y < 0 then
				targrel = 0 -- Up
			else
				targrel = 2 -- Down
			end
		end

		if leeway then
			if targrel % 2 == 0 then
				if math.abs(math.abs(pos1.X) - math.abs(pos2.X)) > leeway then
					targrel = false
				end
			else
				if math.abs(math.abs(pos1.Y) - math.abs(pos2.Y)) > leeway then
					targrel = false
				end
			end
		end
	end

	return targrel
end

function mod:GetNewPosAligned(pos,ignorerocks)
	local room = game:GetRoom()
	local vec = Vector(0, 40)
	local positions = {}
	for i = 1, 4 do
		local gridvalid = true
		local dist = 1
		while gridvalid == true do
			local newpos = pos + (vec:Rotated(i*90) * dist)
			local gridColl = room:GetGridCollisionAtPos(newpos)
			if (gridColl ~= GridCollisionClass.COLLISION_NONE or dist > 25) and not ignorerocks then
				gridvalid = false
			elseif ignorerocks and gridColl == GridCollisionClass.COLLISION_WALL or dist > 25 then
				gridvalid = false
			else
				table.insert(positions, newpos)
				dist = dist + 1
			end
		end
	end
	--[[for i = 1, #positions do
		Isaac.Spawn(5, 40, 0, positions[i], nilvector, npc):ToEffect()
	end]]
	if #positions > 0 then
		return positions[math.random(#positions)]
	else
		return pos
	end
end

function mod:GetClosestWall(pos, Alignment)
	local vec = Vector(0, 40)
	local room = Game():GetRoom()
	pos = room:GetGridPosition(room:GetGridIndex(pos))
	local wall = {Position = pos, Dist = 99999, Alignment = 1}

	for i = 1, 4 do
		local keepSearching = true
		local dist = 1
		while keepSearching == true do
			local newpos = pos + (vec:Rotated(i*90) * dist)
			local grident = room:GetGridEntityFromPos(newpos)
			if grident and (grident.Desc.Type == GridEntityType.GRID_WALL or grident.Desc.Type == GridEntityType.GRID_DOOR) then
				if dist < wall.Dist then
					wall = {Position = newpos, Dist = dist, Alignment = i}
				end
				keepSearching = false
			else
				dist = dist + 1
				if dist > 800 then
					keepSearching = false
				end
			end
		end
	end
	if Alignment then
		return {wall.Position, wall.Alignment}
	else
		return wall.Position
	end
end

function mod:GetClosestVerticalGridPos(pos)
	local dist = 0
	local room = Game():GetRoom()

	local keepsearching = true
	local gridpos

	repeat
		dist = dist + 40
		for i = 0, 1 do
			if room:GetGridCollisionAtPos(pos + Vector(0, dist):Rotated(i * 180)) > 0 then
				gridpos = pos + Vector(0, dist):Rotated(i * 180)
				dist = 801
				break
			end
		end
	until (dist > 800)

	if gridpos then
		return gridpos
	else
		return pos
	end
end

function mod.GetGridEntities()
	local room = game:GetRoom()
	local size = room:GetGridSize()-1
	local grids = {}
	for i=0, size do
		local grid = room:GetGridEntity(i)
		if grid then
			table.insert(grids,grid)
		end
	end
	return grids
end

function mod:diagonalMove(npc, speed, thirdboolean, xmult)
	xmult = xmult or 1
	local xvel = speed * xmult
	local yvel = speed
	if npc.Velocity.X < 0 then
		xvel = xvel * -1
	end
	if npc.Velocity.Y < 0 then
		yvel = yvel * -1
	end

	if mod:isScare(npc) then
		if npc:GetPlayerTarget() then
			local pdist = npc:GetPlayerTarget().Position:Distance(npc.Position)
			if pdist < 100 then
				local vec = (npc.Position - npc:GetPlayerTarget().Position):Resized(math.max(5, 10 - pdist/20))
				xvel = vec.X
				yvel = vec.Y
			end
		end
	end
	if mod:isConfuse(npc) then
		local vec = mod:confusePos(npc, Vector(xvel, yvel), nil, true)
		xvel = vec.X
		yvel = vec.Y
	end
	if thirdboolean then
		return Vector(xvel, yvel)
	else
        npc.Velocity = Vector(xvel, yvel)
	end
end


--[[attacktable format
{name, timesattacked}
]]

function mod.ChooseNextAttack(attacktable, randomgen)
	--Initialises variables, so highest and lowest remain consistent during the loop.
	--Attack choice could be after the loop, but it's snug here with the others.
	local highest
	local lowest
	local attackchoice

	--Some awkward complex code to check which attacks are least used.
	--Cycles through all the attacks, and how often they've been done
	--You can check exactly what attacktable is in the table being passed.
	for attacks = 1, #attacktable do

		--If there are no high/low values yet, set them
		--The [1] value is the string name of the attack, [2] is the times the attack has been done.
		highest = highest or {{attacktable[attacks][1], attacktable[attacks][2]}}
		lowest = lowest or {{attacktable[attacks][1], attacktable[attacks][2]}}

		--This compares whether the attack here is done more than the current most done
		--If the attack has been performed more, it will replace the highest with the most done attack
		if attacktable[attacks][2] > highest[1][2] then
			highest = {{attacktable[attacks][1], attacktable[attacks][2]}}
		--If found to be equal, a table of highest values is created (not really that necessary tbh)
		elseif attacktable[2] == highest[1][2] then
			table.insert(highest, {attacktable[attacks][1]})
		end

		--This is then the opposite, checking which attack has been done the least
		if attacktable[attacks][2] < lowest[1][2] then
			lowest = {{attacktable[attacks][1], attacktable[attacks][2]}}
		--If both attacks are equally lowest, creates a table so they can be randomly chosen.
		elseif attacktable[2] == lowest[1][2] then
			table.insert(lowest, {attacktable[attacks][1]})
		end
	end

	--This is to check if the least done attack is significantly less done.
	if lowest[1][2] < highest[1][2] - 1 then
		--If there's more than one lowest used attack, will select between then randomly
		local ran = randomgen:RandomInt(#lowest) + 1
		attackchoice = lowest[ran][1]
	--Otherwise just choose a random attack from the whole pool.
	else
		local ran = randomgen:RandomInt(#attacktable) + 1
		attackchoice = attacktable[ran][1]
	end

	return attackchoice
end

------------------------------------------------------------------------
--Mini Functions

if type(FiendFolio.cheekyspawn) ~= "function" then
	function mod.cheekyspawn(pos, spawner, targetpos, etype, evar, esub, splatcolor, health)
		EntityNPC.ThrowSpider(pos,spawner,targetpos,false,0);
		local ents = Isaac.GetRoomEntities()
	    for _, entity in ipairs(Isaac.GetRoomEntities()) do
	        if (entity.Type == 85 or entity.Type == 814) and entity.SpawnerType == spawner.Type and	entity.SpawnerVariant == spawner.Variant and not (entity:GetData().CheekySpawned) then
				entity:ToNPC():Morph(etype,evar,esub,-1)
				entity:ToNPC().State = NpcState.STATE_MOVE
				entity:ToNPC().HitPoints = entity:ToNPC().MaxHitPoints
				entity:GetData().CheekySpawned = true
				entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				if splatcolor then
					entity.SplatColor = splatcolor;
				end
				if health then
					entity.HitPoints = health;
				end
				return entity
	        end
	    end
	end
end

function mod.spawnent(parent, pos, veloc, etype, evar, esub, health)
	evar = evar or 0
	esub = esub or 0
	local entity = Isaac.Spawn(etype, evar, esub, pos, veloc, parent)
	entity:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	if health then
		entity.HitPoints = health;
	end
	return entity
end

--function for lust style movement
function mod:lustymove(npc, npcdata, target, acceleration, velocitymax)
	local distance = math.sqrt(((target.X-npc.Position.X)^2)+((target.Y-npc.Position.Y)^2));
	local angle = math.atan((target.Y-npc.Position.Y)/(target.X-npc.Position.X));
	angle = math.deg(angle);
	if npc.Position.X >= target.X then
	angle = angle + 180;
	end
	if velocitymax ~= nil then
		local speed = math.sqrt(((npc.Velocity.X)^2)+((npc.Velocity.Y)^2));
		local velocityangle = 0;
		if npc.Velocity.X == 0 then
			velocityangle = 0;
		else
			velocityangle = math.atan((npc.Velocity.Y)/(npc.Velocity.X));
			velocityangle = math.deg(velocityangle);
		end
		if npc.Velocity.X <= 0 then
			velocityangle = velocityangle + 180;
		end
		npc.Velocity = Vector(speed,0):Rotated(velocityangle) + Vector(acceleration,0):Rotated(angle);
		if speed > velocitymax then
			npc.Velocity = Vector(velocitymax, 0):Rotated(velocityangle)+Vector(acceleration,0):Rotated(angle);
		else
			npc.Velocity = Vector(speed,0):Rotated(velocityangle) + Vector(acceleration,0):Rotated(angle);
		end
	else
		npc.Velocity = npc.Velocity + Vector(acceleration,0):Rotated(angle)
	end
end

--function for movement for large blobby enemies, somewhat like dinga
function mod:heavymovement(npc, npcdata, speed, accel, mintime, maxtime)
	--basic timer behavior
	if not npcdata.heavytimer then
		npcdata.heavytimer = 0;
	end
	if not npcdata.heavyangle then
		npcdata.heavyangle = math.random(0,359);
	end
	npcdata.heavytimer = npcdata.heavytimer - 1;
	if npcdata.heavytimer <= 0 then
		npcdata.heavyangle = math.random(0,359);
		npcdata.heavytimer = math.random(mintime, maxtime);
	end
	--its ok to copy from my lust function because i made it
	mod:lustymove(npc, npcdata, Vector(1000000, 0):Rotated(npcdata.heavyangle),accel, speed);

	--check if standing still
	if npc:CollidesWithGrid() == true then
		npcdata.heavytimer = npcdata.heavytimer - 5
	end
end

------------------------------------------------------------------------
--Dunno who made these ones

-- Hi Erfly! Hi!
-- I (Xalum), made ThrowMaggot
-- Taiga made applyFakeDamageFlash (hello hello)

function mod.ThrowMaggot(pos, vel, z_init, z_vel, spawner, hp_mul)
	local maggot = Isaac.Spawn(853, 0, 0, pos, vel, spawner):ToNPC()
	maggot.State = 16
	maggot.PositionOffset = Vector(0, z_init)
	maggot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

	local data = maggot:GetData()
	data.isthrown = true
	data.z_vel = z_vel
	data.forcevel = vel

	return maggot
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
	local data = npc:GetData()
	if data.isthrown then
		if data.z_vel < 0 then
			npc.PositionOffset = Vector(0, npc.PositionOffset.Y + data.z_vel)
			data.z_vel = data.z_vel + 1
			npc.Position = npc.Position + data.forcevel
		end
		if npc.PositionOffset.Y ~= 0 then npc.State = 16 end
	end
end, 853)

function mod:applyFakeDamageFlash(entity)
	entity:SetColor(FiendFolio.damageFlashColor, 2, 0, false, false)
end

function mod:makeCharmProj(npc, projectile)
	local proj = projectile:ToProjectile()
	if mod:isFriend(npc) then
		proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.HIT_ENEMIES
		return true
	elseif mod:isCharm(npc) then
		proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.HIT_ENEMIES
		return true
	else
		return false
	end
end

mod.gridToProjectile = {
	[GridEntityType.GRID_ROCK] = {["spritesheet"] = "rock", ["special"] = "visuals"},
	[GridEntityType.GRID_ROCKT] = {["spritesheet"] = "rock"},
	[GridEntityType.GRID_ROCK_BOMB] = {["spritesheet"] = "rock"},
	[GridEntityType.GRID_ROCK_ALT] = {["spritesheet"] = "rock", ["special"] = "visuals"},
	[GridEntityType.GRID_TNT] = {["special"] = "tnt"},
	[GridEntityType.GRID_POOP] = {["special"] = "poop"},
	[GridEntityType.GRID_ROCK_SS] = {["spritesheet"] = "rock", ["special"] = "supersecret"},
	[GridEntityType.GRID_ROCK_SPIKED] = {["spritesheet"] = "rock", ["special"] = "visuals"},
	[GridEntityType.GRID_ROCK_ALT2] = {["spritesheet"] = "rock"},
	[GridEntityType.GRID_ROCK_GOLD] = {["spritesheet"] = "rock", ["special"] = "visuals"},
}

mod.gridToProjectileSpecials = {
	[GridEntityType.GRID_ROCKB] = {["spritesheet"] = "rock", ["customDeath"] = function(proj) SFXManager():Play(SoundEffect.SOUND_METAL_BLOCKBREAK, 1, 0, false, 1)
		for i = 1, 6 do
			local particle = Isaac.Spawn(1000, 27, 0, proj.Position, RandomVector()*math.random(8,35)/10, proj)
			particle:GetSprite():ReplaceSpritesheet(0, "gfx/grid/super_tnt.png")
			particle:GetSprite():LoadGraphics()
			particle:GetData().turnedIntoCoolBetterParticles = true
			particle:GetSprite().Rotation = math.random(360)
			particle:Update()
		end end},
	[GridEntityType.GRID_LOCK] = {["special"] = "lock", ["customDeath"] = function(proj) SFXManager():Play(SoundEffect.SOUND_METAL_BLOCKBREAK, 1, 0, false, 1)
		for i = 1, 6 do
			local particle = Isaac.Spawn(1000, 27, 0, proj.Position, RandomVector()*math.random(8,35)/10, proj)
			particle:GetSprite():ReplaceSpritesheet(0, "gfx/grid/super_tnt.png")
			particle:GetSprite():LoadGraphics()
			particle:GetData().turnedIntoCoolBetterParticles = true
			particle:GetSprite().Rotation = math.random(360)
			particle:Update()
		end end},
	--[GridEntityType.GRID_TNT] = {["special"] = "tnt", ["custom"] = "tnt"},
}

--Mode: true is projectiles, false is tears.
function mod:turnGridtoProjectile(spawner, index, velocity, mode, flags, leaveGrid, specialSelection)
	local room = game:GetRoom()
	local grid = room:GetGridEntity(index)
	if grid and (grid.CollisionClass == GridCollisionClass.COLLISION_SOLID or grid.CollisionClass == GridCollisionClass.COLLISION_OBJECT or grid.CollisionClass == GridCollisionClass.COLLISION_WALL) then
		local gridType = grid:GetType()
		local gridVar = grid:GetVariant()
		local results = mod.gridToProjectile[gridType]
		local deathData
		if specialSelection then
			for _,num in pairs(specialSelection) do
				if num == gridType then
					results = mod.gridToProjectileSpecials[gridType]
				end
			end
		end
		if results then
			local state = grid.State
			local sprite = grid:GetSprite()
			local gridAnim = sprite:GetAnimation()
			local gridAnm2 = sprite:GetFilename()
			local gridFrame = 0
			if results.special == "visuals" then
				gridFrame = sprite:GetFrame()
			end
			local poopNum = 0
			local poopSheet
			if results.special == "poop" then
				poopSheet = mod.GetPoopSpritesheet(grid)
				poopNum = grid:GetVariant()
			end
			if gridType == GridEntityType.GRID_ROCK_SPIKED then
				gridType = GridEntityType.GRID_ROCK
			end

			if gridAnim == "big" then
				gridAnim = "normal"
				gridFrame = math.random(3)
				grid:Destroy(true)
				for _,particle in ipairs(Isaac.FindByType(1000, 4, -1, false, false)) do
					if particle.FrameCount == 0 and particle.Position:Distance(room:GetGridPosition(index)) < 10 then
						particle:Remove()
					end
				end
				sfx:Stop(SoundEffect.SOUND_ROCK_CRUMBLE)
			end

			local gridConfig = nil
			if StageAPI.GetCustomGrids(index)[1] and StageAPI.GetCustomGrids(index)[1].GridConfig then
				for key,result in pairs(StageAPI.GetCustomGrids(index)[1].GridConfig) do
					local blacklists = {"RNG", "RecentlyLifted", "GridIndex", "GridEntity", "GridConfig", "Initialized", "RoomIndex", "PersistentIndex", "RecentProjectileHelper", "Data", "LastFilename"}
				end
				gridConfig = true
			end

			room:RemoveGridEntity(index, 0, false)
			FiendFolio.scheduleForUpdate(function()
				room:SpawnGridEntity(index, 1, 0, 0, 0)
				--[[Isaac.GridSpawn(2, 0, room:GetGridPosition(index), false)
				local newRock = room:GetGridEntity(index)
				newRock:Destroy(true)
				for _,particle in ipairs(Isaac.FindByType(1000, 4, -1, false, false)) do
					if particle.FrameCount == 0 and particle.Position:Distance(room:GetGridPosition(index)) < 10 then
						particle:Remove()
					end
				end
				sfx:Stop(SoundEffect.SOUND_ROCK_CRUMBLE)]]
				local newRock = room:GetGridEntity(index)
				if newRock then
					local temp = newRock:GetSprite()
					temp:ReplaceSpritesheet(0, "gfx/nothing.png")
					temp:LoadGraphics()
				end
				mod:makeDecorInvisible(index)
			end, 2)
			--[[local helper = Isaac.Spawn(1000, 136, 0, room:GetGridPosition(index), Vector.Zero, spawner):ToEffect()
			helper.Parent = npc]]
			local subt = (gridType*65536)+gridFrame+poopNum
			if gridConfig then
				--subt = 0
			end

			local proj
			if mode then
				proj = Isaac.Spawn(9, 8, subt, room:GetGridPosition(index), (velocity or Vector.Zero), spawner):ToProjectile()
			else
				proj = Isaac.Spawn(2, 40, subt, room:GetGridPosition(index), (velocity or Vector.Zero), spawner):ToTear()
			end
			local pSprite = proj:GetSprite()
			local pData = proj:GetData()
			pSprite:Load(gridAnm2)

			local RoomSeed = room:GetSpawnSeed()
			if mod.d12ed_Rooms[RoomSeed] and results.spritesheet == "rock" and not gridConfig then
				if mod.d12ed_Rooms[RoomSeed].Type == 1 then
					pSprite:ReplaceSpritesheet(0, "gfx/grid/rocks_d12.png")
					pSprite:LoadGraphics()
					pData.d12 = 1
				elseif mod.d12ed_Rooms[RoomSeed].Type == 2 then
					pSprite:ReplaceSpritesheet(0, "gfx/grid/rocks_ed12.png")
					pSprite:LoadGraphics()
					pData.d12 = 2
				end
			elseif results.spritesheet == "rock" and not gridConfig then
				local roomgfx = mod:getCurrentRoomGfx()
				local backdropType = room:GetBackdropType()
				if roomgfx and roomgfx.Grids and roomgfx.Grids.Rocks then
					pSprite:ReplaceSpritesheet(0, roomgfx.Grids.Rocks)
					pSprite:LoadGraphics()
				elseif mod.backdropRockSpritesheets[backdropType] then
					pSprite:ReplaceSpritesheet(0, mod.backdropRockSpritesheets[backdropType])
					pSprite:LoadGraphics()
				end
			elseif results.special == "poop" and not gridConfig then
				pSprite:ReplaceSpritesheet(0, poopSheet)
				pSprite:LoadGraphics()
			end
			pSprite:Play(gridAnim, true)
			if gridFrame > 0 then
				pSprite:SetFrame(gridAnim, gridFrame)
				pData.rockFrame = gridFrame
			end
			pData.gridProjectile = true
			if mode and spawner:ToNPC() then
				mod:makeCharmProj(spawner, proj)
			end
			if flags and mode then
				proj.ProjectileFlags = proj.ProjectileFlags | flags
			elseif flags then
				proj:AddTearFlags(flags)
			end
			if leaveGrid then
				pData.leaveGrid = {gridType, gridVar}
				pData.gridState = state
				if gridConfig ~= nil then
					pData.leaveCustomGrid = StageAPI.GetCustomGrids(index)[1]
				end
			end

			if gridConfig ~= nil then
				pData.CustomGrid = StageAPI.GetCustomGrids(index)[1]
				StageAPI.GetCustomGrids(index)[1].Projectile = proj
				StageAPI.GetCustomGrids(index)[1]:RemoveFromGrid()
			end

			if results.customDeath then
				pData.specialGridDeath = results.customDeath
			end

			return proj
		else
			return nil
		end
	else
		return nil
	end
end

function mod:turnEntitytoProjectile(spawner, ent, velocity, mode, flags, leaveEnemy, anm2, anim, overlay, deathFunc, gridPath)
	if ent and ent:Exists() then
		local sprite = ent:GetSprite()
		anm2 = anm2 or sprite:GetFilename()
		anim = anim or sprite:GetAnimation()
		overlay = overlay or sprite:GetOverlayAnimation()

		local proj
		if mode then
			proj = Isaac.Spawn(9, 8, 0, ent.Position, (velocity or Vector.Zero), spawner):ToProjectile()
		else
			proj = Isaac.Spawn(2, 40, 0, ent.Position, (velocity or Vector.Zero), spawner):ToTear()
		end
		local pSprite = proj:GetSprite()
		local pData = proj:GetData()
		pSprite:Load(anm2, true)
		pSprite:Play(anim)
		pData.projAnim = anim
		if overlay then
			pSprite:PlayOverlay(overlay)
			pData.projAnimOverlay = overlay
		end
		pData.enemyTurnedProjectile = true
		if mode and spawner:ToNPC() then
			mod:makeCharmProj(spawner, proj)
		end
		if flags and mode then
			proj.ProjectileFlags = proj.ProjectileFlags | flags
		elseif flags then
			proj:AddTearFlags(flags)
		end
		if leaveEnemy then
			pData.leaveEnemy = ent
			pData.enemyState = ent.State
			pData.hitPoints = ent.HitPoints
		end

		if deathFunc then
			pData.enemyProjDeath = deathFunc
			pData.enemyProjEnt = ent
		end
		if ent.Type == 292 then
			proj:Update() --these barrels don't work nicely, for some reason
		end
		ent:Remove()

		if gridPath then
			local room = Game():GetRoom()
			local index = room:GetGridIndex(ent.Position)
			room:SetGridPath(index, 0)
		end

		return proj
	else
		return nil
	end
end

function mod:isAnimaChained(npc)
	local chained
	for _,chain in ipairs(Isaac.FindByType(1000, EffectVariant.ANIMA_CHAIN, -1, false, false)) do
		if chain.Target and chain.Target.InitSeed == npc.InitSeed then
			chained = true
		end
	end
	if chained then
		return true
	else
		return false
	end
end
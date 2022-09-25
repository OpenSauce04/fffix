local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:dogmeatAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not d.init then
		npc.SpriteOffset = Vector(0,-10)
		d.state = "idle"
		d.init = true
		npc.StateFrame = 60
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if mod.TrueVoteOutcome then
		if not sprite:IsPlaying("Appear") then
			Isaac.Spawn(1000,19,0, npc.Position, nilvector, npc)
			Isaac.Explode(npc.Position, npc, 5)
			npc:Kill()
		end
	end

	if npc.State == 11 then
		npc.Velocity = nilvector
		if npc.FrameCount % 4 == 0 then
			local blood = Isaac.Spawn(1000, 5, 0, npc.Position, RandomVector()*3, npc):ToEffect();
			blood:Update()

			local bloo2 = Isaac.Spawn(1000, 2, 0, npc.Position, RandomVector()*3, npc):ToEffect();
			bloo2.SpriteScale = Vector(1,1)
			bloo2.SpriteOffset = Vector(-3+math.random(14), -45+math.random(40))
			bloo2:Update()

			npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,0.2,0,false,0.8)
		end
		if sprite:IsFinished("Death") then
			local fleshlord = mod.spawnent(npc, npc.Position, nilvector, mod.FF.NerveCluster.ID, mod.FF.NerveCluster.Var)
			fleshlord.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			for i = 1, math.random(2,3) do
				local chunk = mod.spawnent(npc, npc.Position, RandomVector():Resized(math.random(3,6)), 310, 1)
				chunk.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			end
			npc:Kill()
		elseif not sprite:IsPlaying("Death") then
			sprite:Play("Death", true)
		end
	else
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		if d.state == "idle" then
			if npc.Velocity.Y < 0 then
				if d.dir == 0 then
					local fr = sprite:GetFrame()
					sprite:SetFrame("WalkUp", fr)
				end
				d.dir = 1
				mod:spritePlay(sprite, "WalkUp")
			else
				if d.dir == 1 then
					local fr = sprite:GetFrame()
					sprite:SetFrame("WalkDown", fr)
				end
				d.dir = 0
				mod:spritePlay(sprite, "WalkDown")
			end
			if npc.Velocity.X < 0 then
				sprite.FlipX = true
			else
				sprite.FlipX = false
			end
			npc.Velocity = npc.Velocity * 0.97
			if npc.StateFrame % 100 == 1 or not d.target then
				d.target = mod:FindRandomFreePos(npc, 120)
			end
			if sprite:GetFrame() == 14 then
				if mod:isScare(npc) then
					d.target = mod:runIfFear(npc, d.target, nil, true)
				elseif mod:isConfuse(npc) then
					d.target = mod:FindRandomFreePos(npc, 120)
				end
				local newvel = (d.target - npc.Position):Resized(5)
				npc.Velocity = mod:Lerp(npc.Velocity, newvel, 0.3)
				if npc.Position:Distance(d.target) < 50 then
					d.target = nil
				end
			end
			if npc.StateFrame > 120 and math.random(10) == 1 and game:GetRoom():CheckLine(npc.Position, target.Position,3,1,false,false) and not mod:isScareOrConfuse(npc) then
				if mod.GetEntityCount(mod.FF.NerveCluster.ID, mod.FF.NerveCluster.Var) < 10 then
					d.state = "attack"
					d.targcurr = target.Position
				end
			end
		elseif d.state == "attack" then
			npc.Velocity = npc.Velocity * 0.8
			d.targcurr = d.targcurr or target.Position
			local vecline = (d.targcurr - npc.Position):Resized(13)
			if vecline.X < 0 then
				sprite.FlipX = true
			else
				sprite.FlipX = false
			end
			if vecline.Y < 0 then
				d.dir = "Up"
			else
				d.dir = "Down"
			end
			if sprite:IsFinished("Shoot" .. d.dir) then
				npc.StateFrame = 0
				d.state = "idle"
			elseif sprite:IsEventTriggered("Shoot") then
				npc:PlaySound(SoundEffect.SOUND_BOSS_LITE_SLOPPY_ROAR, 1, 0, false, 1)
				for i = -30, 30, 30 do
					local fleshlord = mod.spawnent(npc, npc.Position, vecline:Rotated(i), mod.FF.NerveCluster.ID, mod.FF.NerveCluster.Var)
					fleshlord.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
				end
			else
				mod:spritePlay(sprite, "Shoot" .. d.dir)
			end
		end
	end
end

function mod:dogmeatHurt(npc, damage, flag, source)
    if npc:ToNPC().State == 11 then
        return false
    end
    --	if npc.HitPoints - damage <= 10 then
	--		if not (npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) or npc:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE)) then
	--			npc.Velocity = nilvector
	--			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	--			npc.HitPoints = 0
	--			npc:ToNPC().State = 11
	--			return false
	--		end
	--	end
end

function mod.dogmeatDeathEffect(npc)
	local fleshlord = mod.spawnent(npc, npc.Position, nilvector, mod.FF.NerveCluster.ID, mod.FF.NerveCluster.Var)
	fleshlord.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
	for i = 1, math.random(2,3) do
		local chunk = mod.spawnent(npc, npc.Position, RandomVector():Resized(math.random(3,6)), 310, 1)
		chunk.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
	end
end

--Nerve Cluster
function mod:dogmeatProjectileAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = target.Position

	if not d.init then
		npc.SpriteOffset = Vector(0,-15)
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
		d.state = "firing"
		d.init = true
	end

	if d.state == "firing" then
		mod:spritePlay(sprite, "Idle01")
		npc.Velocity = npc.Velocity * 0.95
		if npc.Velocity:Length() < 0.5 or npc:CollidesWithGrid() then
			d.state = "shootout"
		end
	elseif d.state == "shootout" then
		npc.Velocity = npc.Velocity * 0.7
		if sprite:IsFinished("Shootout") then
			d.state = "finished"
		elseif sprite:IsEventTriggered("squadda") then
			npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS,1,2,false,0.7)
		elseif sprite:GetFrame() == 15 then
			npc:SetSize(35, Vector(1,1), 40)
		else
			mod:spritePlay(sprite, "Shootout")
		end
	elseif d.state == "finished" then
		mod:spritePlay(sprite, "Idle02")
		local starving = mod.FindClosestEntity(npc.Position, 75, mod.FF.Starving.ID, mod.FF.Starving.Var)
		if starving then
			npc.Velocity = mod:Lerp(npc.Velocity, ((starving.Position - npc.Position):Resized(0.3)), 0.3)
		else
			npc.Velocity = npc.Velocity * 0.7
		end
		if room:IsClear() then
			npc:Kill()
		end
	end
end
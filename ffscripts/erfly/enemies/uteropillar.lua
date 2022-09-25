local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

mod.uteroPilSpawns = {1,1,1,1,1,1,1,1,1,2,2,2,2,3}

function mod:uteroPillarAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
    local room = game:GetRoom()

    if not d.Init then
		d.state = "idle"
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
        FiendFolio.NPCBlockerGrid:Spawn(room:GetGridIndex(npc.Position), true, false, { Parent = npc })
		d.Init = true
	end

	npc.Velocity = npc.Velocity * 0.1

	if npc.FrameCount % 10 == 0 then
		for _,ClosePickup in ipairs(Isaac.FindInRadius(npc.Position, 1, EntityPartition.PICKUP)) do
			ClosePickup.Velocity = RandomVector()*2
		end
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")

		if mod.CanIComeOutYet() or room:IsClear() then
			d.state = "end"
		end

		if npc.Position:Distance(target.Position) < 80 or d.hurting then
			if mod.GetEntityCount(mod.FF.Organelle.ID, mod.FF.Organelle.Var) < 6 then
				d.state = "shoot"
			else
				d.state = "owie"
			end
		end

	elseif d.state == "shoot" then
		if sprite:IsFinished("Shoot") then
			d.hurting = false
			d.state = "idle"
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_FART, 1, 0, false, 1.3)
			local randspawncount = math.random(#mod.uteroPilSpawns)
			if mod.GetEntityCount(mod.FF.Organelle.ID, mod.FF.Organelle.Var) > 5 then
				randspawncount = 1
			end
			for i = 1, mod.uteroPilSpawns[randspawncount] do
				local organpos = mod:FindRandomFreePos(npc, 120, true)
				local vec = (organpos - npc.Position):Resized(8)
				local organlet = Isaac.Spawn(mod.FF.Organelle.ID, mod.FF.Organelle.Var, 0, npc.Position, vec, npc):ToNPC()
				organlet.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
				organlet.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				organlet:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				local od = organlet:GetData()
				od.flying = organpos
				od.speed = -10
				organlet.SpriteOffset = Vector(0, -50)
				organlet:Update()
			end
		else
			mod:spritePlay(sprite, "Shoot")
		end
	elseif d.state == "owie" then
		if sprite:IsFinished("ShootNo") then
			d.hurting = false
			d.state = "idle"
		else
			mod:spritePlay(sprite, "ShootNo")
		end
	elseif d.state == "end" then
		mod:spritePlay(sprite, "ShutDown")
	end
end

function mod:uteroPillarHurt(npc, damage, flag, source)
	local d = npc:GetData()
	d.hurting = true
	return false
end

function mod:organelleAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder
	local r = npc:GetDropRNG()

	if not d.init then
		local rand = math.random(4)
		if rand > 1 then
			sprite:ReplaceSpritesheet(0, "gfx/enemies/wombpillar/organelle" .. rand .. ".png")
            sprite:LoadGraphics()
		end
		d.init = true
	end

	--[[if npc.FrameCount % 3 == 1 then
		local blood = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc)
		blood.SpriteScale = Vector(0.6,0.6)
		blood:Update()
	end]]

	if d.flying then
		if d.landing then
			if sprite:IsFinished("Land") then
				d.flying = false
			else
				mod:spritePlay(sprite, "Land")
			end
		else
			mod:spritePlay(sprite, "Fly")
			npc.Position = npc.Position + (d.flying - npc.Position) * 0.1
			npc.Velocity = (d.flying - npc.Position) * 0.1
			d.speed = d.speed + 2
			if d.speed >= 10 then
				d.speed = 10
			end
			npc.SpriteOffset = Vector(0, npc.SpriteOffset.Y + d.speed)
			if npc.SpriteOffset.Y > 0 then
				npc.SpriteOffset = Vector(0,0)
				d.landing = true
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			end
		end
	else
		--[[if npc.FrameCount % (5 + #mod.creepSpawnerCount) == 1 then
			local creep = Isaac.Spawn(1000, 22, 0, npc.Position, nilvector, npc):ToEffect();
			creep.Scale = 0.5
			creep:SetTimeout(30)
			creep:Update()
		end]]

		mod:spritePlay(sprite, "Walk")
		if sprite:IsEventTriggered("Scootch") then
			npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,0.2,0,false,1.4)
			local targetpos
			if npc:HasEntityFlags(EntityFlag.FLAG_CHARM) or npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
				targetpos = npc:GetPlayerTarget().Position
			elseif npc.Parent then
				if path:HasPathToPos(npc.Parent.Position, false) then
					targetpos = npc.Parent.Position
				else
					targetpos = mod:FindRandomValidPathPosition(npc)
				end
			else
				targetpos = mod:FindRandomValidPathPosition(npc)
			end

			if game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) or mod:isScare(npc) then
				npc.Velocity = mod:runIfFear(npc, (targetpos - npc.Position):Resized(math.random(4,6)), math.random(4,6))
			else
				path:FindGridPath(targetpos, 5, 900, false)
			end
		end
		npc.Velocity = npc.Velocity * 0.9
	end

	if npc:IsDead() then
		for i = 60, 360, 60 do
			local rand = r:RandomFloat()
			local p = Isaac.Spawn(9, 0, 0, npc.Position, Vector(0,4):Rotated(i-40+rand*80), nil):ToProjectile()
			p.FallingSpeed = -35 + math.random(10);
			p.FallingAccel = 2
			--p:GetData().projType = "bloodafter"
		end
	end
end

function mod:organelleColl(npc1, npc2)
	if npc2.Type == 1 then
		npc1:Kill()
	end
end
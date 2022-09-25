local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:tombitAI(npc)
	local sprite = npc:GetSprite();
	local d = npc:GetData();
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()
	local path = npc.Pathfinder
    local room = game:GetRoom()

	if not d.init then
		npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET + EntityFlag.FLAG_NO_BLOOD_SPLASH)
		d.state = "idle"
		d.init = true
		d.spawns = 0
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if room:IsClear() then
		npc:Kill()
	end

	if d.state == "idle" then

		d.newhome = d.newhome or mod:FindRandomValidPathPosition(npc, nil, false, nil, nil, true)
		local pdist = target.Position:Distance(npc.Position)
		if pdist < 100 or mod:isScare(npc) then
			npc.Velocity = (npc.Position - target.Position):Resized(5 - pdist/50)
			d.newhome = nil
		elseif npc.Position:Distance(d.newhome) < 5 or npc.Velocity:Length() < 1 then
			d.newhome = mod:FindRandomValidPathPosition(npc, nil, false, nil, nil, true)
			path:FindGridPath(d.newhome, 0.6, 900, true)
		else
			path:FindGridPath(d.newhome, 0.6, 900, true)
		end


		if npc.Velocity:Length() > 0 then
			if math.abs(npc.Velocity.Y) > math.abs(npc.Velocity.X) then
				if npc.Velocity.Y > 0 then
					d.dir = "Down"
				else
					d.dir = "Up"
				end
			else
				d.dir = "Hori"
				if npc.Velocity.X > 0 then
					sprite.FlipX = false
				else
					sprite.FlipX = true
				end

			end
			mod:spritePlay(sprite, "Walk" .. d.dir)
		end

		if (not mod:isScareOrConfuse(npc)) and npc.StateFrame > 50 + (d.spawns * 5) and math.random(25) == 1 and mod.GetEntityCount(mod.FF.Gravin.ID, mod.FF.Gravin.Var) < 20 then
			local closeboy = mod.FindClosestEntity(npc.Position + npc.Velocity:Resized(50), 50, mod.FF.Gravin.ID, mod.FF.Gravin.Var)
			if not closeboy then
				d.state = "trip"
				d.vec = mod:SnapVector(npc.Velocity, 90)
				d.spawns = d.spawns + 1
			end
		end
	elseif d.state == "trip" then
		npc.Velocity = npc.Velocity * 0.9
		if sprite:IsFinished("Slam" .. d.dir) then
			d.state = "recover"
			d.slowie = false
		elseif sprite:IsEventTriggered("Slam") then
			npc:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND,0.7,2,false,math.random(210,235)/100)
			npc.Velocity = npc.Velocity * 0.7
		elseif sprite:IsEventTriggered("Jump") then
			npc:PlaySound(SoundEffect.SOUND_BOSS_LITE_ROAR,1,0,false,math.random(180,200)/100)
		else
			mod:spritePlay(sprite, "Slam" .. d.dir)
		end
	elseif d.state == "recover" then
		if sprite:IsFinished("Recover" .. d.dir) then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Spawn") then
			npc.Velocity = d.vec * -1
			local gravin = Isaac.Spawn(mod.FF.Gravin.ID, mod.FF.Gravin.Var, 0, npc.Position, nilvector, npc)
			sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 0.7, 0, false, 1)
			gravin:Update()
		elseif sprite:GetFrame() == 21 then
			d.slowie = true
		else
			mod:spritePlay(sprite, "Recover" .. d.dir)
		end
		if d.slowie then
			npc.Velocity = npc.Velocity * 0.9
		end
	end
end

function mod:gravinAI(npc)
	local sprite = npc:GetSprite();
	local d = npc:GetData();

	if not d.init then
		sprite:Play("Appear"..mod:RandomInt(0,5,npc:GetDropRNG()))
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK + EntityFlag.FLAG_NO_KNOCKBACK + EntityFlag.FLAG_NO_BLOOD_SPLASH)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		d.init = true
	end
    local room = game:GetRoom()
	--room:SetGridPath(room:GetClampedGridIndex(npc.Position), 900)
	npc.Velocity = nilvector

	if npc:IsDead() then
		for i = 90, 360, 90 do
			local params = ProjectileParams()
			params.Variant = 9
			params.Scale = 0.9
			params.HeightModifier = 20
			npc:FireProjectiles(npc.Position, Vector(4,0):Rotated(i), 0, params)
			--[[local coal = Isaac.Spawn(9, 3, 0, npc.Position, Vector(0,5):Rotated(i), npc):ToProjectile()
			local coald = coal:GetData()
			coald.projType = "coalButActuallyRock"
			local coals = coal:GetSprite()
			coals:Load("gfx/projectiles/sooty_tear_rock.anm2",true)
			coals:Play("spin",true)
			coal.SpriteScale = coal.SpriteScale * 0.8
			--coal.FallingSpeed = -15
			coal.FallingAccel = 0.2
			coal:Update()]]
		end
	end
end
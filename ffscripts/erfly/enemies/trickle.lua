local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:trickleAI(npc, subt)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder
    local room = game:GetRoom()

	if not d.init then
		if subt == 1 then
			d.state = "walk"
			d.landed = true
		else
			d.state = "fly"
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
		end
		npc.SpriteOffset = Vector(0, -3)
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "fly" then
		mod:spritePlay(sprite, "Fly")
		local targvel = mod:diagonalMove(npc, 6, 1)
		if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE) then
			targvel = targvel / 2
		end
		npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.1)
		if npc.HitPoints < (npc.MaxHitPoints - 10) and room:GetGridCollisionAtPos(npc.Position) == GridCollisionClass.COLLISION_NONE then
			d.state = "transform"
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
		end
	elseif d.state == "transform" then
		local targvel = mod:diagonalMove(npc, 3, 1)
		npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.1)
		if sprite:IsFinished("Transform") then
			d.state = "walk"
		elseif sprite:IsEventTriggered("Fart") then
			d.falling = true
			game:ButterBeanFart(npc.Position, 120, npc, false)
			local fart = Isaac.Spawn(1000, 34, 1, npc.Position, nilvector, npc):ToEffect()
			npc:PlaySound(SoundEffect.SOUND_FART,1,0,false, 1.2)
			local players = Isaac.FindInRadius(npc.Position, 80, EntityPartition.PLAYER)
			if #players > 0 then
				player:TakeDamage(1, 0, EntityRef(npc), 0)
			end
		elseif sprite:IsEventTriggered("Land") then
			d.landed = true
			npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS,1,2,false,1)
		else
			mod:spritePlay(sprite, "Transform")
		end
		if d.landed then
			npc.Velocity = npc.Velocity * 0.2
		elseif d.falling then
			npc.Velocity = npc.Velocity * 0.9
		else
			npc.Velocity = npc.Velocity * 0.99
		end
	elseif d.state == "walk" then
		if npc.Velocity:Length() > 0.1 then
			mod:spritePlay(sprite, "Walk")
			if npc.Velocity.X < 0 then
				sprite.FlipX = true
			else
				sprite.FlipX = false
			end
		else
			sprite:SetFrame("Transform", 29)
		end

		if d.moving then
			d.targmove = d.targmove or mod:FindRandomValidPathPosition(npc)
			if room:CheckLine(npc.Position,d.targmove,0,1,false,false) then
				local targetvel = mod:reverseIfFear(npc, (d.targmove - npc.Position):Resized(12))
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.3)
			else
				path:FindGridPath(d.targmove, 1.5, 900, true)
			end
			if npc.StateFrame > d.moving or npc.Position:Distance(d.targmove) < 10 then
				d.moving = false
				npc.StateFrame = 0
			end
		else
			npc.Velocity = npc.Velocity * 0.2
			if npc.StateFrame > 5 then
				if math.random(4) == 1 and not mod:isScareOrConfuse(npc) then
					d.state = "jump"
				else
					d.moving = math.random(7, 19)
					npc.StateFrame = 0
					if room:CheckLine(npc.Position,target.Position,0,1,false,false) and not mod:isConfuse(npc) then
						d.targmove = target.Position
					else
						d.targmove = mod:FindRandomValidPathPosition(npc)
					end
				end
			end
		end
	elseif d.state == "jump" then
		npc.Velocity = npc.Velocity * 0.2
		if sprite:IsFinished("Jump") then
			d.state = "walk"
		elseif sprite:IsEventTriggered("Jump") then
			npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,1,2,false,1)
		elseif sprite:IsEventTriggered("Land") then
			npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS,1,2,false,1)
			for i = 1, 8 do
				local ang = (360 / 8) * i
				npc:FireProjectiles(npc.Position, Vector(0,11):Rotated(-22.5+ang), 0, ProjectileParams())
			end
		else
			mod:spritePlay(sprite, "Jump")
		end
	end

	if npc:IsDead() then
		for i = 1, 16 do
			local ang = (360 / 12) * i
			npc:FireProjectiles(npc.Position, Vector(0,8):Rotated(ang), 0, ProjectileParams())
		end

	end
end

function mod:trickleHurt(npc, damage, flag, source)
    if (npc.SubType == mod.FF.TrickleFly.Sub and not npc:GetData().landed) then
        if flag & DamageFlag.DAMAGE_SPIKES ~= 0 then
            return false
        end
    end
end
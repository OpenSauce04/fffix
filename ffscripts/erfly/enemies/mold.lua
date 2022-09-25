local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:moldAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not d.init then
		d.state = "idle"
		d.homePos = npc.Position
		d.invincible = true
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        local room = game:GetRoom()
		if room:GetGridCollisionAtPos(npc.Position + Vector(0, -50)) ~= GridCollisionClass.COLLISION_NONE then
			d.spriteDir = "Ceiling"
			npc.SpriteOffset = Vector(0, -12)
			d.fireoffset = Vector(0, 20)
		elseif room:GetGridCollisionAtPos(npc.Position + Vector(0, 50)) ~= GridCollisionClass.COLLISION_NONE then
			d.spriteDir = "Floor"
			npc.SpriteOffset = Vector(0, 5)
			d.fireoffset = Vector(0, 15)
		elseif room:GetGridCollisionAtPos(npc.Position + Vector(50, 0)) ~= GridCollisionClass.COLLISION_NONE or room:GetGridCollisionAtPos(npc.Position + Vector(-50, 0)) ~= GridCollisionClass.COLLISION_NONE then
			d.spriteDir = "Wall"
			if room:GetGridCollisionAtPos(npc.Position + Vector(-50, 0)) ~= GridCollisionClass.COLLISION_NONE then
				sprite.FlipX = true
			end
			npc.SpriteOffset = Vector(12, 0)
			d.fireoffset = Vector(0, 20)
		else
			d.spriteDir = "Floor"
			npc.SpriteOffset = Vector(0, 5)
			d.fireoffset = Vector(0, 15)
		end
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.invincible then
		if not npc:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
			npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
		end
	else
		if npc:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
		end
	end

	if d.homePos then
		npc.Position = d.homePos
		npc.Velocity = nilvector
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle_" .. d.spriteDir)
		if (not mod:isScareOrConfuse(npc)) and npc.StateFrame > 30 and math.random(10) == 1 and target.Position:Distance(npc.Position) < 200 and game:GetRoom():CheckLine(target.Position,npc.Position,3,900,false,false) then
			d.state = "shoot"
		end
	elseif d.state == "bombed" then
		if sprite:IsFinished("Bombed_" .. d.spriteDir) then
			d.state = "idle"
		else
			mod:spritePlay(sprite, "Bombed_" .. d.spriteDir)
		end
	elseif d.state == "shoot" then
		if sprite:IsFinished("Shoot_" .. d.spriteDir) then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Open") then
			d.invincible = false
			npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH,1,2,false,1)
		elseif sprite:IsEventTriggered("Close") then
			d.invincible = true
		elseif sprite:IsEventTriggered("Shoot") then
			d.shooting = 0
			d.shootvec = (target.Position - (npc.Position + d.fireoffset)):Resized(10)

			local poof = Isaac.Spawn(1000, 16, 0, npc.Position, nilvector, npc):ToEffect()
			if sprite.FlipX then
				poof:GetSprite().FlipX = true
			end
			poof.RenderZOffset = 100
			poof.SpriteOffset = d.fireoffset + Vector(0, -20)
			poof.SpriteScale = Vector(0.4,0.5)
			poof:FollowParent(npc)
			poof.Color = Color(1,1,1,0.6,0,0,0)
			poof:Update()
		else
			mod:spritePlay(sprite, "Shoot_" .. d.spriteDir)
		end
	end

	if d.shooting then
		d.shooting = d.shooting + 1
		if d.shooting % 2 == 1 then
			npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 0.8, 0, false, math.random(110,120)/100)
			local fireoffset = d.fireoffset or nilvector
			npc:FireProjectiles(npc.Position + fireoffset, d.shootvec, 0, ProjectileParams())
		end
		if d.shooting > 6 then
			d.shooting = nil
		end
	end
end

function mod:moldHurt(npc, damage, flag, source)
    local d = npc:GetData()
    if d.invincible then
        if flag == flag | DamageFlag.DAMAGE_EXPLOSION then
            d.state = "bombed"
            npc:ToNPC().StateFrame = 0
        end
        return false
    end
end
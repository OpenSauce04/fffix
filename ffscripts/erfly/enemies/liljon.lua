local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:lilJonAI(npc)
	local d = npc:GetData()
	local sprite = npc:GetSprite();
	local subt = npc.SubType
    local room = game:GetRoom()

	if not d.init then
		npc.Velocity = Vector(1, 1):Resized(7)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
		if subt == 1 then
			npc:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
		end
		--npc.SplatColor = Color(0.15, 0, 0, 1, 25 / 255, 25 / 255, 25 / 255)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
		npc.RenderZOffset = 150
		d.init = true
	end

	if subt == 1 then
		if not mod.resetelitejon then
			if mod.elitejontopness then
				npc.Position = room:GetCenterPos() + Vector(0, -120)
				mod.elitejontopness = false
			else
				npc.Position = room:GetCenterPos()
			end
			mod.resetelitejon = true
		end
		if room:GetType() == RoomType.ROOM_DUNGEON then
			npc.Position = room:GetCenterPos()
		end
	end

	if room:IsClear() and npc.State ~= 11 and subt ~= 1 then
		npc.State = 11
		npc:PlaySound(SoundEffect.SOUND_DEVILROOM_DEAL,1,1,false,0.6)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	end

	if npc.State == 11 then
		npc.Velocity = nilvector
		if sprite:IsFinished("Death") then
			npc:Kill()
			Game():ShakeScreen(15)
			mod:PlaySound(SoundEffect.SOUND_DEATH_BURST_BONE, npc, 0.6)
		else
			mod:spritePlay(sprite, "Death")
		end
	else
		if subt == 1 then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		else
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		end
		mod:spritePlay(sprite, "Idle")
		if subt == 1 then
			--[[if npc.FrameCount % 3 == 0 then
				local extravel = (npc.Velocity * -1):Rotated(-20 + math.random(40))
				local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position, nilvector, npc)
				smoke.SpriteScale = Vector(3,3)
				smoke.SpriteOffset = Vector(0, -5)
				smoke:Update()
			end]]
        end

        if npc:CollidesWithGrid() then
			--d.targetVelocity = mod.bounceOffWall(npc.Position, d.targetVelocity)
			local farbounce = true
			local players = Isaac.FindInRadius(npc.Position, 120, EntityPartition.PLAYER)
			if #players > 0 then
				farbounce = false
			end
			if farbounce then
				Game():ShakeScreen(5)
				npc:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND,0.2,2,false,2.2)
			else
				Game():ShakeScreen(15)
				npc:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND,0.6,2,false,1.7)
			end
		end
		--npc.Velocity = (d.targetVelocity * 0.3) + (npc.Velocity * 0.6)
		if room:GetType() == RoomType.ROOM_DUNGEON then
			npc.Velocity = nilvector
		else
			mod:diagonalMove(npc, 3)
		end
		npc.RenderZOffset = 2500
	end

	--[[if npc:IsDead() and subt == 1 then
		Isaac.Spawn(960, 190, 1, npc.Position, nilvector, nil)
	end]]
end

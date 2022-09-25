local mod = FiendFolio

function mod:connipshitAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not data.init then
		data.shotCount = 0
		data.state = "GAS"
		data.initPos = npc.Position
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
		data.init = true
	end
	
	if not data.isSpecturned then
		if not data.initPos then
			data.initPos = npc.Position
		end
		npc.Velocity = data.initPos-npc.Position
	else
		data.initPos = nil
	end

	if data.state == "Idle" then
		mod:spritePlay(sprite, "Idle")
		if data.frameCount > 0 then
			data.frameCount = data.frameCount-1
		elseif mod.GetEntityCount(1000, 141, 1) < 3 or data.shotCount == 6 and not mod:isScareOrConfuse(npc)then
			data.state = "GAS"
		elseif not mod:isScareOrConfuse(npc) then
			data.shotCount = data.shotCount+1
			sprite:Play("blergh")
			data.state = "hurl"
		end
	elseif data.state == "hurl" then
		if sprite:IsEventTriggered("vomit") then
			npc:PlaySound(SoundEffect.SOUND_CHILD_ANGRY_ROAR, 1, 0, false, 1)
			local cDirection = (target.Position - npc.Position)*0.025
			local projectile = Isaac.Spawn(9, 0, 0, npc.Position, cDirection, npc):ToProjectile()
			projectile.FallingSpeed = -40
			projectile.Color = mod.ColorIpecacDross
			projectile.FallingAccel = 1
			projectile.ProjectileFlags = projectile.ProjectileFlags | ProjectileFlags.EXPLODE
			if mod:isFriend(npc) then
				projectile.ProjectileFlags = projectile.ProjectileFlags | ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.HIT_ENEMIES
			elseif mod:isCharm(npc) then
				projectile.ProjectileFlags = projectile.ProjectileFlags | ProjectileFlags.CANT_HIT_PLAYER
			end
		elseif sprite:IsFinished("blergh") then
			data.state = "Idle"
			data.frameCount = 50
		end
	elseif data.state == "GAS" then
		mod:spritePlay(sprite, "gasgasgasgasgasgas")
		if sprite:IsEventTriggered("fart") then
			npc:PlaySound(SoundEffect.SOUND_FART, 1, 0, false, 1)
			for i=0,3 do
				local fartVec = (mod:FindRandomFreePos(npc, 120)-npc.Position)*0.15
				Isaac.Spawn(1000, 141, 1, npc.Position, fartVec, npc)
				--local fartPos = mod:FindRandomFreePos(npc, 120)
				--Isaac.Spawn(1000, 141, 1, fartPos, nilvector, npc)
			end
		elseif sprite:IsFinished("gasgasgasgasgasgas") then
			data.shotCount = 0
			data.state = "Idle"
			data.frameCount = 65
		end
	end
end

function mod:connipshitHurt(npc, damage, flag, source)
	if flag & DamageFlag.DAMAGE_EXPLOSION ~= 0 and source.Entity.SpawnerEntity and source.Entity.SpawnerEntity.Type == 114 and source.Entity.SpawnerEntity.Variant == 2 then
		npc:TakeDamage(damage*0.2, flag & ~DamageFlag.DAMAGE_EXPLOSION, source, 0)
		return false
	end
end
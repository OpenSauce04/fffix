local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:quackAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder

	if not d.init then
		d.state = "idle"
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		if npc.StateFrame > 5 or math.random(3) == 1 then
			local count = math.min(mod.GetEntityCount(mod.FF.QuackMine.ID, mod.FF.QuackMine.Var, 0), 3)
			if count > 0 and math.random(4 - count) == 1 and mod.GetEntityCount(mod.FF.Quack.ID, mod.FF.Quack.Var, 1) < 1 then
				d.state = "detonate"
				npc.SubType = 1
			else
				d.state = "attack"
			end
		end
	elseif d.state == "hop" then
		if sprite:IsFinished("Hop") then
			d.state = "idle"
		elseif sprite:IsEventTriggered("Hop") then
			npc:PlaySound(SoundEffect.SOUND_HEARTIN, 0.5, 0, false, math.random(65,75)/100)
			d.hopping = true
			local targ = mod:FindRandomVisiblePosition(npc, npc.Position + RandomVector(), 2, 200)
			npc.Velocity = (targ - npc.Position):Resized(5)
		elseif sprite:IsEventTriggered("Land") then
			npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS,0.5,0,false,math.random(95,105)/100)
			d.hopping = nil
		else
			mod:spritePlay(sprite, "Hop")
		end
	elseif d.state == "attack" then
		if sprite:IsFinished("Attack01") then
			d.state = "hop"
		elseif sprite:IsEventTriggered("Shoot") then
			sfx:Play(SoundEffect.SOUND_SUMMONSOUND,0.3,1,false,1)
			local bomb = Isaac.Spawn(mod.FF.QuackMine.ID,mod.FF.QuackMine.Var,0,npc.Position + Vector(0, 10),nilvector,npc)
			bomb.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		else
			mod:spritePlay(sprite, "Attack01")
		end
	elseif d.state == "detonate" then
		if sprite:IsFinished("Detonate") then
			d.state = "hop"
		elseif sprite:IsEventTriggered("Detonate") then
			npc:PlaySound(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ, 0.5, 0, false, 1.25)
			for _, entity in ipairs(Isaac.FindByType(mod.FF.QuackMine.ID, mod.FF.QuackMine.Var, 0, EntityPartition.ENEMY, true)) do
				entity.SubType = 1
				npc.SubType = 0
			end
		elseif sprite:GetFrame() == 10 and sprite:IsPlaying("Detonate") then
			sfx:Play(SoundEffect.SOUND_SHELLGAME,1,0,false,0.7)
		elseif sprite:GetFrame() == 21 and sprite:IsPlaying("Detonate") then
			npc:PlaySound(mod.Sounds.FlashMuffledRoar, 1, 0, false, math.random(180,190)/100)
		else
			mod:spritePlay(sprite, "Detonate")
		end
	elseif d.state == "dying" then
		if sprite:IsFinished("Death") then
			--If there are no other Quacks, detonate the rest of the Mines
			if not mod:AreThereAnyOthers(npc) then
				for _, entity in ipairs(Isaac.FindByType(mod.FF.QuackMine.ID, mod.FF.QuackMine.Var, 0, EntityPartition.ENEMY, true)) do
					entity = entity:ToNPC()
					for i = 45, 360, 45 do
						entity:FireProjectiles(entity.Position, Vector(10,0):Rotated(i), 0, ProjectileParams())
					end
					game:BombExplosionEffects(entity.Position, 2, 0, mod.ColorNormal, entity, 1, false, true)
					entity:BloodExplode()
					entity:Remove()
				end
			end
			npc:Kill()
		end
	end

	if not d.hopping then
		npc.Velocity = npc.Velocity * 0.8
	end

end

function mod:quackHurt(npc, damage, flag, source)
	if mod:HasDamageFlag(DamageFlag.DAMAGE_EXPLOSION, flag) and not mod:IsPlayerDamage(source) then
		return false
	end
end

function FiendFolio.QuackDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
        deathAnim:GetData().init = true
		deathAnim:GetData().state = "dying"
	end
	FiendFolio.genericCustomDeathAnim(npc, "Death", true, onCustomDeath)
end

function mod:quackMineAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder

	if not d.init then
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
		d.init = true
	end

	npc.Velocity = nilvector

	if npc:IsDead() then
		for i = 90, 360, 90 do
			npc:FireProjectiles(npc.Position, Vector(10,0):Rotated(i), 0, ProjectileParams())
		end
		local bomb = Isaac.Spawn(4, 0, 0, npc.Position, nilvector, npc):ToBomb()
		bomb.ExplosionDamage = 10
		bomb:Update()
	end

	if npc.SubType == 1 then
		if sprite:IsFinished("Pulse") then
			for i = 45, 360, 45 do
				npc:FireProjectiles(npc.Position, Vector(10,0):Rotated(i), 0, ProjectileParams())
			end
			game:BombExplosionEffects(npc.Position, 2, 0, mod.ColorNormal, npc, 1, false, true)
			npc:BloodExplode()
			npc:Remove()
		else
			mod:spritePlay(sprite, "Pulse")
		end
	end
end
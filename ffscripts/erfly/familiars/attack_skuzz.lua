local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local d = fam:GetData()
	local sprite = fam:GetSprite()
	if fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND) then
		if not fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
			fam.SpriteScale = Vector(1.25,1.25)
		end
		if not d.HiveMinded then
			fam:SetSize(18, Vector(1.25,1.25), 12)
			d.HiveMinded = true
		end
	elseif fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
		fam.SpriteScale = Vector(0.8,0.8)
		if d.HiveMinded then
			fam:SetSize(13, Vector(1,1), 12)
			d.HiveMinded = nil
		end
	else
		fam.SpriteScale = Vector(1,1)
		if d.HiveMinded then
			fam:SetSize(13, Vector(1,1), 12)
			d.HiveMinded = nil
		end
	end
	if not d.init then
		d.init = true
		sprite.Offset = Vector(0, 0)
		d.jumpytimer = 0
		d.state = "idle"
		d.stateframe = 0
		fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
		fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
	end
	if d.state == "idle" then
		if not sprite:IsPlaying("land") then
			mod:spritePlay(sprite, "idle")
			fam.Velocity = mod:Lerp(fam.Velocity, Vector(0,0), 0.75)
		elseif sprite:IsFinished("land") then
			mod:spritePlay(sprite, "idle")
		else
			fam.Velocity = mod:Lerp(fam.Velocity, Vector(0,0), 0.4)
		end
		--just in case
		if not d.jumpytimer then
			d.jumpytimer = 30
		end
		if d.jumpytimer <= 0 then
			d.state = "hop"
			--sfx:Play(SoundEffect.SOUND_FETUS_LAND,0.6,1,false,2.7)
			mod:spritePlay(sprite, "hopstart")
			d.stateframe = 0;
			local targetpos = mod:chooserandomlocationforskuzz(fam, 150, 50, true, true)
			local lengthto = targetpos - fam.Position
			fam.Velocity = Vector(lengthto.X / 15 , lengthto.Y / 15) * 0.90
			fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			fam.GridCollisionClass = GridCollisionClass.COLLISION_NONE
		else
			d.jumpytimer = d.jumpytimer - 1
		end
	elseif d.state == "hop" then
		if not sprite:IsPlaying("hopstart") then
			mod:spritePlay(sprite, "hop")
		elseif sprite:IsFinished("hopstart") then
			mod:spritePlay(sprite, "hop")
		end
		sprite.Offset = Vector(0, -2 * (-0.025 * ((d.stateframe - 30)^2) + 29.5))
		if sprite.Offset.Y > 0 then
			sprite.Offset = Vector(0,0)
			d.state = "idle"
			mod:spritePlay(sprite, "land")
			--sfx:Play(SoundEffect.SOUND_FETUS_LAND,0.6,1,false,1.7)
			d.jumpytimer = math.random(10, 30)
			fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
			fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
		else
		d.stateframe = d.stateframe + 4
		end
	else
		d.state = "idle"
	end
end, FamiliarVariant.ATTACK_SKUZZ)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, fam, collider)
	if collider:IsEnemy() and collider:IsVulnerableEnemy() and collider:IsActiveEnemy() and not (mod:isFriend(collider) or collider:HasEntityFlags(EntityFlag.FLAG_NO_TARGET)) then
		local dmgMulti = 3
		if fam:GetData().HiveMinded then
			dmgMulti = dmgMulti * 2
		end
		--Meltdown
		if fam.SubType == 1 then
			collider:AddBurn(EntityRef(fam.Player), 150, fam.Player.Damage)
			--[[local size = room:GetGridSize()
			for i=0, size do
				local gridpos = room:GetGridPosition(i)
				Isaac.Explode(gridpos, fam, 10)
			end]]
		--Deluge
		elseif fam.SubType == 2 then
			--[[
			local creep = Isaac.Spawn(1000, 46, 0, collider.Position, nilvector, fam.Player):ToEffect();
			creep.Color = Color(0,0,0,1,100 / 255,100 / 255,120 / 255)
			creep:SetTimeout(60)
			creep:Update()]]
			local targ = mod.FindClosestEnemy(fam.Position, 800, true, nil, collider.InitSeed)
			local vec = Vector(0, 9)
			if targ then
				vec = (targ.Position - fam.Position):Resized(9)
			end
			for i = 45, 360, 45 do
				local tear = Isaac.Spawn(2, 0, 0, fam.Position, vec:Rotated(i), fam):ToTear()
				tear.Scale = 0.9
				tear.CollisionDamage = fam.Player.Damage
				tear.FallingAcceleration = -0.05
			end
		--Pollution
		elseif fam.SubType == 3 then
			local creep = Isaac.Spawn(1000, 45, 0, collider.Position, nilvector, fam.Player):ToEffect()
			creep:SetTimeout(350)
			creep:Update()
		--Propaganda
		elseif fam.SubType == 4 then
			collider:AddCharmed(EntityRef(fam), 150)
		end
		collider:TakeDamage(fam.Player.Damage * dmgMulti, 0, EntityRef(fam.Player), 0)
		if fam.SubType ~= 100 then
			fam:Kill()
		end
	end
end, FamiliarVariant.ATTACK_SKUZZ)
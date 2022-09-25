local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local d = fam:GetData()
	local sprite = fam:GetSprite()
	local room = Game():GetRoom()
	local isSuperpositioned = mod:isSuperpositionedPlayer(fam.Player)
	local isSirenCharmed, charmer = mod:isSirenCharmed(fam)

	--fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
	fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
	if not d.init then
		d.face = d.face or math.random(3)
		--print("yea")
		if fam.FrameCount > 5 then
			fam.Position = fam.Player.Position + (room:GetCenterPos() - fam.Player.Position):Resized(15):Rotated(-25 + math.random(50))
		end
		fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		d.init = true
		fam.Visible = true
		
		local roomseed = tostring(room:GetSpawnSeed())
		local roomData = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'rockRoomCount', roomseed, {})
		if roomData.count and roomData.count > 0 then
			mod.petRocksKilled = mod.petRocksKilled or 0
			if mod.petRocksKilled < roomData.count then
				mod.petRocksKilled = mod.petRocksKilled + 1
				fam.Visible = false
				fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				fam:ClearEntityFlags(EntityFlag.FLAG_APPEAR | EntityFlag.FLAG_PERSISTENT)
			end
		end
	else
		d.StateFrame = d.StateFrame or 0
		d.StateFrame = d.StateFrame + 1
	end
	
	if not fam.Visible then
		fam.Velocity = nilvector
		return
	end

	sprite:SetFrame("Rock", d.face - 1)
	fam.Size = 15
	local spritePlus = 0
	local vecDown = 0
	if fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
		fam.Size = fam.Size + 10
		vecDown = vecDown + 5
	end
	if Sewn_API then
		if Sewn_API:IsUltra(d) then
			fam.Size = fam.Size + 20
			spritePlus = 1
			vecDown = vecDown + 10
		elseif Sewn_API:IsSuper(d) then
			fam.Size = fam.Size + 10
			spritePlus = 0.5
			vecDown = vecDown + 5
		end
		Sewn_API:AddCrownOffset(fam, Vector(0, -10 -fam.Size))
	end
	fam.SpriteScale = Vector(1 + spritePlus,1 + spritePlus)
	fam.SpriteOffset = Vector(0, 0 + vecDown)
	fam.DepthOffset = 0 + (vecDown)

	for _, proj in pairs(Isaac.FindByType(9, -1, -1, false, false)) do
		if proj.Position:Distance(fam.Position) - proj.Size - fam.Size <= 5 then
			fam.Velocity = mod:Lerp(fam.Velocity, proj.Velocity, 0.1)
			proj:Die()
		end
	end

	--local testPos = fam.Position + fam.Velocity:Resized(15)
	local testPos = fam.Position
	if room:GetGridCollisionAtPos(testPos) == GridCollisionClass.COLLISION_PIT then
		local grident = room:GetGridEntityFromPos(testPos):ToPit()
		grident:MakeBridge(grident)
		if isSirenCharmed then 
			grident.State = 2 
			if charmer then charmer:Kill() end
		end
		grident:UpdateCollision()
		if grident.CollisionClass ~= GridCollisionClass.COLLISION_PIT then
			--Cool smoke :)
			for i = 30, 360, 30 do
				local coolVec = (Vector(math.random(5,30)/10, 0)):Rotated(i - 20 + math.random(40))
				local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, fam.Position + Vector(0, -10) + coolVec * 5 , coolVec, fam):ToEffect()
				smoke.Color = Color(1,1,1,1,0.3,0.3,0.3)
				smoke:Update()
			end
			--Sets it so the rocks shouldn't spawn again
			local roomseed = tostring(room:GetSpawnSeed())
			local roomData = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'rockRoomCount', roomseed, {})
			roomData.count = roomData.count or 0
			roomData.count = roomData.count + 1
			--print(roomData.count)
			--KILL IT
			mod.petRocksKilled = mod.petRocksKilled or 0
			mod.petRocksKilled = mod.petRocksKilled + 1
			sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.7, 0, false, math.random(110,130)/100)
			
			fam.Visible = false
			fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			fam:ClearEntityFlags(EntityFlag.FLAG_PERSISTENT)
		end
	end

	fam.Velocity = fam.Velocity * 0.8
end, FamiliarVariant.PETROCK)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, familiar, collider)
	if collider.Type == EntityType.ENTITY_SIREN_HELPER and 
	   collider.Target and 
	   collider.Target.Index == familiar.Index and 
	   collider.Target.InitSeed == familiar.InitSeed 
	then
		return true
	end
	
	local targvec = (familiar.Position - collider.Position)
	targvec = targvec:Resized(targvec:Length() - familiar.Size - collider.Size)
	familiar.Velocity = mod:Lerp(familiar.Velocity, targvec * -1, 0.1)
	collider.Velocity = mod:Lerp(collider.Velocity, targvec * 0.05, 0.1)
end, FamiliarVariant.PETROCK)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)
	familiar.Visible = false
end, FamiliarVariant.PETROCK)
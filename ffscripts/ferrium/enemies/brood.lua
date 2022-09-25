local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:broodAI(npc)
	local data = npc:GetData()
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local rand = npc:GetDropRNG()
	
	if not data.init then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		data.state = "Appear"
		Isaac.Spawn(1000, 15, 0, npc.Position, Vector.Zero, npc)
		data.eggState = npc.SubType
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end
	
	if data.state == "Idle" then
		if npc.StateFrame % 50 == 0 then
			npc:PlaySound(mod.Sounds.BeeBuzzDown, 0.15, 0, false, math.random(120,160)/100)
			data.flightDir = (targetpos-npc.Position):Resized(5)+(targetpos-npc.Position)*0.025
			npc.StateFrame = -5+rand:RandomInt(10)
		end
		local dLength = data.flightDir:Length()
		if dLength > 0.1 then
			data.flightDir = data.flightDir*0.96
		end
		if mod:isScare(npc) then
			npc.Velocity = mod:Lerp(npc.Velocity, -data.flightDir*1.5, 0.15)
		else
			npc.Velocity = mod:Lerp(npc.Velocity, data.flightDir, 0.15)
		end
		
		if npc.Position:Distance(target.Position) < 100 and not mod:isScareOrConfuse(npc) and data.eggState == 0 then
			data.state = "Toss"
		else
			mod:spritePlay(sprite, "Idle" .. data.eggState)
		end
	elseif data.state == "Toss" then
		if sprite:IsFinished("Toss") then
			data.state = "Idle"
			data.eggState = 1
			npc.StateFrame = 10
			data.flightDir = Vector.Zero
		elseif sprite:IsEventTriggered("Toss") then
			npc:PlaySound(SoundEffect.SOUND_ANGEL_WING, 0.4, 0, false, math.random(120,130)/100)
			local proj = Isaac.Spawn(9, 8, 0, npc.Position-Vector(0,10), (target.Position-npc.Position)*0.03, npc):ToProjectile()
			local pSprite = proj:GetSprite()
			pSprite:Load("gfx/projectiles/projectile_broodEgg.anm2", true)
			pSprite:Play("Projectile", true)
			proj:GetData().projType = "Brood"
			proj:GetData().target = target
			proj.Parent = npc
			proj.FallingAccel = 1
			proj.FallingSpeed = -25
			proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
			if mod:isFriend(npc) then
				proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.HIT_ENEMIES
				proj:GetData().friend = true
			elseif mod:isCharm(npc) then
				proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.CANT_HIT_PLAYER
				proj:GetData().friend = true
			end
			proj:Update()
		else
			mod:spritePlay(sprite, "Toss")
		end
	
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.1)
	elseif data.state == "Appear" then
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
		if sprite:IsFinished("Appear" .. data.eggState) then
			data.state = "Idle"
			data.flightDir = Vector.Zero
			npc.StateFrame = 35
		else
			mod:spritePlay(sprite, "Appear" .. data.eggState)
		end
	end
end

function mod.broodProj(v, d)
	if d.projType == "Brood" then
		local room = game:GetRoom()

		if v.FrameCount > 2 and v:HasProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE) then
			v:ClearProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
		end
		
		if v:IsDead() then
			if not room:GetGridEntityFromPos(v.Position) and not d.friend and room:IsPositionInRoom(v.Position, 0) then
				Isaac.GridSpawn(10, 0, v.Position, true)
			end
		
			local testSpiders = false
			local testPos = v.Position
			sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 0.6, 0, false, math.random(80, 120)/100)
			if room:GetGridCollisionAtPos(v.Position) == GridCollisionClass.COLLISION_NONE then
				testSpiders = true
			else
				if room:GetGridCollisionAtPos(v.Position-v.Velocity:Resized(40)) == GridCollisionClass.COLLISION_NONE then
					testSpiders = true
					testPos = v.Velocity:Resized(25)
				end
				
			end
			
			if testSpiders == true then
				local testPath = Isaac.Spawn(114, 5, 0, testPos, Vector.Zero, nil):ToNPC()
				testPath.Visible = false
				testPath:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				testPath.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				if testPath.Pathfinder:HasPathToPos(d.target.Position, false) then
					for i=0,1 do
						EntityNPC.ThrowSpider(v.Position, v.Parent, mod:chooserandomlocationforskuzz(testPath, 100, 50), false, v.Height)
					end
				end
				testPath:Remove()
			end
			local effect = Isaac.Spawn(1000,2,2,v.Position,Vector.Zero,v)
			effect.Color = mod.ColorPureWhite
		end
	end
end

function mod.broodProjColl(v, d)
	if d.projType == "Brood" then
		local room = game:GetRoom()
		if not room:GetGridEntityFromPos(v.Position) and not d.friend and room:IsPositionInRoom(v.Position, 0) then
			Isaac.GridSpawn(10, 0, v.Position, true)
		end
	
		local testSpiders = false
		local testPos = v.Position
		sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 0.6, 0, false, math.random(80, 120)/100)
		if room:GetGridCollisionAtPos(v.Position) == GridCollisionClass.COLLISION_NONE then
			testSpiders = true
		else
			local gridPos = room:GetGridPosition(room:GetGridIndex(v.Position))
			local newTarg = (v.Position-gridPos):Resized(50)+gridPos
			if room:GetGridCollisionAtPos(newTarg) == GridCollisionClass.COLLISION_NONE then
				testSpiders = true
				testPos = newTarg
			end
		end
		
		if testSpiders == true then
			local testPath = Isaac.Spawn(114, 5, 0, testPos, Vector.Zero, nil):ToNPC()
			testPath.Visible = false
			testPath:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			testPath.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			if testPath.Pathfinder:HasPathToPos(d.target.Position, false) then
				for i=0,1 do
					EntityNPC.ThrowSpider(v.Position, v.Parent, mod:chooserandomlocationforskuzz(testPath, 100, 50), false, v.Height)
				end
			end
			testPath:Remove()
		end
	end
end
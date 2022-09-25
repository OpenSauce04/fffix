local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:superGrimaceAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	local room = Game():GetRoom()

	--This guy was nice and simple but then fucking minecarts
	--Don't you love the two inits
	if not d.updatedOnce then
		d.updatedOnce = true
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
		--Force the appear animation, fuck off
		if room:IsClear() or mod.areRoomPressurePlatesPressed() then
			d.stayDead = true
			sprite:Play("ClosedEyes", true)
		else
			sprite:Play("Appear", true)
		end
		npc.Position = npc.Position + Vector(20, 20)
		npc.SpriteOffset = Vector(0, 15)
	--This is so fucking stupid
	--Why does it have to work this way
	elseif npc.FrameCount > 0 or d.inMinecart then
			--Don't you love this ^^^^^^^^^ check right here?
		--How I have to check if it's in a minecart an update later??????????
		if not d.init then
			d.init = true
			npc.SplatColor = mod.ColorGreyscale
			npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
			if room:IsClear() or mod.areRoomPressurePlatesPressed() then
				d.stayDead = true
			else
				d.state = "idle"
			end
			if not d.inMinecart then
				--[[for i = 90, 360, 90 do 
					--Spawn those fucking grids
					--They're decoration grids for fucks sake, regular grimaces don't deal with this shit
					local test = Isaac.GridSpawn(GridEntityType.GRID_DECORATION, 0, npc.Position + Vector(20,20):Rotated(i), true)
					test.CollisionClass = GridCollisionClass.COLLISION_PIT
					local ts = test:GetSprite()
					--DOESN'T WORK, BUT I'LL KEEP IT HERE COS DAMN IF I'LL TRY
					ts.Color = mod.ColorInvisible
					ts:Update()
					test:Update()
				end]]
			else
				npc.SpriteOffset = Vector(0, -10)
				--This is how to remove shadows I guess...
				sprite:ReplaceSpritesheet(2, "gfx/nothing.png")
				sprite:LoadGraphics()
			end
			npc.TargetPosition = npc.Position
		else
			if not sprite:IsPlaying("Appear") then
				npc.StateFrame = npc.StateFrame + 1
			end
		end

		--local grid = room:GetGridEntity(index)
		if not d.inMinecart then
			npc.Position = npc.TargetPosition
			npc.Velocity = nilvector
			for i = 90, 360, 90 do --Doing it the proper way -Guwah
				local index = room:GetGridIndex(npc.Position + Vector(20,20):Rotated(i))
				room:SetGridPath(index, 3999)
			end
		end

		if room:IsClear() or d.stayDead or mod.areRoomPressurePlatesPressed() then
			if d.stayDead then
				mod:spritePlay(sprite, "ClosedEyes")
			elseif sprite:IsFinished("CloseEyes") then
				d.stayDead = true
			else
				mod:spritePlay(sprite, "CloseEyes")
			end
		elseif d.state == "idle" then
			if not sprite:IsPlaying("Appear") then
				mod:spritePlay(sprite, "Idle")
			end
			if npc.StateFrame > 60 and room:CheckLine(npc.Position,target.Position,3,1,false,false) then
				d.state = "shoot"
				d.sucking = true
				npc.StateFrame = 0
			end
		elseif d.state == "shoot" then
			if sprite:IsFinished("Shoot") then
				d.state = "idle"
				npc.StateFrame = 0
				d.sucking = false
			elseif sprite:IsEventTriggered("Grunt") then
				if not sfx:IsPlaying(SoundEffect.SOUND_STONE_WALKER) then
					npc:PlaySound(SoundEffect.SOUND_STONE_WALKER,1,0,false,math.random(140,160)/100)
				end
				d.sucking = true
				npc.StateFrame = npc.StateFrame + 50
			elseif sprite:IsEventTriggered("Shoot") then
				--Gamefeel funnies
				npc:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4,1,0,false,math.random(65,75)/100)
				npc:PlaySound(SoundEffect.SOUND_BULLET_SHOT,0.3,0,false,math.random(65,75)/100)
				game:ShakeScreen(7)
				d.sucking = false

				local shootvec = (target.Position - (npc.Position + npc.SpriteOffset)):Resized(11)
				local proj = Isaac.Spawn(9,0,0,(npc.Position + npc.SpriteOffset) + shootvec:Resized(25), shootvec, npc):ToProjectile()
				proj.SpawnerEntity = npc
				proj:AddScale(1)
				proj.Color = mod.ColorDecentlyRed
				proj:GetData().projType = "superGrimace"
				proj:Update()

			else
				mod:spritePlay(sprite, "Shoot")
			end

			if d.sucking then
				local smokeVec = Vector(0, 60):Rotated(-30 + math.random(60))
				local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position + smokeVec, smokeVec:Resized(math.random(3,7) * -1), npc)
				local alpha = math.min(0.3, npc.StateFrame / 300)
				smoke.Color = Color(1,1,1,alpha,1,0,0)
				smoke.SpriteOffset = Vector(0, -25) + npc.SpriteOffset
				smoke.SpriteScale = smoke.SpriteScale * math.random(70,100)/100
				smoke:Update()
			end
		end

		--[[if npc:IsDead() then
			for i = 90, 360, 90 do
				local grident = room:GetGridEntityFromPos(npc.Position + Vector(20,20):Rotated(i))
				if grident and grident.Desc.Type == GridEntityType.GRID_DECORATION and grident.CollisionClass == GridCollisionClass.COLLISION_PIT then
					grident.CollisionClass = GridCollisionClass.COLLISION_NONE
					grident:Update()
				end
			end
		end]]
	end
end
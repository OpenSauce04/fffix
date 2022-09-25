local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--Spider maggot
function mod:carrierAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder

	if not d.init then
		npc.SplatColor = Color(0,0,0,1,20 / 255,10 / 255,10 / 255);
		d.state = "idle"
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if npc.State == 11 then
		npc.Velocity = nilvector
		if sprite:IsFinished("Death") then
			local spider = Isaac.Spawn(207, 1, 0, npc.Position, nilvector, npc)
			spider:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			npc:Kill()
		elseif sprite:IsEventTriggered("Slorp") then

		elseif sprite:IsEventTriggered("Explode") then
			d.bleeding = true
		elseif not sprite:IsPlaying("Death") then
			sprite:Play("Death", true)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		end

		if d.bleeding then
			if npc.FrameCount % 3 == 0 then
				local bloo2 = Isaac.Spawn(1000, 2, 0, npc.Position + Vector(0, 5), nilvector, npc):ToEffect();
				bloo2.SpriteScale = Vector(0.7,0.7)
				bloo2.SpriteOffset = Vector(0, -10) + RandomVector()*math.random(200)/10
				bloo2.Color = Color(0,0,0,1,20 / 255,10 / 255,10 / 255);
				bloo2:Update()
				npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,0.2,0,false,0.8)
			end
		end
	--I don't give two shits I'm just copying this shit code from shambles
	elseif d.state == "idle" then
		d.newhome = d.newhome or mod:FindRandomValidPathPosition(npc)
		local pdist = target.Position:Distance(npc.Position)
		if mod:isScare(npc) then
			npc.Velocity = (npc.Position - target.Position):Resized(math.max(1, 5 - pdist/50))
			d.newhome = nil
		elseif npc.Position:Distance(d.newhome) < 5 or npc.Velocity:Length() < 1 or (mod:isConfuse(npc) and npc.FrameCount % 30 == 1) then
			d.newhome = mod:FindRandomValidPathPosition(npc)
			path:FindGridPath(d.newhome, 0.3, 900, true)
		else
			path:FindGridPath(d.newhome, 0.3, 900, true)
		end

		--whatever here's an edit ig, changed some string names, big code skills oooo
		if npc.Velocity:Length() > 0 and npc.FrameCount % 5 == 1 then
			if math.abs(npc.Velocity.Y) > math.abs(npc.Velocity.X) then
				sprite.FlipX = false
				if npc.Velocity.Y > 0 then
					d.dir = "Down"
				else
					d.dir = "Up"
				end
			else
				d.dir = "Hori"
				if npc.Velocity.X < 0 then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end

			end
			mod:spritePlay(sprite, "Move" .. d.dir)
		end

		if npc.StateFrame > 9 and npc.FrameCount % 5 == 1 and ((npc.Velocity:Normalized():Dot((target.Position - npc.Position):Normalized()) > math.cos(0.3)) and npc.Position:Distance(target.Position) < 300 and game:GetRoom():CheckLine(npc.Position, target.Position,0,1,false,false)) and not mod:isScareOrConfuse(npc) then
			if d.dir == "Hori" and math.abs(math.abs(target.Position.Y) - math.abs(npc.Position.Y)) < 60 or d.dir ~= "Hori" and math.abs(math.abs(target.Position.X) - math.abs(npc.Position.X)) < 60 then
				local vec = (target.Position - npc.Position)
				if math.abs(vec.Y) > math.abs(vec.X) then
					sprite.FlipX = false
					if vec.Y > 0 then
						d.dir = "Down"
					else
						d.dir = "Up"
					end
				else
					d.dir = "Hori"
					if vec.X < 0 then
						sprite.FlipX = true
					else
						sprite.FlipX = false
					end

				end
				d.shootVec = mod:SnapVector(vec, 90):Normalized()
				d.state = "shoot"
			end
		end
	elseif d.state == "shoot" then
		npc.Velocity = npc.Velocity * 0.7
		if sprite:IsFinished("Shoot" .. d.dir) then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			if mod.GetEntityCount(85, 0) > 4 or math.random(3) == 1 then
				npc:PlaySound(SoundEffect.SOUND_LITTLE_SPIT,1,2,false,0.7)
				local projectile = Isaac.Spawn(9, 0, 0, npc.Position, d.shootVec:Resized(8), npc):ToProjectile();
				local dist = npc.Position:Distance(target.Position)
				projectile.FallingSpeed = dist * -0.03
				projectile.FallingAccel = 0.5
				projectile.Scale = 2
				projectile.Color = mod.ColorWebWhite
				projectile:GetData().projType = "ogreCreep"
				projectile:Update()
			else
				npc:PlaySound(SoundEffect.SOUND_SPIDER_COUGH,1,0,false,1)
				local vec = d.shootVec:Resized(9)
				local ball = Isaac.Spawn(mod.FF.SpiderProj.ID, mod.FF.SpiderProj.Var, 0, npc.Position + vec:Resized(20), vec, npc):ToNPC()
				ball:GetData().vel = vec
				ball:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				if not sprite.FlipX then
					ball:GetSprite().FlipX = true
				end
				ball:Update()

				for i = 1, 5 do
					local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position + vec:Resized(15), (vec * (math.random(70,90)/100)):Rotated(-60 + math.random(120)), npc):ToEffect()
					smoke.SpriteRotation = math.random(360)
					smoke.Color = Color(1,1,1,0.4,0,0,0)
					smoke.SpriteScale = Vector(0.7, 0.7)
					--smoke.SpriteScale = Vector(2,2)
					smoke.SpriteOffset = Vector(0, -10)
					smoke.RenderZOffset = 300
					smoke:Update()
				end

			end
		else
            local room = game:GetRoom()
			local aimPos = room:GetGridPosition(room:GetGridIndex(npc.Position))
			local vec = aimPos - npc.Position
			npc.Velocity = mod:Lerp(npc.Velocity, vec:Resized(vec:Length() / 10), 0.3)
			mod:spritePlay(sprite, "Shoot" .. d.dir)
		end
	end

	if npc:IsDead() then
	 npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
	end
end

function mod:carrierHurt(npc, damage, flag, source)
    if npc:ToNPC().State == 11 then
        return false
    end
end

function mod.carrierDeathEffect(npc)
	local spider = Isaac.Spawn(207, 1, 0, npc.Position, nilvector, npc)
	spider:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
end

function mod:spiderRollerMineAI(npc)
	local d = npc:GetData()
	local sprite = npc:GetSprite()
	d.vel = d.vel or RandomVector():Resized(9)
	mod:spritePlay(sprite, "Idle")
	npc.SplatColor = Color(0.3, 1, 1, 1, 0, 0, 0)
	npc.SpriteOffset = Vector(0, -5)

	npc.Velocity = mod:Lerp(npc.Velocity, d.vel, 0.3)
	if npc:IsDead() then
		for i = 1, 2 do
			EntityNPC.ThrowSpider(npc.Position, npc, npc.Position + Vector(math.random(-40, 40), math.random(-40, 40)), false, 0)
		end
	elseif npc:CollidesWithGrid() then
		npc:Kill()
		sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 0.85, 0, false, 1)
		for i = 1, 2 do
			EntityNPC.ThrowSpider(npc.Position, npc, npc.Position + Vector(math.random(-40, 40), math.random(-40, 40)), false, 0)
		end
	end
end
local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

mod.ghostseDirs = {
	{Vector(1,-1), "Down", false}, -- UR
	{Vector(1,1), "Up", false}, -- DR
	{Vector(-1,1), "Up", true}, -- DL
	{Vector(-1,-1), "Down", true}, -- UL
}
function mod:ghostseAI(npc, subt, var)
	local d = npc:GetData()
	local sprite = npc:GetSprite();
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()

	if not d.init then
		d.state = "idle"
		d.init = true
		d.chargecounter = 0
		npc.SplatColor = mod.ColorGhostly
		--npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Move")
		local targetvel = (mod:randomConfuse(npc, target.Position) - npc.Position):Resized(3)
		if mod:isScare(npc) then
			mod:UnscareWhenOutOfRoom(npc)
			if npc.Position:Distance(target.Position) < 500 then
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel * -1.2, 0.2)
			else
				npc.Velocity = npc.Velocity * 0.9
			end
		else
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.2)
		end
		if npc.Position.X < target.Position.X then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end
		if npc.StateFrame > 60 and not mod:isScareOrConfuse(npc) then
			if math.abs(math.abs(targetvel.X) - math.abs(targetvel.Y)) < 2 then
				if targetvel.X < 0 then
					if targetvel.Y > 0 then
						d.dir = 1
					else
						d.dir = 2
					end
				else
					if targetvel.Y < 0 then
						d.dir = 3
					else
						d.dir = 4
					end
				end
				d.state = "chargeinit"
			end
		end
	elseif d.state == "chargeinit" then
		npc.Velocity = mod:Lerp(npc.Velocity, nilvector, 0.2)
		if sprite:IsFinished("StartAttack" .. mod.ghostseDirs[d.dir][2]) then
			d.state = "charge"
			npc.StateFrame = 0
			d.chargecounter = 0
			d.maxcharges = math.random(2)
		elseif sprite:IsPlaying("StartAttack" .. mod.ghostseDirs[d.dir][2]) and sprite:GetFrame() == 21 then
			npc:PlaySound(SoundEffect.SOUND_SKIN_PULL,1,0,false,math.random(120,140)/100)
		else
			mod:spritePlay(sprite, "StartAttack" .. mod.ghostseDirs[d.dir][2])
			sprite.FlipX = mod.ghostseDirs[d.dir][3]
		end
	elseif d.state == "charge" then
		mod:spritePlay(sprite, "Attack" .. mod.ghostseDirs[d.dir][2] .. "Loop")
		sprite.FlipX = mod.ghostseDirs[d.dir][3]
		npc.Velocity = mod:Lerp(npc.Velocity, mod.ghostseDirs[d.dir][1]:Resized(10), 0.5)
		local room = game:GetRoom()
        if (npc.Position.X > room:GetGridWidth()*40 or npc.Position.X < 0
		or npc.Position.Y > room:GetGridHeight()*40 + 120 or npc.Position.Y < 120)
		and npc.StateFrame > 20
		then
			d.state = "disappear"
		elseif npc.StateFrame > 20 and d.chargecounter >= d.maxcharges then
			d.state = "finish"
		else
			if npc.StateFrame % 2 == 0 then
				npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,0.5,2,false,math.random(9,11)/10)
				local shootdir = mod.ghostseDirs[d.dir][1]:Resized(-11)
				local spread = 35
				if var == 272 then
					local projectile = Isaac.Spawn(9, 0, 0, npc.Position + shootdir:Resized(-20), shootdir:Rotated((-spread/2)+math.random(spread)), npc):ToProjectile();
					local dist = npc.Position:Distance(target.Position)
					projectile.FallingSpeed = -10
					projectile.FallingAccel = 1
					projectile.Scale = 2
					local ipecolor = Color(1,1,1,1,0,0,0)
					ipecolor:SetColorize(0.7, 2, 0.7, 1)
					projectile.Color = ipecolor
					projectile.ProjectileFlags = ProjectileFlags.EXPLODE
					projectile:Update()
				else
					local params = ProjectileParams()
					params.Variant = 3
					params.FallingAccelModifier = 0.13
					params.BulletFlags = params.BulletFlags | ProjectileFlags.GHOST
					params.Color = mod.ColorNormal
					for i = 0, 1 do
						local bullet = npc:FireProjectiles(npc.Position + shootdir:Resized(i*20), shootdir:Rotated((-spread/2)+math.random(spread)), 0, params)
					end
				end
			end
		end
	elseif d.state == "disappear" then
		if sprite:IsFinished("Attack" .. mod.ghostseDirs[d.dir][2] .. "Disappear") then
			d.dir = math.random(4)
			npc.Position = target.Position + mod.ghostseDirs[d.dir][1]:Resized(-200)
			mod:spritePlay(sprite, "Attack" .. mod.ghostseDirs[d.dir][2] .. "Appear")
			d.state = "appear"
			npc.Velocity = mod.ghostseDirs[d.dir][1]:Resized(5)
		else
			mod:spritePlay(sprite, "Attack" .. mod.ghostseDirs[d.dir][2] .. "Disappear")
		end
	elseif d.state == "appear" then
		npc.Velocity = mod:Lerp(npc.Velocity, mod.ghostseDirs[d.dir][1]:Resized(5), 0.2)
		sprite.FlipX = mod.ghostseDirs[d.dir][3]
		if sprite:IsFinished("Attack" .. mod.ghostseDirs[d.dir][2] .. "Appear") then
			d.state = "charge"
			d.chargecounter = d.chargecounter + 1
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "Attack" .. mod.ghostseDirs[d.dir][2] .. "Appear")
		end
	elseif d.state == "finish" then
		npc.Velocity = mod:Lerp(npc.Velocity, nilvector, 0.2)
		if sprite:IsFinished("Attack" .. mod.ghostseDirs[d.dir][2] .. "End") then
			d.state = "idle"
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "Attack" .. mod.ghostseDirs[d.dir][2] .. "End")
		end
	end

end

function mod:ghostseEasyModeAI(npc)
    local d = npc:GetData()
    local sprite = npc:GetSprite();
    local target = npc:GetPlayerTarget()
    local r = npc:GetDropRNG()
    local path = npc.Pathfinder

	if not d.init then
		d.state = "idle"
		d.init = true
		d.chargecounter = 0
		npc.SplatColor = mod.ColorGhostly
		--npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Move")
		local targetvel = (target.Position - npc.Position):Resized(3)
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.2)
		if npc.Position.X < target.Position.X then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end

		if path:HasPathToPos(target.Position) and npc.StateFrame > 100 and r:RandomInt(20) == 0 then
			d.state = "attackstart"
			npc.Velocity = npc.Velocity * 0.90
		end
	elseif d.state == "attackstart" then
		npc.Velocity = npc.Velocity * 0.9
		if sprite:IsFinished("StartAttackDown") then
			d.state = "attackstop"
		elseif sprite:GetFrame() == 24 then
			Isaac.GridSpawn(14, 4, npc.Position, true)
			npc:PlaySound(SoundEffect.SOUND_HAPPY_RAINBOW,1,0,false,1)
			npc:PlaySound(SoundEffect.SOUND_FART,1,0,false,0.7)
		else
			mod:spritePlay(sprite, "StartAttackDown")
		end
	elseif d.state == "attackstop" then
		npc.Velocity = npc.Velocity * 0.9
		if sprite:IsFinished("AttackDownEnd") then
			d.state = "idle"
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "AttackDownEnd")
		end
	end

	if npc:IsDead() then
		Isaac.Spawn(1000, 104, 0, npc.Position, nilvector, npc)
		npc:PlaySound(SoundEffect.SOUND_HAPPY_RAINBOW,1,0,false,1)
	end
end

function mod:ghostseEasyColl(npc1, npc2)
	local d = npc1:GetData()
	if not d.charmed then
		if (npc2.Type == 1 or (npc2.Type == mod.FF.WoodburnerEasy.ID and npc2.Variant == mod.FF.WoodburnerEasy.Var and npc2.SubType == 1) or (npc2.Type == mod.FF.GhostseEasy.ID and npc2.Variant ==  mod.FF.GhostseEasy.Var and npc2.SubType == 1)) then
			npc1:PlaySound(SoundEffect.SOUND_BROWNIE_LAUGH,1,0,false,math.random(60,70)/100)
			npc1:AddEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY)
			npc1.SubType = 1
			d.charmed = true
		end
	end
end

function mod.ghostseProjOverride(v)
	if v.SpawnerType == mod.FF.Ghostse.ID and v.SpawnerVariant == mod.FF.Ghostse.Var then
		v.Color = Color(1,1,1,0.75,0,0,0)
	end
end

function mod:ghostseSepticHurt(npc, damage, flag, source)
	if flag & DamageFlag.DAMAGE_EXPLOSION ~= 0 and source.Type ~= 1 then
		return false
	end
end
local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:grapeAI(npc, subt)
	local sprite = npc:GetSprite()
	local d = npc:GetData()

	local movespeed = 4
	local movelerp = 0.3

	if subt == 1 then
		movespeed = 5
		movelerp = 0.05
		d.face = d.face or math.random(3)
	else
		if not d.init then
			d.tilt = -2
			d.init = true
		end
	end

	npc.StateFrame = npc.StateFrame + 1

	if d.face and d.face > 1 then
		mod:spritePlay(sprite, "Fly" .. d.face)
	else
		mod:spritePlay(sprite, "Fly")
	end

	local targvel = mod:diagonalMove(npc, movespeed, 1)
	if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE) then
		targvel = targvel / 2
	end
	if subt == 1 and npc.SpawnerEntity and npc.SpawnerEntity.Type == 67 then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		d.orbOffset = d.orbOffset or math.random(360)
		d.orbDir = d.orbDir or math.random(2)
		if d.orbDir == 2 then
			d.orbDir = -1
		end
		d.orbOffset = (d.orbOffset + (2 * d.orbDir)) % 360

		d.orbDist = d.orbDist or 75
		local targetOrbdist = 75
		for _, enemy in pairs(Isaac.FindInRadius(npc.Position, 50, EntityPartition.ENEMY)) do
			if enemy.Type == npc.Type and enemy.Variant == npc.Variant then
				if enemy:GetData().orbDir then
					if enemy:GetData().orbDir ~= d.orbDir then
						if d.orbDir == 1 then
							targetOrbdist = 90
						else
							targetOrbdist = 60
						end
					end
				end
			end
		end
		d.orbDist = mod:Lerp(d.orbDist, targetOrbdist, 0.1)
		local targpos = npc.SpawnerEntity.Position + Vector(d.orbDist, 0):Rotated(d.orbOffset)
		targvel = (targpos - npc.Position)
		targvel = targvel:Resized(math.min(targvel:Length(), 10))
		movelerp = 0.5
	elseif subt ~=1 then
		local tiltCalc = Vector(targvel.X, 0):Resized(-1) * d.tilt
		targvel = (targvel + tiltCalc):Resized(movespeed)
		if npc:CollidesWithGrid() then
			d.tilt = d.tilt * -1
		end
	end
	npc.Velocity = mod:Lerp(npc.Velocity, targvel, movelerp)

	if npc:IsDead() then
		if subt == 1 then
			game:BombExplosionEffects(npc.Position, 5, 0, mod.ColorInvisible, npc, 0.5, false, true)
			local explosion = Isaac.Spawn(1000, 1, 0, npc.Position, nilvector, npc)
			explosion.SpriteScale = Vector(0.5, 0.5)
			explosion:Update()
		else
			local vec = RandomVector()
			for i = 120, 360, 120 do
				local baby = Isaac.Spawn(mod.FF.Grape.ID, mod.FF.Grape.Var, mod.FF.Grape.Sub, npc.Position + vec:Resized(10):Rotated(i), vec:Resized(5):Rotated(i), npc):ToNPC()
				baby:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				baby:GetData().face = math.ceil(i / 120)
				if npc:IsChampion() then
					baby:MakeChampion(69, npc:GetChampionColorIdx(), true)
					baby.HitPoints = baby.MaxHitPoints
				end
				baby:Update()
				local params = ProjectileParams()
				params.Scale = 1.5
				params.Color = mod.ColorKickDrumsAndRedWine
				npc:FireProjectiles(npc.Position, vec:Resized(7):Rotated(i + 60), 0, params)
			end
		end
	end
end
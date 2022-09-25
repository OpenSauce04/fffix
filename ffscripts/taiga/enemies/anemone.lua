-- Anemone (ported from Flooded Caves Overhaul, originally coded by BlorengeRhymes) --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero
local rng = RNG()

function mod:anemoneAI(npc, sprite, npcdata)
	if not npcdata.init then
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		npcdata.params = ProjectileParams()
		npcdata.params.GridCollision = false
		npcdata.params.BulletFlags = ProjectileFlags.ACCELERATE | ProjectileFlags.NO_WALL_COLLIDE
		npcdata.params.Scale = 1.75
		npcdata.params.FallingAccelModifier = -0.175
		npcdata.lastfire = 3
		npcdata.init = true
	end

	npc.Velocity = nilvector

	if sprite:IsFinished("Appear") or sprite:IsFinished("Shoot") then
		npcdata.last = npc.FrameCount
		sprite:Play("Idle")
	end

	if sprite:IsPlaying("Idle") then
		if (npcdata.last + 25 - npc.FrameCount <= 0 or npc.FrameCount < 20) and math.random(10) == math.random(10) then
			sprite:Play("Shoot")
		end
	end

	if sprite:IsPlaying("Shoot") and sprite:GetFrame() == 1 then
		sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS, 1, 0, false, math.random(8, 12)/10)
	end

	if sprite:IsEventTriggered("Shoot") then
		local r = mod:RandomInt(2,4)
		if r == npcdata.lastfire then r = math.random(3) end
		if r == 1 then npcdata.params.Scale = npcdata.params.Scale * 1.2 end
		local offset = 0
		local speed = 1.4
		for i = 1, r do
			if i == 2 then offset = math.random(2) == math.random(2) and 10 or -10 end
			if i == 3 then offset = -offset end
			npc:FireProjectiles(npc.Position, (npc:GetPlayerTarget().Position - npc.Position):Resized(speed):Rotated(offset), 0, npcdata.params)
			npcdata.params.Scale = npcdata.params.Scale * 0.75
			speed = speed * 0.9
		end
		for _, projectile in pairs(Isaac.FindByType(9, -1, -1)) do
			if projectile.FrameCount <= 1 and projectile.SpawnerType == npc.Type and projectile.SpawnerVariant == npc.Variant then
				local projsprite = projectile:GetSprite()
				projsprite:ReplaceSpritesheet(0, "gfx/projectiles/anemone_projectile.png")
				projsprite:LoadGraphics()
				
				projectile:GetData().AnemoneProjectile = true
			end
		end
		npcdata.params.Scale = 1.5
		sfx:Play(SoundEffect.SOUND_ANIMAL_SQUISH, 1, 0, false, math.random(8, 12)/10)
		npcdata.lastfire = r
	end
end

function mod.anemoneProjectiles(projectile, data)
	if data.AnemoneProjectile then
		data.customProjSplat = "gfx/projectiles/anemoneSplat.png"
		local room = game:GetRoom()
		local gridCollision = room:GetGridCollisionAtPos(projectile.Position)

		if gridCollision == GridCollisionClass.COLLISION_WALL or 
		   gridCollision == GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER or 
		   projectile:IsDead() 
		then
			projectile:Die()
			--[[local effect = Isaac.Spawn(1000, 11, 0, projectile.Position, nilvector, projectile)
			effect:GetSprite():ReplaceSpritesheet(0, "gfx/projectiles/anemoneSplat.png")
			effect:GetSprite():LoadGraphics()
			effect.PositionOffset = projectile.PositionOffset
			sfx:Play(SoundEffect.SOUND_TEARIMPACTS, 1, 0, false, 1)
			projectile:Remove()]]
		end
	end
end

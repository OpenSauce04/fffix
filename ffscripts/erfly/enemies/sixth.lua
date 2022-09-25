local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:sixthAI(npc, subt)
	local sprite = npc:GetSprite()
	local path = npc.Pathfinder
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)

	npc.StateFrame = npc.StateFrame + 1

	if npc.Velocity:Length() > 0.1 then
		npc:AnimWalkFrame("WalkHori","WalkVert",0)
	else
		sprite:SetFrame("WalkVert", 0)
	end

	if mod:isScare(npc) then
		local targetvel = (targetpos - npc.Position):Resized(-6)
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
	elseif game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
		local targetvel = (targetpos - npc.Position):Resized(4)
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
	else
		path:FindGridPath(targetpos, 0.6, 900, true)
	end

	if npc.State == 4 then
		mod:spriteOverlayPlay(sprite, "Head")
		if npc.StateFrame > 20 and math.random(5) == 1 and npc.Position:Distance(targetpos) < 250 and not mod:isScareOrConfuse(npc) then
			npc.State = 8
			mod:spriteOverlayPlay(sprite, "Shoot")
		end
	elseif npc.State == 8 then
		if sprite:IsOverlayFinished("Shoot") then
			npc.State = 4
			npc.StateFrame = 0
		elseif sprite:GetOverlayFrame() == 9 then
			npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1)
			local projectile = Isaac.Spawn(9, 4, 0, npc.Position, (target.Position - npc.Position):Resized(6), npc):ToProjectile();
			projectile.FallingSpeed = -9;
			projectile.Height = -60
			projectile.Scale = 3
			projectile.Color = FiendFolio.ColorPsyGrape2
			projectile:GetData().projType = "Sixth"
			projectile.SpawnerEntity = npc
			projectile:Update()
			for i = 1, 5 do
				local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position, npc.Velocity * 1.3 + Vector(0,0 - math.random(4,7)):Rotated(-60 + math.random(120)), npc):ToEffect()
				smoke.SpriteRotation = math.random(360)
				smoke.Color = FiendFolio.ColorPsyGrape2
				--smoke.SpriteScale = Vector(2,2)
				smoke.SpriteOffset = Vector(0, -30)
				smoke.RenderZOffset = 300
				smoke:Update()
			end
		else
			mod:spriteOverlayPlay(sprite, "Shoot")
		end
	else
		mod:spriteOverlayPlay(sprite, "Head")
		npc.State = 4
	end


end

function mod.sixthProj(v,d)
	if d.projType == "Sixth" then
		if v.SpawnerEntity and v.SpawnerEntity:Exists() then
			local target = v.SpawnerEntity:ToNPC():GetPlayerTarget()
			local targvel = (target.Position - v.Position)
			v.Velocity = mod:Lerp(v.Velocity, targvel:Resized(math.min(targvel:Length() * 0.05, 11)), 0.3)
			if v.FallingSpeed > 0 then
				v.FallingSpeed = 0
			end
		end
		if v.FrameCount > 25 then
			sfx:Play(SoundEffect.SOUND_BOSS1_EXPLOSIONS, 0.65, 0, false, math.random(230,250)/100);
			sfx:Play(SoundEffect.SOUND_HEARTIN, 1.5, 0, false, 1.5);
			local vec = RandomVector()
			for i = 60, 360, 60 do
				local projectile = Isaac.Spawn(9, 4, 0, v.Position, vec:Rotated(i):Resized(3), v.SpawnerEntity):ToProjectile();
				projectile.Height = v.Height
				projectile.FallingSpeed = 1
				projectile.FallingAccel = 0.4
				projectile.HomingStrength = 0.5
				projectile.Color = FiendFolio.ColorPsyGrape2
				projectile:AddProjectileFlags(ProjectileFlags.SMART)
				projectile.SpawnerEntity = v.SpawnerEntity
				mod:makeProjectileConsiderFriend(v.SpawnerEntity, projectile)
				projectile:Update()
			end
			local sploshEffect = Isaac.Spawn(1000, 1738, 0, v.Position, nilvector, v):ToEffect()
			sploshEffect.SpriteOffset = Vector(0, -10 + v.Height / 2)
			sploshEffect.SpriteScale = Vector(0.5, 0.5)
			sploshEffect.Color = FiendFolio.ColorPsyGrape2
			sploshEffect:GetSprite():ReplaceSpritesheet(0, "gfx/projectiles/projectile_bighemo_blue.png");
			sploshEffect:GetSprite():LoadGraphics()
			sploshEffect:Update()

			for i = 30, 360, 30 do
				local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, v.Position, Vector(math.random(40,70)/10,0):Rotated(i), v):ToEffect()
				smoke.SpriteRotation = math.random(360)
				smoke.Color = FiendFolio.ColorPsyGrape2
				--smoke.SpriteScale = Vector(2,2)
				smoke.SpriteOffset = Vector(0, -10 + v.Height / 2)
				smoke.RenderZOffset = 300
				smoke:Update()
			end
			v:Remove()
		end
	end
end
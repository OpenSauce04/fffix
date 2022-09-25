local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:shiitakeAI(npc, subType)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()

	if not d.init then
		if subType > 1 then
			local Vec = RandomVector()*10
			for i = 1, subType do
				local baby = Isaac.Spawn(mod.FF.Shiitake.ID, mod.FF.Shiitake.Var, 0, npc.Position + Vec:Rotated(-40 + math.random(80) + (360/subType) * i):Resized(math.random(8,10)), nilvector, npc)
				baby:Update()
			end
			npc:Remove()
		end

		d.randCol = d.randCol or math.random(7) - 1
		if d.randCol > 0 then
			sprite:ReplaceSpritesheet(0, "gfx/enemies/small mushroom/extraCol" .. d.randCol .. ".png")
			sprite:LoadGraphics()
		end

		d.state = "idle"
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		d.init = true
		d.ChangedHP = true
		d.HPIncrease = 0.1
	else
		npc.StateFrame = npc.StateFrame + 1
		npc.Velocity = nilvector
	end

	if target.Position.X > npc.Position.X + 40 then
		sprite.FlipX = false
	elseif target.Position.X < npc.Position.X - 40 then
		sprite.FlipX = true
	end

	if sprite:IsEventTriggered("shot") then
		if target.Position.X > npc.Position.X then
			sprite.FlipX = false
		elseif target.Position.X < npc.Position.X then
			sprite.FlipX = true
		end

		npc:PlaySound(SoundEffect.SOUND_LITTLE_SPIT,1,2,false,1.3)
		local params = ProjectileParams()
		params.HeightModifier = 15
		params.Scale = 0.5
		npc:FireProjectiles(npc.Position, (target.Position - npc.Position):Resized(7), 0, params)
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		if (not mod:isScareOrConfuse(npc)) and npc.StateFrame > 10 and r:RandomInt(20)+1 == 1 and (target.Position - npc.Position):Length() < 200 and game:GetRoom():CheckLine(target.Position,npc.Position,3,900,false,false) then
			d.state = "spit"
			if target.Position.X > npc.Position.X then
				sprite.FlipX = false
			elseif target.Position.X < npc.Position.X then
				sprite.FlipX = true
			end
		end
	elseif d.state == "spit" then
		if sprite:IsFinished("Shoot") then
			d.state = "idle"
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "Shoot")
		end
	end
end

function mod:shiiitakeInit(npc)
    if npc.SubType > 1 then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end
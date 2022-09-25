local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:lookseeAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
    local room = game:GetRoom()
	if not d.init then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.Visible = false
		d.state = "waiting"
		d.init = true
		local hand = Isaac.Spawn(1000, mod.FF.LookseeHand.Var, mod.FF.LookseeHand.Sub, npc.Position, nilvector, npc)
		hand.Parent = npc
		local hSprite = hand:GetSprite()
		hSprite:ReplaceSpritesheet(0, "gfx/nothing.png")
	--	hSprite:ReplaceSpritesheet(1, "gfx/nothing.png")
	--	hSprite:ReplaceSpritesheet(2, "gfx/nothing.png")
		hSprite:LoadGraphics()
		hand:Update()
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	--npc.Color = Color(0.8,0.8,0.8,1)
	local vecOff = Vector(-40, 0)
	if sprite.FlipX then
		vecOff = vecOff * -1
	end

	if d.state == "waiting" then
		d.shots = 0
		if room:IsClear() then
			npc:Remove()
		end
		if npc.StateFrame > 30 and npc.StateFrame % 10 == 0 and math.random(5) == 1 then
			local newPos, wasSuccessful = mod:FindRandomPillar(npc)
			if wasSuccessful then
				npc.Position = newPos
				local safeToAppear = true
				for _, player in pairs(Isaac.FindInRadius(npc.Position, 150, EntityPartition.PLAYER)) do
					if player then
						safeToAppear = false
					end
				end
				if safeToAppear then
					if room:GetGridCollisionAtPos(npc.Position + Vector(40, 0)) > GridCollisionClass.COLLISION_PIT then
						sprite.FlipX = false
					elseif room:GetGridCollisionAtPos(npc.Position + Vector(-40, 0)) > GridCollisionClass.COLLISION_PIT then
						sprite.FlipX = true
					else
						if target.Position.X > npc.Position.X then
							sprite.FlipX = true
						else
							sprite.FlipX = false
						end
					end
					d.state = "appear"
					sprite:Play("Appear", true)
					npc.Visible = true
				end
			end
		end
	elseif d.state == "appear" then
		if sprite:IsFinished("Appear") then
			d.state = "idle"
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "Appear")
		end
	elseif d.state == "shitHide" then
		if sprite:IsFinished("Hide") then
			d.state = "waiting"
			npc.StateFrame = 0
			npc.Visible = false
		else
			mod:spritePlay(sprite, "Hide")
		end
	elseif d.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		if (npc.StateFrame > 10 and (math.random(10) == 1 or npc.StateFrame > 30)) and room:CheckLine(npc.Position + vecOff, target.Position, 3, 900, false, false) then
			d.state = "shoot"
		elseif npc.StateFrame > 150 then
			d.state = "shitHide"
		end
	elseif d.state == "shoot" then
		if sprite:IsFinished("Shoot") then
			d.state = "idle"
			d.shots = d.shots + 1
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			local reimplementedProj = false
			npc:PlaySound(SoundEffect.SOUND_FAMINE_DEATH_1,1,0,false,math.random(130,150)/100)
			if not reimplementedProj then
				local params = ProjectileParams()
				params.Scale = 2
				params.HeightModifier = 5
				params.FallingAccelModifier = -0.1
				params.BulletFlags = params.BulletFlags | ProjectileFlags.BURST8
				params.Color = mod.ColorDecentlyRed
				npc:FireProjectiles(npc.Position + vecOff, (target.Position - (npc.Position + vecOff)):Resized(12), 0, params)
			else
				local projectile = Isaac.Spawn(9, 0, 0, npc.Position + vecOff, (target.Position - (npc.Position + vecOff)):Resized(15), npc):ToProjectile();
				projectile.Parent = npc
				projectile.SpawnerEntity = npc
				projectile.Scale = 1.5
				projectile.Height = -5
				projectile.FallingAccel = -0.1

				local pd = projectile:GetData()
				pd.projType = "yummer"
				projectile:Update()
			end
		else
			mod:spritePlay(sprite, "Shoot")
		end
	end

	if d.state == "idle" or d.state == "shoot" then
		local safeToAppear = true
		for _, player in pairs(Isaac.FindInRadius(npc.Position + vecOff, 100, EntityPartition.PLAYER)) do
			if player then
				safeToAppear = false
			end
		end
		local tear = mod.FindClosestEntity(npc.Position + vecOff, 50, 2)
		local bomb = mod.FindClosestEntity(npc.Position + vecOff, 50, 4)
		local knife = mod.FindClosestEntity(npc.Position + vecOff, 50, 8)
		if tear or bomb or knife then
			safeToAppear = false
		end
		if d.shots >= 3 then
			safeToAppear = false
		end
		if (not safeToAppear) or room:IsClear() then
			d.state = "shitHide"
		end
	end
end
function mod:lookseeHandAI(e)
	if e.Parent and e.Parent:Exists() then
		e.Position = e.Parent.Position
		e.DepthOffset = 20
		local sprite = e:GetSprite()
		local psprite = e.Parent:GetSprite()
		sprite:SetFrame(psprite:GetAnimation(), psprite:GetFrame())
		if psprite.FlipX then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end
		if e.Parent.Visible then
			e.Visible = true
		else
			e.Visible = false
		end
	else
		e:Remove()
	end
end
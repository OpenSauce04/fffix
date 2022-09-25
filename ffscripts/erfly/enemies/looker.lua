local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:lookerAI(npc, subT)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	if not d.init then
		d.init = true
		if subT == 1 then
			d.state = "broken"
		else
			d.state = "idle"
		end
		npc.SpriteOffset = Vector(0, -15)
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if npc.Velocity:Length() == 0 then
		npc.Velocity = RandomVector() * 4
	end

	if d.state == "idle" then
		sprite:SetFrame("Idle", npc.FrameCount % 16)
		npc.Velocity = mod:Lerp(npc.Velocity, mod:runIfFear(npc, npc.Velocity:Resized(4), 6):Rotated(-30 + math.random(90)), 0.2)
		if npc.HitPoints < npc.MaxHitPoints - 15 then
			npc:BloodExplode()
			npc:PlaySound(mod.Sounds.LookerBreak,1,2,false,math.random(80,120)/100)
			d.state = "appear"

		end
	elseif d.state == "appear" then
		sprite:SetFrame("Idle2", npc.FrameCount % 16)
		npc.Velocity = npc.Velocity * 0.9
		if sprite:IsOverlayFinished("EyeAppear") then
			d.state = "broken"
		else
			mod:spriteOverlayPlay(sprite, "EyeAppear")
		end
	elseif d.state == "broken" then
		sprite:SetFrame("Idle2", npc.FrameCount % 16)
		sprite:SetOverlayFrame("Eye", npc.FrameCount % 24)
		npc.Velocity = mod:Lerp(npc.Velocity, mod:runIfFear(npc, npc.Velocity:Resized(4), 6):Rotated(-30 + math.random(90)), 0.2)
		if npc.FrameCount % 24 == 8 and not mod:isScareOrConfuse(npc) then
			npc:PlaySound(mod.Sounds.LookerCharge,0.4,2,false,math.random(80,120)/100)
			local projectile = Isaac.Spawn(9, 0, 0, npc.Position, Vector(0,-4), npc):ToProjectile();
			projectile:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
			local projdata = projectile:GetData();
			projectile.FallingSpeed = 0
			projectile.FallingAccel = -0.1
			projectile.Height = -20
			projectile.Color = mod.ColorPsy2
			projectile.Scale = 1
			projdata.projType = "lookerTear"
			projdata.target = target
			projectile.Parent = npc
			mod:makeProjectileConsiderFriend(npc, projectile)
		end
	end


end

function mod.lookerProjectiles(v,d)
	if d.projType == "lookerTear" then
		if v.Parent then
			if v.Parent:IsDead() then
			d.mode = 2
			end
		end
		if not d.target then
			if v.Parent then
				d.target = v.Parent:GetPlayerTarget()
			else
				d.target = Isaac.GetPlayer(0)
			end
		end
		v.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		if not d.mode then
			if v.FrameCount > 30 then
				if v.FrameCount == 31 then
					--[[local targcoord = mod:intercept(v, d.target, 16)
					local shootvec = targcoord:Normalized() * 16
					v.Velocity = shootvec]]
					v.Velocity = (d.target.Position + (d.target.Velocity * 0.5) - v.Position):Resized(16)
					d.mode = 2
					sfx:Play(mod.Sounds.LookerShoot, 0.75, 0, false, math.random(90,110)/100)
				end
			else
				v.Velocity = v.Velocity * 0.8
			end
		elseif d.mode == 2 then
			v.FallingSpeed = 0.2
			v.FallingAccel = 0
			d.mode = 0
		end
	end
end
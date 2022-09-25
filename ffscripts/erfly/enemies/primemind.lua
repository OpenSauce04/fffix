local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

--I'm in the prime of my life, Bub!
--Brains gains no more pains
--AahHAahAhahHAhaAH
function mod:primemindAI(npc)
	local d = npc:GetData()
	local r = npc:GetDropRNG()
	local target = npc:GetPlayerTarget()
	local targetpos = target.Position
	local sprite = npc:GetSprite()
	
	if not d.init then
		d.init = true
		d.state = "idle"
		npc.SpriteOffset = Vector(0,-15)
		local gridtarget = mod:FindRandomFreePosAir(target.Position, 120)
		d.targetvel = (gridtarget - npc.Position):Resized(5)
	else
		npc.StateFrame = npc.StateFrame + 1
	end


	if d.state == "idle" then
		mod:spritePlay(sprite, "Walk")
		if mod:isScare(npc) or npc.Position:Distance(targetpos) < 120 then
			d.targetvel = (targetpos - npc.Position):Resized(-10)
			d.running = true
		else
			if npc.StateFrame % 30 == 0 or d.running or (mod:isConfuse(npc) and npc.StateFrame % 5 == 0) then
				local gridtarget = mod:FindRandomFreePosAir(target.Position, 120)
				d.targetvel = (gridtarget - npc.Position):Resized(5)
				d.running = false
			end
		end
		npc.Velocity = mod:Lerp(npc.Velocity, d.targetvel, 0.05)

		if npc.StateFrame > 5 and r:RandomInt(math.max(2, 25 - npc.StateFrame)) == 0 and not mod:isScareOrConfuse(npc) then
			if mod.FindClosestEntityPrimeMind(npc.Position,radius,{npc}) then
				d.state = "shoot"
				npc.StateFrame = 1
			end
		end
	elseif d.state == "shoot" then
		npc.Velocity = npc.Velocity * 0.95
		if sprite:IsFinished("ShootLaser") then
			d.state = "openyoureyes"
		elseif sprite:IsEventTriggered("Shoot") then
			d.shooting = true
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "ShootLaser")
		end

	elseif d.state == "openyoureyes" then
		local slowdown = true
		if mod:isScare(npc) or npc.Position:Distance(targetpos) < 120 then
			local targvel = (targetpos - npc.Position):Resized(-3)
			npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.1)
			slowdown = false
		elseif d.target then
			local followtarget = nil
			for i, enemy in pairs(d.target) do
				if i >= 2 then
					followtarget = enemy
					if enemy.Type ~= mod.FF.Primemind.ID and enemy.Type ~= mod.FF.Primemind.Var then
						break
					end
				end
			end
			if followtarget then
				if followtarget.Position:Distance(npc.Position) > 150 then
					local targvel = (followtarget.Position - npc.Position):Resized(2)
					npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.1)
					slowdown = false
				end
			end
		end
		if slowdown then
			npc.Velocity = npc.Velocity * 0.95
		end
		mod:spritePlay(sprite, "WalkLaser")
	elseif d.state == "becomenormal" then
		npc.Velocity = npc.Velocity * 0.95
		if sprite:IsFinished("BecomeNormal") then
			d.state = "idle"
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "BecomeNormal")
		end
	end

	if d.shooting then
		local maxtargs = 5
		if not d.target then
			d.target = {npc}
		end
		d.laser = d.laser or {}
		if #d.target < maxtargs and npc.StateFrame % 30 == 0 then
			local newtarg = mod.FindClosestEntityPrimeMind(d.target[#d.target].Position,radius,d.target)
			if newtarg then
				npc:PlaySound(mod.Sounds.ArcaneFizzle,1,0,false,math.random(16,20)/10)
				table.insert(d.target, newtarg)
				local reticle = Isaac.Spawn(1000, 7017, 0, newtarg.Position, nilvector, npc):ToEffect()
				reticle.SpriteOffset = Vector(0, -10)
				reticle:FollowParent(newtarg)
			end
		end
		if npc.StateFrame % 30 == 10 then
			if d.target then
				for i = 2, #d.target do
					if not d.laser[i-1] then
						npc:PlaySound(mod.Sounds.LightningImpact,1,0,false,1)
						local vec = d.target[i].Position - d.target[i-1].Position
						--local laser = Isaac.Spawn(7,2,0,d.target[i-1].Position, nilvector, npc):ToLaser()
						local laser = EntityLaser.ShootAngle(2, d.target[i-1].Position, vec:GetAngleDegrees(), 999999999, Vector(0, -30), d.target[i-1])
						--[[
						laser.SpawnerEntity = d.target[i-1]
						laser.Parent = d.target[i-1]
						laser.Angle = vec:GetAngleDegrees()
						laser:SetTimeout(10)
						laser.DepthOffset = 500
						laser:GetSprite().Offset = Vector(0, -20)]]
						laser.MaxDistance = vec:Length()
						laser.Color = mod.ColorPsy
						laser.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
						laser.CollisionDamage = 0
						laser:Update()
						table.insert(d.laser, laser)
					end
				end
			end
		end
		if d.target then
			for i = 2, #d.target do
				if d.target[i]:IsDead() or mod:isStatusCorpse(d.target[i]) --[[or not d.target[i].Visible]] then
					for j = #d.laser, i - 1, -1 do
						d.laser[j]:Remove()
						d.laser[j] = nil
					end
					for j = #d.target, i, -1 do
						d.target[j] = nil
					end
					if #d.laser <= 0 then
						d.target = nil
						d.laser = nil
						d.shooting = false
						d.state = "becomenormal"
					end
					break
				end
			end
		end
		if d.target and d.laser then
			for i = 1, #d.laser do
				local vec = d.target[i+1].Position - d.target[i].Position
				local laser = d.laser[i]
				laser.Angle = vec:GetAngleDegrees()
				laser.MaxDistance = vec:Length()
                laser.Mass = 0
				laser.Parent = d.target[i]
				laser.SpawnerEntity = d.target[i]
				laser:Update()
			end
		end
	end
	if npc:IsDead() or mod:isLeavingStatusCorpse(npc) then
		if d.laser then
			for i = 1, #d.laser do
				d.laser[i]:Remove()
			end
		end
	end
end

function mod:primemindReticle(e)
	if e.FrameCount > 10 then
		e:Remove()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.primemindReticle, 7017)

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local rng = RNG()

local SPAWN_CHANCE = 15
local CONSECUTIVE_SPAWN_MAX = 7
local BEADFLY_CAP = 8

return {
	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if not data.rng then
			data.rng = RNG()
			data.rng:SetSeed(npc.InitSeed, 32)

			data.spawned = 0
		end

		if sprite:IsFinished("StartAttackDown") then
			sprite:Play("AttackDownLoop")
		elseif sprite:IsFinished("StartAttackUp") then
			sprite:Play("AttackUpLoop")
		elseif sprite:IsFinished() then
			if sprite:GetAnimation() == "Appear" then
				data.buffer = npc.FrameCount - 100
			else
				data.buffer = npc.FrameCount
			end

			data.spawned = 0

			sprite:Play("Move")
		end

		--[[if sprite:IsEventTriggered("StartAttack") then
			local gib = Isaac.Spawn(mod.FF.RipcordRingGib.ID, mod.FF.RipcordRingGib.Var, mod.FF.RipcordRingGib.Sub, npc.Position, data.fire:Rotated(math.random(-15, 15)):Resized(math.random(4, 5)), npc)
			local dat = gib:GetData()

			gib:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			gib.SpriteOffset = Vector(0, -16)
			gib.SpriteRotation = math.random(360)
			dat.vel = -7
		end]]

		if sprite:IsEventTriggered("StartAttack") or sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(mod.Sounds.RipcordPop, sprite:IsEventTriggered("StartAttack") and 1 or 0.6, 0, false, 1)
			
			local gib = Isaac.Spawn(1000, 58, 0, npc.Position, -data.fire:Rotated(math.random(-30, 30)):Resized(math.random(3, 4)), npc)

			local new = Isaac.Spawn(mod.FF.BeadFly.ID, mod.FF.BeadFly.Var, 0, npc.Position, data.fire:Resized(2), npc):ToNPC()
			new:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			
			local color = Color(1, 1, 1, 0.8, 0, 0, 0)
			color:SetColorize(1.8, 0.55, 0.45, 1)
			
			if sprite:IsEventTriggered("StartAttack") then
				new:GetData().altsprite = true
				
				local poof = Isaac.Spawn(1000, 16, 4, npc.Position, Vector.Zero, npc)
				poof.SpriteOffset = Vector(0, -16)
				poof.SpriteScale = Vector(0.65, 0.65)
				poof.Color = color
				
				poof = Isaac.Spawn(1000, 2, 0, npc.Position, -data.fire:Resized(5), npc)
				poof.SpriteOffset = Vector(0, -16)
				poof.Color = color
			else
				if rng:RandomFloat() <= 0.5 then
					local poof = Isaac.Spawn(1000, 2, 0, npc.Position, -data.fire:Resized(5), npc)
					poof.SpriteOffset = Vector(0, -16)
					poof.Color = color
				else
					local poof = Isaac.Spawn(1000, 2, 5, npc.Position, -data.fire:Resized(5), npc)
					poof.SpriteOffset = Vector(0, -16)
					poof.Color = color
				end
			end

			new:GetSprite():Play("Appear")
			
			new.Parent = data.lastfly
			if data.lastfly then
				data.lastfly.Child = new

				new:GetData().chain = Isaac.Spawn(mod.FF.BeadFlyChain.ID, mod.FF.BeadFlyChain.Var, mod.FF.BeadFlyChain.Sub, new.Position, Vector.Zero, npc)
				new:GetData().chain:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				new:GetData().chain.Visible = false
			end
			data.lastfly = new

			new:GetData().dir = data.fire

			npc.Velocity = -data.fire:Resized(13)

			data.spawned = data.spawned + 1
			if data.spawned >= CONSECUTIVE_SPAWN_MAX or not game:GetRoom():IsPositionInRoom(npc.Position + npc.Velocity * 5, 20) then
				if sprite:IsPlaying("AttackUpLoop") then
					sprite:Play("AttackUpEnd")
				elseif sprite:IsPlaying("AttackDownLoop") then
					sprite:Play("AttackDownEnd")
				end

				data.lastfly = nil
			end
		end

		if sprite:IsPlaying("StartAttackDown") or sprite:IsPlaying("StartAttackUp") then
			local frame = sprite:GetFrame()

			if frame == 10 then
				npc:PlaySound(mod.Sounds.RipcordReveal, 1, 12, false, 1)
			elseif frame == 34 then
				--npc:PlaySound(mod.Sounds.RipcordShitting, 1, 0, false, 1)
			end
		end

		if sprite:IsPlaying("Move") then
			local target = npc:GetPlayerTarget()
			npc.Velocity = mod.Xalum_Lerp(npc.Velocity, (target.Position - npc.Position):Resized(3), 0.2)
			sprite.FlipX = npc.Velocity.X > 0

			if npc.FrameCount % 90 == math.random(5) then
				npc:PlaySound(mod.Sounds.RipcordIdle, 1, 0, false, 1)
			end

			if npc.FrameCount - data.buffer > 150 and Isaac.CountEntities(nil, mod.FF.BeadFly.ID, mod.FF.BeadFly.Var) < BEADFLY_CAP then
				if npc.FrameCount % SPAWN_CHANCE == data.rng:RandomInt(SPAWN_CHANCE) then
					local target = npc.Position - 2 * (game:GetRoom():GetCenterPos() - npc.Position)
					local dir = "Down"
					data.fire = Vector(0, 1)

					if target.Y < npc.Position.Y then
						dir = "Up"
						data.fire = -data.fire
					end

					sprite.FlipX = target.X > npc.Position.X
					data.fire = data.fire + Vector(sprite.FlipX and 1 or -1, 0)

					sprite:Play("StartAttack" .. dir)

					
				end
			end
		else
			npc.Velocity = npc.Velocity * 0.8
		end
	end,
}
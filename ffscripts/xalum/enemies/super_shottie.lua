local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local ShottieState = {
	IDLE 		= 1,
	STATIONARY	= 2,
	FLYING		= 3,
	FLAKKING	= 4,
}

local function CanSeePlayerTarget(npc)
	local target = npc:GetPlayerTarget()
	local room = game:GetRoom()

	return room:CheckLine(npc.Position, target.Position, 3)
end

return {
	Init = function(npc)
		local data = npc:GetData()
		data.stateFrame = 0
		data.attackCooldown = 60

		npc.Mass = 10
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	end,

	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		data.stateFrame = data.stateFrame + 1
		data.attackCooldown = data.attackCooldown - 1

		if sprite:IsFinished("Appear") then
			sprite:Play("Intro")
			data.state = ShottieState.STATIONARY
		elseif sprite:IsFinished("Intro") or sprite:IsFinished("ShootHori") or sprite:IsFinished("ShootDown") or sprite:IsFinished("ShootUp") or sprite:IsFinished("HookFail") then
			data.state = ShottieState.IDLE
			data.stateFrame = 0
			data.attackCooldown = 60
		elseif sprite:IsFinished("ShootHook") then
			sprite:Play("ShootHookLoop")
		elseif sprite:IsFinished("HookLand") then
			data.state = ShottieState.FLYING
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			sfx:Play(mod.Sounds.SuperShottieChainLoop, 1, 0, true)
		end

		if data.state == ShottieState.IDLE then
			if data.stateFrame % 210 > 90 and data.stateFrame % 210 < 150 then
				npc.Velocity = mod.XalumLerp(npc.Velocity, Vector.Zero, 0.2)
			else
				mod.XalumRandomPathfind(npc, 1.5)
			end

			if npc.Velocity:Length() > 0.5 then
				sprite:Play("Walk")
				sprite.FlipX = npc.Velocity.X > 0
			else
				sprite:Play("Idle")
			end

			if CanSeePlayerTarget(npc) and mod.IsPositionOnScreen(npc.Position) and npc.FrameCount % 45 == 0 and data.attackCooldown < 0 then
				sprite:Play("ShootHook")
				data.state = ShottieState.STATIONARY
				sfx:Play(SoundEffect.SOUND_MONSTER_GRUNT_4)
			end
		elseif data.state == ShottieState.STATIONARY then
			npc.Velocity = mod.XalumLerp(npc.Velocity, Vector.Zero, 0.2)
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
		elseif data.state == ShottieState.FLYING then
			local direction = data.hook.Position - npc.Position
			npc.Velocity = mod.XalumLerp(npc.Velocity, direction:Resized(16), 0.2)

			local animFrame = sprite:GetFrame()
			local suffix = "Hori"
			if math.abs(npc.Velocity.Y) > math.abs(npc.Velocity.X) then
				if npc.Velocity.Y > 0 then
					suffix = "Down"
				else
					suffix = "Up"
				end

				sprite.FlipX = false
			else
				sprite.FlipX = npc.Velocity.X > 0
			end

			local prefix = "Fly"
			sprite:Play(prefix .. suffix)
			sprite:SetFrame(animFrame)

			if (npc.Position:Distance(data.hook.Position) < npc.Velocity:Length() * 16) or data.flakking then
				sprite:Play("Shoot" .. suffix)
				sprite:SetFrame(data.flakking and animFrame or 0)

				data.flakking = true
			end

			if sprite:IsEventTriggered("PreBlast") then
				data.state = ShottieState.FLAKKING
				data.hook:GetData().state = 4
				sprite:Play("Shoot" .. suffix)
			end
		elseif data.state == ShottieState.FLAKKING then
			local speed = npc.Velocity:Length()
			npc:AddVelocity((npc:GetPlayerTarget().Position - npc.Position):Resized(4))
			npc.Velocity = npc.Velocity:Resized(speed)
		end

		if sprite:IsEventTriggered("Flak") then
			npc:FireBossProjectiles(18, npc.Position + npc.Velocity:Resized(40), 0, ProjectileParams())
			npc:FireProjectiles(npc.Position, npc.Velocity:Resized(9), 5, ProjectileParams())
			sfx:Play(mod.Sounds.SuperShottieBlast, 2)
			game:ShakeScreen(5)

			local recoil = -npc.Velocity:Resized(80)
			local landingPosition = Isaac.GetFreeNearPosition(npc.Position + recoil, 0)

			npc.Velocity = (landingPosition - npc.Position) / 6
			data.state = ShottieState.STATIONARY
			data.flakking = false

			Isaac.Spawn(1000, 2, 3, npc.Position, Vector.Zero, npc).SpriteOffset = Vector(0, -16)
		end

		if sprite:IsEventTriggered("Shoot") then
			local target = npc:GetPlayerTarget()
			local direction = (target.Position + target.Velocity * 16 - npc.Position)
			local hook = Isaac.Spawn(mod.FF.SuperShottieHook.ID, mod.FF.SuperShottieHook.Var, 0, npc.Position + direction:Resized(12), direction:Resized(24), npc)
			sprite.FlipX = direction.X > 0

			local chainTarget = mod:AddDummyEffect(npc, Vector(-12, 0))
			local chainParent = mod:AddDummyEffect(hook, Vector(0, -8))
			local chain = Isaac.Spawn(865, 10, 0, npc.Position, Vector.Zero, npc)
			chain.Parent = chainParent
			chain.Target = chainTarget

			local chainSprite = chain:GetSprite()
			chainSprite:Load("gfx/enemies/shottie/monster_supershottiechain.anm2", true)

			data.hook = hook
			data.chainElements = {
				chainParent,
				chainTarget,
				chain,
			}

			sfx:Play(SoundEffect.SOUND_MONSTER_GRUNT_1)
			sfx:Play(mod.Sounds.SuperShottieChainLoop, 1, 0, true)
			sfx:Play(mod.Sounds.CleaverThrow, 0.6)

			npc.Velocity = hook.Velocity:Resized(-6)
		end

		if sprite:IsEventTriggered("ShotgunOpen") then
			sfx:Play(mod.Sounds.SuperShottieOpen, 2)
		end

		if sprite:IsEventTriggered("ShotgunClose") then
			sfx:Play(mod.Sounds.SuperShottieClose, 2)
		end

		if sprite:IsEventTriggered("Reload") then
			sfx:Play(mod.Sounds.SuperShottieReload)
		end

		if sprite:IsEventTriggered("PreBlast") then
			sfx:Play(mod.Sounds.SuperShottiePreBlast)
		end

		if npc:HasMortalDamage() and (data.hook or data.chainElements) then
			sfx:Stop(mod.Sounds.SuperShottieChainLoop)
			
			if data.hook then
				data.hook:Remove()
			end

			if data.chainElements then
				for _, element in pairs(data.chainElements) do
					element:Remove()
				end
			end
		end
	end,
}
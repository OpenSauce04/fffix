local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--TEST AI
function mod:pacmanAI(npc)
    local target = npc:GetPlayerTarget()
    local subt = npc.SubType
    local speed = 7
    local acc = 0.6

    local pos = nil
	if subt == 1 then
	    pos = target.Position
	elseif subt == 2 then
	    pos = target.Position + target.Velocity * 30
	elseif subt == 3 then
	    pos = target.Position - target.Velocity * 30
	elseif subt == 4 then
	    pos = mod:Lerp(game:GetRoom():GetCenterPos(), target.Position, -1)
    else
        return
    end

    mod:CatheryPathFinding(npc, pos, {
        Speed = speed,
        Accel = acc
    })
end

function mod:oldpathfind(npc)
npc.Pathfinder:FindGridPath(npc:GetPlayerTarget().Position, 0.5, 900, true)
end

function mod:boringWalkAI(npc)
local path = npc.Pathfinder
local target = npc:GetPlayerTarget()

path:SetCanCrushRocks(true)

local targetpos = target.Position

	if game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) and npc.Position:Distance(targetpos) then
		npc.Velocity = (targetpos - npc.Position):Resized(5)
	else
		path:FindGridPath(targetpos, 1, 900, false)
	end
end

function mod:PlayWackySound()
	local numDefaultSounds = SoundEffect.NUM_SOUND_EFFECTS - 1
	local sound = math.random(numDefaultSounds + (FiendFolio.Sounds.MinionSoundscape - FiendFolio.Sounds.SplashSmall))
	if sound > numDefaultSounds then
		sfx:Play(FiendFolio.Sounds.SplashSmall + sound,1,2,false,1)
	else
		sfx:Play(sound - 1,1,2,false,math.random(1,20)/10)
	end
end

function mod:stupidShotsAI(npc)
	mod:PlayWackySound()
	local params = ProjectileParams()
	local target = npc:GetPlayerTarget()
	local projspeed = 10
	local targcoord = mod:intercept(npc, target, projspeed)
	local shootvec = targcoord:Normalized() * projspeed
	params.Scale = 1
	params.BulletFlags = params.BulletFlags | ProjectileFlags.SMART | ProjectileFlags.GHOST
	params.FallingSpeedModifier = 0
	params.FallingAccelModifier = 0
	npc:FireProjectiles(npc.Position, shootvec, 0, params)
	game:ShakeScreen(6)
end

function mod:bigbrainai(npc)
	local d = npc:GetData()
	if not d.init then
		d.init = true
		local braincount = 100
		for i = 1, braincount do
			local brain = Isaac.Spawn(mod.FF.Cortex.ID, mod.FF.Cortex.Var, 0, npc.Position, nilvector, npc)
			brain.Parent = npc
			brain:GetData().rotval = (75 / braincount) * i
		end
	end
end

function mod:mernAI(npc)
	npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_DEATH_TRIGGER | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_FLASH_ON_DAMAGE | EntityFlag.FLAG_PERSISTENT)
	mod:boringWalkAI(npc)
	mod:stupidShotsAI(npc)
	--mod:bigbrainai(npc)
	local target = npc:GetPlayerTarget()
	local targetpos = target.Position
	local roompos = game:GetRoom():FindFreePickupSpawnPosition(targetpos, 80, true)
	npc.Position = roompos

	if npc:IsDead() then
		for i = 0, 360, 3.6 do
			mod.spawnent(npc, npc.Position, Vector(10,10):Rotated(i), 256, 0)
		end
	end
end
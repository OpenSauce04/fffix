local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local data = familiar:GetData()
	local sprite = familiar:GetSprite()
    local player = familiar.Player

	if sprite:IsFinished("Hit") then
		sprite:Play("Idle", false)
	end

    data.speed = data.speed or 1
    familiar.CollisionDamage = 1

    local maxSpeed = 1
    local pspeed = player:GetMovementVector():Length()
    if pspeed > 0.05 then
        data.speed = math.min(pspeed, data.speed + 0.1) 
    else
        data.moveTimer = 0
        data.speed = data.speed * 0.9
    end

	if sprite:IsEventTriggered("Spawn") then
        local isBFF, isBabyBender
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
            isBFF = true
        end
        if player:HasTrinket(TrinketType.TRINKET_BABY_BENDER) then
            isBabyBender = true
        end
        for i = 45, 360, 45 do
            local laser = EntityLaser.ShootAngle(2, familiar.Position, i, 3, Vector(0, -20), familiar)
            laser.Parent = familiar
            laser.CollisionDamage = 3.5
            if isBFF then
                laser.CollisionDamage = laser.CollisionDamage * 2
            end
            if isBabyBender then
                laser:AddTearFlags(TearFlags.TEAR_HOMING)
                laser.Color = Color(1,1,1,1,0,0,1)
            else
                laser.Color = Color(1.5,2.5,2.5,1,-0.8,0.8,1)
            end
            laser:Update()
        end
	end
    --movement
    data.moveTimer = data.moveTimer or 0
    local timeOff = 5
    if data.moveTimer >= timeOff or data.moveTimer == 0 then
	    familiar:MoveDiagonally(data.speed)
    else
        familiar:MoveDiagonally(data.speed * data.moveTimer / timeOff)
        familiar.Velocity = mod:Lerp(familiar.Velocity, player:GetMovementVector() * 3, 1 - (data.moveTimer / timeOff))
    end
    data.moveTimer = data.moveTimer + 1
end, FamiliarVariant.ROBOBABY3)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, f, c)
    if c:ToProjectile() or (c:IsEnemy() and not c:HasEntityFlags(EntityFlag.FLAG_NO_TARGET)) then
    	if c:ToProjectile() then
            c:Die()
        end

    	local s = f:GetSprite()
    	if s:IsPlaying("Idle") then
			s:Play("Hit", false)
		end
    end
end, FamiliarVariant.ROBOBABY3)
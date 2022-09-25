local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local data = familiar:GetData()
	local sprite = familiar:GetSprite()
	local isSuperpositioned = mod:isSuperpositionedPlayer(familiar.Player)
	local isSirenCharmed = mod:isSirenCharmed(familiar)

    if not data.init then
        familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        data.lastShootFrame = 0
        data.init = true
    end

	if sprite:IsFinished("Appear") or sprite:IsFinished("Attack") then
		sprite:Play("Idle")
	end

	if familiar.Velocity.X >= 0 then
		sprite.FlipX = false
	else
		sprite.FlipX = true
	end

	if sprite:IsPlaying("Attack") then
		familiar.Velocity = familiar.Velocity * 0.8
		if sprite:IsEventTriggered("Shoot") then

			local shootRots = {0, 0, 1}
			if Sewn_API then
				if Sewn_API:IsUltra(data) then
					shootRots = {-40, 40, 20}
				elseif Sewn_API:IsSuper(data) then
					shootRots = {-20, 20, 20}
				end
			end

			for i = shootRots[1], shootRots[2], shootRots[3] do
				if isSirenCharmed then
					local proj = Isaac.Spawn(9, 0, 0, familiar.Position, (data.target.Position - familiar.Position):Resized(9):Rotated(i), familiar)
				else
					local tear = Isaac.Spawn(2, 0, 0, familiar.Position, (data.target.Position - familiar.Position):Resized(9):Rotated(i), familiar)
				
					if isSuperpositioned then
						local tearcolor = Color.Lerp(tear.Color, Color(1,1,1,1,0,0,0), 0)
						tearcolor.A = tearcolor.A / 4
						tear.Color = tearcolor
					end
				end
			end
			data.lastShootFrame = familiar.FrameCount
		end
    elseif not sprite:IsPlaying("Appear") then
        if familiar.Velocity:Length() > 0.3 then
            if not sprite:IsPlaying("Attack") then
                sprite:Play("Walk")
            end
        else
            sprite:Play("Idle")
        end

		if data.target and 
		   (data.target:IsDead() or 
		    familiar.FrameCount % 30 == 0 or 
		    (data.target.Type == 1 and familiar.FrameCount % 15 == 0 and not isSirenCharmed) or
		    (data.target.Type ~= 1 and familiar.FrameCount % 15 == 0 and isSirenCharmed)) 
		then
			data.target = nil
		end
		if not data.target then
			if isSirenCharmed then
				data.target = mod:getClosestPlayer(familiar.Position, 900)
			else
				data.target = mod:getClosestEnemyMinion(familiar.Position, 900)
			end
			if not data.target then
				data.target = familiar.Player
			end
		end
        if data.target and familiar.FrameCount % 2 == 0
        and (familiar.Position:DistanceSquared(data.target.Position) - familiar.Size ^ 2 - data.target.Size ^ 2 > 20 ^ 2
        or not game:GetRoom():CheckLine(familiar.Position, data.target.Position, 0, 1, false, false)) then
			mod:CatheryPathFinding(familiar, data.target.Position, {
                Speed = 6,
                Accel = 0.9,
                Threshold = 600
            })
        else
			familiar.Velocity = familiar.Velocity * 0.7
		end

        if familiar.FrameCount - data.lastShootFrame >= 20
        and data.target and ((data.target.Type ~= 1 and not isSirenCharmed) or (data.target.Type == 1 and isSirenCharmed))
        and familiar.Position:DistanceSquared(data.target.Position) - familiar.Size ^ 2 - data.target.Size ^ 2 <= 80 ^ 2 then
			sprite:Play("Attack")
		end
	end
end, FamiliarVariant.MAMA_SPOOTER)
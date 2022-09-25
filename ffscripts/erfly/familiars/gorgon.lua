local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local d = fam:GetData()
	local sprite = fam:GetSprite()
	local isSirenCharmed = mod:isSirenCharmed(fam)

	d.StateFrame = d.StateFrame or 0

	if not d.init then
		local room = Game():GetRoom()
		fam.Position = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 40)
		d.aimvec = Vector(0, -1)
		d.init = true
	else
		d.StateFrame = d.StateFrame + 1
	end
	
	if d.target and ((isSirenCharmed and d.target.Type ~= 1) or (not isSirenCharmed and d.target.Type == 1)) then
		d.target = nil
	end

	if (not d.target) or (d.target and (not d.target:Exists())) or (d.target and d.target.EntityCollisionClass == EntityCollisionClass.ENTCOLL_NONE) or (not isSirenCharmed and d.StateFrame > 60) or (isSirenCharmed and d.StateFrame > 120) then
		local seedPass
		if d.ignoreSeed then
			if d.StateFrame > 150 or (not d.ignoreSeed:Exists()) then
				d.ignoreSeed = nil
			else
				seedPass = d.ignoreSeed.InitSeed
			end
		end
		local target
		if isSirenCharmed then
			target = mod:getClosestPlayer(fam.Position, 800, seedPass)
		else
			target = mod.FindClosestEnemy(fam.Position, 800, true, nil, seedPass)
		end
		d.target = target or fam.Player
		if target then
			d.StateFrame = 0
		end
	end

	fam.Velocity = fam.Velocity * 0.1

	if d.target then
		if (isSirenCharmed and (d.target.Index ~= fam.Player.Index or d.target.InitSeed ~= fam.Player.InitSeed)) or d.target.Type ~= 1 then
			d.ignoreSeed = d.target
			if not d.activated then
				mod:spritePlay(sprite, "Appear")
				d.activated = true
			end
		else
			if not d.ignoreSeed then
				mod:spritePlay(sprite, "Shut Down")
				d.activated = false
				d.aimvec = Vector(0, -1)
			end
		end

		if not sprite:IsPlaying("Appear") and d.activated then
			local ang = mod.chooseClosestRotationDirection(d.aimvec, d.target.Position - fam.Position, true)
			d.aimvec = d.aimvec:Rotated(ang[1] * ang[2] / 10)
			local faceVec = (d.aimvec):Rotated(67.5)
			sprite:SetFrame("Attack", math.floor((faceVec:GetAngleDegrees() * -1 / 45) % 8))
			if ang[2] < 10 and ((isSirenCharmed and (d.target.Index ~= fam.Player.Index or d.target.InitSeed ~= fam.Player.InitSeed)) or d.target.Type ~= 1) then
				local freezeAmount = 2
				if d.target:IsBoss() then
					freezeAmount = 50
				end
				if isSirenCharmed then
					d.target:AddSlowing(EntityRef(nil), 1, 0.6, Color(1.0, 1.0, 1.3, 1.0, 40/255, 40/255, 40/255))
				else
					d.target:AddFreeze(EntityRef(Isaac.GetPlayer(0)), freezeAmount)
				end
			end
		end
	end
end, FamiliarVariant.GORGON)
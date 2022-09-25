local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--Closely linked to Sanguine Hook

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local player = fam.Player
	local d = fam:GetData()
	local sprite = fam:GetSprite()
	local isSuperpositioned = mod:isSuperpositionedPlayer(fam.Player)
	
	local wasSirenCharmed = d.IsSirenCharmed or false
	local isSirenCharmed = mod:isSirenCharmed(fam)

	if not d.init then
		d.state = "idle"
		d.followParent = true
		fam.SpriteOffset = Vector(0, 7)
		d.init = true
	elseif isSirenCharmed and not wasSirenCharmed then
		d.StateFrame = -20
	else
		d.StateFrame = d.StateFrame or 0
		d.StateFrame = d.StateFrame + 1
	end

	if d.state == "idle" then
		if not d.followParent then
			fam:AddToFollowers()
			d.followParent = true
		end
		fam:FollowParent()
		if sprite:IsPlaying("ShootIdle") then
			mod:spritePlay(sprite, "Catch")
		end
		if not sprite:IsPlaying("Catch") then
			mod:spritePlay(sprite, "Walk")
		end
		local aim = mod:SnapVector(player:GetAimDirection(), 90):Normalized()
		if aim:Length() > 0.5 and (not isSirenCharmed or d.StateFrame >= 0) then
			d.SavedVec = aim * 30 * player.ShotSpeed + player:GetTearMovementInheritance(aim)
			d.state = "throwHook"
			d.shouldHaveHook = false
			d.PulledOut = nil
			d.PullOutWait = 0
		end
	elseif d.state == "throwHook" then
		if sprite:IsFinished("Shoot") then
			mod:spritePlay(sprite, "ShootIdle")
		elseif sprite:IsEventTriggered("Shoot") then
			local hook = Isaac.Spawn(mod.FF.SanguineHookSmall.ID, mod.FF.SanguineHookSmall.Var, mod.FF.SanguineHookSmall.Sub, fam.Position - fam.Velocity, d.SavedVec, fam)
			hook.GridCollisionClass = GridCollisionClass.COLLISION_WALL
			hook.CollisionDamage = 8
			hook:GetSprite().Rotation = hook.Velocity:GetAngleDegrees()
			hook.Parent = fam
			hook.SpawnerEntity = player
			d.myVeryOwnSanfordSanguineHook = hook
			hook:GetData().IsSirenCharmed = isSirenCharmed
			sfx:Play(mod.Sounds.CleaverThrow,0.3,0,false, math.random(70,90)/100)
			d.shouldHaveHook = true
			if isSuperpositioned then
				local hookcolor = Color.Lerp(hook.Color, Color(1,1,1,1,0,0,0), 0)
				hookcolor.A = hookcolor.A / 4
				hook.Color = hookcolor
				hook:GetData().IsSuperpositioned = true
			end
			hook:Update()
		elseif not sprite:IsPlaying("ShootIdle") then
			mod:spritePlay(sprite, "Shoot")
		end

		if d.shouldHaveHook and ((not d.myVeryOwnSanfordSanguineHook) or (d.myVeryOwnSanfordSanguineHook and (not d.myVeryOwnSanfordSanguineHook:Exists()))) then
			d.state = "idle"
			if isSirenCharmed then d.StateFrame = -20 end
		elseif d.myVeryOwnSanfordSanguineHook and d.myVeryOwnSanfordSanguineHook:Exists() then
			local hd = d.myVeryOwnSanfordSanguineHook:GetData()
			local aim = mod:SnapVector(player:GetAimDirection(), 90):Normalized()
			if hd.hooktarget and hd.hooktarget:Exists() then
				d.followParent = false
				if aim:Length() < 0.5 or fam.Position:Distance(d.myVeryOwnSanfordSanguineHook.Position) < 20 then
					if not d.PulledOut then
						d.PullOutWait = d.PullOutWait or 0
						d.PullOutWait = d.PullOutWait + 1
						if d.PullOutWait > 7 then
							hd.pullingOut = true
							d.myVeryOwnSanfordSanguineHook:Update()
							d.PulledOut = true
						end
					end
				end
			end
		end

		if d.followParent then
			fam:FollowParent()
		else
			fam.Velocity = fam.Velocity * 0.9
			fam:RemoveFromFollowers()
		end
	end

	d.IsSirenCharmed = isSirenCharmed
end, FamiliarVariant.DEIMOS)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)
	familiar.IsFollower = true
end, FamiliarVariant.DEIMOS)
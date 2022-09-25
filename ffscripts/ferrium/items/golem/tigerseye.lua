local mod = FiendFolio
local game = Game()

function mod:tigersEyeUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.TIGERS_EYE) then
		if not data.tigersEye or not data.tigersEye:Exists() then
			local rock = Isaac.Spawn(3, FamiliarVariant.TIGERS_EYE, 0, player.Position, Vector.Zero, player):ToFamiliar()
			rock.Player = player
			data.tigersEye = rock
			rock:Update()
		end
	end
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local data = familiar:GetData()
	local sprite = familiar:GetSprite()
	local player = familiar.Player
    local rng = familiar:GetDropRNG()
    local room = game:GetRoom()

    mod:spritePlay(sprite, "Float")

	if not player:HasTrinket(FiendFolio.ITEM.ROCK.TIGERS_EYE) then
		familiar:Remove()
	end
	if not data.init then
		data.stateframe = 0
        data.moveDir = Vector(0,4):Rotated(rng:RandomInt(360))
        data.lastColl = 0
		data.init = true
	else
		data.stateframe = data.stateframe + 1
	end

    familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS

    if familiar.FrameCount % 3 == 0 then
        for _,ent in ipairs(Isaac.FindInRadius(familiar.Position, 100, EntityPartition.ENEMY)) do
            if ent:IsActiveEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
                if ent.Position:Distance(familiar.Position) - ent.Size < 10 then
                    ent:TakeDamage(player.Damage*0.66, 0, EntityRef(player), 0)
                end
            end
        end
    end
	for _,ent in ipairs(Isaac.FindByType(9,-1,-1,false, true)) do
		if ent.Position:Distance(familiar.Position) - ent.Size < 10 then
			ent:Die()
		end
	end
	if familiar:CollidesWithGrid() then
        if familiar.FrameCount-data.lastColl < 5 then
            data.lastColl = familiar.FrameCount
            data.moveDir = (room:GetCenterPos()-familiar.Position):Rotated(mod:getRoll(-40,40,rng)):Resized(4)
        else
            local target
            local maxRadius = 999
            for _,ent in ipairs(Isaac.FindInRadius(player.Position, 999, EntityPartition.ENEMY)) do
                if ent:IsActiveEnemy() and (not mod:isFriend(ent)) then
                    local dist = familiar.Position:Distance(ent.Position)
                    if dist < maxRadius then
                        maxRadius = familiar.Position:Distance(ent.Position)
                        target = ent
                    end
                end
            end

            if target then
                data.moveDir = (target.Position-familiar.Position):Resized(4)
            end
            data.lastColl = familiar.FrameCount
        end
    end

    familiar.Velocity = data.moveDir
end, FamiliarVariant.TIGERS_EYE)
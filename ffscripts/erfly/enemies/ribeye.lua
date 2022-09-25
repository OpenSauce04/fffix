local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero


function mod:ribeyeAI(npc)
	local d = npc:GetData()
	local sprite = npc:GetSprite();
	local target = npc:GetPlayerTarget()
	local room = game:GetRoom()

	if not d.init then
		d.init = true
		if d.waited then
			d.npcState = "Appear"
			sprite:Play("IdlePeek", true)
			sprite:Play("Appear", true)
		elseif npc.SubType == 1 then
			mod.makeWaitFerr(npc, npc.Type, npc.Variant, npc.SubType, 50)
		else
			d.npcState = "IdlePeek"
		end
		d.peekhits = 0
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET)
		if not d.waited and room:GetFrameCount() < 3 then
			room:SpawnGridEntity(room:GetGridIndex(npc.Position), GridEntityType.GRID_PIT, 0, 1, 0)
			mod:UpdatePits()
		end
	elseif d.init then
		npc.StateFrame = npc.StateFrame + 1
		npc.Velocity = nilvector
		if not mod:IsCurrentPitSafe(npc) then
			npc:Kill()
		end
	end

	if sprite:IsEventTriggered("DMG") then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH,0.3,2,false,1.3)
	elseif sprite:IsEventTriggered("NoDMG") then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	elseif sprite:IsEventTriggered("shoot") then
		npc:PlaySound(SoundEffect.SOUND_BONE_HEART,1,2,false,1.3)
		for i = 0, 2 do
			local projectile = Isaac.Spawn(9, 1, 0, npc.Position, (target.Position-npc.Position):Resized(10):Rotated(-60 + 60*i), npc):ToProjectile();
			projectile.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			projectile.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			local s = projectile:GetSprite()
			s:Load("gfx/projectiles/boomerang rib big.anm2",true)
			s:Play("spin",false)
			s.Offset = Vector(0,-10)
			projectile.Parent = npc
			projectile.FallingSpeed = 0
			projectile.FallingAccel = -0.1
			local pd = projectile:GetData()
			pd.projType = "boomerang2"
			pd.origpos = npc.Position
			if i == 0 then
				pd.rot = 3.5
			elseif i == 2 then
				pd.rot = -3.5
			else
				pd.rot = 0
				projectile.Velocity:Resized(17)
			end
		end

	end

	if d.npcState == "Appear" then
		d.dmgState = "peek"
		if sprite:IsFinished("Appear") then
			npc.StateFrame = 0
            d.npcState = "IdlePeek"
		else
			mod:spritePlay(sprite, "Appear")
		end
	elseif d.npcState == "IdlePeek" then
		d.dmgState = "peek"
		mod:spritePlay(sprite, "IdlePeek")
		if room:CheckLine(target.Position,npc.Position,3,900,false,false) and (npc.StateFrame > 20) and npc.Position:Distance(target.Position) < 200 and (math.random(5) == 1) then
			d.npcState = "Reveal"
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
		elseif npc.StateFrame > 60 or (mod:isScare(npc) and npc.StateFrame > 20) then
			d.npcState = "SubmergePeek"
		end
	elseif d.npcState == "HitPeek" then
		d.dmgState = "peek"
		if sprite:IsFinished("HitPeek") then
			d.npcState = "IdlePeek"
			npc.StateFrame = npc.StateFrame - 10
		else
			mod:spritePlay(sprite, "HitPeek")
		end
	elseif d.npcState == "SubmergePeek" then
		d.dmgState = "peek"
		if sprite:IsFinished("SubmergePeek") then
			npc.Position = mod:FindRandomPit(npc, not (mod:isConfuse(npc) or mod:isScare(npc)))
            d.npcState = "Appear"
            npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
		else
			mod:spritePlay(sprite, "SubmergePeek")
		end
	elseif d.npcState == "Reveal" then
		d.dmgState = "rib"
		d.peekhits = 0
		if sprite:IsFinished("Reveal") then
			d.npcState = "RevealIdle"
			npc.StateFrame = 0
		elseif sprite:IsPlaying("Reveal") and sprite:GetFrame() == 7 then
			npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH,1,2,false,1)
		else
			mod:spritePlay(sprite, "Reveal")
		end
	elseif d.npcState == "RevealIdle" then
		d.dmgState = "rib"
		mod:spritePlay(sprite, "RevealIdle")
		if room:CheckLine(target.Position,npc.Position,3,900,false,false) and (npc.StateFrame > 10) and npc.Position:Distance(target.Position) < 250 and (math.random(3) == 1) and not (mod:isScare(npc) or mod:isConfuse(npc)) then
			d.npcState = "Shoot"
		elseif npc.StateFrame > 60 then
			d.npcState = "Submerge"
		end
	elseif d.npcState == "Shoot" then
		d.dmgState = "rib"
		if sprite:IsFinished("Shoot") then
			d.npcState = "RiblessIdle"
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "Shoot")
		end
	elseif d.npcState == "RiblessIdle" then
		d.dmgState = "heart"
		mod:spritePlay(sprite, "RiblessIdle")
		if npc.StateFrame == 150 then
			d.npcState = "SubmergeRibless"
		end
	elseif d.npcState == "Submerge" then
		d.dmgState = "rib"
		if sprite:IsFinished("Submerge") then
			npc.Position = mod:FindRandomPit(npc, not (mod:isConfuse(npc) or mod:isScare(npc)))
			d.npcState = "Appear"
			npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
		elseif sprite:IsPlaying("Submerge") and sprite:GetFrame() == 13 then
			npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH,1,2,false,0.9)
		else
			mod:spritePlay(sprite, "Submerge")
		end
	elseif d.npcState == "SubmergeRibless" then
		d.dmgState = "heart"
		if sprite:IsFinished("SubmergeRibless") then
			npc.Position = mod:FindRandomPit(npc, not (mod:isConfuse(npc) or mod:isScare(npc)))
			d.npcState = "Appear"
			npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
		elseif sprite:IsPlaying("SubmergeRibless") and sprite:GetFrame() == 7 then
			npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH,1,2,false,0.9)
		else
			mod:spritePlay(sprite, "SubmergeRibless")
		end
	end
end

function mod:ribeyeHurt(npc, damage, flag, source)
    local d = npc:GetData()
    if d.npcState == "IdlePeek" then
        if d.peekhits > 5 then
            d.npcState = "Reveal"
            npc:ToNPC():ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
        else
            d.npcState = "HitPeek"
            npc:ToNPC():PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, 0.3, 0, false, math.random(160,180)/100)
            d.peekhits = d.peekhits + 1
        end
    end
    if d.dmgState == "peek" then
        --npc.HitPoints = npc.HitPoints + damage * 0.88
        return false
    elseif d.dmgState == "rib" then
        npc.HitPoints = npc.HitPoints + damage * 0.55
    end
end
local mod = FiendFolio
local game = Game()

--Mutant Horf AI
local function wrap_angle(angle, add)
	if angle + add < 0 then
		return 360 + (angle + add)
	elseif angle + add > 360 then
		return (angle + add) - 360
	else
		return angle + add
	end
end

function mod:mutantHorfAI(npc, sprite, npcdata)
	local target = npc:GetPlayerTarget()

	if not npcdata.init then
		npcdata.init = true
		npcdata.framecount = 0
		npcdata.firstshot = true
		npcdata.bullet = nil
		npcdata.bullet2 = nil
		sprite:Play("Appear")
	else
		npcdata.framecount = npcdata.framecount + 1
	end

	npcdata.radius = 75 --+ math.sin(npcdata.framecount/5) * 2.5
	if sprite:IsFinished("Appear") then
		mod:spritePlay(sprite, "DoubleAttack")
	end
	if sprite:IsFinished("Attack") or sprite:IsFinished("Attack2") or sprite:IsFinished("DoubleAttack") then
		mod:spritePlay(sprite, "Shake")
	end

	local level = game:GetLevel()
	local stage = level:GetStage()
	local stageType = level:GetStageType()

	local bVariant = 0
	if (stageType == StageType.STAGETYPE_REPENTANCE) and (stage == LevelStage.STAGE1_1 or stage == LevelStage.STAGE1_2) then
		bVariant = 4
	end

	if sprite:IsEventTriggered("Shoot") then
		if npcdata.firstshot then
			npc:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR,1,0,false,1)
			npcdata.bullet = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, bVariant, 0, npc.Position, Vector(0, 5), npc):ToProjectile()
			npcdata.bullet:GetData().offset = 0
			--npcdata.bullet.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			npcdata.bullet.Parent = npc
			npcdata.bullet:GetData().projType = "mutantorbital"
		else
			npc:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR,1,0,false,1)
			if not npcdata.bullet:Exists() then
				npcdata.bullet = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, bVariant, 0, npc.Position, Vector(0, 5), npc):ToProjectile()
				if npcdata.bullet2:Exists() then
					npcdata.bullet:GetData().offset = wrap_angle(npcdata.bullet2:GetData().offset, -180)
				else
					npcdata.bullet:GetData().offset = 0
				end
				--npcdata.bullet.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
				npcdata.bullet.Parent = npc
				npcdata.bullet:GetData().projType = "mutantorbital"
			end
		end
	end
	if sprite:IsEventTriggered("Shoot2") then
		if npcdata.firstshot then
			npc:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR,1,0,false,1)
			npcdata.bullet2 = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, bVariant, 0, npc.Position, Vector(0, -5), npc):ToProjectile()
			npcdata.bullet2:GetData().offset = 180
			--npcdata.bullet.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			npcdata.bullet2.Parent = npc
			npcdata.bullet2:GetData().projType = "mutantorbital"

			npcdata.firstshot = false
		else
			npc:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR,1,0,false,1)
			if not npcdata.bullet2:Exists() then
				npcdata.bullet2 = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, bVariant, 0, npc.Position, Vector(0, -5), npc):ToProjectile()
				if npcdata.bullet:Exists() then
					npcdata.bullet2:GetData().offset = wrap_angle(npcdata.bullet:GetData().offset, 180)
				else
					npcdata.bullet2:GetData().offset = 180
				end
				--npcdata.bullet.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
				npcdata.bullet2.Parent = npc
				npcdata.bullet2:GetData().projType = "mutantorbital"
			end
		end
	end

	--if npcdata.bullet and npcdata.bullet2 then
		--npcdata.bullet.Height = -35
		if npcdata.bullet ~= nil and npcdata.bullet2 ~= nil then
			if not npcdata.bullet:Exists() or not npcdata.bullet2:Exists() then
				if not npcdata.bullet:Exists() and not npcdata.bullet2:Exists() then
					--print("respawning both projectiles")
					mod:spritePlay(sprite, "DoubleAttack")
				elseif npcdata.bullet:Exists() then
					--print("respawning projectile 2")
					mod:spritePlay(sprite, "Attack2")
				else
					--print("respawning projectile 1")
					mod:spritePlay(sprite, "Attack")
				end
			end
		end
	--end

	npc.Velocity = npc.Velocity * 0.5
end
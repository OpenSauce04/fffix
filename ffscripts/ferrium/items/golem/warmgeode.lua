local mod = FiendFolio
local game = Game()

function mod:warmGeodeUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.WARM_GEODE) then
		local level = game:GetLevel()
		local fireNearby = false
        for _, fire in ipairs(Isaac.FindByType(33, -1, -1, false, false)) do
			if fire.Position:Distance(player.Position) <= 80 and fire.HitPoints > 1 then
				fireNearby = true
			end
        end
		for _,fire in ipairs(Isaac.FindByType(1000, EffectVariant.HOT_BOMB_FIRE, -1, false, false)) do
			if fire.Position:Distance(player.Position) <= 80 then
				fireNearby = true
			end
		end
		for _,fire in ipairs(Isaac.FindByType(1000, EffectVariant.BLUE_FLAME, -1, false, false)) do
			if fire.Position:Distance(player.Position) <= 80 then
				fireNearby = true
			end
		end
		for _,fire in ipairs(Isaac.FindByType(1000, EffectVariant.RED_CANDLE_FLAME, -1, false, false)) do
			if fire.Position:Distance(player.Position) <= 80 then
				fireNearby = true
			end
		end
		for _,fire in ipairs(Isaac.FindByType(1000, EffectVariant.FIRE_JET, -1, false, false)) do
			if fire.Position:Distance(player.Position) <= 80 then
				fireNearby = true
			end
		end
		local stage = level:GetStage()
		local stageType = level:GetStageType()
		if fireNearby == true then
			if mod.HasTwoGeodes(player) then
				data.warmGeodeBonus = 2
				data.warmGeodeDamage = 5
			else
				data.warmGeodeBonus = 1
				data.warmGeodeDamage = 3
			end
		elseif ((stage == LevelStage.STAGE1_1 or stage == LevelStage.STAGE1_2) and stageType == StageType.STAGETYPE_AFTERBIRTH) or ((stageType == StageType.STAGETYPE_REPENTANCE or stageType == StageType.STAGETYPE_REPENTANCE_B) and (stage == LevelStage.STAGE2_1 or stage == LevelStage.STAGE2_2)) then
			data.warmGeodeBonus = 1
			data.warmGeodeDamage = 1.5
		else		
			data.warmGeodeBonus = nil
		end
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
		player:EvaluateItems()
	end
end

function mod:warmGeodeKnife(player, ent, secondHand)
	if player:GetData().warmGeodeBonus == 2 then
		ent:AddBurn(EntityRef(player), 60*secondHand, player.Damage)
	end
end

function mod:warmGeodeLaser(player, ent, secondHand)
	if player:GetData().warmGeodeBonus == 2 then
		ent:AddBurn(EntityRef(player), 60*secondHand, player.Damage)
	end
end

function mod:warmGeodeDarkArts(player, ent, secondHand)
	if player:GetData().warmGeodeBonus == 2 then
		ent:AddBurn(EntityRef(player), 60*secondHand, player.Damage)
	end
end
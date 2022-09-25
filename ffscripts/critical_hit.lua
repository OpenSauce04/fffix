local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.CritDamageMult = 5

function mod:canCritialHit(player)
	return player:HasCollectible(CollectibleType.COLLECTIBLE_IMP_SODA) or player:HasTrinket(FiendFolio.ITEM.ROCK.SODALITE_GEODE)
end

function mod:shouldCriticalHit(player)
	if mod:canCritialHit(player) then
		local extraOdds = 0
		if player:HasCollectible(CollectibleType.COLLECTIBLE_IMP_SODA) then
			extraOdds = extraOdds + 5
			if player:HasTrinket(FiendFolio.ITEM.ROCK.SODALITE_GEODE) then
				extraOdds = extraOdds + 5
			end
		end
		
		local trinketPower, geodeBonus = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SODALITE_GEODE)
		if geodeBonus then
			trinketPower = trinketPower * 1.5
		end
		if trinketPower > 0 then
			extraOdds = extraOdds + 5 * (trinketPower - 1)
		end
		
		local ImpSodaOdds = (30 - math.floor(player.Luck * 2) - math.ceil(extraOdds))
		return math.random(math.max(3, ImpSodaOdds)) == 1
	end
	return false
end

function mod:doCriticalHitFx(pos, target, source)
	sfx:Play(mod.Sounds.ImpSodaCrit,0.8,0,false,math.random(80,120)/100)
	local crit = Isaac.Spawn(1000, 1734, 0, pos + Vector(0,1), nilvector, source):ToEffect()
	crit.SpriteOffset = Vector(0, -15)
	crit:Update()
	if target and not (target.Type == EntityType.ENTITY_BEAST and (target.Variant == 10 or target.Variant == 20 or target.Variant == 30 or target.Variant == 40)) then
		target:BloodExplode()
	end
	game:ShakeScreen(6)
end

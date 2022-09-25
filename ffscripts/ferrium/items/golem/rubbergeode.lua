local mod = FiendFolio
local sfx = SFXManager()

function mod:rubberGeodeOnFireTear(player, tear, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.RUBBER_GEODE) then
		local geode = 0
		if mod.HasTwoGeodes(player) then
			geode = 1
		end
	
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.RUBBER_GEODE)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.RUBBER_GEODE)
		local chance = 10+5*mult+(2*player.Luck)+15*geode
		
		if rng:RandomInt(100) < math.min(chance, 50) then
			local data = tear:GetData()

			data.ApplyBruise = true
			data.ApplyBruiseDuration = 100 * secondHandMultiplier
			data.ApplyBruiseStacks = 1
			data.ApplyBruiseDamagePerStack = 1
			data.fakeKnockbackApply = 10+15*geode
			data.customTearSplat = "gfx/projectiles/tear_tennis_splat.png"
			data.makeSplat = 12
			
			local sprite = tear:GetSprite()
			if tear.Variant ~= 0 then
				tear:ChangeVariant(0)
			end
			local anim = sprite:GetAnimation()
			local scale = tear.Scale
			data.scaleSplat = scale
			tear:ChangeVariant(40)
			tear.Scale = scale/2
			sprite:Load("gfx/002.000_tear.anm2")
			sprite:ReplaceSpritesheet(0, "gfx/projectiles/tear_tennis.png")
			sprite:LoadGraphics()
			sprite:Play(anim, true)
			data.customTearSpritesheet = "gfx/projectiles/tear_tennis.png"
			
			tear:AddTearFlags(TearFlags.TEAR_BOUNCE)

			if not tear:HasTearFlags(BitSet128(0, 1 << (127 - 64))) then
				tear.Velocity = tear.Velocity * (1.25+0.5*geode)
				sfx:Play(mod.Sounds.TennisHit, 1, 0, false, math.random(90,110)/100)
			end
		end
	end
end


mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flags, source, cooldown)
	if source and source.Type == 2 then
		if entity:GetData().fakeKnockbackApply then
			entity:GetData().fakeKnockbackEffect = true
			entity:GetData().fakeKnockbackData = {(entity.Position-source.Position):Resized(entity:GetData().fakeKnockbackApply), 5, 5,}
		end
	end
end)
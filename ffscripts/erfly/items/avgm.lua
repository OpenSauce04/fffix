local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.AVGMTargets = {10212, 22450, 49148, 107175}

function mod:incrementAVGM(player, spawnEnt, isLocust)
	local d = player:GetData().ffsavedata
	--Init
	d.AVGMnext = d.AVGMnext or 2
	d.AVGMuses = d.AVGMuses or 0
	d.AVGMoveralluses = d.AVGMoveralluses or 0
	d.AVGMTarget = d.AVGMTarget or 1

	d.AVGMuses = d.AVGMuses + 1
	d.AVGMoveralluses = d.AVGMoveralluses + 1

    if isLocust then
        if d.AVGMoveralluses % 2 == 1 then
            sfx:Play(mod.Sounds.LightSwitch,0.5,0,false,0.9)
        else
            sfx:Play(mod.Sounds.LightSwitch,0.5,0,false,1.1)
        end
    else
        if d.AVGMoveralluses % 2 == 1 then
            game:Darken(1,1000)
            sfx:Play(mod.Sounds.LightSwitch,1,0,false,0.9)
        else
            game:Darken(0,1)
            sfx:Play(mod.Sounds.LightSwitch,1,0,false,1.1)
        end
    end

	local finaltarget = mod.AVGMTargets[math.min(d.AVGMTarget, 4)]
	if d.AVGMTarget > 4 then
		finaltarget = mod.AVGMTargets[4] * (2 * (d.AVGMTarget - 4))
	end
	if d.AVGMoveralluses >= finaltarget then
		Isaac.Spawn(5,100,0,spawnEnt.Position+RandomVector()*40,spawnEnt.Velocity,player)
		d.AVGMoveralluses = 0
		d.AVGMuses = 0
		d.AVGMTarget = d.AVGMTarget + 1
		d.AVGMnext = (2 * d.AVGMTarget)
        if not isLocust then
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
                player:UseActiveItem(CollectibleType.COLLECTIBLE_LEMEGETON)
            end
        end
	else
		if d.AVGMuses >= d.AVGMnext then
			if d.AVGMuses > 82 then
				Isaac.Spawn(5,20,1,spawnEnt.Position+RandomVector()*40,spawnEnt.Velocity,player)
			else
				if math.random(10) == 1 then
					Isaac.Spawn(5,0,2,spawnEnt.Position+RandomVector()*40,spawnEnt.Velocity,player)
				else
					Isaac.Spawn(5,20,1,spawnEnt.Position+RandomVector()*40,spawnEnt.Velocity,player)
				end
			end

            if not isLocust then
                if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
                    player:AddWisp(CollectibleType.COLLECTIBLE_AVGM, player.Position)
                    sfx:Play(SoundEffect.SOUND_CANDLE_LIGHT, 1, 0, false, 1)
                end
                if mod:playerIsBelialMode(player) then
                    player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL, true, false, true, true)
                    player:SetColor(Color(1,1,1,1,5,0,0), 10, 1, true, true)

                    --Cool ring
                    local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_ATTRACT, 10, player.Position, nilvector, player):ToEffect()
                    eff.MinRadius = 1
                    eff.MaxRadius = 15
                    eff.LifeSpan = 10
                    eff.Timeout = 10
                    eff.SpriteOffset = Vector(0, -15)
                    eff.Color = Color(1,1,1,1,1,0,0)
                    eff.Visible = false
                    eff:FollowParent(player)
                    eff:Update()
                    eff.Visible = true
                end
            end
		d.AVGMnext = d.AVGMnext + (2 * d.AVGMTarget)
		d.AVGMuses = 0
		end
	end
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, typ, rng, player)
    mod:incrementAVGM(player, player, isLocust)
	return true
end, CollectibleType.COLLECTIBLE_AVGM)

function mod:avgmLocustAI(locust)
	local d = locust:GetData()
    local player = locust.Player
    local sd = player:GetData().ffsavedata
    if sd.AVGMoveralluses and sd.AVGMoveralluses % 2 == 1 then
        d.Lit = false
    else
        d.Lit = true
    end
	if locust.FireCooldown == -1 then
		if not d.currentlyCharging then
			d.currentlyCharging = true
		end
	else
		if d.currentlyCharging then
            mod:incrementAVGM(player, locust, true)
            d.currentlyCharging = false
		end
	end

	if d.Lit then
		locust.Color = Color(3,3,3,1)
	else
		locust.Color = mod.ColorNormal
	end
end
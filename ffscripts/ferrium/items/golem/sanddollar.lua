local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, trinket)
	if trinket.SubType % 32768 == FiendFolio.ITEM.ROCK.SAND_DOLLAR and trinket.Touched == true then
		local sprite = trinket:GetSprite()
		local room = game:GetRoom()
		if room:GetType() == RoomType.ROOM_SHOP then
			if sprite:IsEventTriggered("DropSound") then
				if sfx:IsPlaying(SoundEffect.SOUND_SCAMPER) then sfx:Stop(SoundEffect.SOUND_SCAMPER) end
				for i=0,6 do
					Isaac.Spawn(1000, EffectVariant.COIN_PARTICLE, 0, trinket.Position, RandomVector()*math.random(1,6), trinket)
				end
				for i = 30, 360, 40 do
					local expvec = Vector(0,math.random(10,35)):Rotated(i+math.random(-10,10))
					local sparkle = Isaac.Spawn(1000, 1727, 0, trinket.Position + expvec * 0.1, expvec * 0.2, trinket):ToEffect()
					sparkle.SpriteOffset = Vector(0,-7)
					sparkle.SpriteScale = Vector(0.8, 0.8)
					sparkle:SetColor(Color(1,1,1,1,1,1,0), 100, 1, false, false)
					sparkle:Update()
				end
				local rng = RNG()
				rng:SetSeed(trinket.InitSeed, 0)
				if trinket.SubType > 32768 then
					sfx:Play(SoundEffect.SOUND_CASH_REGISTER, 1, 0, false, 1)
					for i=1,3+rng:RandomInt(3) do
						Isaac.Spawn(5, 20, 7, trinket.Position, RandomVector()*(rng:RandomInt(5)+3), trinket)
					end
					trinket:Remove()
				else
					Isaac.Spawn(1000, 15, 0, trinket.Position, Vector.Zero, trinket)
					sfx:Play(SoundEffect.SOUND_CASH_REGISTER, 1, 0, false, 1)
					for i=1,2 do
						Isaac.Spawn(5, 20, 2, trinket.Position, RandomVector()*(rng:RandomInt(5)+3), trinket)
					end
					for i=1,rng:RandomInt(11) do
						Isaac.Spawn(5, 20, 0, trinket.Position, RandomVector()*(rng:RandomInt(5)+3), trinket)
					end
					trinket:Remove()
				end
			end
		end
	end
end, PickupVariant.PICKUP_TRINKET)
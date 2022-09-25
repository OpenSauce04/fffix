local mod = FiendFolio
local sfx = SFXManager()
local game = Game()
local dog = false -- Dead: ???

function mod:maxFossilNewRoom()
	local room = game:GetRoom()
	if mod.anyPlayerHas(FiendFolio.ITEM.ROCK.MAXS_FOSSIL, true) then
		if not mod.anyPlayerHas(CollectibleType.COLLECTIBLE_DOG_TOOTH) then
			local doors = {}
			for i = 0, 8 do
				local d = room:GetDoor(i)
				if d then
					if d:GetVariant() == DoorVariant.DOOR_HIDDEN then
						sfx:Play(SoundEffect.SOUND_DOG_HOWELL, 1, 40, false, 1)
					end
				end
			end
		end
	end
	for i = 1, game:GetNumPlayers() do
        local p = Isaac.GetPlayer(i - 1)
		local data = p:GetData()
		
		if data.ffsavedata.RunEffects.storedDogsHowls and data.ffsavedata.RunEffects.storedDogsHowls > 0 then
			for _,grid in ipairs(mod.GetGridEntities()) do
				if grid:GetType() == GridEntityType.GRID_ROCKT or grid:GetType() == GridEntityType.GRID_ROCK_SS then
					data.ffsavedata.RunEffects.storedDogsHowls = data.ffsavedata.RunEffects.storedDogsHowls-1
					sfx:Play(SoundEffect.SOUND_DOG_HOWELL, 1, 40, false, 1)
					Isaac.Spawn(mod.FF.MaxFossilGhost.ID, mod.FF.MaxFossilGhost.Var, mod.FF.MaxFossilGhost.Sub, grid.Position, Vector.Zero, nil)
				end
			end
		end
		--[[for _,grid in ipairs(mod.GetGridEntities()) do
			if grid:GetType() == GridEntityType.GRID_WALL or grid:GetType() == GridEntityType.GRID_DOOR then
			else
				Isaac.Spawn(mod.FF.MaxFossilGhost.ID, mod.FF.MaxFossilGhost.Var, mod.FF.MaxFossilGhost.Sub, grid.Position, Vector.Zero, nil)
				sfx:Play(SoundEffect.SOUND_DOG_BARK, 0.6, 0, false, math.random(9,15)/10)
				dog = true
			end
		end]]
	end
end

mod.DogPictures = {
	"originalDog",
	"unknown",
	"milkdog",
	"spaghettidog",
	"borzoi",
	"8bitdoordog",
	"cosplaydog",
	"weirdpigdog",
	"smilingstaircasedog",
	"dewford",
	"dogthatdoesntlikeicecream",
	"glassdistortiondog",
	"brickdog",
	"thatpoorjaildog",
	"dollareatingdog",
	"bipedaldog",
	"pepsidog",
	"swimmingdog",
	"hybriddog",
	"dogjones",
	"fooddog",
	"backpackdog",
	"backpackdogparent",
	"attackdog",
	"sacreddog",
	"kineticdog",
	"hotdogsquared",
	"suckydog",
	"dogeatingdog",
	"noodledog",
	"paradedog",
	"traindog",
	"nailbitingdog",
	"raincoatdog",
	"catloverdog",
	"bagdog",
	"existentialdog",
	"kilburnloverdog",
	"wetdog",
	"dogmadeoutofwooddog",
	"pizzadog",
	"girldog",
	"lightdog",
	"artsydog",
	"minecraftdog",
	"fishdog",
	"rockdog",
	"bananadog",
	"dogthathastogrowup",
	"chernobyldog",
	"sputteringhound",
	"erfkitty",
	"erfruby",
	"erfrubydroplets",
	"erffrisbeefight",
	"spookydog",
	"gangsta1",
	"gangsta2",
	"flowerdog",
	"taigacharlieroar",
	"taigacharlieboots",
	"taigacharliedoor",
	"taigacharliecar",
	"boniasnooze",
	"boniasilly",
	"boniastare",
	"spinydog",
	"walldog",
	"chairdog",
	"fluffdog",
	"pizzaretriever",
	"pizzapug1",
	"pizzapug2",
	"dogporthos",
	"dogalien",
	"dogalienevil",
	"ohyoudog",
	"homophobicdog",
	"komondordog",
	"bedlingtondog",
	"pulidog",
	"linustechtipdog",
	"swingdog",
	"loafdog",
	"chowchowdog",
	"frogdog",
	"humandog",
	"birthdaydog",
	"ptsddog",
	"beedog",
	"beeretriever",
	"spacedog",
	"iggyboots",
	"romanticdog",
	"advicedog",
	"investigativedog",
	"dancingdog",
	"kegdog",
	"minecraftdogbutreal",
}

function mod:dogFossilEffect(e)
	local sprite = e:GetSprite()
	local data = e:GetData()
	local rng = e:GetDropRNG()
	if not data.init then
		local dog = rng:RandomInt(#mod.DogPictures)+1
		sprite:ReplaceSpritesheet(0, "gfx/effects/dogs/" .. mod.DogPictures[dog] .. ".png")
		sprite:LoadGraphics()
		data.init = true
	end
	
	if sprite:IsFinished("ghosty") then
		e:Remove()
	end
end

--[[mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	if not sfx:IsPlaying(SoundEffect.SOUND_DOG_BARK) and dog == true then
		sfx:Play(SoundEffect.SOUND_DOG_BARK, 0.6, 0, false, math.random(11,15)/10)
		sfx:Play(SoundEffect.SOUND_DOG_BARK, 0.6, 0, false, math.random(11,15)/10)
	end
end)

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
	Isaac.Spawn(1000,1750,9, npc.Position, Vector.Zero, nil)
	npc:Remove()
end)]]
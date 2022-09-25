local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local frogPuppet = mod.ITEM.TRINKET.FROG_PUPPET
local tatteredPuppet = mod.ITEM.TRINKET.TATTERED_FROG_PUPPET

-- Priority:
--[[
	Held Golden Frog Puppet
	Held Frog Puppet
	Held Tattered Frog Puppet
	Smelted Golden Frog Puppet
	Smelted Frog Puppet
	Smelted Tattered Frog Puppet
]]

function mod.CanPlayerReviveWithFrogPuppet(player)
	return player:GetTrinketMultiplier(mod.ITEM.TRINKET.FROG_PUPPET) + player:GetTrinketMultiplier(mod.ITEM.TRINKET.TATTERED_FROG_PUPPET) > 0
end

function mod.DowngradeFrogPuppet(player)
	mod.DowngradeTrinket(player, frogPuppet, tatteredPuppet)
end

function mod.DoFrogPuppetRevive(player)
	local oldPlayerType = player:GetPlayerType()
	local alreadySlippy = oldPlayerType == mod.PLAYER.SLIPPY
	local expectedBrokens = mod.GetExpectedBrokenHeartsFromDamage(player)

	mod.DowngradeFrogPuppet(player)
	
	if not alreadySlippy then
		player:ChangePlayerType(mod.PLAYER.SLIPPY)
		player:ClearCostumes()

		player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_FROG_HEAD, ActiveSlot.SLOT_POCKET)
		mod.UniversalRemoveItemFromPools(CollectibleType.COLLECTIBLE_FROG_HEAD)
	end

	if oldPlayerType == mod.PLAYER.CHINA then
		player:AddBrokenHearts(-6)
	elseif player:GetBrokenHearts() + expectedBrokens >= 12 then
		player:AddBrokenHearts(-(player:GetBrokenHearts() + expectedBrokens) + 12)
	end

	player:AddMaxHearts(6 - player:GetMaxHearts())
	player:AddBoneHearts(-player:GetBoneHearts())
	player:AddSoulHearts(-player:GetSoulHearts())
	player:AddRottenHearts(-player:GetRottenHearts())
	player:AddHearts(-99) -- clearing out custom hp
	player:AddHearts(6)

	game:Fart(player.Position, 80, player, 1, 0)
	for i = 45, 360, 45 do
		game:Fart(player.Position + Vector(40, 0):Rotated(i), 80, player, 1, 0)
	end

	game:ButterBeanFart(player.Position, 280, player, false)
	game:ShakeScreen(50)
	sfx:Play(mod.Sounds.FartFrog4, 1, 0, false, math.random(90,110)/100)
	sfx:Stop(SoundEffect.SOUND_FART)

	mod.scheduleForUpdate(function()
		player:AddHearts(99) -- Absorb the current hit without cancelling the damage
	end, 1)
end
local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)
	familiar.IsFollower = true
	familiar:GetData().rooms = 0
end, mod.ITEM.FAMILIAR.SACK_OF_SPICY)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local data = familiar:GetData()
	local sprite = familiar:GetSprite()
	data.rooms = data.rooms or 0
	if not data.init then

	end
	local payoutNum = 7
	local payoutSub = FiendFolio.PICKUP.KEY.SPICY_PERM
	if Sewn_API then
		if Sewn_API:IsUltra(data) then
			payoutNum = 3
		elseif Sewn_API:IsSuper(data) then
			payoutNum = 5
		end
	end
	if familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
		payoutSub = FiendFolio.PICKUP.KEY.SUPERSPICY_PERM
	end
	if data.rooms >= payoutNum then
		sprite:Play("Spawn", false)
        local key = Isaac.Spawn(5, 30, payoutSub, familiar.Position, nilvector, familiar)
		data.rooms = 0
	end
	if sprite:IsFinished("Spawn") then
		sprite:Play("FloatDown", false)
	end
	familiar:FollowParent()
end, mod.ITEM.FAMILIAR.SACK_OF_SPICY)

function mod:spicyBagRoomClear()
	for _, d in pairs(Isaac.FindByType(3, mod.ITEM.FAMILIAR.SACK_OF_SPICY, -1, false, false)) do
		local data = d:GetData()
		data.rooms = data.rooms or 0
		data.rooms = data.rooms + 1
	end
end
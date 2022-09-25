-- Bridge Bombs --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:bridgeBombsPostFireBomb(player, bomb)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.BRIDGE_BOMBS) then
		bomb:GetData().FFBridgeBomb = true
		bomb:GetData().FFBridgeBombMega = player:HasCollectible(CollectibleType.COLLECTIBLE_MR_MEGA) and bomb.Variant ~= BombVariant.BOMB_SMALL
	end
end

function mod:bridgeBombsPostFireRocket(player, rocket)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.BRIDGE_BOMBS) then
		rocket:GetData().FFBridgeBomb = true
		rocket:GetData().FFBridgeBombMega = player:HasCollectible(CollectibleType.COLLECTIBLE_MR_MEGA)
	end
end

-- https://www.geeksforgeeks.org/check-if-any-point-overlaps-the-given-circle-and-rectangle/
local function gridInRadius(grid, pos, radius)
	local x1 = grid.Position.X - 20
	local x2 = grid.Position.X + 20
	local y1 = grid.Position.Y - 20
	local y2 = grid.Position.Y + 20
	
    local xn = math.max(x1, math.min(pos.X, x2))
    local yn = math.max(y1, math.min(pos.Y, y2))
	
    local dx = xn - pos.X
    local dy = yn - pos.Y
	
    return (dx ^ 2 + dy ^ 2) <= radius ^ 2
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, explosion)
	local room = game:GetRoom()
	if explosion.SpawnerEntity and 
	   explosion.SpawnerEntity:GetData().FFBridgeBomb and 
	   not (room:GetType() == RoomType.ROOM_BOSS and room:GetBossID() == 55) 
	then
		local explosionRadius = 75
		if explosion.SpawnerEntity:ToBomb() then
			local bomb = explosion.SpawnerEntity:ToBomb()
			explosionRadius = 75 * bomb.RadiusMultiplier
			if bomb.Variant == BombVariant.BOMB_GIGA or 
			   bomb.Variant == BombVariant.BOMB_ROCKET_GIGA or 
			   bomb.Flags & BitSet128(0,1<<(119 - 64)) == BitSet128(0,1<<(119 - 64)) 
			then
				explosionRadius = 130 * bomb.RadiusMultiplier
			elseif bomb.Variant == BombVariant.BOMB_BIG or explosion.SpawnerEntity:GetData().FFBridgeBombMega then
				explosionRadius = 105 * bomb.RadiusMultiplier
			end
		end
		
		local madeBridge = false
		for x = math.ceil(explosionRadius / 40) * -1, math.ceil(explosionRadius / 40) do
			for y = math.ceil(explosionRadius / 40) * -1, math.ceil(explosionRadius / 40) do
				local grid = room:GetGridEntityFromPos(Vector(explosion.Position.X + 40 * x, explosion.Position.Y + 40 * y))
				if grid and grid:ToPit() then
					local pit = grid:ToPit()
					if gridInRadius(pit, explosion.Position, explosionRadius) then
						pit:MakeBridge(nil)
						madeBridge = true
					end
				end
			end
		end
		
		if madeBridge then
			sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 1.0, 0, false, 1.0)
		end
	end
end, EffectVariant.BOMB_EXPLOSION)

FiendFolio.AddItemPickupCallback(function(player, added)
	player:AddBombs(5)
end, nil, FiendFolio.ITEM.COLLECTIBLE.BRIDGE_BOMBS)

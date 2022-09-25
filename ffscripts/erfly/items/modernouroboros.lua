local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:modernOuroborosPostFireTear(player, tear, rng, pdata, tdata, ignorePlayerEffects, isLudo) 
	if player:HasCollectible(mod.ITEM.COLLECTIBLE.MODERN_OUROBOROS) and
	   not ignorePlayerEffects
	then
		tear:GetData().leavePowderCreep = true
		if isLudo then
			tear:GetData().hasSpawnedPowderCreep = false
		else
			for i = -30, 30, 30 do
				local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, tear.Position, tear.Velocity:Resized(10):Rotated(i), npc)
				--smoke.SpriteScale = Vector(1,1)
				smoke.SpriteOffset = Vector(0, -10)
				smoke:Update()
			end
		end
	end
end

local function temptearflagthing(x) -- because the one in enums.lua is broke
	return x >= 64 and BitSet128(0,1<<(x - 64)) or BitSet128(1<<x,0)
end

function mod:modernOuroborosTearDamage(tear, data)
    if data.leavePowderCreep and tear.TearFlags & temptearflagthing(127) == temptearflagthing(127) and not data.hasSpawnedPowderCreep then
        mod.SpawnGunpowder(Isaac.GetPlayer(0),Game():GetRoom():GetClampedPosition(tear.Position, 0), 120, 120, nil, nil, true, FiendFolio.ColorModernOuroboros)
        data.hasSpawnedPowderCreep = true
    end
end

function mod:modernOuroborosPostTearRemove(tear,data)
    if data.leavePowderCreep then
		mod.SpawnGunpowder(Isaac.GetPlayer(0),Game():GetRoom():GetClampedPosition(tear.Position, 0), 120, 120, nil, nil, true, FiendFolio.ColorModernOuroboros)
	end
end

function mod:modernOuroPostFireBomb(player, bomb, rng, pdata, bdata)
	if player:HasCollectible(mod.ITEM.COLLECTIBLE.MODERN_OUROBOROS) then
		bdata.leavePowderCreep = true
	end
end

function mod:modernOuroborosPostBombUpdate(bomb, data)
	if bomb:IsDead() then
		if data.leavePowderCreep then
			mod.SpawnGunpowder(Isaac.GetPlayer(0),Game():GetRoom():GetClampedPosition(bomb.Position, 0), 120, 120, nil, nil, true, FiendFolio.ColorModernOuroboros)
		end
	end
end

function mod:modernOuroOnRocketFire(player, target)
	if player:HasCollectible(mod.ITEM.COLLECTIBLE.MODERN_OUROBOROS) then
		target:GetData().leavePowderCreep = true
	end
end

function mod:modernOuroOnRocketExplosion(explosion, rocket)
	if rocket:GetData().leavePowderCreep then
		mod.SpawnGunpowder(Isaac.GetPlayer(0),Game():GetRoom():GetClampedPosition(explosion.Position, 0), 120, 120, nil, nil, true, FiendFolio.ColorModernOuroboros)
	end
end

--Laser, Knife, Dark arts
function mod:modernOuroOnGenericDamage(player, entity)
	if player:HasCollectible(mod.ITEM.COLLECTIBLE.MODERN_OUROBOROS) then
		if not entity:GetData().spawnedModernOuroCreepLately then
			entity:GetData().spawnedModernOuroCreepLately = 30
			mod.SpawnGunpowder(Isaac.GetPlayer(0),Game():GetRoom():GetClampedPosition(entity.Position, 0) + RandomVector():Resized(math.random(entity.Size)), 120, 120, nil, nil, true, FiendFolio.ColorModernOuroboros)
		end
	end
end

function mod:modernOuroOnLocustDamage(player, locust, entity)
	if not entity:GetData().spawnedModernOuroCreepLately then
		entity:GetData().spawnedModernOuroCreepLately = 30
		mod.SpawnGunpowder(Isaac.GetPlayer(0),Game():GetRoom():GetClampedPosition(entity.Position, 0) + RandomVector():Resized(math.random(entity.Size)), 120, 120, nil, nil, true, FiendFolio.ColorModernOuroboros)
	end
end

function mod:modernOuroEntityUpdate(npc, data)
	if data.spawnedModernOuroCreepLately then
		data.spawnedModernOuroCreepLately = data.spawnedModernOuroCreepLately - 1
		if data.spawnedModernOuroCreepLately <= 0 then
			data.spawnedModernOuroCreepLately = nil
		end
	end
end
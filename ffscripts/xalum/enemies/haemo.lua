local mod = FiendFolio
local sfx = SFXManager()
local game = Game()

local haemoCache
local friendlyHaemoCache

local function IsBlacklisted(npc)
	for _, data in pairs(mod.HaemoBlacklist) do
		if data[1] == npc.Type and (data[2] == npc.Variant or data[2] == -1) and (data[3] == npc.SubType or data[3] == -1) then
			return true
		end
	end
end

local function CacheHaemos(returnFriendly)
	haemoCache = Isaac.FindByType(mod.FF.Haemo.ID, mod.FF.Haemo.Var, -1)
	friendlyHaemoCache = Isaac.FindByType(mod.FF.Haemo.ID, mod.FF.Haemo.Var, -1, false, true)

	return returnFriendly and friendlyHaemoCache or haemoCache
end

local function GetHaemos() return haemoCache or CacheHaemos() end
local function GetFriendlyHaemos() return friendlyHaemoCache or CacheHaemos(true) end

local function UniqueHaemoExists(npc)
	local haemos = #GetHaemos()
	if npc.Type == mod.FF.Haemo.ID and npc.Variant == mod.FF.Haemo.Var then
		haemos = haemos - 1
	end

	return haemos > 0
end

local function ShouldEntityRevive(npc)
	return (
		UniqueHaemoExists(npc) and
		not (npc.SpawnerEntity or npc.SpawnerType ~= 0) and
		npc:GetChampionColorIdx() ~= 12 and
		not IsBlacklisted(npc) and
		not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)	
	)
end

local function ShouldHaemoGlobinBeFriendly()
	local allHaemos = #GetHaemos()
	local noFriendlies = #GetFriendlyHaemos()

	return allHaemos > noFriendlies
end

mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
	if ShouldEntityRevive(npc) then
		local globin = Isaac.Spawn(mod.FF.HaemoGlobin.ID, mod.FF.HaemoGlobin.Var, 0, npc.Position, Vector.Zero, npc)
		local globinData = globin:GetData()
		globinData.fiendfolio_respawnData = {
			npc.Type,
			npc.Variant,
			npc.SubType,
		}

		local haemos = GetHaemos()
		local myHaemo = haemos[math.random(#haemos)]
		local indicatorBeam = Isaac.Spawn(1000, 175, 0, myHaemo.Position, Vector.Zero, myHaemo):ToEffect()
		indicatorBeam.Parent = myHaemo
		indicatorBeam.Target = globin
		indicatorBeam.Color = Color(1, 0, 0, 1)
		indicatorBeam.DepthOffset = -1000
		indicatorBeam.Timeout = 25

		sfx:Play(SoundEffect.SOUND_BISHOP_HIT)

		if ShouldHaemoGlobinBeFriendly() then
			globin:AddCharmed(EntityRef(Isaac.GetPlayer()), -1)
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	haemoCache = nil
	friendlyHaemoCache = nil
end)

return {
	Init = function(npc)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)

		local sprite = npc:GetSprite()
		local room = game:GetRoom()
		local facingDirection = room:GetCenterPos() - npc.Position
		sprite.FlipX = facingDirection.X < 0

		local data = npc:GetData()
		data.shootCooldown = 0
		data.params = ProjectileParams()
		data.params.FallingAccelModifier = 1
		data.params.FallingSpeedModifier = 3
	end,

	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if sprite:IsFinished() then
			sprite:Play("Idle")
		end

		if sprite:IsEventTriggered("Shoot") then
			sprite.FlipX = data.retaliationTarget.Position.X < npc.Position.X

			local fireDirection = (data.retaliationTarget.Position - npc.Position):Normalized()
			local positionOffset = fireDirection * 40
			for i = 1, 3 do
				mod.XalumSchedule(i * 2, function()
					local creep = Isaac.Spawn(1000, 22, 0, npc.Position + positionOffset * i - positionOffset / 2, Vector.Zero, npc):ToEffect()
					creep.SpriteScale = creep.SpriteScale * i / 1.5
					creep.Timeout = 60 - i * 2
					creep:Update()

					local poof = Isaac.Spawn(1000, 2, 2, creep.Position, Vector.Zero, creep)
					poof.SpriteScale = creep.SpriteScale
				end)
			end

			local poof = Isaac.Spawn(1000, 2, 2, npc.Position, Vector.Zero, npc)
			poof.SpriteOffset = Vector(0, -20)
			poof.DepthOffset = 15

			npc:FireBossProjectiles(12, npc.Position + fireDirection * 80, 0, data.params)
			sfx:Play(SoundEffect.SOUND_MONSTER_GRUNT_4)
		end

		npc.Velocity = npc.Velocity * 0.6
		mod.QuickSetEntityGridPath(npc)
	end,

	Damage = function(npc, amount, _, source)
		local data = npc:GetData()
		if data.shootCooldown and data.shootCooldown < npc.FrameCount and amount < npc.HitPoints then
			local realSource = mod.XalumFindRealEntity(source) or npc:GetPlayerTarget()

			if realSource.Type == 2 then realSource = realSource.SpawnerEntity end

			data.shootCooldown = npc.FrameCount + 90
			data.retaliationTarget = realSource or npc:GetPlayerTarget()

			npc:GetSprite():Play("Shoot")
			sfx:Play(SoundEffect.SOUND_MONSTER_GRUNT_5, 1, 0, false, 0.7)
		end
	end,
}
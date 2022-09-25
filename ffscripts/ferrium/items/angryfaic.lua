local mod = FiendFolio
local game = Game()

local angryFaicBlacklist = {
	[407] = true,
	[406] = true,
	[412] = true,
	[102 .. " " .. 1] = true,
	[273] = true,
	[950] = true,
	[951] = true,
	[912] = true,
	[274] = true,
	[907] = true,
}

function mod:angryFaicNewRoom()
	local level = game:GetLevel()
	local room = game:GetRoom()
	if room:GetType() == RoomType.ROOM_BOSS or room:GetType() == RoomType.ROOM_MINIBOSS and not room:IsClear() then
		for i = 1, game:GetNumPlayers() do
			local player = Isaac.GetPlayer(i-1)
			if player:HasTrinket(FiendFolio.ITEM.TRINKET.ANGRY_FAIC) then
				local mult = player:GetTrinketMultiplier(FiendFolio.ITEM.TRINKET.ANGRY_FAIC)
				for _,ent in ipairs(Isaac.GetRoomEntities()) do
					local npc = ent:ToNPC()
					if npc and npc:IsBoss() then
						if angryFaicBlacklist[npc.Type] or angryFaicBlacklist[npc.Type .. " " .. npc.Variant] then
						else 
							npc.HitPoints = npc.MaxHitPoints*(100+math.min(30, 5+5*mult))/100
							npc:GetData().angryFaicBuffed = mult
							npc:GetData().angryFaicNotification = true
							table.insert(mod.angryFaicedBosses, {["npc"] = npc, ["mult"] = mult})
						end
					end
				end
			end
		end
	--elseif room:GetType() == RoomType.ROOM_SECRET or room:GetType() == RoomType.ROOM_SHOP and not room:IsClear() then
	end
end

function mod:angryFaicNPCUpdate(npc)
	local data = npc:GetData()
	--[[if npc:IsBoss() and npc:IsDead() then
		if data.angryFaicBuffed then
			local rng = npc:GetDropRNG()
			if room:GetAliveBossesCount() <= 1 then
				for i=1,data.angryFaicBuffed do
					local dropNum = rng:RandomInt(100)
					if dropNum < 33 then
						Isaac.Spawn(5, 10, 0, npc.Position, Vector(0,rng:RandomInt(3,5)):Rotated(rng:RandomInt(360)), npc)
					else
						local rhn = rng:RandomInt(100)
						if rhn < 50 then
							Isaac.Spawn(5, 10, 1, npc.Position, Vector(0,rng:RandomInt(3,5)):Rotated(rng:RandomInt(360)), npc)
						elseif rhn < 75 then
							Isaac.Spawn(5, 10, 2, npc.Position, Vector(0,rng:RandomInt(3,5)):Rotated(rng:RandomInt(360)), npc)
						elseif rhn < 85 then
							Isaac.Spawn(5, 10, 9, npc.Position, Vector(0,rng:RandomInt(3,5)):Rotated(rng:RandomInt(360)), npc)
						elseif rhn < 95 then
							Isaac.Spawn(5, 10, 5, npc.Position, Vector(0,rng:RandomInt(3,5)):Rotated(rng:RandomInt(360)), npc)
						else
							Isaac.Spawn(5, 10, 12, npc.Position, Vector(0,rng:RandomInt(3,5)):Rotated(rng:RandomInt(360)), npc)
						end
					end
				end
			end
			data.angryFaicBuffed = nil
		end
	end]]
	
	if data.angryFaicNotification and npc.FrameCount > 0 then
		local poof = Isaac.Spawn(1000, 49, 0, npc.Position, Vector.Zero, npc):ToEffect()
		poof.SpriteOffset = Vector(0, -30 + npc.Size * -1.0)
		poof:FollowParent(npc)
		poof.DepthOffset = 5
		poof:Update()
		SFXManager():Play(SoundEffect.SOUND_VAMP_GULP, 1, 0, false, 1)
		data.angryFaicNotification = nil
	end
end
	
function mod:checkForAngryFaicDeath(entry, key)
	local npc = entry.npc
	local mult = entry.mult
	if not npc:Exists() then
		local data = npc:GetData()
		if mult then
			local rng = npc:GetDropRNG()
			local room = game:GetRoom()
			if room:GetAliveBossesCount() == 0 then
				SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_SMALL, 2, 0, false, 2)
				local poof = Isaac.Spawn(1000, 16, 4, npc.Position, Vector.Zero, npc):ToEffect()
				poof.SpriteScale = Vector(0.7,0.7)
				poof.Color = npc.SplatColor
				for i=1,5 do
					local gib = Isaac.Spawn(1000, 5, 0, npc.Position, RandomVector()*math.random(2,6), npc):ToEffect()
					gib.Color = npc.SplatColor
				end
				for i=1,mult do
					local dropNum = rng:RandomInt(100)
					if dropNum < 33 then
						Isaac.Spawn(5, 10, 0, npc.Position, Vector(0,rng:RandomInt(3,5)):Rotated(rng:RandomInt(360)), npc)
					else
						local rhn = rng:RandomInt(100)
						if rhn < 50 then
							Isaac.Spawn(5, 10, 1, npc.Position, Vector(0,rng:RandomInt(3,5)):Rotated(rng:RandomInt(360)), npc)
						elseif rhn < 75 then
							Isaac.Spawn(5, 10, 2, npc.Position, Vector(0,rng:RandomInt(3,5)):Rotated(rng:RandomInt(360)), npc)
						elseif rhn < 85 then
							Isaac.Spawn(5, 10, 9, npc.Position, Vector(0,rng:RandomInt(3,5)):Rotated(rng:RandomInt(360)), npc)
						elseif rhn < 95 then
							Isaac.Spawn(5, 10, 5, npc.Position, Vector(0,rng:RandomInt(3,5)):Rotated(rng:RandomInt(360)), npc)
						else
							Isaac.Spawn(5, 10, 12, npc.Position, Vector(0,rng:RandomInt(3,5)):Rotated(rng:RandomInt(360)), npc)
						end
					end
				end
			end
		end
		mod.angryFaicedBosses[key] = nil
	end
end
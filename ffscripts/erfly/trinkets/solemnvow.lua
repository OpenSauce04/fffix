--Solemn Vow trinket code
--[[FiendFolio.AddTrinketPickupCallback(function(player, added)
	local savedata = Isaac.GetPlayer():GetData().ffsavedata
	if not player:HasCollectible(403,false) then
	 savedata.playerWithVow = player
	 player:AddItemWisp(403,player.Position,false)
	 --RemoveSpider
		for _, spoder in pairs(Isaac.FindByType(3, 94, -1, false, false)) do
		spoder:Remove()
		end
	end
end, function(player, added)
	for _, wisp in ipairs(Isaac.FindByType(3, 237, 403, false, false)) do
		local savedata = wisp:ToFamiliar().Player:GetData().ffsavedata
		if savedata.playerWithVow ~= nil then
		 wisp:Remove()
		 wisp:Kill()
		end
		savedata.playerWithVow = nil
	end
end, TrinketType.TRINKET_SOLEMN_VOW, nil)

--Don't you love when AddCollectibleEffect doesn't actually do what the item does yeepee
--This Makes the wisp invisible
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function(_)
	--AdjustWisp
	local savedata = Isaac.GetPlayer():GetData().ffsavedata
	if savedata.playerWithVow ~= nil then
		for _, wisp in ipairs(Isaac.FindByType(3, 237, 403, false, false)) do
		 wisp.Visible = false
		 wisp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		 wisp.Position = Vector(1900,1900)
		 wisp:ToFamiliar():RemoveFromOrbit()
		end
	end
		 --RemoveSpider
		for _, spoder in pairs(Isaac.FindByType(3, 94, -1, false, false)) do
		spoder:Remove()
		end
end)
--Solemn Vow Code end]]

--Cake originally made this
--THIS WOULD HAVE NO PROBLEMS IF WE COULD JUST ADD ITEM EFFECTS WITHOUT GIVING THE ITEM AAAA

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:solemnVowUpdate(player, d)
    local savedata = d.ffsavedata
    if player:HasTrinket(mod.ITEM.TRINKET.SOLEMN_VOW) and player.FrameCount >= 1 then
        if not d.SolemnVowWisp then
            local foundWisp
            if savedata.SolemnVowWisp then
                local wisps = Isaac.FindByType(3, 237, 403, false, false)
                if #wisps > 0 then
                    local wisp = wisps[1]:ToFamiliar()
                    d.SolemnVowWisp = wisp
                    foundWisp = true
                    wisp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                    wisp:GetData().preventWispFiring = true
                    wisp:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    wisp:RemoveFromOrbit()
                    wisp:Update()
                end
            end
            if not foundWisp then
                local wisp = Isaac.Spawn(3, 237, 403, Vector(-100, -50), nilvector, player):ToFamiliar()
                wisp.Parent = player
                wisp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                wisp:GetData().preventWispFiring = true
                wisp:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                wisp:RemoveFromOrbit()
                wisp:Update()
                d.SolemnVowWisp = wisp
                savedata.SolemnVowWisp = true
            end
        end
    end
    if d.SolemnVowWisp then
        d.SolemnVowWisp.Position = Vector(-100, -50)
        d.SolemnVowWisp.Visible = false
        if not player:HasTrinket(mod.ITEM.TRINKET.SOLEMN_VOW) then
            d.SolemnVowWisp:Remove()
            d.SolemnVowWisp:Kill()
            d.SolemnVowWisp = nil
            savedata.SolemnVowWisp = nil
            
            local tempEffects = player:GetEffects()
            tempEffects:RemoveCollectibleEffect(403, -1)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
    if flag == CacheFlag.CACHE_FAMILIARS then
        if player:HasTrinket(mod.ITEM.TRINKET.SOLEMN_VOW) or player:GetData().SolemnVowWisp then
            local youngestSpoder
            for _, spoder in pairs(Isaac.FindByType(3, 94, -1, false, false)) do
                if player.InitSeed == spoder.SpawnerEntity.InitSeed then
                    --local smoke = mod.FindClosestEntity(spoder.Position, 5, 292, 750)
                    if youngestSpoder then
                        if spoder.FrameCount < youngestSpoder.FrameCount then
                            youngestSpoder = spoder
                        end
                    else
                        youngestSpoder = spoder
                    end
                end
            end
            if youngestSpoder then
                youngestSpoder:Remove()
            end
        end
    end
end)
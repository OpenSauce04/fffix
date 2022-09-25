local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:pesterAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local path = npc.Pathfinder
	local target = npc:GetPlayerTarget()

	if not d.init then
		local eternalfriend = Isaac.Spawn(mod.FF.DeadFlyOrbital.ID, mod.FF.DeadFlyOrbital.Var, 0, npc.Position, nilvector, npc):ToNPC()
			eternalfriend.Parent = npc
			npc.Child = eternalfriend
			eternalfriend:GetData().rotval = math.random(100)
			eternalfriend:Update()
		d.init = true
	end

	if npc.Velocity:Length() > 0.1 then
		if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
			if npc.Velocity.X > 0 then
				mod:spritePlay(sprite, "WalkRight")
			else
				mod:spritePlay(sprite, "WalkLeft")
			end
		else
			mod:spritePlay(sprite, "WalkVert")
		end
	else
		sprite:SetFrame("WalkVert", 0)
	end

	local targetpos = mod:confusePos(npc, target.Position)
	if game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) or mod:isScare(npc) then
		local targetvel = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(4))
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
	else
		path:FindGridPath(targetpos, 0.6, 900, true)
	end
end

function mod:pesterKill(npc, variant)
    if not (npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) or npc:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) or mod:isLeavingStatusCorpse(npc)) then
        local r = npc:ToNPC():GetDropRNG()
        if r:RandomInt(3) == 1 then
            local newvar = 1
            if r:RandomInt(3) == 1 then
                newvar = 0
            end

            local spawned = Isaac.Spawn(11, newvar, variant, npc.Position, npc.Velocity, npc)
            spawned:ToNPC():Morph(spawned.Type, spawned.Variant, spawned.SubType, npc:ToNPC():GetChampionColorIdx())
            spawned.HitPoints = spawned.MaxHitPoints
            spawned:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

            if npc.Child then
                npc.Child.Parent = spawned
            end

            if (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                spawned:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
            end

            npc:Remove()
        end
    end
end
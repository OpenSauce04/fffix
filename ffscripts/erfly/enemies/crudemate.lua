local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--for requirepath pass the npc pathfinder
function mod:findClosestFreeGrate(pos, maxdist, requirepath)
	local choices = {}
	local dist = maxdist or 9999999
	for _, grate in pairs(Isaac.FindByType(mod.FF.Graterhole.ID, mod.FF.Graterhole.Var, -1, false, false)) do
		if not (grate:GetData().occupied) then
			if (not requirepath) or (requirepath and requirepath:HasPathToPos(grate.Position)) then
				local calcDist = pos:Distance(grate.Position)
				if calcDist < dist then
					dist = calcDist
					choices = {grate}
				elseif calcDist == dist then
					table.insert(choices, grate)
					--print("equidist")
				end
			end
		end
	end
	if #choices > 0 then
		return choices[math.random(#choices)]
	end
end

function mod:crudemateAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local path = npc.Pathfinder

	npc.StateFrame = npc.StateFrame + 1
	npc.SplatColor = FiendFolio.ColorDankBlackReal

	if d.state == "venting" then
		if npc.TargetPosition then
			npc.Position = npc.TargetPosition
			npc.Velocity = nilvector
		end
		if sprite:IsFinished("GrateEnter") then
			d.vent:GetData().occupied = nil
			d.vent:Update()
			npc:Remove()
		elseif sprite:IsEventTriggered("Open") then
			sfx:Play(mod.Sounds.SussyOpen, 3)
		elseif sprite:IsEventTriggered("Close") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			sfx:Play(mod.Sounds.SussyClose, 3)
		else
			mod:spritePlay(sprite, "GrateEnter")
		end
	else
		local grate = mod:findClosestFreeGrate(npc.Position, nil, path)
		if grate then
			d.walktarg = nil
			npc.StateFrame = 0
			targetpos = grate.Position
			if game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
				local targetvel = (targetpos - npc.Position):Resized(6)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
			else
				if npc.FrameCount > 0 then
					mod:CatheryPathFinding(npc, targetpos, {
						Speed = 6,
						Accel = 0.25,
						GiveUp = true
					})
				end
			end
			if npc.Position:Distance(targetpos) < 5 then
				grate:GetData().occupied = npc
				d.state = "venting"
				d.vent = grate
				npc.TargetPosition = grate.Position
				mod:spritePlay(sprite, "GrateEnter")
			end
		else
			if npc.StateFrame > 160 or ((not d.walktarg) and npc.StateFrame > 30) then
				d.walktarg = mod:FindRandomValidPathPosition(npc)
				npc.StateFrame = 0
			end
			if d.walktarg and npc.Position:Distance(d.walktarg) > 30 then
				if game:GetRoom():CheckLine(npc.Position,d.walktarg,0,1,false,false) then
					local targetvel = (d.walktarg - npc.Position):Resized(6)
					npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
				else
					mod:CatheryPathFinding(npc, d.walktarg, {
						Speed = 6,
						Accel = 0.25,
						GiveUp = true
					})
				end
			else
				npc.Velocity = npc.Velocity * 0.7
				npc.StateFrame = npc.StateFrame + 2
			end
		end

		if not sprite:IsPlaying("GrateEnter") then
			if npc.Velocity:Length() > 0.5 and npc.FrameCount > 0 then
				mod:spritePlay(sprite, "WalkSussly")
				if npc.Velocity.X < 0 then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end
			else
				sprite:SetFrame("Idleposter", 0)
			end
		end
	end
end
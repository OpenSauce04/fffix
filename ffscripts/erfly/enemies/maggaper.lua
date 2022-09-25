local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:magGaperAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local path = npc.Pathfinder
    local room = game:GetRoom()

	if not d.init then
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	d.walkCycle = d.walkCycle or 0
	local moduloVal = d.walkCycle % 20
	local LerpVal = 0.1
	if moduloVal % 10 == 0 then
		LerpVal = 0.4
	elseif moduloVal % 10 == 7 then
		npc.Velocity = npc.Velocity * 0.9
		npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS,0.3,0,false,(math.random(70,90)+(npc.Velocity:Length()*5))/100)
		local vecOff = npc.Velocity:Rotated(90):Resized(5)
		if moduloVal % 20 == 10 then
			vecOff = vecOff * -1
		end
		local footprint = Isaac.Spawn(1000, 89, 0, npc.Position + vecOff, nilvector, npc)
		footprint.SpriteScale = footprint.SpriteScale * 0.5
		footprint:Update()
	else
		npc.Velocity = npc.Velocity * 0.97
	end


	if npc.FrameCount > 1 and (room:CheckLine(npc.Position,targetpos,0,1,false,false) or mod:isScareOrConfuse(npc)) then
		local speed = mod:reverseIfFear(npc, 8)
		npc.Velocity = mod:Lerp(npc.Velocity, (targetpos - npc.Position):Resized(speed), LerpVal)
		d.walkCycle = d.walkCycle + 1
		if not mod:isScareOrConfuse(npc) then
			d.seenTimer = 60
		end
		d.walktarg = nil
		npc.StateFrame = 0
	else
		d.seenTimer = d.seenTimer or 0
		if d.seenTimer > 0 then
			d.walktarg = nil
			if not room:CheckLine(npc.Position,targetpos,3,1,false,false) then
				d.seenTimer = d.seenTimer - 1
			end
			if path:HasPathToPos(targetpos) then
				--path:FindGridPath(targetpos, 1, 900, true)
				mod:CatheryPathFinding(npc, targetpos, {
					Speed = 8,
					Accel = LerpVal,
					GiveUp = true
				})
				d.walkCycle = d.walkCycle + 1
			else
				d.walkCycle = 0
				d.seenTimer = 0
				npc.StateFrame = 0
			end
		else
			if npc.StateFrame > 160 or ((not d.walktarg) and npc.StateFrame > 30) then
				d.walktarg = mod:FindRandomValidPathPosition(npc)
				npc.StateFrame = 0
			end
			if d.walktarg and npc.Position:Distance(d.walktarg) > 30 then
				d.walkCycle = d.walkCycle + 1
				if room:CheckLine(npc.Position,d.walktarg,0,1,false,false) then
					local targetvel = (d.walktarg - npc.Position):Resized(5)
					npc.Velocity = mod:Lerp(npc.Velocity, targetvel,LerpVal)
				else
					mod:CatheryPathFinding(npc, d.walktarg, {
						Speed = 5,
						Accel = LerpVal,
						GiveUp = true
					})
				end
			else
				d.walkCycle = 0
				npc.Velocity = npc.Velocity * 0.7
				npc.StateFrame = npc.StateFrame + 2
			end
		end
	end

	local spriteDir
	if math.abs(npc.Velocity.Y) > math.abs(npc.Velocity.X) then
		spriteDir = "Vert"
	else
		spriteDir = "Hori"
		if npc.Velocity.X > 0 then
			sprite.FlipX = false
		else
			sprite.FlipX = true
		end
	end
	if npc.Velocity:Length() > 0.1 then
		sprite:SetFrame("Walk" .. spriteDir, moduloVal)
	else
		sprite:SetFrame("Walk" .. spriteDir, 0)
	end

	for k,v in ipairs(mod.GetGridEntities()) do
		if v.Position:Distance(npc.Position + npc.Velocity) < 45 then
			if v.Desc.Type ~= GridEntityType.GRID_DOOR then
				v:Destroy()
			end
		end
	end
end
local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:setCentiAngle(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()

	local angle = npc.Velocity:GetAngleDegrees()
	angle = angle + 180
	if angle > -23 and angle <= 22 then
		d.dir = "Hori"
		sprite.FlipX = true
	elseif angle > 22 and angle <= 67 then
		d.dir = "DiagUp"
		sprite.FlipX = true
	elseif angle > 67 and angle <= 112 then
		d.dir = "Up"
		sprite.FlipX = false
	elseif angle > 112 and angle <= 157 then
		d.dir = "DiagUp"
		sprite.FlipX = false
	elseif angle > 157 and angle <= 202 then
		d.dir = "Hori"
		sprite.FlipX = false
	elseif angle > 202 and angle <= 247 then
		d.dir = "DiagDown"
		sprite.FlipX = false
	elseif (angle > 247 and angle < 270) or angle < -78 then
		d.dir = "Down"
		sprite.FlipX = false
	else
		d.dir = "DiagDown"
		sprite.FlipX = true
	end
end

function mod.FindClosestCentibit(pos)
	local dist = {false, 9999999999}
	for _, seg in pairs(Isaac.FindByType(mod.FF.Centipede.ID, mod.FF.Centipede.Var, 1, false, false)) do
		local newdist = seg.Position:Distance(pos)
		if newdist < dist[2] then
			dist = {seg, newdist}
		end
	end
	return dist
end

function mod.CollectCentiBits(npc)
	local d = npc:GetData()
	local segpos = npc.Position
	local looking = true
	local butts = {}
	while looking do
		local newseg = mod.FindClosestCentibit(segpos)
		if newseg[1] then
			if newseg[2] < 75 then
				table.insert(butts, newseg[1])
				newseg[1].SubType = #butts + 1
				newseg[1].Parent = npc
				if #butts > 1 then
					newseg[1]:GetData().Leader = butts[#butts - 1]
				else
					newseg[1]:GetData().Leader = npc
				end
				local vec = newseg[1]:GetData().Leader.Position - newseg[1].Position
				segpos = newseg[1].Position
				local maxmove = 5
				for i = 1, maxmove do
					table.insert(d.prevpositions, {
                        state = d.state,
                        divestate = 0,
                        dir = "Down",
                        lastdir = "Down",
                        flipnes = false,
                        pos = segpos + (vec * (i/maxmove)),
                        offset = 0,
                        scale = 1,
                        velocity = (vec / maxmove) / 2
                    })
				end
			else
				break
			end
		else
			break
		end
	end
	return butts
end

--been feeling so crap recently
--gonna make centipede good as shit to prove my worth
function mod:centipedeAI(npc, subt, var)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	if target.Parent and target.Parent.InitSeed == npc.InitSeed then
		target = Isaac.GetPlayer(0)
	end

	local movespeed = 7
	local normscale = 1
	if var == 541 then
		if d.hasangered then
			movespeed = 10
			normscale = 1.2
			if not sfx:IsPlaying(mod.Sounds.SteamTrain) then
				sfx:Play(mod.Sounds.SteamTrain, 2, 0, true, 0.9)
			end
		else
			movespeed = 4
			normscale = 0.9
		end
		--FUCK LOOPING SOUNDS
		if npc:IsDead() or mod:isLeavingStatusCorpse(npc) then
			sfx:Stop(mod.Sounds.SteamTrain)
		end
	end

	if subt == 0 or subt > 100 then
	--HEAD
		if not d.init then
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			d.prevpositions = {}
			d.dir = "Down"
			d.lastdir = "Down"

			--Oh my god look away
			if subt > 100 then
				--PLEASE LOOK AWAY
				npc.Visible = false
				if (not mod:isFriend(npc)) and Game():GetRoom():GetFrameCount() < 5 then 
					local pit = Isaac.GridSpawn(7, 0, npc.Position, true)
					mod:UpdatePits()
				end
				d.state = "dive"
				d.divestate = 2
				d.spawning = true
				npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				--STOP BEFORE IT'S TOO LATE
				for i = 1, (subt - 100) * 5 do
					table.insert(d.prevpositions, 1, {
                        state = "dive",
						divestate = 2,
						dir = "Down",
						lastdir = "Down",
						flipnes = false,
						pos = npc.Position,
						offset = 0,
						scale = 1,
						velocity = nilvector
                    })

				end
				--well you're this far in
				d.butts = {}
				local butt = Isaac.Spawn(mod.FF.Centipede.ID, mod.FF.Centipede.Var, 2, npc.Position, nilvector, npc)
				local td = butt:GetData()
				td.Leader = npc
				butt.Parent = npc
				table.insert(d.butts, butt)
				for i = 1, (subt - 101) do
					local butt = Isaac.Spawn(mod.FF.Centipede.ID, mod.FF.Centipede.Var, #d.butts + 2, npc.Position, nilvector, npc)
					local td = butt:GetData()
					if #d.butts > 1 then
						td.Leader = d.butts[#d.butts - 1]
					else
						td.Leader = npc
					end
					butt.Parent = npc
					table.insert(d.butts, butt)
				end
				--if #d.butts > 1 then
				--	npc.MaxHitPoints = npc.MaxHitPoints * (1 + (0.15 * (#d.butts - 2)))
				--	npc.HitPoints = npc.MaxHitPoints
				--end
				--are you happy
			else
				d.butts = mod.CollectCentiBits(npc)
				--if #d.butts > 1 then
				--	npc.MaxHitPoints = npc.MaxHitPoints * (1 + (0.15 * (#d.butts - 2)))
				--	npc.HitPoints = npc.MaxHitPoints
				--end
				d.state = "im jus w... im just walkin here"
			end
			if #d.butts > 0 then
				local tail = Isaac.Spawn(mod.FF.Centipede.ID, mod.FF.Centipede.Var, #d.butts + 1, d.butts[#d.butts].Position, nilvector, npc)
				local td = tail:GetData()
				td.Leader = d.butts[#d.butts]
				td.Tail = true
				tail.Parent = npc
			else
				local tail = Isaac.Spawn(mod.FF.Centipede.ID, mod.FF.Centipede.Var, 2, npc.Position, nilvector, npc)
				local td = tail:GetData()
				td.Leader = npc
				td.Tail = true
				tail.Parent = npc
			end
			d.init = true
		else
			npc.StateFrame = npc.StateFrame + 1
		end

		if d.state == "im jus w... im just walkin here" then
			local targetedpos = target.Position
			if (npc.StateFrame % 60 == 0 and not d.targetrando) or mod:isConfuse(npc) then
				if math.random(3) == 1 then
					d.targetrando = mod:FindRandomValidPathPosition(npc, 2, 30)
				end
			end

			if d.targetrando then
				targetedpos = d.targetrando
			end

			if mod:isScare(npc) then
				movespeed = movespeed * -1
			end
			local targvel = (targetedpos - npc.Position):Resized(movespeed)
			npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.07):Rotated(math.sin((npc.InitSeed + npc.FrameCount) / 7) * 8)
			if d.hasangered then
				npc.Velocity = npc.Velocity:Resized(movespeed)
			end
			mod:setCentiAngle(npc)
			mod:spritePlay(sprite, "Head" .. d.dir)

			if d.targetrando and npc.Position:Distance(d.targetrando) < 20 then
				d.targetrando = nil
			end

			if npc.StateFrame > 25 and mod:IsCurrentPitSafe(npc) then
				npc.SpriteOffset = Vector(0, 0)
				d.targetrando = nil
				d.state = "dive"
				d.lastdir = d.dir
				d.pitaim = game:GetRoom():GetGridEntityFromPos(npc.Position)
				d.divestate = 1
			else
				local coll = game:GetRoom():GetGridCollisionAtPos(npc.Position)
				if coll > 1 then
					npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(0, -10), 0.2)
					npc.Scale = mod:Lerp(npc.Scale, normscale + 0.2, 0.2)
				else
					npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(0, 0), 0.2)
					npc.Scale = mod:Lerp(npc.Scale, normscale, 0.2)
				end
			end

			if d.angry and not d.hasangered then
				d.state = "angytime"
				npc.StateFrame = 0
			end
		elseif d.state == "dive" then
			if d.divestate == 1 then
				--npc.Velocity = npc.Velocity * 0.8
				local gopit = d.pitaim.Position - npc.Position
				npc.Velocity = gopit:Resized(math.max(gopit:Length()/3),5)
				if sprite:IsFinished("Head" .. d.lastdir .. "Pit") then
					d.divestate = 2
					npc.StateFrame = 0
				else
					mod:spritePlay(sprite, "Head" .. d.lastdir .. "Pit")
				end
			elseif d.divestate == 2 then
				npc.Visible = false
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				if npc.StateFrame == 15 then
					if not d.spawning then
						npc.Position = mod:FindRandomPit(npc, true)
					end
					npc.Velocity = (target.Position - npc.Position):Resized(1)
					d.divestate = 3
					mod:setCentiAngle(npc)
					d.lastdir = d.dir
					d.spawning = false
				end
			elseif d.divestate == 3 then
				npc.Visible = true
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				if sprite:IsFinished("Head" .. d.lastdir .. "Emerge") then
					d.state = "im jus w... im just walkin here"
					npc.StateFrame = 0
				else
					mod:spritePlay(sprite, "Head" .. d.lastdir .. "Emerge")
				end
			end
		elseif d.state == "angytime" then
			npc.Velocity = nilvector
			sprite:SetFrame("Head" .. d.dir, 0)
			if npc.StateFrame == 1 then
				npc:PlaySound(mod.Sounds.SteamTrainWhistle,0.7,0,false, 1)
			elseif npc.StateFrame < 20 then
				npc.Scale = mod:Lerp(npc.Scale, 1.6, 0.2)
				npc.Color = Color((npc.StateFrame / 5), 1, 1, 1, 0,0,0)
			elseif npc.StateFrame < 50 then
				npc.Scale = mod:Lerp(npc.Scale, 1.1, 0.2)
				npc.Color = Color((4 - ((npc.StateFrame - 25)) / 10), ((npc.StateFrame - 50) / 5), ((npc.StateFrame - 50) / 5), 1, 0,0,0)
			elseif npc.StateFrame > 50 then
				d.state = "im jus w... im just walkin here"
				d.hasangered = true
			end
		end

		if d.state ~= "angytime" then
			table.insert(d.prevpositions, 1, {state = d.state,
												divestate = d.divestate,
												dir = d.dir,
												lastdir = d.lastdir,
												flipnes = sprite.FlipX,
												pos = npc.Position,
												offset = npc.SpriteOffset.Y,
												scale = npc.Scale,
												velocity = npc.Velocity
												})
			if #d.prevpositions > #d.butts * 10 then
				table.remove(d.prevpositions, #d.prevpositions)
			end
		else
			if not d.angyprev then d.angyprev = {} end
			table.insert(d.angyprev, 1, {npc.Scale, npc.Color})
		end

	--CENTIPEDE ASS
	else
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.StateFrame = npc.StateFrame + 1
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		local chainplus = 0
		local spritething = "Segment"
		if d.Tail then
			chainplus = 3
			spritething = "Tail"
		end
		local chainpos = ((subt - 1) * 4) + chainplus
		local p = npc.Parent
		if p then
			local pd = p:GetData()
			local startspeed = 4
			if pd.butts and #pd.butts > 9 then
				startspeed = 2
			end
			if pd.prevpositions and #pd.prevpositions > chainpos and (p.SubType > 100 or npc.FrameCount > chainpos + startspeed) then
				if pd.state ~= "angytime" then
					npc.Position = pd.prevpositions[chainpos].pos
					npc.Velocity = pd.prevpositions[chainpos].velocity
					npc.SpriteOffset = Vector(0, pd.prevpositions[chainpos].offset)
					npc.Scale = pd.prevpositions[chainpos].scale
				end

				if pd.state == "angytime" then
					npc.Velocity = nilvector
					sprite:SetFrame(spritething .. pd.prevpositions[chainpos].dir, 0)
					if pd.angyprev and pd.angyprev[chainpos] then
						npc.Scale = pd.angyprev[chainpos][1]
						npc.Color = pd.angyprev[chainpos][2]
					else
						npc.Scale = 1
					end
				elseif pd.prevpositions[chainpos].state == "im jus w... im just walkin here" then
					mod:spritePlay(sprite, spritething .. pd.prevpositions[chainpos].dir)
				elseif pd.prevpositions[chainpos].state == "dive" then
					if pd.prevpositions[chainpos].divestate == 1 then
						mod:spritePlay(sprite, spritething .. pd.prevpositions[chainpos].lastdir .. "Pit")
					elseif pd.prevpositions[chainpos].divestate == 2 then
						npc.Visible = false
						npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					elseif pd.prevpositions[chainpos].divestate == 3 then
						npc.Visible = true
						npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
						mod:spritePlay(sprite, spritething .. pd.prevpositions[chainpos].lastdir .. "Emerge")
					end
				end
				sprite.FlipX = pd.prevpositions[chainpos].flipnes

			elseif npc.FrameCount > chainpos then
				local targvel = (d.Leader.Position - npc.Position):Resized(npc.Position:Distance(d.Leader.Position) / (startspeed + 1))
				npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.2)
				npc.Position = npc.Position + ((d.Leader.Position - npc.Position)/(startspeed + 1))
				mod:setCentiAngle(npc)
				mod:spritePlay(sprite, spritething .. d.dir)
			else
				npc.Velocity = npc.Velocity * 0.25
				mod:setCentiAngle(npc)
				mod:spritePlay(sprite, spritething .. d.dir)
			end
		else
			if npc.StateFrame > 10 then
				npc:Die()
			end
		end
	end
end

function mod:centipedeHurt(npc, damage, flag, source)
    local data = npc:GetData()
    if npc.Parent and npc.Parent:Exists() then
        if npc.Parent:GetData().eternalFlickerspirited then
            return false
        end
    end
    if flag == flag | DamageFlag.DAMAGE_POISON_BURN then -- Keep Poison/Burn Synced to once per 40 frames
        data.FFLastPoisonProc = data.FFLastPoisonProc or 0
        if Isaac.GetFrameCount() - data.FFLastPoisonProc < 40 then
            return false
        end
        data.FFLastPoisonProc = Isaac.GetFrameCount()
    end

    if npc.SubType == 0 then
        if variant == mod.FF.CentipedeAngy then
            data.angry = true
        end

        local butts = Isaac.FindByType(mod.FF.Centipede.ID, mod.FF.Centipede.Var)
        for _, butt in ipairs(butts) do
            if butt.Parent and butt.Parent.InitSeed == npc.InitSeed then
                butt:TakeDamage(damage, flag | DamageFlag.DAMAGE_CLONES, source, 0)
            end
        end
    elseif flag ~= flag | DamageFlag.DAMAGE_CLONES then
        if npc.SubType > 1 and npc.SubType < 100 then
            if npc.Parent then
                data.IgnorePassedDamage = true
                npc.Parent:TakeDamage(damage, flag | DamageFlag.DAMAGE_CLONES, source, 0)
                data.IgnorePassedDamage = false
            end
        end
    elseif data.IgnorePassedDamage then
        return false
    end
	--	if npc.SubType > 1 and npc.SubType < 100 then
	--		if flag & DamageFlag.DAMAGE_CLONES == 0 then
	--			if npc.Parent then
	--				npc.Parent:TakeDamage(damage, flag & DamageFlag.DAMAGE_CLONES, EntityRef(npc), 0)
	--			end
	--		end
	--	end
	--elseif variant == mod.FF.CentipedeAngy.Var then
	--	local d = npc:GetData()
	--	d.angry = true
end

function mod:centipedeColl(npc1, npc2)
    if npc1.Parent and npc1.Parent.InitSeed == npc2.InitSeed then -- Prevent selfdamage from charm/bait
        return true
    elseif npc2.Parent and npc2.Parent.InitSeed == npc1.InitSeed then
        return true
    elseif npc1.Parent and npc2.Parent and npc1.Parent.InitSeed == npc2.Parent.InitSeed then
        return true
    end
end
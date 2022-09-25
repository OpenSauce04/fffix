local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod.nearValidShroom(ent, invert)
	local len = 10000
	if invert then
		len = 0
	end
	local dist = 0
	local near = 0
	for k, v in ipairs(Isaac.GetRoomEntities()) do
		if v.Type == mod.FF.Fatshroom.ID and v.Variant == mod.FF.Fatshroom.Var and not (v:IsDead() or mod:isStatusCorpse(v)) then
			dist = (ent.Position - v.Position):Length()
			if v:GetData().leaper == nil and ((dist < len and not invert) or (invert and dist > len)) then
				len = dist
				near = v
			end
		end
	end
	return near
end

--CordyAI, Cordy, Cordy AI
function mod:shroomLeaperAI(npc)
	local d = npc:GetData()
	local s = npc:GetSprite()
	local rng = npc:GetDropRNG()
	local target = npc:GetPlayerTarget()

	if not d.init then
		d.init = true
		d.statetime = 0
		d.state = 'main'
		d.lastpos = npc.Position
		d.aim = npc.Position
		d.tgt = 0
		d.lasttgt = 0
		d.up = false
		d.hops = 0
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS

		d.tgt = 0--l.nearValidShroom(npc)
		d.lasttgt = d.tgt
		--[[if d.tgt ~= 0 then
			d.state = 'main'
			npc.Position = d.tgt.Position + Vector(0, 4)
			npc.PositionOffset = Vector(0, -34)
			d.up = true
			d.tgt:GetData().leaper = npc
			d.tgt:GetData().squish = true
			d.tgt:GetData().invulnerable = true
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		end--]]
	end

	npc.State = 4

	if npc.FrameCount > 30 and not s:IsPlaying("Idle") and not d.playIdle then
		s:Play("Idle")
		d.playIdle = true
	end

	if d.state == 'main' then
		local alive = (d.lasttgt ~= 0 and d.lasttgt:IsEnemy() and not (d.lasttgt:IsDead() or mod:isStatusCorpse(d.lasttgt)))
		if alive then
			npc.Position = d.lasttgt.Position + d.lasttgt.Velocity + Vector(0, 2)
		else
			npc.Velocity = npc.Velocity * .9
		end
		if s:IsPlaying("BigJumpDown") then
			if s:IsEventTriggered("Stomp") then
				npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,1,0,false,1)
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
				if alive then
					d.tgt:GetData().squish = true
					if mod:isCharm(d.tgt) then
						d.tgt:Kill()
					end
				else
					d.hops = 1
					npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				end
			end
			if alive then
				npc.PositionOffset = Vector(0, -34)
				d.up = true
			else
				npc.PositionOffset = nilvector
				d.up = false
			end
		end
		if s:IsFinished("BigJumpDown") or s:IsFinished("Hop") then
			s:Play("Idle")
		end
		if s:IsPlaying("Idle") then
			local alive = (d.tgt ~= 0 and d.tgt:IsEnemy() and not (d.tgt:IsDead() or mod:isStatusCorpse(d.tgt)))

			local rand = rng:RandomFloat()
			if d.tgt ~= 0 then
				if d.tgt:IsDead() or mod:isStatusCorpse(d.tgt) then
					npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				end
			end
			if (d.statetime > 10 and rand < .15) or (not d.up) or (not alive) then
				local invert = false
				if npc.FrameCount < 90 then
					invert = true
				end
				d.tgt = mod.nearValidShroom(target, invert)
				if d.tgt ~= 0 and d.hops <= 0 then
					d.tgt:GetData().leaper = npc
					s:Play("BigJumpUp")
				elseif alive and d.hops <= 0 then
					d.tgt = d.lasttgt
					s:Play("BigJumpUp")
				elseif not d.up then
					s:Play("Hop")
				else--failsafe
					npc.PositionOffset = nilvector
					s:Play("BigJumpUp")
				end
			end
		end
		if s:IsEventTriggered("Hop") and not d.up then
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			if rng:RandomFloat() < .5 or npc.FrameCount < 90 then
				d.hops = d.hops - 1
			end
			d.state = 'hop'
			d.statetime = 0
			d.lastpos = npc.Position
			d.aim = (target.Position - npc.Position)
			d.aimjumpo = game:GetRoom():FindFreeTilePosition(npc.Position + d.aim:Resized(math.min(d.aim:Length(),320)), 0)
		end
		if s:IsEventTriggered("Land") then
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS,1,0,false,1)
		end
		if s:IsPlaying("BigJumpUp") then
			if s:IsEventTriggered("Jump") then
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				if alive then
					d.lasttgt:GetData().squish = false
					d.lasttgt:GetData().leaper = nil
				end
				if d.tgt ~= 0 then
					d.tgt:GetData().leaper = npc
					d.aim = d.tgt.Position
				end
				d.lastpos = npc.Position
				d.state = 'leap'
				d.statetime = 0
			end
		end
	elseif d.state == 'leap' then
		local alive = (d.tgt ~= 0 and d.tgt:IsEnemy() and not (d.tgt:IsDead() or mod:isStatusCorpse(d.tgt)))
		if alive then
			d.aim = d.tgt.Position
		end
		npc.Position = mod:Lerp(d.lastpos, d.aim, d.statetime / 20)
		if d.statetime > 19 then
			d.state = 'main'
			d.statetime = 0
			s:Play("BigJumpDown")
			d.lasttgt = d.tgt
		end
	elseif d.state == 'hop' then
		local jumpvel = 20
		if npc.Position:Distance(d.aimjumpo) < 160 then
			jumpvel = 20 - ((160 - npc.Position:Distance(d.aimjumpo)) / 8)
		end
		npc.Velocity = mod:Lerp(npc.Velocity, (d.aimjumpo - npc.Position):Resized(jumpvel), .3)
		if d.statetime == 10 then
			d.state = 'main'
			d.statetime = 0
		end
	end

	d.statetime = d.statetime + 1

end

function mod:fatShroomAI(npc)
	local d = npc:GetData()
	local s = npc:GetSprite()
	local rng = npc:GetDropRNG()
	local target = npc:GetPlayerTarget()
    local room = game:GetRoom()

	if not d.init then
		d.init = true
		d.statetime = 0
		d.laststate = 0
		d.state = 'idle'
		d.spawnpos = npc.Position
		d.lastpos = npc.Position
	end

	if room:IsClear() then
		game:Fart(npc.Position, 40, npc, 1, 0)
		npc:Kill()
	end

	if d.leaper and (d.leaper:IsDead() or mod:isStatusCorpse(d.leaper) or not d.leaper:IsEnemy()) then
		d.leaper = nil
	end
	if not d.leaper then
		d.squish = false
	end

	npc.Velocity = d.spawnpos - npc.Position

	if d.state == 'idle' then
		if d.squish then
			s:Play("Squish")
			d.state = 'squish'
			d.statetime = 0
		elseif not s:IsPlaying("Release") then
			s:Play("Idle")
		end
		local diff = d.spawnpos - npc.Position
		local len = diff:Length()
		local dir = diff:Normalized()
		if len > 10 then
			npc.Velocity = npc.Velocity + (dir * .15)
		end
	elseif d.state == 'squish' then
		if s:IsEventTriggered("Shoot") then
			if npc.FrameCount > 15 then
				sfx:Play(SoundEffect.SOUND_ANIMAL_SQUISH,1,0,false,1)
				local params = ProjectileParams()
				local shot = nil
				local vel = nilvector
				local rand = 0
				for i = 24, 360, 24 do
					rand = rng:RandomFloat()
					params.FallingSpeedModifier = (rand * -14)
					params.FallingAccelModifier = 1.2
					params.VelocityMulti = .3 + ((1-rand) * 1.4)
					params.Scale = 1 + (rng:RandomInt(2) * .5)
					vel = Vector(0, 8 + (rng:RandomFloat() * .1)):Rotated(i + rng:RandomInt(16))
					shot = npc:FireProjectiles(npc.Position, vel, 1, params)
				end
			end
		end
		if not d.squish then
			s:Play("Release")
			d.state = 'idle'
			d.statetime = 0
		elseif s:IsFinished("Squish") then
			s:Play("Squished")
		end
	end
end
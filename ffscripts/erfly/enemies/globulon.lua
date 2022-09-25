local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:globulonAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()
	local path = npc.Pathfinder

	npc.SpriteOffset = Vector(0, -6)
	if not d.init then
		d.state = "idle"
		d.init = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.state == "idle" then
		if npc.Velocity:Length() > 0.1 then
			mod:spritePlay(sprite, "Walk")
		else
			mod:spritePlay(sprite, "Idle")
		end
		if d.shootsoon then
			npc.Velocity = npc.Velocity * 0.6
			if npc.StateFrame > 20 and not mod:isScareOrConfuse(npc) then
				d.state = "shoot"
				d.shootsoon = nil
			end
		else
			if mod:isScare(npc) or (npc.Position:Distance(target.Position) < 160 and game:GetRoom():CheckLine(npc.Position,target.Position,0,1,false,false)) then
				local targetvel = (target.Position + npc.Position):Resized(5)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
				d.wandertarg = nil
				npc.StateFrame = 0
				if r:RandomInt(30) == 0 then
					d.bubblesize = 0
					d.state = "shoot"
				end
			else
				if d.wandertarg then
					if game:GetRoom():CheckLine(npc.Position,d.wandertarg,0,1,false,false) then
						local targetvel = (d.wandertarg - npc.Position):Resized(4)
						npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
					else
						path:FindGridPath(d.wandertarg, 0.6, 900, true)
					end
					if npc.StateFrame > 120 or (mod:isConfuse(npc) and npc.StateFrame > 15) then
						d.wandertarg = nil
					elseif npc.Position:Distance(d.wandertarg) < 20 then
						d.wandertarg = nil
					end
				else
					npc.Velocity = npc.Velocity * 0.6
					if (not mod:isScareOrConfuse(npc)) and npc.StateFrame > 20 and r:RandomInt(30) == 0 then
						d.state = "drinkstart"
						npc:PlaySound(mod.Sounds.GlobSwallow,1,2,false,math.random(115,135)/100)
					elseif (not mod:isScareOrConfuse(npc)) and npc.StateFrame % 60 == 0 then
						if npc.Position:Distance(target.Position) < 180 and game:GetRoom():CheckLine(npc.Position,target.Position,0,1,false,false) then
							d.state = "drinkstart"
							npc:PlaySound(mod.Sounds.GlobSwallow,1,2,false,math.random(115,135)/100)
						else
							d.wandertarg = mod:FindRandomValidPathPosition(npc)
							npc.StateFrame = 0
						end
					elseif (mod:isConfuse(npc) and npc.StateFrame > 15) then
						d.wandertarg = mod:FindRandomValidPathPosition(npc)
					end
				end
			end
		end
	elseif d.state == "drinkstart" then
		npc.Velocity = nilvector
		if sprite:IsFinished("StartDrink") then
			d.state = "drink"
			d.sips = 0
			npc.StateFrame = 0
		else
			mod:spritePlay(sprite, "StartDrink")
		end
	elseif d.state == "drink" then
		npc.Velocity = nilvector
		if sprite:IsFinished("Drink") then
			if d.sips > 2 then
				d.shootsoon = true
				d.state = "idle"
				npc.StateFrame = 10
			else
				sprite:Play("Drink", true)
			end
		elseif sprite:GetFrame() == 3 then
			d.sips = d.sips + 1
			npc:PlaySound(mod.Sounds.GlobGulp,1,2,false,math.random(120,130)/100)
			if d.bubble then
				d.bubble:GetData().size = d.bubble:GetData().size + 1
			else
				local bubble = Isaac.Spawn(1000, 7016, 0, npc.Position, nilvector, npc):ToEffect();
				bubble:FollowParent(npc)
				bubble:GetData().size = 1
				bubble:Update()
				d.bubble = bubble
			end
		else
			mod:spritePlay(sprite, "Drink")
		end
	elseif d.state == "shoot" then
		npc.Velocity = nilvector
		if sprite:IsFinished("Shoot") then
			npc.StateFrame = 0
			d.state = "idle"
		elseif sprite:IsEventTriggered("Shoot") then
			local bubby = 0
			if d.bubble then
				if d.bubble:GetData().size then
					bubby = 6 + d.bubble:GetData().size
				end
				d.bubble:Remove()
				d.bubble = nil
			end
			npc:PlaySound(mod.Sounds.BubbleLaunch,2,0,false,math.random(120,130)/100 - 0.05 * bubby)
			local bub = mod.ShootBubble(npc,bubby,npc.Position,(target.Position - npc.Position):Resized(4))
			bub.SpriteOffset = Vector(0,-10)
		else
			mod:spritePlay(sprite, "Shoot")
		end
	elseif d.state == "startle" then
		if not d.jumping then
			npc.Velocity = npc.Velocity * 0.9
		end
		if sprite:IsFinished("Startle") then
			npc.StateFrame = 0
			d.shootsoon = true
			d.state = "idle"
		elseif sprite:IsEventTriggered("Jump") then
			npc:PlaySound(mod.Sounds.GlobSurprise,0.6,2,false,math.random(115,165)/100)
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			--npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,1,2,false,1)
			d.jumping = true
			d.aim = npc.Position - target.Position
            local room = game:GetRoom()
			d.aimjumpo = room:FindFreeTilePosition(npc.Position + d.aim:Resized(math.min(d.aim:Length(),320)), 0)
			if d.aimjumpo:Distance(npc.Position) > 180 or room:GetGridCollisionAtPos(d.aimjumpo) ~= GridCollisionClass.COLLISION_NONE then
				d.aimjumpo = npc.Position
			end
		elseif sprite:IsEventTriggered("Land") then
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			d.jumping = false
			npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS,1,2,false,1)
		else
			mod:spritePlay(sprite, "Startle")
		end
	end

	if d.jumping then
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
end

function mod:globulonHurt(npc, damage, flag, source)
    local d = npc:GetData()
    if d.state == "drink" then
        local sf = npc:ToNPC().StateFrame
        if sf < 50 then
            d.bubblesize = 7
        elseif sf < 100 then
            d.bubblesize = 8
        else
            d.bubblesize = 9
        end
        d.state = "startle"
    end
end

function mod:checkGlobulonThirstyBoyHahaICanJustMakeThisAsLongAsIWant(e)
	local d = e:GetData()
	local sprite = e:GetSprite()
	e.RenderZOffset = 500

	if e.Parent then
		e.Velocity = e.Parent.Velocity
		e.Position = e.Parent.Position

		local yoff = -15
		if e.Parent:GetSprite():IsPlaying("Startle") then
			yoff = yoff + mod.globOffTable[e.Parent:GetSprite():GetFrame()]
		end
		e.SpriteOffset = Vector(0, yoff) + e.Parent.SpriteOffset

		if not d.prevBub or d.size > d.prevBub then
			mod:spritePlay(sprite, "Grow" .. d.size)
			d.prevBub = d.size
		else
			if not sprite:IsPlaying("Grow" .. d.size) then
				mod:spritePlay(sprite, "Idle" .. d.size)
			end
		end
		if e.Parent:IsDead() then
			e:Remove()
		end
	else
		e:Remove()
	end
end

mod.globOffTable = {
    [0] = 0,
    [1] = 3,
    [2] = 2,
    [3] = 0,
    [4] = -10,
    [5] = -22,
    [6] = -23,
    [7] = -23,
    [8] = -24,
    [9] = -25,
    [10] = -25,
    [11] = -26,
    [12] = -25,
    [13] = -23,
    [14] = -22,
    [15] = -22,
    [16] = 2,
    [17] = 1,
    [18] = 0,
    [19] = 0,
    [20] = 0,
    [21] = 0,
    [22] = 0,
    [23] = 0,
    [24] = 0,
}

--[[function mod:checkGlobulonThirstyBoyHahaICanJustMakeThisAsLongAsIWant(e)
	local d = e:GetData()
	local sprite = e:GetSprite()
	e.RenderZOffset = 500

	if e.Parent then
		e.Velocity = e.Parent.Velocity
		e.Position = e.Parent.Position
		if e.Parent:IsDead() then
			e:Remove()
		end
	else
		e:Remove()
	end

	local sizeoffset = nilvector
	local size = 1
	if d.huge then
		sizeoffset = Vector(0,-5)
		size = 3
	elseif d.med then
		sizeoffset = Vector(0,-2.5)
		size = 2
	end
	local positionoffset = nilvector
	if d.frame then
		positionoffset = Vector(0, mod.globOffTable[d.frame])
	end

	e.SpriteOffset = mod:Lerp(e.SpriteOffset, Vector(0, -8) + sizeoffset + positionoffset, 0.7)

	if d.setscale then
		if d.setscale == 8 then
			if not d.med then
				sprite:Load("gfx/projectiles/bubble/bubble_shootmedium.anm2",true)
				d.med = true
			end
		elseif d.setscale == 9 then
			if not d.huge then
				sprite:Load("gfx/projectiles/bubble/bubble_shootlarge.anm2",true)
				d.huge = true
			end
		end
		e.SpriteScale = mod:Lerp(e.SpriteScale, Vector(1,1), 0.3)
	else
		if d.size then
			if d.size == 0 then
				e.SpriteScale = nilvector
			elseif d.size < 50 then
				e.SpriteScale = mod:Lerp(e.SpriteScale, (Vector(1,1) * (math.min(1.3,0.3 + d.size/50))), 0.3)
			elseif d.size < 100 then
				if not d.med then
					d.med = true
				end
				e.SpriteScale = mod:Lerp(e.SpriteScale, (Vector(1,1) * (math.min(1.3,0.3 + d.size/100))), 0.3)
			else
				if not d.huge then
					d.huge = true
				end
				e.SpriteScale = mod:Lerp(e.SpriteScale, (Vector(1,1) * (math.min(1,d.size/120))), 0.3)
			end
		end
	end
	mod:spritePlay(sprite, "Idle" .. size)
end]]
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.checkGlobulonThirstyBoyHahaICanJustMakeThisAsLongAsIWant, 7016)

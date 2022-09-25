local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

local cBoyBodyAnims = {"WalkLeft", "WalkVert", "WalkRight", "WalkVert"}
local cBoyHeadAnims = {"HeadLeft", "HeadUp", "HeadRight", "HeadDown"}
local cBoyShootAnims = {"ShootLeft", "ShootUp", "ShootRight", "ShootDown"}

function mod:CancerBoyGetAnimIndex(vec)
	local dir = (vec:GetAngleDegrees() + 180 + 45) % 360
	return math.ceil(dir / 90)
end

function mod:Greyscale(sprite, luminosity, alpha)
	alpha = alpha or 1
	local color = Color(1,1,1,alpha,0,0,0)
	color:SetColorize(luminosity,luminosity,luminosity,1)
	sprite.Color = color
	
	return color
end

function mod:CancerBoyUpdate(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local path = npc.Pathfinder
	local target = npc:GetPlayerTarget()
	local room = game:GetRoom()
	
	local speed = 2
	local max_cancerlets = 5
	
	if not d.init then
		d.state = "Normal"
		d.walkframe = 0
		d.headanim_change = -1
		npc.StateFrame = 40
		npc.SplatColor = Color(0,0,0,1,0.1,0.1,0.1)
		d.init = true
	end
	
	if d.state == "Normal" then
		speed = 2
		
		if room:CheckLine(npc.Position,target.Position,3,1,false,false) then
			local count = mod.GetEntityCount(mod.FF.Cancerlet.ID, mod.FF.Cancerlet.Var, mod.FF.Cancerlet.Sub)
			if count < max_cancerlets then
				npc.StateFrame = npc.StateFrame + 1
			end
			
			-- start shooting
			if npc.StateFrame > 75 then
				npc.StateFrame = 0
				d.state = "Shoot"
			end
		end
	elseif d.state == "Shoot" then
		speed = 0.5
		
		-- get player position, and play shoot animation
		if not d.shootvec then
			--local predict = (target.Position + (target.Velocity * 3))
			d.shootvec = (target.Position - npc.Position):Normalized()
			
			local i = mod:CancerBoyGetAnimIndex(d.shootvec)
			d.shootanim = cBoyShootAnims[i]
		end
		
		if d.shootanim then
			mod:spriteOverlayPlay(sprite, d.shootanim)
		end
		
		-- shoot
		if sprite:GetOverlayFrame() == 10 and not d.shot then
			npc:PlaySound(SoundEffect.SOUND_WHEEZY_COUGH, 0.8, 0, false, math.random(8, 10) / 10)
			
			d.shot = true
			local count = math.random(2) + 1
			local spread = 20
			local falavel = 10.5
			
			local spawnoffs = d.shootvec:Resized(20)
			local spriteoffs = Vector(0, -30)
			if sprite:GetOverlayAnimation() == "ShootLeft" or sprite:GetOverlayAnimation() == "ShootRight" then
				spriteoffs = Vector(0, -16)
			end
			
			local countreal = count - 1
			for i = 0, countreal do
				local spreadvec = d.shootvec:Rotated(spread * i / countreal - (spread * 0.5)) -- shoot vector with spread
				
				-- spawn cancerlet
				local f = Isaac.Spawn(mod.FF.Cancerlet.ID, mod.FF.Cancerlet.Var, mod.FF.Cancerlet.Sub, npc.Position + spawnoffs, spreadvec:Resized(falavel):Rotated(math.random(3)), npc)
				local fd = f:GetData()
				local fs = f:GetSprite()
				
				f.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				f:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				f.SpriteOffset = Vector(0, -8)
				
				fd.fallspeed = -4 - math.random(3)
				fd.fallaccel = 1
				fd.state = "shot"
				
				f:Update()
				
				-- spawn gibs
				for i = 0, 3 do
					local gibs = Isaac.Spawn(1000, 5, 0, npc.Position + d.shootvec:Resized(35), spreadvec:Resized(i * 2), npc)
					local color = mod:Greyscale(gibs:GetSprite(), 1, 1 - (i * 0.1))
					gibs.SplatColor = color
					gibs.SpriteScale = Vector(1 - (i * 0.1), 1 - (i * 0.1))
					gibs:Update()
				end
				
				-- spawn maggot fx
				if math.random(3) == 1 then
					local maggot = Isaac.Spawn(1000, 63, 0, npc.Position + spawnoffs, nilvector, npc):ToEffect()
					maggot:Update()
				end
			end
			
			-- spawn poof
			local poof = Isaac.Spawn(1000, 16, 0, npc.Position + spawnoffs:Resized(28), nilvector, npc)
			mod:Greyscale(poof:GetSprite(), 0.7)
			poof.SpriteScale = Vector(0.6, 0.6)
			poof.SpriteOffset = spriteoffs
			poof.DepthOffset = 100
			poof:Update()
			
			-- spawn dust
			local dust = Isaac.Spawn(1000, 59, 0, npc.Position + d.shootvec:Resized(30), d.shootvec:Resized(4), npc)
			dust:ToEffect():SetTimeout(12)
			mod:Greyscale(dust:GetSprite(), 0.5)
			dust.SpriteOffset = spriteoffs
			dust.SpriteScale = Vector(0.7, 0.7)
			poof.DepthOffset = 80
			dust:Update()
		end
		
		-- done
		if sprite:IsOverlayFinished(d.shootanim) then
			d.state = "Normal"
			d.shootvec = nil
			d.shot = false
		end
	end
	
	-- walk to player (or wander randomly)
	d.idle = not path:HasPathToPos(target.Position)
	
	if d.idle then
		npc.Velocity = npc.Velocity * 0.4
		if npc.Velocity:Length() < 0.1 then
			npc.Velocity = nilvector
		end
	else
		path:FindGridPath(target.Position, speed / 7, 900, true)
	end
	
	-- body walk animation
	local moving = npc.Velocity:Length()
	if moving > 0.1 then
		local i = mod:CancerBoyGetAnimIndex(npc.Velocity)
		
		if d.state == "Normal" then
			d.headanim_change = d.headanim_change - 1
			
			if not d.headanim or d.headanim_change == 0 then
				d.headanim = cBoyHeadAnims[i]
				d.headanim_change = 10
			end
			mod:spriteOverlayPlay(sprite, d.headanim)
		end
		
		d.walkframe = d.walkframe + math.min(moving * moving, 1) -- I'd use PlaybackSpeed for this instead but that affects the overlay animation too, and I don't want it to
		sprite:SetFrame(cBoyBodyAnims[i], math.floor(d.walkframe))
		if d.walkframe >= 21 then
			d.walkframe = 0
		end
	else
		-- not moving
		if d.state == "Normal" then
			mod:spriteOverlayPlay(sprite, "IdleDown")
		end
		
		sprite:SetFrame("WalkVert", 0)
	end
end

function mod:CancerBoyDeath(npc, variant)
	local poof = Isaac.Spawn(1000, 2, 0, npc.Position, nilvector, npc)
	mod:Greyscale(poof:GetSprite(), 0.7)
	poof:Update()
	
	local poof = Isaac.Spawn(1000, 16, 0, npc.Position, nilvector, npc)
	poof.SpriteOffset = Vector(0, -24)
	mod:Greyscale(poof:GetSprite(), 0.7)
	poof:Update()
end
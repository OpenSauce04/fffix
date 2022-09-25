local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

local shaggothRingSprite = Sprite()
shaggothRingSprite:Load("gfx/enemies/shaggoth/halo.anm2", true)
shaggothRingSprite:Play("Idle", true)

local shaggothGlowSprite = Sprite()
shaggothGlowSprite:Load("gfx/enemies/shaggoth/glow.anm2", true)
shaggothGlowSprite:Play("Idle", true)

local ignoreProjTypes = {
    ["Clergy"] = true,
    ["foeorbital"] = true
}

local removeProjTypes = {
    ["craterorbital"] = true,
    ["mutantorbital"] = true,
    ["dewdrop"] = true,
	["Psyker"] = true,
	["Occult"] = true,
	["Aper"] = true,
	["shi"] = true
}

local shaggothMarker = nil

function mod:EyeOfShaggothFadeParticles(npc)
	local ember = Isaac.Spawn(1000, 66, 0, npc.Position - Vector(2, 20) + Vector(math.random(16) - 8, 0), Vector(0, -1):Rotated(math.random(3)):Resized(3), npc)
	ember.DepthOffset = 100
	ember:GetSprite().Color = Color(0.5, 0, 0.5, 1, 0.2, 0, 0.2)
end

function mod:EyeOfShaggothUpdate(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local room = game:GetRoom()
	local index = room:GetGridIndex(npc.Position)
	
	local captureDistance = npc.SubType
	
	-- counter
	npc.StateFrame = npc.StateFrame + 1
	
	-- shut down on room clear
	if room:IsClear() and not d.shutdown then
		if not d.init then
			d.fade = 1
			npc.StateFrame = -1
		end
		
		if npc.StateFrame > 0 then
			npc.StateFrame = -15
		elseif npc.StateFrame == -1 then
			d.shutdown = true
		end
	end
	
	-- init
	if not d.init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_HIDE_HP_BAR | EntityFlag.FLAG_NO_TARGET)
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        d.position = room:GetGridPosition(index)
		
		if not d.fade then
			d.fade = 0
		end
		
		d.init = true
	else
        if room:GetGridPath(index) < 3000 then
            room:SetGridPath(index, 3000)
        end
	end
	
	-- don't move
    npc.Velocity = Vector.Zero
    npc.Position = d.position
	
	-- shut down / fade animation
	if d.shutdown then
		local frame = math.max(0, sprite:GetFrame() - 1)
		sprite:SetFrame("RotateFade2", frame)
		
		-- fade
		if not d.fade then
			d.fade = 0
		end
		if d.fade < 1 then
			d.fade = d.fade + 0.1
			
			if d.fade >= 1 then
				mod:EyeOfShaggothFadeParticles(npc)
				d.fade = 1
			elseif d.fade > 0.5 then
				mod:EyeOfShaggothFadeParticles(npc)
				sprite:SetFrame("RotateFade1", frame)
			else
				sprite:SetFrame("Rotate", frame)
			end
		end
		
		return
	end
	
	-- spawn marker if one doesn't exist
	if not shaggothMarker then
		-- get a shaggoth marker if there's already one in the room (and remove all the others)
		local markers = Isaac.FindByType(1000, 1809, 4)
		for _, marker in ipairs(markers) do
			if not shaggothMarker then
				shaggothMarker = marker
			else
				marker:Remove()
			end
		end
		-- make a shaggoth marker if there were none already
		if not shaggothMarker then
			shaggothMarker = Isaac.Spawn(1000, 1809, 4, room:GetCenterPos(), nilvector, npc)
			shaggothMarker.Parent = npc
			shaggothMarker:Update()
		end
	end
	local md = shaggothMarker:GetData()
	
	-- look at marker
	local frameCount = 20
	local targetAngle = (shaggothMarker.Position - npc.Position):GetAngleDegrees()
	local frameAngle = targetAngle - 90
    local frame = (-frameAngle / 360) * (frameCount - 1)
    frame = math.ceil(frame - 0.5)
	
    sprite:SetFrame("Rotate", frame % frameCount)
	
	-- pass player target to marker
	md.playerTarget = npc:GetPlayerTarget()
	
	-- capture projectiles (mostly stolen from glass eye sry)
	if md.CapturedProjectiles then
		local projectiles = Isaac.FindByType(EntityType.ENTITY_PROJECTILE)
		for _, proj in ipairs(projectiles) do
			local pdata = proj:GetData()
			if not pdata.ShaggothCaptured and proj.Position:DistanceSquared(npc.Position) < captureDistance ^ 2 then
				local ignore
				if pdata.GlassEyeCaptured then
					ignore = true
				elseif pdata.projType then
					ignore = ignoreProjTypes[pdata.projType]
					if removeProjTypes[pdata.projType] then
						pdata.projType = nil
					end
				end
				
				if not ignore then
					proj:ToProjectile():ClearProjectileFlags(ProjectileFlags.SMART)
					md.CapturedProjectiles[#md.CapturedProjectiles + 1] = {
						Projectile = proj,
						CaptureTime = 0,
						InitialFallAccel = proj:ToProjectile().FallingAccel
					}
					pdata.ShaggothCaptured = true
				end
			end
		end
	end
	
	-- ring
	shaggothRingSprite:Update()
	shaggothGlowSprite:Update()
end

function mod:EyeOfShaggothHurt(npc, damage, flag, source, countdown)
	return false
end

function mod:EyeOfShaggothRender(npc)
	local captureDistance = npc.SubType
    local rpos = Isaac.WorldToScreen(npc.Position)
    local rscale = (captureDistance / 100) * Vector.One
    shaggothRingSprite.Scale = rscale
    shaggothRingSprite.Offset = Vector(0, -8)
	
	local d = npc:GetData()
	if d.fade then
		shaggothRingSprite.Color = Color(1, 1, 1, 1 - d.fade)
	end
	shaggothRingSprite:Render(rpos, Vector.Zero, Vector.Zero)
end

function mod:EyeOfShaggothRemove(npc)
    local room = game:GetRoom()
    local index = room:GetGridIndex(npc.Position)
    local grid = room:GetGridEntity(index)
    if not grid then
        if room:GetGridPath(index) == 3000 then
            room:SetGridPath(index, 0)
        end
    end
	
	shaggothMarker = nil
end

function mod:EyeOfShaggothMarker(e)
	local d = e:GetData()
	local sprite = e:GetSprite()
	local room = game:GetRoom()
	
	-- init
	if not d.init then
		d.StateFrame = 0
		e.RenderZOffset = -1000
		
		local glowrenderer = Isaac.Spawn(1000, 1808, 0, nilvector, nilvector, e)
		glowrenderer.Parent = e
		glowrenderer:Update()
		
		mod:spritePlay(sprite, "Appear")
		
		d.init = true
	end
	
	-- counter
	d.StateFrame = d.StateFrame + 1
	
	-- animations/start marker removal
	if not e.Parent or e.Parent:IsDead() or mod:isStatusCorpse(e.Parent) or e.Parent:GetData().shutdown then
		mod:spritePlay(sprite, "Remove")
	elseif not sprite:IsPlaying("Appear") then
		mod:spritePlay(sprite, "Blink")
	end
	
	-- remove marker and uncapture projectiles
	if e:GetSprite():IsFinished("Remove") then
		if d.CapturedProjectiles then
			for i = #d.CapturedProjectiles, 1, -1 do
				local projData = d.CapturedProjectiles[i]
				local proj = projData.Projectile:ToProjectile()
				proj.FallingAccel = 3
				proj:GetData().ShaggothCaptured = false
			end			
			d.CapturedProjectiles = nil
		end
		
		e:Remove()
	end
	
	-- move
	if d.playerTarget then
		if d.StateFrame > 40 or not d.targetPos or e.Position:Distance(d.targetPos) < 6 then
			d.targetPos = Isaac.GetFreeNearPosition(d.playerTarget.Position + RandomVector():Resized(math.random(30) + 120), 40)
			d.StateFrame = 0
		end
	end
	
	if d.targetPos then
		e.Velocity = mod:Lerp(e.Velocity, (d.targetPos - e.Position):Resized(4), 0.08)
	end
	
	-- sine counter
	if not d.sine or d.sine == 360 then
		d.sine = 0
	end
	d.sine = d.sine + 1
	
	-- pink colour
	local cshift = math.sin(d.sine * 0.15) + 2
	
	local color = Color(1,1,1,1)
	color:SetColorize(cshift, cshift * 0.5, cshift * 0.7, 1)
	
	local colorVibrant = Color(color.R, color.G, color.B, color.A)
	colorVibrant.RO = 0.4
	colorVibrant.GO = 0
	colorVibrant.BO = 0.2
	
	sprite.Color = color
	
	-- move captured projectiles
	if not d.CapturedProjectiles then
        d.CapturedProjectiles = {}
    end
	for i = #d.CapturedProjectiles, 1, -1 do
		local projInfo = d.CapturedProjectiles[i]
		local proj = projInfo.Projectile:ToProjectile()
		local projData = proj:GetData()
		local projSprite = proj:GetSprite()
		
		if not proj:Exists() or proj:IsDead() or not projData.ShaggothCaptured then
			table.remove(d.CapturedProjectiles, i)
		else
			proj.Parent = e
			
			-- destroy on pillars but not walls
			proj:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
			
			-- move projectile
			if not projData.ShaggothMarkerOverride then
				proj.Velocity = mod:Lerp(proj.Velocity, e.Velocity, 0.4)
				proj.Height = mod:Lerp(proj.Height, -18, 0.15)
				
				-- drop after enough time has passed
				projInfo.CaptureTime = projInfo.CaptureTime + 1
				if projInfo.CaptureTime > 210 then
					proj.FallingAccel = 3
				else
					proj.FallingAccel = -0.1
				end
			else
				proj.FallingAccel = projInfo.InitialFallAccel
			end
			
			-- set colours
			proj:GetData().ShaggothColour = true
			proj.SplatColor = Color(1, 0, 1)
			projSprite.Color = color
			if proj.Child then
				proj.Child:GetSprite().Color = color
			end
			
			-- exceptions/special behaviours
			
			local spawner = projInfo.Projectile.SpawnerEntity
			if spawner then
				-- kineti
				if spawner.Type == 816 and spawner.Variant == 1 then
					if proj.Variant == ProjectileVariant.PROJECTILE_GRID and proj:HasProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE) then
						proj.Parent = nil
						spawner.Child = nil
						proj.SpawnerEntity = nil
					end
				-- 1/2 heart
				elseif spawner.Type == 92 and spawner.Variant == 1 then
					if not projData.shaggothConvert then
						projData.shaggothConvert = 10
					end
					projData.shaggothConvert = projData.shaggothConvert - 1
					if projData.shaggothConvert < 0 then
						local new = Isaac.Spawn(proj.Type, proj.Variant, proj.SubType, proj.Position, proj.Velocity, e)
						
						local np = new:ToProjectile()
						np.Height = proj.Height
						np.Scale = proj.Scale
						np.Acceleration = proj.Acceleration
						
						proj:Remove()
						proj = new
						d.CapturedProjectiles[i].Projectile = proj
					end
				-- shi
				elseif spawner.Type == mod.FF.Shi.ID and spawner.Variant == mod.FF.Shi.Var then
                    local ffFlags = mod:getCustomProjectileFlags(proj)
                    ffFlags.MatchRotation = true
				-- morvid
				elseif spawner.Type == mod.FF.Morvid.ID and spawner.Variant == mod.FF.Morvid.Var then
					projSprite:Load("gfx/projectiles/morvid_feather_noblink.anm2", true)
                    projSprite:Play("Move", true)
				end
			end
			-- punisher
			if projData.punisher then
				local vibrant = Color(color.R, color.G, color.B, color.A)
				vibrant.RO = 0.4
				vibrant.GO = 0
				vibrant.BO = 0.2
				
				projSprite.Color = vibrant
			end
			-- gabber
			projData.gabberProj = false
			
			-- destroy on pillars (pillars use wall collision, so i have to do this manually)
			local grid = room:GetGridEntityFromPos(proj.Position + proj.Velocity)
			if grid then
				if grid:GetType() == GridEntityType.GRID_PILLAR then
					proj:Die()
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.EyeOfShaggothMarker, 1809)

function mod:EyeOfShaggothGlowUpdate(e)
	if not e.Parent or e.Parent:IsDead() or not e.Parent:Exists() then
		e:Remove()
	end
	e.Position = Vector(-100, -100)
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.EyeOfShaggothGlowUpdate, 1808)

function mod:EyeOfShaggothGlowRender(e)
	if e.Parent then
		local d = e.Parent:GetData()
		if d.CapturedProjectiles then
			for i = #d.CapturedProjectiles, 1, -1 do
				local projData = d.CapturedProjectiles[i]
				local proj = projData.Projectile:ToProjectile()
				
				local heightcalc = math.abs(-18 / proj.Height)
				
				shaggothGlowSprite.Offset = Vector(0, -18 + math.max(1, heightcalc))
				if shaggothMarker then
					shaggothGlowSprite.Color = shaggothMarker.Color
				end
				
				if proj.Variant == ProjectileVariant.PROJECTILE_GRID then
					shaggothGlowSprite.Scale = Vector(3.5, 3.5)
				elseif proj.Height then
					local mult = Color(1, 1, 1, math.min(1, heightcalc ^ 2))
					local color = shaggothGlowSprite.Color
					shaggothGlowSprite.Color = mult * color
				end
				
				shaggothGlowSprite:Render(Isaac.WorldToScreen(proj.Position), Vector.Zero, Vector.Zero)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, mod.EyeOfShaggothGlowRender, 1808)
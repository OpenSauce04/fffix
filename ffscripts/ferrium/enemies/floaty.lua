local mod = FiendFolio
local sfx = SFXManager()

local floatyDirs = {
}

--I1 is movement? If constantly set, prevents it from firing.
--V1.X is angle it is pointing in. 0-11, 30 degrees each. 0 is straight down.
--Positive on left, negative on right. 

function mod:floatyAI(npc)
	local data = npc:GetData()
	local sprite = npc:GetSprite()
	local rng = npc:GetDropRNG()
	
	if not data.init then
		data.stateFrame = 0
		data.init = true
	else
		data.stateFrame = data.stateFrame+1
	end
	
	npc.I1 = -50
	--npc.V1 = Vector(data.stateFrame,0)
	if not data.firing and data.stateFrame > 30 and npc.Velocity:Length() > 1 and not mod:isScareOrConfuse(npc) then
		local angle = math.abs(npc.V1.X)
		if angle > 29 and angle < 60 then
			if npc.V1.X > 0 then
				data.anim = "01"
				data.vec = Vector(-1,1)
			else
				data.anim = "11"
				data.vec = Vector(1,1)
			end
			data.setAngle = npc.V1.X
			data.firing = true
			data.stateFrame = 0
		elseif angle > 119 and angle < 150 then
			if npc.V1.X > 0 then
				data.anim = "04"
				data.vec = Vector(-1,-1)
			else
				data.anim = "08"
				data.vec = Vector(1,-1)
			end
			data.setAngle = npc.V1.X
			data.firing = true
			data.stateFrame = 0
		end
	elseif data.firing then
		if data.stateFrame > 20 then
			data.stateFrame = 0 
			data.firing = nil
			data.fired = nil
		elseif data.stateFrame == 5 and not data.fired then
			data.fired = true
			npc:PlaySound(SoundEffect.SOUND_BOSS_LITE_SLOPPY_ROAR, 1, 0, false, 2)
			npc:PlaySound(SoundEffect.SOUND_HEARTOUT, 0.35, 0, false, 1)
			local greenColor = Color(0.1,1,1,1,0,0.3,0.1)
			for i=1,4 do
				mod.scheduleForUpdate(function()
					if mod:isFriend(npc) then
						local creep = Isaac.Spawn(1000, 46, 0, npc.Position+data.vec:Resized(30*i), Vector.Zero, npc):ToEffect()
						local num = (10+i)/10
						creep.SpriteScale = Vector(num, num)
						creep.Color = greenColor
						local poof = Isaac.Spawn(1000, 2, 160, npc.Position+data.vec:Resized(30*i), Vector.Zero, npc):ToEffect()
						poof.Color = greenColor
						local num2 = (5+i)/10
						poof.SpriteScale = Vector(0.5,0.5)
						local splat = Isaac.Spawn(1000, 7, 0, npc.Position+data.vec:Resized(30*i), Vector.Zero, npc):ToEffect()
						splat.Color = greenColor
					else
						local creep = Isaac.Spawn(1000, 23, 0, npc.Position+data.vec:Resized(30*i), Vector.Zero, npc):ToEffect()
						local num = (10+i)/10
						creep.SpriteScale = Vector(num, num)
						local poof = Isaac.Spawn(1000, 2, 160, npc.Position+data.vec:Resized(30*i), Vector.Zero, npc):ToEffect()
						poof.Color = greenColor
						local num2 = (5+i)/10
						poof.SpriteScale = Vector(0.5,0.5)
						local splat = Isaac.Spawn(1000, 7, 0, npc.Position+data.vec:Resized(30*i), Vector.Zero, npc):ToEffect()
						splat.Color = greenColor
						--For the flying players, thank bloaty for this
						for _,player in ipairs(Isaac.FindByType(1, -1, -1, false, false)) do
							if player.Position:Distance(npc.Position+data.vec:Resized(30*i)) < 25 then
								player:TakeDamage(1, 0, EntityRef(creep), 0)
							end
						end
					end
					local params = ProjectileParams()
					params.Scale = 0.4
					params.Color = mod.ColorIpecacProper
					params.FallingSpeedModifier = mod:getRoll(-16,-10,rng)
					params.FallingAccelModifier = mod:getRoll(100,120,rng)/100
					npc:FireProjectiles(npc.Position, data.vec:Resized(rng:RandomInt(5)+i):Rotated(mod:getRoll(-10,10,rng)), 0, params)
				end, i)
			end
		else
			sprite:SetFrame("Attack" .. data.anim, data.stateFrame)
		end
		npc.V1 = Vector(data.setAngle, 0)
	end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, npc, damage, flag, source)
	if npc.Variant == 0 and npc.SubType == mod.FF.Floaty.Sub then
		mod.scheduleForUpdate(function()
			if sfx:IsPlaying(SoundEffect.SOUND_SHAKEY_KID_ROAR) then
				sfx:Stop(SoundEffect.SOUND_SHAKEY_KID_ROAR)
			end
		end, 2)
	end
end, 812)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, e)
	if e.SpawnerEntity and e.SpawnerEntity:ToNPC() then
		local npc = e.SpawnerEntity:ToNPC()
		if npc.Type == mod.FF.Floaty.ID and npc.Variant == mod.FF.Floaty.Var and npc.SubType == mod.FF.Floaty.Sub then
			e.Color = Color(0.1,1,1,1,0,0.3,0.1)
		end
	end
end, 7)
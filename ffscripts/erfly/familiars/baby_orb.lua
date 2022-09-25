local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local player = fam.Player
	local d = fam:GetData()
	local sprite = fam:GetSprite()

	if not d.init then
		d.init = true
	end
	d.stateframe = d.stateframe or 0
	d.stateframe = d.stateframe + 1

	d.target = d.target or nil
	if d.target then
		if fam.Position:Distance(d.target) < 20 then
			if math.random(3) == 1 then
				d.target = nil
				d.stateframe = 0
			else
				d.target = Isaac.GetRandomPosition()
				if math.random(3) == 1 then
					for i = 30, 360, 30 do
						local expvec = Vector(0,math.random(10,15)):Rotated(i)
						local sparkle = Isaac.Spawn(1000, 1727, 0, fam.Position + expvec * 0.1, expvec * 0.3, fam):ToEffect()
						sparkle.SpriteOffset = Vector(0,-25)
						sparkle:Update()
					end
					fam.Position = d.target
				else
					fam.Velocity = ((d.target or fam.Position) - fam.Position):Resized(fam.Velocity:Length())
				end
			end
		end
	else
		if (d.stateframe >= 0 and math.random(60) == 1) or d.stateframe > 120 then
			d.target = Isaac.GetRandomPosition()
			if math.random(3) == 1 then
				for i = 30, 360, 30 do
					local expvec = Vector(0,math.random(10,15)):Rotated(i)
					local sparkle = Isaac.Spawn(1000, 1727, 0, fam.Position + expvec * 0.1, expvec * 0.3, fam):ToEffect()
					sparkle.SpriteOffset = Vector(0,-25)
					sparkle:Update()
				end
				fam.Position = d.target
			end
		end
		fam.Velocity = fam.Velocity * 0.95
	end
	fam.Velocity = mod:Lerp(fam.Velocity, ((d.target or fam.Position) - fam.Position):Resized(15), 0.05)


	d.frame = d.frame or 0
	local speed = math.max(math.floor(fam.Velocity:Length() / 3), 1)
	if fam.Velocity.X > 0 then
		d.frame = d.frame + speed
	else
		d.frame = d.frame - speed
	end
	d.frame = d.frame % 120
	sprite:SetFrame("Idle", d.frame)
	fam.SpriteScale = Vector(0.3, 0.3)
	fam.SpriteOffset = Vector(0, -15)

end, FamiliarVariant.BABY_ORB)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, fam, collider)
	if collider.Type > 9 and collider.EntityCollisionClass >= 2 then
		local d = fam:GetData()
		if d.stateframe and d.stateframe >= 0 then
			d.target = nil
			d.stateframe = 0 - math.random(15)
			fam.Velocity = fam.Velocity * -1
			if fam.Velocity:Length() < 1 then
				fam.Velocity = (fam.Position - collider.Position):Resized(10)
			end
			fam.Color = Color(math.random(),math.random(),math.random(),1,math.random(),math.random(),math.random())
			sfx:Play(SoundEffect.SOUND_BEEP,1,0,false,math.random(5,20)/100)
			collider:TakeDamage(fam.Velocity:Length(), 0, EntityRef(fam.Player), 0)
		end
	end
end, FamiliarVariant.BABY_ORB)
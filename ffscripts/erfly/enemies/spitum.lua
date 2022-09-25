local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:spitumAI(npc)
	local d = npc:GetData()
	local sprite = npc:GetSprite();
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()

	if not d.init then
		npc.SpriteOffset = Vector(0, -5)
		d.state = "idle"
		d.init = true
		npc.SplatColor = mod.ColorSpittyGreen
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if not (d.state == "airtime" or d.state == "slam") then
		if npc.Position.X > target.Position.X then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end

		npc.Velocity = npc.Velocity * 0.7
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		if npc.StateFrame > 65 and r:RandomInt(20)+1 == 1 and game:GetRoom():CheckLine(target.Position,npc.Position,3,900,false,false) and not mod:isScareOrConfuse(npc) then
			d.state = "sneeze"
		end
	elseif d.state == "sneeze" then
		if sprite:IsFinished("Shoot") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:GetFrame() == 1 then
			npc:PlaySound(FiendFolio.Sounds.SpitumCharge,1,0,false,math.random(95,105)/100)
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(FiendFolio.Sounds.SpitumShoot,1,0,false,math.random(95,105)/100)
			for i = 1, 10 do
				local proj = Isaac.Spawn(9, 0, 0, npc.Position, (target.Position - npc.Position):Resized(math.random(5,8)):Rotated(-20+math.random(40)), npc):ToProjectile()
				proj.Scale = math.random(8,10)/10
				proj.Color = mod.ColorSpittyGreen
				proj.FallingSpeed = -15 - math.random(20)/10
				proj.FallingAccel = 0.9 + math.random(10)/10
				local pd = proj:GetData()
				pd.projType = "acidic splot"
				if npc.SpawnerEntity and npc.SpawnerEntity.Type == 20 then
					pd.creepTimer = 30
				end
			end
		else
			mod:spritePlay(sprite, "Shoot")
		end
	elseif d.state == "airtime" then
		mod:spritePlay(sprite, "Airtime")
		npc.StateFrame = npc.StateFrame + 2
		sprite.Offset = Vector(0, -2 * (-0.025 * ((npc.StateFrame - 45)^2) + 52))
		if sprite.Offset.Y >= 0 then
			sprite.Offset = Vector(0, -5)
			d.state = "slam"
			npc.StateFrame = 0
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			mod:spritePlay(sprite, "Slam")
			local creep = Isaac.Spawn(1000, EffectVariant.CREEP_GREEN, 0, npc.Position, Vector(0,0), npc):ToEffect();
			creep.SpriteScale = Vector(1.5, 1)
			creep:SetTimeout(math.floor(creep.Timeout * 0.75))
			creep:SetColor(Color(0, 0, 0, 1, 99 / 255, 56 / 255, 74 / 255), 60, 99999, true, false)
			creep:Update()
		end
		if npc.Velocity.X < 0 then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end
	elseif d.state == "slam" then
		npc.Velocity = npc.Velocity * 0.5
		if sprite:IsFinished("Slam") then
			d.state = "idle"
			npc.StateFrame = 0
		end
	end
end
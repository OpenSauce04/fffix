local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--buck shit starts here
function mod:BombPickupUpdate(pickup)
	local d = pickup:GetData()
	if d.buckBomb then
		if pickup.FrameCount > 30 then
			--local poof = Isaac.Spawn(1000, EffectVariant.POOF01, 15, pickup.Position, nilvector, nil)
			--sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 0.3, 0, false, 0.7)
			Isaac.Spawn(4,0,0,pickup.Position, nilvector, pickup)
			pickup:Remove()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.BombPickupUpdate, 40)

function mod.IsRefSpawnerBuckOrSnagger(ref)
	for _, v in pairs(Isaac.GetRoomEntities()) do
		if ref.Entity and ref.Entity.Index == v.Index then
			--Isaac.ConsoleOutput("found")
			if v.SpawnerEntity then
				if v.SpawnerEntity.Type == mod.FF.Snagger.ID or v.SpawnerEntity.Type == mod.FF.Buck.ID then
					return true
				end
			end
		end
	end
	if ref.Entity then
		if ref.Entity.SpawnerType == mod.FF.Snagger.ID or ref.Entity.SpawnerType == mod.FF.Buck.ID or ref.Entity.SpawnerType == 9 then
			return true
		end
	end
	if ref.SpawnerType == mod.FF.Snagger.ID or ref.SpawnerType == mod.FF.Buck.ID then
		return true
	end
	return false
end

function mod:idleOrPassBomb(npc,npcdata,sprite)
	local snaggers = mod.GetAllEntities(npc,mod.FF.Snagger.ID,mod.FF.Snagger.Var,0);

	if #snaggers > 0 then
		npcdata.state = "passbomb"
		mod:spritePlay(sprite, "PassBomb")
		npc.StateFrame = 0;

		for i = 1, #snaggers, 1 do
			snaggers[i]:GetData().frozen_by_buck = true
		end
	else
		npcdata.state = "idle";
		npc.StateFrame = 0;
	end
end

function mod:buckRenderAI(npc)
	local sprite = npc:GetSprite()
	if sprite:IsPlaying("Death") then
		if sprite:IsEventTriggered("HeadThrow") then
			npc:PlaySound(mod.Sounds.BuckDeath1, 1, 0, false, 1)
		elseif sprite:IsEventTriggered("SFXDed1") then
			npc:PlaySound(mod.Sounds.BuckDeath2, 1, 0, false, 1)
		elseif sprite:IsEventTriggered("SFXDed2") then
			npc:PlaySound(mod.Sounds.BuckDeath3, 1, 0, false, 1)
		elseif sprite:IsEventTriggered("Explode") then
			if not npc:GetData().doneSploded then
				npc:BloodExplode()
				npc:GetData().doneSploded = true
			end
		else
			npc:GetData().doneSploded = false
		end
		if npc.SubType == 0 and game:GetRoom():GetType() == RoomType.ROOM_BOSS and not npc:GetData().checkedForBag then
			npc:GetData().checkedForBag = true
			local bags = Isaac.FindByType(8, 4, -1, false, false)
			for _, bag in pairs(bags) do
				if bag:GetSprite():GetAnimation() == "Swing" then
					Isaac.Spawn(5, 100, mod.ITEM.COLLECTIBLE.MYSTERY_BADGE, npc.Position, Vector.Zero, nil)
					break
				end
			end
		end
	end
end

function mod:buckAI(npc, sprite, npcdata)
	local target = npc:GetPlayerTarget();

	local shoot_duration = 200;
	local sack_duration = 60;
	local bomb_duration = 60;

	local bomb_count = 4;

	local attack_cooldown = 30;
	local spread = 2;

	local attack_count = 3;

	local r = npc:GetDropRNG();

	--SoundStuff
		if sprite:IsEventTriggered("SFXCharge") then
			npc:PlaySound(mod.Sounds.BuckCharge, 1, 0, false, 1)
		elseif sprite:IsEventTriggered("Gasp") then
			npc:PlaySound(mod.Sounds.BuckAppear1, 1, 0, false, 1)
		elseif sprite:IsPlaying("Appear") and sprite:GetFrame() == 34 then
			npc:PlaySound(mod.Sounds.BuckAppear2, 1, 0, false, 1)
		elseif sprite:IsPlaying("StartRummage") and sprite:GetFrame() == 2 then
			npc:PlaySound(mod.Sounds.BuckRummage, 1, 0, false, 1)
		elseif sprite:IsEventTriggered("Throw") and not sprite:IsPlaying("RummageQuick") then
			npc:PlaySound(SoundEffect.SOUND_SHELLGAME, 0.6, 0, false, 0.8)
		elseif sprite:IsEventTriggered("Throw") and sprite:IsPlaying("RummageQuick") then
			npc:PlaySound(SoundEffect.SOUND_SHELLGAME, 0.6, 0, false, 0.8)
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(mod.Sounds.BuckSpit, 1, 0, false, 1)
		elseif sprite:IsPlaying("StartShoot") and sprite:GetFrame() == 1 then
			npc:PlaySound(mod.Sounds.BuckShoot, 1, 0, false, 1)
		elseif sprite:IsPlaying("EndRummage") and sprite:GetFrame() == 15 then
			npc:PlaySound(mod.Sounds.BuckHeadRecover, 1, 0, false, 1)
		elseif sprite:IsPlaying("ShootEnd") and sprite:GetFrame() == 3 then
			sfx:Play(mod.Sounds.BuckHeadRecover, 3, 0, false, 1.15)
		end

		if mod.allPlayersDead() then
			npc:PlaySound(mod.Sounds.BuckVictory, 1, 0, false, 1)
		end

	--Isaac.DebugString(npc.State)
	--Isaac.ConsoleOutput(npc.State .. "\n")
	if sprite:IsPlaying("Death") then
		npc.Velocity = nilvector
		if sprite:IsFinished("Death") then
			npc:Kill()
		else
			mod:spritePlay(sprite, "Death")
		end
		if sprite:IsEventTriggered("Explode") then
			npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,0.2,0,false,0.8)
			npc:BloodExplode()
		end
	elseif npcdata.state == "init" then
		npcdata.next_attack = 0;
		npcdata.charge_timer = 0;
		npcdata.charge_cooldown = 20;
		npcdata.rummage_counter = 0
		npcdata.shoot_direction = "ShootDown"
		npcdata.charge_direction = "ChargeDown"
		mod:idleOrPassBomb(npc,npcdata,sprite)
	elseif npcdata.state == "idle" then
		npcdata.target_velocity = nilvector;
		mod:spritePlay(sprite, "Idle2");
		npcdata.previous_sprite = "Idle2"
		if npc.StateFrame > attack_cooldown then
			npcdata.next_attack = npcdata.next_attack + 1;
			if npcdata.next_attack > attack_count then npcdata.next_attack = 1 end
			if npcdata.next_attack == 3 then
				if math.random(0,1) == 0 then npcdata.state = "attack3" else
					npcdata.state = "rummage"
					npcdata.rummage_counter = 0
				end
			else
				npcdata.state = "attack"..npcdata.next_attack;
			end
			npc.StateFrame = 0;
		end
	elseif npcdata.state == "attack1" then --shooting
		npcdata.target_velocity = nilvector;

		local toggle
		if npc.StateFrame == 1 then
			npcdata.tracking = false;
			npcdata.target_pos = target.Position;
			toggle = true
			npcdata.shoot_toggle = false
			mod:spritePlay(sprite, "StartShoot");
			npcdata.previous_sprite = "StartShoot"
			npcdata.shotAtALez = false
		end

		if sprite:IsFinished("StartShoot") then
			mod:spritePlay(sprite, "ShootDown");
			npcdata.previous_sprite = "ShootDown"
		end

		if sprite:IsPlaying("ShootDown") or sprite:IsPlaying("ShootDiagDown") or sprite:IsPlaying("ShootHori") or sprite:IsPlaying("ShootUp") or sprite:IsPlaying("ShootDiagUp") then
			if not sprite:IsPlaying(npcdata.shoot_direction) then
				mod:spritePlay(sprite, npcdata.shoot_direction)
				npcdata.previous_sprite = npcdata.shoot_direction
			end

			local closeLez = mod.FindClosestEntity(target.Position, 200, mod.FF.Lez.ID, mod.FF.Lez.Var, mod.FF.Lez.Sub)
			if closeLez and closeLez:Exists() and closeLez:GetData().state == "idle" and not npcdata.shotAtALez then
				npcdata.targetedLez = closeLez
				npcdata.LezTimer = 60
				npcdata.shotAtALez = true

				local lezD = closeLez:GetData()
				lezD.suck_end_counter = 0
				lezD.sucked_bullets = 0
				lezD.state = "suck"
				closeLez:ToNPC().StateFrame = 0
				mod:spritePlay(closeLez:GetSprite(), "OpenMouth")
			end

			if npcdata.targetedLez and npcdata.targetedLez:Exists() and npcdata.LezTimer and npcdata.LezTimer > 0 then
				target = npcdata.targetedLez
				npcdata.LezTimer = npcdata.LezTimer - 1
			end

			local angle = math.atan((target.Position.Y-npc.Position.Y)/(target.Position.X-npc.Position.X));
			angle = math.deg(angle);
			if npc.Position.X >= target.Position.X then
				angle = angle + 180;
			end

			--Isaac.ConsoleOutput(angle .. "\n")
			npcdata.shootoffH = 0
			if angle > -23 and angle <= 22 then
				npcdata.shoot_direction = "ShootHori"
				sprite.FlipX = false
				npcdata.shootoffL = 35
			elseif angle > 22 and angle <= 67 then
				npcdata.shoot_direction = "ShootDiagDown"
				sprite.FlipX = false
				npcdata.shootoffL = 10
				npcdata.shootoffH = 10
			elseif angle > 67 and angle <= 112 then
				npcdata.shoot_direction = "ShootDown"
				npcdata.shootoffL = 0
			elseif angle > 112 and angle <= 157 then
				npcdata.shoot_direction = "ShootDiagDown"
				sprite.FlipX = true
				npcdata.shootoffL = 10
				npcdata.shootoffH = -10
			elseif angle > 157 and angle <= 202 then
				npcdata.shoot_direction = "ShootHori"
				sprite.FlipX = true
				npcdata.shootoffL = 35
			elseif angle > 202 and angle <= 247 then
				npcdata.shoot_direction = "ShootDiagUp"
				sprite.FlipX = true
				npcdata.shootoffL = 10
			elseif (angle > 247 and angle < 270) or angle < -78 then
				npcdata.shoot_direction = "ShootUp"
				npcdata.shootoffL = 0
			else
				npcdata.shoot_direction = "ShootDiagUp"
				sprite.FlipX = false
				npcdata.shootoffL = 10
			end

			if npc.FrameCount % 15 == 0 then
				toggle = true
			end

			if toggle then
				npcdata.shoot_toggle = not npcdata.shoot_toggle
				npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, 1)
				local params = ProjectileParams()
				if npcdata.shoot_toggle then
					npc:FireBossProjectiles(5, target.Position, 10, params)
				else
					params.FallingAccelModifier = 2
					npc:FireBossProjectiles(3, target.Position, 10, params)
				end
			end

			if npc.FrameCount % 2 == 0 and npcdata.shoot_toggle then
				npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, 1)

				local vel = (target.Position - npc.Position):Normalized() * 15;

				local vel2 = (vel + Vector(math.random(-spread, spread), math.random(-spread, spread))):Normalized();
				local rand = r:RandomFloat()
				local params = ProjectileParams()
				params.HeightModifier = 15

				params.FallingSpeedModifier = -3

				params.FallingAccelModifier = 0
				params.Scale = math.random(12, 15)/10

				npc:FireProjectiles(npc.Position + Vector(npcdata.shootoffH, 0) + vel2:Resized(npcdata.shootoffL), vel2 * 8, 0, params)

				--local projectile = Isaac.Spawn(9, 0, 0, npc.Position, vel2 * 8, npc):ToProjectile();
				--local projdata = projectile:GetData();
				--projectile.FallingSpeed = -2
				--projectile.FallingAccel = 0
				--projectile.Velocity = projectile.Velocity * (math.random(16, 18)/7.5)
				--projectile.Scale = math.random(12, 15)/10
				-- + RandomVector() * math.random(-3,3)
			end

			--[[
			if npc.StateFrame == 75 then
			--	mod:spritePlay(sprite, "StartShoot");
			--	npcdata.previous_sprite = "StartShoot"
				npcdata.tracking = true;
			end
			if npcdata.tracking then
				npcdata.target_pos = target.Position;
			end]]
		end

		if npc.StateFrame > shoot_duration then
			mod:spritePlay(sprite, "ShootEnd")
			npcdata.previous_sprite = "ShootEnd"
		end

		if sprite:IsFinished("ShootEnd") then
			mod:idleOrPassBomb(npc,npcdata,sprite)
		end
	elseif npcdata.state == "attack2" then --snagger spawn
		if npc.StateFrame == 1 then
			npcdata.throw_vel = RandomVector() * 20;
			mod:spritePlay(sprite, "SpawnSnagger")
		end

		if sprite:IsEventTriggered("Shoot") then
			if sprite:IsPlaying("SpawnSnagger") then
				local top_left = room:GetTopLeftPos()
				local bottom_right = room:GetBottomRightPos()
				local snag = Isaac.Spawn(mod.FF.Snagger.ID,mod.FF.Snagger.Var,0,Vector(math.random(top_left.X, bottom_right.X),-20), nilvector, npc);
				snag:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				snag:GetData().spawned_by_buck = true
				snag:Update()
				npc:PlaySound(SoundEffect.SOUND_SUMMONSOUND,0.6,1,false,1)

				--spawn lez
				local vel = (target.Position - npc.Position):Normalized()
				local lez_count = mod.GetAllEntities(npc,mod.FF.Lez.ID, mod.FF.Lez.Var, mod.FF.Lez.Sub);

				if #lez_count < 3 then
					local vel2 = vel * math.random(5,7);
					local r = npc:GetDropRNG()
					local rand = r:RandomFloat()
					local lez = Isaac.Spawn(mod.FF.Lez.ID, mod.FF.Lez.Var, mod.FF.Lez.Sub, npc.Position, Vector(vel2.X + math.random(-spread, spread), vel2.Y + math.random(-spread, spread)), npc):ToNPC();
					local lezdata = lez:GetData();
					lezdata.downvelocity = -20 + math.random(10);
					lezdata.downaccel = 1
					lez.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					lez.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
					lez:GetSprite().Offset = Vector(0, -1)
					lezdata.state = "air"
					lezdata.hop_delay = 60
					lez.StateFrame = 0
					lez:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				end
			end
		end

		if sprite:IsFinished("SpawnSnagger") then
			mod:idleOrPassBomb(npc,npcdata,sprite)
		end

		--elseif npc.StateFrame == sack_duration - 10 then

			--elseif pickup == 2 then
			--	Isaac.Spawn(5,40,4,npc.Position, npcdata.throw_vel, npc);
			--elseif pickup == 3 then
			--	Isaac.Spawn(5,40,2,npc.Position, npcdata.throw_vel, npc);
			--end
		--end

		--if npc.StateFrame > sack_duration then
		--	npcdata.state = "idle";
		--	npc.StateFrame = 0;
		--end
	elseif npcdata.state == "passbomb" then
		if sprite:IsEventTriggered("Shoot") then
			local snaggers = mod.GetAllEntities(npc,mod.FF.Snagger.ID,mod.FF.Snagger.Var,0);

			if #snaggers > 0 then
				for i = 1, #snaggers, 1 do
					--npcdata.throw_vel = (snaggers[i].Position + snaggers[i].Velocity*5 - npc.Position):Normalized():Resized(10)
					npcdata.throw_vel = (snaggers[i].Position - npc.Position):Normalized():Resized(10)
					local pickup = math.random(1,3); --only spawn pickups a snagger can throw

					bombshot = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_BONE, 0, npc.Position, npcdata.throw_vel, npc):ToProjectile()
					bombd = bombshot:GetData()
					bombd.projType = "buckbomb"
					if ammosub == 4 then bombd.projTypeS = true end
					bombshot.FallingSpeed = -20
					bombshot.FallingAccel = 1.2
					bombshot.Scale = 1
				end
			end

			local lez = mod.GetAllEntities(npc,mod.FF.Lez.ID,mod.FF.Lez.Var,mod.FF.Lez.Sub)

			local proj_type
			local proj_variant
			local proj_scale

			if #lez > 0 then
				for i = 1, #lez, 1 do
					if lez[i]:GetData().state == "idle" or lez[i]:GetData().state == "air" then
						npcdata.throw_vel = (lez[i].Position - npc.Position):Normalized():Resized(15)

						if math.random(0,1) == 0 then
							proj_type = "buckbomb"
							proj_variant = ProjectileVariant.PROJECTILE_BONE
							proj_scale = 1
						else
							proj_type = "buckball"
							proj_variant = 0
							proj_scale = 3
						end

						bombshot = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, proj_variant, 0, npc.Position, npcdata.throw_vel, npc):ToProjectile()
						bombd = bombshot:GetData()
						bombd.projType = proj_type
						--if ammosub == 4 then bombd.projTypeS = true end
						bombshot.FallingSpeed = -20
						bombshot.FallingAccel = 1.2
						bombshot.Scale = proj_scale
					end
				end
			end
		end

		if sprite:IsFinished("PassBomb") then
			local snaggers = mod.GetAllEntities(npc,mod.FF.Snagger.ID,mod.FF.Snagger.Var,0);
			--print("stoppd")
			if #snaggers > 0 then
				for i = 1, #snaggers, 1 do
					snaggers[i]:GetData().frozen_by_buck = false
				end
			end
			npcdata.state = "idle";
			npc.StateFrame = 0;
		end
	elseif npcdata.state == "attack3" then --bomb throwing
		if npc.StateFrame == 1 then
			npcdata.bomb_counter = 1;
			sprite:Play("StartRummage", false);
			npcdata.previous_sprite = "StartRummage"
		end

		if sprite:IsFinished("StartRummage") then
			mod:spritePlay(sprite, "RummageQuick")
			npcdata.previous_sprite = "RummageQuick"
		end

		--if npc.StateFrame == 10 then
		--	sprite:Play("RummageQuick", false);
		--end

		if sprite:IsEventTriggered("Throw") then
			if npcdata.bomb_counter < bomb_count then
				local rand = r:Next()
				local projectile = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_BONE, 0, npc.Position, RandomVector():Resized(2), npc):ToProjectile();
				local projdata = projectile:GetData();
				projectile.FallingSpeed = -50 + math.random(10);
				projectile.FallingAccel = 1.5
				projectile.Velocity = projectile.Velocity * (math.random(12, 20)/10)
				projectile.Scale = math.random(8, 12)/10
				projdata.projType = "thrownbomb";
				projectile.SpawnerEntity = npc
				npcdata.bomb_counter = npcdata.bomb_counter + 1;
			else
				mod:spritePlay(sprite, "EndRummage")
			end
		end

		if sprite:IsFinished("EndRummage") then
			mod:idleOrPassBomb(npc,npcdata,sprite)
		end

	elseif npcdata.state == "rummage" then
		if npc.StateFrame == 1 then
			mod:spritePlay(sprite, "StartRummage");
			npcdata.previous_sprite = "StartRummage"
		end

		if sprite:IsEventTriggered("Throw") then
			if sprite:IsPlaying("Rummage1") then
				local vel = (target.Position - npc.Position):Resized(5)
				for i = 1, 4 do
					Isaac.Spawn(18, 0, 0, npc.Position, vel, npc)
				end
			elseif sprite:IsPlaying("Rummage2") then
				for i = 1, 3, 1 do
					local rand = r:Next()
					local projectile = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_BONE, 0, npc.Position, RandomVector():Resized(2), npc):ToProjectile();
					local projdata = projectile:GetData();
					projectile.SpawnerEntity = npc
					projectile.FallingSpeed = -50 + math.random(10);
					projectile.FallingAccel = 1.5
					projectile.Velocity = projectile.Velocity * (math.random(12, 20)/7)
					projectile.Scale = math.random(8, 12)/10
					projdata.projType = "buckbomb";
				end
			else
				for i = 1, 15, 1 do
					local rand = r:Next()
					local projectile = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, npc.Position, RandomVector():Resized(2), npc):ToProjectile();
					local projdata = projectile:GetData();
					projectile.FallingSpeed = -25 + math.random(10);
					projectile.FallingAccel = 0.5
					projectile.Velocity = projectile.Velocity * (math.random(12, 20)/8)
					projectile.Scale = math.random(8, 12)/8
				end
			end
		end

		if sprite:IsFinished("StartRummage") or sprite:IsFinished("Rummage1") or sprite:IsFinished("Rummage2") or sprite:IsFinished("Rummage3") then
			local rng = math.random(1,3);
			npcdata.rummage_counter = npcdata.rummage_counter + 1

			if rng == 1 then
				mod:spritePlay(sprite, "Rummage1");
				npcdata.previous_sprite = "Rummage1"
			elseif rng == 2 then
				mod:spritePlay(sprite, "Rummage2");
				npcdata.previous_sprite = "Rummage2"
			elseif rng == 3 then
				mod:spritePlay(sprite, "Rummage3");
				npcdata.previous_sprite = "Rummage3"
			else

			end
		end

		if npcdata.rummage_counter > 3 then
			mod:spritePlay(sprite, "EndRummage")
		end

		if sprite:IsFinished("EndRummage") then
			mod:idleOrPassBomb(npc,npcdata,sprite)
		end
	elseif npcdata.state == "charge" then
		if sprite:IsEventTriggered("Hop") then
			npcdata.target_velocity = (target.Position - npc.Position):Resized(15);

		end
		--elseif npc.StateFrame < 20 and npc.StateFrame > 10 then npcdata.target_velocity = npcdata.target_velocity / 1.5
		if sprite:IsEventTriggered("Land") then npcdata.target_velocity = nilvector end

		if sprite:IsFinished(npcdata.charge_direction) then
			--if npcdata.previous_frame then npc.StateFrame = npcdata.previous_frame else npc.StateFrame = 0 end
			if npcdata.previous_state then
				if npcdata.previous_state == "attack1" then
					npcdata.state = "attack1"
					mod:spritePlay(sprite, "StartShoot")
					if npcdata.previous_frame then 
						--dont bother going back to shooting state if youre so close to being done that youre not going to start firing anyway
						if npcdata.previous_frame < shoot_duration - 10 then
							npc.StateFrame = npcdata.previous_frame - 36
						else
							mod:idleOrPassBomb(npc,npcdata,sprite)
						end
					else 
						npc.StateFrame = 0 
					end
				else
					npcdata.state = npcdata.previous_state

					if npcdata.previous_frame then npc.StateFrame = npcdata.previous_frame else npc.StateFrame = 0 end

					if npcdata.previous_sprite then
						mod:spritePlay(sprite, npcdata.previous_sprite)
						--if npcdata.previous_sprite_frame then sprite:SetFrame(npcdata.previous_sprite, npcdata.previous_sprite_frame) end
					else mod:spritePlay(sprite, "Idle2") end
				end
			else npcdata.state = "idle" end
			--if npcdata.previous_sprite then
			--	mod:spritePlay(sprite, npcdata.previous_sprite)
			--	if npcdata.previous_sprite_frame then sprite:SetFrame(npcdata.previous_sprite, npcdata.previous_sprite_frame) end
			--else mod:spritePlay(sprite, "Idle2") end
		end
	elseif npcdata.state == "appear" then
		if sprite:IsFinished("Appear") then
			npcdata.state = "init"
		end
	else
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npcdata.state = "appear"
		sprite:Play("Appear", true)

		local champSheet
		if mod.IsDeliriumRoom then
			champSheet = "gfx/bosses/buck/boss_buck_cummie.png"
		end
		if champSheet then
			for i = 0, 1 do
				sprite:ReplaceSpritesheet(i, champSheet)
			end
			sprite:LoadGraphics()
		end
	end

	if not sprite:IsPlaying("StartRummage") and not sprite:IsPlaying("EndRummage") and not sprite:IsPlaying("StartShoot") and not sprite:IsPlaying("ShootEnd") and not sprite:IsPlaying("SpawnSnagger") and not sprite:IsPlaying("PassBomb") then
		if npc.FrameCount > 20 and (npc.Position:Distance(target.Position) < 125) and npcdata.charge_cooldown == 0 and npcdata.state ~= "charge" then
			npcdata.charge_timer = npcdata.charge_timer + 1;
		else
			npcdata.charge_timer = 0;
		end
	end

	if npcdata.charge_timer > 10 then
		npcdata.charge_cooldown = 120;
		npcdata.charge_timer = 0;

		npcdata.previous_state = npcdata.state;
		npcdata.previous_frame = npc.StateFrame;
		npcdata.previous_sprite_frame = sprite:GetFrame()

		npcdata.target_pos = target.Position;

		local angle = math.atan((npcdata.target_pos.Y-npc.Position.Y)/(npcdata.target_pos.X-npc.Position.X));
		angle = math.deg(angle);
		if npc.Position.X >= npcdata.target_pos.X then
			angle = angle + 180;
		end

		if angle <= 22 or angle > 338 then
			npcdata.charge_direction = "ChargeHori"
			sprite.FlipX = false
		elseif angle > 22 and angle <= 67 then
			npcdata.charge_direction = "ChargeDown"
			sprite.FlipX = false
		elseif angle > 67 and angle <= 112 then
			npcdata.charge_direction = "ChargeDown"
		elseif angle > 112 and angle <= 157 then
			npcdata.charge_direction = "ChargeDown"
			sprite.FlipX = true
		elseif angle > 157 and angle <= 202 then
			npcdata.charge_direction = "ChargeHori"
			sprite.FlipX = true
		elseif angle > 202 and angle <= 247 then
			npcdata.charge_direction = "ChargeUp"
			sprite.FlipX = true
		elseif angle > 247 and angle < 292 then
			npcdata.charge_direction = "ChargeUp"
		else
			npcdata.charge_direction = "ChargeUp"
			sprite.FlipX = false
		end

		npcdata.state = "charge";
		mod:spritePlay(sprite, npcdata.charge_direction);
		npc.StateFrame = 0;
	end

	if npcdata.charge_cooldown then
		if npcdata.charge_cooldown > 0 then npcdata.charge_cooldown = npcdata.charge_cooldown - 1 end
	end

	if npcdata.target_velocity then
		npc.Velocity = (npcdata.target_velocity * 0.3) + (npc.Velocity * 0.6);
	else
		npc.Velocity = (nilvector * 0.3) + (npc.Velocity * 0.6);
	end

	--Isaac.DebugString(npc.StateFrame)
	--Isaac.ConsoleOutput(npcdata.state.."   "..npc.StateFrame.."\n")
	--Isaac.ConsoleOutput(npcdata.previous_sprite.."\n")
	--Isaac.ConsoleOutput(tostring(sprite:IsPlaying(npcdata.previous_sprite)).."\n")


	npc.StateFrame = npc.StateFrame + 1;

end

function mod:lezAI(npc, sprite, npcdata)
	local suck_duration = 45
	local target = npc:GetPlayerTarget();

	if sprite:IsEventTriggered("Jump") then
		npc:PlaySound(mod.Sounds.WingFlap,1,0,false,math.random(120,150)/100)
	elseif sprite:IsEventTriggered("Land") then
		npc:PlaySound(SoundEffect.SOUND_SCAMPER,1,2,false,math.random(70,80)/100)
	end

	if npc.State == 17 then
		local effect = Isaac.Spawn(1000,7000,0,npc.Position,nilvector,nil)
		local efsprite = effect:GetSprite()
		efsprite:Load(sprite:GetFilename(),true)
		efsprite:Play("Death",true)
		npc:Kill()
	elseif npcdata.state == "init" then
		npc.SplatColor = mod.ColorInvisible

		npc.StateFrame = 0;
		npcdata.state = "idle";

		npcdata.suck_end_counter = 0
		npcdata.sucked_bullets = 0

		npcdata.hop_delay = 60
	elseif npcdata.state == "idle" then
		if sprite:IsPlaying("CloseMouth") then
			if sprite:IsFinished("CloseMouth") then
				mod:spritePlay(sprite, "Idle01")
			end
		else
			mod:spritePlay(sprite, "Idle01")
		end

		npc.Velocity = nilvector

		for k,v in ipairs(Isaac.GetRoomEntities()) do
			--if v.Type == 9 and v:GetData().spawner ~= "lez" then
			if v.Type == 9 and v.SpawnerEntity and v.SpawnerEntity.Index ~= npc.Index then
				if npc.Position:Distance(v.Position) < 80 then
					--v:Remove()
					--dont eat
					npcdata.suck_end_counter = 0
					npcdata.sucked_bullets = 0
					npcdata.state = "suck"
					npc.StateFrame = 0
					mod:spritePlay(sprite, "OpenMouth")
					--npc:PlaySound(mod.Sounds.LezSuck, 1, 0, false, 1)
				end
			end
		end

		--Isaac.ConsoleOutput(npc.StateFrame.."\n")

		if npc.StateFrame > npcdata.hop_delay then
			npc.StateFrame = 0;
			npcdata.state = "jump";

		end

	--drinking bucks piss and other nice things lez likes to do
	elseif npcdata.state == "suck" then

		if sprite:IsFinished("OpenMouth") then
			mod:spritePlay(sprite, "OpenMouthLoop")
		end

		--npcdata.sexual_orientation = gay

		for k,v in ipairs(Isaac.GetRoomEntities()) do
			--if v.Type == 9 and v:GetData().spawner ~= "lez" then
			if v.Type == 9 and (not v.SpawnerEntity or v.SpawnerEntity.Index ~= npc.Index) then
				if npc.Position:Distance(v.Position) < 20 then
					if v:GetData().projType == "buckbomb" or v:GetData().projType == "thrownbomb" then --if its a buck thrown bomb
						v:Remove()
						npcdata.state = "suckbomb"
						npc.StateFrame = 0
						mod:spritePlay(sprite, "Catch01")
						--npc:PlaySound(mod.Sounds.LezEffectGet, 0.02, 0, false, 1)
						npc:PlaySound(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1)
					elseif v:GetData().projType == "buckball" then --if its a special big buck ball (thrown)
						v:Remove()
						npcdata.state = "suckball" --thats gay lol
						npc.StateFrame = 0
						mod:spritePlay(sprite, "Catch02")
						--npc:PlaySound(mod.Sounds.LezEffectGet, 0.02, 0, false, 1)
						npc:PlaySound(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1)
					else
						v:Remove()
						--eat
						npcdata.suck_end_counter = 0
						npcdata.sucked_bullets = npcdata.sucked_bullets + 1
					end
				end
			end
		end

		if npcdata.suck_end_counter > suck_duration or npcdata.sucked_bullets > 5 then
			if npcdata.sucked_bullets > 0 then
				npc.StateFrame = 0
				npcdata.state = "shoot"
				mod:spritePlay(sprite, "Attack03")
				npc:PlaySound(mod.Sounds.GlobGulp, 1, 0, false, math.random(70,80)/100)
			else
				npc:PlaySound(mod.Sounds.GlobGulp, 1, 0, false, math.random(70,80)/100)
				mod:spritePlay(sprite, "CloseMouth")
				npcdata.state = "idle"
				npc.StateFrame = 0
			end
		end

		npcdata.suck_end_counter = npcdata.suck_end_counter + 1

	elseif npcdata.state == "suckbomb" then

		if sprite:IsFinished("Catch01") then
			mod:spritePlay(sprite, "Idle02")
		end

		if npc.StateFrame > 50 then
			local distance = npc.Position:Distance(target.Position)

			if distance > 200 then --throw bomb
				npcdata.state = "throwbomb"
				npc.StateFrame = 0
			else --kamikaze chase player
				npcdata.state = "chase"
				npc.StateFrame = 0
			end
		end

	elseif npcdata.state == "throwbomb" then

		mod:spritePlay(sprite, "Attack01")

		if sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_LITTLE_SPIT,1,2,false,math.random(70,80)/100)
			local projectile = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_BONE, 0, npc.Position, (target.Position - npc.Position):Normalized() * 8, npc):ToProjectile();
			local projdata = projectile:GetData();
			projectile.FallingSpeed = -25 + math.random(10);
			projectile.FallingAccel = 1.5
			--projectile.Velocity = projectile.Velocity * (math.random(18, 22)/10)
			--projectile.Scale = math.random(8, 12)/10
			projdata.projType = "thrownbomb";
			projectile.SpawnerEntity = npc
		end

		if sprite:IsFinished("Attack01") then
			npcdata.state = "idle"
			npc.StateFrame = 0
		end
	elseif npcdata.state == "suckball" then

		if sprite:IsFinished("Catch02") then
			mod:spritePlay(sprite, "Idle03")
		end

		if npc.StateFrame > 50 then
			if math.random(3) == 1 or npcdata.alreadyJomped then
				npcdata.state = "chomp"
				npcdata.alreadyJomped = false
			else
				npcdata.state = "jompWithHaemo"
				npcdata.alreadyJomped = true
			end
			npc.StateFrame = 0
		end

	elseif npcdata.state == "jompWithHaemo" then
		if sprite:IsEventTriggered("Jump") then
			npcdata.target_velocity = (target.Position - npc.Position):Normalized():Resized(10);
		end
		if sprite:IsEventTriggered("Land") then
			npcdata.target_velocity = nilvector
		end
		if sprite:IsFinished("Jump03") then
			npcdata.state = "suckball"
			npc.StateFrame = 50
			mod:spritePlay(sprite, "Idle03")
		else
			mod:spritePlay(sprite, "Jump03")
		end


	elseif npcdata.state == "chomp" then

		mod:spritePlay(sprite, "Attack02")

		if sprite:IsEventTriggered("Shoot") then
			for i = 0, 360, 45 do
				npc:FireProjectiles(npc.Position, Vector(0,10):Rotated(i), 0, ProjectileParams())

				--local bullet = Isaac.Spawn(9, 0, 0, npc.Position, Vector(0,10):Rotated(i), npc):ToProjectile()
				--bullet:GetData().spawner = "lez"
			end
		end

		if sprite:IsPlaying("Attack02") and sprite:GetFrame() == 15 then
			npc:PlaySound(mod.Sounds.GnawfulBite,1,2,false,math.random(120,130)/100)
		end

		if sprite:IsFinished("Attack02") then
			npcdata.state = "idle"
			npc.StateFrame = 0
		end
	elseif npcdata.state == "chase" then
		mod:spritePlay(sprite, "Jump02")

		if npc.StateFrame > 240 then
			Isaac.Explode(npc.Position, npc, 10)
			npc:Kill()
		end

		if sprite:IsEventTriggered("Jump") then
			npcdata.target_velocity = (target.Position - npc.Position):Normalized():Resized(10);
		end
		if sprite:IsEventTriggered("Land") then
			npcdata.target_velocity = nilvector
		end

		--if sprite:IsFinished("Jump02") then
		--	mod:spritePlay(sprite, "Jump02")
			--npc.StateFrame = 0;
		--end
	--shooting out sucked buck bullets at player
	elseif npcdata.state == "shoot" then

		if sprite:IsFinished("Attack03") then
			mod:spritePlay(sprite, "Attack03Loop")
		end

		if target.Position.X > npc.Position.X then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end

		if npcdata.sucked_bullets > 0 then
			if sprite:IsEventTriggered("Shoot") then
				npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1)
				local vel = (target.Position - npc.Position):Normalized() --* 15;

				--local vel2 = (vel + Vector(math.random(-spread, spread), math.random(-spread, spread))):Normalized();
				--local rand = r:RandomFloat()
				local params = ProjectileParams()
				--params.HeightModifier = 15
				--params.FallingSpeedModifier = -3
				--params.FallingAccelModifier = 0
				params.Scale = math.random(12, 15)/10

				--local bullet = Isaac.Spawn(9, 0, 0, npc.Position, vel * 8, npc):ToProjectile()
				--bullet.FallingSpeed = -3
				--bullet.Height = 15
				--bullet.FallingAccel = 0
				--bullet.Scale = math.random(12, 15)/10
				--bullet:GetData().spawner = "lez"
				npc:FireProjectiles(npc.Position, vel * 8, 0, params)
				npcdata.sucked_bullets = npcdata.sucked_bullets - 1
			end

		else
			--mod:spritePlay(sprite, "CloseMouth")
			npcdata.state = "idle"
			npc.StateFrame = 0
		end

	elseif npcdata.state == "jump" then

		mod:spritePlay(sprite, "Jump01")

		if sprite:IsEventTriggered("Jump") then
			npcdata.target_velocity = RandomVector():Resized(5);
		end
		if sprite:IsEventTriggered("Land") then
			npcdata.target_velocity = nilvector
		end

		if sprite:IsFinished("Jump01") then
			npcdata.state = "idle"
			npc.StateFrame = 0;
		end
	elseif npcdata.state == "air" then --stolen shamelessly from blots code
		mod:spritePlay(sprite, "InAir");
		--mini - making airtime a thing
		sprite.Offset = Vector(0, sprite.Offset.Y + npcdata.downvelocity * 0.5)
		npcdata.downvelocity = npcdata.downvelocity + npcdata.downaccel
		if sprite.Offset.Y >= 0 then
			--land
			sprite.Offset = Vector(0,0)
			npcdata.state = "idle"
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			--dont land on pits or shit
			if not (room:GetGridCollisionAtPos(npc.Position + (npc.Velocity * 5)) == GridCollisionClass.COLLISION_NONE or room:GetGridCollisionAtPos(npc.Position) == GridCollisionClass.COLLISION_NONE) then
				npc.Position = room:FindFreeTilePosition(npc.Position,40)
			end
		end
	else npcdata.state = "init" end

	if npcdata.state ~= "air" then
		if npcdata.target_velocity then
			npc.Velocity = (npcdata.target_velocity * 0.3) + (npc.Velocity * 0.6);
			if npc.Velocity:Length() > 0.5 then
				mod:flipX(npc)
			end
		else
			npc.Velocity = (nilvector * 0.3) + (npc.Velocity * 0.6);
		end
	end

	npc.StateFrame = npc.StateFrame + 1;
end

function mod:buckHurt(npc, damage, flag, source)
	--print(flag & DamageFlag.DAMAGE_EXPLOSION)
	if flag & DamageFlag.DAMAGE_EXPLOSION > 0 and mod.IsRefSpawnerBuckOrSnagger(source) then
		return false
	end

	--local sub = npc.SubType
	--if sub == 100 then --lez death anim
	--	if npc.HitPoints - damage <= 0 then
	--		if not (npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) or npc:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE)) then
	--			npc.Velocity = nilvector
	--			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	--			npc.HitPoints = 0
	--			npc:ToNPC().State = 11
	--			return false
	--		end
	--	end
	--end

	local sub = npc.SubType
	if sub == 100 then --lez death anim
		if npc:ToNPC().State == 17 then
			return false
		end
	end
end
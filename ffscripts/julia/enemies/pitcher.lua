local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--Pitcher AI
function mod:pitcherAI(npc,sprite,npcdata)
	local target = npc:GetPlayerTarget();
	local path = npc.Pathfinder;

	local movement_speed = 3.5;

	local spread = 1;

	local max_spawned_blots = 15;

	if npc.Velocity:Length() > 1 then
		npc:AnimWalkFrame("WalkHori","WalkVert",0)
	else
		sprite:SetFrame("WalkVert", 0)
	end

	if npcdata.state == "init" then
		npcdata.attack_delay = math.random(80,100);
		npcdata.state = "move";
		npc.StateFrame = 0;
		mod:spriteOverlayPlay(sprite, "Head");
	elseif npcdata.state == "move" then
		--movement
		local targetpos = mod:confusePos(npc, target.Position)
		if room:CheckLine(npc.Position,targetpos,0,1,false,false) or mod:isScare(npc) then
			npcdata.targetvelocity = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(movement_speed))
			npc.Velocity = mod:Lerp(npc.Velocity, npcdata.targetvelocity, 0.25)
		else
			npcdata.targetvelocity = path:FindGridPath(targetpos, movement_speed/5, 1, true)
			npc.Velocity = mod:Lerp(npc.Velocity, npc.Velocity, 0.8)
		end

		--leave cosmetic tar
		if npc.FrameCount % 20 == 1 then
			local tar = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc)
			tar.SpriteScale = Vector(0.6,0.6)
			tar.Color = Color(0,0,0,0.5,0,0,0)
			tar:Update()
		end

		mod:spriteOverlayPlay(sprite, "Head");

		if npc.StateFrame > npcdata.attack_delay and not mod:isScareOrConfuse(npc) then
			if room:CheckLine(npc.Position, target.Position,3,1,false,false) then
				npcdata.state = "attack";
				npc.StateFrame = 0;
				mod:spriteOverlayPlay(sprite, "Attack");
			else
				npc.StateFrame = 0;
			end
		end
	elseif npcdata.state == "attack" then
		if sprite:GetOverlayFrame() == 20 then
			npc:PlaySound(SoundEffect.SOUND_LEECH ,0.4,0,false, 0.65)
			npc:PlaySound(SoundEffect.SOUND_MEATHEADSHOOT  ,0.4,0,false, 1)
			local vel = (target.Position - npc.Position):Normalized()
			for i = 1, math.random(8,12), 1 do
				local vel2 = vel * math.random(1,9);
				local r = npc:GetDropRNG()
				local rand = r:RandomFloat()
				local projectile = Isaac.Spawn(9, 0, 0, npc.Position, Vector(vel2.X + math.random(-spread, spread), vel2.Y + math.random(-spread, spread)), npc):ToProjectile();
				local projdata = projectile:GetData();
				projectile.FallingSpeed = -20 + math.random(10);
				projectile.FallingAccel = 1.5
				--projectile.Velocity = projectile.Velocity * (math.random(16, 18)/7.5)
				projectile.Scale = math.random(12, 15)/10
				-- + RandomVector() * math.random(-3,3)
				projectile.Color = mod.ColorDankBlackReal;
				--projdata.projType = "dank trail";
				projdata.creeptype = "black"
			end

			if mod.GetEntityCount(mod.FF.Blot.ID, mod.FF.Blot.Var) < max_spawned_blots then
				for i = 1, math.random(1,3), 1 do
					local vel2 = vel * math.random(5,7);
					local r = npc:GetDropRNG()
					local rand = r:RandomFloat()
					local blot = Isaac.Spawn(mod.FF.Blot.ID, mod.FF.Blot.Var, 0, npc.Position, Vector(vel2.X + math.random(-spread, spread), vel2.Y + math.random(-spread, spread)), npc):ToNPC();
					local blotdata = blot:GetData();
					blotdata.downvelocity = -20 + math.random(10);
					blotdata.downaccel = 2.5
					blot.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					blot.GridCollisionClass = GridCollisionClass.COLLISION_NONE
					blot:GetSprite().Offset = Vector(0, -1)
					blotdata.state = "air"
					blot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				end
			end

		end

		npc.Velocity = nilvector;

		if sprite:IsOverlayFinished("Attack") then
			npcdata.state = "move";
			npc.StateFrame = 0;
			npcdata.attack_delay = math.random(80,100);
		end
	else
		npcdata.state = "init"
		npc.SplatColor = mod.ColorDankBlackReal
		mod:spriteOverlayPlay(sprite, "Head");
	end

	npc.StateFrame = npc.StateFrame + 1;
end
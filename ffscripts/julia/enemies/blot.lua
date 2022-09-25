local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--Blot AI
function mod:blotAI(npc, sprite, npcdata) --todo make them jump over grids
	local creep_size = Vector(1.5,1.5);
	local speed = 7;
	local target = npc:GetPlayerTarget().Position
	if sprite:IsEventTriggered("Splot") then
		npc:PlaySound(SoundEffect.SOUND_GOOATTACH0,0.3,0,false,1.1)
		local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_BLACK, 0, npc.Position, Vector(0,0), npc):ToEffect();
		creep:Update();
	end

	if npcdata.state == "init" then
		npc.StateFrame = 0;
		npcdata.state = "idle";
	elseif npcdata.state == "idle" then
		local boiler = mod:GetNearestThing(npc.Position, mod.FF.Boiler.ID, mod.FF.Boiler.Var, -1, npcdata.boilerFilter)
		mod:spritePlay(sprite, "Idle");

		if npc.StateFrame > npcdata.hop_delay or boiler then
			npc.StateFrame = 0;
			npcdata.state = "hop";
		end
	elseif npcdata.state == "hop" then
		mod:spritePlay(sprite, "Move");

		if sprite:IsPlaying("Move") then
			if sprite:GetFrame() == 8 then
				local boiler = mod:GetNearestThing(npc.Position, mod.FF.Boiler.ID, mod.FF.Boiler.Var, -1, npcdata.boilerFilter)
				local boilertarget
				local vel = Vector(0,0)
				if mod:isCharmOrBerserk(npc) then
					vel = (((target - npc.Position):Resized(1.75)) + RandomVector():Normalized()):Resized(speed + math.random(-1, 1))
				elseif boiler and boiler.Position:Distance(npc.Position) < 100 and boiler:GetData().blotprep then
					npcdata.state = "air"
					npcdata.downvelocity = -25 + math.random(0, 5);
					npcdata.downaccel = 5
					vel = (boiler.Position - npc.Position)/12
					sprite.Offset = Vector(0, -1)
					if not mod:isFriend(npc) then
						npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					end
					npc.GridCollisionClass = GridCollisionClass.COLLISION_NONE
				elseif boiler and npc.Pathfinder:HasPathToPos(boiler.Position) then
					boilertarget = boiler.Position
				elseif (npc.Position - target):Length() >= 150 or mod:isScare(npc) then
					vel = (((mod:reverseIfFear(npc, target - npc.Position)):Normalized()) + RandomVector():Normalized()):Resized(speed + math.random(-2, 2))
				else
					vel = (((target - npc.Position):Resized(0.75)) + RandomVector():Normalized()):Resized(speed + math.random(-1, 1))
				end
				if boilertarget then
					if game:GetRoom():CheckLine(npc.Position,boilertarget,0,1,false,false) then
						vel = (boilertarget - npc.Position):Resized(speed + math.random(-1, 1))
					else
						npc.Pathfinder:FindGridPath(boilertarget, 3, 900, true)
					end
				end
				if vel then
					npc.Velocity = npc.Velocity + mod:rotateIfConfuse(npc, vel);
				end
				if npc.Velocity.X < 0 then sprite.FlipX = true else sprite.FlipX = false end
				--npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS;
			end
		end

		if sprite:IsFinished("Move") then
			npc.StateFrame = 0;
			npcdata.state = "idle";
			if mod:isFriend(npc) then
				npcdata.hop_delay = math.random(10)
			else
				npcdata.hop_delay = 40 + math.random(-20,20);
			end
		end
	elseif npcdata.state == "air" then
		mod:spritePlay(sprite, "InAir");
		--mini - making airtime a thing
		sprite.Offset = Vector(0, sprite.Offset.Y + npcdata.downvelocity * 0.5)
		npcdata.downvelocity = npcdata.downvelocity + npcdata.downaccel
		if sprite.Offset.Y >= 0 then
			--land
			sprite.Offset = Vector(0,0)
			npcdata.state = "land"
			mod:spritePlay(sprite, "land")
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			--dont land on pits or shit
			if not (room:GetGridCollisionAtPos(npc.Position + (npc.Velocity * 5)) == GridCollisionClass.COLLISION_NONE or room:GetGridCollisionAtPos(npc.Position) == GridCollisionClass.COLLISION_NONE) then
				npc:Kill()
			end
			--spawn creep
			local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_BLACK, 0, npc.Position, Vector(0,0), npc):ToEffect();
			creep.SpriteScale = creep.SpriteScale * 1.5
			creep:Update()
		end
	elseif npcdata.state == "land" then
		if sprite:IsFinished("land") then
			npcdata.state = "idle"
		end
	else npcdata.state = "init" end

	if npc.Velocity:Length() > 0 and npcdata.state ~= "air" then
		npc.Velocity = npc.Velocity * 0.9;
		--Isaac.ConsoleOutput(npc.Velocity.X .." "..npc.Velocity.Y);
	end

	if npc.FrameCount % 30 == 1 and npc.Velocity:Length() < 0.1 then
		local tar = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc)
		tar.SpriteScale = Vector(0.6,0.6)
		tar.Color = Color(0,0,0,0.5,0,0,0)
		tar:Update()
	end


	--[[if npc:IsDead() or npc.FrameCount % 15 == 1 and npc.Velocity:Length() < 0.5 then
		local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_BLACK, 0, npc.Position, Vector(0,0), npc):ToEffect();
		creep:Update();
	end]]--

	npc.StateFrame = npc.StateFrame + 1;

	--if there are no enemies that aren't blots left in the room, reduce their health to 0.1 (not 1 because soy milk can make your dmg less than 1)
	--since this is ran every frame it can't be efficient at all right? still trying to think of a more efficient way to do this

	--since blot hp is now one this is a whole lot of unnecessary lag
	--[[npcdata.ent_count = 0;

	if npcdata.reduced == false then
		for _,ent in ipairs(Isaac.GetRoomEntities()) do
			if (not (ent.Type == 970 and ent.Variant == 40)) and ent:IsActiveEnemy() and (not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
				npcdata.ent_count = npcdata.ent_count + 1;
			end
		end

		--Isaac.ConsoleOutput(npcdata.ent_count.."\n");

		if npcdata.ent_count == 0 then
			npc.HitPoints = 0.1;
			npcdata.reduced = true;
		end
	end]]--

end

function mod:getRandomBlotSprite()
	local sum = 0;

	for _,v in ipairs(mod.blotAnimationVariants) do
		sum = sum + v.weight;
	end

	local rand = math.random(0,sum-1);

	for _,v in ipairs(mod.blotAnimationVariants) do
		if rand < v.weight then return v end
		rand = rand - v.weight;
	end
end

function mod:blotInit(npc, sprite, npcdata)
	npc.SplatColor = mod.ColorDankBlackReal;
	if npc:HasEntityFlags(EntityFlag.FLAG_APPEAR) then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npcdata.hop_delay = 40 + math.random(-20,20);
		npcdata.reduced = false;
		if not npcdata.anim then
			npcdata.anim = mod:getRandomBlotSprite();
			sprite:ReplaceSpritesheet(0, "gfx/enemies/blot/monster_blot_"..npcdata.anim.name..".png");
			sprite:LoadGraphics();
		end
		sprite:Play("Idle");
		npc:AddEntityFlags(EntityFlag.FLAG_APPEAR)
		npcdata.boilerFilter = function (position, boiler)
			if boiler:GetData().blotsfed < 3 then
				return true
			end
		end
		npcdata.downvelocity = 0
		npcdata.downaccel = 0
	end
end
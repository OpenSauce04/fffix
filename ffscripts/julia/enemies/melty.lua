local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:meltyInit(npc, sprite, npcdata)
	npc.SplatColor = mod.ColorDankBlackReal;
	if npc:HasEntityFlags(EntityFlag.FLAG_APPEAR) then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		--sprite:Play("WalkVert", 0)
		sprite:PlayOverlay("Appear", 0);
		npc:AddEntityFlags(EntityFlag.FLAG_APPEAR)
	end
end

--Melty AI
function mod:meltyAI(npc, sprite, npcdata)
	local target = npc:GetPlayerTarget()
	local path = npc.Pathfinder
	npc.SplatColor = mod.ColorDankBlackReal

	if npc.State == 11 then
		if npcdata.movement_speed then
			npcdata.movement_speed = npcdata.movement_speed + 0.125;
		else
			npcdata.movement_speed = 2.125
		end
		if not npcdata.balond then
			npcdata.balond = true
			npc:PlaySound(mod.Sounds.BaloonShort, 1.5, 0, false, 2);
		end
		if sprite:IsOverlayPlaying("Poof") then
			if sprite:GetOverlayFrame() == 36 then
				--for i = 1, 2 + math.random(0,2) do
					--local blot = mod.spawnent(npc, npc.Position, RandomVector():Resized(5), mod.FF.Blot.ID, mod.FF.Blot.Var, 0)
					--blot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					--blot:GetData().state = "air";
				--end
			elseif sprite:GetOverlayFrame() == 37 then
				Isaac.Spawn(1000,7009,0,npc.Position,nilvector,npc);
				local tar = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc)
				tar.SpriteScale = Vector(2,2)
				tar.Color = Color(0,0,0,0.5,0,0,0)
				tar:Update()
				for i = 30, 360, 30 do
					local r = npc:GetDropRNG()
					local rand = r:RandomFloat()
					if math.random(0,2) == 0 then
						--makin it fire blots and not reskinned projectiles
						local blot = Isaac.Spawn(mod.FF.Blot.ID, mod.FF.Blot.Var, 0, npc.Position, Vector(0,0.5):Rotated(i-40+rand*80), npc):ToNPC()
						local blotdata = blot:GetData()
						blotdata.downvelocity = -35 + math.random(10);
						blotdata.downaccel = 2.5
						blot.Velocity = blot.Velocity * (math.random(12, 20)/7.5)
						blot.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
						blot.GridCollisionClass = GridCollisionClass.COLLISION_NONE
						blot:GetSprite().Offset = Vector(0, -1)
						blotdata.state = "air"
						blot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					else
						local projectile = Isaac.Spawn(9, 0, 0, npc.Position, Vector(0,2):Rotated(i-40+rand*80), npc):ToProjectile();
						local projdata = projectile:GetData();
						local s = projectile:GetSprite()
						--s:Load("gfx/enemies/blot/monster_blot.anm2",true)
						--s:Play("InAir1",false)
						projectile.FallingSpeed = -35 + math.random(10);
						projectile.FallingAccel = 1.5
						projectile.Velocity = projectile.Velocity * (math.random(12, 20)/7.5)
						projectile.Scale = math.random(8, 12)/10
						projectile.Color = mod.ColorDankBlackReal
					end
				end
				sfx:Play(SoundEffect.SOUND_BOSS1_EXPLOSIONS, 0.65, 0, false, 1.6);
				npc:PlaySound(SoundEffect.SOUND_HEARTIN, 1.5, 0, false, 1);
				npc:Kill();
			end
		else mod:spriteOverlayPlay(sprite, "Poof") end

		--npc.Velocity = nilvector;
	elseif npcdata.state == "init" then
		--mod:spritePlay(sprite, "WalkHori");
		--mod:spriteOverlayPlay(sprite, "Appear");
		mod:spriteOverlayPlay(sprite, "Head");
		npcdata.movement_speed = 2;
		--if sprite:IsOverlayFinished("Appear") then
			npcdata.state = "move";
			npc.StateFrame = 0;
		--end
	elseif npcdata.state == "move" then
		mod:spriteOverlayPlay(sprite, "Head");
	else npcdata.state = "init" end

	if npcdata.state == "move" or npc.State == 11 then
		if npc.Velocity:Length() > 1 then
			npc:AnimWalkFrame("WalkHori","WalkVert",0)
		else
			sprite:SetFrame("WalkVert", 0)
		end

		local targetpos = mod:confusePos(npc, target.Position)
		if room:CheckLine(npc.Position,targetpos,0,1,false,false) or mod:isScare(npc) then
			npcdata.targetvelocity = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(npcdata.movement_speed))
			npc.Velocity = mod:Lerp(npc.Velocity, npcdata.targetvelocity, 0.8)
		else
			npcdata.targetvelocity = path:FindGridPath(targetpos, npcdata.movement_speed/5, 1, true)
			npc.Velocity = mod:Lerp(npc.Velocity, npc.Velocity, 0.8)
		end
	end

	if npc.FrameCount % 3 == 1 then
		local tar = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc)
		tar.SpriteScale = Vector(0.6,0.6)
		tar.Color = Color(0,0,0,0.5,0,0,0)
		tar:Update()
	end

	npc.StateFrame = npc.StateFrame + 1
end

function mod:meltyHurt(npc, damage, flag, source)
	--if npc.HitPoints - damage <= 10 then
	--	if not (npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) or npc:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE)) then
	--		npc.Velocity = nilvector
			--npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	--		npc.HitPoints = 0
	--		npc:ToNPC().State = 11
	--		return false
	--	end
	--end

	if npc:ToNPC().State == 11 then return false end;
end

function mod.meltyDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
		deathAnim.State = 11
	end

	mod.genericCustomDeathAnim(npc, nil, nil, onCustomDeath, true, true)
end

function mod.meltyDeathEffect(npc)
	local tar = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc)
	tar.SpriteScale = Vector(2,2)
	tar.Color = Color(0,0,0,0.5,0,0,0)
	tar:Update()
	for i = 30, 360, 30 do
		local r = npc:GetDropRNG()
		local rand = r:RandomFloat()
		if math.random(0,2) == 0 then
			--makin it fire blots and not reskinned projectiles
			local blot = Isaac.Spawn(mod.FF.Blot.ID, mod.FF.Blot.Var, 0, npc.Position, Vector(0,0.5):Rotated(i-40+rand*80), npc):ToNPC()
			local blotdata = blot:GetData()
			blotdata.downvelocity = -35 + math.random(10);
			blotdata.downaccel = 2.5
			blot.Velocity = blot.Velocity * (math.random(12, 20)/7.5)
			blot.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			blot.GridCollisionClass = GridCollisionClass.COLLISION_NONE
			blot:GetSprite().Offset = Vector(0, -1)
			blotdata.state = "air"
			blot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		else
			local projectile = Isaac.Spawn(9, 0, 0, npc.Position, Vector(0,2):Rotated(i-40+rand*80), npc):ToProjectile();
			local projdata = projectile:GetData();
			local s = projectile:GetSprite()
			--s:Load("gfx/enemies/blot/monster_blot.anm2",true)
			--s:Play("InAir1",false)
			projectile.FallingSpeed = -35 + math.random(10);
			projectile.FallingAccel = 1.5
			projectile.Velocity = projectile.Velocity * (math.random(12, 20)/7.5)
			projectile.Scale = math.random(8, 12)/10
			projectile.Color = mod.ColorDankBlackReal
		end
	end
	sfx:Play(SoundEffect.SOUND_BOSS1_EXPLOSIONS, 0.65, 0, false, 1.6);
	npc:PlaySound(SoundEffect.SOUND_HEARTIN, 1.5, 0, false, 1);
end

function mod:checkMeltyPoof(effect)
	local sprite = effect:GetSprite();

	mod:spritePlay(sprite, "PoofEffect");

	if sprite:IsFinished("PoofEffect") then effect:Remove() end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.checkMeltyPoof, 7009)
local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--Fossil, Fossilized 
function mod:fossilizedBoomFlyAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	npc.SplatColor = Color(0,0,0,1,20 / 255,10 / 255,10 / 255);
	if not d.Init then
		npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
		d.Init = true
	end
	if d.rocktime then
		npc.Velocity = nilvector
		if sprite:IsFinished("Fall") then
			sprite:Play("Idle", true)
            npc.CanShutDoors = false
			npc.CollisionDamage = 0
		end
	else
		mod:spritePlay(sprite, "Fly")
		local targvel = mod:diagonalMove(npc, 4, 1)
		if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE) then
			targvel = targvel / 2
		end
		npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.1)
	end
end

function mod.fossilizedBoomFlyDeathAnim(npc)
    local data = npc:GetData()
	if not data.rocktime then
		local room = Game():GetRoom()
		if room:GetGridCollisionAtPos(npc.Position) == GridCollisionClass.COLLISION_NONE then
			local spawned = Isaac.Spawn(npc.Type, npc.Variant, npc.SubType, npc.Position, nilvector, npc)
			spawned:ToNPC():Morph(spawned.Type, spawned.Variant, spawned.SubType, npc:ToNPC():GetChampionColorIdx())
			spawned.HitPoints = spawned.MaxHitPoints
			spawned:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			spawned:GetData().rocktime = true
			spawned:GetSprite():Play("Fall", true)
			spawned:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)

			if (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
				spawned:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
			end

			spawned:GetData().FFPreventDeathDrops = true
			npc.Visible = false
		elseif room:GetGridCollisionAtPos(npc.Position) == GridCollisionClass.COLLISION_PIT then
			local grident = room:GetGridEntityFromPos(npc.Position)
			room:TryMakeBridge(grident, grident)
		end
    end
end

function mod.fossilizedBoomFlyDeathEffect(npc)
	local r = npc:GetDropRNG()
	local params = ProjectileParams()
	params.Variant = 9
	params.FallingAccelModifier = 1.5
	params.Scale = 0.9
	for i = 60, 360, 60 do
		params.FallingSpeedModifier = -30 + math.random(10)
		local rand = r:RandomFloat()
		npc:FireProjectiles(npc.Position, Vector(0,2):Rotated(i-40+rand*80), 0, params)
		--[[local rand = r:RandomFloat()
		local coal = Isaac.Spawn(9, 3, 0, npc.Position, Vector(0,2):Rotated(i-40+rand*80), npc):ToProjectile()
		local coald = coal:GetData()
		coald.projType = "coalButActuallyRock"
		coal.FallingSpeed = -30 + math.random(10)
		coal.FallingAccel = 1.2
		local coals = coal:GetSprite()
		coals:Load("gfx/projectiles/sooty_tear_rock.anm2",true)
		coals:Play("spin",true)
		coal.SpriteScale = coal.SpriteScale * 0.7
		coal:Update()]]
	end
end
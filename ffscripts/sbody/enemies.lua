local mod = FiendFolio
local sfx = SFXManager()

function mod:punisherAI(npc)
  npc.Position = npc.Position
  npc.Velocity = Vector.Zero
  
  local data = npc:GetData()
  local sprite = npc:GetSprite()
  
  --init
  if not data.state then
    data.state = 1
    sprite:Play("Idle", true)
    npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
    npc.PositionOffset = Vector(0,-24)
    npc.SplatColor = Color(0,0,0,0,0,0,0)
    
    data.bulletAmmount = npc.SubType
    data.param1 = ProjectileParams()
    data.param1.CircleAngle = 0
    data.param1.BulletFlags = ProjectileFlags.ACCELERATE | ProjectileFlags.CURVE_RIGHT | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT --| ProjectileFlags.CHANGE_VELOCITY_AFTER_TIMEOUT
    data.param1.ChangeFlags = ProjectileFlags.DECELERATE | ProjectileFlags.CURVE_RIGHT --| ProjectileFlags.FADEOUT
    data.param1.ChangeVelocity = 2.5
    data.param1.ChangeTimeout = 30
    data.param1.HeightModifier = -24
    data.param1.FallingAccelModifier = 0.0175 -- -0.04
    --data.param1.FallingSpeedModifier = 0
    data.param1.Color = FiendFolio.ColorGehennaFire2
    
    data.param2 = ProjectileParams()
    data.param2.CircleAngle = math.pi / data.bulletAmmount
    data.param2.BulletFlags = ProjectileFlags.ACCELERATE | ProjectileFlags.CURVE_RIGHT | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT --| ProjectileFlags.CHANGE_VELOCITY_AFTER_TIMEOUT
    data.param2.ChangeFlags = ProjectileFlags.DECELERATE | ProjectileFlags.CURVE_RIGHT --| ProjectileFlags.FADEOUT
    data.param2.ChangeVelocity = 2.5
    data.param2.ChangeTimeout = 30
    data.param2.HeightModifier = -24
    data.param2.FallingAccelModifier = 0.0175 -- -0.04
    --data.param2.FallingSpeedModifier = 0
    data.param2.Color = FiendFolio.ColorGehennaFire2
  end
  
  --if npc.State == 0 then
  --  npc.State = 1
  --  --sprite:Play("Idle", false)
  --end
  
  --print(npc.StateFrame % 32)
    
  if data.state == 1 then         --idle
    if npc.StateFrame == 24 * 4 then --4
      data.state = 2
      sprite:Play("AttackStart", true)
      npc:PlaySound(mod.Sounds.PunisherGroan, 0.5, 0, false, 1)
    end
  elseif data.state == 2 then     --shootingStart
    if sprite:IsFinished("AttackStart") then
      data.state = 3
      npc.StateFrame = -1      
      sprite:Play("AttackLoop", true)
    end
  elseif data.state == 3 then     --shootingLoop
    if (npc.StateFrame % 28) == 0 then
      npc:FireProjectiles(npc.Position, Vector(5, data.bulletAmmount), 9, data.param1)
    end
    if (npc.StateFrame % 28) == 8 then
      npc:FireProjectiles(npc.Position, Vector(10/3, data.bulletAmmount), 9, data.param2)
    end
    if npc.StateFrame == 8 * 15 then
      data.state = 4
      sprite:Play("Attackend", true)
    end
  elseif data.state == 4 then     --shootingEnd
    if sprite:IsFinished("Attackend") then
      data.state = 1  
      npc.StateFrame = 24
      sprite:Play("Idle", true)
    end
  end
  
  if npc:IsDead() then
    local gColor = Color(1.2, 1.2, 1.3, 1, 0, 0, 0)
    gColor:SetColorize(1, 1, 1, 0.3)
    
    for i=0, 15 do 
      Isaac.Spawn(1000, 163, 0, npc.Position + RandomVector()*5 + Vector(0, -50-i*5), RandomVector()*2 + Vector(0, 8+i/12.5), npc):ToEffect()
      local chain = Isaac.Spawn(1000, 163, 0, npc.Position + Vector(0, -100-i*10), RandomVector() + Vector(0, 8+(i*0.4)+(i*0.15)), npc):ToEffect()
      chain.Color = gColor
      local scrap1 = Isaac.Spawn(1000, 4, 0, npc.Position + Vector(0,-24) + RandomVector()*(24+math.random()*16), RandomVector()*(1.5+math.random()*1.5) + Vector(0,1.5), npc):ToEffect()
      local scrap2 = Isaac.Spawn(1000, 4, 0, npc.Position + Vector(0,-56) + RandomVector()*(24+math.random()*16), RandomVector()*(1.5+math.random()*1.5) + Vector(0,3), npc):ToEffect()
      --scrap1:GetSprite():ReplaceSpritesheet(0, "gfx/grid/rocks_gehenna.png")  --grrrr this doesnt works
      --scrap1:GetSprite():LoadGraphics()
      --scrap2:GetSprite():ReplaceSpritesheet(0, "gfx/grid/rocks_gehenna.png")      
      --scrap2:GetSprite():LoadGraphics()
      scrap1.Color = gColor
      scrap2.Color = gColor
      scrap1:Update()
      scrap2:Update()
      if (data.state == 2 and sprite:GetFrame() > 12) or data.state == 3 or (data.state == 4 and sprite:GetFrame() < 10) then
        for i=0, 2 do 
          local spark = Isaac.Spawn(1000, 66, 0, npc.Position + RandomVector()*(8+math.random()*32), Vector(0,-2), proj):ToEffect()
          spark.PositionOffset = Vector(0, -48-math.random()*32)
        end
      end
    end
    
    sfx:Stop(SoundEffect.SOUND_DEATH_BURST_SMALL)
    npc:PlaySound(SoundEffect.SOUND_ANIMA_BREAK, 0.5, 0, false, 0.6)
    npc:PlaySound(SoundEffect.SOUND_METAL_BLOCKBREAK, 0.5, 0, false, 0.8)    
  end
  
  npc.StateFrame = npc.StateFrame + 1  
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, npc, dmg, dmgType, dmgSrc, dmgCountDown)
  if dmgSrc.Entity and dmgSrc.Entity.SpawnerType == 124 and dmgSrc.Entity.SpawnerVariant == 0 then return false end
end, 124)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, proj)
  local data = proj:GetData()
  if data.punisher then
    local flamesub = 0
    if data.Nihilism then
      flamesub = 1
    end
    local flame = Isaac.Spawn(1000, 147, flamesub, proj.Position + Vector(0, 0.01), Vector(0, 0), proj.SpawnerEntity):ToEffect()
    flame:GetSprite().Scale = Vector(0.5, 0.5)
    flame.CollisionDamage = 2.5
    sfx:Stop(SoundEffect.SOUND_TEARIMPACTS)
    sfx:Stop(SoundEffect.SOUND_SPLATTER)
	
    if data.ShaggothColour then
      flame:GetSprite().Color = proj:GetSprite().Color
    else
      flame.Color = mod.ColorGehennaFire
    end
  end
end, 9)

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, function(_, proj)
  local data = proj:GetData()
  if proj.SpawnerType == 124 and proj.SpawnerVariant == 0 then 
    data.punisher = true
  end
end)

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, proj)
  local data = proj:GetData()
  if data.punisher then
    if proj.FrameCount % 3 == 0 then
      local spark = Isaac.Spawn(1000, 66, 0, proj.Position + RandomVector()*5, proj.Velocity / 4, proj):ToEffect()
      spark.PositionOffset = Vector(0, proj.Height)
      spark.Color = mod.ColorGehennaFire
      proj.Child = spark
    end
  end
end)

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
  if npc.Variant == 0 then mod:punisherAI(npc) end
end, 124)
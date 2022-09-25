local mod = FiendFolio
local game = Game()

--------------
-- OROSHIBU --
--------------

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
  -- VALVO
	if npc.Variant == 0 then
    local sprite = npc:GetSprite()
    npc:MultiplyFriction(0.7)
    if npc.State == NpcState.STATE_INIT then
      sprite:PlayOverlay("Head",false)
      --npc.I1 = math.random(20,40)
      npc.I1 = 0
      npc.StateFrame = 0
      npc.State = NpcState.STATE_IDLE
      npc.Velocity = Vector(0,0)
      npc.Target = npc:GetPlayerTarget()
      npc.TargetPosition = npc.Target.Position
      npc.Friction = 10
    elseif npc.State == NpcState.STATE_IDLE then
      npc.StateFrame = npc.StateFrame + 1
      if npc.StateFrame >= npc.I1 or mod:isScareOrConfuse(npc) then
        npc.State = NpcState.STATE_MOVE
        npc.I1 = math.random(50,200)
        npc.StateFrame = 0
      end
    elseif npc.State == NpcState.STATE_MOVE then
			npc.Target = npc:GetPlayerTarget()
			npc.TargetPosition = npc.Target.Position
      if npc.StateFrame%5 == 0 then
		mod:runIfFearNearby(npc)
		npc.Pathfinder:MoveRandomly(false)
	  end
      npc.StateFrame = npc.StateFrame + 1
      local acc = 1
      if npc.StateFrame < 20 then
        acc = (npc.StateFrame/20)^2
      elseif npc.StateFrame >= npc.I1 - 30 then
        acc = ((npc.I1 - npc.StateFrame)/30)^2
      end
			npc.Velocity = npc.Velocity * 20
      if (npc.Velocity:Length() > acc*5) then npc.Velocity = npc.Velocity:Normalized() *acc*5 end
			npc:AnimWalkFrame("WalkHori", "WalkVert", 1)
      if npc.StateFrame >= npc.I1 then
        npc.State = NpcState.STATE_IDLE
        npc.I1 = math.random(20,70)
        npc.StateFrame = 0
        npc.Velocity = Vector(0,0)
      end
    end
    if sprite:IsOverlayPlaying("Attack") and sprite:GetOverlayFrame()>=6 then
      if sprite:GetOverlayFrame()==6 then
        npc:PlaySound(mod.Sounds.Valvo, 1.5, 0, false, math.random(9,11)/10)
      end
      local power = (38-(sprite:GetOverlayFrame()-6))/38
      local pistolet = ProjectileParams()
      npc.Velocity = npc.Velocity - npc.V1*5*(power^3)
      Game():ShakeScreen(math.floor((power^2)*15))
      if npc.StateFrame%(5-math.ceil((power^2)*4))==0 then
        for i=0,math.ceil((power^2)*4),1 do
          local projectileSpeed = math.random(40,80)/10*power*1.5
          pistolet.Scale = (projectileSpeed-3)/3.5 +(1-power)/4
          pistolet.FallingAccelModifier = math.random(1,5)/20*(2-power)
          npc:ToNPC():FireProjectiles(npc:ToNPC().Position + npc.V1*10, npc.V1:Rotated(-5):Rotated(math.random(0,10))*projectileSpeed, 0, pistolet)
        end
      end
    end
    if sprite:IsOverlayFinished("Attack") then
      sprite:PlayOverlay("Head",false)
    end

  ------------------------------------------------------------FIENDFOLIO SOMBRA
  elseif npc.Variant == 1 then
	for _,sombra in ipairs(Isaac.FindByType(mod.FF.Sombra.ID, mod.FF.Sombra.Var, -1, false, false)) do
		if sombra.InitSeed ~= npc.InitSeed then
			if sombra.Position:Distance(npc.Position) < 60 then
				sombra.Velocity = mod:Lerp(sombra.Velocity, (sombra.Position - npc.Position):Resized(2), 0.2)
			end
		end
	end
    local sprite = npc:GetSprite()
    if npc.State == 0 then -----------------------------------APPEAR
      npc.Velocity = Vector(0,0)
      npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
      local color = Color(0.2, 1, 1, 1, 0, 0, 0)
      color:SetColorize(1, 1, 1, 1)
      npc.SplatColor = color
      sprite:Play("Appear",false)
      if sprite:IsFinished("Appear") then
        sprite:Play("Idle", false)
        npc.State = 5
        npc.I1 = math.random(20,50)
        npc.I2 = 0
        npc.StateFrame = 0
      end
    elseif npc.State == 5 then -------------------------------IDLE
      npc.Velocity = Vector(0,0)
      npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
      if npc.StateFrame < npc.I1 then
        sprite:Play("Idle", false)
        npc.StateFrame = npc.StateFrame + 1
      elseif npc.StateFrame >= npc.I1 then
		if not mod:isScareOrConfuse(npc) then
          sprite:Play("Transform", false)
		end
        if sprite:IsFinished("Transform") then
          npc.State = 6
          npc.I1 = math.random(50,100)
          npc.StateFrame = 0
        end
      end
    elseif npc.State == 6 then -------------------------------IDLE2
      if npc.Child == nil then
        npc.Child = Isaac.Spawn(EntityType.ENTITY_PITFALL, 0, 0, npc.Position, Vector(0,0), npc):ToNPC()
        npc.Child:ToNPC().Visible = false
        npc.Child.Visible = false
        npc.Child:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc.Child.Parent = npc
      else
        npc.Child.Position = npc.Position
        npc.Child.Visible = false
      end
      sprite:Play("Idle2", false)
			npc.Target = npc:GetPlayerTarget()
			npc.TargetPosition = mod:confusePos(npc, npc.Target.Position)
      local distance = (npc.TargetPosition - npc.Position):Length()
      if mod:isScare(npc) then
		    local targetDirection = (npc.TargetPosition - npc.Position):Normalized()
        npc.Velocity = mod:Lerp(npc.Velocity, (npc.Velocity) + (targetDirection * -2), 0.3)
      elseif distance >= 300 then
        npc.State = 4
        npc.I1 = 0
        sprite:Play("Exit", false)
      elseif distance >= 10 then
        if game:GetRoom():CheckLine(npc.Position,npc.TargetPosition,0,1,false,false) then
          local targetDirection = (npc.TargetPosition - npc.Position):Normalized()
          npc.Velocity = mod:Lerp(npc.Velocity, (npc.Velocity) + (targetDirection * 2), 0.3)
        else
          npc.Pathfinder:FindGridPath(npc.TargetPosition, 4, 900, true)
        end
      elseif distance >=4 then
        npc.Velocity = npc.Velocity*0.8
        npc.StateFrame = npc.StateFrame - 1
      else
        if npc.I2 == 0 then --if not said as in hole yet
          npc.I2 = 1
          npc.I1 = 40
          npc.StateFrame = 0
        end
      end
      if (npc.Velocity:Length() > 4) then npc.Velocity = npc.Velocity:Normalized() * 4 end
      npc.StateFrame = npc.StateFrame + 1
      if npc.StateFrame >= npc.I1 then
        npc.Child:Remove()
        if distance <= 150 then
          npc.State = 3
          npc.I1 = 0
          sprite:Play("ReturnToNormal", false)
          npc.Target = npc:GetPlayerTarget()
          npc.TargetPosition = mod:confusePos(npc, npc.Target.Position)
          if npc.Position.X < npc.TargetPosition.X then
            npc.FlipX = true
          else
            npc.FlipX = false
          end
        else
          npc.State = 4
          npc.I1 = 0
          sprite:Play("Exit", false)
        end
      end
    elseif npc.State == 3 then ---------------------------------ATTACK
      if npc.I2 == 1 then
        npc.I2 = 0
      end
      npc.Velocity = Vector(0,0)
      npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
      if npc.I1 == 0 then
        sprite:Play("ReturnToNormal", false)
        if sprite:IsFinished("ReturnToNormal") then
		  if mod:isScareOrConfuse(npc) then
             npc.State = 5
             npc.I1 = math.random(10,30)
             npc.StateFrame = 0
		  else
             npc.I1 = 1
		  end
        end
      elseif npc.I1 == 1 then
        sprite:Play("Attack", false)
        if sprite:IsFinished("Attack") then
          npc.State = 5
          npc.I1 = math.random(10,30)
          npc.StateFrame = 0
        end
      end
    elseif npc.State == 4 then ---------------------------------TELEPORT
      npc.Velocity = Vector(0,0)
      npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
      if npc.I1 == 0 then
        sprite:Play("Exit", false)
        if sprite:IsFinished("Exit") then
          npc.Target = npc:GetPlayerTarget()
          npc.TargetPosition = npc.Target.Position
          local direction = (npc.TargetPosition - npc.Position):Normalized()
          npc.Position = npc.TargetPosition - direction*50
          npc.I1 = 1
        end
      elseif npc.I1 == 1 then
        sprite:Play("Return", false)
        if sprite:IsFinished("Return") then
          npc.State = 6
          npc.I1 = math.random(10,40)
          npc.StateFrame = 0
        end
      end
    end
	if sprite:IsEventTriggered("Sound1") then ---------SOUNDS
		npc:PlaySound(SoundEffect.SOUND_SKIN_PULL,0.6,0,false,0.5)
	elseif sprite:IsEventTriggered("Sound2") then
		--Could use sounds for exiting/entering hole
	elseif sprite:IsEventTriggered("Sound3") then
		--Could use sounds for exiting/entering hole
    elseif sprite:IsEventTriggered("NoDMG") then -----------------EVENT NODMG
      npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
      npc.DepthOffset = -10 
	elseif sprite:IsEventTriggered("DMG") then -----------------EVENT DMG
      npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
      npc.DepthOffset = 0
    elseif sprite:IsEventTriggered("Shoot") then -----------------EVENT Shoot
      local pistolet = ProjectileParams()
      local projectileSpeed = 15
      pistolet.Scale = 2
      pistolet.Spread = 3
      pistolet.FallingAccelModifier = -0.05
      pistolet.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
      local color = Color(0.2, 1, 1, 1, 0, 0, 0)
      color:SetColorize(1, 1, 1, 1)
      pistolet.Color = color
      npc.Target = npc:GetPlayerTarget()
      npc.TargetPosition = npc.Target.Position
	  mod:FlipSprite(sprite, npc.TargetPosition, npc.Position)
      local dir = (npc.TargetPosition - (npc.Position+Vector(0,-20))):Normalized()
      for i=0,2,1 do
        npc:FireProjectiles(npc.Position+Vector(0,-20)+dir*20, dir:Rotated(-20):Rotated(i*20)*projectileSpeed, 0, pistolet)
      end
	  npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,0,false,0.7)
    end
	if npc:IsDead() then
		if npc.Child then
			npc.Child:Remove()
		end
	end
  end
end, mod.FFID.Oro)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, npc, dmg, dmgType, dmgSrc, dmgCountDown)

  -- VALVO
	if npc.Variant == 0 then
    local sprite = npc:GetSprite()
    --if npc.HitPoints < dmg and not mod:isScareOrConfuse(npc:ToNPC()) then
    --  local pistolet = ProjectileParams()
    --  pistolet.Scale = 2.5
    --  pistolet.FallingAccelModifier = 0.4
    --  pistolet.FallingSpeedModifier = -6
    --  npc:ToNPC():FireProjectiles(npc:ToNPC().Position, Vector(0,0), 0, pistolet)
    --end
    if (not sprite:IsOverlayPlaying("Attack")) and math.random(0,1) == 1 and not mod:isScareOrConfuse(npc:ToNPC()) then
      sprite:PlayOverlay("Attack",false)
      if dmgSrc.Entity and dmgSrc.Entity.Parent then
        npc:ToNPC().V1 = (dmgSrc.Entity.Parent.Position - npc:ToNPC().Position):Normalized()
      else
        npc:ToNPC().V1 = (npc:ToNPC():GetPlayerTarget().Position - npc:ToNPC().Position):Normalized()
      end
    end


  end
end, mod.FFID.Oro)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, npc)
	-- VALVO
	if npc.Variant == 0 then
		if not mod:isScareOrConfuse(npc:ToNPC()) and not mod:isLeavingStatusCorpse(npc) then
			local pistolet = ProjectileParams()
			pistolet.Scale = 2.5
			pistolet.FallingAccelModifier = 0.4
			pistolet.FallingSpeedModifier = -6
			npc:ToNPC():FireProjectiles(npc:ToNPC().Position, Vector(0,0), 0, pistolet)
		end
	end
end, mod.FFID.Oro)
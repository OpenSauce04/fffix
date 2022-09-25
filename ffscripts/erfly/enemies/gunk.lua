local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:gunkAI(npc, subt, var)
    local d = npc:GetData()
    local sprite = npc:GetSprite();
    local target = npc:GetPlayerTarget()
    
    if not d.init then
        d.init = true
        npc.SplatColor = mod.ColorDankBlackReal
        d.state = "idle"
        if var == mod.FF.Punk.Var then
            mod:ReplaceEnemySpritesheet(npc, "gfx/enemies/gunk/punk", 0)
            sprite:LoadGraphics()   
        end
    elseif d.init then
        npc.StateFrame = npc.StateFrame + 1
    end

    if npc.SubType == 1 then
        npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, nilvector, 0.03)
    end

    if npc.State == 11 then
        mod:spritePlay(sprite, "TurnIntoBubble")
        if sprite:GetFrame() > 15 then
            npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH,1,0,false,1)
            local bubble = mod.spawnent(npc, npc.Position, nilvector, mod.FF.TarBubble.ID, mod.FF.TarBubble.Var, 0)
            bubble:GetSprite():ReplaceSpritesheet(0, "gfx/enemies/gunk/slime.png")
            bubble:GetSprite():LoadGraphics()
            npc:Remove()
        elseif sprite:IsEventTriggered("fall") then
            d.fallpos = game:GetRoom():FindFreePickupSpawnPosition(npc.Position, 1, true)
        end
        if sprite:GetFrame() == 0 then
        local blood = Isaac.Spawn(1000, 2, 0, npc.Position, nilvector, npc):ToEffect();
            npc:PlaySound(SoundEffect.SOUND_DEATH_BURST_SMALL,1,0,false,1)
            blood.RenderZOffset = 100
            blood.SpriteOffset = Vector(-3+math.random(14), -45+math.random(40))
            blood.Color = mod.ColorDankBlackReal
            blood:Update()
        end
        if d.fallpos then
            local dist = (npc.Position-d.fallpos):Length()
            if dist < 10 then
                npc.Velocity = npc.Velocity * 0.5
            else
                npc.Velocity = (d.fallpos - npc.Position):Normalized() * (dist/20)
                if npc.Velocity >= dist then
                    npc.Velocity = npc.Velocity:Resized(dist)
                end
            end
        end
    else
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        if d.state == "idle" then
            mod:spritePlay(sprite, "Shake")
            local targpos = mod:randomConfuse(npc, target.Position)
            d.targetvelocity = mod:reverseIfFear(npc, (targpos - npc.Position):Resized(7))
            npc.Velocity = mod:Lerp(npc.Velocity, d.targetvelocity, 0.1)
            if game:GetRoom():CheckLine(npc.Position,target.Position,0,3,false,false) and npc.Position:Distance(target.Position) < 150 and npc.StateFrame > 20 and math.random(5) == 1 and not mod:isConfuse(npc) then
                d.state = "attack"
                d.flippy = true
                d.creepass = false
            end

            if npc.FrameCount % 3 == 1 then
                local blood = Isaac.Spawn(1000, 7, 0, npc.Position+Vector(0,10), nilvector, npc)
                blood.SpriteScale = Vector(0.4,0.4)
                blood.Color = mod.ColorDankBlackReal
                blood:Update()
            end

        elseif d.state == "attack" then
            if d.flippy then
                if target.Position.X > npc.Position.X then
                    sprite.FlipX = false
                else
                    sprite.FlipX = true
                end
            end
            npc.Velocity = npc.Velocity * 0.95
            if sprite:IsFinished("Shoot") then
                d.state = "idle"
                npc.StateFrame = 0
                sprite.FlipX = false
            elseif sprite:IsEventTriggered("shoot") then
                d.creepass = true
                local shootang = (target.Position - npc.Position)
                local projectile = Isaac.Spawn(9, 0, 0, npc.Position, shootang:Resized(8), npc):ToProjectile();
                local projdata = projectile:GetData();
                projectile.FallingSpeed = 0
                projectile.FallingAccel = -0.07
                projectile.Scale = 2
                projectile.Color = mod.ColorDankBlackReal
                projdata.projType = "dank trail"
                npc:PlaySound(SoundEffect.SOUND_SKIN_PULL,1,2,false,1)
                npc.Velocity = mod:Lerp(npc.Velocity, shootang:Resized(-20), 0.5)
                d.flippy = false
            elseif sprite:IsEventTriggered("stopflip") then
                sprite.FlipX = false
            else
                mod:spritePlay(sprite, "Shoot")
            end
            if d.creepass then
                if npc.FrameCount % 3 == 0 then
                    local creep = Isaac.Spawn(1000, 26, 0, npc.Position+RandomVector()*10, nilvector, npc):ToEffect()
                    creep:SetTimeout(150)
                    creep:Update()
                end
            end
        end
    end
end

function mod:gunkHurt(npc, damage, flag, source)
    --elseif variant == mod.FF.Gunk.Var or variant == mod.FF.Punk.Var then
	--	if npc.HitPoints - damage <= 10 then
	--		if not (npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) or npc:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE)) then
	--			npc.Velocity = nilvector
	--			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	--			npc.HitPoints = 0
	--			npc:ToNPC().State = 11
	--			return false
	--		end
	--	end
    if npc:ToNPC().State == 11 then
        return false
    end
end

function mod.gunkDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
		deathAnim.State = 11
	end
	
	mod.genericCustomDeathAnim(npc, nil, nil, onCustomDeath, nil, nil, nil, true)
end

function mod.gunkDeathEffect(npc)
	for i = 30, 360, 30 do
	local rand = npc:GetDropRNG():RandomFloat()
	local projectile = Isaac.Spawn(9, npc.SubType == 10 and 3 or 0, 0, npc.Position, Vector(0,2):Rotated(i-40+rand*80), npc):ToProjectile();
		local projdata = projectile:GetData();
		projectile.FallingSpeed = -50 + math.random(10);
		projectile.FallingAccel = 2
		projectile.Velocity = projectile.Velocity * (math.random(12, 20)/10)
		projectile.Scale = math.random(8, 12)/10
		projectile.Color = mod.ColorDankBlackReal
	end
end
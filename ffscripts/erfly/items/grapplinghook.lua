local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local grapplingMode = 2 --1 is space to pull, stop, 2 is based on aim
local hookmode = 1 --Changes how it works when sticking into wall, 1 waits, 2 pulls immediately

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, itemID, rng, player)
	local d = player:GetData()
	if d.myVeryOwnGrapplingHook and d.myVeryOwnGrapplingHook:Exists() then
		local gh = d.myVeryOwnGrapplingHook
		local hd = gh:GetData()
		if hd.state == "reelin" or grapplingMode == 2 then
            if not player.CanFly then
                player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            end
            hd.state = "return"
            if hd.state == "hooked" or hd.state == "reelin" then
                sfx:Play(mod.Sounds.GrappleGrab,0.3,0,false,math.random(130,150)/100)
            end
        elseif hd.state == "hooked" and grapplingMode == 1 then
            hd.state = "reelin"
		elseif grapplingMode == 1 then
            local room = game:GetRoom()
            local pos = room:GetGridPosition(room:GetGridIndex(gh.Position + gh.Velocity:Resized(25)))
            if room:GetGridCollisionAtPos(pos) == GridCollisionClass.COLLISION_PIT then
                --gh.Position = pos
                hd.state = "return"
                gh.Velocity = nilvector
            else
                gh.Position = pos
                hd.state = "reelin"
                sfx:Play(mod.Sounds.GrappleGrab,0.3,0,false,math.random(100,110)/100)
                gh.Velocity = nilvector
                mod:spritePlay(gh:GetSprite(), "Pinned")
            end
		end
	elseif (not d.myVeryOwnGrapplingHook) or not (d.myVeryOwnGrapplingHook:Exists()) then
		if d.holdingFFItem then
			d.holdingFFItem = nil
            d.HoldingFFItemBlankVisual = nil
			player:AnimateCollectible(mod.ITEM.COLLECTIBLE.GRAPPLING_HOOK, "HideItem", "PlayerPickup")
		else
			d.holdingFFItem = mod.ITEM.COLLECTIBLE.GRAPPLING_HOOK
            d.HoldingFFItemBlankVisual = true
			player:AnimateCollectible(mod.ITEM.COLLECTIBLE.GRAPPLING_HOOK, "LiftItem", "PlayerPickup")
		end
	end
end, mod.ITEM.COLLECTIBLE.GRAPPLING_HOOK)

function mod:grapplingHookPlayerUpdate(player, d)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.GRAPPLING_HOOK) then
        if not player.CanFly then
            local room = game:GetRoom()
            local gridcoll = room:GetGridCollisionAtPos(player.Position)
            if gridcoll == GridCollisionClass.COLLISION_PIT then
                --player.SpriteOffset = mod:Lerp(player.SpriteOffset, Vector(0,0), 0.3)
                if player:IsExtraAnimationFinished() and player:GetDamageCooldown() == 0 and not player:IsDead() then
                    if room:GetFrameCount() >= 2 and not (d.myVeryOwnGrapplingHook and d.myVeryOwnGrapplingHook:Exists() and d.myVeryOwnGrapplingHook:GetData().state == "reelin") then
                        player:AnimatePitfallIn()
                        player.Velocity = nilvector
                    end
                end
            elseif gridcoll >= 2 and gridcoll <= 4 then
                player.PositionOffset = Vector(0, -10)
                if not (d.myVeryOwnGrapplingHook and d.myVeryOwnGrapplingHook:Exists() and d.myVeryOwnGrapplingHook:GetData().state == "reelin") then
                    player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
                end
            else
                --player.SpriteOffset = mod:Lerp(player.SpriteOffset, Vector(0,0), 0.3)
                if not (d.myVeryOwnGrapplingHook and d.myVeryOwnGrapplingHook:Exists() and d.myVeryOwnGrapplingHook:GetData().state == "reelin") then
                    player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
                end
            end
        end
    end
    if d.myVeryOwnGrapplingHook and d.myVeryOwnGrapplingHook:Exists() then
        local gh = d.myVeryOwnGrapplingHook
        local hd = d.myVeryOwnGrapplingHook:GetData()
        if grapplingMode == 2 then
            local aim = mod.GetGoodShootingJoystick(player)
            if aim:Length() < 0.5 then
                if hd.state == "hooked" then
                    hd.state = "reelin"
                elseif hd.state == "flying" then
                    local room = game:GetRoom()
                    local pos = room:GetGridPosition(room:GetGridIndex(gh.Position + gh.Velocity:Resized(25)))
                    if room:GetGridCollisionAtPos(pos) == GridCollisionClass.COLLISION_PIT then
                        --gh.Position = pos
                        hd.state = "return"
                        gh.Velocity = nilvector
                    else
                        gh.Position = pos
                        hd.state = "reelin"
                        sfx:Play(mod.Sounds.GrappleGrab,0.3,0,false,math.random(100,110)/100)
                        gh.Velocity = nilvector
                        mod:spritePlay(gh:GetSprite(), "Pinned")
                    end
                end
            end
        end
    end
end

local GrapplingInvulnSpeed = 9

function mod:grapplingHookPlayerColl(player, collider)
    if collider.Type > 9 then
        local d = player:GetData()
        if d.myVeryOwnGrapplingHook and d.myVeryOwnGrapplingHook:Exists() and d.myVeryOwnGrapplingHook:GetData().state == "reelin" and player.Velocity:Length() > GrapplingInvulnSpeed then
            collider:TakeDamage(player.Damage, 0, EntityRef(player), 0)
            sfx:Play(mod.Sounds.BertranSlap, 0.3, 0, false, 1)
        end
    end
end

function mod:useHeldGrapplingHook(player, data, aim)
    local hook = Isaac.Spawn(mod.FF.GrapplingHook.ID, mod.FF.GrapplingHook.Var, mod.FF.GrapplingHook.Sub, player.Position - player.Velocity, aim * 30 * player.ShotSpeed + player:GetTearMovementInheritance(aim), player)
    hook.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
    hook.CollisionDamage = 8
    hook:GetSprite().Rotation = hook.Velocity:GetAngleDegrees()
    hook.Parent = player
    hook.SpawnerEntity = player
    data.myVeryOwnGrapplingHook = hook
    hook:GetData().LaunchVel = hook.Velocity
    hook:Update()
    sfx:Play(mod.Sounds.CleaverThrow,0.3,0,false, math.random(70,90)/100)
end


function mod:grapplingHookAI(e)
	local player = e.Parent:ToPlayer()
	local sprite = e:GetSprite()
	local d = e:GetData()

	--e.SpriteOffset = Vector(0, -15)
	e.RenderZOffset = -300

	if not d.init then
		d.state = "flying"
		d.init = true
	end

    e.SpriteOffset = Vector(0, -15)

    if not e.Child then
        local handler = Isaac.Spawn(1000, 1749, 162, e.Position, nilvector, e):ToEffect()
        handler.Parent = e
        handler.Visible = false
        handler:Update()

        local rope = Isaac.Spawn(EntityType.ENTITY_EVIS, 10, 162, e.Parent.Position, nilvector, e)
        e.Child = rope

        rope.Parent = handler
        rope.Target = player

        rope:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        rope:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        rope.DepthOffset = -50

        rope:GetSprite():Play("Idle", true)
        rope:GetSprite():SetFrame(100)
        rope:Update()

        rope.SplatColor = Color(1,1,1,0,0,0,0)
    end
    e.Child:Update()
    e.Child:Update()

	if d.state == "flying" then
        if d.LaunchVel then
            e.Velocity = d.LaunchVel
        end
		mod:spritePlay(sprite, "Idle")
        e.SpriteRotation = (e.Position - player.Position):GetAngleDegrees() + 180
		if game:GetRoom():GetGridCollisionAtPos(e.Position) >= 4 then
            if hookmode == 1 then
			    d.state = "hooked"
            elseif hookmode == 2 then
                d.state = "reelin"
            end
            sfx:Play(mod.Sounds.GrappleGrab,0.3,0,false,math.random(80,100)/100)
			--SFXManager():Play(SoundEffect.SOUND_GOOATTACH0,1,0,false,math.random(80,100)/100)
			e.Velocity = nilvector
			mod:spritePlay(sprite, "Pinned")
        else
            --[[local targ = mod.FindClosestEnemy(e.Position, 500)
            if targ.Position:Distance(e.Position) < e.Size + targ.Size then
                d.state = "reelin"
                SFXManager():Play(SoundEffect.SOUND_GOOATTACH0,1,0,false,math.random(80,100)/100)
                e.Velocity = nilvector
                mod:spritePlay(sprite, "Pinned")
                d.enemyHook = targ
            end]]
		end
	elseif d.state == "hooked" then
        e.Velocity = nilvector
        if game:GetRoom():GetGridCollisionAtPos(e.Position) < 4 then
            e.SpriteRotation = -90
        end
		if not sprite:IsPlaying("Pinned") then
			mod:spritePlay(sprite, "PinnedIdle")
		end
    elseif d.state == "reelin" then
        if d.enemyHook and d.enemyHook:Exists() then
            local targetVec = (d.enemyHook.Position + d.enemyHook.Velocity) - e.Position
            if targetVec:Length() > 30 then
                targetVec = targetVec:Resized(30)
            end
            e.Velocity = mod:Lerp(e.Velocity, targetVec, 0.5)
        else
            e.Velocity = nilvector
        end
        local vec = e.Position - player.Position
        player.Velocity = mod:Lerp(player.Velocity, vec:Resized(math.min(vec:Length(), 50)), 0.1)

        if not player.CanFly then
            player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        end
        if game:GetRoom():GetGridCollisionAtPos(e.Position) < 2 then
            e.SpriteRotation = -90
        end
		if not sprite:IsPlaying("Pinned") then
			mod:spritePlay(sprite, "PinnedIdle")
		end
        --print(player.Velocity:Length())
        if player.Velocity:Length() > GrapplingInvulnSpeed then
            player:SetMinDamageCooldown(5)
            if e.FrameCount % 2 == 0 then
                --player:SetColor(Color(0.5, 0.5, 0.5, 1, 0.11, 0.11, 0.11), 1, 1, true, false)
                player:SetColor(Color(0.5, 0.5, 0.5, 1, 0.35, 0.35, 0.35), 1, 1, true, false)
            end
            local grident = game:GetRoom():GetGridEntityFromPos(player.Position)
            if grident and grident:ToPoop() then
                grident:Destroy(true)
            end
        end

        if player.Position:Distance(e.Position) < 10 or player:IsDead() then
            d.state = "return"
            sfx:Play(mod.Sounds.GrappleGrab,0.3,0,false,math.random(130,150)/100)
        end
    elseif d.state == "return" then
        --e.Velocity = mod:Lerp(e.Velocity, player.Position - e.Position, 0.5)
        local targetVec = ((player.Position + player.Velocity) - e.Position)
        if targetVec:Length() > 30 then
            targetVec = targetVec:Resized(30)
        end
        e.Velocity = mod:Lerp(e.Velocity, targetVec, 0.5)
        mod:spritePlay(sprite, "Idle")
        e.SpriteRotation = (e.Position - player.Position):GetAngleDegrees() + 180

        if e.Position:Distance(player.Position) < 10 then
            if e.Child then
                e.Child:Remove()
            end
            e:Remove()
        end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, handler)
	if handler.SubType == 162 then
		if not handler.Parent or not handler.Parent:Exists() then
			handler:Remove()
		else
			handler.Position = handler.Parent.Position + handler.Parent.SpriteOffset + Vector(0,11)
			handler.Velocity = handler.Parent.Velocity
		end
	end
end, 1749)


mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, function(_, npc)
    if npc.Variant == 10 and npc.SubType == 162 then
        return false
    end
end, EntityType.ENTITY_EVIS)
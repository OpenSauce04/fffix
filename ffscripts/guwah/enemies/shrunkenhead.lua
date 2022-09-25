local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:ShrunkenHeadAI(npc, sprite, data)
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    local rng = npc:GetDropRNG()

    if not data.Init then
        if npc.SubType > 1 then
            local headgroup = {}
            local vec = RandomVector()*10
            for i = 1, npc.SubType do
                local head = Isaac.Spawn(mod.FF.ShrunkenHead.ID, mod.FF.ShrunkenHead.Var, 0, npc.Position + vec:Rotated(360/i), Vector.Zero, npc.SpawnerEntity):ToNPC()
                head:GetData().ImBaby = true
				if npc:IsChampion() and i == 1 then
					head:MakeChampion(69, npc:GetChampionColorIdx(), true)
					head.HitPoints = head.MaxHitPoints
				end
                table.insert(headgroup, EntityRef(head))
            end
            table.insert(mod.ShrunkenHeadGroups, {["Heads"] = headgroup, ["CenterPos"] = npc.Position})
			npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            npc:Remove()
        elseif not data.ImBaby then
            table.insert(mod.ShrunkenHeadGroups, {["Heads"] = {EntityRef(npc)}, ["CenterPos"] = npc.Position})
        end

        local skin = mod:RandomInt(1,4,rng)
        mod:ReplaceEnemySpritesheet(npc, "gfx/enemies/shrunkenhead/monster_shrunkenhead0"..skin)
        sprite.FlipX = (rng:RandomFloat() <= 0.5)
        npc.SplatColor = Color(0.5,0.5,0.5)

        data.Params = ProjectileParams()
        data.Params.Scale = 0.6
    
        sprite:Play("Appear")
        data.State = "Idle"
        data.Init = true
    end

    if data.State == "Idle" then
        if not sprite:IsPlaying("Appear") then
            mod:spritePlay(sprite, "Idle")
        end
    elseif data.State == "Attack" then
        if sprite:IsFinished("Shoot") then
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Shoot") then
            npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(8), 0, data.Params)
            mod:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR, npc, 1.1)
            mod:FlipSprite(sprite, npc.Position, targetpos)

            local effect = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc):ToEffect()
            effect.SpriteScale = Vector(0.8,0.8)
            effect.SpriteOffset = Vector(0,-20)
            effect.Color = Color(1,1,1,0.6)
            effect.DepthOffset = npc.Position.Y + 40
            effect:FollowParent(npc)
        else
            mod:spritePlay(sprite, "Shoot")
        end
    end

    if data.TargetPos then
        data.TargetAngle = data.TargetAngle or mod:RandomAngle()
        data.TargetOffset = data.TargetOffset or mod:RandomInt(0,20,rng)
        if mod:RandomInt(1,5) == 1 then
            data.TargetAngle = data.TargetAngle + mod:RandomInt(-45,45,rng)
            data.TargetOffset = mod:RandomInt(0,20,rng)
        end
        npc.TargetPosition = data.TargetPos + Vector(data.TargetOffset,0):Rotated(data.TargetAngle)

        local vel = (npc.TargetPosition - npc.Position)
        vel = vel:Resized(math.min(12, vel:Length()))
        npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.05)
    end
end

function mod:ShrunkenHeadGroupControl(group) --This is like Ztewies but much simpler
    local room = game:GetRoom()
    group.AttackTimer = group.AttackTimer or mod:RandomInt(30,60)
    group.AttackTimer = group.AttackTimer - 1
    group.GiveUpTimer = group.GiveUpTimer or 90
    group.GiveUpTimer = group.GiveUpTimer - 1
    group.TargetPos = group.TargetPos or (game:GetNearestPlayer(group.CenterPos).Position + (RandomVector() * mod:RandomInt(0,80)))

    local heads = {}
    for _, headref in pairs(group.Heads) do
        if headref.Entity then
            if mod:IsReallyDead(headref.Entity) then
                headref.Entity = nil
            else
                table.insert(heads, headref.Entity)
            end
        end
    end
    local count = #heads
    --print(count)
    if count > 0 then
        for _, head in pairs(heads) do
            head:GetData().TargetPos = group.CenterPos
        end
        if group.TargetPos:Distance(group.CenterPos) <= 5 or group.GiveUpTimer <= 0 then
            group.TargetPos = (game:GetNearestPlayer(group.CenterPos).Position + (RandomVector() * mod:RandomInt(0,80)))
            group.GiveUpTimer = mod:RandomInt(15,90)
        elseif room:GetFrameCount() > 30 then
            group.CenterPos = group.CenterPos + (group.TargetPos - group.CenterPos):Resized(1.5)
        end
        if group.AttackTimer <= 0 then
            local valids = {}
            for _, head in pairs(heads) do
                if not (mod:IsReallyDead(head) or head:GetData().State ~= "Idle") then
                    head = head:ToNPC()
                    local targetpos = mod:confusePos(head, head:GetPlayerTarget().Position)
                    if room:CheckLine(head.Position, targetpos, 3, 0, false, false) and head.Position:Distance(targetpos) < 300 then
                        table.insert(valids, head)
                    end
                end
            end
        
            local attackhead = mod:GetRandomElem(valids)
            if attackhead then
                attackhead:GetData().State = "Attack"
                group.AttackTimer = mod:RandomInt(30,60)
            end
        end
    else
        group = nil
    end
end
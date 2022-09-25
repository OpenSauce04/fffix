local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.OphiuchusSpriteDirs = {
    {AnimString = "DiagDown", SpriteFlip = false},
    {AnimString = "Down", SpriteFlip = false},
    {AnimString = "DiagDown", SpriteFlip = true},
    {AnimString = "Hori", SpriteFlip = true},
    {AnimString = "DiagUp", SpriteFlip = true},
    {AnimString = "Up", SpriteFlip = false},
    {AnimString = "DiagUp", SpriteFlip = false},
    {AnimString = "Hori", SpriteFlip = false},
    
    }
    
    mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
        local player = fam.Player
        local d = fam:GetData()
        local sprite = fam:GetSprite()
		local isSirenCharmed, charmer = mod:isSirenCharmed(fam)
    
        local WiggleOff1, WiggleOff2 = 10, 5
		
		if fam.SubType == 0 then
            fam.CollisionDamage = math.max(0.5, player.Damage / 10)
    
            if not d.init then
                d.prevPositions = {}
                d.init = true
            else
                d.StateFrame = d.StateFrame or 0
                d.StateFrame = d.StateFrame + 1
            end
    
            if not fam.Child then
                local segs = 5
                for i = 1, segs do
                    local seg = Isaac.Spawn(3, FamiliarVariant.OPHIUCHUS, i, fam.Position, nilvector, fam):ToFamiliar()
                    seg.Parent = fam
					seg.Player = fam.Player
                    if i == segs then
                        seg:GetData().Tail = true
                    end
                    seg:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    --[[if player:HasCollectible(CollectibleType.COLLECTIBLE_KEEPERS_SACK) and i == segs - 1 then
                        for j = -70, 70, 140 do
                            local ball = Isaac.Spawn(3, FamiliarVariant.OPHIUCHUS, i, fam.Position, nilvector, fam):ToFamiliar()
                            ball:GetData().Balls = j
                            ball.Parent = fam
							ball.Player = fam.Player
                            ball:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                            ball:Update()
							fam:GetData().Segments = fam:GetData().Segments or {}
							table.insert(fam:GetData().Segments, ball)
                        end
                    end]]
                    seg:Update()
                    fam.Child = seg
					fam:GetData().Segments = fam:GetData().Segments or {}
					table.insert(fam:GetData().Segments, seg)
                end
    
            end
    
            fam.SpriteOffset = Vector(0, -12 + math.sin(fam.FrameCount / WiggleOff1) * WiggleOff2)
    
            local target
            local speed = 5
            local extraString = ""
			if isSirenCharmed then
				target = mod:getClosestPlayer(fam.Position, 150)
			else
				target = mod.FindClosestEnemy(fam.Position, 150, true, nil, nil, EntityCollisionClass.ENTCOLL_PLAYEROBJECTS, EntityFlag.FLAG_POISON)
			end
            if target then
                speed = 7
                extraString = "Attack"
            else
                target = player
            end
    
            local targvel = (target.Position - fam.Position):Resized(speed)
            fam.Velocity = mod:Lerp(fam.Velocity:Resized(math.max(fam.Velocity:Length(), 3)), targvel, 0.1):Rotated(math.sin((fam.FrameCount) / 7) * 8)
    
            local ang = math.ceil(((fam.Velocity:GetAngleDegrees() - 22.5) % 360) / 45)
            local anim = "Head" .. mod.OphiuchusSpriteDirs[ang].AnimString .. extraString
            --mod:spritePlay(sprite, anim)
            sprite:SetFrame(anim, fam.FrameCount % 10)
            sprite.FlipX = mod.OphiuchusSpriteDirs[ang].SpriteFlip
    
            d.prevPositions = d.prevPositions or {}
            table.insert(d.prevPositions, 1, {
                    Position = fam.Position,
                    Velocity = fam.Velocity,
                }
            )
            if #d.prevPositions > 50 then
                table.remove(d.prevPositions, #d.prevPositions)
            end
        else
			if not isSirenCharmed and fam.Parent then
				fam.Player = fam.Parent:ToFamiliar().Player
				player = fam.Player
			end
		
            fam.CollisionDamage = 0.1
            if fam.Parent then
                local p = fam.Parent
                local pd = p:GetData()
                local posOffset = (fam.SubType * 5) + 1
                if pd.prevPositions and #pd.prevPositions >= posOffset then
                    fam.Position = pd.prevPositions[posOffset].Position
                    fam.Velocity = pd.prevPositions[posOffset].Velocity
                    if d.Balls then
                        fam.Position = fam.Position + fam.Velocity:Rotated(d.Balls):Resized(7)
                    end
                else
                    fam.Visible = false
                end
                if pd.prevPositions and not isSirenCharmed then
                    local AlphaCol = math.max(math.min(((#pd.prevPositions - posOffset) / 5), 1), 0)
                    if AlphaCol > 0.1 then
                        fam.Visible = true
                    end
                    fam.Color = Color(AlphaCol,AlphaCol,AlphaCol,AlphaCol)
				end
					
                fam.SpriteOffset = Vector(0, -14 + math.sin((p.FrameCount - fam.SubType * 10) / WiggleOff1) * WiggleOff2)
    
                if d.Balls then
                    fam.SpriteOffset = fam.SpriteOffset + Vector(0, 9)
                end
    
                if d.Tail then
                    mod:spritePlay(sprite, "Tail")
                else
                    mod:spritePlay(sprite, "Segment")
                end
                fam.Velocity = nilvector
            else
				fam:Remove()
			end
        end
		
		if isSirenCharmed then fam.CollisionDamage = 0 end
    
    end, FamiliarVariant.OPHIUCHUS)
    
    mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, familiar, collider)
        if familiar.SubType == 0 and collider.Type > 9 and collider.EntityCollisionClass >= 2 then
            if (not collider:HasEntityFlags(EntityFlag.FLAG_NO_TARGET)) and (not collider:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)) and (not mod:isFriend(collider)) then
                if not collider:HasEntityFlags(EntityFlag.FLAG_POISON) then
					local isSirenCharmed = mod:isSirenCharmed(familiar)
					if not isSirenCharmed then
						local PoisonDamage = familiar.Player.Damage
						if not familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
							PoisonDamage = familiar.Player.Damage / 2
						end
						collider:AddPoison(EntityRef(familiar.Player), 30, PoisonDamage)
					end
                end
            end
        end
    end, FamiliarVariant.OPHIUCHUS)
	
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, helper)
	if helper.FrameCount == 0 then
		if helper.Target and 
		   helper.Target.Type == EntityType.ENTITY_FAMILIAR and 
		   helper.Target.Variant == FamiliarVariant.OPHIUCHUS and 
		   helper.Target.SubType == 0 
		then
			for _,seg in ipairs(helper.Target:GetData().Segments) do
				if seg:Exists() and not mod:isSirenCharmed(seg) and helper.Parent and helper.Parent:Exists() then
					local segmenthelper = Isaac.Spawn(EntityType.ENTITY_SIREN_HELPER, 0, 0, seg.Position, nilvector, nil):ToNPC()
					segmenthelper.Parent = helper.Parent
					segmenthelper.Target = seg
					segmenthelper:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					segmenthelper:AddEntityFlags(EntityFlag.FLAG_HIDE_HP_BAR)
					segmenthelper:Update()
					
					seg.Player = helper.Target:ToFamiliar().Player
				end
			end
		end
	end
end, EntityType.ENTITY_SIREN_HELPER)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, amount, flags, source, countdown)
	if flags ~= flags | DamageFlag.DAMAGE_CLONES and 
	   ent.Target and 
	   ent.Target.Type == EntityType.ENTITY_FAMILIAR and 
	   ent.Target.Variant == FamiliarVariant.OPHIUCHUS 
	then
		local snek = ent.Target
		
		local head
		if snek.SubType ~= 0 then
			head = snek.Parent
		else
			head = snek
		end
		
		if head then
			local _, headcharmer = mod:isSirenCharmed(head)
			if headcharmer and (headcharmer.Index ~= ent.Index or headcharmer.InitSeed ~= ent.InitSeed) then
				headcharmer:TakeDamage(amount, flags | DamageFlag.DAMAGE_CLONES, source, countdown)
			end
			
			local segments = head:GetData().Segments
			for _,segment in ipairs(segments) do
				local _, segmentcharmer = mod:isSirenCharmed(segment)
				if segmentcharmer and (segmentcharmer.Index ~= ent.Index or segmentcharmer.InitSeed ~= ent.InitSeed) then
					segmentcharmer:TakeDamage(amount, flags | DamageFlag.DAMAGE_CLONES, source, countdown)
				end
			end
		end
	end
end, EntityType.ENTITY_SIREN_HELPER)
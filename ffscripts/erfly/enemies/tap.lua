local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:tapAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
    local room = game:GetRoom()

	--Set this to true and you can try out the unused honey mode
	local honeyModeActivated = false
	--Actually screw it anyone can find em now! Have fun :)
	if npc.SubType == 10 then
		honeyModeActivated = true
	end

	local emergesound = mod.Sounds.TapStart
	local loopsound = mod.Sounds.TapLoop
	local creeptype = 22

	if honeyModeActivated then
		emergesound = mod.Sounds.TapHoney01
		loopsound = mod.Sounds.TapHoney02
		creeptype = 24
	end

	if not d.init then
		d.state = "idle"
		d.Index = room:GetGridIndex(npc.Position)
        room:SpawnGridEntity(d.Index, GridEntityType.GRID_ROCK_ALT, 0, 1, 0)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		d.init = true
		npc.StateFrame = -1
		if honeyModeActivated then
			sprite:ReplaceSpritesheet(0, "gfx/enemies/tap/tapHoney.png")
			sprite:LoadGraphics()
		end
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	npc.SpriteOffset = Vector(-1,-11)

	if sprite:IsEventTriggered("Place") then
		npc:PlaySound(mod.Sounds.TapTap,0.3,0,false,math.random(90,100)/100)
	end

	if d.state == "idle" then
		if npc.StateFrame > 0 then
			if room:GetGridCollisionAtPos(npc.Position) == GridCollisionClass.COLLISION_NONE then
				sfx:Stop(loopsound)
				npc:Remove()
			end
		end
		mod:spritePlay(sprite, "Idle")
		if npc.StateFrame > 20 and math.random(5) == 1 then
			d.state = "burrow"
			npc:PlaySound(mod.Sounds.TapEnd,0.6,1,false,math.random(90,100)/100)
		end
	elseif d.state == "burrow" then
		if room:GetGridCollisionAtPos(npc.Position) == GridCollisionClass.COLLISION_NONE then
			sfx:Stop(loopsound)
			npc:Remove()
		end
		if sprite:IsFinished("Burrow") then
			mod.OccupiedGrids[d.Index] = "Open"
			if room:IsClear() then
				npc:Remove()
			else
				d.Index = mod:GetUnoccupiedPot(d.Index)
				mod.OccupiedGrids[d.Index] = "Closed"
				npc.Position = room:GetGridPosition(d.Index)
				d.state = "emerge"
				npc:PlaySound(emergesound,0.6,2,false,math.random(90,100)/100)
			end
		else
			mod:spritePlay(sprite, "Burrow")
		end
	elseif d.state == "emerge" then
		if room:GetGridCollisionAtPos(npc.Position) == GridCollisionClass.COLLISION_NONE then
			sfx:Stop(loopsound)
			npc:Remove()
		end
		if sprite:IsFinished("Emerge") then
			d.state = "spew"
		else
			mod:spritePlay(sprite, "Emerge")
		end
	elseif d.state == "spew" then
		if room:GetGridCollisionAtPos(npc.Position) == GridCollisionClass.COLLISION_NONE then
			sfx:Stop(loopsound)
			npc:Remove()
		end
		if sprite:IsFinished("Spew") then
			d.state = "idle"
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Creep Start") then
			d.leavecreep = true
			d.creeprot = 0
			npc.StateFrame = 0
		elseif sprite:IsEventTriggered("Creep Stop") then
			d.leavecreep = false
			sfx:Stop(loopsound)
		else
			mod:spritePlay(sprite, "Spew")
		end
	end

	if d.leavecreep then
		if not sfx:IsPlaying(loopsound) then
			sfx:Play(loopsound, 1, 0, true, 1)
		end
		if npc.StateFrame % 2 == 0 then
			local ang = (90 / 8) * npc.StateFrame
			local vec = Vector(0, 30):Rotated(-ang)
			local creep = Isaac.Spawn(1000, creeptype, 0, npc.Position + vec, nilvector, npc):ToEffect();
			creep:SetTimeout(40)
			creep:Update();
		end
	end
end
local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:deathanyAI(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()

	mod.doMistEffect = true

	if not d.init then
		d.init = true
		d.state = "waiting"
		npc.Visible = false
		npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.Position = target.Position
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	end

	if d.state == "waiting" then
		if npc.FrameCount < 1 then
			npc.Position = target.Position
		end
		npc.Velocity = nilvector
		if npc.FrameCount > 10 then
			if target.Position:Distance(npc.Position) > 120 then
				d.state = "appear"
				npc:PlaySound(SoundEffect.SOUND_MONSTER_ROAR_3,1,0,false,1.6)
				d.startRecording = true
				sprite:Play("Appear", true)
				npc.Visible = true
				d.spawners = {}
				local subWillo = 6
				if npc.SubType > 0 then
					subWillo = npc.SubType
				end
				for i = 1, subWillo do
					local vec = Vector(-45	, 0):Rotated((360 / subWillo) * i - 1)
					local telin = Isaac.Spawn(1000, 157, 960, npc.Position + vec, Vector.Zero, npc)
					telin.Color = Color(1,1,1,1,1,1,1)
					table.insert(d.spawners, telin)
				end
			end
		end
	elseif d.state == "appear" then
		if sprite:IsFinished("Appear") then
			d.state = "chasing"
		elseif sprite:IsEventTriggered("Summon") then
			for i = 1, #d.spawners do
				local willo = Isaac.Spawn(808, 0, 0, d.spawners[i].Position, nilvector, npc):ToNPC()
				willo.Parent = npc
				willo:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				willo.V1 = Vector(45, 1)
				willo.TargetPosition = willo.Position
				willo.State = 14
				--willo.Color = Color(1,1,1,1,0.4,0.6,0.5)
				local wSprite = willo:GetSprite()
				wSprite:Load("gfx/enemies/deathany/willo_grey.anm2", true)
				wSprite:Play("UnderwaterSpawn", true)
				willo.CollisionDamage = 1
				willo:Update()
			end
		end
	elseif d.state == "chasing" then
		mod:spritePlay(sprite, "Idle")
		if npc.FrameCount % 10 == 0 then
			local stillgood
			for _, willo in ipairs(Isaac.FindByType(808, -1, -1, false, false)) do
				if willo.Parent and willo.Parent.InitSeed == npc.InitSeed then
					stillgood = true
				end
			end
			if not stillgood then
				d.state = "death"
				npc:PlaySound(SoundEffect.SOUND_MONSTER_ROAR_2,1,0,false,1.6)
				d.startRecording = nil
			end
		end
	elseif d.state == "death" then
		npc.Velocity = npc.Velocity * 0.5
		for _, willo in ipairs(Isaac.FindByType(808, -1, -1, false, false)) do
			if willo.Parent and willo.Parent.InitSeed == npc.InitSeed then
				willo:Kill()
			end
		end
		if sprite:IsFinished("Death") then
			npc:Remove()
		else
			mod:spritePlay(sprite, "Death")
		end
	end

	if d.startRecording then
		d.playerPos = d.playerPos or {}
		table.insert(d.playerPos, 1, target.Position)
		local limit = 45
		if #d.playerPos > limit then
			table.remove(d.playerPos, limit + 1)
		end

		if d.playerPos[limit] then
			local targvel = d.playerPos[limit] - npc.Position
			targvel = targvel:Resized(math.min(targvel:Length(), 10))
			npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.1)
		else
			npc.Velocity = nilvector
		end
	end
end

function mod:checkWillo(npc)
	if npc.Parent and npc.Parent.Type == mod.FF.Deathany.ID and npc.Parent.Variant == mod.FF.Deathany.Var then
		npc.V1 = Vector(45, 1)
		local sprite = npc:GetSprite()
		if npc.State == 14 and sprite:IsPlaying("UnderwaterSpawn") and sprite:GetFrame() > 2 then
			npc.State = 0
			npc.StateFrame = 0
			npc:Update()
		elseif npc.State ~= 14 then
			npc.State = 3
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.checkWillo, 808)

function mod:tryDoRoomMist()
	if mod.GetEntityCount(mod.FF.Deathany.ID, mod.FF.Deathany.Var) > 0 then
		mod.doMistEffect = true
		local room = Game():GetRoom()
		local count = 50
		if room:IsMirrorWorld() then
			count = 30
		end
		for i = 1, count do
			local vecX = math.random() * 2
			if math.random(2) == 1 then
				vecX = vecX * -1
			end

			local side = -400 + math.random(room:GetGridWidth()*40 + 650)

			local eff = Isaac.Spawn(1000, 138, 960, Vector(side, 30 + math.random(room:GetGridHeight() * 40 + 120)), Vector(vecX, 0), nil):ToEffect()
			eff:GetData().opacity = math.random()
			eff:GetSprite():Stop()
			eff:GetSprite():SetFrame(math.random(4)-1)
			eff.Timeout = 1000
			eff:Update()
		end
	else
		mod.doMistEffect = nil
	end
end

function mod:roomMist()
	if mod.doMistEffect then
		local room = Game():GetRoom()
		local frameNum = 30
		if room:IsMirrorWorld() then
			frameNum = 60
		end
		if room:GetFrameCount() % frameNum == 0 then
			local side = -400
			local vecX = math.random() * 2
			if math.random(2) == 1 then
				vecX = vecX * -1
				side = room:GetGridWidth()*40 + 650
			end

			local eff = Isaac.Spawn(1000, 138, 960, Vector(side, 30 + math.random(room:GetGridHeight() * 40 + 120)), Vector(vecX, 0), nil):ToEffect()
			eff:GetData().opacity = math.random()
			eff:GetSprite():Stop()
			eff:GetSprite():SetFrame(math.random(4)-1)
			eff.Timeout = 1000
			eff:Update()
		end
	end
end
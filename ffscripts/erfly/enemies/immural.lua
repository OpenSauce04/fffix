local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.ImmuralAppearOffset = {154,138,121,105,88,72,55,39,33,28,23,18,13,10,8,6,4,3,2,1,1,4,8,8,8,6,5,3,2,1,0,0,0,0,0}

mod.immuralBlacklist = {
	[mod.FF.Immural.ID .. " " .. mod.FF.Immural.Var] = true,		-- Immural
	[mod.FF.EternalFlickerspirit.ID .. " " .. mod.FF.EternalFlickerspirit.Var] = true,		-- Eternal Flickerspirit
	[mod.FF.Viscerspirit.ID .. " " .. mod.FF.Viscerspirit.Var] = true,      -- Viscerspirit
	[mod.FF.Onlooker.ID .. " " .. mod.FF.Onlooker.Var] = true,      -- Onlooker
    [mod.FF.EffigyCord.ID .. " " .. mod.FF.EffigyCord.Var .. " " .. mod.FF.EffigyCord.Sub] = true,
    [mod.FF.HarletwinCord.ID .. " " .. mod.FF.HarletwinCord.Var .. " " .. mod.FF.HarletwinCord.Sub] = true,
	[mod.FF.NerviePoint.ID .. " " .. mod.FF.NerviePoint.Var] = true,   
	[mod.FF.WaitingWorm.ID .. " " .. mod.FF.WaitingWorm.Var] = true,   
	[mod.FF.WaitingSpider.ID .. " " .. mod.FF.WaitingSpider.Var] = true,  
}

function mod:isImmuralBlacklisted(entity)
	return mod.immuralBlacklist[entity.Type] or
	       mod.immuralBlacklist[entity.Type .. " " .. entity.Variant] or
	       mod.immuralBlacklist[entity.Type .. " " .. entity.Variant .. " " .. entity.SubType]
end

function mod:immuralAI(npc, subt)
	local sprite = npc:GetSprite()
	local d = npc:GetData()

	if not d.init then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		d.connectedboys = {}

		local room = game:GetRoom()
		--Could possibly make this work for void in like, cellar or sheol backdrop rooms            but fuck it ykno?
		if room:GetBackdropType() == 12 then
			sprite:ReplaceSpritesheet(0, "gfx/enemies/immural/immural_scarredwomb.png")
			sprite:LoadGraphics()
		elseif room:GetBackdropType() == BackdropType.CORPSE then
			sprite:ReplaceSpritesheet(0, "gfx/enemies/immural/immural_corpse.png")
			sprite:LoadGraphics()
		end

		if subt == 1 then
			d.state = "dead"
			sprite:Play("FloorBound", true)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		else
			d.state = "appear"
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			for i = 1, 20 do
				local immuraldangler = Isaac.Spawn(1000, 1729, 0, npc.Position, nilvector, npc)
				immuraldangler.Parent = npc
				immuraldangler:GetData().LinePos = i
				immuraldangler:Update()
			end
			for _, entity in pairs(Isaac.GetRoomEntities()) do
				if entity.Position:Distance(npc.Position) < 100 then
					if not mod:isImmuralBlacklisted(entity) then
						if entity:IsActiveEnemy() then
							table.insert(d.connectedboys, entity)
						end
					end
				end
			end
			sprite:Play("Appear", true)
		end
		d.init = true
	end

	if npc.FrameCount % 10 == 0 then
		for _,ClosePickup in ipairs(Isaac.FindInRadius(npc.Position, 1, EntityPartition.PICKUP)) do
			ClosePickup.Velocity = RandomVector()*2
		end
	end

	if #d.connectedboys > 0 then
		for _, entity in pairs(d.connectedboys) do
			if entity and not (entity:IsDead() or mod:isStatusCorpse(entity)) then
				local dist = entity.Position:Distance(npc.Position)
				if dist > 100 then
					local vec = (npc.Position - entity.Position):Resized(math.min(10, dist - 100))
					--entity.Velocity = entity.Velocity + vec
					entity.Position = entity.Position + vec
					entity.Velocity = entity.Velocity * 0.1
				end
			else
				for i = 1, #d.connectedboys do
					if (d.connectedboys[i].InitSeed and entity.InitSeed == d.connectedboys[i].InitSeed) or not d.connectedboys[i].InitSeed then
						table.remove(d.connectedboys, i)
						break
					end
				end
			end
		end
	elseif d.state ~= "dead" then
		d.state = "dead"
		mod:spritePlay(sprite, "Fall")
		sfx:Play(SoundEffect.SOUND_MEATHEADSHOOT, 1, 0, false, 0.85)
	end

	--Isaac.ConsoleOutput(#d.connectedboys)

	if d.state == "appear" then
		npc.Velocity = nilvector
		d.hangoffset = mod.ImmuralAppearOffset[sprite:GetFrame() + 1]
		if sprite:IsFinished("Appear") then
			mod:spritePlay(sprite, "Hanging")
			d.hangoffset = 0
			d.state = "idle"

			for _, entity in pairs(d.connectedboys) do
				for i = 1, 6 do
				local connectingDangle = Isaac.Spawn(1000, 1729, 1, npc.Position, nilvector, npc)
				local chaind = connectingDangle:GetData()
				chaind.Pos = i
				chaind.Num = 8
				chaind.Source = entity
				chaind.Home = npc
				connectingDangle:GetSprite():Play("CordAppear2")
				connectingDangle:Update()
				end
			end

		end
	elseif d.state == "idle" then
		npc.Velocity = nilvector
		mod:spritePlay(sprite, "Hanging")

	elseif d.state == "dead" then
		npc.Velocity = nilvector
		if sprite:IsFinished("Fall") then
			mod:spritePlay(sprite, "FloorBound")
		end
		if sprite:IsEventTriggered("dropped") then
			sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 1, 0, false, 0.7)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			local r = npc:GetDropRNG()
			local params = ProjectileParams()
			for i = 30, 360, 30 do
				local rand = r:RandomFloat()
				params.FallingSpeedModifier = -30 + math.random(10);
				params.FallingAccelModifier = 2
				params.VelocityMulti = math.random(13,19) / 10
				npc:FireProjectiles(npc.Position, Vector(0,3):Rotated(i-40+rand*80), 0, params)
			end
		end
	end
end

function mod:ImmuralChain(e)
	local d = e:GetData()
	local sprite = e:GetSprite()

	if not d.init then
		local room = game:GetRoom()
		if room:GetBackdropType() == 12 then
			sprite:ReplaceSpritesheet(0, "gfx/enemies/immural/immural_scarredwomb.png")
			sprite:LoadGraphics()
		elseif room:GetBackdropType() == BackdropType.CORPSE then
			sprite:ReplaceSpritesheet(0, "gfx/enemies/immural/immural_corpse.png")
			sprite:LoadGraphics()
		end
		d.init = true
	end

	if e.SubType == 1 then
		if not d.dying and (d.Source and not (d.Source:IsDead() or mod:isStatusCorpse(d.Source))) and (d.Home and not d.Home:IsDead()) then
			if d.Source:GetData().released then
				e:Remove()
			end
			local dist = d.Source.Position:Distance(d.Home.Position)
			local vecfun = d.Home.Position - d.Source.Position
			local targpos = d.Source.Position + vecfun:Resized(dist * ((d.Pos + 0.7) / d.Num))

			local targvel = (targpos - e.Position):Resized(3)
			--npc.Velocity = targvel
			e.Velocity = nilvector
			e.Position = targpos
			--local enemysYoff = d.Source.SpriteOffset.Y
			--e.SpriteOffset = Vector(0, enemysYoff - 12 - ((30 - enemysYoff) * (d.Pos / d.Num) ))
			e.SpriteOffset = Vector(0, -12 - ((30) * (d.Pos / d.Num) ))

			if sprite:IsFinished("CordAppear2") then
				mod:spritePlay(sprite, "Cord")
			end
		else
			d.dying = true
			if sprite:IsFinished("CordDestroy") then
				e:Remove()
			else
				mod:spritePlay(sprite, "CordDestroy")
			end
		end
	else
		local npcp = e.Parent
		if not d.dying and npcp then
			local pd = npcp:GetData()
			local topmostpos = 200
			local danglerpos = pd.hangoffset or 171
			local actualdist = (topmostpos - danglerpos)

			local yOffset =  (actualdist / 20) * d.LinePos

			e.RenderZOffset = 5000

			e.SpriteOffset = Vector(1, -257 + yOffset)
			local col = (1 / 20) * d.LinePos
			e.Color = Color(1,1,1,col,0,0,0)

			if npcp:GetData().state == "dead" then
				if sprite:IsFinished("CordDestroy") then
					e:Remove()
				else
					mod:spritePlay(sprite, "CordDestroy")
				end
			else
				mod:spritePlay(sprite, "Cord")
			end
		else
			d.dying = true
			if sprite:IsFinished("CordDestroy") then
				e:Remove()
			else
				mod:spritePlay(sprite, "CordDestroy")
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.ImmuralChain, 1729)

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local function CollapseSubType(npc)
	local mask = npc.SubType % 8
	return npc.SubType - mask
end

function mod.IsCustomRockBall(npc)
	local check = CollapseSubType(npc)

	return (
		check == mod.FF.RockBallMines.Sub or
		check == mod.FF.RockBallMinesLava.Sub or
		check == mod.FF.RockBallAshpit.Sub or
		check == mod.FF.RockBallAshpitLava.Sub or
		check == mod.FF.RockBallGold.Sub or
		check == mod.FF.RockBallTumbleweed.Sub or
		check == mod.FF.RockBallFootball.Sub
	)
end

local function IsLavaRock(npc)
	local check = CollapseSubType(npc)

	return (
		check == mod.FF.RockBallMinesLava.Sub or
		check == mod.FF.RockBallAshpitLava.Sub
	)
end

return {
	Init = function(npc)
		local ballType = CollapseSubType(npc)
		local skin

		mod.XalumInitNpcRNG(npc)

		if ballType == mod.FF.RockBallMines.Sub or ballType == mod.FF.RockBallAshpit.Sub then
			local data = npc:GetData()
			if data.rng:RandomFloat() < 1/64 and not npc.SpawnerEntity then
				local subTypeDifference = npc.SubType - ballType
				local newSubType = mod.FF.RockBallGold.Sub + subTypeDifference

				npc.SubType = newSubType
				ballType = mod.FF.RockBallGold.Sub
			end
		end

		if ballType == mod.FF.RockBallMines.Sub then
			skin = "gfx/grid/balls/rockball_mine.png"
		elseif ballType == mod.FF.RockBallMinesLava.Sub then
			skin = "gfx/grid/balls/rockball_mine_lava.png"
		elseif ballType == mod.FF.RockBallAshpit.Sub then
			skin = "gfx/grid/balls/rockball_ashpit.png"
		elseif ballType == mod.FF.RockBallAshpitLava.Sub then
			skin = "gfx/grid/balls/rockball_ashpit_lava.png"
		elseif ballType == mod.FF.RockBallGold.Sub then
			skin = "gfx/grid/balls/rockball_gold.png"
		elseif ballType == mod.FF.RockBallTumbleweed.Sub then
			skin = "gfx/grid/balls/rockball_tumbleweed.png"
		elseif ballType == mod.FF.RockBallFootball.Sub then
			skin = "gfx/grid/balls/rockball_football.png"
		end

		if skin then
			local sprite = npc:GetSprite()
			sprite:ReplaceSpritesheet(0, skin)
			sprite:LoadGraphics()
		end
	end,
	AI = function(npc)
		if CollapseSubType(npc) == mod.FF.RockBallTumbleweed.Sub then
			npc.Mass = 1
		elseif CollapseSubType(npc) == mod.FF.RockBallFootball.Sub then
			npc.Mass = 0.1
			npc.Friction = 0.97
			local d = npc:GetData()
			d.PuntOffset = d.PuntOffset or 0
			if d.PuntAccel then
				d.PuntOffset = d.PuntOffset + d.PuntAccel
				d.PuntAccel = d.PuntAccel + 0.5
				if d.PuntOffset >= 0 then
					sfx:Play(mod.Sounds.FootballPunt, 1, 0, false, math.min(0.5 + (d.PuntAccel/5), 2))
					d.PuntOffset = 0
					d.PuntAccel = d.PuntAccel * -0.5
					if d.PuntAccel > -1 then
						d.PuntAccel = nil
					end
				end
			end
			if d.pickedUp or npc.FrameCount < 50 then
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			elseif d.PuntOffset < -20 then
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			elseif d.PuntOffset < -10 then
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			else
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			end
			if not d.pickedUp then
				npc.SpriteOffset = Vector(0, -5) + Vector(0, d.PuntOffset)
			end
			if npc:CollidesWithGrid() then
				if sfx:IsPlaying(SoundEffect.SOUND_STONE_IMPACT) then
					sfx:Stop(SoundEffect.SOUND_STONE_IMPACT)
					sfx:Play(mod.Sounds.FootballPunt, 1, 0, false, 1)
				end
			end
		end
	end,
	Collision = function(npc, collider)
		if mod.IsCustomRockBall(npc) then
			--Football shit
			if CollapseSubType(npc) == mod.FF.RockBallFootball.Sub then
				if collider:ToPlayer() then
					if npc:GetData().PuntOffset > -10 then
						local kickMulti = 1.3
						npc.Velocity = collider.Velocity * 3
						local d = npc:GetData()
						if d.PuntAccel and d.PuntAccel < -5 then
							d.PuntAccel = math.min(-collider.Velocity:Length() * kickMulti, d.PuntAccel * -1)
						else
							d.PuntAccel = -collider.Velocity:Length() * kickMulti
						end
						--sfx:Play(mod.Sounds.FunnyFart, 1, 0, false, math.random(150,200)/100)
					end
					return false
				elseif collider.Type == mod.FF.Gritty.ID and collider.Variant == mod.FF.Gritty.Var then
					return false
				else
					if npc.Velocity:Length() > 1 then
						sfx:Play(mod.Sounds.FootballPunt, 1, 0, false, 1)
						collider:TakeDamage(math.log(npc.Velocity:Length()), 0, EntityRef(npc), 0)
					end
					if npc:GetData().PuntOffset > -10 then
						npc.Velocity = (npc.Position - collider.Position):Resized(10)
						npc:GetData().PuntAccel = -5
					end
				end
			--End of football shit
			elseif collider:ToPlayer() then
				if npc.V2:Length() == 0 or CollapseSubType(npc) == mod.FF.RockBallTumbleweed.Sub then
					return false
				end
			end
		end
	end,
	Death = function(npc)
		if mod.IsCustomRockBall(npc) then
			local data = npc:GetData()
			if IsLavaRock(npc) then
				mod:MakeFireWaveCross(npc.Position, false, npc)

				--[[local data = npc:GetData()
				local projectile = Isaac.Spawn(9, 0, 0, npc.Position, Vector.Zero, npc):ToProjectile()

				if data.rng:RandomFloat() < 0.5 then
					projectile:AddProjectileFlags(ProjectileFlags.FIRE_WAVE_X)
				else
					projectile:AddProjectileFlags(ProjectileFlags.FIRE_WAVE)
				end
				projectile.Visible = false
				projectile:Die()]]
			elseif CollapseSubType(npc) == mod.FF.RockBallGold.Sub then
				for i = 1, 3 + data.rng:RandomInt(3) do
					Isaac.Spawn(5, 20, 0, npc.Position, RandomVector():Resized(data.rng:RandomFloat() * 3), npc)
				end
			end
			local ballType = CollapseSubType(npc)
			local anm2 
			if ballType == mod.FF.RockBallMines.Sub then
				anm2 = "gfx/grid/balls/rockball_mine.anm2"
			elseif ballType == mod.FF.RockBallMinesLava.Sub then
				anm2 = "gfx/grid/balls/rockball_mine_lava.anm2"
			elseif ballType == mod.FF.RockBallAshpit.Sub then
				anm2 = "gfx/grid/balls/rockball_ashpit.anm2"
			elseif ballType == mod.FF.RockBallAshpitLava.Sub then
				anm2 = "gfx/grid/balls/rockball_ashpit_lava.anm2"
			elseif ballType == mod.FF.RockBallGold.Sub then
				anm2 = "gfx/grid/balls/rockball_gold.anm2"
			elseif ballType == mod.FF.RockBallTumbleweed.Sub then
				anm2 = "gfx/grid/balls/rockball_tumbleweed.anm2"
			elseif ballType == mod.FF.RockBallFootball.Sub then
				anm2 = "gfx/grid/balls/rockball_football.anm2"
			end
			if anm2 then
				for i = 1, 4 do
					local shard = Isaac.Spawn(1000, 163, 0, npc.Position, RandomVector():Resized(data.rng:RandomFloat()*4), npc)
					shard:GetSprite():Load(anm2, true)
					shard:GetSprite():SetFrame("Gibs", FiendFolio:RandomInt(0,3,data.rng))
					shard:Update()
				end
			end
			sfx:Stop(SoundEffect.SOUND_DEATH_BURST_SMALL)
			sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
		end
	end,
}
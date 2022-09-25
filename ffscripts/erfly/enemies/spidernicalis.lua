local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:koalaAI(npc)
	local target = npc:GetPlayerTarget()
	local targetpos = target.Position
	local sprite = npc:GetSprite()
	local path = npc.Pathfinder

	if game:GetRoom():CheckLine(npc.Position,targetpos,0,1,false,false) then
		local targetvel = (targetpos - npc.Position):Resized(4)
		npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
	else
		path:FindGridPath(targetpos, 0.6, 900, true)
	end

	if npc.Velocity:Length() > 0.1 then
		npc:AnimWalkFrame("WalkHori","WalkVert",0)
	else
		sprite:SetFrame("WalkVert", 0)
	end

	if npc:IsDead() then
		local DENIED = Isaac.Spawn(1000, 1725, 0, npc.Position, nilvector, v):ToEffect()
		--[[if not mod.nextOverwatch then
			mod.nextOverwatch = 1
		else
			mod.nextOverwatch = mod.nextOverwatch + 1
		end
		npc:PlaySound(mod.Sounds["OverwatchOverwatch" .. ((mod.nextOverwatch % 9) + 1)],3,0,false,1)]]
		npc:PlaySound(mod.Sounds.OverwatchOverwatch,3,0,false,1)
		game:ShakeScreen(50)
	end
end

function mod:Denial(e)
	local sprite = e:GetSprite()
	if sprite:IsFinished("Appear") then
		e:Remove()
	end

	e.SpriteOffset = Vector(0, -15)
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.Denial, 1725)
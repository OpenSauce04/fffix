local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:poopleAI(npc)
    local sprite  = npc:GetSprite()
    local target = npc:GetPlayerTarget()
	npc.SplatColor = mod.ColorBrowniePoop
	if npc.FrameCount % (#mod.creepSpawnerCount * 4 - 1) == 1 then
		local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_SLIPPERY_BROWN, 0, npc.Position, Vector(0,0), npc):ToEffect();
		creep:Update()
	end
	npc.StateFrame = npc.StateFrame + 1

	mod:CatheryPathFinding(npc, Isaac.GetFreeNearPosition(mod:Lerp(game:GetRoom():GetCenterPos(), mod:confusePos(npc, target.Position), -1), 900), {
        Speed = 8,
        Accel = 0.05
    })

    local spsq = npc.Velocity:LengthSquared()
	if spsq > 1 then
        npc:AnimWalkFrame("WalkHori","WalkVert",0)
		if math.abs(npc.Velocity.X) * 2 > math.abs(npc.Velocity.Y) then
			sprite:PlayOverlay("HeadHori",true)
		else
			if npc.Velocity.Y < 0 then
				sprite:PlayOverlay("HeadUp",true)
			else
				sprite:PlayOverlay("HeadDown",true)
			end
		end
    else
		sprite:SetFrame("WalkVert", 0)
		sprite:PlayOverlay("HeadDown",true)
	end

	if spsq > 3 ^ 2 and npc.StateFrame > 10 and npc:CollidesWithGrid() and not mod:isScareOrConfuse(npc) then
		--	npc.Velocity = mod.bounceOffWall(npc.Position, npc.Velocity)
		mod:softservesplatter(npc, 1)
		npc.StateFrame = 0
	end
	mod:rancid(npc, 180, 240, 8, mod.pooplerancidtable)
end
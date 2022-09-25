local mod = FiendFolio
local game = Game()

local unshornzDir = {
	[1] = "Left",
	[2] = "Up",
	[3] = "Right",
	[4] = "Down",
}
local dirUnshornz = {
	["Left"] = 1,
	["Up"] = 2,
	["Right"] = 3,
	["Down"] = 4,
}

function mod:unshornzAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local room = game:GetRoom()
	local rng = npc:GetDropRNG()
	
	if not data.init then
		if not data.setStats then
			if npc.SubType % 8 == 0 then
				data.startDir = unshornzDir[rng:RandomInt(4)+1]
			else
				data.startDir = unshornzDir[npc.SubType%8] --Left, up, right, down
			end
			if npc.SubType & 8 ~= 0 then
				data.rotateDir = true
			else
				data.rotateDir = false
			end
		end
		if npc.SubType & 16 ~= 0 then
			data.trueLeader = true
		end
		
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
		local randomSprite = rng:RandomInt(3)+1
		mod:ReplaceEnemySpritesheet(npc, "gfx/enemies/unshornz/monster_unshornz0" .. randomSprite, 0)
		data.init = true
	end
	--npc.Color = Color(1,1,1,1,1-npc.I1*0.5,0,0)
	mod:spritePlay(sprite, "Idle")
	if npc.FrameCount > 1 then
		if data.breakAway then
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
			npc.Velocity = mod:Lerp(npc.Velocity, Vector(-6, 0):Rotated(-90+dirUnshornz[data.breakAway]*90), 0.3)
			if npc:CollidesWithGrid() then
				data.breakAway = nil
				mod:WallHuggerInit(npc, data.WallHuggerData.Dir, data.WallHuggerData.CC, GridCollisionClass.COLLISION_PIT, 5)
				--mod:WallHuggerMovement(npc, 8)
				--mod:WallHuggerMovement(npc, 8)
				--mod:WallHuggerMovement(npc, 8)
				--mod:WallHuggerMovement(npc, 8)
			end
		elseif npc.I1 == 0 or data.trueLeader then -- Thank you Xalum for the Ossularry code
			if not npc.Child and not data.leadingMember then
				data.leadingMember = true
				mod:WallHuggerInit(npc, data.startDir, data.rotateDir, GridCollisionClass.COLLISION_PIT, 5)
				local curr = npc
				local dontEval = {}
				table.insert(dontEval, npc.InitSeed)
				while curr do
					local did
					local closest
					local dist = 60

					for _, ent in pairs (Isaac.FindByType(npc.Type, npc.Variant, -1)) do
						local distance = ent.Position:Distance(curr.Position)
						if distance < dist and not ent:GetData().trueLeader and not mod:Contains(dontEval, ent.InitSeed) then
							closest = ent
							dist = distance
						end
					end

					if closest then
						did = true
						mod:WallHuggerInit(closest, data.startDir, data.rotateDir, GridCollisionClass.COLLISION_PIT, 5)
						local cData = closest:GetData()
						curr.Child = closest
						cData.startDir = data.startDir
						cData.rotateDir = curr:GetData().rotateDir
						cData.setStats = true
						closest.Parent = curr
						table.insert(dontEval, closest.InitSeed)
						closest:ToNPC().I1 = curr:ToNPC().I1+1
						--print(room:GetGridIndex(closest.Position))
						curr = closest
					end

					if not did then
						curr = nil 
					end
				end
			end
			mod:WallHuggerMovement(npc, 8)
		else
			if npc.Parent and npc.Parent:Exists() then
				local pData = npc.Parent:GetData()
				if npc.Parent:IsDead() or FiendFolio:isStatusCorpse(npc.Parent) then
					data.leadingMember = true
					npc.I1 = 0
					data.breakPoint = npc.Position
					data.WallHuggerData.Dir = mod:RotateDirection(data.WallHuggerData.Dir, data.WallHuggerData.CC)
					data.breakAway = data.WallHuggerData.Dir
				end
				
				if pData.breakPoint ~= nil then
					if npc.Position:Distance(pData.breakPoint) < 5 then
						npc.Position = pData.breakPoint
						data.WallHuggerData.Dir = mod:RotateDirection(data.WallHuggerData.Dir, data.WallHuggerData.CC)
						if npc.Child then
							data.breakPoint = npc.Position
						end
						pData.breakPoint = nil
						data.breakAway = data.WallHuggerData.Dir
					end
				end
				
				if npc.Position:Distance(npc.Parent.Position) > 150 then
					data.leadingMember = true
					npc.I1 = 0
				end
				
				local speed = 8
				--[[if npc.Position:Distance(npc.Parent.Position) > 45 then --Just causes issues in practice
					speed = 6
				elseif npc.Position:Distance(npc.Parent.Position) < 35 then
					speed = 10
				end]]
				mod:WallHuggerMovement(npc, speed)
			else
				data.leadingMember = true
				npc.I1 = 0
			end
		end
	end
end

function mod:unshornzColl(npc, coll, bool)
	if npc.Variant == mod.FF.Unshornz.Var then
		if (coll.Type == mod.FFID.Ferrium and coll.Variant == mod.FF.Unshornz.Var) or coll.Type == 40 or coll.Type == 218 or coll.Type == 862 then
			return true
		end
	end
end
--mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, mod.unshornzColl, mod.FFID.Ferrium)
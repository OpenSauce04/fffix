local mod = FiendFolio
local sfx = SFXManager()

-- Atom Master

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, atom)
  if atom.Variant == 1000 then
    atom:GetSprite():Play("Idle", true)
    atom.EntityCollisionClass = 0
    local mm = MusicManager()
    local banger = Isaac.GetMusicIdByName("Requiem")
    mm:Play(banger, 0)
    mm:UpdateVolume()
  end
end, 124)

-- Pulse Effect (Small)

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
  if npc.SubType == 150 then
    npc.SplatColor = Color(0,0,0,0,0,0,0)
    npc:ClearEntityFlags(1<<2)
    npc.Visible = false
    npc.EntityCollisionClass = 0
    npc.Position = npc.Position + Vector(0,20)
    for i=0, 16 do
      npc:Update()
    end
    mod.scheduleForUpdate(function()
      npc:Remove()
      sfx:Stop(28)
      sfx:Stop(161)
    end, 0)
  end
end, 306)

mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, typ, var, subt, pos, vel, spawner, seed)
  if spawner and spawner.Type == 306 and spawner.SubType == 150 then
    return {1000, 122, 0, seed}
  end
end)

mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION , function(_, npc1, np2)
  if npc1.SubType == 150 then return true end
end, 306)

-- Pulse Effect (Big)

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
  if npc.SubType == 150 then
    npc.SplatColor = Color(0,0,0,0,0,0,0)
    npc:ClearEntityFlags(1<<2)
    npc.Visible = false
    npc.State = 7
    npc.EntityCollisionClass = 0
    npc.Position = npc.Position + Vector(0,-10)
    local sprite = npc:GetSprite()
    sprite:Play("JumpDown", true)
    for i=0, 31 do
      sprite:Update()
    end
    mod.scheduleForUpdate(function()
      npc:Remove()
      sfx:Stop(48)
    end, 0)
  end
end, 20)

mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, typ, var, subt, pos, vel, spawner, seed)
  if spawner and spawner.Type == 20 and spawner.SubType == 150 then
    return {1000, 122, 0, seed}
  end
end)

mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION , function(_, npc1, np2)
  if npc1.SubType == 150 then return true end
end, 20)

-- Smart Pit

--bool isPathableGrid(GridEntity grid)
local function isPathableGrid(grid)
  if not grid then return true end
  
  local gType = grid:GetType()
  if gType == 9 or (gType == 14 and grid.Desc.Variant == 1) or gType == 17 then return false end    --moving spikes/red poop/trapdoor
  
  return Game():GetRoom():GetGridPathFromPos(grid.Position) <= 900
  
  --local gType = grid:GetType()
  --local typeFlags = 1<<0 | 1<<1 | 1<<10 | 1<<20 -- | 1<<23
  --  --1<<0 null  --1<<1 decoration  --1<<10 spiderweb  --1<<20 pressureplate  --1<<23 teleporter
  --return (typeFlags & (1<<gType)) ~= 0
end

local function thatSuperSpecificCasePoopsAndBarrelsHasOnAllOfThisAlgorithmMadness(pos, g_adj)
  local room = Game():GetRoom()
  local adjBool
  for i=1, 4 do
    if g_adj[i][1] and (g_adj[i][1]:GetType() == 12 or g_adj[i][1]:GetType() == 14) and room:GetGridPathFromPos(g_adj[i][2]) > 900 then
      adjBool = true
      break
    end
  end
  if not adjBool then return false end
  
  --que lidie con ello el sbody del mañana
  return true  
end

--void recursiveGridPath(table gMap[][], GridEntity grid, Vector gridPos, int offsetInitX, int offsetInitY)
local function recursiveGridPath(gMap, pos, offsetInitX, offsetInitY)
  
  local room = Game():GetRoom()
  local posNorm = room:GetGridPosition(room:GetGridIndex(pos))
  local offsetX = math.floor(posNorm.X / 40)
  local offsetY = math.floor(posNorm.Y / 40 - 2)
  if gMap[offsetX][offsetY] then return end    
  
  local grid = room:GetGridEntityFromPos(pos)
  if not isPathableGrid(grid) then
    return
  else
    gMap[offsetX][offsetY] = true
    if gMap[offsetInitX][offsetInitY-1] and gMap[offsetInitX+1][offsetInitY] and gMap[offsetInitX][offsetInitY+1] and gMap[offsetInitX-1][offsetInitY] then return end
    
    recursiveGridPath(gMap, pos + Vector(0,-40), offsetInitX, offsetInitY)
    recursiveGridPath(gMap, pos + Vector(40,0), offsetInitX, offsetInitY)
    recursiveGridPath(gMap, pos + Vector(0,40), offsetInitX, offsetInitY)
    recursiveGridPath(gMap, pos + Vector(-40,0), offsetInitX, offsetInitY)
  end
end

--bool canGeneratePit(vector pos, int breakGrid, table gMap[][], bool checkPoopsOrBarrels, bool checkPlayer)
function mod.canGeneratePit(pos, breakGrid, gMap, checkPoopsOrBarrels, checkPlayer)
  local room = Game():GetRoom()
  
  if pos:Distance(room:GetClampedPosition(pos, 0)) ~= 0 then return false end
  local posNorm = room:GetGridPosition(room:GetGridIndex(pos))
  for i=0, 7 do
    if room:IsDoorSlotAllowed(i) and room:GetDoorSlotPosition(i):Distance(posNorm, 0) == 40 then return false end
  end
  
  if checkPlayer then
    local players = Isaac.FindByType(1, -1, -1, false, false)
    for _, p in ipairs(players) do
      p = p:ToPlayer()
      if (not p.CanFly) and p.Position.X >= posNorm.X-20 and p.Position.X <= posNorm.X+20 and p.Position.Y >= posNorm.Y-20 and p.Position.Y <= posNorm.Y+20 then
        return false
      end
    end
  end
  
  local grid = room:GetGridEntityFromPos(pos)
  --if not grid then return false end
  
  local gridPath = room:GetGridPathFromPos(pos)
  if grid then
    --print(grid.Desc.Variant)
    local gType = grid:GetType()
    --print(gType)
    local typesDeny = 1<<7 | 1<<8 | 1<<15 | 1<<16 | 1<<17 | 1<<18 | 1<<20 | 1<<23  --pit/wall/door/trapdoor/stairs/plate/teleporter
    if (typesDeny & (1<<gType)) ~= 0 then
      if not(gType == 7 and gridPath == 0) then return false end
    end
    if gridPath == 999 then return false end      --moving spikes (up)
    if gType == 21 and grid.Desc.Variant == 0 then return false end   --satan statue
    --if gridPath == 1000 then
    if gridPath > 900 then                                            --[breakGrid] 0:Ground; 1:Grids; 2:Strong grids
      local typesStrong = 1<<3 | 1<<11 | 1<<24    --block/lock/pillar
      if (typesStrong & (1<<gType)) ~= 0 and breakGrid < 2 then return false end
      local typesWeak = 1<<2 | 1<<4 | 1<<5 | 1<<6 | 1<<12 | 1<<14 | 1<<21 | 1<<22 | 1<<25 | 1<<26 | 1<<27   --a lot
      if (typesWeak & (1<<gType)) ~= 0 and breakGrid < 1 then return false end
    end
  elseif gridPath == 950 then
    return false
  end
  
  local g_adj = {}
    g_adj[1] = {room:GetGridEntityFromPos(pos + Vector(0,-40)), pos + Vector(0,-40)}
      if g_adj[1][1] and g_adj[1][1]:GetType() == 16 then return false end   -- type == door
    g_adj[2] = {room:GetGridEntityFromPos(pos + Vector(40,0)), pos + Vector(40,0)}
      if g_adj[2][1] and g_adj[2][1]:GetType() == 16 then return false end
    g_adj[3] = {room:GetGridEntityFromPos(pos + Vector(0,40)), pos + Vector(0,40)}
      if g_adj[3][1] and g_adj[3][1]:GetType() == 16 then return false end
    g_adj[4] = {room:GetGridEntityFromPos(pos + Vector(-40,0)), pos + Vector(-40,0)}
      if g_adj[4][1] and g_adj[4][1]:GetType() == 16 then return false end
  
  local cGrids = 0
  if not gMap then
    gMap = {}
    for i=0, room:GetGridWidth() do
      gMap[i] = {}
    end
  end
  
  local offsetX = math.floor(posNorm.X / 40)
  local offsetY = math.floor(posNorm.Y / 40 - 2)
  
  if checkPoopsOrBarrels and thatSuperSpecificCasePoopsAndBarrelsHasOnAllOfThisAlgorithmMadness(pos, g_adj) then return false end
  
  if not isPathableGrid(g_adj[1][1]) then cGrids=cGrids+1 gMap[offsetX][offsetY-1] = true end
  if not isPathableGrid(g_adj[2][1]) then cGrids=cGrids+1 gMap[offsetX+1][offsetY] = true end
  if not isPathableGrid(g_adj[3][1]) then cGrids=cGrids+1 gMap[offsetX][offsetY+1] = true end
  if not isPathableGrid(g_adj[4][1]) then cGrids=cGrids+1 gMap[offsetX-1][offsetY] = true end
  if cGrids >= 3 then
    --mod:UpdatePits()
    return true
  end
  
  local sPos -- start pos
  for i=1, 4 do
    if isPathableGrid(g_adj[i][1]) then sPos = g_adj[i][2] break end
  end
  
  gMap[offsetX][offsetY] = true
    
  recursiveGridPath(gMap, sPos, offsetX, offsetY)
  
  return (gMap[offsetX][offsetY-1] and gMap[offsetX+1][offsetY] and gMap[offsetX][offsetY+1] and gMap[offsetX-1][offsetY]) == true
end

--local gMapBuffer = {}

-- Smart Pit (old)

--function mod.smartPitOld(pos)
--  local npc = Isaac.Spawn(62, 3, 0, pos, Vector(0,0), nil):ToNPC()
--  npc:GetData().dummyWorm = true
--  npc.SplatColor = Color(0,0,0,0,0,0,0)
--  npc:ClearEntityFlags(1<<2)
--  npc:AddEntityFlags(1<<31)
--  npc.Visible = false
--  npc.State = 9  
--  npc.EntityCollisionClass = 0
--  npc.CollisionDamage = 0
--  --npc:AddHealth(100)
--  local sprite = npc:GetSprite()
--  sprite:Play("Attack2", true)
--  for i=0, 7 do
--    sprite:Update()
--  end
--  npc.EntityCollisionClass = 0
--  npc.CollisionDamage = 0
--  pos = npc.Position    --new pos
--  --mod.scheduleForUpdate(function()      
--  --  Game():ShakeScreen(0)
--  --  npc.EntityCollisionClass = 0
--  --  local effs = Isaac.FindByType(1000, -1, -1, false, false)
--  --  for _, e in ipairs(effs) do
--  --    --if e.FrameCount < 2 then print(e.FrameCount) end
--  --    --if e.Variant == 132 and e.FrameCount == 0 and pos:Distance(e.Position) == 0 then e:Remove() end
--  --    if e.Variant == 4 and e.FrameCount == 0 and pos:Distance(e.Position) <= 6 then e:Remove() break end
--  --  end
--  --  npc:Remove()
--  --  sfx:Stop(474)
--  --  sfx:Stop(137)
--  --  
--  --  --for i=0, 817 do
--  --  --  if sfx:IsPlaying(i) then print(i) end
--  --  --end
--  --end, 0)  
--end

--mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
--  if npc:GetData().dummyWorm and npc.FrameCount == 1 then
--    local pos = npc.Position
--    Game():ShakeScreen(0)
--    local effs = Isaac.FindByType(1000, -1, -1, false, false)
--    for _, e in ipairs(effs) do
--      --if e.FrameCount < 2 then print(e.FrameCount) end
--      --if e.Variant == 132 and e.FrameCount == 0 and pos:Distance(e.Position) == 0 then e:Remove() end
--      if e.Variant == 4 and e.FrameCount == 0 and pos:Distance(e.Position) <= 6 then e:Remove() break end
--    end
--    npc:Remove()
--    sfx:Stop(474)
--    sfx:Stop(137)
--    
--    --for i=0, 817 do
--    --  if sfx:IsPlaying(i) then print(i) end
--    --end
--  end
--end, 62)

--mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, typ, var, subt, pos, vel, spawner, seed)
--  --if spawner and spawner.Type == 20 and spawner.SubType == 150 then
--  if typ == 1000 and var == 132 then
--    local dWorms = Isaac.FindByType(62, 3, -1, false, false)
--    for _, w in ipairs(dWorms) do
--      --if e.FrameCount < 2 then print(e.FrameCount) end
--      if w:GetData().dummyWorm and pos:Distance(w.Position) == 0 then return {1000, 122, 0, seed} end
--      break
--    end
--  end
--end)

--mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flags, source, cooldown)
--  if source.Type == 62 and source.Entity and source.Entity:GetData().dummyWorm then return false end
--end)

-- smart pit demo

--mod:AddCallback(ModCallbacks.MC_POST_UPDATE , function()
--  --if Input.IsButtonTriggered(Keyboard.KEY_ENTER, 0) then
--  if Input.IsMouseBtnPressed(0) and Game():GetFrameCount()%3 == 0 then
--  --if Input.IsButtonTriggered(32, 0) then
--    local mousePos = Input.GetMousePosition(true) -- get mouse position in world coordinates
--    local screenPos = Isaac.WorldToScreen(mousePos) -- transfer game- to screen coordinates
--    --print(mod.canGeneratePit(mousePos, 2, nil))
--    if mod.canGeneratePit(mousePos, 0, nil, true, true) then
--      sfx:Play(SoundEffect.SOUND_THUMBSUP, 1, 0, false, 1)
--      Game():GetRoom():SpawnGridEntity(Game():GetRoom():GetGridIndex(mousePos), 7, 0, 0, 0)
--      mod:UpdatePits(Game():GetRoom():GetGridIndex(mousePos))
--    else
--      sfx:Play(SoundEffect.SOUND_THUMBS_DOWN, 1, 0, false, 1)
--    end
--    --mod.smartPit(mousePos)
--  end
--  if Input.IsMouseBtnPressed(1) then
--    local mousePos = Input.GetMousePosition(true) -- get mouse position in world coordinates
--    local screenPos = Isaac.WorldToScreen(mousePos) -- transfer game- to screen coordinates
--    mod.smartPitOld(mousePos)
--    --Isaac.Spawn(1000, 1, 0, mousePos, Vector(0,0), nil)
--  end
--end)
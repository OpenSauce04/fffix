FiendFolio.LoadScripts({
    --items
    "ffscripts.julia.items.blackLantern",
    "ffscripts.julia.items.birthdayGift",

    --enemies
        --pre-reheated
        "ffscripts.julia.enemies.temper",
        "ffscripts.julia.enemies.spinny",
        "ffscripts.julia.enemies.congression",
        "ffscripts.julia.enemies.blot",
        "ffscripts.julia.enemies.melty",
        "ffscripts.julia.enemies.pitcher",
        "ffscripts.julia.enemies.mutanthorf",
        "ffscripts.julia.enemies.lightningfly",

        --post-reheated
        "ffscripts.julia.enemies.gobhopper",
        "ffscripts.julia.enemies.skipper",
        "ffscripts.julia.enemies.pyroclasm",
        "ffscripts.julia.enemies.prick",
        "ffscripts.julia.enemies.blastcore",
        "ffscripts.julia.enemies.cushion",

    --bosses
    "ffscripts.julia.bosses.buck",
    "ffscripts.julia.bosses.vanillachampions"
})

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:check970(npc)
	local sprite = npc:GetSprite();
	local npcdata = npc:GetData();
	local variant = npc.Variant;
	local subtype = npc.SubType
	if variant == mod.FF.Temper.Var then
		mod:temperAI(npc, sprite, npcdata)
	elseif variant == mod.FF.Spinny.Var or variant == mod.FF.Dizzy.Var then
		mod:spinnyAI(npc,sprite,npcdata)
	elseif variant == mod.FF.LightningFly.Var then
		mod:lightningFlyAI(npc, sprite, npcdata)
	elseif variant == mod.FF.Blot.Var then
		mod:blotAI(npc, sprite, npcdata);
	elseif variant == mod.FF.Melty.Var then
		mod:meltyAI(npc, sprite, npcdata);
	elseif variant == mod.FF.Pitcher.Var then
		mod:pitcherAI(npc, sprite, npcdata);
	elseif variant == mod.FF.MutantHorf.Var then
		mod:mutantHorfAI(npc, sprite, npcdata)
	elseif variant == mod.FF.Phoenix.Var then
		if subtype == mod.FF.PhoenixCorpse.Sub then
			mod:phoenixCorpseAI(npc)
		else
			mod:bumblerAI(npc)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.check970, FiendFolio.FFID.Julia)

function mod:check970Init(npc)
	local sprite = npc:GetSprite();
	local npcdata = npc:GetData();
	local variant = npc.Variant;
	if variant == mod.FF.Blot.Var then
		mod:blotInit(npc, sprite, npcdata);
	elseif variant == mod.FF.Melty.Var then
		mod:meltyInit(npc, sprite, npcdata);
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.check970Init, FiendFolio.FFID.Julia)

function mod:check970Hurt(npc, damage, flag, source)
	local variant = npc.Variant;

	if variant == mod.FF.Temper.Var then
		return mod:temperHurt(npc, damage, flag, source);
	elseif variant == mod.FF.LightningFly.Var then
		return mod:lightningFlyHurt(npc, damage, flag, source);
	elseif variant == mod.FF.Melty.Var then
		return mod:meltyHurt(npc, damage, flag, source);
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.check970Hurt, FiendFolio.FFID.Julia)

function mod:check970Kill(npc)
	local variant = npc.Variant;

	if variant == mod.FF.Phoenix.Var and npc.SubType == 0 then
		return mod:phoenixKill(npc)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mod.check970Kill, FiendFolio.FFID.Julia)

function mod:check970Coll(npc, npc2, mysteryBoolean)
	local variant = npc.Variant;
	if variant == mod.FF.Spinny.Var then
		npc.Velocity = (npc.Velocity * 0.3) + (npc2.Velocity * 0.7) * 0.7
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION , mod.check970Coll, FiendFolio.FFID.Julia)

function mod:check970Death(npc)
	local variant = npc.Variant
	if variant == mod.FF.LightningFly.Var then
		sfx:Stop(mod.Sounds.LightningFlyBuzzLoop)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.check970Death, FiendFolio.FFID.Julia)

--Run Temper AI
function mod:checkTemper(npc)
	local sprite = npc:GetSprite();
	local npcdata = npc:GetData();
	mod:temperAI(npc, sprite, npcdata)
end
--mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.checkTemper, 707)

--Run Spinny AI
function mod:checkSpinny(npc)
	local sprite = npc:GetSprite();
	local npcdata = npc:GetData();
	mod:spinnyAI(npc,sprite,npcdata)
end
--mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.checkSpinny, 708)

--Run Congression AI
function mod:checkCongression(npc)
	if npc.Variant > 1 then return end
	local sprite = npc:GetSprite();
	local npcdata = npc:GetData();
	local subType = npc.SubType
	mod:congressionAI(npc,sprite,npcdata,subType)
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.checkCongression, mod.FF.Congression.ID)

function mod:CongressionInit(npc)
	if npc.Variant < 2 then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.CongressionInit, mod.FF.Congression.ID)
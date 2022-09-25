local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:focusCrystalUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.FOCUS_CRYSTAL) then
		if not data.focusCrystalRing or not data.focusCrystalRing:Exists() then
			local aura = Isaac.Spawn(mod.FF.FocusCrystalRing.ID, mod.FF.FocusCrystalRing.Var, mod.FF.FocusCrystalRing.Sub, player.Position, Vector.Zero, player):ToEffect()
			aura.Parent = player
			aura:FollowParent(player)
			aura.DepthOffset = 500
			data.focusCrystalRing = aura
		end
	end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, damage, flags, source, countdown)
	if ent:ToNPC() then
		local npc = ent:ToNPC()
		if npc.Type == 33 then return end
		if flags ~= flags | DamageFlag.DAMAGE_CLONES then
			for i = 1, game:GetNumPlayers() do
				local player = Isaac.GetPlayer(i - 1)
				if player:HasTrinket(FiendFolio.ITEM.ROCK.FOCUS_CRYSTAL) then
					local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.FOCUS_CRYSTAL)
					if ent.Position:Distance(player.Position) < 100 then
						sfx:Play(mod.Sounds.FocusCrystal, 0.4, 0, false, 1)
						local poof = Isaac.Spawn(mod.FF.FocusCrystalPoof.ID, mod.FF.FocusCrystalPoof.Var, mod.FF.FocusCrystalPoof.Sub, ent.Position+Vector(math.random(-5,5),math.random(-5,5)), Vector.Zero, ent):ToEffect()
						if flags ~= flags | DamageFlag.DAMAGE_FIRE then --Some damage callback somewhere that's messing with this
							npc:TakeDamage(damage*(1+0.2*mult), flags | DamageFlag.DAMAGE_CLONES, source, 0)
							if source.Type == 2 and source.Entity:ToTear() then
								poof.SpriteOffset = Vector(0,source.Entity:ToTear().Height)
							else
								poof.SpriteOffset = Vector(0,-5)
							end
							poof:GetSprite().Rotation = math.random(360)
							return false
						end
					end
				end
			end
		end
	end
end)

function mod:focusCrystalRingEffect(e)
	local sprite = e:GetSprite()
	if e.Parent and e.Parent:Exists() then
		if e.Parent:ToPlayer() then
			if not e.Parent:ToPlayer():HasTrinket(FiendFolio.ITEM.ROCK.FOCUS_CRYSTAL) then
				e:Remove()
			end
		end
		sprite.Rotation = e.FrameCount
	else
		e:Remove()
	end
end

--[[function mod:focusCrystalPoofEffect(e)
	if e:GetSprite():IsFinished("bang") then
		e:Remove()
	end
end]]
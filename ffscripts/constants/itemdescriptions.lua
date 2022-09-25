local mod = FiendFolio

--Unfinished right now, in the process of it
--This is so freaking tedious but will be worth it when done i think
FiendFolio.ExternalDescriptions = {
	COLLECTIBLE = {
		{
			ID = FiendFolio.ITEM.COLLECTIBLE.PYROMANCY,
			EID = {
				Desc = "Orbital fireballs periodically spawn around the player, up to three#Double-tap the shoot button to shoot out a fireball, leaving a trail of flames and exploding on contact"
			},
            Encyclopedia = Encyclopedia and {
                Pools = {
                    Encyclopedia.ItemPools.POOL_DEVIL,
                    Encyclopedia.ItemPools.POOL_GREED_DEVIL,
                },
            }
		},
		{
			ID = FiendFolio.ITEM.COLLECTIBLE.FIEND_FOLIO,
			EID = {
				Desc = "Summons a Fiend Folio helper to assist you in the room!",
				Transformations = "12"
			},
            Encyclopedia = Encyclopedia and {
                Pools = {
                    Encyclopedia.ItemPools.POOL_TREASURE,
                    Encyclopedia.ItemPools.POOL_GREED_TREASURE,
                    Encyclopedia.ItemPools.POOL_LIBRARY,
                }
            }
		},
		{
			ID = FiendFolio.ITEM.COLLECTIBLE.D2,
			EID = {
				Desc = "Can be thrown and will spin on the floor temporarily#Any pickups, enemies and tears touching it will be rerolled"
			},
		},
		{ID = FiendFolio.ITEM.COLLECTIBLE.D2,
			EID = {
				Desc = "Can be thrown and will spin on the floor temporarily#Any pickups, enemies and tears touching it will be rerolled"
			},
		},
		{ID = FiendFolio.ITEM.COLLECTIBLE.STORE_WHISTLE,
			EID = {
				Desc = "Spawns a shop chest nearby"
			},
		},
		{ID = FiendFolio.ITEM.COLLECTIBLE.DICE_BAG,
			EID = {
				Desc = "Drops a glass die every 8 rooms#Room counter is reduced to 3 rooms with BFFs#Glass dice mimic a die and break after use#Glass D4 and Glass D100 cannot reroll Dice Bag"
			},
		},
		{ID = FiendFolio.ITEM.COLLECTIBLE.LIL_FIEND,
			EID = {
				Desc = "Flies diagonally across the room and has a chance to drop a fiend minion when colliding with an enemy or enemy projectile#Minions disappear on room clear and will not drop a black heart#BFFs increases the hitbox and chance of dropping a minon"
			},
		},
		{ID = FiendFolio.ITEM.COLLECTIBLE.BABY_CRATER,
			EID = {
				Desc = "Whilst you are shooting, Baby Crater creates a circle of tears similar to the enemy Craterface#Tears are released when you stop firing#With BFFs your Baby Crater can support a larger ring#Baby Crater can drop from polyps in the womb"
			},
		},
		{ID = FiendFolio.ITEM.COLLECTIBLE.MAMA_SPOOTER,
			EID = {
				Desc = "Blue tinted spooter that pursues enemies#Periodically fires tears at targets#Becomes a tinted Super Spooter with BFFs"
			},
		},
		{ID = FiendFolio.ITEM.COLLECTIBLE.RANDY_THE_SNAIL,
			EID = {
				Desc = "Snail familiar that retracts into its shell when hit by a projectile#Randy can then be bounced around the room through repeated projectile collisions#Causes increased damage on contact with enemy and increases his hit box with BFFs"
			},
		},
		{ID = FiendFolio.ITEM.COLLECTIBLE.CORN_KERNEL,
			EID = {
				Desc = "LVL1: Wavy orbital#LVL2: Orbital that shoots weak explosions#LVL3: Familiar that teleports and chases enemies#LVL4: Familiar that teleports and shoots explosive corn"
			},
		},
		{ID = FiendFolio.ITEM.COLLECTIBLE.GRABBER,
			EID = {
				Desc = "Familiar based on Grabber from hit video game Grabber#Mirrors your movements and grabs things in front of him#BFFs increases hitbox and damage dealt by his hand"
			},
		},
		{ID = FiendFolio.ITEM.COLLECTIBLE.PEACH_CREEP,
			EID = {
				Desc = "Wall Creep familiar that tries to line up with enemies and shoots bursts of tears#Tears are bigger and have double damage with BFFs"
			},
		},
		{ID = FiendFolio.ITEM.COLLECTIBLE.GMO_CORN,
			EID = {
				Desc = "You are immobilized and forced to consume 7 random pills#\1 +1 max hearts#\1 +1 Damage up#Synergises with PHD, Virgo and Little Baggy#Little Baggy increases the number of pills taken to 10"
			},
		},
		{ID = FiendFolio.ITEM.COLLECTIBLE.COOL_SUNGLASSES,
			EID = {
				Desc = "+6 coins#Walking near coins grants a speed up#Colleting coins damages all enemies in the room#Upon entering an occupied room 3 cents are taken from you and strewn across the room"
			},
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.FIENDS_HORN,
			EID = {
				Desc = "Enemies have a chance to drop a fiend minion on death#Minions disappear on room clear#Chance starts at 5% and scales to 20% at 14 luck#A bonus chance is applied for any immoral hearts you have"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.RISKS_REWARD,
			EID = {
				Desc = "Can be used to reroll an item in the treasure room into one of a higher quality#This is achieved by traversing a unique psionic zone and fighting Hermit"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.SPARE_RIBS,
			EID = {
				Desc = "\1 +1 bone heart#Taking damage has a chance to fire out rib projectiles in a circle around you#Rib projectiles return to their sender and are destroyed only on contact with what fired them#Rib projectiles can destroy enemy projectiles"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.BACON_GREASE,
			EID = {
				Desc = "\1 +1 empty heart container#\1 +0.15 Shot Speed up#!!! -1 red heart"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.NUGGET_BOMBS,
			EID = {
				Desc = "Bombs spawn a Pooter familiar when they explode"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.DEVILS_UMBRELLA,
			EID = {
				Desc = "Sometimes fire a flurry of weak tears that spawn yellow creep#Frequency scales with Luck"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.BEE_SKIN,
			EID = {
				Desc = "Every tear fired triggers 3 weaker tears spread evenly around the player#Each time this effect triggers, the angle of all tears is incremented clockwise"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.ALPHA_COIN,
			EID = {
				Desc = "25% chance to spawn a coin#25% to spawn a card/pill#A variety of effects based on the current room and exploration"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.DADS_WALLET,
			EID = {
				Desc = "Shop items can be purchased even if unaffordable#Debt gives a multiplicative damage down#Drops a credit card on pickup"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.FROG_HEAD,
			EID = {
				Desc = "Forces you to stand still upon holding down the use active button#Letting go of the use active button makes isaac fart, the fart getting more powerful the longer you hold it down"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.BEGINNERS_LUCK,
			EID = {
				Desc = "\1 +5 luck up#\2 -0.5 luck per how many floors down you are#At minimum will grant +1 luck"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.DICHROMATIC_BUTTERFLY,
			EID = {
				Desc = "Hitbox size is reduced and indicated by a marker#Grants +0.2 damage, for the current room, for narrowly avoiding a projectile#Caps at +3 damage#Luck-affected chance to fire a tear with 1.25x damage and aggressive homing"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.BIRTHDAY_GIFT,
			EID = {
				Desc = "Replaces all found items with Mystery Gift#Rerolls and special/fixed drops are not affected"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.IMP_SODA,
			EID = {
				Desc = "Luck-affected chance to shoot crit tears that deal quintuple damage"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.SLIPPYS_GUTS,
			EID = {
				Desc = "Enemies have a chance to spawn a lingering poison cloud on death#Chance is proportionate to enemy's Max HP#Bombs spawn a lingering poison cloud on explosion"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.SLIPPYS_HEART,
			EID = {
				Desc = "Chance to fart while near enemies#Fart chance scales with luck#Farts vary in type"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.COMMUNITY_ACHIEVEMENT,
			EID = {
				Desc = "Grants a Damage up which scales with the current records in the Fiend Folio Community Discord counting channels"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.CHIRUMIRU,
			EID = {
				Desc = "\1 +1 soul heart#\1 +0.9 damage up#Upon entering a room, all enemies are frozen for 0.9 seconds"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.GOLEMS_ORB,
			EID = {
				Desc = "\1 +0.23 shot speed up#\1 +0.2 speed up#\1 +1 luck up#+2 Soul Hearts"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.GOLEMS_ROCK,
			EID = {
				Desc = "Spawns a golem trinket on pickup#On use, grinds your current trinket into a rock trinket#!Can grind regular trinkets into rock trinkets"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.LEFTOVER_TAKEOUT,
			EID = {
				Desc = "\1 All stats up#Chance to fire a fortune worm tear#Chance scales with luck"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.CLEAR_CASE,
			EID = {
				Desc = "The next active item you pick up will be assigned to your Pocket Active slot."
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.MODERN_OUROBOROS,
			EID = {
				Desc = "Tears leave oil creep upon impact#Walking over oil creep will ignite it"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.BLACK_LANTERN,
			EID = {
				Desc = "\1 +1 black heart#Guarantees a curse on every floor#Replaces curses with special new kinds of potentially beneficial curses"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.CRUCIFIX,
			EID = {
				Desc = "Enemies killed by tears will leave behind a short-lived ghost with an aura#Standing in the aura grants tears up, damage up and homing"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.BEDTIME_STORY,
			EID = {
				Desc = "Inflicts all enemies with drowsy#Drowsy enemies will slow down and eventually fall asleep#Damaging a sleeping enemy deals double damage but wakes them up"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.PINHEAD,
			EID = {
				Desc = "Luck-affected chance to shoot sewing needle tears that pierce and inflict enemies with sewn#Sewn enemies reflect damage taken onto all other enemies inflicted with sewn"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.PRANK_COOKIE,
			EID = {
				Desc = "Grants multi-coloured tears with different effects (hemorrhaging, bruising, drowsing, sewing, critting, etc.)"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.DEVILS_HARVEST,
			EID = {
				Desc = "When dead, respawn as Fiend"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.RUBBER_BULLETS,
			EID = {
				Desc = "Luck-affected chance to fire bullet tears that inflict enemies with bruising#Bruised enemies take bonus damage from all sources of damage based on the number of stacks applied"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.THE_DELUXE,
			EID = {
				Desc = "\1 +1 bone heart#\1 +1 morbid heart#\1 +1 gold heart#\1 +1 eternal heart"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.LIL_MINX,
			EID = {
				Desc = "Menace familiar that charges at enemies#Double-tap the shoot button to possess the nearest enemy and inflict them with berserk#Double-tap the shoot button to exit the enemy and fire a spectral tear barrage#Berserked enemies periodically switch targets (including enemies), take bonus damage, move faster and cannot die during the duration"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.PURPLE_PUTTY,
			EID = {
				Desc = "+1 immoral heart on use"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.FETAL_FIEND,
			EID = {
				Desc = "\1 Damage up#On pickup, replaces all soul and black hearts with immoral hearts#On pickup, replaces all red hearts with immoral hearts at a 2:1 ratio"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.FIEND_MIX,
			EID = {
				Desc = "On use, transforms half your health into Fiend minions"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.SECRET_STASH,
			EID = {
				Desc = "On pickup, spawn a coin, a key, a bomb and a card/pill/rune#At the start of your next run, spawn 10% of the coins, keys and bombs you held at the end of this run (rounded down, max of 5), and the cards/pills/runes you held"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.SANGUINE_HOOK,
			EID = {
				Desc = "Throwable hook that latches onto and pulls in enemies/pickups#Inflicts enemies with bruising while hooked#On releasing enemies, inflicts them with hemorrhaging and fires blood tears in the direction they were released"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.GORGON,
			EID = {
				Desc = "Stationary familiar that gazes at enemies in the room, freezing them in place until they are killed"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.FIDDLE_CUBE,
			EID = {
				Desc = "Grants an increasing amount of damage and tears when used rhythmically#Damage and tears gradually go away if the item is not being used"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.AVGM,
			EID = {
				Desc = "Pays out with coins after using an increasing amount of times"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.DEIMOS,
			EID = {
				Desc = "Familiar that fires hooks that latch onto and pull in enemies/pickups#Remains stationary while pulling in enemies/pickups#Inflicts enemies with bruising while hooked#On releasing enemies, inflicts them with hemorrhaging and fires blood tears in the direction they were released"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.PET_ROCK,
			EID = {
				Desc = "Pet rock familiar that can be pushed around and blocks shots#Fills pits when pushed into them"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.CONTRABAND,
			EID = {
				Desc = "Better hold onto this!#I heard a shady guy next floor is looking for it..."
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.ETERNAL_D12,
			EID = {
				Desc = "Switches between two modes#With two charges, has a high chance to reroll grids and a low chance to wipe away grids#With one charge, has a low chance to reroll grids and a high chance to wipe away grids"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.ETERNAL_D12_ALT,
			EID = {
				Desc = "Switches between two modes#With two charges, has a high chance to reroll grids and a low chance to wipe away grids#With one charge, has a low chance to reroll grids and a high chance to wipe away grids"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.GLIZZY,
			EID = {
				Desc = "\1 +1 half-filled heart container#\1 +0.1 speed up#\1 +0.1 tears up#\1 +0.1 damage up#\1 +0.1 range up#\1 +0.1 shot speed up#\1 +0.1 luck up"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.FIEND_HEART,
			EID = {
				Desc = "\1 +3 immoral hearts"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.DEVILLED_EGG,
			EID = {
				Desc = "\1 +2 immoral hearts#\1 +0.3 tears up"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.TEA,
			EID = {
				Desc = "\1 +1 max heart"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.OPHIUCHUS,
			EID = {
				Desc = "Wiggly snake familiar that chases after enemies, inflicting poison and dealing damage on contact#Prioritizes chasing after enemies that are not currently inflicted with poison"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.FRAUDULENT_FUNGUS,
			EID = {
				Desc = "\1 +1 rotten heart#\1 +0.2 speed up#\1 +0.3 damage up#\1 +0.38 range up"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.SMALL_PIPE,
			EID = {
				Desc = "\1 +0.2 damage up#\1 +0.2 tears up#\1 +0.2 shot speed up#\1 +0.2 speed up"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.SMALL_WOOD,
			EID = {
				Desc = "\1 +1 tears up#\1 +0.2 damage up#\2 -0.2 shot speed down"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.WHITE_PEPPER,
			EID = {
				Desc = "On use, shoots 5 flames in a ring around you"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.PEPPERMINT,
			EID = {
				Desc = "Chance to fire a fire that damages and frezes enemies"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.PAGE_OF_VIRTUES,
			EID = {
				Desc = "On pickup, grants a random wisp#Whenever this wisp is destroyed, grants you a new random wisp"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.BRIDGE_BOMBS,
			EID = {
				Desc = "Grants 5 bombs#Bombs fill pits when they explode"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.LAWN_DARTS,
			EID = {
				Desc = "Luck-affected chance to fire tears that inflict enemies with hemorrhaging#Hemorrhaging enemies periodically take damage, spew blood tears randomly around themselves and leave blood creep on the ground that damages enemies"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.TOY_PIANO,
			EID = {
				Desc = "Luck-affected chance to fire tears that inflict enemies with doom#Doomed enemies gain a counter that goes down every time they take damage#Upon reaching zero the enemy takes a large amount of damage, removing the doomed status"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.HYPNO_RING,
			EID = {
				Desc = "Luck-affected chance to fire tears that inflict enemies with drowsy#Drowsied enemies slowly fall asleep, moving and attacking increasingly slower over time#Sleeping enemies remain still until they awake#Sleeping enemies take double damage but awake instantly upon taking damage"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.MUSCA,
			EID = {
				Desc = "Grants 3 bombs#Bombs spawn three random locusts when they explode#Enemies have a luck-based chance to spawn a random locust on death"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.MODEL_ROCKET,
			EID = {
				Desc = "\1 2x shot speed multiplier#\1 +1.5 range up#Tears accelerate up from zero movement speed to normal movement speed on firing#Tears deal bonus damage based on their movement speed upon impact"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.SIBLING_SYL,
			EID = {
				Desc = "Normal tear familiar#Deals 4.75 damage per tear"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.WRONG_WARP,
			EID = {
				Desc = "On use, teleports you to a random floor"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.THE_BROWN_HORN,
			EID = {
				Desc = "On use, causes all enemies to defecate violently, pushing them away from you and spawning friendly dips"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.NYX,
			EID = {
				Desc = "Grants 3 homing gems that can be cast while attacking and stick to enemies, inflicting damage and bruising#Bruised enemies take bonus damage from all sources of damage based on the number of stacks applied#Has special synergies with certain items"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.SNOW_GLOBE,
			EID = {
				Desc = "On use, causes an earthquake that flings most grids to a random spot nearby."
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.ETERNAL_CLICKER,
			EID = {
				Desc = "On use, 50% chance to change to another character and lose an item."
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.DICE_GOBLIN,
			EID = {
				Desc = "Spawns 3 random objects on pickup#Spawns 1 object at the start of every floor"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.CHERRY_BOMB,
			EID = {
				Desc = "On use, the player picks up a small red bomb that deals no damage to the player and doesn't break rocks."
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.ASTROPULVIS,
			EID = {
				Desc = "Destroys the closest rock and turns it into a large ghost. Using the active again will detonate all large ghosts in the room."
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.SPINDLE,
			EID = {
				Desc = "Spawns 3 'disc' consumables.#Discs grant the effects of a few passive items for 1 minute.#Spawns a disc when entering a boss room."
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.AZURITE_SPINDOWN,
			EID = {
				Desc = "On use, rerolls all trinkets in the room by decreasing their internal ID number by one."
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.KING_WORM,
			EID = {
				Desc = "On use, grants the effect of a random worm trinket for the current room#5 second cooldown"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.HEART_OF_CHINA,
			EID = {
				Desc = "Overhealing charges a special health bar#Filling this health bar grants an empty heaty container#The number of hearts in the special bar scales with how many hearts you have#The special health bar can be viewed by standing near a heart that will overheal you or by viewing the map"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.HORSE_PASTE,
			EID = {
				Desc = "Heals 1 broken heart#Granted only by China's birthright"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.DADS_DIP,
			EID = {
				Desc = "\1 +1 max heart#\1 +1 morbid heart"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.YICK_HEART,
			EID = {
				Desc = "+1 morbid heart on use"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.LIL_LAMB,
			EID = {
				Desc = "{{Collectible149}} Familiar that charges to shoot an ipecac explosive#When the player is hit, has a chance to drop on the floor and target enemies automatically"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.GRAPPLING_HOOK,
			EID = {
				Desc = "Throwable hook that can be used to quickly travel#Can be used to climb onto rocks#The player can take damage by falling into pits"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.CETUS,
			EID = {
				Desc = "On taking damage, spew out a large amount of tears that leave creep"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.MALICE,
			EID = {
				Desc = "Use to turn into a malicious fireball and charge across the room#Enemies killed in this state have a chance to drop black hearts"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.BLACK_MOON,
			EID = {
				Desc = "On death, enemies spawn a cross that damages enemies in an area of effect#Enemies killed by the cross don't spawn another cross"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_1,
			EID = {
				Desc = "Copies the effects of Isaac's held pocket object (excluding cards, pills, runes and soulstones).#Drops one random object the first time it's picked up.#Variable recharge time based on which object is used."
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_2,
			EID = {
				Desc = "Copies the effects of Isaac's held pocket object (excluding cards, pills, runes and soulstones).#Drops one random object the first time it's picked up.#Variable recharge time based on which object is used."
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_3,
			EID = {
				Desc = "Copies the effects of Isaac's held pocket object (excluding cards, pills, runes and soulstones).#Drops one random object the first time it's picked up.#Variable recharge time based on which object is used."
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_4,
			EID = {
				Desc = "Copies the effects of Isaac's held pocket object (excluding cards, pills, runes and soulstones).#Drops one random object the first time it's picked up.#Variable recharge time based on which object is used."
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_5,
			EID = {
				Desc = "Copies the effects of Isaac's held pocket object (excluding cards, pills, runes and soulstones).#Drops one random object the first time it's picked up.#Variable recharge time based on which object is used."
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_6,
			EID = {
				Desc = "Copies the effects of Isaac's held pocket object (excluding cards, pills, runes and soulstones).#Drops one random object the first time it's picked up.#Variable recharge time based on which object is used."
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_8,
			EID = {
				Desc = "Copies the effects of Isaac's held pocket object (excluding cards, pills, runes and soulstones).#Drops one random object the first time it's picked up.#Variable recharge time based on which object is used."
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_12,
			EID = {
				Desc = "Copies the effects of Isaac's held pocket object (excluding cards, pills, runes and soulstones).#Drops one random object the first time it's picked up.#Variable recharge time based on which object is used."
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.PLANET_BADGE,
			EID = {
				Desc = "\1 +0.1 damage"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.HAUNTED_BADGE,
			EID = {
				Desc = "\1 +0.1 damage"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.BABY_BADGE,
			EID = {
				Desc = "\1 +0.1 damage"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.COMMISSIONED_BADGE,
			EID = {
				Desc = "\1 +0.1 damage"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.DRIPPING_BADGE,
			EID = {
				Desc = "\1 +0.1 damage"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.MYSTERY_BADGE,
			EID = {
				Desc = "\1 +0.1 damage"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.SPATULA_BADGE,
			EID = {
				Desc = "\1 +0.1 damage"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.YOUR_ETERNAL_REWARD,
			EID = {
				Desc = "\1 +0.1 damage"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.MARIAS_IPAD,
			EID = {
				Desc = "Moves all entities to the bottom of the room#Joke item"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.GREG_THE_EGG,
			EID = {
				Desc = "Familiar that has a chance to drop a pickup after clearing a room#After being shot by projectiles, has a chance to crack and spawn another familiar"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.FAMILIAR_FLY,
			EID = {
				Desc = "Orbiting familiar#Can charm flies#Will explode when close to enemies for long enough"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.MONAS_HIEROGLYPHICA,
			EID = {
				Desc = "Gives you a random planetarium item effect every floor"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.CYANIDE_DEADLY_DOSE,
			EID = {
				Desc = "Cyanide pills can appear, which provide a risky all stats up!"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.DADS_POSTICHE,
			EID = {
				Desc = "Random chance to spawn blue skuzzes when shooting tears#Morbid hearts have a slightly higher chance to appear"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.EXCELSIOR,
			EID = {
				Desc = "Active items when used will shoot fireworks, based on the amount of item charge"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.GRIDDLED_CORN,
			EID = {
				Desc = "\1 +1 damage#+1 black heart#Drops a spicy key"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.ETERNAL_D10,
			EID = {
				Desc = "Rerolls enemies in the current room#Enemies have a chance to disappear"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.TOY_CAMERA,
			EID = {
				Desc = "Create a camera flash that destroys projectiles and stuns enemies#Grants a tears up when you flash yourself#If enough enemies are caught, spawns a Cool Photo"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.HAPPYHEAD_AXE,
			EID = {
				Desc = "Periodically fire a piercing axe towards the closest enemy#The axe boomerangs back shortly after launch"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.PENNY_ROLL,
			EID = {
				Desc = "Spawns a penny trinket, a golden penny and 4 random pennies"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.EVIL_STICKER,
			EID = {
				Desc = "Increases the chance for immoral hearts, cursed pennies, dire chests, spicy keys and copper bombs to spawn"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.WIMPY_BRO,
			EID = {
				Desc = "Slammer familiar that jumps on and crushes enemies"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.ROBOBABY3,
			EID = {
				Desc = "Familiar that moves diagonally in the direction you move#On contact with enemies, will fire 8 lasers around it"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.TELEBOMBS,
			EID = {
				Desc = "+5 bombs#A target follows behind you at a delay#When placing a bomb, the player teleports back to the marker, and the bomb instantly explodes"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.DEVILS_DAGGER,
			EID = {
				Desc = "Fire daggers alongisde your tears#Enemies when killed drop gems that can power up your daggers"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.STRANGE_RED_OBJECT,
			EID = {
				Desc = "\1 +1 red heart#\1 +0.3 damage#\1 +0.05 speed#\1 +2 luck"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.D3,
			EID = {
				Desc = "Orbital familiar that rerolls tears#Wacky"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.EMOJI_GLASSES,
			EID = {
				Desc = "Fire emoji tears that each have a unique effect#Cycles through 3 different emojis at a time"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.SACK_OF_SPICY,
			EID = {
				Desc = "Sack familiar that spawns spicy keys"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.DEVILS_ABACUS,
			EID = {
				Desc = "Count with your tears for an increasing damage and tears up#Counting counts as firing X amount of tears and stopping"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.DAZZLING_SLOT,
			EID = {
				Desc = "Pay 5 cents to turn an enemy into a one use Golden Slot Machine"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.INFINITY_VOLT,
			EID = {
				Desc = "Double tap to link to an enemy#Linked enemies are charmed and continually spawn lasers#After being linked for long enough, the enemy will explode"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.KALUS_HEAD,
			EID = {
				Desc = "Is held above the player's head, and controls a cone of vision#Enemies in the cone are frozen and take a minor amount of damage#Enemies killed while frozen burst into tears"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.HORNCOB,
			EID = {
				Desc = "Killing an enemy has a chance to take a pill"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.X10KACHING,
			EID = {
				Desc = "+10 coins"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.X10BATOOMKLING,
			EID = {
				Desc = "+10 keys"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.X10BADUMP,
			EID = {
				Desc = "+10 hearts (not containers)"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.X10BZZT,
			EID = {
				Desc = "+10 pips of charge"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.X10CHOMPCHOMP,
			EID = {
				Desc = "+10 glizzies"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.RAT_POISON,
			EID = {
				Desc = "When used in a room with a visible creator, will skip it and remove all future rooms by that person"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.ANGELIC_LYRE_B,
			EID = {
				Desc = "Can be used to change into a unique tear mode and reset tear delay#Blue mode fires 1, then 3, then 0 tears"}
				}
				
		,
		{ ID = FiendFolio.ITEM.COLLECTIBLE.ANGELIC_LYRE_R,
			EID = {
				Desc = "Can be used to change into a unique tear mode and reset tear delay#Red mode fires 4 spectral tears with a long cooldown"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.ANGELIC_LYRE_Y,
			EID = {
				Desc = "Can be used to change into a unique tear mode and reset tear delay#Yellow mode fires a chain of 10 weaker homing tears and then has a long cooldown"}
				}
				
		,
		{ ID = FiendFolio.ITEM.COLLECTIBLE.LEMON_MISHUH,
			EID = {
				Desc = "{{Collectible56}} A throwable lemon mishap"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.MIME_DEGREE,
			EID = {
				Desc = "Summon blocks in the room that enemies cannot pass through#Touch the block to relocate it"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.CRAZY_JACKPOT,
			EID = {
				Desc = "On hit, the player rolls for a unique effect"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.NIL_PASTA,
			EID = {
				Desc = "Capture enemies with spaghetti ropes to hold them in place.#Pulling out the spaghetti also removes parts of their code, and they can occasionally lose their AI"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.CLUTCHS_CURSE,
			EID = {
				Desc = "Familiar that possesses the player occasionally#When possessed, the player can fire a homing ipecac tear#Rocks occasionally glow purple and shoot fire on destruction"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.PET_PEEVE,
			EID = {
				Desc = "Grudge familiar#Moves around like a poky#Charges on double tap"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.MOMS_STOCKINGS,
			EID = {
				Desc = "\1 +1.5 Range up#Spawns a bunch of skuzzes"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.GOLDEN_POPSICLE,
			EID = {
				Desc = "\1 +1 soul heart#\1 +2 luck up#Spawns a golden pickup"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.TIME_ITSELF,
			EID = {
				Desc = "Has a chance to fire multi-euclidean tears#Enemies that are multi-euclidean can be shot through, doubling tears"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.EMPTY_BOOK,
			EID = {
				Desc = "Customizable active item#Does a variety of effects depending on what you choose"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.MY_STORY_2,
			EID = {
				Desc = "Customizable active item#Does a variety of effects depending on what you choose"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.MY_STORY_4,
			EID = {
				Desc = "Customizable active item#Does a variety of effects depending on what you choose"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.MY_STORY_6,
			EID = {
				Desc = "Customizable active item#Does a variety of effects depending on what you choose"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.HOST_ON_TOAST,
			EID = {
				Desc = "\1 +0.5 Damage up#\1 +0.38 Range up"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.BAG_OF_BOBBIES,
			EID = {
				Desc = "Has a chance to spawn a Fragile Bobby on room clear#{{Collectible8}} Fragile bobbies are similar to Brother Bobby but can die"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.BOX_TOP,
			EID = {
				Desc = "\1 +2 Luck up#Spawns a Puzzle Piece"
			}
		},
		{ ID = FiendFolio.ITEM.COLLECTIBLE.KINDA_EGG,
			EID = {
				Desc = "\1 +1 HP up#Spawns a random object"
			}
		},
	}
}

-- Lots of eid icons by Cuerzor

if EID then
	local icons = Sprite()
	icons:Load("gfx/ui/eid/eid_ff_inline_icons.anm2", true)

	-- Hearts
	EID:addIcon("ffMorbidHeart", "Hearts", 0, 10, 9, 1, 1, icons)
	EID:addIcon("ffHalfMorbidHeart", "Hearts", 1, 10, 9, 1, 1, icons)
	EID:addIcon("ffThirdMorbidHeart", "Hearts", 2, 10, 9, 1, 1, icons)
	EID:addIcon("ffMorbidBoneHeart", "Hearts", 3, 10, 9, 1, 1, icons)
	EID:addIcon("ffHalfMorbidBoneHeart", "Hearts", 4, 10, 9, 1, 1, icons)
	EID:addIcon("ffThirdMorbidBoneHeart", "Hearts", 5, 10, 9, 1, 1, icons)
	EID:addIcon("ffImmoralHeart", "Hearts", 6, 10, 9, 1, 1, icons)
	EID:addIcon("ffHalfImmoralHeart", "Hearts", 7, 10, 9, 1, 1, icons)

	-- Status Effects
	EID:addIcon("ffBruise", "StatusEffects", 0, 10, 9, 0, 1, icons)
	EID:addIcon("ffSew", "StatusEffects", 1, 10, 9, 0, 1, icons)
	EID:addIcon("ffHemorrhage", "StatusEffects", 2, 10, 9, 0, 1, icons)
	EID:addIcon("ffSleeping", "StatusEffects", 3, 10, 9, 0, 1, icons)
	EID:addIcon("ffBerserk", "StatusEffects", 4, 10, 9, 0, 1, icons)
	EID:addIcon("ffHoney", "StatusEffects", 5, 10, 9, 0, 1, icons)
	EID:addIcon("ffDoom", "StatusEffects", 6, 10, 9, 0, 1, icons)

	-- Curses
	EID:addIcon("ffCurseImp", "Curses", 0, 14, 12, 0, -1, icons)
	EID:addIcon("ffCurseStone", "Curses", 1, 13, 14, 0, -1, icons)
	EID:addIcon("ffCurseSun", "Curses", 2, 13, 13, 0, -1, icons)
	EID:addIcon("ffCurseSwine", "Curses", 3, 14, 12, 0, -1, icons)
	EID:addIcon("ffCurseGhost", "Curses", 4, 13, 13, 0, -1, icons)
	EID:addIcon("ffCurseScythe", "Curses", 5, 13, 11, 0, -1, icons)
	EID:addIcon("ffCurseMaster", "Curses", 6, 13, 13, 0, -1, icons)

	-- Curses (small)
	EID:addIcon("ffCurseImpSmall", "Curses", 7, 9, 9, 0, 1, icons)
	EID:addIcon("ffCurseStoneSmall", "Curses", 8, 11, 9, 0, 1, icons)
	EID:addIcon("ffCurseSunSmall", "Curses", 9, 9, 10, 0, 1, icons)
	EID:addIcon("ffCurseSwineSmall", "Curses", 10, 10, 8, 0, 1, icons)
	EID:addIcon("ffCurseGhostSmall", "Curses", 11, 10, 9, 0, 1, icons)
	EID:addIcon("ffCurseScytheSmall", "Curses", 12, 9, 8, 0, 1, icons)
	EID:addIcon("ffCurseMasterSmall", "Curses", 13, 11, 10, 0, 1, icons)

	-- Players 
	local players = Sprite()
	players:Load("gfx/ui/eid/eid_ff_player_icons.anm2", true)
	EID:addIcon("Player"..FiendFolio.PLAYER.FIEND, "Players", 0, 12, 12, -1, 1, players)
	EID:addIcon("Player"..FiendFolio.PLAYER.BIEND, "Players", 1, 12, 12, -1, 1, players)
	EID:addIcon("Player"..FiendFolio.PLAYER.GOLEM, "Players", 2, 12, 12, -1, 1, players)
	EID:addIcon("Player"..FiendFolio.PLAYER.SLIPPY, "Players", 4, 12, 12, -1, 1, players)
	EID:addIcon("Player"..FiendFolio.PLAYER.CHINA, "Players", 5, 12, 12, -1, 1, players)

	mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, eff)
		if eff.SubType == 880 or eff.SubType == 881 then
			local descTable = {
				["Name"] = "[Dice Room effect] (12)",
				["Description"] = "For the whole floor, on room clear rerolls all grids in the room into other random grids.",
			}
			eff:GetData()["EID_Description"] = descTable
		end
	end, 76)
end
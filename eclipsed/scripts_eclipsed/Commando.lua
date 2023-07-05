local mod = EclipsedMod
local enums = mod.enums
local functions = mod.functions
local datatables = mod.datatables

---EXECUTE COMMAND---
function mod:onExecuteCommand(command, args)
	--- console commands ---
	if command == "eclipsed" then
		if args == "help" or args == "" then
			print('eclipsed curse enabled - enable mod curses')
			print('eclipsed curse disabled - disable mod curses')
			print('eclipsed curse [curse number | name] -> enable/disable mod curse')
			print('eclipsed curse -> list of curses')
			print('eclipsed reset challenge [all | magic | lobotomy | potato | beatmaker | mongofamily]') -- | shovel
			print('eclipsed unlock challenge [all | magic | lobotomy | potato | beatmaker | mongofamily]') --| shovel
			print('eclipsed reset [all | nadab | abihu | unbid | tunbid] [heart | isaac | bbaby | satan | lamb | rush | hush | deli | megas | greed | mother | beast]')
			print('eclipsed unlock [all | nadab | abihu | unbid | tunbid] [heart | isaac | bbaby | satan | lamb | rush | hush | deli | megas | greed | mother | beast]')
			print("example: [eclipsed reset nadab rush] -> reset completion on Boss Rush")
			print("example: [eclipsed unlock] OR [eclipsed unlock all] -> unlocks everything on all characters")
			--print("UnbiddenB familiars aura attack - not implemented (fate rewards, incubus, splinker, twisted pair?)") they somehow works; guess it's ok
		elseif args == "curse" then
			print('eclipsed curse disabled -> disable mod curses FOREVAAA')
			print('eclipsed curse [curse number or name] -> enable/disable mod curses')
			print("eclipsed curse [1 | void]")
			print("eclipsed curse [2 | jam | jamming]")
			print("eclipsed curse [3 | emperor]")
			print("eclipsed curse [4 | mage | magician]")
			print("eclipsed curse [5 | pride]")
			print("eclipsed curse [6 | bell]")
			print("eclipsed curse [7 | envy]")
			print("eclipsed curse [8 | carrion]")
			print("eclipsed curse [9 | bishop]")
			print("eclipsed curse [10 | montezuma | zuma]")
			print("eclipsed curse [11 | misfortune]")
			print("eclipsed curse [12 | poverty]")
			print("eclipsed curse [13 | fool]")
			print("eclipsed curse [14 | secret | secrets]")
			print("eclipsed curse [15 | warden]")
			print("eclipsed curse [16 | desolation | wisp]")
		elseif args == "curse enable" then
			print("eclipsed curses enabled")
			mod.PersistentData.SpecialCursesAvtice = true
		elseif args == "curse disable" then
			print("eclipsed curses disabled")
			mod.PersistentData.SpecialCursesAvtice = false
		elseif args == "curse 1" or args == "curse void" then
			functions.AddModCurse(enums.Curses.Void)
			print("Curse of the Void! - 16% chance to reroll enemies and grid upon entering room")
			print("eclipsed curse [1 | void]")
		elseif args == "curse 2" or args == "curse jam" or args == "curse jamming" then
			functions.AddModCurse(enums.Curses.Jamming)
			print("Curse of the Jamming! - 16% chance to respawn enemies after clearing room")
			print("eclipsed curse [2 | jam | jamming]")
		elseif args == "curse 3" or args == "curse emperor" then
			functions.AddModCurse(enums.Curses.Emperor)
			print("Curse of the Emperor! - remove exit door from boss room (similar to mom boss room)")
			print("eclipsed curse [3 | emperor]")
		elseif args == "curse 4" or args == "curse mage" or args == "curse magician" then
			functions.AddModCurse(enums.Curses.Magician)
			print("Curse of the Magician! - 25% chance to shoot homing enemy tear (except boss)")
			print("eclipsed curse [4 | mage | magician]")
		elseif args == "curse 5" or args == "curse pride" then
			functions.AddModCurse(enums.Curses.Pride)
			print("Curse of the Pride! - 50% chance to enemies become champion (except boss)")
			print("eclipsed curse [5 | pride]")
		elseif args == "curse 6" or args == "curse bell" then
			functions.AddModCurse(enums.Curses.Bell)
			print("Curse of the Bell! - all troll bombs is golden")
			print("eclipsed curse [6 | bell]")
		elseif args == "curse 7" or args == "curse envy" then
			functions.AddModCurse(enums.Curses.Envy)
			print("Curse of the Envy! - other shop items disappear when you buy one [shop, black market, member card, devil deal, angel shop]")
			print("eclipsed curse [7 | envy]")
		elseif args == "curse 8" or args == "curse carrion" then
			functions.AddModCurse(enums.Curses.Carrion)
			print("Curse of Carrion! - turn normal poops into red")
			print("eclipsed curse [8 | carrion]")
		elseif args == "curse 9" or args == "curse bishop" then
			functions.AddModCurse(enums.Curses.Bishop)
			print("Curse of the Bishop! - 16% chance to damage immunity. enemy will flash blue")
			print("eclipsed curse [9 | bishop]")
		elseif args == "curse 10" or args == "curse zuma" or args == "curse montezuma" then
			functions.AddModCurse(enums.Curses.Montezuma)
			print("Curse of Montezuma! - slippery floor inside uncleared rooms")
			print("eclipsed curse [10 | montezuma | zuma]")
		elseif args == "curse 11" or args == "curse misfortune" then
			functions.AddModCurse(enums.Curses.Misfortune)
			print("Curse of Misfortune! - -5 luck while curse is applyed")
			print("eclipsed curse [11 | misfortune]")
		elseif args == "curse 12" or args == "curse poverty" then
			functions.AddModCurse(enums.Curses.Poverty)
			print("Curse of Poverty! - greedy enemy tears. drop your coins when enemy tear hits you")
			print("eclipsed curse [12 | poverty]")
		elseif args == "curse 13" or args == "curse fool" then
			functions.AddModCurse(enums.Curses.Fool)
			print("Curse of the Fool! - 16% chance to respawn enemies in cleared rooms (except boss room)")
			print("eclipsed curse [13 | fool]")
		elseif args == "curse 14" or args == "curse secret" or args == "curse secrets" then
			functions.AddModCurse(enums.Curses.Secrets)
			print("Curse of Secrets! - hide secret/supersecret room doors when reentering room")
			print("eclipsed curse [14 | secret | secrets]")
		elseif args == "curse 15" or args == "curse warden" then
			functions.AddModCurse(enums.Curses.Warden)
			print("Curse of the Warden! - all locked doors need 2 keys")
			print("Visual bug with door not applying chains on first door encounter. Door stil require 2 keys")
			print("eclipsed curse [15 | warden]")
		elseif args == "curse 16" or args == "curse wisp" or args == "curse desolation" then
			functions.AddModCurse(enums.Curses.Desolation)
			print("Curse of the Desolation! - 16% chance to turn item into Item Wisp when touched. Add wisped item on next floor")
			print("eclipsed curse [16 | desolation | wisp]")
		elseif args == "reset" or args == "reset all" then
		    mod.PersistentData.CompletionMarks.Nadab = datatables.completionInit
			mod.PersistentData.CompletionMarks.Abihu = datatables.completionInit
			mod.PersistentData.CompletionMarks.Unbidden = datatables.completionInit
			mod.PersistentData.CompletionMarks.UnbiddenB = datatables.completionInit
			mod.PersistentData.CompletionMarks.Challenges = datatables.challengesInit
			print("reset all")
		elseif args == "reset challenge" or args == "reset challenge all" then
			mod.PersistentData.CompletionMarks.Challenges = datatables.challengesInit
			print("reset all challenges")
		elseif args == "reset potato" or args == "reset challenge potato" then
			mod.PersistentData.CompletionMarks.Challenges.potato = 0
			print("reset potato challenge")
		elseif args == "reset lobotomy" or args == "reset challenge lobotomy" then
			mod.PersistentData.CompletionMarks.Challenges.lobotomy = 0
			print("reset lobotomy challenge")
		elseif args == "reset magician" or args == "reset challenge magician" then
			mod.PersistentData.CompletionMarks.Challenges.magician = 0
			print("reset magician challenge")
		elseif args == "reset beatmaker" or args == "reset challenge beatmaker" then
			mod.PersistentData.CompletionMarks.Challenges.beatmaker = 0
			print("reset beatmaker challenge")
		elseif args == "reset mongofamily" or args == "reset challenge mongofamily" then
			mod.PersistentData.CompletionMarks.Challenges.mongofamily = 0
			print("reset mongofamily challenge")
		elseif args == "reset nadab" or args == "reset nadab all" then
			mod.PersistentData.CompletionMarks.Nadab = datatables.completionInit
		    print("ok")
		elseif args == "reset nadab heart" then
			mod.PersistentData.CompletionMarks.Nadab.heart = 0
		    print("ok")
		elseif args == "reset nadab isaac" then
			mod.PersistentData.CompletionMarks.Nadab.isaac = 0
		    print("ok")
		elseif args == "reset nadab bbaby" then
			mod.PersistentData.CompletionMarks.Nadab.bbaby = 0
		    print("ok")
		elseif args == "reset nadab satan" then
			mod.PersistentData.CompletionMarks.Nadab.satan = 0
		    print("ok")
		elseif args == "reset nadab lamb" then
			mod.PersistentData.CompletionMarks.Nadab.lamb = 0
		    print("ok")
		elseif args == "reset nadab rush" then
			mod.PersistentData.CompletionMarks.Nadab.rush = 0
		    print("ok")
		elseif args == "reset nadab hush" then
			mod.PersistentData.CompletionMarks.Nadab.hush = 0
		    print("ok")
		elseif args == "reset nadab deli" then
			mod.PersistentData.CompletionMarks.Nadab.deli = 0
		    print("ok")
		elseif args == "reset nadab mega" then
			mod.PersistentData.CompletionMarks.Nadab.mega = 0
		    print("ok")
		elseif args == "reset nadab greed" then
			mod.PersistentData.CompletionMarks.Nadab.greed = 0
		    print("ok")
		elseif args == "reset nadab mother" then
			mod.PersistentData.CompletionMarks.Nadab.mother = 0
		    print("ok")
		elseif args == "reset nadab beast" then
			mod.PersistentData.CompletionMarks.Nadab.beast = 0
		    print("ok")
		elseif args == "reset abihu" or args == "reset abihu all" then
			mod.PersistentData.CompletionMarks.Abihu = datatables.completionInit
			print("ok")
		elseif args == "reset abihu heart" then
			mod.PersistentData.CompletionMarks.Abihu.heart = 0
		    print("ok")
		elseif args == "reset abihu isaac" then
			mod.PersistentData.CompletionMarks.Abihu.isaac = 0
		    print("ok")
		elseif args == "reset abihu bbaby" then
			mod.PersistentData.CompletionMarks.Abihu.bbaby = 0
		    print("ok")
		elseif args == "reset abihu satan" then
			mod.PersistentData.CompletionMarks.Abihu.satan = 0
		    print("ok")
		elseif args == "reset abihu lamb" then
			mod.PersistentData.CompletionMarks.Abihu.lamb = 0
		    print("ok")
		elseif args == "reset abihu rush" then
			mod.PersistentData.CompletionMarks.Abihu.rush = 0
		    print("ok")
		elseif args == "reset abihu hush" then
			mod.PersistentData.CompletionMarks.Abihu.hush = 0
		    print("ok")
		elseif args == "reset abihu deli" then
			mod.PersistentData.CompletionMarks.Abihu.deli = 0
		    print("ok")
		elseif args == "reset abihu mega" then
			mod.PersistentData.CompletionMarks.Abihu.mega = 0
		    print("ok")
		elseif args == "reset abihu greed" then
			mod.PersistentData.CompletionMarks.Abihu.greed = 0
		    print("ok")
		elseif args == "reset abihu mother" then
			mod.PersistentData.CompletionMarks.Abihu.mother = 0
		    print("ok")
		elseif args == "reset abihu beast" then
			mod.PersistentData.CompletionMarks.Abihu.beast = 0
		    print("ok")
		elseif args == "reset unbid" or args == "reset unbid all" then
			mod.PersistentData.CompletionMarks.Unbidden = datatables.completionInit
			print("ok")
		elseif args == "reset unbid heart" then
			mod.PersistentData.CompletionMarks.Unbidden.heart = 0
		    print("ok")
		elseif args == "reset unbid isaac" then
			mod.PersistentData.CompletionMarks.Unbidden.isaac = 0
		    print("ok")
		elseif args == "reset unbid bbaby" then
			mod.PersistentData.CompletionMarks.Unbidden.bbaby = 0
		    print("ok")
		elseif args == "reset unbid satan" then
			mod.PersistentData.CompletionMarks.Unbidden.satan = 0
		    print("ok")
		elseif args == "reset unbid lamb" then
			mod.PersistentData.CompletionMarks.Unbidden.lamb = 0
		    print("ok")
		elseif args == "reset unbid rush" then
			mod.PersistentData.CompletionMarks.Unbidden.rush = 0
		    print("ok")
		elseif args == "reset unbid hush" then
			mod.PersistentData.CompletionMarks.Unbidden.hush = 0
		    print("ok")
		elseif args == "reset unbid deli" then
			mod.PersistentData.CompletionMarks.Unbidden.deli = 0
		    print("ok")
		elseif args == "reset unbid mega" then
			mod.PersistentData.CompletionMarks.Unbidden.mega = 0
		    print("ok")
		elseif args == "reset unbid greed" then
			mod.PersistentData.CompletionMarks.Unbidden.greed = 0
		    print("ok")
		elseif args == "reset unbid mother" then
			mod.PersistentData.CompletionMarks.Unbidden.mother = 0
		    print("ok")
		elseif args == "reset unbid beast" then
			mod.PersistentData.CompletionMarks.Unbidden.beast = 0
		    print("ok")
		elseif args == "reset tunbid" or args == "reset tunbid all" then
			mod.PersistentData.CompletionMarks.UnbiddenB = datatables.completionInit
			print("ok")
		elseif args == "reset tunbid heart" then
			mod.PersistentData.CompletionMarks.UnbiddenB.heart = 0
		    print("ok")
		elseif args == "reset tunbid isaac" then
			mod.PersistentData.CompletionMarks.UnbiddenB.isaac = 0
		    print("ok")
		elseif args == "reset tunbid bbaby" then
			mod.PersistentData.CompletionMarks.UnbiddenB.bbaby = 0
		    print("ok")
		elseif args == "reset tunbid satan" then
			mod.PersistentData.CompletionMarks.UnbiddenB.satan = 0
		    print("ok")
		elseif args == "reset tunbid lamb" then
			mod.PersistentData.CompletionMarks.UnbiddenB.lamb = 0
		    print("ok")
		elseif args == "reset tunbid rush" then
			mod.PersistentData.CompletionMarks.UnbiddenB.rush = 0
		    print("ok")
		elseif args == "reset tunbid hush" then
			mod.PersistentData.CompletionMarks.UnbiddenB.hush = 0
		    print("ok")
		elseif args == "reset tunbid deli" then
			mod.PersistentData.CompletionMarks.UnbiddenB.deli = 0
		    print("ok")
		elseif args == "reset tunbid mega" then
			mod.PersistentData.CompletionMarks.UnbiddenB.mega = 0
		    print("ok")
		elseif args == "reset tunbid greed" then
			mod.PersistentData.CompletionMarks.UnbiddenB.greed = 0
		    print("ok")
		elseif args == "reset tunbid mother" then
			mod.PersistentData.CompletionMarks.UnbiddenB.mother = 0
		    print("ok")
		elseif args == "reset tunbid beast" then
			mod.PersistentData.CompletionMarks.UnbiddenB.beast = 0
		    print("ok")
		elseif args == "unlock" or args == "unlock all" then
			mod.PersistentData.CompletionMarks.Nadab = datatables.completionFull
			mod.PersistentData.CompletionMarks.Abihu = datatables.completionFull
			mod.PersistentData.CompletionMarks.Unbidden = datatables.completionFull
			mod.PersistentData.CompletionMarks.UnbiddenB = datatables.completionFull
			mod.PersistentData.CompletionMarks.Challenges = datatables.challengesFull
		    print("unlocked all")
		elseif args == "unlock challenge" or args == "unlock challenge all" then
			mod.PersistentData.CompletionMarks.Challenges = datatables.challengesFull
			print("unlock all challenges")
		elseif args == "unlock potato" or args == "unlock challenge potato" then
			mod.PersistentData.CompletionMarks.Challenges.potato = 2
			print("reset potato challenge")
		elseif args == "unlock lobotomy" or args == "unlock challenge lobotomy" then
			mod.PersistentData.CompletionMarks.Challenges.lobotomy = 2
			print("unlock lobotomy challenge")
		elseif args == "unlock magician" or args == "unlock challenge magician" then
			mod.PersistentData.CompletionMarks.Challenges.magician = 2
			print("unlock magician challenge")
		elseif args == "unlock beatmaker" or args == "unlock challenge beatmaker" then
			mod.PersistentData.CompletionMarks.Challenges.beatmaker = 2
			print("unlock beatmaker challenge")
		elseif args == "unlock mongofamily" or args == "unlock challenge mongofamily" then
			mod.PersistentData.CompletionMarks.Challenges.mongofamily = 2
			print("unlock mongofamily challenge")
		elseif args == "unlock nadab" or args == "unlock nadab all" then
			mod.PersistentData.CompletionMarks.Nadab = datatables.completionFull
		    print("ok")
		elseif args == "unlock nadab heart" then
			mod.PersistentData.CompletionMarks.Nadab.heart = 2
		    print("ok")
		elseif args == "unlock nadab isaac" then
			mod.PersistentData.CompletionMarks.Nadab.isaac = 2
		    print("ok")
		elseif args == "unlock nadab bbaby" then
			mod.PersistentData.CompletionMarks.Nadab.bbaby = 2
		    print("ok")
		elseif args == "unlock nadab satan" then
			mod.PersistentData.CompletionMarks.Nadab.satan = 2
		    print("ok")
		elseif args == "unlock nadab lamb" then
			mod.PersistentData.CompletionMarks.Nadab.lamb = 2
		    print("ok")
		elseif args == "unlock nadab rush" then
			mod.PersistentData.CompletionMarks.Nadab.rush = 2
		    print("ok")
		elseif args == "unlock nadab hush" then
			mod.PersistentData.CompletionMarks.Nadab.hush = 2
		    print("ok")
		elseif args == "unlock nadab deli" then
			mod.PersistentData.CompletionMarks.Nadab.deli = 2
		    print("ok")
		elseif args == "unlock nadab mega" then
			mod.PersistentData.CompletionMarks.Nadab.mega = 2
		    print("ok")
		elseif args == "unlock nadab greed" then
			mod.PersistentData.CompletionMarks.Nadab.greed = 2
		    print("ok")
		elseif args == "unlock nadab mother" then
			mod.PersistentData.CompletionMarks.Nadab.mother = 2
		    print("ok")
		elseif args == "unlock nadab beast" then
			mod.PersistentData.CompletionMarks.Nadab.beast = 2
		    print("ok")
		elseif args == "unlock abihu" or args == "unlock abihu all" then
			mod.PersistentData.CompletionMarks.Abihu = datatables.completionFull
			print("ok")
		elseif args == "unlock abihu heart" then
			mod.PersistentData.CompletionMarks.Abihu.heart = 2
		    print("ok")
		elseif args == "unlock abihu isaac" then
			mod.PersistentData.CompletionMarks.Abihu.isaac = 2
		    print("ok")
		elseif args == "unlock abihu bbaby" then
			mod.PersistentData.CompletionMarks.Abihu.bbaby = 2
		    print("ok")
		elseif args == "unlock abihu satan" then
			mod.PersistentData.CompletionMarks.Abihu.satan = 2
		    print("ok")
		elseif args == "unlock abihu lamb" then
			mod.PersistentData.CompletionMarks.Abihu.lamb = 2
		    print("ok")
		elseif args == "unlock abihu rush" then
			mod.PersistentData.CompletionMarks.Abihu.rush = 2
		    print("ok")
		elseif args == "unlock abihu hush" then
			mod.PersistentData.CompletionMarks.Abihu.hush = 2
		    print("ok")
		elseif args == "unlock abihu deli" then
			mod.PersistentData.CompletionMarks.Abihu.deli = 2
		    print("ok")
		elseif args == "unlock abihu mega" then
			mod.PersistentData.CompletionMarks.Abihu.mega = 2
		    print("ok")
		elseif args == "unlock abihu greed" then
			mod.PersistentData.CompletionMarks.Abihu.greed = 2
		    print("ok")
		elseif args == "unlock abihu mother" then
			mod.PersistentData.CompletionMarks.Abihu.mother = 2
		    print("ok")
		elseif args == "unlock abihu beast" then
			mod.PersistentData.CompletionMarks.Abihu.beast = 2
		    print("ok")
		elseif args == "unlock unbid" or args == "unlock unbid all" then
			mod.PersistentData.CompletionMarks.Unbidden = datatables.completionFull
			print("ok")
		elseif args == "unlock unbid heart" then
			mod.PersistentData.CompletionMarks.Unbidden.heart = 2
		    print("ok")
		elseif args == "unlock unbid isaac" then
			mod.PersistentData.CompletionMarks.Unbidden.isaac = 2
		    print("ok")
		elseif args == "unlock unbid bbaby" then
			mod.PersistentData.CompletionMarks.Unbidden.bbaby = 2
		    print("ok")
		elseif args == "unlock unbid satan" then
			mod.PersistentData.CompletionMarks.Unbidden.satan = 2
		    print("ok")
		elseif args == "unlock unbid lamb" then
			mod.PersistentData.CompletionMarks.Unbidden.lamb = 2
		    print("ok")
		elseif args == "unlock unbid rush" then
			mod.PersistentData.CompletionMarks.Unbidden.rush = 2
		    print("ok")
		elseif args == "unlock unbid hush" then
			mod.PersistentData.CompletionMarks.Unbidden.hush = 2
		    print("ok")
		elseif args == "unlock unbid deli" then
			mod.PersistentData.CompletionMarks.Unbidden.deli = 2
		    print("ok")
		elseif args == "unlock unbid mega" then
			mod.PersistentData.CompletionMarks.Unbidden.mega = 2
		    print("ok")
		elseif args == "unlock unbid greed" then
			mod.PersistentData.CompletionMarks.Unbidden.greed = 2
		    print("ok")
		elseif args == "unlock unbid mother" then
			mod.PersistentData.CompletionMarks.Unbidden.mother = 2
		    print("ok")
		elseif args == "unlock unbid beast" then
			mod.PersistentData.CompletionMarks.Unbidden.beast = 2
		    print("ok")
		elseif args == "unlock tunbid" or args == "unlock tunbid all" then
			mod.PersistentData.CompletionMarks.UnbiddenB = datatables.completionFull
			print("ok")
		elseif args == "unlock tunbid heart" then
			mod.PersistentData.CompletionMarks.UnbiddenB.heart = 2
		    print("ok")
		elseif args == "unlock tunbid isaac" then
			mod.PersistentData.CompletionMarks.UnbiddenB.isaac = 2
		    print("ok")
		elseif args == "unlock tunbid bbaby" then
			mod.PersistentData.CompletionMarks.UnbiddenB.bbaby = 2
		    print("ok")
		elseif args == "unlock tunbid satan" then
			mod.PersistentData.CompletionMarks.UnbiddenB.satan = 2
		    print("ok")
		elseif args == "unlock tunbid lamb" then
			mod.PersistentData.CompletionMarks.UnbiddenB.lamb = 2
		    print("ok")
		elseif args == "unlock tunbid rush" then
			mod.PersistentData.CompletionMarks.UnbiddenB.rush = 2
		    print("ok")
		elseif args == "unlock tunbid hush" then
			mod.PersistentData.CompletionMarks.UnbiddenB.hush = 2
		    print("ok")
		elseif args == "unlock tunbid deli" then
			mod.PersistentData.CompletionMarks.UnbiddenB.deli = 2
		    print("ok")
		elseif args == "unlock tunbid mega" then
			mod.PersistentData.CompletionMarks.UnbiddenB.mega = 2
		    print("ok")
		elseif args == "unlock tunbid greed" then
			mod.PersistentData.CompletionMarks.UnbiddenB.greed = 2
		    print("ok")
		elseif args == "unlock tunbid mother" then
			mod.PersistentData.CompletionMarks.UnbiddenB.mother = 2
		    print("ok")
		elseif args == "unlock tunbid beast" then
			mod.PersistentData.CompletionMarks.UnbiddenB.beast = 2
		    print("ok")
		end
	end
end
mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, mod.onExecuteCommand)


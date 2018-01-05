/obj/item/organ/internal/brain
	name = "brain"
	health = INFINITY //They need to live awhile longer than other organs.
	max_damage = 200
	icon_state = "brain2"
	force = 1.0
	w_class = 2
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = "biotech=3"
	attack_verb = list("attacked", "slapped", "whacked")
	var/mob/living/carbon/brain/brainmob = null
	organ_tag = "brain"
	parent_organ = "head"
	slot = "brain"
	vital = 1
	var/mmi_icon = 'icons/obj/assemblies.dmi'
	var/mmi_icon_state = "mmi_full"

/obj/item/organ/internal/brain/surgeryize()
	if(!owner)
		return
	owner.setEarDamage(0,0) //Yeah, didn't you...hear? The ears are totally inside the brain.

/obj/item/organ/internal/brain/xeno
	name = "xenomorph brain"
	desc = "We barely understand the brains of terrestial animals. Who knows what we may find in the brain of such an advanced species?"
	icon_state = "brain-x"
	origin_tech = "biotech=7"
	mmi_icon = 'icons/mob/alien.dmi'
	mmi_icon_state = "AlienMMI"

/obj/item/organ/internal/brain/New()
	..()
	spawn(5)
		if(brainmob && brainmob.client)
			brainmob.client.screen.len = null //clear the hud

/obj/item/organ/internal/brain/proc/transfer_identity(var/mob/living/carbon/H)
	brainmob = new(src)
	for(var/obj/item/weapon/implant/I in H.contents) // this should be in remove() so that even npcs transfer implants but it all needs to go into brainmob. hm....
		if(I && I.implanted && I.implant_loc == "brain")
			H.contents -= I
			brainmob.contents += I
			I.imp_in = brainmob
			I.loc = brainmob
			if(I.actions && !isemptylist(I.actions))
				for(var/X in I.actions)
					var/datum/action/A = X
					A.Grant(H)	// i guess if u grant to someone who already has it it takes it away
					A.Grant(brainmob)
	if(isnull(dna)) // someone didn't set this right...
		log_to_dd("[src] at [loc] did not contain a dna datum at time of removal.")
		dna = H.dna.Clone()
	name = "\the [dna.real_name]'s [initial(src.name)]"
	brainmob.dna = dna.Clone() // Silly baycode, what you do
//	brainmob.dna = H.dna.Clone() Putting in and taking out a brain doesn't make it a carbon copy of the original brain of the body you put it in
	brainmob.name = dna.real_name
	brainmob.real_name = dna.real_name
	brainmob.timeofhostdeath = H.timeofdeath
	if(H.mind)
		H.mind.transfer_to(brainmob)

	to_chat(brainmob, "<span class='notice'>You have been reduced to a [initial(src.name)]. Without being confined to a body, you can access your implants and sense things around you... This is not death.</span>")
	callHook("debrain", list(brainmob))

/obj/item/organ/internal/brain/examine(mob/user) // -- TLE
	..(user)
	if(brainmob && brainmob.client)//if thar be a brain inside... the brain.
		to_chat(user, "You can feel the small spark of life still left in this one.")
	else
		to_chat(user, "This one seems particularly lifeless. Perhaps it will regain some of its luster later..")

/obj/item/organ/internal/brain/remove(var/mob/living/user,special = 0)
	if(dna)
		name = "[dna.real_name]'s [initial(name)]"

	if(!owner) return ..() // Probably a redundant removal; just bail

	var/obj/item/organ/internal/brain/B = src
	
	
	if(!special)
		var/mob/living/simple_animal/borer/borer = owner.has_brain_worms()

		if(borer)
			borer.detatch() //Should remove borer if the brain is removed - RR
		if(owner.mind && !non_primary)//don't transfer if the owner does not have a mind.
			B.transfer_identity(user)

	if(istype(owner,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = owner
		H.update_hair(1)
	if(user && user.loc)
		src.loc = user.loc	
	..()

/obj/item/organ/internal/brain/insert(var/mob/living/target,special = 0)

	name = "[initial(name)]"
	var/brain_already_exists = 0

	if(!brain_already_exists)
		if(brainmob)
			for(var/obj/item/weapon/implant/I in brainmob.contents) // this should be in remove() so that even npcs transfer implants but it all needs to go into brainmob. hm....
				if(I)
					brainmob.contents -= I
					target.contents += I
					I.imp_in = target
					I.loc = target
					if(I.actions && !isemptylist(I.actions))
						for(var/X in I.actions)
							var/datum/action/A = X
							A.Grant(brainmob)	// i guess if u grant to someone who already has it it takes it away
							A.Grant(target)
			if(target.key)
				target.ghostize(0, 1)
			if(brainmob.mind)
				brainmob.mind.transfer_to(target)
			else
				target.key = brainmob.key
	..(target, special = special, dont_remove_slot = brain_already_exists)

/obj/item/organ/internal/brain/prepare_eat()
	return // Too important to eat.

/obj/item/organ/internal/brain/slime
	name = "slime core"
	desc = "A complex, organic knot of jelly and crystalline particles."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "green slime extract"
	mmi_icon_state = "slime_mmi"
//	parent_organ = "chest" Hello I am from the ministry of rubber forehead aliens how are you

/obj/item/organ/brain/slime/take_damage(var/amount, var/silent = 1)
	//Slimes are 150% more vulnerable to brain damage
	damage = between(0, src.damage + (1.5*amount), max_damage) //Since they take the damage twice, this is +150%
	return ..()


/obj/item/organ/internal/brain/golem
	name = "Runic mind"
	desc = "A tightly furled roll of paper, covered with indecipherable runes."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"

/obj/item/organ/internal/brain/Destroy() //copypasted from MMIs.
	/**
	if(istype(loc, /obj))
		var/obj/parent = loc
		if(parent.deleting)
			return ..()
		else
			loc = parent.loc
			return Destroy()
	else if(istype(loc, /mob/living))
		var/mob/living/parent = loc
		if(parent.deleting)
			return ..()
		else
			if(istype(parent.loc, /turf))
				remove(parent)
			else
				loc = parent.loc
			return Destroy()
	**/
	if(brainmob && brainmob.mind && brainmob.mind.active)
		return QDEL_HINT_LETMELIVE
	else
		return ..()
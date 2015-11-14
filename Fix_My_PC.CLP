;;; FUNCTIONS

(deffunction ask-question (?question $?allowed-values)
	(printout t ?question)
	(bind ?answer (read))
	(if (lexemep ?answer)
		then (bind ?answer (lowcase ?answer)))
	(while (not (member ?answer ?allowed-values)) do
		(printout t ?question)
		(bind ?answer (read))
		(if (lexemep ?answer)
			then (bind ?answer (lowcase ?answer))))
	?answer)

(deffunction yes-or-no-p (?question)
	(bind ?response (ask-question ?question oui non o n))
	(if (or (eq ?response oui) (eq ?response o))
		then TRUE
		else FALSE))
;;; CONCLUSIONS

(defrule image-affiche-conclusions
	(image-affiche oui)
	=>
	(assert (ecran-fonctionne oui))
	(assert (ordi-branche oui))
)

(defrule ecran-fonctionne-conclusions
	(ecran-fonctionne oui)
	=>
	(assert (ecran-branche oui))
)

(defrule ordi-demare-pas-conclusions
	(ordi-demarre non)
	=>
	(assert (ordi-plante non))
	(assert (os-demarre non))
	(assert (hardware-problem oui))
)

(defrule os-demarre-conclusions
	(os-demarre oui)
	=>
	(assert (image-affiche oui))
	(assert (ordi-demarre oui))
)

(defrule ordi-pas-branche-conclusions
	(ordi-branche non)
	=>
	(assert (conclusion "Brancher l'ordinateur"))
)

(defrule ecran-pas-branche-conclusions
	(ecran-branche non)
	=>
	(assert (conclusion "Brancher l'écran"))
)

(defrule ordi-plante-ecran-bleu-conclusions
	(ordi-plante oui)
	(ordi-ecran-bleu oui)
	=>
	(assert (hardware-problem oui))
)

(defrule ordi-plante-pas-ecran-bleu
	(ordi-plante oui)
	(ordi-ecran-bleu non)
	=>
	(assert (hardware-problem non))
)

(defrule hardware-problem-conclusions
	(hardware-problem oui)
	=>
	(assert (software-problem non))
)

(defrule software-problem-conclusions
	(software-problem oui)
	=>
	(assert (hardware-problem non))
)

(defrule fan-tourne-pas-conclusions
	(fan-tourne non)
	=>
	(assert (conclusion "Veuillez remplacer votre ventilateur"))
)

(defrule fan-libre-ferme-conclusions
	(fan-libre non)
	=>
	(assert (conclusion "Veuillez laisser respirer votre ordinateur, nettoyer le ventillateur, et libérer la sortie d'aération"))
)

(defrule temperature-ambiante-chaud-conclusions
	(temperature-ambiante-chaud oui)
	=>
	(assert (conclusion "Veuillez refroidir votre ordinateur, il a trop chaud"))
)

(defrule crash-reproductible-conclusions
	(crash-reproductible oui)
	=>
	(assert (surchauffe oui))
)

(defrule crash-reproductible-non-conclusions
	(crash-reproductible non)
	=>
	(assert (instable oui))
)

;;; RÈGLES

(defrule ordi-et-os-OK
	(os-demarre oui)
	(ordi-plante non)
	=>
	(assert (hardware-problem non))
)

(defrule tout-branche-pas-image
	(image-affiche non)
	(ecran-branche oui)
	(ordi-branche oui)
	=>
	(assert (hardware-problem oui))
)

(defrule pas-de-prob
	(ordi-plante non)
	(image-affiche oui)
	=>
	(assert (conclusion "Vouz n'avez pas de problèmes, merci d'avoir utilisé notre programme"))
)

(defrule ram-instable
	(ram-ok non)
	(instable oui)
	=>
	(assert (conclusion "Veuillez remplacer la barette défectueuse"))
)

(defrule ram-ok-instable
	(ram-ok oui)
	(instable oui)
	=>
	(assert (surchauffe oui))
)

(defrule disque-instable
	(surchauffe non)
	(ram-ok oui)
	(instable oui)
	=>
	(assert (conclusion "Le problème est probablement votre disque. Veuillez sauvegarder vos données ailleurs et le remplacer"))
)

;;; QUERY RULES

(defrule determine-ordi-image-depart
	(not(image-affiche ?))
	=>
	(if(yes-or-no-p "Est-ce qu'une image s'affiche lorsque vous allumez l'ordinateur ? (o ou n)") 
	then
		(assert (image-affiche oui))
	else 
		(assert (image-affiche non))
	)
)

(defrule determine-ordi-branche
	(not(ordi-branche ?))
	=>
	(if(yes-or-no-p "Est-ce que l'ordinateur est branché ? (o ou n)") 
	then
		(assert (ordi-branche oui))
	else 
		(assert (ordi-branche non))
	)
)

(defrule determine-ecran-branche
	(not(ecran-branche ?))
	=>
	(if(yes-or-no-p "Est-ce que l'écran est branché ? (o ou n)") 
	then
		(assert (ecran-branche oui))
	else 
		(assert (ecran-branche non))
	)
)

(defrule determine-ordi-demarre
	(image-affiche oui)
	(not(os-demarre ?))
	=>
	(if(yes-or-no-p "Est-ce que l'ordinateur démarre dans le système d'exploitation ? (o ou n)") 
	then
		(assert (os-demarre oui))
	else 
		(assert (os-demarre non))
	)
)

(defrule determine-ordi-plante
	(image-affiche oui)
	(not(ordi-plante ?))
	=>
	(if(yes-or-no-p "Est-ce que l'ordinateur plante ? (o ou n)") 
	then
		(assert (ordi-plante oui))
	else 
		(assert (ordi-plante non))
	)
)

(defrule determine-ordi-ecran-bleu
	(ordi-plante oui)
	(not(ordi-ecran-bleu ?))
	=>
	(if(yes-or-no-p "Est-ce que l'ordinateur plante avec un écran bleu ? (o ou n)") 
	then
		(assert (ordi-ecran-bleu oui))
	else 
		(assert (ordi-ecran-bleu non))
	)
)

;;; Hardware problems

(defrule determine-temps-crash
	(hardware-problem oui)
	(ordi-ecran-bleu oui)
	(not(crash-reproductible ?))
	(not(conclusion ?))
	=>
	(if(yes-or-no-p "Est-ce que l'écran bleu se produit plusieurs fois si vous répétez des circonstances semblables ? (o ou n)") 
	then
		(assert (crash-reproductible oui))
	else 
		(assert (crash-reproductible non))
	)
)

(defrule determine-fan-tourne
	(hardware-problem oui)
	(not(fan-tourne ?))
	(not(conclusion ?))
	=>
	(if(yes-or-no-p "Est-ce que le ventilateur de votre ordinateur tourne ? (o ou n)") 
	then
		(assert (fan-tourne oui))
	else 
		(assert (fan-tourne non))
	)
)

(defrule determine-fan-libre
	(surchauffe oui)
	(not(fan-libre ?))
	(not(conclusion ?))
	=>
	(if(yes-or-no-p "Est-ce que le ventilateur est à l'air libre et pas poussièreux ? (o ou n)") 
	then
		(assert (fan-libre oui))
	else 
		(assert (fan-libre non))
	)
)

(defrule determine-surchauffe-temperature
	(surchauffe oui)
	(not(temperature-ambiante-chaud ?))
	(not(conclusion ?))
	=>
	(if(yes-or-no-p "Est-ce qu'il fait chaud ? (o ou n)") 
	then
		(assert (temperature-ambiante-chaud oui))
	else 
		(assert (temperature-ambiante-chaud non))
	)
)

(defrule determine-ram-ok
	(instable oui)
	(not(ram-ok ?))
	(not(conclusion ?))
	=>
	(if(yes-or-no-p "Est-ce que votre système plante encore si vous enlèver une barette de RAM (les essayer une à une) ? (o ou n)") 
	then
		(assert (ram-ok oui))
	else 
		(assert (ram-ok non))
	)
)

;;; Sofware problems



;;; FINAL

(defrule print-conclusion
	(conclusion ?message)
	=>
	(printout t "Conclusion : " ?message crlf) 
)

(defrule print-non-conclusion
	(not(conclusion ?))
	=>
	(printout t "Aucune conclusion " crlf)
)
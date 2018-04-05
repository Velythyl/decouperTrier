main:	
    .data
    	tabMot: 	.space 600
    	buffer: 	.space 300
    	str1:  	.asciiz "Vous avez saisi le texte suivant:\n"
    	str2:	.asciiz "Voici le tableau des mots:\n"
    	str3:	.asciiz "\nVoici le texte trié: \n"

    .text
    	jal saisir

    	la $a0, str1    # imprime "vous avez ecrit"
    	li $v0, 4
    	syscall

    	la $a0, buffer  # reprends le buffer
    	li $v0, 4       # print le string du user
    	syscall
    
    	la $a0, buffer  # load byte space
    	li $a1, 300     # grosseur buffer
    
    	la $a0, str2    # imprime voici le tab de mot
    	li $v0, 4
    	syscall
    
    	jal	decMots		#decoupe le buffer
    
    	move	$a0, $v0
    	move	$a1, $v1
    	move	$s6, $v0
    	move	$s7, $v1
    
    	jal afficher	#affiche le buffer
    
    	la $a0, str3    	# imprime buffer dec
    	li $v0, 4
    	syscall
    
    	move	$a0, $s6
    	move	$a1, $s7
    
    	jal trier		#tri
    
    	move	$a0, $s6
    	move	$a1, $s7
    
    	jal afficher	#idem mais trie

    	li $v0, 10      	# end program
    	syscall
    
saisir:
    li $v0, 8       # prend input

    la $a0, buffer  # load byte space
    li $a1, 300     # et grosseur

    syscall
    la    $t2, buffer
    j	checkN
    
checkN:			#check si la seule chose entree est \n
    lbu	$t1, ($t2)
    addi $t2, $t2, 1
    beq $t1, '\n', saisirDone	#si oui: on a enter,enter: fin de saisir
    j saisirDecal		#si non: incrementer l'addresse
    
saisirDecal:			#increment l'adresse jusqu'a la prochaine position
    lbu	$t1, ($t2)		#d'entree
    addi $t2, $t2, 1
    beq $t1, '\n', saisirNEXT	#lorsqu'on trouve fin du user input, prendre prochain input
    j	saisirDecal
    
saisirNEXT:
    li $v0, 8       # prend user input

    add $a0, $t2, $0  # load byte space
    li $a1, 300      # et grosseur

    syscall
    j	checkN		#check la g
    
saisirDone:		#fin de l'entree du user
    jr	$ra
    
lettre:
    add $t0, $0, 65	#valeurs ascii a verifier
    add $t1, $0, 91
    add $t2, $0, 97
    add $t3, $0, 122
    add $t4, $0, 1
    add $t5, $0, 0

    slt $t6, $a0, $t0   #t6 == 1 si char < 65
    beq $t6, $t4, lettreFalse
    slt $t6, $a0, $t3   #t6 == 0 si char >= 122
    beq $t6, $t5, lettreFalse

    #On sait: 65<=char<=122
    slt $t6, $a0, $t2   #t6 == 0 si char >= 97: 97<=char<=122
    beq $t6, $t5, lettreTrue

    slt $t6, $a0, $t1   #t1 == 1 si char < 91 aka char<=90
    beq $t6, $t4, lettreTrue

lettreFalse:
    addi $v0, $0, 0
    jr $ra		#retourne false

lettreTrue:
    addi $v0, $0, 1	#retourne true
    jr $ra

decMots:
    #$a0 == addr buffer texte, $a1 == int taille texte
    la	$s0, buffer		 #Contient l'adresse du buffer
    lbu  $t1, ($s0)    #t1: char
    addi $t2, $0, 0     #t2: counter grosseur texte
    addi $t3, $0, 0     #t3: 0
    addi $t4, $0, 1     #t4: 1
    addi $s5, $0, 0     #counter du while
    add	 $s6, $0, $a1
    add	$s7, $0, $ra
    la $s2, tabMot		 #Contient l'adresse du tabMot
    addi $s3, $0, 0     #\0
    addi $s4, $0, 0		#Taille de tabMot
    
    j decMotsWhile		#Loop du decMot

decMotsWhile:
    slt $t9, $s6, $s5	#Condition de fin du DecMot
    beq $t9, 1, decMotsDone
    addi $a0, $t1, 0	#Entre le char comme argument pour lettre
    jal lettre			#V?rifie que $a0 est une lettre
    addi	$s5, $s5, 1		#On incr?mente le compteur du while
    beq $v0, 1, saveMot	#Si vraie alors sauver l'adresse du char du String dans tabMot
    addi $s0, $s0, 1			#Sinon on incr?mente l'adresse de buffer de 1 pour passer au prochain char
    lbu $t1, ($s0)			#On load le prochain char
    j decMotsWhile			#On recommence le loop

saveMot:
	sw $s0, 0($s2)			#Sauvegarde l'adresse actuelle du char dans l'index actuelle de tabMot
	addi $s2, $s2, 4		#Incr?mente l'adresse de tabMot
    addi $s4, $s4, 1		#Incr?mente la taille de tabMot
    j nextNotChar			#On cherche le prochain char qui n'est pas une lettre

nextNotChar:
    addi $s0, $s0, 1		#On passe au prochain char
    lbu $t1, ($s0)			#On load le prochain char
    addi $a0, $t1, 0		#On entre en argument le prochain char
    jal lettre				#On v?rifie si le prochain char est une lettre
    addi	$s5, $s5, 1		#On incr?mente le compteur du while
    beq $v0, 0, replaceNotChar	#Si faux, on remplace le char par \0
    j nextNotChar			#Si vrai, on recommence

replaceNotChar:
    sb $s3, 0($s0)			#On modifie le char dans le String ? \0
    addi $s0, $s0, 1		#Sinon on incr?mente l'adresse de buffer de 1 pour passer au prochain char
    lbu $t1, ($s0)			#On load le prochain char
    j decMotsWhile			#On revient au loop original

decMotsDone:
    la $v0, tabMot			#On renvoie l'adresse de d?but du tabMot
    addi $v1, $s4, -1		#On renvoie la taille de tabMot
    add	$ra, $0, $s7
    jr $ra			
    
afficher:
	move	$s1, $a0	#tabMot contenant les r?f?rences des adresses des charact?res dans le buffer (le string)
	move	$t1, $a1	#Taille de tabMot
	addi	$t2, $0, 0	#Counter du loop1
	addi	$t3, $0, 0	#Bool?an permettant de sortir de l'affichage
	slt 	$t3, $t2, $t1 # i < taille tabMot?
	beq 	$t3, $0, done # if not then done
	j	loop1

loop1:
	lw $t9, 0($s1)		#Donne la valeur de l'adresse contenue dans l'index 0 de tabMot ($t9 repr?sente le pointeur dans le buffer)
	j	decWord

back:
	addi $a0, $0, 32	#Imprime un espace entre chaque mot
	li $v0, 11
	syscall 
	
	addi	$t2, $t2, 1	#Incr?mente le compteur
	addi	$s1, $s1, 4	#Passe au prochain index de tabMot
	slt $t3, $t2, $t1 # i < taille tabMot?
	beq $t3, $0, done # if not then done
	j loop1
	
decWord:
	add $t7, $t9, $0	#$t7 est une variable temporaire, car on doit conserver $t9 pour l'incr?menter
	lbu	$t8, 0($t7)		#Lit le char au pointeur $t7($t9)
	beq	$t8, '\0', return	#Si le char==\0, on a finit le String	
	addi $t9, $t9, 1	#Incr?menter le pointeur vers le prochain char
	
	
	add $a0, $0, $t8	#Imprime le char ?tudi?
	li $v0, 11
	syscall
	
	j decWord			#On continue de lire char par char tant qu'on ne trouve pas de \0
	
return:
	j back				#Ram?ne dans le loop principal pour recommencer avec un nouveau mot

done:
	jr $ra				#Fin de l'affichage, retour ? main
	
strCmp:
    #$a0 == string1 $a1 == string2
    #https://stackoverflow.com/questions/32819645/printing-the-x-char-in-a-string-mips

    
    la $t8, ($a0)  #t1: char du string 1
    lbu  $t1,($t8)
    la $t9, ($a1)	 #t2: char du string 2
    lbu  $t2,($t9)
	
    beq $t1, $zero, firstTrueStrCmp     #si char1 == null: str1 < str2
    beq $t2, $zero, firstFalseStrCmp    #sinon, et si char2 == null: str2 < str1

    beq $t1, $t2, nextStrCmp    #si t1 == t2, on regarde prochain char (voir nextStrCmp)
    slt $t3, $t1, $t2   #t3 == 1 si char1 < char2
    add $v0, $0, $t3    #v0 prend t3, le resultat de la comparaison	
    
    jr $ra              #retourne le resultat

nextStrCmp: #https://www.daniweb.com/programming/software-development/threads/510199/mips-how-to-remove-the-first-character-of-a-string
	
    add $a0, $a0, 1    #on passe au prochain byte du string
    add $a1, $a1, 1    #idem
    j strCmp          #on rappelle strCmp sur les prochains chars

firstTrueStrCmp:        #si char1 est null, str1 < str2
    addi $v0, $0, 1
    jr $ra              #retourne true

firstFalseStrCmp:       #si char 1 =/= null et char2 == null
    addi $v0, $0, 0
    jr $ra              #retourne false

trier:  #(tabmots, taille)
	move	$s2, $a0	#tabMot contenant les r?f?rences des adresses des charact?res dans le buffer (le string)
	move	$s3, $a1	#Taille de tabMot
	addi	$t0, $0, 0	#counter de subTri
	addi	$t5, $0, 1	#test si il y a eu un swap
	move	$s5, $ra	#sauve $ra
	j 	triMain
	
triMain:
	beq	$t5, 0, triDone	#t5 == 0 ssi on a pas fait de swap
	move	$s4, $s2	#temp pour s2
	addi	$t0, $0, 0	#reset le t0 que subTri utilise
	addi	$t5, $0, 0	#reset le t5 pour prochaine passe de subTri
	j	subTri

subTri:
	addi	$t0, $t0, 1	#incremente
	beq	$t0, $s3, triMain	#si passe finie: retourne a main
	lw	$t6, 0($s4)	#t6: mot 1
	lw	$t7, 4($s4)	#t7: mot 2
	
	move	$a0, $t6	#pour appel a strCmp
	move	$a1, $t7
	
	jal	strCmp
	beq	$v0, 0, changeMin	#si strCmp == 0: mot1 > mot2: on swap
	
	addi	$s4, $s4, 4	#sinon, on passe au prochain mot
	j	subTri
	
changeMin:	#on doit echanger t6 et t7 (mot1 et mot2)
	sw	$t6, 4($s4)	#bubble sort, donc on ne compare que deux elements colles
	sw	$t7, 0($s4)	#donc, on peut simplement echanger avec 0 et 4(s4)
	addi	$s4, $s4, 4	#passe prochain mot pour retourner a subtri
	addi	$t5, $0, 1	#increment le counter de subTri
	j	subTri
	
triDone:
	move $ra, $s5		#reprends le $ra
	jr	$ra		#retour
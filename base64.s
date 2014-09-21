### Base 64 ###

#------- Segmento de datos ---------#
	.data	
_ncd : .asciiz "" # Encoded	
__tbl: .ascii "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P","Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z","a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p","q", "r", "s", "t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9","+",""
_txt : .asciiz "Man" # Text



#------- Segmento de código ---------#
	.text
    	.globl __start	
		
__start: jal __setEncoded
		 li $v0,10
		 syscall
		 .end

__setEncoded: la $t0,_txt		# Load buffer addr
			  la $t1,_ncd 	    # Load text addr
			  la $s0,__tbl      # Load const table
			  li $s1,0			# _ncd offset
			  li $t2,0x0	    # Base
			  li $v0,3
			  li $a1,0
			  
			  ## Coger bloques 3 en 3 en $t2 ##
loop:		  lb $a0,0($t0)     # Se coje el actual caracter del texto a cifrar
			  addiu $t0,$t0,1   # Se incrementa el puntero al texto
			  or $t2,$t2,$a0    # Se hace la or Base | caracter 
			  sll $t2,$t2,8     # Se desplaza a la izquierda -> Base << 8
			  addiu $a1,$a1,1	# Se avanza el puntero al texto
              div $a1,$v0		# Dividir contador / 3
			  mfhi $a2			# Cargar módulo
			  beqz $a2,__encode # Si tenemos un bloque de 3 en el reg (32 bits) , aplicar máscara, sacar de la tabla y guardar en memoria (_ncd)
			  j endloop
			  
			  
__encode:     li $s2,0x00FC0000
			  and $t3,$t2,$s2         # Se parte del registro base, 00000000 char1 char2 char3, se hace la and con la máscara variando cada vez (>>6), con ese valor p se hace lb $reg,p(__tbl) y se guarda en _ncd	  
			  srl $t3,$t3,16          # 00000000 00char1 00000000 00000000 -> se desplaza 16 bits a la derecha 0 0 0 00char1
			  add $s3,$t1,$s1         # dir auxiliar = dir _ncd + offset
			  # Guardar $t3 en _ncd   #
			  addiu $s1,$s1,1
			  # Cargar de la tabla constante el valor con offset $t3 #
			  sb $t3,0($s3)			  # Guardar byte en _ncd	  
			  move $a3,$t3
			  jal printchar
			  # Coger del registro base con mask $s2 >> 6
			  srl $s2,$s2,6
			  and $t3,$t2,$s2
			  srl $t3,$t3,8           # Desplazar el valor >> 8 (00000000 00000000 00char2 00000000) 0 0 0 00char2
			  # Guardar $t3 en _ncd   #
			  add $s3,$t1,$s1         # dir auxiliar = dir _ncd + offset
			  addiu $s1,$s1,1
			  # Cargar de la tabla constante el valor con offset $t3 #
			  sb $t3,0($s3)			  # Guardar byte en _ncd	
			  move $a3,$t3
			  jal printchar
			  
			  # Coger del registro base con mask $s2 >> 6
			  srl $s2,$s2,6
			  and $t3,$t2,$s2
			  srl $t3,$t3,8           # Desplazar el valor >> 8 (00000000 00000000 00char2 00000000) 0 0 0 00char2
			  # Guardar $t3 en _ncd   #
			  add $s3,$t1,$s1         # dir auxiliar = dir _ncd + offset
			  addiu $s1,$s1,1
			  # Cargar de la tabla constante el valor con offset $t3 #
			  sb $t3,0($s3)			  # Guardar byte en _ncd	
			  move $a3,$t3
			  jal printchar
			  
			  li $t2,0x0			  # Reset Base
endloop:	  bnez $a0,loop
			  jr $ra
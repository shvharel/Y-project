IDEAL
		; programer name :   base.asm by yossi
MODEL small
STACK 100h
DATASEG
	  name1 db "-----"
	  name2 db "*****"
	  

CODESEG
    
start: 
	mov ax, @data
	mov ds,ax
	mov ax,55h
	mov bx,67h
	xor ax,bx
	 
	 
	; Here is Main 
    	
	
	
	
		
exit:
	mov ax, 4c00h
	int 21h

END start


 
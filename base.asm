IDEAL
MODEL small
STACK 100h



SCREEN_WIDTH = 320 
SMALL_BMP_HEIGHT = 40
SMALL_BMP_WIDTH = 40
FILE_NAME_IN equ 'CBG1.bmp'

BOAT1_COLS = 65
BOAT1_ROWS = 39

BOAT2_COLS = 69
BOAT2_ROWS = 48

BOAT3_COLS = 79
BOAT3_ROWS = 49

PARACHUTE1_COLS = 32
PARACHUTE1_ROWS = 31

PARACHUTE2_COLS = 25
PARACHUTE2_ROWS = 41

PARACHUTE3_COLS = 35
PARACHUTE3_ROWS = 33

PARACHUTE4_COLS = 35
PARACHUTE4_ROWS = 33

DROWN_COLS = 45
DROWN_ROWS = 23
DATASEG
	
	ScrLine db SCREEN_WIDTH dup (0)  ; One Color line read buffer

	;BMP File data
	FileName 	db FILE_NAME_IN ,0
	
	FirstBoatShadow db BOAT1_COLS * BOAT1_ROWS dup('A')
	SecondBoatShadow db BOAT2_COLS * BOAT2_ROWS dup('A')
	ThirdBoatShadow db BOAT3_COLS * BOAT3_ROWS dup('A')
	FirstParachuteShadow db PARACHUTE1_COLS * PARACHUTE1_ROWS dup ('A')
	SecondParachuteShadow db PARACHUTE2_COLS * PARACHUTE2_ROWS dup ('A')
	ThirdParachuteShadow db PARACHUTE3_COLS * PARACHUTE3_ROWS dup ('A')
	FourthParachuteShadow db PARACHUTE4_COLS * PARACHUTE4_ROWS dup ('A')
	DrownShadow db DROWN_COLS * DROWN_ROWS dup ('A')
 
	FileHandle	dw ?
	Header 	    db 54 dup(0)
	Palette 	db 400h dup (0)
	
	SmallPicName db 'Route1.1.bmp' ,0
	
	RLeft dw 0
	RTop dw 0
	RWidth dw 150
	RHeight dw 130
	
	
	Slow dw 1100
	Mid db 200
	fast db 100
	
	lives db 3
	Points db ?
	
	Firstcnt dw 0
	Secondcnt dw 0
	Thirdcnt dw 0
	
	BmpLeft dw ?
	BmpTop dw ?
	BmpWidth dw 320
	BmpHeight dw 200
	
	BoatCurrent dw 27
	BoatLeftMaxY dw 27
	BoatRightMaxY dw 170
	
	FirstBoat db 'Boat111.bmp' ,0
	FirstBoatLeft dw 27
	FirstBoatTop dw 114
	
	SecondBoat db 'Boat22.bmp' ,0
	SecondBoatLeft dw 98
	SecondBoatTop dw 110
	
	ThirdBoat db 'Boat3.bmp' ,0
	ThirdBoatLeft dw  170
	ThirdBoatTop dw 109
	
	Helicopter db 'Choppa2.bmp' ,0
	
	FirstParachute db 'GlideOne.bmp' ,0
	SecondParachute db 'Glider.bmp' ,0
	ThirdParachute db 'TG.bmp' ,0
	FourthParachute db 'FG.bmp' ,0
	Drown db 'DP.bmp' ,0
	Open db 'Opening.bmp' ,0
	
	FirstParachute1Left dw 190
	FirstParachute1Top dw 0
	
	FirstParachute2Left dw 205
	FirstParachute2Top dw 21
	
	FirstParachute3Left dw 225
	FirstParachute3Top dw 43
	
	SecondParachute1Left dw 170
	SecondParachute1Top dw 10
	
	SecondParachute2Left dw 185
	SecondParachute2Top dw 43
	
	SecondParachute3Left dw 208
	SecondParachute3Top dw 70
	
	ThirdParachute1Left dw 133
	ThirdParachute1Top dw 30
	
	ThirdParachute2Left dw 77
	ThirdParachute2Top dw 80
	
	ThirdParachute3Left dw 150
	ThirdParachute3Top dw 76
	
	FourthParachute1Left dw 106
	FourthParachute1Top dw 51
	
	FourthParachute2Left dw 59
	FourthParachute2Top dw 110
	
	FourthParachute3Left dw 130
	FourthParachute3Top dw 110
	
	FourthParachute4Left dw 203
	FourthParachute4Top dw 110
	
	DrownLeft dw 45
	DrownTop dw 152
	
	DrownLeft2 dw 115
	DrownTop2 dw 152
	
	DrownLeft3 dw 188
	DrownTop3 dw 152

CODESEG
    
start: 
	mov ax, @data
	mov ds,ax
	
	call SetGraphic
	
	mov dx, offset Open
	mov [BmpLeft],0
	mov [BmpTop],0
	
	call OpenShowBmp
	
@@Wait:
	call CheckAndReadKey
	jz @@NotPress
	cmp ah, 1ch
	jz @@StartGame
	
@@NotPress:	
	jmp @@Wait
@@StartGame:	
	
	mov [lives], 3
	mov [Points], 0
	
	mov dx, offset FileName
	mov [BmpLeft],0
	mov [BmpTop],0
	
	call OpenShowBmp
	
	
	mov [BmpLeft], 220
	mov [BmpTop], 0
	mov [BmpWidth], 100
	mov [BmpHeight], 70
	mov dx, offset Helicopter
	
	call OpenShowBmpBee
	
	call PutFirstBoatOnScreen


@@MainLoop:	
	cmp [lives], 0
	jle exit
	call CheckAndReadKey
	jz @@NoKeyPressed
	cmp ah,4bh
	jnz @@RightPressed
	
@@LeftPressed:
	call MoveLeft
	jmp @@NoKeyPressed
@@RightPressed:
	cmp ah,4dh
	jnz @@NoKeyPressed
	call MoveRight
	
@@NoKeyPressed:	  

	call FirstRoute
	call SecondRoute
	call ThirdRoute
	jmp @@MainLoop
	
	
		
exit:

	mov ah,0
	int 16h
	
	mov ax,2
	int 10h
	
	mov ax, 4c00h
	int 21h



;proc closes the bmp file
proc CloseBmpFile near
	mov ah,3Eh
	mov bx, [FileHandle]
	int 21h
	ret
endp CloseBmpFile


;proc opens the bmp file
proc OpenBmpFile	near						 
	mov ah, 3Dh
	xor al, al
	int 21h
	mov [FileHandle], ax
	jmp @@ExitProc
@@ExitProc:	
	ret
endp OpenBmpFile

;proc put together all of the procs to show bmp on screen
proc OpenShowBmp near
	call OpenBmpFile
	
	call ReadBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call ShowBMP
	
	call CloseBmpFile

@@ExitProc:
	ret
endp OpenShowBmp

;proc put together all of the procs to show bmp on screen without white background
proc OpenShowBmpBee near
	call OpenBmpFile
	
	call ReadBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call ShowBMPBee
	
	call CloseBmpFile

@@ExitProc:
	ret
endp OpenShowBmpBee

;proc reads the bmp header
proc ReadBmpHeader	near					
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadBmpHeader

;proc reads the bmp palette
proc ReadBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
						 ; 4 bytes for each color BGR + null)			
	push cx
	push dx
	
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	
	pop dx
	pop cx
	
	ret
endp ReadBmpPalette
	
;proc copies the palette to the DS
proc CopyBmpPalette		near					
										
	push cx
	push dx
	
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0  ; black first							
	out dx,al ;3C8h
	inc dx	  ;3C9h
CopyNextColor:
	mov al,[si+2] 		; Red				
	shr al,2 			; divide by 4 Max (cos max is 63 and we have here max 255 ) (loosing color resolution).				
	out dx,al 						
	mov al,[si+1] 		; Green.				
	shr al,2            
	out dx,al 							
	mov al,[si] 		; Blue.				
	shr al,2            
	out dx,al 							
	add si,4 			; Point to next color.  (4 bytes for each color BGR + null)				
								
	loop CopyNextColor
	
	pop dx
	pop cx
	
	ret
endp CopyBmpPalette


;proc draws the bmp without the white background
proc ShowBMPBee
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
	push cx
	
	mov ax, 0A000h
	mov es, ax
	
	mov cx,[BmpHeight]
	
 
	mov ax,[BmpWidth] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	xor dx,dx
	mov si,4
	div si
	cmp dx,0
	mov bp,0
	jz @@row_ok
	mov bp,4
	sub bp,dx
	cld ; Clear direction flag, for movsb
	
@@row_ok:	
	mov dx,[BmpLeft]
	
@@NextLine:
	push cx
	push dx
	
	mov di,cx  ; Current Row at the small bmp (each time -1)
	add di,[BmpTop] ; add the Y on entire screen
	
 
	; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
	mov cx,di
	shl cx,6
	shl di,8
	add di,cx
	add di,dx
	 
	; small Read one line
	mov ah,3fh
	mov cx,[BmpWidth]  
	add cx,bp  ; extra  bytes to each row must be divided by 4
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory
	
	mov cx,[BmpWidth]  
	mov si,offset ScrLine
	
@@nextp:
	mov al,[si]
	cmp al,0ffh ; yellow
	jz @@skip
	mov [es:di],al
@@skip:
	inc di
	inc si
	loop @@nextp
	;rep movsb ; Copy line to the screen
	
	pop dx
	pop cx
	 
	loop @@NextLine
	
	pop cx
	ret
endp ShowBMPBee

;proc draws the bmp
proc ShowBMP
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpHeight lines in VGA format),
; displaying the lines from bottom to top.
	push cx
	
	mov ax, 0A000h
	mov es, ax
	
 
	mov ax,[BmpWidth] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	mov bp, 0
	and ax, 3
	jz @@row_ok
	mov bp,4
	sub bp,ax

@@row_ok:	
	mov cx,[BmpHeight]
    dec cx
	add cx,[BmpTop] ; add the Y on entire screen
	; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
	mov di,cx
	shl cx,6
	shl di,8
	add di,cx
	add di,[BmpLeft]
	cld ; Clear direction flag, for movsb forward
	
	mov cx, [BmpHeight]
@@NextLine:
	push cx
 
	; small Read one line
	mov ah,3fh
	mov cx,[BmpWidth]  
	add cx,bp  ; extra  bytes to each row must be divided by 4
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory es:di
	
	mov cx,[BmpWidth]  
	mov si,offset ScrLine
	rep movsb ; Copy line to the screen
	sub di,[BmpWidth]            ; return to left bmp
	sub di,SCREEN_WIDTH  ; jump one screen line up
	pop cx
	loop @@NextLine
	
	pop cx
	ret
endp ShowBMP
	
proc ShowBMPOnlyWhite
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpHeight lines in VGA format),
; displaying the lines from bottom to top.
	push cx
	
	mov ax, 0A000h
	mov es, ax
	
 
	mov ax,[BmpWidth] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	mov bp, 0
	and ax, 3
	jz @@row_ok
	mov bp,4
	sub bp,ax

@@row_ok:	
	mov cx,[BmpHeight]
    dec cx
	add cx,[BmpTop] ; add the Y on entire screen
	; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
	mov di,cx
	shl cx,6
	shl di,8
	add di,cx
	add di,[BmpLeft]
	cld ; Clear direction flag, for movsb forward
	
	mov cx, [BmpHeight]
@@NextLine:
	push cx
 
	; small Read one line
	mov ah,3fh
	mov cx,[BmpWidth]  
	add cx,bp  ; extra  bytes to each row must be divided by 4
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory es:di
	
	mov cx,[BmpWidth]
	mov si,offset ScrLine
@@Loops:
	cmp [byte ptr si], 0ffh
	je @@Equal
	movsb	; Copy line to the screen
@@Equal:
	inc di
	inc si
	loop @@Loops
	sub di,[BmpWidth]            ; return to left bmp
	sub di,SCREEN_WIDTH  ; jump one screen line up
	pop cx
	loop @@NextLine
	
	pop cx
	ret
endp ShowBMPOnlyWhite
	
proc  SetGraphic
	mov ax,13h   ; 320 X 200 
				 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
	int 10h
	ret
endp 	SetGraphic


;all of proc are drawing the boat/parachutes on screen for a specific place
proc drawFirstBoat
	mov ax, [FirstBoatTop]
	mov [BmpTop], ax 
	mov ax, [FirstBoatLeft]
	mov [BmpLeft], ax 
	mov [BmpWidth], BOAT1_COLS
	mov [BmpHeight], BOAT1_ROWS
	mov dx, offset FirstBoat
	call OpenShowBmpBee
	ret
endp drawFirstBoat


proc drawSecondBoat
	mov ax, [SecondBoatTop]
	mov [BmpTop], ax 
	mov ax, [SecondBoatLeft]
	mov [BmpLeft], ax 
	mov [BmpWidth], BOAT2_COLS
	mov [BmpHeight], BOAT2_ROWS
	mov dx, offset SecondBoat
	call OpenShowBmpBee
	ret
endp drawSecondBoat


proc drawThirdBoat
	mov ax, [ThirdBoatTop]
	mov [BmpTop], ax 
	mov ax, [ThirdBoatLeft]
	mov [BmpLeft], ax 
	mov [BmpWidth], BOAT3_COLS
	mov [BmpHeight], BOAT3_ROWS
	mov dx, offset ThirdBoat
	call OpenShowBmpBee
	ret
endp drawThirdBoat

proc drawFirstParachute
	mov ax, [FirstParachute1Top]
	mov [BmpTop], ax 
	mov ax, [FirstParachute1Left]
	mov [BmpLeft], ax 
	mov [BmpWidth], PARACHUTE1_COLS
	mov [BmpHeight], PARACHUTE1_ROWS
	mov dx, offset FirstParachute
	call OpenShowBmpBee
	ret
endp drawFirstParachute

proc drawFirstParachute2
	mov ax, [FirstParachute2Top]
	mov [BmpTop], ax 
	mov ax, [FirstParachute2Left]
	mov [BmpLeft], ax 
	mov [BmpWidth], PARACHUTE1_COLS
	mov [BmpHeight], PARACHUTE1_ROWS
	mov dx, offset FirstParachute
	call OpenShowBmpBee
	ret
endp drawFirstParachute2

proc drawFirstParachute3
	mov ax, [FirstParachute3Top]
	mov [BmpTop], ax 
	mov ax, [FirstParachute3Left]
	mov [BmpLeft], ax 
	mov [BmpWidth], PARACHUTE1_COLS
	mov [BmpHeight], PARACHUTE1_ROWS
	mov dx, offset FirstParachute
	call OpenShowBmpBee
	ret
endp drawFirstParachute3

proc drawSecondParachute
	mov ax, [SecondParachute1Top]
	mov [BmpTop], ax 
	mov ax, [SecondParachute1Left]
	mov [BmpLeft], ax 
	mov [BmpWidth], PARACHUTE2_COLS
	mov [BmpHeight], PARACHUTE2_ROWS
	mov dx, offset SecondParachute
	call OpenShowBmpBee
	ret
endp drawSecondParachute

proc drawSecondParachute2
	mov ax, [SecondParachute2Top]
	mov [BmpTop], ax 
	mov ax, [SecondParachute2Left]
	mov [BmpLeft], ax 
	mov [BmpWidth], PARACHUTE2_COLS
	mov [BmpHeight], PARACHUTE2_ROWS
	mov dx, offset SecondParachute
	call OpenShowBmpBee
	ret
endp drawSecondParachute2

proc drawSecondParachute3
	mov ax, [SecondParachute3Top]
	mov [BmpTop], ax 
	mov ax, [SecondParachute3Left]
	mov [BmpLeft], ax 
	mov [BmpWidth], PARACHUTE2_COLS
	mov [BmpHeight], PARACHUTE2_ROWS
	mov dx, offset SecondParachute
	call OpenShowBmpBee
	ret
endp drawSecondParachute3

proc drawThirdParachute
	mov ax, [ThirdParachute1Top]
	mov [BmpTop], ax
	mov ax, [ThirdParachute1Left]
	mov [BmpLeft], ax 
	mov [BmpWidth], PARACHUTE3_COLS
	mov [BmpHeight], PARACHUTE3_ROWS
	mov dx, offset ThirdParachute
	call OpenShowBmpBee
	ret 
endp drawThirdParachute

proc drawThirdParachute2
	mov ax, [ThirdParachute2Top]
	mov [BmpTop], ax
	mov ax, [ThirdParachute2Left]
	mov [BmpLeft], ax 
	mov [BmpWidth], PARACHUTE3_COLS
	mov [BmpHeight], PARACHUTE3_ROWS
	mov dx, offset ThirdParachute
	call OpenShowBmpBee
	ret 
endp drawThirdParachute2

proc drawThirdParachute3
	mov ax, [ThirdParachute3Top]
	mov [BmpTop], ax
	mov ax, [ThirdParachute3Left]
	mov [BmpLeft], ax 
	mov [BmpWidth], PARACHUTE3_COLS
	mov [BmpHeight], PARACHUTE3_ROWS
	mov dx, offset ThirdParachute
	call OpenShowBmpBee
	ret 
endp drawThirdParachute3

proc drawFourthParachute
	mov ax, [FourthParachute1Top]
	mov [BmpTop], ax
	mov ax, [FourthParachute1Left]
	mov [BmpLeft], ax 
	mov [BmpWidth], PARACHUTE4_COLS
	mov [BmpHeight], PARACHUTE4_ROWS
	mov dx, offset FourthParachute
	call OpenShowBmpBee
	ret 
endp drawFourthParachute

proc drawFourthParachute1
	mov ax, [FourthParachute2Top]
	mov [BmpTop], ax
	mov ax, [FourthParachute2Left]
	mov [BmpLeft], ax 
	mov [BmpWidth], PARACHUTE4_COLS
	mov [BmpHeight], PARACHUTE4_ROWS
	mov dx, offset FourthParachute
	call OpenShowBmpBee
	ret 
endp drawFourthParachute1

proc drawFourthParachute2
	mov ax, [FourthParachute3Top]
	mov [BmpTop], ax
	mov ax, [FourthParachute3Left]
	mov [BmpLeft], ax 
	mov [BmpWidth], PARACHUTE4_COLS
	mov [BmpHeight], PARACHUTE4_ROWS
	mov dx, offset FourthParachute
	call OpenShowBmpBee
	ret 
endp drawFourthParachute2

proc drawFourthParachute3
	mov ax, [FourthParachute4Top]
	mov [BmpTop], ax
	mov ax, [FourthParachute4Left]
	mov [BmpLeft], ax 
	mov [BmpWidth], PARACHUTE4_COLS
	mov [BmpHeight], PARACHUTE4_ROWS
	mov dx, offset FourthParachute
	call OpenShowBmpBee
	ret 
endp drawFourthParachute3

proc drawDrown
	mov ax, [DrownTop]
	mov [BmpTop], ax
	mov ax, [DrownLeft]
	mov [BmpLeft], ax 
	mov [BmpWidth], DROWN_COLS
	mov [BmpHeight], DROWN_ROWS
	mov dx, offset Drown
	call OpenShowBmpBee
	ret 
endp drawDrown

proc drawDrown1
	mov ax, [DrownTop2]
	mov [BmpTop], ax
	mov ax, [DrownLeft2]
	mov [BmpLeft], ax 
	mov [BmpWidth], DROWN_COLS
	mov [BmpHeight], DROWN_ROWS
	mov dx, offset Drown
	call OpenShowBmpBee
	ret 
endp drawDrown1

proc drawDrown2
	mov ax, [DrownTop3]
	mov [BmpTop], ax
	mov ax, [DrownLeft3]
	mov [BmpLeft], ax 
	mov [BmpWidth], DROWN_COLS
	mov [BmpHeight], DROWN_ROWS
	mov dx, offset Drown
	call OpenShowBmpBee
	ret 
endp drawDrown2

;proc checks if a key was pressed
proc CheckAndReadKey
	  mov ah,1
	  int 16h
	  pushf
	  jz @@return 
	  mov ah ,0
	  int 16h

@@return:	
	  popf
	  ret
endp CheckAndReadKey

;proc copies the shadow of a specific place
; input : shadow, screen bg  ,height, len , direction 0 or 1
proc FromToShadow
	push bp
	mov bp, sp
	push ax
	push cx
	push dx
	push si
	push di
	 
	cld
	
	mov si, [bp +4] ;  shodow
	mov di, [bp +6] ; screen
	mov dx, [bp +10]   ; len
	mov cx, [bp +8] ; height
start1:	
	cmp [word bp +12],0
	jz @@toScreen

@@r:
	push cx
	mov cx, dx
@@c:
	mov al, [es:di]
	mov [si],al
	inc si
	inc di
	loop @@c
 	
	add di, 320 
	sub di, dx
	
	pop cx
	loop @@r
	
	jmp @@ret
	 
@@toScreen:
	 
@@r2:
	push cx
	mov cx, dx
	
	rep movsb
 	
	add di, 320 
	sub di, dx
	
	pop cx
	loop @@r2
	
@@ret:	
	 
	pop di
	pop si
	pop dx
	pop cx
	pop ax
	pop bp
	ret 10
endp FromToShadow

;all procs removes the boat/parachutes from screen
proc RemoveFirstBoatFromScreen
	push cx
	push dx
	push es
	mov [Firstcnt],0
	mov ax,0a000h
	mov es,ax
	
	mov ax,0
	push ax   ; from shadow to screen 
	
	mov ax, BOAT1_COLS
	push ax

	mov ax, BOAT1_ROWS
	push ax
	
	mov cx,[FirstBoatLeft]
	mov dx,[FirstBoatTop]
	call getXYonScreen  ; return ax
	push ax
	mov ax, offset FirstBoatShadow  
	push ax
	
	call FromToShadow 
	
	pop es
	pop dx
	pop cx
	ret
endp RemoveFirstBoatFromScreen

proc RemoveSecondBoatFromScreen
	push cx
	push dx
	push es
	mov [Secondcnt],0
	mov ax,0a000h
	mov es,ax
	
	mov ax,0
	push ax   ; from shadow to screen 
	
	mov ax, BOAT2_COLS
	push ax

	mov ax, BOAT2_ROWS
	push ax
	
	mov cx,[SecondBoatLeft]
	mov dx,[SecondBoatTop]
	call getXYonScreen  ; return ax
	push ax
	mov ax, offset SecondBoatShadow  
	push ax
	
	call FromToShadow 
	
	pop es
	pop dx
	pop cx
	ret
endp RemoveSecondBoatFromScreen

proc RemoveThirdBoatFromScreen
	push cx
	push dx
	push es
	mov [Thirdcnt],0
	mov ax,0a000h
	mov es,ax
	
	mov ax,0
	push ax   ; from shadow to screen 
	
	mov ax, BOAT3_COLS
	push ax

	mov ax, BOAT3_ROWS
	push ax
	
	mov cx,[ThirdBoatLeft]
	mov dx,[ThirdBoatTop]
	call getXYonScreen  ; return ax
	push ax
	mov ax, offset ThirdBoatShadow  
	push ax
	
	call FromToShadow 
	
	pop es
	pop dx
	pop cx
	ret
endp RemoveThirdBoatFromScreen

proc RemoveFirstParachuteFromScreen
	push cx
	push dx
	push es
	mov [Firstcnt],0
	mov ax,0a000h
	mov es,ax
	
	mov ax,0
	push ax   ; from shadow to screen 
	
	mov ax, PARACHUTE1_COLS
	push ax

	mov ax, PARACHUTE1_ROWS
	push ax
	
	mov cx,[FirstParachute1Left]
	mov dx,[FirstParachute1Top]
	call getXYonScreen  ; return ax
	push ax
	mov ax, offset FirstParachuteShadow
	push ax
	
	call FromToShadow 
	
	pop es
	pop dx
	pop cx
	ret
endp RemoveFirstParachuteFromScreen

proc RemoveFirstParachuteFromScreen1
	push cx
	push dx
	push es
	mov [Firstcnt],0
	mov ax,0a000h
	mov es,ax
	
	mov ax,0
	push ax   ; from shadow to screen 
	
	mov ax, PARACHUTE1_COLS
	push ax

	mov ax, PARACHUTE1_ROWS
	push ax
	
	mov cx,[FirstParachute2Left]
	mov dx,[FirstParachute2Top]
	call getXYonScreen  ; return ax
	push ax
	mov ax, offset FirstParachuteShadow
	push ax
	
	call FromToShadow 
	
	pop es
	pop dx
	pop cx
	ret
endp RemoveFirstParachuteFromScreen1

proc RemoveFirstParachuteFromScreen2
	push cx
	push dx
	push es
	mov [Firstcnt],0
	mov ax,0a000h
	mov es,ax
	
	mov ax,0
	push ax   ; from shadow to screen 
	
	mov ax, PARACHUTE1_COLS
	push ax

	mov ax, PARACHUTE1_ROWS
	push ax
	
	mov cx,[FirstParachute3Left]
	mov dx,[FirstParachute3Top]
	call getXYonScreen  ; return ax
	push ax
	mov ax, offset FirstParachuteShadow
	push ax
	
	call FromToShadow 
	
	pop es
	pop dx
	pop cx
	ret
endp RemoveFirstParachuteFromScreen2

proc RemoveSecondParachuteFromScreen
	push cx
	push dx
	push es
	mov [Firstcnt],0
	mov ax,0a000h
	mov es,ax
	
	mov ax,0
	push ax   ; from shadow to screen 
	
	mov ax, PARACHUTE2_COLS
	push ax

	mov ax, PARACHUTE2_ROWS
	push ax
	
	mov cx,[SecondParachute1Left]
	mov dx,[SecondParachute1Top]
	call getXYonScreen  ; return ax
	push ax
	mov ax, offset SecondParachuteShadow
	push ax
	
	call FromToShadow 
	
	pop es
	pop dx
	pop cx
	ret
endp RemoveSecondParachuteFromScreen

proc RemoveSecondParachuteFromScreen1
	push cx
	push dx
	push es
	mov [Firstcnt],0
	mov ax,0a000h
	mov es,ax
	
	mov ax,0
	push ax   ; from shadow to screen 
	
	mov ax, PARACHUTE2_COLS
	push ax

	mov ax, PARACHUTE2_ROWS
	push ax
	
	mov cx,[SecondParachute2Left]
	mov dx,[SecondParachute2Top]
	call getXYonScreen  ; return ax
	push ax
	mov ax, offset SecondParachuteShadow
	push ax
	
	call FromToShadow 
	
	pop es
	pop dx
	pop cx
	ret
endp RemoveSecondParachuteFromScreen1

proc RemoveSecondParachuteFromScreen2
	push cx
	push dx
	push es
	mov [Firstcnt],0
	mov ax,0a000h
	mov es,ax
	
	mov ax,0
	push ax   ; from shadow to screen 
	
	mov ax, PARACHUTE2_COLS
	push ax

	mov ax, PARACHUTE2_ROWS
	push ax
	
	mov cx,[SecondParachute3Left]
	mov dx,[SecondParachute3Top]
	call getXYonScreen  ; return ax
	push ax
	mov ax, offset SecondParachuteShadow
	push ax
	
	call FromToShadow 
	
	pop es
	pop dx
	pop cx
	ret
endp RemoveSecondParachuteFromScreen2

proc RemoveThirdParachuteFromScreen
	push cx
	push dx
	push es
	mov [Firstcnt],0
	mov ax,0a000h
	mov es,ax
	
	mov ax,0
	push ax   ; from shadow to screen 
	
	mov ax, PARACHUTE3_COLS
	push ax

	mov ax, PARACHUTE3_ROWS
	push ax
	
	mov cx,[ThirdParachute1Left]
	mov dx,[ThirdParachute1Top]
	call getXYonScreen  ; return ax
	push ax
	mov ax, offset ThirdParachuteShadow
	push ax
	
	call FromToShadow 
	
	pop es
	pop dx
	pop cx
	ret
endp RemoveThirdParachuteFromScreen

proc RemoveThirdParachuteFromScreen1
	push cx
	push dx
	push es
	mov [Firstcnt],0
	mov ax,0a000h
	mov es,ax
	
	mov ax,0
	push ax   ; from shadow to screen 
	
	mov ax, PARACHUTE3_COLS
	push ax

	mov ax, PARACHUTE3_ROWS
	push ax
	
	mov cx,[ThirdParachute2Left]
	mov dx,[ThirdParachute2Top]
	call getXYonScreen  ; return ax
	push ax
	mov ax, offset ThirdParachuteShadow
	push ax
	
	call FromToShadow 
	
	pop es
	pop dx
	pop cx
	ret
endp RemoveThirdParachuteFromScreen1

proc RemoveThirdParachuteFromScreen2
	push cx
	push dx
	push es
	mov [Firstcnt],0
	mov ax,0a000h
	mov es,ax
	
	mov ax,0
	push ax   ; from shadow to screen 
	
	mov ax, PARACHUTE3_COLS
	push ax

	mov ax, PARACHUTE3_ROWS
	push ax
	
	mov cx,[ThirdParachute3Left]
	mov dx,[ThirdParachute3Top]
	call getXYonScreen  ; return ax
	push ax
	mov ax, offset ThirdParachuteShadow
	push ax
	
	call FromToShadow 
	
	pop es
	pop dx
	pop cx
	ret
endp RemoveThirdParachuteFromScreen2

proc RemoveFourthParachuteFromScreen
	push cx
	push dx
	push es
	mov [Firstcnt],0
	mov ax,0a000h
	mov es,ax
	
	mov ax,0
	push ax   ; from shadow to screen 
	
	mov ax, PARACHUTE4_COLS
	push ax

	mov ax, PARACHUTE4_ROWS
	push ax
	
	mov cx,[FourthParachute1Left]
	mov dx,[FourthParachute1Top]
	call getXYonScreen  ; return ax
	push ax
	mov ax, offset FourthParachuteShadow
	push ax
	
	call FromToShadow 
	
	pop es
	pop dx
	pop cx
	ret
endp RemoveFourthParachuteFromScreen

proc RemoveFourthParachuteFromScreen1
	push cx
	push dx
	push es
	mov [Firstcnt],0
	mov ax,0a000h
	mov es,ax
	
	mov ax,0
	push ax   ; from shadow to screen 
	
	mov ax, PARACHUTE4_COLS
	push ax

	mov ax, PARACHUTE4_ROWS
	push ax
	
	mov cx,[FourthParachute2Left]
	mov dx,[FourthParachute2Top]
	call getXYonScreen  ; return ax
	push ax
	mov ax, offset FourthParachuteShadow
	push ax
	
	call FromToShadow 
	
	pop es
	pop dx
	pop cx
	ret
endp RemoveFourthParachuteFromScreen1

proc RemoveFourthParachuteFromScreen2
	push cx
	push dx
	push es
	mov [Firstcnt],0
	mov ax,0a000h
	mov es,ax
	
	mov ax,0
	push ax   ; from shadow to screen 
	
	mov ax, PARACHUTE4_COLS
	push ax

	mov ax, PARACHUTE4_ROWS
	push ax
	
	mov cx,[FourthParachute3Left]
	mov dx,[FourthParachute3Top]
	call getXYonScreen  ; return ax
	push ax
	mov ax, offset FourthParachuteShadow
	push ax
	
	call FromToShadow 
	
	pop es
	pop dx
	pop cx
	ret
endp RemoveFourthParachuteFromScreen2

proc RemoveFourthParachuteFromScreen3
	push cx
	push dx
	push es
	mov [Firstcnt],0
	mov ax,0a000h
	mov es,ax
	
	mov ax,0
	push ax   ; from shadow to screen 
	
	mov ax, PARACHUTE4_COLS
	push ax

	mov ax, PARACHUTE4_ROWS
	push ax
	
	mov cx,[FourthParachute4Left]
	mov dx,[FourthParachute4Top]
	call getXYonScreen  ; return ax
	push ax
	mov ax, offset FourthParachuteShadow
	push ax
	
	call FromToShadow 
	
	pop es
	pop dx
	pop cx
	ret
endp RemoveFourthParachuteFromScreen3

proc RemoveDrownFromScreen
	push cx
	push dx
	push es
	mov [Firstcnt],0
	mov ax,0a000h
	mov es,ax
	
	mov ax,0
	push ax   ; from shadow to screen 
	
	mov ax, DROWN_COLS
	push ax

	mov ax, DROWN_ROWS
	push ax
	
	mov cx,[DrownLeft]
	mov dx,[DrownTop]
	call getXYonScreen  ; return ax
	push ax
	mov ax, offset DrownShadow
	push ax
	
	call FromToShadow 
	
	pop es
	pop dx
	pop cx
	ret
endp RemoveDrownFromScreen

proc RemoveDrownFromScreen1
	push cx
	push dx
	push es
	mov [Firstcnt],0
	mov ax,0a000h
	mov es,ax
	
	mov ax,0
	push ax   ; from shadow to screen 
	
	mov ax, DROWN_COLS
	push ax

	mov ax, DROWN_ROWS
	push ax
	
	mov cx,[DrownLeft2]
	mov dx,[DrownTop2]
	call getXYonScreen  ; return ax
	push ax
	mov ax, offset DrownShadow
	push ax
	
	call FromToShadow 
	
	pop es
	pop dx
	pop cx
	ret
endp RemoveDrownFromScreen1

proc RemoveDrownFromScreen2
	push cx
	push dx
	push es
	mov [Firstcnt],0
	mov ax,0a000h
	mov es,ax
	
	mov ax,0
	push ax   ; from shadow to screen 
	
	mov ax, DROWN_COLS
	push ax

	mov ax, DROWN_ROWS
	push ax
	
	mov cx,[DrownLeft3]
	mov dx,[DrownTop3]
	call getXYonScreen  ; return ax
	push ax
	mov ax, offset DrownShadow
	push ax
	
	call FromToShadow 
	
	pop es
	pop dx
	pop cx
	ret
endp RemoveDrownFromScreen2

;all procs put the boats/parachutes on screen
proc PutFirstBoatOnScreen
	push cx
	push dx
	push es
	
	mov ax,0a000h
	mov es,ax
	mov [Firstcnt],0
	mov ax,1
	push ax   ; from screen to shadow
	mov cx,[FirstBoatLeft]
	mov dx,[FirstBoatTop]
	 
	 
	
	mov ax, BOAT1_COLS
	push ax
	mov ax, BOAT1_ROWS
	push ax
	
	call getXYonScreen  ; return ax
	push ax ; from screen 
	
	mov ax, offset FirstBoatShadow 
	push ax
	
	
	
	 
	call FromToShadow  
	 

	call drawFirstBoat
	
	pop es
	pop dx
	pop cx
	ret
endp PutFirstBoatOnScreen

proc PutSecondBoatOnScreen
	push cx
	push dx
	push es
	
	mov ax,0a000h
	mov es,ax
	mov [Secondcnt],0
	mov ax,1
	push ax   ; from screen to shadow
	mov cx,[SecondBoatLeft]
	mov dx,[SecondBoatTop]
	 
	 
	
	mov ax, BOAT2_COLS
	push ax
	mov ax, BOAT2_ROWS
	push ax
	
	call getXYonScreen  ; return ax
	push ax ; from screen 
	
	mov ax, offset SecondBoatShadow 
	push ax
	
	
	
	 
	call FromToShadow  
	 

	call drawSecondBoat
	
	pop es
	pop dx
	pop cx
	ret
endp PutSecondBoatOnScreen

proc PutThirdBoatOnScreen
	push cx
	push dx
	push es
	
	mov ax,0a000h
	mov es,ax
	mov [Thirdcnt],0
	mov ax,1
	push ax   ; from screen to shadow
	mov cx,[ThirdBoatLeft]
	mov dx,[ThirdBoatTop]
	 
	 
	
	mov ax, BOAT3_COLS
	push ax
	mov ax, BOAT3_ROWS
	push ax
	
	call getXYonScreen  ; return ax
	push ax ; from screen 
	
	mov ax, offset ThirdBoatShadow 
	push ax
	
	
	
	 
	call FromToShadow  
	 

	call drawThirdBoat
	
	pop es
	pop dx
	pop cx
	ret
endp PutThirdBoatOnScreen

proc PutFirstParachuteOnScreen
	push cx
	push dx
	push es
	
	mov ax,0a000h
	mov es,ax
	mov [Firstcnt],0
	mov ax,1
	push ax   ; from screen to shadow
	mov cx,[FirstParachute1Left]
	mov dx,[FirstParachute1Top]
	 
	 
	
	mov ax, PARACHUTE1_COLS
	push ax
	mov ax, PARACHUTE1_ROWS
	push ax
	
	call getXYonScreen  ; return ax
	push ax ; from screen 
	
	mov ax, offset FirstParachuteShadow 
	push ax
	
	
	
	 
	call FromToShadow  
	 

	call drawFirstParachute
	
	pop es
	pop dx
	pop cx
	ret
endp PutFirstParachuteOnScreen


proc PutFirstParachuteOnScreen1
	push cx
	push dx
	push es
	
	mov ax,0a000h
	mov es,ax
	mov [Firstcnt],0
	mov ax,1
	push ax   ; from screen to shadow
	mov cx,[FirstParachute2Left]
	mov dx,[FirstParachute2Top]
	 
	 
	
	mov ax, PARACHUTE1_COLS
	push ax
	mov ax, PARACHUTE1_ROWS
	push ax
	
	call getXYonScreen  ; return ax
	push ax ; from screen 
	
	mov ax, offset FirstParachuteShadow 
	push ax
	
	
	
	 
	call FromToShadow  
	 

	call drawFirstParachute2
	
	pop es
	pop dx
	pop cx
	ret
endp PutFirstParachuteOnScreen1

proc PutFirstParachuteOnScreen2
	push cx
	push dx
	push es
	
	mov ax,0a000h
	mov es,ax
	mov [Firstcnt],0
	mov ax,1
	push ax   ; from screen to shadow
	mov cx,[FirstParachute3Left]
	mov dx,[FirstParachute3Top]
	 
	 
	
	mov ax, PARACHUTE1_COLS
	push ax
	mov ax, PARACHUTE1_ROWS
	push ax
	
	call getXYonScreen  ; return ax
	push ax ; from screen 
	
	mov ax, offset FirstParachuteShadow 
	push ax
	
	
	
	 
	call FromToShadow  
	 

	call drawFirstParachute3
	
	pop es
	pop dx
	pop cx
	ret
endp PutFirstParachuteOnScreen2

proc PutSecondParachuteOnScreen
	push cx
	push dx
	push es
	
	mov ax,0a000h
	mov es,ax
	mov [Firstcnt],0
	mov ax,1
	push ax   ; from screen to shadow
	mov cx,[SecondParachute1Left]
	mov dx,[SecondParachute1Top]
	 
	 
	
	mov ax, PARACHUTE2_COLS
	push ax
	mov ax, PARACHUTE2_ROWS
	push ax
	
	call getXYonScreen  ; return ax
	push ax ; from screen 
	
	mov ax, offset SecondParachuteShadow 
	push ax
	
	
	
	 
	call FromToShadow  
	 

	call drawSecondParachute
	
	pop es
	pop dx
	pop cx
	ret
endp PutSecondParachuteOnScreen

proc PutSecondParachuteOnScreen1
	push cx
	push dx
	push es
	
	mov ax,0a000h
	mov es,ax
	mov [Firstcnt],0
	mov ax,1
	push ax   ; from screen to shadow
	mov cx,[SecondParachute2Left]
	mov dx,[SecondParachute2Top]
	 
	 
	
	mov ax, PARACHUTE2_COLS
	push ax
	mov ax, PARACHUTE2_ROWS
	push ax
	
	call getXYonScreen  ; return ax
	push ax ; from screen 
	
	mov ax, offset SecondParachuteShadow 
	push ax
	
	
	
	 
	call FromToShadow  
	 

	call drawSecondParachute2
	
	pop es
	pop dx
	pop cx
	ret
endp PutSecondParachuteOnScreen1

proc PutSecondParachuteOnScreen2
	push cx
	push dx
	push es
	
	mov ax,0a000h
	mov es,ax
	mov [Firstcnt],0
	mov ax,1
	push ax   ; from screen to shadow
	mov cx,[SecondParachute3Left]
	mov dx,[SecondParachute3Top]
	 
	 
	
	mov ax, PARACHUTE2_COLS
	push ax
	mov ax, PARACHUTE2_ROWS
	push ax
	
	call getXYonScreen  ; return ax
	push ax ; from screen 
	
	mov ax, offset SecondParachuteShadow 
	push ax
	
	
	
	 
	call FromToShadow  
	 

	call drawSecondParachute3
	
	pop es
	pop dx
	pop cx
	ret
endp PutSecondParachuteOnScreen2

proc PutThirdParachuteOnScreen
	push cx
	push dx
	push es
	
	mov ax,0a000h
	mov es,ax
	mov [Firstcnt],0
	mov ax,1
	push ax   ; from screen to shadow
	mov cx,[ThirdParachute1Left]
	mov dx,[ThirdParachute1Top]
	 
	 
	
	mov ax, PARACHUTE3_COLS
	push ax
	mov ax, PARACHUTE3_ROWS
	push ax
	
	call getXYonScreen  ; return ax
	push ax ; from screen 
	
	mov ax, offset ThirdParachuteShadow 
	push ax
	
	
	
	 
	call FromToShadow  
	 

	call drawThirdParachute
	
	pop es
	pop dx
	pop cx
	ret
endp PutThirdParachuteOnScreen

proc PutThirdParachuteOnScreen1
	push cx
	push dx
	push es
	
	mov ax,0a000h
	mov es,ax
	mov [Firstcnt],0
	mov ax,1
	push ax   ; from screen to shadow
	mov cx,[ThirdParachute2Left]
	mov dx,[ThirdParachute2Top]
	 
	 
	
	mov ax, PARACHUTE3_COLS
	push ax
	mov ax, PARACHUTE3_ROWS
	push ax
	
	call getXYonScreen  ; return ax
	push ax ; from screen 
	
	mov ax, offset ThirdParachuteShadow 
	push ax
	
	
	
	 
	call FromToShadow  
	 

	call drawThirdParachute2
	
	pop es
	pop dx
	pop cx
	ret
endp PutThirdParachuteOnScreen1

proc PutThirdParachuteOnScreen2
	push cx
	push dx
	push es
	
	mov ax,0a000h
	mov es,ax
	mov [Firstcnt],0
	mov ax,1
	push ax   ; from screen to shadow
	mov cx,[ThirdParachute3Left]
	mov dx,[ThirdParachute3Top]
	 
	 
	
	mov ax, PARACHUTE3_COLS
	push ax
	mov ax, PARACHUTE3_ROWS
	push ax
	
	call getXYonScreen  ; return ax
	push ax ; from screen 
	
	mov ax, offset ThirdParachuteShadow 
	push ax
	
	
	
	 
	call FromToShadow
	 

	call drawThirdParachute3
	
	pop es
	pop dx
	pop cx
	ret
endp PutThirdParachuteOnScreen2

proc PutFourthParachuteOnScreen
	push cx
	push dx
	push es
	
	mov ax,0a000h
	mov es,ax
	mov [Firstcnt],0
	mov ax,1
	push ax   ; from screen to shadow
	mov cx,[FourthParachute1Left]
	mov dx,[FourthParachute1Top]
	 
	 
	
	mov ax, PARACHUTE4_COLS
	push ax
	mov ax, PARACHUTE4_ROWS
	push ax
	
	call getXYonScreen  ; return ax
	push ax ; from screen 
	
	mov ax, offset FourthParachuteShadow 
	push ax
	
	
	
	 
	call FromToShadow
	 

	call drawFourthParachute
	
	pop es
	pop dx
	pop cx
	ret
endp PutFourthParachuteOnScreen

proc PutFourthParachuteOnScreen1
	push cx
	push dx
	push es
	
	mov ax,0a000h
	mov es,ax
	mov [Firstcnt],0
	mov ax,1
	push ax   ; from screen to shadow
	mov cx,[FourthParachute2Left]
	mov dx,[FourthParachute2Top]
	 
	 
	
	mov ax, PARACHUTE4_COLS
	push ax
	mov ax, PARACHUTE4_ROWS
	push ax
	
	call getXYonScreen  ; return ax
	push ax ; from screen 
	
	mov ax, offset FourthParachuteShadow 
	push ax
	
	
	
	 
	call FromToShadow
	 

	call drawFourthParachute1
	
	pop es
	pop dx
	pop cx
	ret
endp PutFourthParachuteOnScreen1

proc PutFourthParachuteOnScreen2
	push cx
	push dx
	push es
	
	mov ax,0a000h
	mov es,ax
	mov [Firstcnt],0
	mov ax,1
	push ax   ; from screen to shadow
	mov cx,[FourthParachute3Left]
	mov dx,[FourthParachute3Top]
	 
	 
	
	mov ax, PARACHUTE4_COLS
	push ax
	mov ax, PARACHUTE4_ROWS
	push ax
	
	call getXYonScreen  ; return ax
	push ax ; from screen 
	
	mov ax, offset FourthParachuteShadow 
	push ax
	
	
	
	 
	call FromToShadow
	 

	call drawFourthParachute2
	
	pop es
	pop dx
	pop cx
	ret
endp PutFourthParachuteOnScreen2

proc PutFourthParachuteOnScreen3
	push cx
	push dx
	push es
	
	mov ax,0a000h
	mov es,ax
	mov [Firstcnt],0
	mov ax,1
	push ax   ; from screen to shadow
	mov cx,[FourthParachute4Left]
	mov dx,[FourthParachute4Top]
	 
	 
	
	mov ax, PARACHUTE4_COLS
	push ax
	mov ax, PARACHUTE4_ROWS
	push ax
	
	call getXYonScreen  ; return ax
	push ax ; from screen 
	
	mov ax, offset FourthParachuteShadow 
	push ax
	
	
	
	 
	call FromToShadow
	 

	call drawFourthParachute3
	
	pop es
	pop dx
	pop cx
	ret
endp PutFourthParachuteOnScreen3

proc PutDrownOnScreen
	push cx
	push dx
	push es
	
	mov ax,0a000h
	mov es,ax
	mov [Firstcnt],0
	mov ax,1
	push ax   ; from screen to shadow
	mov cx,[DrownLeft]
	mov dx,[DrownTop]
	 
	 
	
	mov ax, DROWN_COLS
	push ax
	mov ax, DROWN_ROWS
	push ax
	
	call getXYonScreen  ; return ax
	push ax ; from screen 
	
	mov ax, offset DrownShadow 
	push ax
	
	
	
	 
	call FromToShadow
	 

	call drawDrown
	
	pop es
	pop dx
	pop cx
	ret
endp PutDrownOnScreen

proc PutDrownOnScreen1
	push cx
	push dx
	push es
	
	mov ax,0a000h
	mov es,ax
	mov [Firstcnt],0
	mov ax,1
	push ax   ; from screen to shadow
	mov cx,[DrownLeft2]
	mov dx,[DrownTop2]
	 
	 
	
	mov ax, DROWN_COLS
	push ax
	mov ax, DROWN_ROWS
	push ax
	
	call getXYonScreen  ; return ax
	push ax ; from screen 
	
	mov ax, offset DrownShadow 
	push ax
	
	
	
	 
	call FromToShadow
	 

	call drawDrown1
	
	pop es
	pop dx
	pop cx
	ret
endp PutDrownOnScreen1

proc PutDrownOnScreen2
	push cx
	push dx
	push es
	
	mov ax,0a000h
	mov es,ax
	mov [Firstcnt],0
	mov ax,1
	push ax   ; from screen to shadow
	mov cx,[DrownLeft3]
	mov dx,[DrownTop3]
	 
	 
	
	mov ax, DROWN_COLS
	push ax
	mov ax, DROWN_ROWS
	push ax
	
	call getXYonScreen  ; return ax
	push ax ; from screen 
	
	mov ax, offset DrownShadow 
	push ax
	
	
	
	 
	call FromToShadow
	 

	call drawDrown2
	
	pop es
	pop dx
	pop cx
	ret
endp PutDrownOnScreen2



;proc puts to ax x and y of a place
proc getXYonScreen
	mov ax,dx
	shl dx,8
	shl ax, 6
	add ax,dx
	add ax,cx
	ret
endp getXYonScreen

;proc moves the boat right
proc MoveRight
	push ax
	push bx
	mov ax, [BoatCurrent]
	mov bx, [BoatRightMaxY]
	cmp ax, bx
	je @@TheExit
	
@@OK:
	mov bx, [SecondBoatLeft]
	cmp ax, bx
	je @@Right
	call RemoveFirstBoatFromScreen
	call PutSecondBoatOnScreen
	mov bx, [SecondBoatLeft]
	mov [BoatCurrent], bx
	jmp @@TheExit
	
@@Right:
	call RemoveSecondBoatFromScreen
	call PutThirdBoatOnScreen
	mov bx, [BoatRightMaxY]
	mov [BoatCurrent], bx

@@TheExit:
	pop bx
	pop ax
	ret
endp MoveRight

;proc moves the boat left
proc MoveLeft
	push ax
	push bx
	mov ax, [BoatCurrent]
	mov bx, [BoatLeftMaxY]
	cmp ax, bx
	je @@TheExit
	
@@ITSOK:
	mov bx, [SecondBoatLeft]
	cmp ax, bx
	je @@ToLeft
	call RemoveThirdBoatFromScreen
	call PutSecondBoatOnScreen
	mov bx, [SecondBoatLeft]
	mov [BoatCurrent], bx
	jmp @@TheExit
	
@@ToLeft:
	call RemoveSecondBoatFromScreen
	call PutFirstBoatOnScreen
	mov bx, [BoatLeftMaxY]
	mov [BoatCurrent], bx

@@TheExit:
	pop bx
	pop ax
	ret
endp MoveLeft

;procs moves the parachutes of the first routes
proc FirstRoute
	call PutFirstParachuteOnScreen
	call PutDelay
	call RemoveFirstParachuteFromScreen
	call PutSecondParachuteOnScreen
	call PutDelay
	call RemoveSecondParachuteFromScreen
	call PutThirdParachuteOnScreen
	call PutDelay
	call RemoveThirdParachuteFromScreen
	call PutFourthParachuteOnScreen
	call PutDelay
	call RemoveFourthParachuteFromScreen
	call PutThirdParachuteOnScreen1
	call PutDelay
	call RemoveThirdParachuteFromScreen1
	call PutFourthParachuteOnScreen1
	call PutDelay
	call RemoveFourthParachuteFromScreen1
	mov ax, [BoatLeftMaxY]
	cmp ax, [BoatCurrent]
	je @@Good
	dec [lives]
	call PutDrownOnScreen
	call PutDelay
	call RemoveDrownFromScreen
	jmp @@Returns
@@Good:
	inc [Points]
	
@@Returns:
	ret
endp FirstRoute

;procs moves the parachutes of the second routes
proc SecondRoute
	call PutFirstParachuteOnScreen1
	call PutDelay
	call RemoveFirstParachuteFromScreen1
	call PutSecondParachuteOnScreen1
	call PutDelay
	call RemoveSecondParachuteFromScreen1
	call PutThirdParachuteOnScreen2
	call PutDelay
	call RemoveThirdParachuteFromScreen2
	call PutFourthParachuteOnScreen2
	call PutDelay
	call RemoveFourthParachuteFromScreen2
	mov ax, [SecondBoatLeft]
	cmp ax, [BoatCurrent]
	je @@Good
	dec [lives]
	call PutDrownOnScreen1
	call PutDelay
	call RemoveDrownFromScreen1
	jmp @@Returns
@@Good:
	inc [Points]
	
@@Returns:
	ret
endp SecondRoute

;procs moves the parachutes of the third routes
proc ThirdRoute
	call PutFirstParachuteOnScreen2
	call PutDelay
	call RemoveFirstParachuteFromScreen2
	call PutSecondParachuteOnScreen2
	call PutDelay
	call RemoveSecondParachuteFromScreen2
	call PutFourthParachuteOnScreen3
	call PutDelay
	call RemoveFourthParachuteFromScreen3
	mov ax, [BoatRightMaxY]
	cmp ax, [BoatCurrent]
	je @@Good
	dec [lives]
	call PutDrownOnScreen2
	call PutDelay
	call RemoveDrownFromScreen2
	jmp @@Returns
@@Good:
	inc [Points]
	
@@Returns:
	ret
endp ThirdRoute


;proc PutDelay
;	push bx
;	push cx
;	mov bx, [Slow]
;	mov cx, bx
;@@FirstOne:
;	push cx
;	mov cx, bx
;@@SecondOne:
;	loop @@SecondOne
;	pop cx
;	loop @@FirstOne
;	pop cx
;	pop bx
;	ret
;endp PutDelay

;proc checks if left/rgiht key was pressed
proc try
	call CheckAndReadKey
	jz @@NoKeyPressed
	cmp ah,4bh
	jnz @@RightPressed
	
@@LeftPressed:
	call MoveLeft
	jmp @@NoKeyPressed
@@RightPressed:
	cmp ah,4dh
	jnz @@NoKeyPressed
	call MoveRight
@@NoKeyPressed:	  
	ret
endp try

;proc puts delay on parachutes drop
proc PutDelay
	push bx
	push cx
	mov bx, [Slow]
	mov cx, bx
@@FirstOne:
	push cx
	mov cx, bx
@@SecondOne:
	loop @@SecondOne
	pop cx
	call try
	loop @@FirstOne
	pop cx
	pop bx
	ret
endp PutDelay

END start
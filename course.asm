text segment 'code'
	assume cs:text, ds:data 

delay proc 
	push cx
	push bx
	push bp
	push ax
	push dx
	mov cx, 9 
	zd:	
		push cx
		mov bp, 0
		mov bx, 1
		cikl1:
			inc bp
			mov ah, 00h
			int 1Ah
			cmp bp, 1
			je ii
			jmp ii1
		ii:
			add bx, dx
		ii1: 
			cmp bx, dx
			jne cikl1
			pop cx
	loop zd
	pop cx
	pop bx
	pop bp
	pop ax
	 pop dx
	ret
delay endp

pauuse proc
	mov bp,1
	mig:
		push cx
		push dx
		call color_changing
		call cube
		call delay 
		pop dx
		pop cx
		inc bp
		cmp bp,15
		je ex
		mov ah, 06h
		push dx
		mov dl, 0FFh
		int 21h
		cmp al, 0
		pop dx
		je mig
		jmp ex
	ex:
	ret
pauuse endp

color_back proc
	mov al, color_temp ; saving current color
	mov color, al ; saving current color
	ret
color_back endp

color_black proc
	mov al, color ; saving current color
	mov color_temp, al ; saving current color
	mov color, 0 ; color = black
	ret
color_black endp

color_changing proc
	inc color
	cmp color, 16
	jne f
	mov color, 1
	 f:
		mov al, color
		ret 
color_changing endp

cube proc
	mov al, color
	mov color_temp, al
	call cube_front ; else
	call color_changing ; return our color
	call cube_top ; draw
	call color_changing ; and 
	call cube_side ; draw cube 
	mov al, color_temp
	mov color, al
	ret
cube endp

cube_side proc
	push cx ; save X coordinate (top left corner of the front)
	push dx ; save Y coordinate (top left corner of the front)
	add cx, 50 ; set new X coordinate (bottom right corner of the front)
	add dx, 50 ; set new Y coordinate (bottom right corner of the front)
	mov si, 25 ; width of the side
	side_width:
		push dx ; save staring point's Y coordinate
		mov bl,51 ; length of the line
		side_line:		
			int 10h ; put pixel
			dec dx ; decrease Y coordinate
			dec bl ; decrese length
			cmp bl, 0 ; if not equal to zero 
		jne side_line ; repeat 
	cmp si, 0 ; else if draw full side than exit
	je side_exit ;than exit
	dec si ; else decrese width of the side
	pop dx ; load Y coordinate from stack
	dec dx ; decrease Y coordinate
	inc cx ; increase X coordinate
	jmp side_width ; start over 
	side_exit:
		pop dx ; extra stack value
		pop dx ;return Y coordinate (top left corner of the front)
		pop cx ;return X coordinate (top left corner of the front)
		ret
cube_side endp

cube_top proc
	mov si, 25 ; width of the top
	push dx ; save Y coordinate (top left corner of the front)
	dec dx ; decrese Y coordinate
	top_width:
		push cx ; save X coordinate (line's start point)
		mov bl,51 ; length of the line
		top_line:		
			int 10h ; put pixel
			inc cx ; increase X coordinate
			dec bl ; decrease line length
			cmp bl, 0 ; if line's length  not equal to zero
		jne top_line ; repeat
	cmp si, 0 ; if drew full top
	je top_exit ; than exit
	dec si ; else descrease top's width
	pop cx ; save X coordinate to the stack
	dec dx ; decrease Y coordinate
	inc cx ; increase X coordinate
	jmp top_width ; repeat 
	top_exit:
		pop cx ; load last X coordinate from the stack 
		add cx, -25 ; X coordinate (top left corner of the front)
		pop dx ; load Y coordinate (top left corner of the front)
		ret
cube_top endp

cube_front proc
	mov ah, 0ch ; function to pixel output
	mov bh, 0 ;videopage
	mov al, color ; set color
	mov si, 50 ; front's height
	push dx ; save Y coordinate to the stack (top left corner of the front)
	front_width:
		push cx ; save X coordinate to the stack
		mov bl,50 ; length of the front
		front_line:		 
			int 10h ; put pixel
			inc cx ; increase X coordinate
			dec bl ; decrese front's length
			cmp bl, 0 ; if front's length not equal to zero
		jne front_line ; that repeat drawing again
	cmp si, 0 ; else if front's height equal to zero
	je front_exit ; that exit
	dec si ; else decrease front's height
	pop cx ; save X coordinate to stack
	inc dx ; increase Y coordinate
	jmp front_width ; repeat drawing again
	front_exit:
		pop cx ; load X coordinate (top left corner of the front)
		pop dx ; load Y coordinate (top left corner of the front)
		ret
cube_front endp	

shadow proc
	call color_black ; set black color
	call cube_front ; remove
	call cube_top ; cube
	call cube_side ; by draving it by
	call color_back ; black color
	ret
shadow endp

main proc
	mov ax, data ; initialization of the system registers
	mov ds,ax ; the system registers
	mov ah, 00h ; function to set mode
	mov al, 10h ;graphic mode EGA
	int 10h  
	mov al, color ; set color
	mov dx, 100 ; point y coordinate
	mov cx, 300 ; point x coordinate
	call cube_front ; draw
	inc al
	call cube_top ; cube
	inc al
	call cube_side ; different colors
	input:
		mov ah, 0Ch ; clear 
		mov al, 08h ; keyboard 
		int 21h ; buffer
		cmp al, 0 ; pressed F10?
		je analize
		jmp change_color
	 analize:
		 mov ah, 08h
		 int 21h
		 cmp al, 44h
		 jne further
		 jmp exit
	further:
		cmp al, 72 ; pressed key up?
		je up
		cmp al, 80 ; pressed key down?
		je down
		cmp al, 75 ; pressed key left?
		jne left_jump
		jmp left
	left_jump:
		cmp al, 77 ; pressed key right?
		jne change_color
		jmp right                         ;;;;;;;;;;;;;;
		change_color:
			push cx
			push dx
			call pauuse 
			mov al, color_temp
			mov color,al
			pop dx
			pop cx
			jmp input
		up:
			push dx
			add dx, -5 ; decrese Y coordinate of the cube
			cmp dx, 30 ; reached the top border?
			jle point_up_stop ; if yes than stop moving
			pop dx
			call shadow
			add dx, -5
			call cube
			jmp input ; again to input 
			point_up_stop:
				pop dx
				jmp input ; again to input
		down:
			push dx
			add dx, 5 ; increase Y coordinate
			cmp dx, 295 ; reached the bottom border?
			jge point_down_stop ; if yes than stop moving
			pop dx
			call shadow
			add dx, 5
			call cube
			jmp input ; again to input
			point_down_stop:
				pop dx
				jmp input ; again to input
		right:
			push cx
			add cx, 5
			cmp cx, 560 ; reached the right border?
			jge point_right_stop ; if yes than stop moving
			pop cx
			call shadow
			add cx, 5
			call cube
			jmp input ; again to input 
			point_right_stop:
				pop cx
			jmp input ; again to input 
		left:
			push cx
			add cx, -5  ; increase X coordinate
			cmp cx, 5 ; reached the left border?
			jle point_left_stop ; if yes than stop moving
			pop cx
			call shadow
			add cx, -5
			call cube
			jmp input ; again to input 
			point_left_stop:
				pop cx
			jmp input ; again to input 
	exit:
		mov ah, 00h ; function to set mode
		mov al, 03h ; text mode
		int 10h
		mov ax, 4c00h 
		int 21h
main endp
text ends

data segment 'data'
	color db 1
	color_temp db ?
data ends
end main
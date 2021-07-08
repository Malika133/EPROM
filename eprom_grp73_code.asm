#make_bin#

; BIN is plain binary format similar to .com format, but not limited to 1 segment;
; All values between # are directives, these values are saved into a separate .binf file.
; Before loading .bin file emulator reads .binf file with the same file name.

; All directives are optional, if you don't need them, delete them.

; set loading address, .bin file will be loaded to this address:
#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

; set entry point:
#CS=0000h#    ; same as loading segment
#IP=0000h#    ; same as loading offset

; set segment registers
#DS=0000h#    ; same as loading segment
#ES=0000h#    ; same as loading segment

; set stack
#SS=0000h#    ; same as loading segment
#SP=FFFEh#    ; set to top of loading segment

; set general registers (optional)
#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#

; add your code here
jmp strt
;1024 locations in CS are for IVT

db 1024 dup(0)



;main program
strt:sti

; intialize ds, es,ss to start of RAM
mov       ax,0200h
mov       ds,ax
mov       es,ax
mov       ss,ax
mov       sp,0FFFEH
mov dx, 0000h			;Initialising address of EPROM to 0000h
;DS:0200h will contain the data entered by the user  


;Table of key recognition for digit entered by user, 3*6 0 to F and backspace and enter keys.	
mov si, 00h ;Starting Point	
mov ax, 0EFEh   ;backspace
mov [si], ax
add si,2
mov ax, 0DFEh   ;enter
mov [si], ax
add si,2
mov ax, 0BFEh       ;key 0
mov [si], ax
add si,2
mov ax, 0EFDh		;key 1
mov [si], ax
add si,2
mov ax, 0DFDh		;key 2
mov [si], ax
add si,2
mov ax, 0BFDh		;key 3
mov [si], ax
add si,2
mov ax, 0EFBh		;key 4
mov [si], ax
add si,2
mov ax, 0DFBh		;key 5
mov [si], ax
add si,2
mov ax, 0BFBh		;key 6
mov [si], ax
add si,2
mov ax, 0EF7h		;key 7
mov [si], ax
add si,2
mov ax, 0DF7h		;key 8
mov [si], ax
add si,2
mov ax, 0BF7h		;key 9
mov [si], ax
add si,2
mov ax, 0EEFh		;key A
mov [si], ax
add si,2
mov ax, 0DEFh		;key B
mov [si], ax
add si,2
mov ax, 0BEFh		;key C
mov [si], ax
add si,2
mov ax, 0EDFh		;key D
mov [si], ax
add si,2
mov ax, 0DDFh	    ;key E
mov [si], ax
add si,2
mov ax, 0BDFh		;key F
mov [si], ax
;Finish


;Table for 7 segment display 	
mov si,102h ;Starting Point	
mov al, 03fh          ;for zero
mov [si], al
add si,1
mov al, 06h           ;for one
mov [si], al
add si,1
mov al, 5bh           ;for two
mov [si], al
add si,1
mov al, 4fh           ;for three
mov [si], al
add si,1
mov al, 66h           ;for four
mov [si], al
add si,1
mov al, 6dh			  ;for five
mov [si], al
add si,1
mov al, 7dh           ;for six
mov [si], al
add si,1
mov al, 27h           ;for seven
mov [si], al
add si,1
mov al, 7fh           ;for eight
mov [si], al
add si,1
mov al, 6fh           ;for nine
mov [si], al
add si,1
mov al, 77h;		  ;for A
mov [si], al
add si,1
mov al, 7ch           ;for B
mov [si], al
add si,1
mov al, 39h           ;for C
mov [si], al
add si,1
mov al, 5eh           ;for D
mov [si], al
add si,1
mov al, 79h           ;for E
mov [si], al
add si,1
mov al, 71h           ;for F
mov [si], al
add si,1
;end of the table

; 8255 1: 50h-56h (Connected to the keypad, LEDs and data lines of EPROM)
; data lines of EPROM connected to Port A : port A    (Input)
; six rows of the keypad from (PB0-PB5) : port B      (Input)
; PB6 and PB7 of PortB are connected to Vcc
; three columns of the keypad  connected to Port C LOWER : port Cl   (Output)
; PC0,PC1,PC2:    Col0,Col1,Col2
; PC3: Connected to ground with the help of resistor
; three status LEDs connected to Port C Higher    : port Ch   (Output)
; PC4: LED1 - Not Empty  Yellow Light    BSR 0001 xxxxb=1xh to be output
; PC5: LED2 - Prog failed   Red Light    BSR 0010 xxxxb=2xh to be output
; PC6: LED3 - Prog completed Green light BSR 0100 xxxxb=4xh to be output

; 8255 2: 60h-66h (Connected to the address lines, data lines, Vpp and CE' signals of the EPROM) 
;data lines of the EPROM   are connected to : port A (Output)
;address lines of EPROM A0-7 connected to PortB   : port B (Output)
;address lines of EPROM A8-11 connected to PortC Lower : port Cl (Output)
;control signals of EPROM connected to PortC higher : port Ch (Output)
;PC4: Vpp to relay unit                    Can be set/reset using BSR mode
;PC5: CE' pin of EPROM via a NOT gate Can be set/reset using BSR mode
;PC6: Grounded with the help of resistor
;PC7: Grounded with the help of resistor
; 8255 3: 70h-76h (Connected to seven-segment displays for showing the memeory location)
; Decoded values of address MNOh: 
; M:port A 		(Output)
; N:port B 		(Output)
; O:port C 		(Output)

; 8255 4: 80h-86h (Connected to seven-segment displays)
; Decoded values of address PMNOh and data QRh: 
; P:port A 		(Output)
; Q:port B 		(Output)
; R:port C 		(Output)    

;Initialising 4 8255   
;8255 50H - Port A, B, Ch - O/P , Port Cl - I/P, initializing the status LEDs to OFF 
mov al, 92h		;92h=10010010b
out 56h, al
mov al, 00h
out 54h, al
;8255 60h - Port A, B, Cl, Ch - O/P 
mov al, 80h    ;80h=10000000b;
out 66h, al	
;8255 70H - Port A, B, Cl, Ch - O/P 
mov al, 80h    ;80h=10000000b;
out 76h, al
;8255 80H - Port A, B, Cl, Ch - O/P  
mov al, 80h    ;80h=10000000b;
out 86h, al
;Checking default conditions of the device (memory is FFh)	
;Set PC5 0010 0000b, Vpp to the relay unit
mov al, 20h			
out 64h, al
mov bx,0000h
fun1 :
mov al, bl
out 62h, al
mov al, bh
and al, 0fh
out 64h, al
in al, 50h
cmp al, 0ffh
jz func
mov al, 10h		
;Turn on LED - "Not Empty" 
out 54h, al			
jmp end
func:
inc bx
cmp bx, 1000h
jnz fun1
start:
mov al, 0ffh
;the data initialised to 0ffh
mov [200h], al 

;displays the address to be programmed in EPROM and FF on seven-segment displays for data 		
call display			

;Key press algorithm
;initializing port c
mov al, 00h
out 54h, al

;Check for key release
ab1:	
in al, 52h
cmp al, 0ffh
jnz ab1
;Delay for the debounce of keys
call delay_20ms
;Detecting which key is pressed
ab2:	
mov al, 00
out 54h, al                           ;data lines
in al, 52h                            ;address lines
cmp al, 0ffh
jz ab2	
;Delay for the debounce of keys
call delay_20ms
;Check if the key is still pressed
mov al, 00
out 54h, al
in al, 52h
cmp al, 0ffh
jz ab2   

;now Detecting which key has been pressed by user
;making  column first low
mov al, 0Eh			;1110b=8+4+2=0Eh 
mov ah, al			
out 54h, al
;ah has input for columns, al has output from rows		
in al, 52h          
cmp al, 0ffh
jnz target
;making  column two low
mov al, 0Dh			;1101b=8+4+1=0Dh
mov ah, al
out 54h, al
;ah has input for columns, al has output from rows
in al, 52h          
cmp al, 0ffh
jnz target
;making  column three low
mov al, 0Bh			;1011b=8+2+1=0Bh
mov ah, al  
out 54h, al 
in al, 52h         
;ah has input for columns, al has output from rows
cmp al, 0ffh
jnz target
jmp ab1

target :
mov cx, 12h
mov di, 00h
mov si, 00h
ab4:	
mov bx, [di]            
cmp ax, bx    ;ax-column and rows
jz ab5
add si,1
add di,2
loop ab4
ab5: 
;moving the digit to ax	
mov ax, si
;Backspace as 0 key is backspace           
cmp al, 00h			
jz ab2 
;if Enter is pressed             
cmp al, 01h			
jnz cont
mov al, 40h			
out 54h, al
jmp end	
cont:
sub si, 2
;Any other key is pressed
mov ax, si			
ror al, 4
or al, 0fh
mov [200h], al
;Display the received digit on seven segment display	
call datashow		


;Initialising columns for second key check
mov al,00h
out 54h,al
;check for key release
ac1: in al, 52h
cmp al, 0ffh          
jnz ac1	
;delay for debounce of keys 
call delay_20ms
;detecting second key press
ac2: mov al, 00h
out 54h, al           ;input
in al, 52h
cmp al, 0ffh
jz ac2	
;Debounce delay of keys
call delay_20ms
;Check if the key is still pressed
mov al, 00h
out 54h, al
in al, 52h
cmp al, 0ffh
jz ac2

;Making column first low
mov al, 0Eh			;1110b=0Eh
mov ah, al
out 54h, al
in al, 52h
cmp al, 0ffh     
;if any key in col first pressed will go to target1   
jnz target1
;make column second low
mov al, 0Dh			;1101b=0Dh
mov ah, al
out 54h, al
in al, 52h
cmp al, 0ffh
;if any key in col second pressed will go to target1
jnz target1         
;make column third low
mov al, 0Bh			;1011b=0Bh
mov ah,al
out 54h, al
in al, 52h
cmp al, 0ffh
 ;if any key in col third pressed will go to target1
jnz target1         
jmp ac1

target1 :
mov cx, 12h		
mov di, 00h
mov si, 00h
ac4:mov bx,[di]     ;base value of table
;ax has the key calculated thats pressed
cmp ax, bx       
jz ac5
add di,2
inc si
loop ac4
ac5: 
;moving the digit to ax   
mov ax, si          
;if Backspace is pressed Display FF and take input from first key
cmp al, 00h			
jnz ac6
mov al, 0ffh
mov [200h], al
;displaying the digit
call datashow	    
jmp ab1
ac6:
;if Enter key pressed , go for another key
cmp al, 01h			
jz ac1 
;if other key is pressed 
mov bl, [200h]		
and bl, 0f0h
or  bl, al
sub bl, 2
mov [200h], bl 		
call datashow


;Initialising columns for third key check
mov al,00h
out 54h,al	
;check for key release
ad1: in al, 52h
cmp al, 0ffh
jnz ad1	
;delay for debounce
call delay_20ms
;checking if second key is pressed
ad2: mov al, 00h  
out 54h, al
in al, 52h
cmp al, 0ffh
jz ad2
;Debounce delay of keys 
call delay_20ms
;Check if the key is still pressed
mov al, 00h
out 54h, al
in al, 52h
cmp al, 0ffh
;if no then first time was mistake by user
jz ad2             

;checking if column1 is low
mov al, 0Eh			;1110b=0Eh
mov ah, al
out 54h, al
in al, 52h
cmp al, 0ffh
;if low go to target2
jnz target2         
;checking if column2 is low
mov al, 0Dh			;1101b=0Dh
mov ah, al
out 54h, al
in al, 52h
cmp al, 0ffh
;if low go to target2
jnz target2         
;checking if column3 is low 
mov al, 0Bh			;1011b=0Bh
mov ah, al
out 54h, al
in al, 52h
cmp al, 0ffh

;if low go to target2
jnz target2         
jmp ad1
target2 :
mov cx, 12h		
mov di, 00h
mov si, 00h
ad4:	mov bx, [di]
cmp ax, bx
jz ad5
add di,2
inc si
loop ad4
ad5: 
mov ax, si
;if pressed Backspace, Display xF and retake input for last 4 bits
cmp al, 00h			
jnz ad6
mov al, [200h]
or al, 0fh
mov [200h], al
call datashow
jmp ac1
ad6:
;if enter is pressed, Write to EPROM 
cmp al, 01h			
jz write
;Any other key if pressed by user is ignored
jmp ad1             


write:
;output data lines and address lines to EPROM here Port A is data lines Port B,Cl are address lines
mov al, [200h]
;data entered by the user available on the data lines of EPROM
out 60h, al         
mov ax, dx
out 62h, al
ror ax, 8
;address lines available on the address lines of EPROM
out 64h, al 
;Delay to stabilise the address and data on their lines        
call delay_55ms     
;enabling E and Vpp of the EPROM
and al, 0fh	
or al, 30h 			;output 0011b to port C upper
out 64h, al		
call delay_50ms	
and al, 2fh 		;Reset Vpp
out 44h, al

;Reading from EPROM
in al, 50h			
mov ah, [200h]
cmp ah, al
;If the input data and output data do not match, jump to 'fail' label and exit
jnz fail  
inc dx
mov al, 0ffh
mov [200h], al
cmp dx, 1000
;If the EPROM has not been programmed fully then process can be repeated for next address.
jnz start   

;To turn on the green LED labeled Programming Completed and then exit
mov al, 40h		    
out 54h, al
jmp end	

fail: 
mov al, 20H    
;Turn on the red LED saying "Programming failed" maybe technical error     
out 54h, al         
jmp end	

end:
jmp end	;for ending the program

;disp1 displays DX on the address 7 segment displays and FF on the data displays
display proc near
;Address KMNOh EPROM starting from 0000h
mov ax, dx 		
;Starting of decoding table   
mov bx, 102h 	
and al, 0fh		
xlatb
out 80h, al 	;Displaying P
mov ax, dx
and al, 0f0h
ror al, 4
xlatb
out 74h, al 	;Displaying O
mov al, ah
and al, 0fh
xlatb
out 72h, al 	;Displaying N
mov al, ah
and al, 0f0h
ror al, 4
xlatb
out 70h, al 	;Displaying M	
call datashow
ret
display endp

;datashow displays currently stored data on the seven segment displays
datashow proc near
;Data QRh
mov al, [200h]    
mov bx, 102h
and al, 0fh 
xlatb
out 84h, al	    ;Displaying R
mov al, [200h]
mov bx, 102h
and al, 0f0h
ror al, 4
xlatb
out 82h, al     ;Displaying Q
ret
datashow endp

;produces 50ms delay
delay_50ms:   
push cx
mov cx,27776
xn2: loop xn2  
pop cx
ret
;produces 55ms delay
delay_55ms:
push cx
mov cx,30554
xn3:loop xn3    
pop cx
ret 
;produces 20ms delay
delay_20ms:   
push cx
mov cx,1110
xn1:loop xn1
pop cx
ret

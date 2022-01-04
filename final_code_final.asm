include 'emu8086.inc'
data  segment
movie_word db "prestige$","venom$","tenet$" ,"avatar$","inception$"    
city_word db "paris$","london$","bangkok$","dubai$","rome$"  
len dw 0  
pos db 0 
correct dw 0     
gotit db 0
lives dw 53    ;53->5 
ends

code segment   
start:    
   mov ax,data
   mov ds,ax  
   
   mov dh,2  
   call setcursor
   PRINTN 'Hangman game development using Emu8086'    
   inc dh
   call setcursor
   PRINTN 'Press 1 to start playing'       
   inc dh 
   call setcursor
   mov ah,01h  ; getting a input from user which will be stores in AL
   int 21h    
   PRINTN ''
   cmp al,31h   ; ascii value of character 1 is 31h
   je gameon
   jmp close  
    
gameon:        
   inc dh
   call setcursor
   PRINTN 'Choose your GENRE' 
   inc dh 
   call setcursor 
   PRINTN '1.Hollywood movie name' 
   inc dh 
   call setcursor
   PRINTN '2.Popular city name' 
   inc dh 
   call setcursor 
   
   mov ah,01h
   int 21h    
   PRINTN ''
   cmp al,31h 
   je movies
   cmp al,32h
   je city 
   
movies:  
   MOV AH, 00h  ; interrupts to get system time        
   INT 1AH      ; CX:DX now hold number of clock ticks since midnight      
   mov  ax, dx
   xor  dx, dx
   mov  cx, 5 
   div  cx       ; here dx contains the remainder of the division - from 0 to 4
   add  dl, '0'  ; to ascii from '0' to '4'   
   
   PRINTN '*Random number choosen:' 
   mov ah, 2h   ; call interrupt to display a value in DL
   int 21h           
   
   mov bl,dl  
   sub bl,30h   ; now the bl value is from 0h to 4h      
   PRINTN ''       
   
   PRINTN '*Word selected:'  
   cmp bl,00h      
   je movie_first   
   cmp bl,01h
   je movie_second
   cmp bl,02h
   je movie_third 
   cmp bl,03h
   je movie_fourth
   cmp bl,04h
   je movie_fifth
   
movie_first:     
   lea di,movie_word[0]
   mov cx,8    
   mov dx,di 
   call printit
   jmp getchar                 
movie_second:
   lea di,movie_word[9] 
   mov cx,5     
   mov dx,di 
   call printit 
   jmp getchar
movie_third: 
   lea di,movie_word[15] 
   mov cx,5     
   mov dx,di 
   call printit    
   jmp getchar
movie_fourth:
   lea di,movie_word[21]  
   mov cx,6     
   mov dx,di 
   call printit    
   jmp getchar     
movie_fifth:
   lea di,movie_word[28] 
   mov cx,9      
   mov dx,di 
   call printit   
   jmp getchar
   
city:
   MOV AH, 00h  ; interrupts to get system time        
   INT 1AH      ; CX:DX now hold number of clock ticks since midnight      
   mov  ax, dx
   xor  dx, dx
   mov  cx, 5 
   div  cx       ; here dx contains the remainder of the division - from 0 to 4
   add  dl, '0'  ; to ascii from '0' to '4'   
   PRINTN '*Random number choosen:'
   mov ah, 2h   ; call interrupt to display a value in DL
   int 21h           
   
   mov bl,dl  
   sub bl,30h   ; now the bl value is from 0h to 4h   
               
   PRINTN ''  
   PRINTN '*Word selected:'
   cmp bl,00h      
   je city_first   
   cmp bl,01h
   je city_second
   cmp bl,02h
   je city_third 
   cmp bl,03h
   je city_fourth
   cmp bl,04h
   je city_fifth
   
city_first:     
   lea di,city_word[0]  
   mov cx,5    
   mov dx,di   
   call printit
   jmp getchar                  
city_second:
   lea di,city_word[6]  
   mov cx,6      
   mov dx,di 
   call printit
   jmp getchar
city_third: 
   lea di,city_word[13]  
   mov cx,7     
   mov dx,di 
   call printit 
   jmp getchar
city_fourth:
   lea di,city_word[21]  
   mov cx,5     
   mov dx,di 
   call printit  
   jmp getchar     
city_fifth:
   lea di,city_word[27]   
   mov cx,4     
   mov dx,di 
   call printit
   jmp getchar

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;rev -3;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printit:
   mov ah,09h
   int 21h   
   ret  
   
setcursor:
   mov dl,20
   mov bh,0
   mov ah,2h
   int 10h        ;set cursor position DH = row.DL = column.BH = page number (0..7).
   ret
   
getchar:
   mov len,cx 
   mov al, 02h
   mov ah, 0
   int 10h        ;clear screen     
   
   call rod    
   
welcome:
   mov dh,2
   mov dl,20
   mov bh,0
   mov ah,2h
   int 10h        ;set cursor position DH = row.DL = column.BH = page number (0..7).
   
   PRINT 'HANGMAN GAME USING EMU8086' 
   call printlife  
    
underscores:   
   mov dh,8
   mov dl,20
   mov bh,0
   mov ah,2h
   int 10h        ;set cursor position DH = row.DL = column.BH = page number (0..7).
   mov cx,len   
   
printunderscores:
   PRINT '_ ' 
   inc dl
   loop printunderscores
      
      
    
beg:   
   mov ah,07h       ;get input without echo
   int 21h
   
   mov ah,00h
   lea si,di 
   mov cx,len  
   mov pos,0      
   
check:
  mov bl,[si]         
  inc pos             
  inc si
  cmp al,bl
  je foundit
  loop check
   
  cmp gotit,0
  je nfound
  mov gotit,0
  
  jmp goagain 
  
nfound:  
  dec lives
  call printlife   
  
  cmp lives,52   ;52->4
  je rope
  
  cmp lives,51
  je head
  
  cmp lives,50
  je body
  
  cmp lives,49
  je hands
  
  cmp lives,48
  je legs
  
  jmp goagain
  
foundit:
  ;PRINTN "found"  
   mov gotit,1 
   inc correct     
   mov dh,7
   mov dl,18
   add dl,pos 
   add dl,pos
   mov bh,0
   mov ah,2h
   int 10h        ;set cursor position DH = row.DL = column.BH = page number (0..7).
   
   mov dl,al    ;printing character
   mov ah,02h
   int 21h  
   
   mov dx,len
   cmp dx,correct
   je cong 
   
   jmp check
     
goagain:
  jmp beg  
  
printlife:
   mov dh,5
   mov dl,20
   mov bh,0
   mov ah,2h
   int 10h        ;set cursor position DH = row.DL = column.BH = page number (0..7).
   
   PRINT 'LIVES:'  
   mov dx,lives    ;printing lives
   mov ah,02h
   int 21h
   ret
gameover:
   mov dh,5
   mov dl,20
   mov bh,0
   mov ah,2h
   int 10h        ;set cursor position DH = row.DL = column.BH = page number (0..7).
   
   PRINT 'GAMEOVER' 
   jmp close
   
cong:
   mov dh,5
   mov dl,20
   mov bh,0
   mov ah,2h
   int 10h        ;set cursor position DH = row.DL = column.BH = page number (0..7).
   
   PRINT 'CONGRATULATIONS YOU GUESSED THE WORD'
   jmp close  
   
rod:
   
   mov dh,5
   mov dl,5
   mov bh,0
   mov ah,2h
   int 10h 
rodtop:       
   PRINT "-"
   
   inc dl
   cmp dl,12
   jb rodtop  
   mov dh,5
    
rodleft:
   
   inc dh 
   mov dl,5
   mov bh,0
   mov ah,2h
   int 10h 
   
   PRINTN "|" 
   
   cmp dh,18
   jb rodleft  
   ret
    
rope:
   mov dh,5
     
drawrope:
   inc dh   
   mov dl,10
   mov bh,0
   mov ah,2h
   int 10h
   
   PRINTN "|" 
    
   cmp dh,8
   jb drawrope
   jmp goagain
   
head:
   mov dh,8
   mov dl,10
   mov bh,0
   mov ah,2h
   int 10h  
   
   PRINT "-"  
   
   inc dh 
   mov dl,9
drawhead:   
   mov bh,0
   mov ah,2h
   int 10h
   PRINT "|"
   inc dl
   inc dl
   
   cmp dl,12
   jb drawhead  
   
   inc dh
   mov dl,10
   mov bh,0
   mov ah,2h
   int 10h 
   PRINT "-" 
   jmp goagain
   
body:
   mov dh,11
   
drawbody:
   mov dl,10
   mov bh,0
   mov ah,2h
   int 10h 
   
   PRINT "|"
   inc dh
   
   cmp dh,14
   jb drawbody
   jmp goagain
   
hands:
   mov dl,8
   
drawhands:
   mov dh,11
   mov bh,0
   mov ah,2h
   int 10h     
   PRINT "-" 
   inc dl
   
   cmp dl,13
   jb drawhands 
   jmp goagain
   
legs:
  mov dl,10
  mov dh,14
  mov bh,0
drawleg:
  mov ah,2h
  int 10h
  PRINT "-"
  
  mov dl,9
  mov dh,15
  mov bh,0
drawleftleg:
  mov ah,2h
  int 10h
  PRINT "|"
  inc dh
  cmp dh,17
  jb drawleftleg 
  
  mov dl,11
  mov dh,15
  mov bh,0
drawrightleg:
  mov ah,2h
  int 10h
  PRINT "|"
  inc dh
  cmp dh,17
  jb drawrightleg
  
  jmp gameover   
   
close:
  mov ah,4ch
  int 21h

   
ends 
end start  
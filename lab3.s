.data
sizeofbuf: .quad 128
bufferin:
    .quad 0 # Initierar ett start index, quad fungerar som word men lagrar 64 bitar istället för 16
    .space 128 # 128 bytes för inmatning
bufferut:
    .quad 0 # Initierar ett start index, quad fungerar som word men lagrar 64 bitar istället för 16
    .space 128 # 128 bytes för inmatning
.text
.global inImage,getInt,getText,getChar,getInPos,setInPos,outImage,putInt,putText,putChar,getOutPos,setOutPos

# Indata
inImage:
leaq bufferin,%rdi # sätter buffer addressen i rdi
movq $0,(%rdi)# laddar 0 till indexet i bufferin
addq $8,%rdi # flyttar oss till space
# kolla someCode i uppgiftbeskrivningen
movq $128,%rsi # Tillåter 128 bytes i inmatning. Null räcknas som ett sista tecken så måste ta 128+1
movq stdin,%rdx # stdin kommer från c
call fgets # använder sig av avancerad kod
ret

callInImage:
call inImage

getInt:
movq $0,%r8
movq $0,%rax
movq $0, %rsi
leaq bufferin,%rdi # buffer
movq (%rdi),%rcx # index
addq $8,%rdi # lägger oss i space
addq %rcx,%rdi # flyttar oss fram till index
cmpq $10,(%rdi)
je callInImage
cmpq $0,(%rdi)
je callInImage
startsearch:
cmpb $'+',(%rdi)
jne lookfornegative
incq %rdi
incq %rsi
jmp lookforinteger
lookfornegative:
cmpb $'-',(%rdi)
jne lookforspace
movq $1,%r8 # vet att den är negativ
incq %rdi
incq %rsi
jmp lookforinteger
lookforspace:
cmpb $' ',(%rdi)
jne lookforinteger
incq %rdi
incq %rsi
jmp startsearch
lookforinteger:
cmpb $48, (%rdi)
jl negativeconverter
cmpb $57,(%rdi)
jg negativeconverter
movzbq (%rdi),%r9
subq $48,%r9
imulq $10,%rax
addq %r9,%rax
incq %rdi
incq %rsi
jmp lookforinteger
negativeconverter:
cmpq $1,%r8
jne intdone
notq %rax # tar inversen av rax
addq $1,%rax # Adderar 1 för att inversen skall bli det negativa värdet av bufferten
jmp intdone
intdone:
subq $8,%rdi # flyttar oss bak till index
subq %rsi,%rdi # hoppar bak de steg vi rört oss under loopen
subq %rcx,%rdi # hoppar bak de steg vi flyttade fram i början, nu är vi tillbaka på index position 0
addq %rsi,%rcx # lägger till de steg vi rört oss i bufferten till index
movq %rcx,(%rdi)
ret

# rdi - adress till minnesutrymme att kopiera sträng till från inmatningsbufferten (buf i texten)
# rsi - maximalt antal tecken att läsa från inmatningsbufferten (n i texten)
getText:
movq %rsi,%rdx # räknare för n
leaq bufferin,%rcx # buffer
movq (%rcx),%r8 # index
addq $8,%rcx # lägger oss i space
addq %r8,%rcx # flyttar oss fram till index
nloop:
cmpq $0,%rdx # om rdx är 0 så har vi gått igenom hela n
je loopdone
cmpb $10,(%rcx)# %10 är newline ascii, alltså vi har nått slutet på texten
je newlinematch
# aktuell position i den är vid buffertens slut vid anrop av getText ska getText kalla på inImage
cmpq $0, (%rcx) # Ifall vi dektiterar NULL så avbrytter vi då
je newlinematch
movzbq (%rcx),%r9 # flytta 8-bits ord utfyllt med nollor
movq %r9,(%rdi) # flyttar den sedan till rdi
incq %rdi
decq %rdx
incq %rcx
jmp nloop
newlinematch:
cmpq %rsi,%rdx # Då vi satt rdx till rsi, så kan vi se om vi hamnar här och vi får samma så vet vi att bufferten är tom
jne loopdone
call inImage
loopdone:
subq %rdx,%rsi # Hur många tecken vi skrivit över
movq %rsi,%rax # output variabel
ret

getChar:
leaq bufferin, %rdi
movq (%rdi), %rsi # laddar index i rsi
addq $8,%rdi # flyttar till inmatningen
addq %rsi, %rdi # rör oss till rätt plats i inmatningen med hjälp av index pekaren
cmpq $0,(%rdi)
je callInImage
cmpq $10,(%rdi) # %10 är newline, newline är ingen char vi vill ha så skippar den
je callInImage
movq (%rdi),%rax # lägger charen i rax (return address)
subq %rsi, %rdi # hoppar tillbaka till början av space innan vi backar tillbaka till indexet
subq $8, %rdi
incq (%rdi) # minskar indexet med 1
ret


getInPos:
leaq bufferin,%rdi
movq (%rdi),%rax # hämtar innehållet från den adress rdi anger
ret

setInPos: # kräver en inparameter: rdi
leaq sizeofbuf,%rsi
movq (%rsi), %rax
cmpq (%rsi),%rdi # jämför max med indexet
jg MAXPOS
cmpq $0,%rdi # jämför 0 med indexet
jl ZEROPOS
jmp SetInPosFinish # hoppar till finish

MAXPOS: # Då %rdi var större än buffer sätter vi den till max
movq (%rsi),%rdi
jmp SetInPosFinish # hoppar till finish

ZEROPOS: # Då indexet var mindre än 0 sätter vi den till 0
movq $0,%rdi
jmp SetInPosFinish # hoppar till finish

SetInPosFinish: # använder en finish då max,zero och den vanliga set använder samma slutfunktion (minimera kod)
leaq bufferin, %rsi
movq %rdi,(%rsi)
ret

# Utdata
outImage:
leaq bufferut,%rdi /* Sparar buffern i rdi */
addq $8,%rdi    /* Hoppar till första elementet i buffern */
movq %rdi, %rax
addq $128, %rax
# movq $0, (%rax) /* Lagt till en word i buffern istället */
pushq %rdi
call puts  /* C funktion som skriver ut i terminalen */
popq %rdi
leaq bufferut,%rdi
movq (%rdi),%rcx /*Sätter rcx som index i buffer */
addq $8,%rdi
addq %rcx,%rdi /*Hoppar fram till sista tecken i buffern */

buff_clear:
movq $0,(%rdi) /* Rensar ett helt quadword åt gången. */
decq %rdi
decq %rcx
cmpq $0,%rcx /*Kollar när stackpekaren är längst fram i stacken/stacken är fullt rensad */
jg buff_clear
movq $0,(%rdi)
subq $8,%rdi
movq $0,(%rdi)
ret



# get the stackpointer to where we were before calling outimage.

putInt:
movq $0,%r9
cmpq $0,%rdi
jge positiv
negq %rdi
movq $1,%r9
positiv:
pushq %r8
movq $0, %r8
leaq bufferut, %rbx /* Sparar buffern i rbx */
movq (%rbx), %rcx /* Sparar bufferindex i rcx*/
addq $8, %rbx  /* Hoppar till första elementet i buffern */
addq %rcx, %rbx /*Hoppar fram till sista tillagda elemenetet */
movq $0, %rax        # Clear %rax (used for division)
movq %rdi, %rax        # Move the value to be converted to %rax

modulo_to_ascii:
pushq %rbx  /* Sparar alla register som används inför divisionen*/
pushq %rcx
movq $10, %rcx         # Set divisor to 10 (for decimal conversion)
movq $0, %rdx        # Clear %rdx (used for remainder)
divq %rcx              # Divide %rax by %rcx, remainder in %rdx
popq %rcx   /* Hämtar tillbaka alla register som använts i divisionen*/
popq %rbx         # Divide %rax by %rcx, remainder in %rdx
addb $48, %dl          # Convert remainder to ASCII digit
movb %dl, %r8b
shlq $8, %r8
cmpq $0, %rax          # Check if division result is zero
jne modulo_to_ascii    # If not zero, continue conversion
shrq $8, %r8
cmpq $1,%r9
jne reverse_loop
movq $'-',(%rbx)
movq $0,%r9
incq %rcx
incq %rbx

reverse_loop:
movb %r8b,(%rbx)
shrq $8, %r8
incq %rcx
incq %rbx
leaq bufferut, %rax
movq %rcx, (%rax) /* Uppdaterar index i buffern */
cmpq $128, %rcx
je outImage
cmpb $0, %r8b
jne reverse_loop
popq %r8
ret

putText:
leaq bufferut, %rbx /* Sparar buffern i rbx */
movq (%rbx), %rcx /* Sparar bufferindex i rcx*/
addq $8, %rbx  /* Hoppar till första elementet i buffern */
addq %rcx, %rbx /*Hoppar fram till sista tillagda elemenetet */
movq $0,%rcx    /* Rensar rcx*/
movq $0, %r8
inc_loop:
cmpb $10,(%rdi)
jle exit_loop
cmpq $128, %rcx /* Checkar om buffert är full, måste ha sista som null för att veta när den tar slut*/
je outImage
movb (%rdi),%r8b
cmpb $0, %r8b
jle exit_loop
movb %r8b,(%rbx)
incq %rbx
addq $1,%rdi /* Går till nästa tecken i Texten */
incq %rcx
jmp inc_loop
exit_loop:
leaq bufferut,%rax /* Laddar utbuff till rbx */
movq %rcx, (%rax) /* Uppdaterar index i buffern */
movq $'\n',%rdi
call putChar
ret

putChar:
leaq bufferut, %rbx /* Sparar buffern i rbx */
movq (%rbx), %rcx /* Sparar bufferindex i rcx*/
addq $8, %rbx  /* Hoppar till första elementet i buffern */
addq %rcx, %rbx /*Hoppar fram till sista tillagda elemenetet */
movb %dil,(%rbx)
incq %rcx
leaq bufferut, %rbx
movq %rcx, (%rbx) /* Uppdaterar index i buffern */
cmpq $128, %rcx
je outImage
ret

getOutPos:
leaq bufferut,%rdi
movq (%rdi),%rax # hämtar innehållet från den adress rdi anger
ret

setOutPos:
leaq sizeofbuf,%rsi
cmpq (%rsi),%rdi # jämför max med indexet
jg MAXPOSUT
cmpq $0,%rdi # jämför 0 med indexet
jl ZEROPOSUT
jmp SetutPosFinish

MAXPOSUT: # Då %rdi var större än buffer sätter vi den till max
movq (%rsi),%rdi
jmp SetutPosFinish # hoppar till finish

ZEROPOSUT: # Då indexet var mindre än 0 sätter vi den till 0
movq $0,%rdi
jmp SetutPosFinish # hoppar till finish

SetutPosFinish: # använder en finish då max,zero och den vanliga set använder samma slutfunktion (minimera kod)
leaq bufferut, %rsi
movq %rdi,(%rsi)
ret

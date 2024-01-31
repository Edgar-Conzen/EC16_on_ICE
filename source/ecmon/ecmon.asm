;  ECMON
;
;
; Usage of the ECMON
; ##################
;
; The input line buffer can hold up to 44 characters (plus a terminating 0) which is
; sufficient for the longest possible command: an 8 word write to external memory
;
; Example:  
; >8000=0123 4567 89ab cdef 0123 4567 89ab cdef<CR><LF>
;  ^------------------------------------------^ 44 characters
;
; All numbers must be separated by exactly one other valid character 
;
; Valid characters besides 0..9, a..f are:  '.', '=', <SPACE>  and r
; All letters must be lower case!
;
; The input must be finished with <CR><LF> and since no editing is possible,
; an input line can be cancelled by pressing <ESC> 
; 
; All numbers must be in hex and either 2 or 4 digits wide 
; Leading zeros are mandatory, leading 0Xs are not allowed
;     To refer to external memory (64 kWords) 4 hex digit addresses must be used
;     To refer to internal memory (256 words) 2 hex digit addresses  must be used
;     Data must always be 4 hex digit numbers
;
; The range operator '.' is used to define a range of read addresses
; The assign operator '=' signals a memory write
; 'r' following a 4 digit external address starts execution from there
;
;
; Examples: (user input lines recognisable by '>')
; #########################################################################################
;
; Read external memory at address 0
; ---------------------------------
; >0000<CR><LF>
;
; 0000: A000
; >
;
; Read range of external memory beginning at address 1 including address 11
; -------------------------------------------------------------------------
; >0001.000b<CR><LF>
;
; 0001: a000 0028 0000 0000 0000 0000 0000 0000 8500
; 000A: 0000 0000
; >
;
; Write up to 8 words to external memory beginning at address 8000
; (no output, no verify)
; ------------------------------------------------------------------------------------------------------
; >8000=1234 5678 9abc<CR><LF>
; >
;
;
; Start execution at external address 8000
; ----------------------------------------
; >8000r<CR><LF>
;
; 
; Read internal memory at address 0
; ---------------------------------
; >00<CR><LF>
;
; 00: A000
; >
;
; Read range of internal memory beginning at address 1 including address 11
; -------------------------------------------------------------------------
; >01.0b<CR><LF>
;
; 01: a000 0028 0000 0000 0000 0000 0000 0000 8500
; 0A: 0000 0000
; >
;
; Write up to 8 words to internal memory beginning at address 60 
; (no output, no verify)
; -----------------------------------------------------------------------------------------
; >60=1234 5678 9abc<CR><LF>
; >


; Assemble with "python ec16asm.py ecmon.asm"
; Modify and/or add your SOC-specific addresses in 
; icy40_def.asm and include it

include "icy40_def.asm"

org_i 0x00

; ---- constants
backspace		equ 0x08
lf				equ 0x0a
cr				equ 0x0d
esc				equ 0x1b
space			equ 0x20
dash			equ 0x2d
dot				equ 0x2e
colon			equ 0x3a
equal			equ 0x3d
greater			equ 0x3e
caret			equ 0x5e
run				equ 0x72
; ---- variables and buffers
r0				res_i 1
r1				res_i 1
r2				res_i 1
tx_addr			res_i 1
start_addr		res_i 1
end_addr		res_i 1
dump_lines		res_i 1
dump_rest		res_i 1
dump_numb		res_i 1
read_mem		res_i 1				;function pointer
write_addr		res_i 1
write_mem		res_i 1				;function pointer

rxb_len			equ 44				;rx buffer length
rxb_start		res_i rxb_len		;rx buffer start address
rxb_end			res_i 0				;label only !
rxb_eol			res_i 1				;45th place for terminating 0
p_lbuf			res_i 1				;pointer to linebuffer
p_str			res_i 1				;pointer to string

; ---- pointers to hardware addresses 
p_fart_d		res_i 1	; pointer to farts data port (r&w)
p_fart_s		res_i 1	; pointer to farts status por (r only)
p_dig_out		res_i 1


org_e reset
					jmpd boot_start

org_e irq0
					reti

org_e irq1
					reti

org_e irq2
					reti

org_e irq3
					reti
					
org_e boot_start

					movd p_dig_out dig_out
					movd a 0xec16
					movxi p_dig_out a

ecmon				movd a 0x00ff
					mov sp a
					movd p_fart_d fart_d
					movd p_fart_s fart_s
					movd p_str str_hello1
					calld print
					movd p_str str_hello2
					calld print
					

ecmon_loop			calld getline				;prompt, fill linebuffer until <CR><LF> or <ESC>
					movd p_lbuf rxb_start		;reset pointer to start of linebuffer
					movi a p_lbuf				;test if buffer is empty (ESC or empty line)
					not a						;i.e. first word in buffer = 0
					not a
					brzs ecmon_loop				;yes -> get another line
					calld parse					;else parse the line
					jmpd ecmon_loop				;get next command


getline				movd p_str str_prompt		;print prompt '>' on next line
					calld print
					movd p_lbuf rxb_start		;point to rx linebuffer
getline_loop		calld rxchar				;get a char from fart
					movd r0 backspace
					cmp a r0
					brzc getline_esc
					movd a rxb_start
					cmp a p_lbuf
					brzs getline_loop
					dec p_lbuf
					calld print_backspace
					jmpd getline_loop
getline_esc			movd r0 esc
					cmp a r0
					brzc getline_cr				;not ESC -> test for CR
					movd p_lbuf rxb_start		;ESC -> cancel input
					movd a 0					;mark end of line with zero in buffer
					movi p_lbuf a
					rets
getline_cr			movd r0 cr
					cmp a r0
					brzc getline_rx				;not CR : char received
					movd a 0					;mark end of line with zero in buffer
					movi p_lbuf a				;write received char to rx buffer
					calld rxchar				;wait for LF (will not be checked)
					rets
getline_rx			push a						;save received character
					movd a rxb_end				;test if rx buffer is full
					cmp a p_lbuf				;if full, ignore char and wait for CRLF
					pop a
					brzs getline_loop
					movi p_lbuf a				;write received char to rx buffer
					inc p_lbuf
					calld txchar				;and echo it
					jmpd getline_loop			;continue receiving


print				movxi a p_str				;fetch character to be tranmitted
					not a						;test for zero terminating the string
					not a
					brzc print_1				;non zero -> gets printed
					rets						;else end of print
print_1				inc p_str					;point to next
					calld txchar				;
					jmpd print


txchar				push a						;Accu contains character to be transfered
					movd r0 fart_tx_free	
txchar_loop			movxi a p_fart_s			;get status
					and a r0					;
					brzs txchar_loop			;wait for tx_free
					pop a						;write character
					movxi p_fart_d a
					rets


rxchar				movd r0 fart_rx_avail
rxchar_loop			movxi a p_fart_s			;get status
					and a r0					;
					brzs rxchar_loop			;wait for rx_avail
					movxi a p_fart_d			;read received character
					rets


parse				calld get_byte				;convert first two words of line buffer to byte
					brcs parse_error			;two ASCII hex digits? no -> error
					mov start_addr a			;yes -> save byte
					mov end_addr a
					movi a p_lbuf				;check next word in line buffer
					movd r0 0					;
					cmp a r0					;compare to 0 (end of line)
					brzs read_int				;yes -> command : read one word of INTMEM
					movd r0 dot					;no ->
					cmp a r0					;compare to '.'
					brzs read_int_range			;yes -> command : read range of INTMEM
					movd r0 equal				;no ->
					cmp a r0					;compare to '='
					brzs write_int_range		;yes -> command : write range of INTMEM
					
					calld get_byte				;no -> must be 16-bit value, get next byte
					brcs parse_error			;two ASCII hex digits? no -> error
					mov r0 a					;yes -> save it
					mov a start_addr			;shift future highbyte 8 bits to the left
					calld shl_8					;
					add a r0					;add second byte to form a word
					mov start_addr a			;save word
					mov end_addr a
					movi a p_lbuf				;check next word in line buffer
					movd r0 0					;
					cmp a r0					;compare to 0 (end of line)
					brzs read_ext				;yes -> command : read one word of EXTMEM
					movd r0 dot					;no ->
					cmp a r0					;compare to '.'
					brzs read_ext_range			;yes -> command : read range of EXTMEM
					movd r0 equal				;no ->
					cmp a r0					;compare to '='
					brzs write_ext_range		;yes -> command : write range of EXTMEM
					movd r0 run					;no ->
					cmp a r0					;compare to 'r'
					brzs run_from_address		;yes -> command : run
					
parse_error			mov a p_lbuf				;mark error location
					movd r1 rxb_start			;calculate number of dashes
					sub a r1					;
					mov r1 a					;
					inc r1						;compensate prompt
					calld print_crlf
					movd a dash					;print line of dashes
parse_errorline		calld txchar				;
					dec r1						;
					brzc parse_errorline		;
					movd a caret				; print '^' beneath error
					calld txchar
					set c						;error flag
					rets
					

read_int_range		inc p_lbuf					;skip dot
					calld get_byte				;get last INTMEM address
					brcs parse_error			;
					mov end_addr a				;
read_int			movd tx_addr tx_byte		;pointer to output 8-bit INTMEM addresses as values
					movd read_mem read_int_mem	;pointer to read from INTMEM
					jmpd calc_lines
					
read_ext_range		inc p_lbuf					;skip dot
					calld get_word				;get last EXTMEM address
					brcs parse_error			;
					mov end_addr a				;
read_ext			movd tx_addr tx_word		;pointer to output 16-bit EXTMEM addresses
					movd read_mem read_ext_mem	;pointer read from EXTMEM

calc_lines			mov a end_addr				;calculate the number of words
					sub a start_addr			;to be dumped
					mov dump_rest a				;result is too low by one
					inc dump_rest				;correct it
					mov a dump_rest				;full lines have 8 words
					calld shr_3					;calculate them
					mov dump_lines a			;
					movd a 0b111				;last (or only) line
					and a dump_rest				;must have 0..7 words 
					mov dump_rest a

dump_loop			movd a 0					;test if full lines have to be dumped
					cmp a dump_lines			;
					brzs dump_the_rest			;no -> dump rest
dump_full_lines		movd dump_numb 8			;yes -> dump 8 words
					calld dump_line				;
					dec dump_lines				;more full lines?
					brzc dump_full_lines		;yes -> repeat
dump_the_rest		movd a 0					;test if a rest has to be dumped
					cmp a dump_rest				;
					brzs dump_end				;no -> ready, return to prompt
					mov a dump_rest				;yes -> get the number of words
					mov dump_numb a				;
					calld dump_line				;ready, return to prompt
dump_end			rets
					
dump_line			calld print_crlf			;cursor to next line
					mov a start_addr			;print the current int/extmem address

					calli tx_addr				;in its respective format
					calld print_colspace		;print colon and space
dump_next			calli read_mem				;read word at current int/extmem address
					calld tx_word				;print value as four digit hex
					calld print_space			;print seperator
					inc start_addr				;next address
					dec dump_numb				;
					brzc dump_next
					rets					

read_int_mem		movi a start_addr			;called via function pointer read_mem
					rets

read_ext_mem		movxi a start_addr			;called via function pointer read_mem
					rets


write_int_range		movd write_mem write_intmem
					jmpd write_range

write_ext_range		movd write_mem write_extmem

write_range			mov a start_addr			;set write_addr to start_addr
					mov write_addr a
					inc p_lbuf					;skip equal sign
write_next			calld get_word				;get 16-bit data word to write to INT/EXTMEM
					brcs parse_error			;there must at least be one word to be written, else error
					calli write_mem				;write word to current int/extmem address
					inc write_addr				;point to next address
					movi a p_lbuf				;look for end of line 
					inc p_lbuf					;
					movd r0 0					;
					cmp a r0					;
					brzc write_next				;
					rets

write_intmem		movi write_addr a 			;called via function pointer read_mem
					rets

write_extmem		movxi write_addr a			;called via function pointer read_mem
					rets


run_from_address	jmpi start_addr


					;return error in Carry and value in Accu
get_word			calld get_byte
					brcs get_byte_end			;not '0'..'f' -> error
					calld shl_8
					mov r2 a
					calld get_byte
					brcs get_byte_end			;not '0'..'f' -> error
					add a r2
					rets
					
					;return error in Carry and value in Accu
get_byte			movi a p_lbuf				;p_lbuf must point to first hex digit
					calld asc2nibble			;convert it to nibble
					brcs get_byte_end			;not '0'..'f' -> error
					calld shl_4					;else shift nibble 4 bits to the left
					mov r1 a					;and save it
					inc p_lbuf					;next hex digit
					movi a p_lbuf				;
					calld asc2nibble			;must also be '0'..'f'
					brcs get_byte_end			;if not -> error
					add a r1					;else combine both nibbles to byte
					inc p_lbuf					;point to next element in line buffer
					clr c						;flag no error
get_byte_end		rets						;return error in Carry and value in Accu
					
asc2nibble			movd r0 0x30				;ASCII 0x30..0x39 => 0..9
					sub a r0					;less than 0x30 ?
					brns a2n_err				;yes => error
					movd r0 0x0a				;less than 0x3a ? 
					cmp a r0					;
					brns a2n_ok					;yes => ready
					movd r0 0x31				;ASCII 0x61..0x66 (a-f) => 0..5
					sub a r0					;less than 0x61 ?
					brns a2n_err				; => error
					movd r0 0x06				;less than 0x67 ? 
					cmp a r0					;
					brns a2n_af					;yes => ok
a2n_err				set c
					rets
a2n_af				movd r0	0x0a				;0..5 => a..f
					add a r0					
a2n_ok				clr c
					rets


tx_word				mov r2 a
					calld shr_12
					calld nibble2asc
					calld txchar
					mov a r2
					calld shr_8
					movd r1 0x000f
					and a r1
					calld nibble2asc
					calld txchar
					mov a r2
tx_byte				mov r2 a
					calld shr_4
					movd r1 0x000f
					and a r1
					calld nibble2asc
					calld txchar
					mov a r2
					and a r1
					calld nibble2asc
					calld txchar
					rets
					
nibble2asc			movd r0 0x30
					add a r0
					movd r0 0x3a
					cmp a r0
					brns n2a_end
					movd r0 0x27
					add a r0
n2a_end				rets


shl_12				calld shl_4
shl_8				calld shl_4
shl_4				shl a
					shl a
					shl a
					shl a
					rets


shr_12				calld shr_4
shr_8				calld shr_4
shr_4				shr a
shr_3				shr a
					shr a
					shr a
					rets


print_space			movd a space
					jmpd txchar					;implicit rets

print_backspace		movd p_str str_backspace
					jmpd print

print_crlf			movd p_str str_crlf
					jmpd print					;implicit rets
				
print_colspace		movd p_str str_colspace
					jmpd print					;implicit rets
					
str_backspace	dw_e backspace space backspace 0
str_prompt		dw_e cr lf greater 0
str_crlf		dw_e cr lf 0
str_colspace	dw_e colon space 0
str_hello1		dw_e cr lf "EC16 CPU on ICE40UP5K @ 20 MHz" cr lf 0
str_hello2		dw_e "16kW RAM 8000-BFFF" 0


last				nop

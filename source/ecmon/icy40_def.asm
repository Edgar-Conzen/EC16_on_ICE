; define EC16 hardware addresses

reset			equ 0x0000
irq0			equ 0x0008
irq1			equ 0x0010 
irq2			equ 0x0018
irq3			equ 0x0020
boot_start		equ 0x0028
boot_end		equ 0x01FF

led_out			equ 0x2000
btn_in			equ 0x2000

dipsw_in		equ 0x4000
dig_out			equ 0x4000
dp_out			equ	0x4001

fart_d			equ 0x6000
fart_s			equ 0x6001
fart_tx_free	equ 0x0002
fart_rx_avail	equ 0x0001

spram_start		equ 0x8000
spram_end		equ 0xBFFF

# EC16_on_ICE
EC16-CPU running ECMON @ 20MHz on an ICE40UP5K-SG48 (ICY40-Board)

* Complete Lattice Radiant project (2023.1.1.200.1 ) with VHDL sources
  * ICY40 board specific top entity
  * EC16 CPU
  * FART (ComPort, fixed 115.200-8-N-1, preset to 2 byte tx and rx buffer)

* Device utilization:
  
  * SLICE (est.)     500/2640       **19% used**
    * LUT            939/5280         18% used
    * REG            257/5280          5% used
  * LFOSC              1/1           100% used
  * SRAM               1/4            25% used
  * EBR                3/30           10% used
  * PLL                1/1           100% used
   

* EC16 assembler source code for the ECMON monitor program including ec16asm.py assembler

The EC16 CPU is word oriented, i.e both data and address bus are 16 bit wide. There are two completely separate memory spaces, the 64K x 16 bit external memory space (EXTMEM) and a small but faster accessible 256 x 16 bit internal memory (INTMEM). 

While the EXTMEM space can be populated as required with on-chip ram, rom and I/O devices, the INTMEM space is fully populated with an EBRam and can be used as registers, pointers to INTMEM or EXTMEM locations, scratchpad ram or stack space.

The EC16 has four maskable prioritized interrupt inputs. 

It has 49 instructions, 45 of which use only 1 word of program memory while the other 4 use two words. 
Thanks to the instruction prefetch the execution speed is rather high
  * 17 instructions execute in 1 clock cycle
  * 15 instructions execute in 2 clock cycles
  * 9 instructions execute in 3 clock cycles
  * 8 instructions (branch) execute in 1 resp. 2 clock cycles (no branch / branch)

![EC16 CPU running on ICY40](EC16%20on%20ICY40.jpg)
![Top of design](EC16_on_ICE_view.jpg)

The design was first developed with logisim-evolution and then transferred to VHDL.

![EC16 in Logisim Evolution](/source/ec16_source/EC16%20Logisim%20Evolution%20top%20sheet.jpg)


-- *********************************
-- ec16_alu.vhd
--
-- Rev 1.0.0  for ICY40
-- 24. April 2023 by Edgar Conzen
-- 
-- ALU - Arithmetic Logic Unit
--
-- *********************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;


	
entity ec16_alu is
	port(
		fn			: in std_logic_vector (3 downto 0);
		a_in		: in std_logic_vector (15 downto 0);
		b_in		: in std_logic_vector (15 downto 0);
		res_out		: out std_logic_vector (15 downto 0);
		c_in		: in std_logic;
		c_out		: out std_logic;
		over		: out std_logic;
		neg			: out std_logic;
		zero		: out std_logic
);
end entity;

	
architecture syn of ec16_alu is

	signal a, b		: std_logic_vector (15 downto 0);
	signal sum		: std_logic_vector (16 downto 0);
	signal logic	: std_logic_vector (15 downto 0);
	signal shift	: std_logic_vector (15 downto 0);
	signal result	: std_logic_vector (15 downto 0);
	signal c_shift	: std_logic;
	signal c_arith	: std_logic;
	attribute syn_keep: boolean;
	attribute syn_keep of sum: signal is true;
	attribute syn_keep of logic: signal is true;
	attribute syn_keep of shift: signal is true;
	attribute syn_keep of result: signal is true;
	attribute syn_keep of c_shift: signal is true;
	attribute syn_keep of c_arith: signal is true;
	
begin
		
	-- fn (function) is encoded in bit 11..8 of opcode (0x4 - fn - INTMEM)
	--
	-- 0000=SUBB
	-- 0001=ADDC
	-- 0010=SUB
	-- 0011=ADD
	-- 0100=CMP
	-- 0101=xxx
	-- 0110=DEC
	-- 0111=INC
	-- 1000=ROL
	-- 1001=ROR
	-- 1010=SHL
	-- 1011=SHR
	-- 1100=AND
	-- 1101=OR																																													
	-- 1110=XOR
	-- 1111=NOT


	-- for the arithmetic operations SUB / ADD / DEC B /INC B 
	-- modified instances of a_in, b_in and c_in are used
	
	with fn select 
		c_arith <=	'0' when "0011" | "0110" | "0111", -- ADD / DEC (B) / INC (B)
					'1' when "0010" | "0100", -- SUB / CMP
					not c_in when "0000", -- SUBB
					c_in when others; -- ADDC (and others)

	with fn select
		a <=	x"FFFF" when "0110", -- DEC (B)
				x"0001" when "0111", -- INC (B)
				a_in when others;
		
	with fn select
		b <=	not (b_in) when "0000" | "0010" | "0100", -- SUBB / SUB / CMP
				b_in when others; 

	sum <= ('0' & a) + ('0' & b) + ("" & c_arith);


	--  logic operations AND / OR / XOR / NOT
	with fn select
		logic <=	(a_in and b_in) when "1100", -- AND
					(a_in or b_in) when "1101",  -- OR
					(a_in xor b_in) when "1110", -- XOR
					not a_in when others;  -- not (and others)
					
	
	-- rotate/shift left/right 
	with fn select
		shift	<=	a_in(14 downto 0) & c_in when "1000", -- ROL
					c_in & a_in(15 downto 1) when "1001", -- ROR
					a_in(14 downto 0) & '0' when "1010",  -- SHL
					'0' & a_in(15 downto 1) when "1011",  -- SHR
					x"0000" when others;

	with fn select
		c_shift	<=	a_in(15) when "1000" | "1010",  -- ROL /SHL
					a_in(0) when others; -- ROR /SHR (and others)
					
	
	-- select output function according to fn
	with fn select
		result	<=	sum (15 downto 0) when "0000" | "0001" | "0010" | "0011" | "0100" | "0101" | "0110" | "0111",
					shift when "1000" | "1001" | "1010" | "1011",
					logic when others;
	
	res_out <= result;
	


	-- carry output
	with fn select
		c_out <=	not sum(16) when "0000" | "0010" | "0100" | "0110", -- SUBB / SUB / CMP / DEC (B)
					sum(16) when "0001" | "0011" | "0111", -- ADDC / ADD / INC (B)
					c_shift when "1000" | "1001" | "1010" | "1011", -- ROL / ROR / SHL / SHR
					c_in when others; -- keep carry

	
	-- neg output
	neg <= result(15);
	
	-- over(flow) output
	-- Addition : (NEG + NEG = POS)  OR  (POS + POS = NEG)         OV =  S15 & !A15 &  !B15  |  !S15 & A15 & B15  
	-- Subtraction :  (POS - NEG = NEG)  OR  (NEG - POS = POS)     OV =  !S15 & A15 &  !B15  |  S15 & !A15 & B15
	with fn select
		over <=		( (not a_in(15)) and b_in(15) and sum(15) ) or ( a_in(15) and (not b_in(15)) and (not sum(15)) ) when "0000" | "0010" | "0100", -- A-B, CMP
					( (not a_in(15)) and (not b_in(15)) and sum(15) ) or ( a_in(15) and b_in(15) and (not sum(15)) ) when "0001" | "0011", -- A+B
					'0' when others;
	
	-- zero flag output
	zero <= '1' when result = x"0000" else '0';

end architecture;
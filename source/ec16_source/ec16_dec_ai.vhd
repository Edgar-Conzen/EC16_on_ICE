-- *********************************
-- ec16_dec_ai.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- DEC_AI - decoder for ACCU input
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_dec_ai is
	port (
		ai			: out std_logic_vector (1 downto 0);
		opc			: in std_logic_vector (15 downto 8);
		state_1		: in std_logic;
		state_2		: in std_logic
	);
end entity;

architecture syn of ec16_dec_ai is

	signal x1,x2,x3,x4	: std_logic;
	signal y1,y2,y3		: std_logic;
	
begin

	x1 <= '1' when opc(15 downto 12) = "0001"  else '0';
	x2 <= '1' when (opc(15 downto 12) & opc(9) & state_1) = "010101"  else '0';
	x3 <= '1' when opc(15 downto 12) = "1000"  else '0';
	x4 <= '1' when (opc(15 downto 13) & opc(8) & state_1) = "01101"  else '0';
	y1 <= '1' when opc(11 downto 8) = "0100"  else '0';
	y2 <= '1' when (opc(10 downto 8) & state_2) = "0001"  else '0';
	y3 <= '1' when (opc(10 downto 8) & state_2) = "0111"  else '0';
	
	ai(0) <= (x1 and y1) or x2 or (x3 and y2);
	
	ai(1) <= x4 or (x3 and y3) or x2 or (x3 and y2);
				
end architecture;

-- *********************************
-- ec16_dec_ia.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- DEC_IA - decoder for Int Mem address
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_dec_ia is
	port (
		ia			: out std_logic_vector (1 downto 0);
		opc			: in std_logic_vector (15 downto 8);
		state_0		: in std_logic;
		state_1		: in std_logic
	);
end entity;

architecture syn of ec16_dec_ia is

	signal x1,x2,x3,x4,x5,x6			: std_logic;
	signal y1,y2,y3,y4,y5,y6,y7,y8,y9	: std_logic;
	
begin

	x1 <= '1' when opc(15 downto 12) = "0001"  else '0';
	x2 <= '1' when opc(15 downto 12) = "0100"  else '0';
	x3 <= '1' when opc(15 downto 12) = "0101"  else '0';
	x4 <= '1' when opc(15 downto 12) = "1000"  else '0';
	x5 <= '1' when (opc(15 downto 13) & opc(9)) = "1011"  else '0';
	x6 <= '1' when opc(15 downto 12) = "1010"  else '0';

	y1 <= '1' when opc(11 downto 8) = "0110"  else '0';
	y2 <= '1' when (opc(11 downto 9) & state_1) = "0111"  else '0';
	y3 <= '1' when opc(11 downto 8) = "0000"  else '0';
	y4 <= '1' when opc(11 downto 8) = "0010"  else '0';
	y5 <= '1' when (opc(11 downto 10) & state_0) = "001"  else '0';
	y6 <= '1' when opc(11 downto 8) = "0101"  else '0';
	y7 <= '1' when opc(11 downto 8) = "0001"  else '0';
	y8 <= '1' when (opc(11 downto 9) & state_0) = "0101"  else '0';
	y9 <= '1' when (opc(11 downto 10) & opc(8) & state_1) = "0011"  else '0';
	
	ia(0) <=	(x1 and y1) or
				(x2 and state_0) or
				-- (x2 and y2) or       Fehler
				(x3 and y3 and state_0) or
				(x3 and y4) or
				(x4 and y5) or
				(x4 and y3 and state_1) or
				(x5 and state_0);
				
	ia(1) <=	(x3 and y4 and state_1) or
				(x1 and y6) or
				(x3 and y7 and state_0) or
				(x4 and y3 and state_1) or
				(x4 and y8) or
				(x6 and y9);
	
	
end architecture;

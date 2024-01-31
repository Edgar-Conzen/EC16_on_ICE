-- *********************************
-- ec16_dec_ae.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- DEC_AE - decoder for AKKU write enable
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_dec_ae is
	port (
		ae			: out std_logic;
		opc			: in std_logic_vector (15 downto 8);
		state_1		: in std_logic;
		state_2		: in std_logic
	);
end entity;

architecture syn of ec16_dec_ae is

	signal x1,x2,x3,x4,x5,x6	: std_logic;
	signal y1,y2,y3,y4,y5,y6,y7	: std_logic;
	
begin

	x1 <= '1' when opc(15 downto 12) = "0001"  else '0';
	x2 <= '1' when opc(15 downto 12) = "0010"  else '0';
	x3 <= '1' when opc(15 downto 12) = "0100"  else '0';
	x4 <= '1' when opc(15 downto 12) = "0101"  else '0';
	x5 <= '1' when opc(15 downto 13) = "011"  else '0';
	x6 <= '1' when opc(15 downto 12) = "1000"  else '0';


	y1 <= '1' when opc(11 downto 8) = "0100"  else '0';
	y2 <= '1' when (opc(11 downto 10) & state_1) = "001"  else '0';
	y3 <= '1' when (opc(11 downto 10) & state_1) = "111"  else '0';
	y4 <= '1' when (opc(9 downto 9) & state_1) = "01"  else '0';
	y5 <= '1' when (opc(8 downto 8) & state_1) = "01"  else '0';
	y6 <= '1' when (opc(10 downto 8) & state_2) = "0001"  else '0';
	y7 <= '1' when (opc(10 downto 8) & state_2) = "0111"  else '0';

	
	ae <=	(x1 and y1) or
			x2 or
			(x3 and y2) or
			(x3 and y3) or
			(x4 and y4) or
			(x5 and y5) or
			(x6 and y6) or
			(x6 and y7);
			
			

end architecture;

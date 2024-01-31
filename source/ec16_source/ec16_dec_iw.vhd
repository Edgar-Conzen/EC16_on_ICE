-- *********************************
-- ec16_dec_iw.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- DEC_IW - decoder for Int Mem write
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_dec_iw is
	port (
		iw			: out std_logic;
		opc			: in std_logic_vector (15 downto 8);
		state_1		: in std_logic
	);
end entity;

architecture syn of ec16_dec_iw is

	signal x1,x2,x3,x4,x5		: std_logic;
	signal y1,y2,y3,y4,y5,y6	: std_logic;
	
begin

	x1 <= '1' when opc(15 downto 12) = "0001"  else '0';
	x2 <= '1' when opc(15 downto 12) = "0100"  else '0';
	x3 <= '1' when opc(15 downto 12) = "0101"  else '0';
	x4 <= '1' when opc(15 downto 12) = "0110"  else '0';
	x5 <= '1' when opc(15 downto 12) = "1010"  else '0';
	y1 <= '1' when opc(11 downto 8) = "0101"  else '0';
	y2 <= '1' when opc(11 downto 8) = "0110"  else '0';
	y3 <= '1' when (opc(11 downto 9) & state_1) = "0111"  else '0';
	y4 <= '1' when (opc(11 downto 8) & state_1) = "00101"  else '0';
	y5 <= '1' when (opc(11 downto 8) & state_1) = "00011"  else '0';
	y6 <= '1' when (opc(11 downto 10) & opc(8) & state_1) = "0011"  else '0';

	iw <=	(x1 and y1) or
			(x1 and y2) or
			(x2 and y3) or
			(x3 and y4) or
			(x4 and y5) or
			(x5 and y6);
end architecture;

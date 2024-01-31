-- *********************************
-- ec16_dec_ir.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- DEC_IR - decoder for Int Mem read
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_dec_ir is
	port (
		ir			: out std_logic;
		opc			: in std_logic_vector (15 downto 8);
		state_0		: in std_logic;
		state_1		: in std_logic
	);
end entity;

architecture syn of ec16_dec_ir is

	signal x1,x2,x3,x4	: std_logic;
	signal y1 			: std_logic;
	
begin

	x1 <= '1' when (opc(15 downto 13) & state_0) = "0101"  else '0';
	x2 <= '1' when (opc(15 downto 13) & state_0) = "1001"  else '0';
	x3 <= '1' when (opc(15 downto 13) & opc(9) & state_0)= "10111"  else '0';
	x4 <= '1' when opc(15 downto 12) = "1000"  else '0';

	y1 <= '1' when opc(11 downto 8) = "0000"  else '0';
	
	ir <=	x1 or x2 or x3 or (x4 and y1 and state_1);

end architecture;

-- *********************************
-- ec16_dec_oe.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- DEC_OE - decoder for OPCode copy enable
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_dec_oe is
	port (
		oe			: out std_logic;
		opc			: in std_logic_vector (15 downto 8);
		state_0		: in std_logic;
		branch		: in std_logic
	);
end entity;

architecture syn of ec16_dec_oe is

	signal o1, o2, o3	: std_logic;
	
begin
	
	o1 <= '1' when (opc(15 downto 14) & state_0) = "011" else '0';
	o2 <= '1' when (opc(15 downto 14) & state_0) = "101" else '0';
	o3 <= '1' when (opc(15 downto 14) & state_0 & branch) = "1111" else '0';

	oe <= o1 or o2 or o3;
	
end architecture;

-- *********************************
-- ec16_dec_id.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- DEC_ID - decoder for Int Mem data
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_dec_id is
	port (
		id			: out std_logic_vector (1 downto 0);
		opc			: in std_logic_vector (15 downto 8);
		state_1		: in std_logic
	);
end entity;

architecture syn of ec16_dec_id is

	signal o1, o2, o3	: std_logic;
	
begin

	o1 <= '1' when (opc(15 downto 9) & state_1) = "01000111" else '0';
	o2 <= '1' when (opc(15 downto 8) & state_1) = "011000011" else '0';
	o3 <= '1' when (opc(15 downto 10) & opc(8) & state_1) = "10100011" else '0';
	
	id(0) <= o1 or o2;
	id(1) <= o1 or o3;
	
end architecture;

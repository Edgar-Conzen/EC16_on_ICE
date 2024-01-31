-- *********************************
-- ec16_dec_spf.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- DEC_SPF - decoder for Stack Pointer function
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_dec_spf is
	port (
		spf			: out std_logic_vector (1 downto 0);
		opc			: in std_logic_vector (15 downto 8);
		state_0		: in std_logic;
		state_1		: in std_logic
	);
end entity;

architecture syn of ec16_dec_spf is

	signal o1, o2, o3, o4, o5	: std_logic;
	
begin
	
	o1 <= '1' when opc(15 downto 8) = "00010011" else '0';
	o2 <= '1' when (opc(15 downto 8) & state_0) = "010100011" else '0';
	o3 <= '1' when (opc(15 downto 9) & state_0) = "10000101" else '0';
	o4 <= '1' when opc(15 downto 8) = "00010101" else '0';
	o5 <= '1' when (opc(15 downto 10) & opc(8) & state_1) = "10100011" else '0';
	
	spf(0) <= o1 or o2 or o3;
	spf(1) <= o2 or o3 or o4 or o5;
	
end architecture;

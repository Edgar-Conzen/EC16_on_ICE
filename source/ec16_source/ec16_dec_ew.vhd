-- *********************************
-- ec16_dec_ew.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- DEC_EW - decoder for Ext Mem write (MOVX @Rn A)
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_dec_ew is
	port (
		ew			: out std_logic;
		opc			: in std_logic_vector (15 downto 8);
		state_1		: in std_logic
	);
end entity;

architecture syn of ec16_dec_ew is

begin
	
	ew <= '1' when (opc(15 downto 8) & state_1) = "100000101" else '0';
	
end architecture;

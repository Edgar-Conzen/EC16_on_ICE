-- *********************************
-- ec16_dec_ea.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- DEC_EA - decoder for Ext Mem access (MOVX)
-- controls input mux to address of ExtMem
-- 1 : address from IntMem 
-- 0 : address from program Counter 
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_dec_ea is
	port (
		ea			: out std_logic;
		opc			: in std_logic_vector (15 downto 8);
		state_1		: in std_logic
	);
end entity;

architecture syn of ec16_dec_ea is

begin
	
	ea <= '1' when (opc(15 downto 9) & state_1) = "10000011" else '0';
	
end architecture;

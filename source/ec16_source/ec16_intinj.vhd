-- *********************************
-- ec16_intinj.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- INTINJ - interrupt vector injection
-- When an interrupt is taken, this module injects 
-- first a CALL and then the int vector address 
-- into the instruction stream
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_intinj is
	port (
		iv		: in std_logic_vector (7 downto 0);
		vs		: in std_logic;
		cvi		: out std_logic_vector (15 downto 0)
	);
end entity;

architecture syn of ec16_intinj is

begin

	cvi <= x"a100" when vs = '0'  else (x"00" & iv);
	
end architecture;

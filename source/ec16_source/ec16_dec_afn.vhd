-- *********************************
-- ec16_dec_afn.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- DEC_AFN - decoder for ALU function
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_dec_afn is
	port (
		afn			: out std_logic_vector (3 downto 0);
		opc			: in std_logic_vector (15 downto 8)
	);
end entity;

architecture syn of ec16_dec_afn is

begin

	afn <= opc(11 downto 8);
		
end architecture;

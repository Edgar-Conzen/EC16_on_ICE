-- *********************************
-- ec16_dec_si.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- DEC_SI - decoder for Status Input select
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_dec_si is
	port (
		si			: out std_logic;
		opc			: in std_logic_vector (15 downto 8)
	);
end entity;

architecture syn of ec16_dec_si is

begin

	si <= '1' when opc(15 downto 8) = "00010010"  else '0';
	
end architecture;

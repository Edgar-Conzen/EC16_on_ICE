-- *********************************
-- ec16_dec_ce.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- DEC_CE - decoder for Carry write enable
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_dec_ce is
	port (
		ce			: out std_logic;
		opc			: in std_logic_vector (15 downto 8)
	);
end entity;

architecture syn of ec16_dec_ce is

begin

	ce <= '1' when opc(15 downto 9) = "0001000"  else '0';

end architecture;

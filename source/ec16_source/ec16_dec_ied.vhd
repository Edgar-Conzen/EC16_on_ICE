-- *********************************
-- ec16_dec_ied.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- DEC_IED - decoder for Int Enable data
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_dec_ied is
	port (
		ied			: out std_logic;
		opc			: in std_logic_vector (15 downto 8)
	);
end entity;

architecture syn of ec16_dec_ied is

begin

	ied <= '1' when opc(15 downto 8) = "00000011"  else '0';

end architecture;

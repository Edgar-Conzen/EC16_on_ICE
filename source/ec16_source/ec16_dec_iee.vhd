-- *********************************
-- ec16_dec_iee.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- DEC_IEE - decoder for Int Enable enable
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_dec_iee is
	port (
		iee			: out std_logic;
		opc			: in std_logic_vector (15 downto 8)
	);
end entity;

architecture syn of ec16_dec_iee is

begin

	iee <= '1' when opc(15 downto 9) = "0000001"  else '0';

end architecture;

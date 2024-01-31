-- *********************************
-- ec16_dec_im.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- DEC_IM - decoder for set Int Mask
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_dec_im is
	port (
		im			: out std_logic;
		opc			: in std_logic_vector (15 downto 8)
	);
end entity;

architecture syn of ec16_dec_im is

begin

	im <= '1' when opc(15 downto 8) = "00000101"  else '0';

end architecture;

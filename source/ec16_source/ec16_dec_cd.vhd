-- *********************************
-- ec16_dec_cd.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- DEC_CD - decoder for Carry write data
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_dec_cd is
	port (
		cd			: out std_logic;
		opc			: in std_logic_vector (15 downto 8)
	);
end entity;

architecture syn of ec16_dec_cd is

begin

	cd <= '1' when opc(15 downto 8) = "00010001"  else '0';

end architecture;

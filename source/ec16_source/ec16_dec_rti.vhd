-- *********************************
-- ec16_dec_rti.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- DEC_RTI - decoder for Return from Int
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_dec_rti is
	port (
		rti			: out std_logic;
		opc			: in std_logic_vector (15 downto 8);
		state_2		: in std_logic
	);
end entity;

architecture syn of ec16_dec_rti is

begin

	rti <= '1' when (opc(15 downto 8) & state_2) = "100001011"  else '0';

end architecture;

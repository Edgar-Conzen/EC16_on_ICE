-- *********************************
-- ec16_dec_se.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- DEC_SE - decoder for Status write enable
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_dec_se is
	port (
		se			: out std_logic;
		opc			: in std_logic_vector (15 downto 8);
		state_1		: in std_logic
	);
end entity;

architecture syn of ec16_dec_se is

	signal x1,x2,x3	: std_logic;
	signal y1		: std_logic;
	
begin

	x1 <= '1' when opc(15 downto 12) = "0001"  else '0';
	x2 <= '1' when opc(15 downto 12) = "0010"  else '0';
	x3 <= '1' when opc(15 downto 12) = "0100"  else '0';

	y1 <= '1' when opc(11 downto 8) = "0010"  else '0';

	se <=	(x1 and y1) or
			x2 or
			(x3 and state_1);

end architecture;

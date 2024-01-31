-- *********************************
-- ec16_dec_pi.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- Control line PI 
-- controls input mux to Program Counter-- 1 : address from ExtMem 
-- 0 : address from IntMem 
-- 
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_dec_pi is
	port (
		pi			: out std_logic;
		opc			: in std_logic_vector (15 downto 8);
		state_0		: in std_logic;
		state_1		: in std_logic;
		branch		: in std_logic
	);
end entity;

architecture syn of ec16_dec_pi is

	signal o1, o2		: std_logic;
	
begin

	o1 <= '1' when ((opc(15 downto 12) & opc(9)) = "10100") else '0';
	o2 <= '1' when (opc(15 downto 12) = "1100") else '0';
	
	pi <= 	(o1 and state_1) or
			(o2 and state_0 and branch);


end architecture;

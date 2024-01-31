-- *********************************
-- ec16_dec_pf.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- Control lines PF(1..0) (input PCF of program counter)
-- 00=INC   01=HLT   10=BRA   11=JMP
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_dec_pf is
	port (
		pf			: out std_logic_vector (1 downto 0);
		opc			: in std_logic_vector (15 downto 8);
		state_0		: in std_logic;
		state_1		: in std_logic;
		branch		: in std_logic;
		int			: in std_logic
	);
end entity;

architecture syn of ec16_dec_pf is

	signal o1, o2, o3, o4, o5, o6	: std_logic;

begin

	o1 <= '1' when opc(15 downto 13) = "010" else '0';
	o2 <= '1' when opc(15 downto 13) = "100" else '0';
	o3 <= '1' when opc(15 downto 13) = "101" else '0';
	o4 <= '1' when opc(15 downto 13) & opc(9) = "1011" else '0';
	o5 <= '1' when opc(15 downto 14) & opc(10) = "101" else '0';
	o6 <= '1' when opc(15 downto 14) = "11" else '0';

	pf(0) <=	int or
				(o1 and state_0) or
				(o2 and state_0) or
				(o2 and state_1) or
				(o3 and state_1) or
				(o4 and state_0);
				
	pf(1) <=	not int and (
				(o5 and state_1) or
				(o3 and state_1) or
				(o6 and state_0 and branch) );
				
end architecture;

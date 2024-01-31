-- *********************************
-- ec16_dec_er.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- DEC_ER - decoder for Ext Mem read
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_dec_er is
	port (
		er			: out std_logic;
		opc			: in std_logic_vector (15 downto 8);
		state_r		: in std_logic;
		state_0		: in std_logic;
		state_1		: in std_logic;
		state_2		: in std_logic;
		branch		: in std_logic;
		int			: in std_logic
	);
end entity;

architecture syn of ec16_dec_er is

	signal o1, o2, o3, o4, o5, o6, o7, o8	: std_logic;
	
begin

	o1 <= '1' when (opc(15 downto 14) & state_0) = "001" else '0';
	o2 <= '1' when (opc(15 downto 14) & state_1) = "011" else '0';
	o3 <= '1' when (opc(15 downto 14) & state_2) = "101" else '0';
	o4 <= '1' when (opc(15 downto 14) & state_0 & branch) = "1110" else '0';
	o5 <= '1' when (opc(15 downto 14) & state_1 & branch) = "1111" else '0';
	o6 <= '1' when (opc(15 downto 13) & state_0) = "0111" else '0';
	o7 <= '1' when (opc(15 downto 8) & state_1) = "100000111" else '0';
	o8 <= '1' when (opc(15 downto 13) & opc(9) & state_0) = "10101" else '0';
	
	er <=	not int and (
			state_r or o1 or o2 or o3 or o4 or o5 or o6 or o7 or o8);

end architecture;

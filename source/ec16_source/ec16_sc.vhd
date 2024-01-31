-- *********************************
-- ec16_sc.vhd
--
-- Rev 1.0.0  for ICY40
-- 26. April 2023 by Edgar Conzen
-- 
-- SC - State Counter
-- Counts the states of the instruction currently executed
--
-- *********************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

	
entity ec16_sc is
	port(
		clk			: in std_logic;
		rst			: in std_logic;
		flags		: in std_logic_vector (4 downto 0);
		opc			: in std_logic_vector (15 downto 8);
		state_r		: out std_logic;
		state_0		: out std_logic;
		state_1		: out std_logic;
		state_2		: out std_logic;
		branch		: out std_logic
	);
end entity;


architecture syn of ec16_sc is
	
	signal s_state_r	: std_logic;
	signal s_state_0	: std_logic;
	signal s_state_1	: std_logic;
	signal s_state_2	: std_logic;
	signal s_branch		: std_logic;	

begin

	p_state_r : process (clk)
	begin
		if rising_edge (clk) then
			s_state_r <= rst;
		end if;
	end process p_state_r;


	p_state_0 : process (clk)
	begin
		if rising_edge (clk) then
			if rst='1' then
				s_state_0 <= '0';
			else
				s_state_0 <= (s_state_r and not rst) or 
							(not opc(15) and not opc(14)) or
							(not opc(15) and opc(14) and s_state_1) or
							(opc(15) and not opc(14) and s_state_2) or
							(opc(15) and opc(14) and not s_branch) or
							(opc(15) and opc(14) and s_branch and s_state_1);
			end if;
		end if;
	end process p_state_0;


	p_state_1 : process (clk)
	begin
		if rising_edge (clk) then
			if rst='1' then
				s_state_1 <= '0';
			else
				s_state_1 <= (not opc(15) and opc(14) and s_state_0) or
							(opc(15) and not opc(14) and s_state_0) or
							(opc(15) and opc(14) and s_state_0 and s_branch);
			end if;
		end if;
	end process p_state_1;

	
	p_state_2 : process (clk)
	begin
		if rising_edge (clk) then
			if rst='1' then
				s_state_2 <= '0';
			else
				s_state_2 <= opc(15) and not opc(14) and s_state_1;
			end if;
		end if;
	end process p_state_2;

	
	s_branch <= ( (flags(0) xnor opc(10)) and (not opc(9) and not opc(8)) ) or
				( (flags(1) xnor opc(10)) and (not opc(9) and opc(8)) ) or
				( (flags(2) xnor opc(10)) and (opc(9) and not opc(8)) ) or
				( (flags(3) xnor opc(10)) and (opc(9) and opc(8)) );
				

	state_r	<= s_state_r;
    state_0	<= s_state_0;
	state_1	<= s_state_1;
	state_2	<= s_state_2;
	branch	<= s_branch;

end architecture;
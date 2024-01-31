-- *********************************
-- ec16_sf.vhd
--
-- Rev 1.0.0  for ICY40
-- 20. April 2023 by Edgar Conzen
-- 
-- SF - Status Flags
--
-- *********************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

	
entity ec16_sf is
	port(
		clk			: in std_logic;
		rst			: in std_logic;
		se			: in std_logic;
		ce			: in std_logic;
		cd			: in std_logic;
		iee			: in std_logic;
		ied			: in std_logic;
		sfi			: in std_logic_vector (4 downto 0);
		sfo			: out std_logic_vector (4 downto 0)
	);
end entity;

	
architecture syn of ec16_sf is

	signal carry	: std_logic;
	signal over		: std_logic;
	signal neg		: std_logic;
	signal zero		: std_logic;
	signal inte		: std_logic;

begin

	p_carry : process (clk, rst)
	begin
		if rst='1' then
			carry <= '0';
		elsif rising_edge(clk) then
			if ce='1' then
				carry <= cd;
			elsif se='1' then
				carry <= sfi(0);
			end if;
		end if;
	end process p_carry;

	p_over : process (clk, rst)
	begin
		if rst='1' then
			over <= '0';
		elsif rising_edge(clk) and se='1' then
			over <= sfi(1);
		end if;
	end process p_over;

	p_neg : process (clk, rst)
	begin
		if rst='1' then
			neg <= '0';
		elsif rising_edge(clk) and se='1' then
			neg <= sfi(2);
		end if;
	end process p_neg;

	p_zero : process (clk, rst)
	begin
		if rst='1' then
			zero <= '0';
		elsif rising_edge(clk) and se='1' then
			zero <= sfi(3);
		end if;
	end process p_zero;

	p_inte : process (clk, rst)
	begin
		if rst='1' then
			inte <= '0';
		elsif rising_edge(clk) then
			if iee='1' then
				inte <= ied;
			elsif se='1' then
				inte <= sfi(4);
			end if;
		end if;
	end process p_inte;
	
	sfo <= inte & zero & neg & over & carry;

end architecture;
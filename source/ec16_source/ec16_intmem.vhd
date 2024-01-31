-- *********************************
-- ec16_intmem.vhd
--
-- Rev 1.0.0  for ICY40
-- 19. April 2023 by Edgar Conzen
-- 
-- INTMEM - internal Memory
-- 256x16 synchronuous RAM 
-- used as register bank
-- *********************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

	
entity ec16_intmem is
	port(
		clk			: in std_logic;
		addr		: in std_logic_vector (7 downto 0);
		din			: in std_logic_vector (15 downto 0);
		dout		: out std_logic_vector (15 downto 0);
		re			: in std_logic;
		we			: in std_logic
	);
end entity;

	
architecture syn of ec16_intmem is

	type ram_type is array (0 to 255) of std_logic_vector(15 downto 0);
	signal ram : ram_type;
	
begin
	
	readram : process (clk)
	begin
		if rising_edge (clk) and re = '1' then
			dout <= ram(to_integer(unsigned(addr)));
		end if;
	end process;

	writeram : process (clk)
	begin
		if rising_edge (clk) and we = '1' then
			ram(to_integer(unsigned(addr))) <= din;
		end if;
	end process;

end architecture;
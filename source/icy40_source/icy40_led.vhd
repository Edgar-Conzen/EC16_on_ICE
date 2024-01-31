-- *********************************
-- ICY40_LED.VHD
--
-- 28. January 2024 by Edgar Conzen
-- 
--
-- simple I/O block for the LEDs 
-- of the ICY40 FPGA lerning board
--
-- ####################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity icy40_led is
	port(
		clk				: in std_logic;
		sel				: in std_logic;
		we				: in std_logic;
		din				: in std_logic_vector(4 downto 0);
		ledport			: out std_logic_vector(4 downto 0)
	);
end entity;
		
architecture syn of icy40_led is
	signal s_ledport	: std_logic_vector(4 downto 0);
begin
	-- LEDs output port
	led_outport : process (clk)
	begin
		if rising_edge(clk) then
			if sel='1' and we='1' then
				s_ledport <= din(4 downto 0);
			end if;
		end if;
	end process;
	
	ledport <= s_ledport;
end architecture;

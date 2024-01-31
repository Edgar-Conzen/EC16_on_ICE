library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fart_package.all;

entity rx_baudtick is
	generic(clockspeed : integer := 12500000);
	port(
		clk		: in std_logic;
		rx_active		: in std_logic;
		rx_tick			: out std_logic);
end entity rx_baudtick;

architecture synth of rx_baudtick is

	-- The baudrate of the FART is fixed at 115200 baud and is derived from the clk input signal
	-- bcc_wrap (baud clock count wrap) is calculated as clockspeed / baud rate
	-- e.g.:  12500000Hz / 115200 = 108.51 => 108 x 115200 = 12441600 => deviation < 0,5%
	
	constant bcc_wrap		: integer := clockspeed / 115200;
	constant rx_sample		: integer := (bcc_wrap + 1) / 2;
	signal rx_clk_counter : integer range 0 to bcc_wrap;
	
begin

	-- up-counter, wrapping to 0 at bcc_wrap
	-- stopped and reset to 0 by rx_active='0'
	-- free running when rx_active='1'
	pr_rx_clk_counter : process(clk, rx_active)
	begin
		if rx_active='0' then
			rx_clk_counter <= 0;
		elsif rising_edge(clk) then
			if rx_clk_counter = bcc_wrap then
				rx_clk_counter <= 0;
			else 
				rx_clk_counter <= rx_clk_counter + 1;
			end if;
		end if;
	end process pr_rx_clk_counter;


	-- rx_tick issues a 1-pulse of length T(clk) 
	-- each time rx_clk_counter = rx_sample
	pr_rx_tick : process(clk)
	begin		
		if rising_edge(clk) then
			if rx_clk_counter=rx_sample then
				rx_tick <= '1';
			else
				rx_tick <= '0';
			end if;
		end if;
	end process pr_rx_tick;
	

end architecture synth;
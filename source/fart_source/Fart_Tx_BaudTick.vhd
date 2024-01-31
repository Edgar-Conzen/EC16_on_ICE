library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fart_package.all;

entity tx_baudtick is
	generic(clockspeed : integer := 12500000);
	port(
		clk				: in std_logic;
		tx_active		: in std_logic;
		tx_tick			: out std_logic);
end entity tx_baudtick;

architecture synth of tx_baudtick is

	-- The baudrate of the FART is fixed at 115200 baud and is derived from the clk input signal
	-- bcc_wrap (baud clock count wrap) is calculated as clockspeed / baud rate
	-- e.g.:  12500000Hz / 115200 = 108.51 => 108 x 115200 = 12441600 => deviation < 0,5%
	
	constant bcc_wrap		:integer := clockspeed / 115200;
	signal tx_clk_counter : integer range 0 to bcc_wrap;
		
begin

	-- up-counter, wrapping to 0 at bcc_wrap
	-- stopped and reset to 0 by tx_active='0'
	-- free running when tx_active='1'
	pr_tx_clk_counter : process(clk, tx_active)
	begin
		if tx_active='0' then
			tx_clk_counter <= 0;
		elsif rising_edge(clk) then
			if tx_clk_counter = bcc_wrap then
				tx_clk_counter <= 0;
			else 
				tx_clk_counter <= tx_clk_counter + 1;
			end if;
		end if;
	end process pr_tx_clk_counter;


	-- tx_tick issues a 1-pulse of length T(clk) 
	-- each time tx_clk_counter wraps to zero
	pr_tx_tick : process(clk)
	begin		
		if rising_edge(clk) then
			if tx_clk_counter=bcc_wrap then
				tx_tick <= '1';
			else
				tx_tick <= '0';
			end if;
		end if;
	end process pr_tx_tick;
	

end architecture synth;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fart_package.all;

entity rx_fsm is
	generic(clockspeed : integer := 12500000);
	port(
		reset			: in std_logic;
		clk				: in std_logic;
		rx_start		: in std_logic;
		rx_sr			: out std_logic_vector (7 downto 0);
		rx_sr_trans		: out std_logic;
		rxd_in			: in std_logic);
end entity rx_fsm;


architecture synth of rx_fsm is
	
	signal sff1, sff2, sff3 : std_logic;
	signal rx_tick			: std_logic;
	signal rx_active		: std_logic;
	
	signal rx_shift_cs		: t_shift_state;
	signal rx_shift_ns		: t_shift_state;
	
	signal shift_reg		: std_logic_vector (7 downto 0);
	
begin

	c_rx_baudtick : rx_baudtick
	generic map(clockspeed => clockspeed)
	port map(
		clk				=> clk,
		rx_active		=> rx_active,
		rx_tick			=> rx_tick);


	-- RX baud clock prescaler (rx_tick) start / stop logic
	pr_rx_active_s : process(reset, clk)
	begin
		if reset='1' then
			rx_active <= '0';
		elsif rising_edge(clk) then
			-- falling edge of start bit starts rx_tick
			if rx_start='1' then
				rx_active <= '1';				
			-- rx_tick at stop bit => rx_tick stops
			elsif rx_tick='1' and rx_shift_cs = sh_stop then
				rx_active <= '0';
			end if;
		end if;
	end process pr_rx_active_s;

	
	-- RX FSM state registers
	pr_rx_fsm_reg : process (reset, rx_start, rx_tick, clk)
	begin
		if reset='1' then
			rx_shift_cs <= sh_mark;	-- default state is sh_mark
		-- state changes at falling edge of start bit or at rx_tick
		elsif (rx_start='1' and rx_active='0') or rx_tick='1' then
			if rising_edge(clk) then
				rx_shift_cs <= rx_shift_ns;
			end if;
		end if;
	end process pr_rx_fsm_reg;
	
	
	-- RX FSM next state logic
	pr_rx_fsm_nsl : process (rx_shift_cs)
	begin
		case rx_shift_cs is
            when sh_mark	=> rx_shift_ns <= sh_start;	-- by rx_start='1', also rx_tick starts
            when sh_start	=> rx_shift_ns <= sh_d0;	-- by rx_tick='1'
            when sh_d0		=> rx_shift_ns <= sh_d1;	-- by rx_tick='1'
            when sh_d1		=> rx_shift_ns <= sh_d2;	-- by rx_tick='1'
            when sh_d2		=> rx_shift_ns <= sh_d3;	-- by rx_tick='1'
            when sh_d3		=> rx_shift_ns <= sh_d4;	-- by rx_tick='1'
            when sh_d4		=> rx_shift_ns <= sh_d5;	-- by rx_tick='1'
            when sh_d5		=> rx_shift_ns <= sh_d6;	-- by rx_tick='1'
            when sh_d6		=> rx_shift_ns <= sh_d7;	-- by rx_tick='1'
            when sh_d7		=> rx_shift_ns <= sh_stop;	-- by rx_tick='1'
			when sh_stop	=> rx_shift_ns <= sh_mark;	-- by rx_tick='1', also rx_tick stops
            when others		=> rx_shift_ns <= sh_mark;
		end case;
	end process pr_rx_fsm_nsl;
	
	
	-- Shifting data in. Start bit first then D0 .. D7. Start bit will be discarded
	pr_shift_reg : process (clk, rx_tick, rx_shift_cs)
	begin
		if rx_tick='1' and rx_shift_cs /= sh_stop then
			if rising_edge(clk) then
				shift_reg(7) <= rxd_in;
				for i in 6 downto 0 loop
					shift_reg(i) <= shift_reg(i+1);
				end loop;
			end if;
		end if;
	end process pr_shift_reg;


	-- output shift register 
	rx_sr <= shift_reg;
	
	-- flag to transfer data received in shift register to fifo
	process (reset, clk)
	begin
		if reset='1' then
			rx_sr_trans <= '0';
		elsif rising_edge(clk) then
			if rx_tick='1' and rx_shift_cs=sh_stop then
				rx_sr_trans <= '1';
			else
				rx_sr_trans <= '0';
			end if;
		end if;
	end process;
	
	
end architecture synth;
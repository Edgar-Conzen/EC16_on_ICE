library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package fart_package is

	type t_shift_state is(
	sh_mark, sh_start, sh_d0, sh_d1, sh_d2, sh_d3, sh_d4, sh_d5, sh_d6, sh_d7, sh_stop);	
	
	
	component tx_fsm is
		generic (clockspeed : integer := 12500000);
		port(
			reset			: in std_logic;
			clk				: in std_logic;
			tx_req			: in std_logic;
			tx_parin		: in std_logic_vector (7 downto 0);
			tx_active		: out std_logic;
			tx_serout		: out std_logic);
	end component tx_fsm;

		
	component tx_baudtick is
		generic (clockspeed : integer := 12500000);
		port(
			clk				: in std_logic;
			tx_active		: in std_logic;
			tx_tick			: out std_logic);
	end component tx_baudtick;
	
	
	component fart_transmitter is
		generic(
			clockspeed 	: integer := 12500000;
			tx_nstages	: positive range 1 to 16 := 6;
			dwidth		: positive range 1 to 32 := 8);
		port(
			reset			: in std_logic;
			clk				: in std_logic;
			tx_free			: out std_logic;
			wr_tx			: in std_logic;
			din 			: in std_logic_vector (7 downto 0);
			txd				: out std_logic);
	end component fart_transmitter;

		
	component rx_fsm is
		generic (clockspeed : integer := 12500000);
		port(
			reset			: in std_logic;
			clk				: in std_logic;
			rx_start		: in std_logic;
			rx_sr			: out std_logic_vector (7 downto 0);
			rx_sr_trans		: out std_logic;
			rxd_in			: in std_logic);
	end component rx_fsm;


	component rx_baudtick is
		generic (clockspeed : integer := 12500000);
		port(
			clk				: in std_logic;
			rx_active		: in std_logic;
			rx_tick			: out std_logic);
	end component rx_baudtick;


	component fart_receiver is
		generic(
			clockspeed	: integer := 12500000;
			rx_nstages	: positive range 1 to 16 := 6;
			dwidth		: positive range 1 to 32 := 8);
		port(
			reset			: in std_logic;
			clk			: in std_logic;
			rx_avail		: out std_logic;
			rd_rx			: in std_logic;
			dout 			: out std_logic_vector (7 downto 0);
			rxd				: in std_logic);
	end component fart_receiver;

end package fart_package;
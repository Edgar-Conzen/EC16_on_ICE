library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fart_package.all;
use work.ripplefifo_package.all;

entity fart_receiver is
	generic(
		clockspeed : integer := 12500000;
		rx_nstages	: positive range 1 to 16 := 6;
		dwidth		: positive range 1 to 32 := 8);
	port(
		reset			: in std_logic;
		clk				: in std_logic;
		rx_avail		: out std_logic;
		rd_rx			: in std_logic;
		dout 			: out std_logic_vector (7 downto 0);
		rxd				: in std_logic);
end entity fart_receiver;

architecture synth of fart_receiver is

	signal rx_din_rdy		: std_logic;
	signal rx_start			: std_logic;
	signal rx_wr			: std_logic;
	signal rx_rd			: std_logic;
	signal rx_data			: std_logic_vector (7 downto 0);
	signal rx_sr_trans		: std_logic;
	
	signal pesynff1			: std_logic;
	signal pesynff2			: std_logic;
	signal peprev_state_ff	: std_logic;
	signal nesynff1			: std_logic;
	signal nesynff2			: std_logic;
	signal neprev_state_ff	: std_logic;


begin

	process (rxd, clk)
	begin	
		if rising_edge(clk) then
			nesynff1 <= rxd;
			nesynff2 <= nesynff1;
			neprev_state_ff <= nesynff2;
		end if;
	end process;
	
	rx_start <= neprev_state_ff and not nesynff2;


	c_rx_fsm : rx_fsm
	generic map(clockspeed => clockspeed)
	port map(
		reset			=> reset,
		clk				=> clk,
		rx_start		=> rx_start,
		rx_sr			=> rx_data,
		rx_sr_trans		=> rx_sr_trans,
		rxd_in			=> rxd);			
			

	process (rx_sr_trans, clk)
	begin	
		if rising_edge(clk) then
			pesynff1 <= rx_sr_trans;
			pesynff2 <= pesynff1;
			peprev_state_ff <= pesynff2;
		end if;
	end process;
	
	rx_wr <= not peprev_state_ff and pesynff2;


	c_rx_rfifo : ripple_fifo
	generic map(
		nstages => rx_nstages,
		dwidth	=> dwidth)
	port map(
		reset			=> reset,
		clk				=> clk,
		din_rdy			=> rx_din_rdy,
		wr				=> rx_wr,
		din				=> rx_data,
		dout_rdy		=> rx_avail,
		rd				=> rd_rx,	
		dout			=> dout);

end architecture synth;
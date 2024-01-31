library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fart_package.all;
use work.ripplefifo_package.all;

entity fart_transmitter is
	generic(
		clockspeed : integer := 12500000;
		tx_nstages	: positive range 1 to 16 := 6;
		dwidth		: positive range 1 to 32 := 8);
	port(
		reset			: in std_logic;
		clk				: in std_logic;
		tx_free			: out std_logic;
		wr_tx			: in std_logic;
		din 			: in std_logic_vector (7 downto 0);
		txd				: out std_logic);
end entity fart_transmitter;

architecture synth of fart_transmitter is

	signal tx_req			: std_logic;	
	signal tx_data			: std_logic_vector (7 downto 0);
	signal tx_active		: std_logic;
	signal tx_din_rdy		: std_logic;
	signal tx_dout_rdy		: std_logic;
	signal tx_rd			: std_logic;

	signal pesynff1			: std_logic;
	signal pesynff2			: std_logic;
	signal peprev_state_ff	: std_logic;
	signal nesynff1			: std_logic;
	signal nesynff2			: std_logic;
	signal neprev_state_ff	: std_logic;
	
begin

	c_tx_rfifo : ripple_fifo
	generic map(
		nstages => tx_nstages,
		dwidth	=> dwidth)
	port map(
		reset			=> reset,
		clk				=> clk,
		din_rdy			=> tx_free,
		wr				=> wr_tx,
		din				=> din,
		dout_rdy		=> tx_dout_rdy,
		rd				=> tx_rd,	
		dout			=> tx_data);	


	pe_detect_fr : process (tx_dout_rdy, clk)
	begin	
		if tx_dout_rdy = '0' then 
			pesynff1 <= '0';
			pesynff2 <= '0';
			peprev_state_ff <= '0';
		elsif rising_edge(clk) then
			pesynff1 <= tx_dout_rdy;
			pesynff2 <= pesynff1;
			peprev_state_ff <= pesynff2;
		end if;
	end process;
	
	tx_req <= not peprev_state_ff and pesynff2;
	
	
	ne_detect : process (tx_active, clk)
	begin	
		if rising_edge(clk) then
			nesynff1 <= tx_active;
			nesynff2 <= nesynff1;
			neprev_state_ff <= nesynff2;
		end if;
	end process;
	
	tx_rd <= neprev_state_ff and not nesynff2;


	c_tx_fsm : tx_fsm
	generic map (clockspeed => clockspeed)
	port map(
		reset			=> reset,
		clk				=> clk,
		tx_req			=> tx_req,
		tx_parin		=> tx_data,
		tx_active		=> tx_active,
		tx_serout		=> txd);

end architecture synth;

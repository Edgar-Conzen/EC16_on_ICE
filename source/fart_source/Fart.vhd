library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fart_package.all;

entity fart is
	generic(clockspeed : integer := 12500000); -- freq of clk in Hz
	port(
		reset			: in std_logic;
		clk				: in std_logic;
		sel				: in std_logic;
		addr 			: in std_logic;
		re				: in std_logic;
		we				: in std_logic;
		din 			: in std_logic_vector (7 downto 0);
		dout			: out std_logic_vector (7 downto 0);
		rxd				: in std_logic;
		txd				: out std_logic;
		rx_avail		: out std_logic;
		tx_free			: out std_logic
		);
end entity fart;


architecture synth of fart is		-- constants for fifos
	constant dwidth			: positive := 8;
	constant tx_nstages		: positive := 2;
	constant rx_nstages		: positive := 2;

	signal s_dout_rx		: std_logic_vector (7 downto 0);
	signal s_dout_reg		: std_logic_vector (7 downto 0);
	signal s_tx_free		: std_logic;	signal s_wr_tx			: std_logic;
	signal s_rx_avail		: std_logic;
	signal s_rd_rx			: std_logic;
	signal s_res_reg		: std_logic;

begin
					
	output_reg : process(clk)
	begin
		if rising_edge(clk) then
			if sel='1' then
				if addr = '0' then
					s_dout_reg <= s_dout_rx;
				else
					s_dout_reg <= "000000" & s_tx_free & s_rx_avail;
				end if;
			end if;
		end if;
	end process;
	
	dout <= s_dout_reg;
				
	rx_avail <= s_rx_avail;
	tx_free <= s_tx_free;
	
	s_rd_rx <= '1' when (sel='1' and re='1' and addr='0') else '0';
	s_wr_tx <= '1' when (sel='1' and we='1' and addr='0') else '0';


	c_fart_transmitter : fart_transmitter
		generic map(
			clockspeed => clockspeed,
			tx_nstages => tx_nstages,
			dwidth		=> dwidth)
		port map(
			reset		=> reset,
			clk			=> clk,
			tx_free		=> s_tx_free,
			wr_tx		=> s_wr_tx,
			din 		=> din,
			txd			=> txd);

	c_fart_receiver : fart_receiver
		generic map(
			clockspeed => clockspeed,
			rx_nstages => rx_nstages,
			dwidth		=> dwidth)
		port map(
			reset		=> reset,
			clk			=> clk,
			rx_avail	=> s_rx_avail,
			rd_rx		=> s_rd_rx,
			dout 		=> s_dout_rx,
			rxd			=> rxd);
	-- test

end architecture synth;


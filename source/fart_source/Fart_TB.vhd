library ieee;
use ieee.std_logic_1164.all;

entity tb is
end entity;

architecture sim of tb is

	constant clk_period	: time := 10 ns;
	signal s_clk 		: std_logic := '0';
	
	signal s_reset		: std_logic;
	signal s_sel		: std_logic;
	signal s_addr		: std_logic;
	signal s_re			: std_logic;
	signal s_we			: std_logic;
	signal s_din		: std_logic_vector(7 downto 0);
	signal s_dout		: std_logic_vector(7 downto 0);
	signal s_rxd		: std_logic;
	signal s_txd		: std_logic;
	signal s_rx_avail	: std_logic;
	signal s_tx_free    : std_logic;

	-- component definition of DUT

	component fart is
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
			tx_free			: out std_logic);
	end component fart;
	
begin

	dut : fart
		port map(
			reset		=> s_reset,
		    clk			=> s_clk,
		    sel			=> s_sel,
		    addr 		=> s_addr,
			re			=> s_re,
			we			=> s_we,
		    din 		=> s_din,
		    dout		=> s_dout,
		    rxd			=> s_rxd,
		    txd			=> s_txd,
			rx_avail	=> s_rx_avail,
			tx_free		=> s_tx_free
		);


	clock : process
	begin
		wait for clk_period / 2;
		s_clk <= '1';
		wait for clk_period / 2;
		s_clk <= '0';
	end process clock;

	s_rxd <= s_txd;


	test : process
	begin
		s_sel <= '0';
		s_addr <= '0';
		s_re <= '0';
		s_we <= '0';
		s_din <= x"00";
		wait until rising_edge (s_clk);
		s_reset <= '1';
		wait until rising_edge (s_clk);
		wait until rising_edge (s_clk);
		wait until rising_edge (s_clk);
		s_reset <= '0';
		wait until rising_edge (s_clk);

		wait until falling_edge (s_clk);
		s_din <= x"A1";
		s_sel <= '1';
		s_we <= '1';
		wait until falling_edge (s_clk);
		s_we <= '0';
		s_sel <= '0';
		
		wait until falling_edge (s_clk);
		wait until falling_edge (s_clk);
		s_din <= x"12";
		s_sel <= '1';
		s_we <= '1';
		wait until falling_edge (s_clk);
		s_we <= '0';
		s_sel <= '0';
		
		wait until falling_edge (s_clk);
		wait until falling_edge (s_clk);
		s_din <= x"34";
		s_sel <= '1';
		s_we <= '1';
		wait until falling_edge (s_clk);
		s_we <= '0';
		s_sel <= '0';
		
		s_din <= x"00";

		s_addr <= '0';
		
		wait for 25 us;

		wait until falling_edge (s_clk);
		s_sel <= '1';
		s_re <= '1';
		wait until falling_edge (s_clk);
		s_re <= '0';
		s_sel <= '0';

		wait for 100 ns;
		
		wait until falling_edge (s_clk);
		s_sel <= '1';
		s_re <= '1';
		wait until falling_edge (s_clk);
		s_re <= '0';
		s_sel <= '0';

		

		wait;
	
	end process;

end architecture;

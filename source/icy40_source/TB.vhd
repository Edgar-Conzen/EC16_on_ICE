library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;
-- use VHDL 2008

-- library ice40up;
-- use ice40up.components.all;

entity tb is
end entity;
	
architecture sim of tb is

	constant clk_period	: time := 10 ns;
	signal s_clk 		: std_logic := '0';

	signal s_rst 		: std_logic := '0';
	signal s_irq		: std_logic_vector(3 downto 0) := "0000";
	signal s_btn		: std_logic_vector(4 downto 0) := "00000";
	signal s_led		: std_logic_vector(4 downto 0);

	signal s_SW_DISP_CLK	: std_logic;
	signal s_DISP_DATA		: std_logic;
	signal s_DISP_STB		: std_logic;
	signal s_SW_DATA		: std_logic := '0';
	signal s_SW_STB_N		: std_logic;
	signal s_FTDI_TXD		: std_logic;
	signal s_FTDI_RXD		: std_logic;
	

	-- component definition of DUT
	-- here

	component icy40 is
		port(
			CLK_IN			: in std_logic; -- input from 24 MHz quartz oscillator
			
			BTN				: in std_logic_vector(4 downto 0); -- 5 push buttons, not pressed = '0', pressed = '1'
			LED				: out std_logic_vector(4 downto 0); -- 5 leds, '0' = off, '1' = on

			SW_DISP_CLK		: out std_logic; -- clock signal for shift registers of DIP-Switch and 7-Segment-Display
			DISP_DATA		: out std_logic; -- data to shift register of 7-Segment-Display
			DISP_STB		: out std_logic; -- strobe to shift register of 7-Segment-Display
			SW_DATA			: in std_logic; -- data from shift register of DIP-Switch
			SW_STB_N		: out std_logic; --strobe to shift register of DIP-Switch

			--PMOD			: in std_logic_vector(7 downto 0) -- 8 I/Os for extension with PMOD modules
			
			-- RGB_RD			: out std_logic; -- open collector output to red diode of tricolor led
			-- RGB_GN			: out std_logic; -- open collector output to green diode of tricolor led
			-- RGB_BL			: out std_logic; -- open collector output to blue diode of tricolor led

			-- Watch out! To use the flash set jumpers to flash mode and Port A of FT4232 to BitBang INPUT
			-- FPGA_SCK			: out std_logic; -- to flash
			-- FPGA_DO			: out std_logic; -- to flash
			-- FPGA_DI			: in std_logic; -- from flash
			-- FPGA_SS			: out std_logic; -- to flash

			-- Watch out! Port B of FT4232 has to be in the correct mode (MPSSE)
			-- DBG_SCK			: in std_logic; -- from channel B of FT4232
			-- DBG_DO			: in std_logic; -- from channel B of FT4232
			-- DBG_DI			: out std_logic; -- to channel B of FT4232
			-- DBG_CS			: in std_logic; -- to channel B of FT4232

			-- Watch out! Port C of FT4232 has to be in the correct mode (UART)
			FTDI_TXD			: in std_logic; -- from channel C of FT4232
			FTDI_RXD			: out std_logic -- to channel C of FT4232
			-- FTDI_RTS			: in std_logic; -- from channel C of FT4232
			-- FTDI_CTS			: out std_logic; -- to channel C of FT4232
		);
	end component;

begin

	-- DUT instatiation
	-- here
	s_FTDI_TXD <= '1';
	--s_btn <= s_rst & s_irq;
	
	dut: icy40
		port map(
			CLK_IN			=> s_clk,
			BTN				=> s_btn,
			LED				=> s_led,
			SW_DISP_CLK		=> s_SW_DISP_CLK,
			DISP_DATA		=> s_DISP_DATA,
			DISP_STB		=> s_DISP_STB,
			SW_DATA			=> s_SW_DATA,
			SW_STB_N		=> s_SW_STB_N,
			FTDI_TXD		=> s_FTDI_TXD,
			FTDI_RXD		=> s_FTDI_RXD
			
			--PMOD			=> "00000000"
		);


	clock : process
	begin
		wait for clk_period / 2;
		s_clk <= '1';
		wait for clk_period / 2;
		s_clk <= '0';
	end process clock;


	test : process
	begin
		
		-- initial values
		-- here
		
		
		-- test steps
		-- here

		wait until rising_edge (s_clk);
		s_rst <= '1';
		wait until rising_edge (s_clk);
		wait until rising_edge (s_clk);
		wait until rising_edge (s_clk);
		s_rst <= '0';
		wait until rising_edge (s_clk);
		wait until rising_edge (s_clk);
		wait until rising_edge (s_clk);
		wait until rising_edge (s_clk);
		wait until rising_edge (s_clk);
		wait until rising_edge (s_clk);
		wait until rising_edge (s_clk);
		wait until rising_edge (s_clk);
		wait until rising_edge (s_clk);
		wait until rising_edge (s_clk);
		wait until rising_edge (s_clk);
		wait until rising_edge (s_clk);
		wait until rising_edge (s_clk);
		wait until rising_edge (s_clk);
		wait until rising_edge (s_clk);
		wait until rising_edge (s_clk);
		wait until rising_edge (s_clk);
				
		
wait;
	
	end process;

end architecture;
